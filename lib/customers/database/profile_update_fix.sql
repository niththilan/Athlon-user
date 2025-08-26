-- =====================================================
-- PROFILE UPDATE ISSUES FIX
-- This script addresses all profile update issues
-- =====================================================

-- Step 1: Ensure all required columns exist in profiles table
DO $$
BEGIN
    -- Add latitude column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'profiles' AND column_name = 'latitude') THEN
        ALTER TABLE profiles ADD COLUMN latitude DECIMAL(10, 8);
        ALTER TABLE profiles ADD CONSTRAINT check_latitude_range 
            CHECK (latitude >= -90 AND latitude <= 90);
        COMMENT ON COLUMN profiles.latitude IS 'GPS latitude coordinate for facility location (-90 to 90)';
    END IF;

    -- Add longitude column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'profiles' AND column_name = 'longitude') THEN
        ALTER TABLE profiles ADD COLUMN longitude DECIMAL(11, 8);
        ALTER TABLE profiles ADD CONSTRAINT check_longitude_range 
            CHECK (longitude >= -180 AND longitude <= 180);
        COMMENT ON COLUMN profiles.longitude IS 'GPS longitude coordinate for facility location (-180 to 180)';
    END IF;

    -- Add timezone column if it doesn't exist (for business hours)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'profiles' AND column_name = 'timezone') THEN
        ALTER TABLE profiles ADD COLUMN timezone TEXT DEFAULT 'Asia/Kolkata';
        COMMENT ON COLUMN profiles.timezone IS 'Timezone for business hours calculations';
    END IF;

    -- Add business_hours_display column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'profiles' AND column_name = 'business_hours_display') THEN
        ALTER TABLE profiles ADD COLUMN business_hours_display JSONB;
        COMMENT ON COLUMN profiles.business_hours_display IS 'Computed JSON from business_hours table';
    END IF;

    RAISE NOTICE 'All required profile columns verified and added if missing.';
END $$;

-- Step 2: Create location index if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_profiles_location ON profiles(latitude, longitude);

-- Step 3: Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 4: Create trigger for profiles table if it doesn't exist
DROP TRIGGER IF EXISTS update_profiles_timestamp ON profiles;
CREATE TRIGGER update_profiles_timestamp
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Step 5: Enable RLS (Row Level Security) on profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Step 6: Create RLS policies for profile access
-- Policy for users to read their own profile
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
CREATE POLICY "Users can read own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Policy for users to update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Policy for users to insert their own profile
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Step 7: Grant necessary permissions
GRANT ALL ON profiles TO authenticated;
GRANT ALL ON profiles TO anon;

-- Step 8: Verify all columns exist
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name IN (
    'id', 'name', 'phone', 'facility_name', 'location', 'full_address', 
    'website', 'opening_hours', 'status', 'latitude', 'longitude', 
    'timezone', 'business_hours_display', 'created_at', 'updated_at'
)
ORDER BY column_name;

-- Step 9: Test profile update function
CREATE OR REPLACE FUNCTION test_profile_update(test_user_id UUID)
RETURNS TEXT AS $$
DECLARE
    result TEXT := '';
    update_count INTEGER;
BEGIN
    -- Test updating various profile fields
    UPDATE profiles 
    SET 
        name = 'Test Facility Updated',
        location = 'Test Location Updated',
        full_address = 'Test Address Updated',
        website = 'https://test-updated.com',
        status = 'Test Status Updated',
        phone = '+1234567890',
        latitude = 40.7128,
        longitude = -74.0060,
        updated_at = NOW()
    WHERE id = test_user_id;
    
    GET DIAGNOSTICS update_count = ROW_COUNT;
    
    IF update_count > 0 THEN
        result := 'SUCCESS: Profile updated successfully for user ' || test_user_id;
    ELSE
        result := 'ERROR: No rows updated for user ' || test_user_id || '. User may not exist or RLS policy may be blocking the update.';
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Step 10: Diagnostic function to check user permissions
CREATE OR REPLACE FUNCTION diagnose_profile_access(user_id UUID)
RETURNS TABLE (
    check_name TEXT,
    status TEXT,
    details TEXT
) AS $$
BEGIN
    -- Check if user exists in auth.users
    RETURN QUERY
    SELECT 
        'User exists in auth.users'::TEXT,
        CASE WHEN EXISTS (SELECT 1 FROM auth.users WHERE id = user_id) 
             THEN 'PASS' ELSE 'FAIL' END::TEXT,
        CASE WHEN EXISTS (SELECT 1 FROM auth.users WHERE id = user_id) 
             THEN 'User found in auth.users table' 
             ELSE 'User not found in auth.users table' END::TEXT;

    -- Check if profile exists
    RETURN QUERY
    SELECT 
        'Profile exists'::TEXT,
        CASE WHEN EXISTS (SELECT 1 FROM profiles WHERE id = user_id) 
             THEN 'PASS' ELSE 'FAIL' END::TEXT,
        CASE WHEN EXISTS (SELECT 1 FROM profiles WHERE id = user_id) 
             THEN 'Profile found in profiles table' 
             ELSE 'Profile not found in profiles table' END::TEXT;

    -- Check RLS policies
    RETURN QUERY
    SELECT 
        'RLS enabled'::TEXT,
        CASE WHEN (SELECT relrowsecurity FROM pg_class WHERE relname = 'profiles') 
             THEN 'ENABLED' ELSE 'DISABLED' END::TEXT,
        'Row Level Security status'::TEXT;

    -- Check if all required columns exist
    RETURN QUERY
    SELECT 
        'Required columns exist'::TEXT,
        CASE WHEN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_name = 'profiles' 
            AND column_name IN ('latitude', 'longitude', 'timezone', 'business_hours_display')
        ) = 4 THEN 'PASS' ELSE 'FAIL' END::TEXT,
        'Checking latitude, longitude, timezone, business_hours_display columns'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- USAGE INSTRUCTIONS
-- =====================================================

-- 1. Run this entire script in your Supabase SQL Editor

-- 2. Test with a specific user ID:
-- SELECT test_profile_update('your-user-uuid-here');

-- 3. Diagnose access issues:
-- SELECT * FROM diagnose_profile_access('your-user-uuid-here');

-- 4. Check if your current user can update profiles:
-- UPDATE profiles SET updated_at = NOW() WHERE id = auth.uid();

-- 5. Verify all columns exist:
-- SELECT column_name FROM information_schema.columns WHERE table_name = 'profiles' ORDER BY column_name;

-- =====================================================
-- COMMON ISSUES AND SOLUTIONS
-- =====================================================

-- Issue 1: "column does not exist"
-- Solution: Run this script to add missing columns

-- Issue 2: "permission denied" or "RLS policy violation"
-- Solution: The RLS policies above should fix this

-- Issue 3: "No rows updated"
-- Solution: Check if the user exists and RLS policies are correct

-- Issue 4: Business hours not updating
-- Solution: Ensure business_hours table exists and triggers are set up

-- =====================================================
-- MONITORING QUERIES
-- =====================================================

-- Check recent profile updates
-- SELECT id, name, facility_name, updated_at 
-- FROM profiles 
-- WHERE updated_at > NOW() - INTERVAL '1 hour'
-- ORDER BY updated_at DESC;

-- Check for profiles missing required data
-- SELECT id, name, facility_name, 
--        CASE WHEN latitude IS NULL THEN 'Missing latitude' ELSE 'Has latitude' END as lat_status,
--        CASE WHEN longitude IS NULL THEN 'Missing longitude' ELSE 'Has longitude' END as lng_status
-- FROM profiles 
-- WHERE user_type = 'vendor';
