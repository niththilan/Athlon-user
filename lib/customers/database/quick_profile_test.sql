-- =====================================================
-- QUICK PROFILE UPDATE TEST
-- Run this to test if profile updates are working
-- =====================================================

-- Test 1: Check if your current user can be identified
SELECT 
    'Current User ID: ' || COALESCE(auth.uid()::text, 'NOT AUTHENTICATED') as user_check;

-- Test 2: Check if profile exists for current user
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Profile EXISTS for current user'
        ELSE 'Profile DOES NOT EXIST for current user'
    END as profile_check
FROM profiles 
WHERE id = auth.uid();

-- Test 3: Try a simple profile update
UPDATE profiles 
SET 
    updated_at = NOW(),
    status = COALESCE(status, 'Test Update - ' || NOW()::text)
WHERE id = auth.uid();

-- Test 4: Check if the update worked
SELECT 
    id, 
    name, 
    facility_name,
    status,
    updated_at,
    'UPDATE SUCCESSFUL' as result
FROM profiles 
WHERE id = auth.uid();

-- Test 5: Check all profile columns that the Flutter app updates
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name IN (
    'facility_name', 'name', 'phone', 'location', 'full_address', 
    'website', 'status', 'opening_hours', 'latitude', 'longitude'
)
ORDER BY column_name;

-- Test 6: Check RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'profiles';

-- If the above tests show issues, run these fixes:

-- Fix 1: Ensure RLS allows updates
-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
-- DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
-- CREATE POLICY "Users can update own profile" ON profiles
--     FOR UPDATE USING (auth.uid() = id);

-- Fix 2: Add missing columns if needed
-- ALTER TABLE profiles ADD COLUMN IF NOT EXISTS latitude DECIMAL(10, 8);
-- ALTER TABLE profiles ADD COLUMN IF NOT EXISTS longitude DECIMAL(11, 8);

-- Fix 3: Grant permissions
-- GRANT ALL ON profiles TO authenticated;
-- GRANT ALL ON profiles TO anon;
