-- =====================================================
-- COMPREHENSIVE BUSINESS HOURS VALIDATION & FINAL SETUP
-- This script validates and ensures proper business hours integration
-- =====================================================

-- Step 1: Verify all required components exist
DO $$
BEGIN
    -- Check if business_hours table exists
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'business_hours') THEN
        RAISE EXCEPTION 'business_hours table does not exist. Run business_hours_supabase_migration.sql first.';
    END IF;
    
    -- Check if required columns exist in profiles table
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'business_hours_display') THEN
        RAISE EXCEPTION 'profiles.business_hours_display column does not exist. Run business_hours_supabase_migration.sql first.';
    END IF;
    
    -- Check if required functions exist
    IF NOT EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'set_business_hours') THEN
        RAISE EXCEPTION 'set_business_hours function does not exist. Run business_hours_supabase_migration.sql first.';
    END IF;
    
    RAISE NOTICE 'All required components verified successfully.';
END $$;

-- Step 2: Enhanced trigger function that syncs both ways
CREATE OR REPLACE FUNCTION trigger_update_business_hours_display()
RETURNS TRIGGER AS $$
DECLARE
    profile_uuid UUID;
    formatted_hours TEXT;
BEGIN
    -- Get the profile UUID from the trigger
    profile_uuid := COALESCE(NEW.profile_id, OLD.profile_id);
    
    -- Update the JSONB display field
    PERFORM update_business_hours_display(profile_uuid);
    
    -- Update the legacy opening_hours field for backward compatibility
    SELECT get_business_hours_formatted(profile_uuid) INTO formatted_hours;
    
    UPDATE profiles 
    SET 
        opening_hours = formatted_hours,
        updated_at = NOW()
    WHERE id = profile_uuid;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Ensure the trigger is properly set up
DROP TRIGGER IF EXISTS update_business_hours_display_trigger ON business_hours;
CREATE TRIGGER update_business_hours_display_trigger
    AFTER INSERT OR UPDATE OR DELETE ON business_hours
    FOR EACH ROW EXECUTE FUNCTION trigger_update_business_hours_display();

-- Step 3: Function to validate business hours integrity
CREATE OR REPLACE FUNCTION validate_business_hours_integrity()
RETURNS TABLE (
    profile_id UUID,
    vendor_name TEXT,
    has_legacy_hours BOOLEAN,
    has_structured_hours BOOLEAN,
    hours_match BOOLEAN,
    issue_description TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as profile_id,
        p.name as vendor_name,
        (p.opening_hours IS NOT NULL AND p.opening_hours != '') as has_legacy_hours,
        (SELECT COUNT(*) > 0 FROM business_hours bh WHERE bh.profile_id = p.id) as has_structured_hours,
        CASE 
            WHEN p.opening_hours IS NULL OR p.opening_hours = '' THEN 
                (SELECT COUNT(*) = 0 FROM business_hours bh WHERE bh.profile_id = p.id)
            ELSE 
                p.opening_hours = get_business_hours_formatted(p.id)
        END as hours_match,
        CASE 
            WHEN p.opening_hours IS NULL OR p.opening_hours = '' THEN
                CASE 
                    WHEN (SELECT COUNT(*) = 0 FROM business_hours bh WHERE bh.profile_id = p.id) THEN
                        'No business hours data found'
                    ELSE 
                        'Has structured hours but missing legacy field'
                END
            WHEN (SELECT COUNT(*) = 0 FROM business_hours bh WHERE bh.profile_id = p.id) THEN
                'Has legacy hours but missing structured data'
            WHEN p.opening_hours != get_business_hours_formatted(p.id) THEN
                'Legacy and structured hours do not match'
            ELSE 
                'OK'
        END as issue_description
    FROM profiles p
    WHERE p.user_type = 'vendor'
    ORDER BY vendor_name;
END;
$$ LANGUAGE plpgsql;

-- Step 4: Function to fix any inconsistencies
CREATE OR REPLACE FUNCTION fix_business_hours_inconsistencies()
RETURNS INTEGER AS $$
DECLARE
    vendor_record RECORD;
    fixed_count INTEGER := 0;
BEGIN
    FOR vendor_record IN 
        SELECT * FROM validate_business_hours_integrity()
        WHERE NOT hours_match OR issue_description != 'OK'
    LOOP
        CASE 
            -- Has structured but missing legacy
            WHEN vendor_record.has_structured_hours AND NOT vendor_record.has_legacy_hours THEN
                UPDATE profiles 
                SET opening_hours = get_business_hours_formatted(vendor_record.profile_id)
                WHERE id = vendor_record.profile_id;
                fixed_count := fixed_count + 1;
                
            -- Has legacy but missing structured
            WHEN vendor_record.has_legacy_hours AND NOT vendor_record.has_structured_hours THEN
                -- Set default hours and let the Flutter app handle specific updates
                PERFORM set_default_business_hours(vendor_record.profile_id);
                fixed_count := fixed_count + 1;
                
            -- Both exist but don't match - prefer structured data
            WHEN vendor_record.has_structured_hours AND vendor_record.has_legacy_hours AND NOT vendor_record.hours_match THEN
                UPDATE profiles 
                SET opening_hours = get_business_hours_formatted(vendor_record.profile_id)
                WHERE id = vendor_record.profile_id;
                fixed_count := fixed_count + 1;
                
            -- No data at all - set defaults
            WHEN NOT vendor_record.has_structured_hours AND NOT vendor_record.has_legacy_hours THEN
                PERFORM set_default_business_hours(vendor_record.profile_id);
                fixed_count := fixed_count + 1;
        END CASE;
    END LOOP;
    
    RETURN fixed_count;
END;
$$ LANGUAGE plpgsql;

-- Step 5: Create a convenience view for debugging
CREATE OR REPLACE VIEW business_hours_debug AS
SELECT 
    p.id,
    p.name,
    p.facility_name,
    p.opening_hours as legacy_hours,
    p.business_hours_display as structured_display,
    get_business_hours_formatted(p.id) as formatted_hours,
    is_business_currently_open(p.id) as currently_open,
    (SELECT COUNT(*) FROM business_hours bh WHERE bh.profile_id = p.id) as business_hours_count
FROM profiles p
WHERE p.user_type = 'vendor'
ORDER BY p.name;

-- =====================================================
-- EXECUTION COMMANDS (uncomment to run)
-- =====================================================

-- Validate current state
-- SELECT * FROM validate_business_hours_integrity();

-- Fix any inconsistencies
-- SELECT fix_business_hours_inconsistencies();

-- Check debug view
-- SELECT * FROM business_hours_debug;

-- Test specific vendor's hours
-- SELECT * FROM vendor_business_hours WHERE profile_id = 'your-vendor-uuid-here';

-- =====================================================
-- TESTING FUNCTIONS
-- =====================================================

-- Function to test business hours operations
CREATE OR REPLACE FUNCTION test_business_hours_operations(test_profile_id UUID)
RETURNS TEXT AS $$
DECLARE
    result TEXT := '';
    test_result BOOLEAN;
    formatted_hours TEXT;
BEGIN
    result := result || 'Testing business hours for profile: ' || test_profile_id || E'\n';
    
    -- Test 1: Set specific hours
    result := result || 'Test 1: Setting Monday 9-17...' || E'\n';
    PERFORM set_business_hours(test_profile_id, 1, true, '09:00', '17:00', NULL, NULL, false, 'Test hours');
    SELECT get_business_hours_formatted(test_profile_id) INTO formatted_hours;
    result := result || 'Formatted result: ' || COALESCE(formatted_hours, 'NULL') || E'\n';
    
    -- Test 2: Check if currently open function works
    result := result || 'Test 2: Checking current status...' || E'\n';
    SELECT is_business_currently_open(test_profile_id) INTO test_result;
    result := result || 'Currently open: ' || test_result::TEXT || E'\n';
    
    -- Test 3: Set default hours
    result := result || 'Test 3: Setting default hours...' || E'\n';
    PERFORM set_default_business_hours(test_profile_id);
    SELECT get_business_hours_formatted(test_profile_id) INTO formatted_hours;
    result := result || 'Default hours result: ' || COALESCE(formatted_hours, 'NULL') || E'\n';
    
    result := result || 'All tests completed successfully!' || E'\n';
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- USAGE INSTRUCTIONS
-- =====================================================

-- 1. First run validation:
--    SELECT * FROM validate_business_hours_integrity();

-- 2. Fix any issues:
--    SELECT fix_business_hours_inconsistencies();

-- 3. Test with a specific vendor:
--    SELECT test_business_hours_operations('your-vendor-uuid');

-- 4. Monitor the debug view:
--    SELECT * FROM business_hours_debug;

-- 5. For ongoing monitoring, check if legacy and structured hours stay in sync:
--    SELECT * FROM business_hours_debug WHERE legacy_hours != formatted_hours;
