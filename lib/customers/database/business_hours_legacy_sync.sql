-- =====================================================
-- LEGACY SYNC MIGRATION FOR BUSINESS HOURS
-- This ensures backward compatibility by updating the 
-- legacy opening_hours field when business_hours changes
-- =====================================================

-- Enhanced trigger function to update both business_hours_display and legacy opening_hours
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

-- Create or replace function to sync legacy field when profiles are created
CREATE OR REPLACE FUNCTION sync_business_hours_to_legacy(profile_uuid UUID)
RETURNS VOID AS $$
DECLARE
    formatted_hours TEXT;
BEGIN
    -- Get formatted business hours
    SELECT get_business_hours_formatted(profile_uuid) INTO formatted_hours;
    
    -- Update the legacy field
    UPDATE profiles 
    SET 
        opening_hours = formatted_hours,
        updated_at = NOW()
    WHERE id = profile_uuid;
END;
$$ LANGUAGE plpgsql;

-- Function to migrate existing opening_hours data to business_hours table
CREATE OR REPLACE FUNCTION migrate_legacy_opening_hours_to_structured()
RETURNS INTEGER AS $$
DECLARE
    profile_record RECORD;
    migrated_count INTEGER := 0;
    day_line TEXT;
    day_parts TEXT[];
    day_name TEXT;
    time_parts TEXT[];
    opening_time TIME;
    closing_time TIME;
    day_num INTEGER;
BEGIN
    -- Process each vendor profile that has opening_hours but no business_hours entries
    FOR profile_record IN 
        SELECT p.id, p.opening_hours
        FROM profiles p
        LEFT JOIN business_hours bh ON p.id = bh.profile_id
        WHERE p.user_type = 'vendor' 
        AND p.opening_hours IS NOT NULL 
        AND p.opening_hours != ''
        AND bh.profile_id IS NULL
    LOOP
        -- Parse the opening_hours string and create business_hours entries
        -- Split by newlines
        FOREACH day_line IN ARRAY string_to_array(profile_record.opening_hours, E'\n')
        LOOP
            day_line := trim(day_line);
            IF day_line != '' AND position(':' in day_line) > 0 THEN
                -- Split day and times
                day_parts := string_to_array(day_line, ':');
                IF array_length(day_parts, 1) >= 2 THEN
                    day_name := trim(day_parts[1]);
                    
                    -- Convert day name to number
                    day_num := CASE lower(day_name)
                        WHEN 'sunday' THEN 0
                        WHEN 'monday' THEN 1
                        WHEN 'tuesday' THEN 2
                        WHEN 'wednesday' THEN 3
                        WHEN 'thursday' THEN 4
                        WHEN 'friday' THEN 5
                        WHEN 'saturday' THEN 6
                        ELSE NULL
                    END;
                    
                    IF day_num IS NOT NULL THEN
                        -- Parse times
                        IF lower(day_parts[2]) LIKE '%closed%' THEN
                            -- Day is closed
                            INSERT INTO business_hours (profile_id, day_of_week, is_open, notes)
                            VALUES (profile_record.id, day_num, false, 'Migrated from legacy data')
                            ON CONFLICT (profile_id, day_of_week) DO NOTHING;
                        ELSIF position('-' in day_parts[2]) > 0 THEN
                            -- Parse time range
                            time_parts := string_to_array(trim(day_parts[2]), '-');
                            IF array_length(time_parts, 1) = 2 THEN
                                BEGIN
                                    -- Try to parse times (basic format)
                                    opening_time := trim(time_parts[1])::TIME;
                                    closing_time := trim(time_parts[2])::TIME;
                                    
                                    INSERT INTO business_hours (
                                        profile_id, day_of_week, is_open, 
                                        opening_time, closing_time, notes
                                    )
                                    VALUES (
                                        profile_record.id, day_num, true, 
                                        opening_time, closing_time, 
                                        'Migrated from legacy data'
                                    )
                                    ON CONFLICT (profile_id, day_of_week) DO NOTHING;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        -- If time parsing fails, just mark as open without specific times
                                        INSERT INTO business_hours (profile_id, day_of_week, is_open, notes)
                                        VALUES (profile_record.id, day_num, true, 'Migrated - manual review needed')
                                        ON CONFLICT (profile_id, day_of_week) DO NOTHING;
                                END;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END LOOP;
        
        migrated_count := migrated_count + 1;
    END LOOP;
    
    RETURN migrated_count;
END;
$$ LANGUAGE plpgsql;

-- Function to bulk set default hours for vendors without business hours
CREATE OR REPLACE FUNCTION set_default_hours_for_vendors_without_business_hours()
RETURNS INTEGER AS $$
DECLARE
    profile_record RECORD;
    updated_count INTEGER := 0;
BEGIN
    FOR profile_record IN 
        SELECT p.id
        FROM profiles p
        LEFT JOIN business_hours bh ON p.id = bh.profile_id
        WHERE p.user_type = 'vendor' 
        AND bh.profile_id IS NULL
    LOOP
        PERFORM set_default_business_hours(profile_record.id);
        updated_count := updated_count + 1;
    END LOOP;
    
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- Run the migration (uncomment to execute)
-- SELECT migrate_legacy_opening_hours_to_structured();

-- For vendors without any business hours data, set default hours (uncomment to execute)
-- SELECT set_default_hours_for_vendors_without_business_hours();

-- Sync all existing structured business hours to legacy field (uncomment to execute)
-- SELECT sync_business_hours_to_legacy(id) FROM profiles WHERE user_type = 'vendor';

-- =====================================================
-- USAGE INSTRUCTIONS
-- =====================================================

-- To run the full migration:
-- 1. Execute: SELECT migrate_legacy_opening_hours_to_structured();
-- 2. Execute: SELECT set_default_hours_for_vendors_without_business_hours();
-- 3. Execute: SELECT sync_business_hours_to_legacy(id) FROM profiles WHERE user_type = 'vendor';

-- To check migration status:
-- SELECT 
--     p.id,
--     p.name,
--     p.opening_hours,
--     COUNT(bh.id) as business_hours_entries
-- FROM profiles p
-- LEFT JOIN business_hours bh ON p.id = bh.profile_id
-- WHERE p.user_type = 'vendor'
-- GROUP BY p.id, p.name, p.opening_hours
-- ORDER BY business_hours_entries, p.name;
