-- =====================================================
-- FIX PROFILE RLS POLICIES
-- =====================================================
-- This script fixes the Row Level Security (RLS) policies for the profiles table
-- to allow users to create and manage their own profiles

-- First, check if RLS is enabled on profiles table
-- If this query returns 'true', then RLS is enabled
-- SELECT relrowsecurity FROM pg_class WHERE relname = 'profiles';

-- Enable RLS on profiles table (if not already enabled)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Public can view profiles" ON profiles;

-- Policy 1: Allow users to view their own profile
CREATE POLICY "Users can view their own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Policy 2: Allow users to insert their own profile (this is the key one for fixing the error)
CREATE POLICY "Users can insert their own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Policy 3: Allow users to update their own profile
CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Policy 4: Allow public to view profiles (for public browsing of facilities)
-- This allows customers to see vendor profiles
CREATE POLICY "Public can view profiles" ON profiles
    FOR SELECT USING (true);

-- Grant necessary permissions to authenticated users
GRANT SELECT, INSERT, UPDATE ON profiles TO authenticated;
GRANT SELECT ON profiles TO anon;

-- Also ensure the RPC function has proper permissions
-- Grant execute permissions to authenticated users for the profile creation function
GRANT EXECUTE ON FUNCTION create_user_profile_on_signup(UUID, TEXT, TEXT, TEXT, TEXT, TEXT) TO authenticated;

-- Additional: Make sure the function runs with proper security context
-- This ensures the function can bypass RLS when creating profiles
ALTER FUNCTION create_user_profile_on_signup(UUID, TEXT, TEXT, TEXT, TEXT, TEXT) SECURITY DEFINER;

-- Verify the policies are created correctly
-- You can run these queries to check:
-- SELECT * FROM pg_policies WHERE tablename = 'profiles';
-- SELECT auth.uid(); -- Should return the current user's UUID when authenticated

COMMENT ON POLICY "Users can view their own profile" ON profiles IS 'Allows users to view their own profile data';
COMMENT ON POLICY "Users can insert their own profile" ON profiles IS 'Allows users to create their own profile during signup';
COMMENT ON POLICY "Users can update their own profile" ON profiles IS 'Allows users to update their own profile information';
COMMENT ON POLICY "Public can view profiles" ON profiles IS 'Allows public access to view vendor profiles for browsing facilities';
