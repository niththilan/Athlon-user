# Profile Creation RLS Policy Fix

## Problem
Users are getting the error: "PostgrestException(message: new row violates row-level security policy for table "profiles", code: 42501, details: Forbidden, hint: null)" when trying to create accounts.

## Root Cause
The `profiles` table has Row Level Security (RLS) enabled, but the necessary policies to allow users to create their own profiles are missing or incorrectly configured.

## Solution

### Step 1: Run the RLS Policy Fix Script
1. Open your Supabase dashboard
2. Go to the SQL Editor
3. Copy and paste the content of `database/fix_profile_rls_policies.sql`
4. Run the script

### Step 2: Verify the Fix
After running the script, you can verify the policies are working by:

1. **Check if policies exist:**
```sql
SELECT * FROM pg_policies WHERE tablename = 'profiles';
```

2. **Test profile creation:**
```sql
-- This should work when authenticated as a user
INSERT INTO profiles (id, name, user_type) 
VALUES (auth.uid(), 'Test User', 'vendor');
```

### Step 3: Test in Your App
After applying the database fixes:
1. Try creating a new account
2. The error should no longer occur
3. Profile creation should work smoothly

## What the Fix Does

The `fix_profile_rls_policies.sql` script:

1. **Enables RLS** on the profiles table (if not already enabled)
2. **Creates necessary policies:**
   - `Users can view their own profile` - Users can read their own data
   - `Users can insert their own profile` - **This fixes the creation error**
   - `Users can update their own profile` - Users can modify their own data
   - `Public can view profiles` - Allows browsing of vendor profiles
3. **Grants proper permissions** to authenticated and anonymous users
4. **Makes the RPC function secure** by setting it as SECURITY DEFINER

## Alternative Manual Fix

If you prefer to run the commands manually in Supabase SQL Editor:

```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to insert their own profile (key fix)
CREATE POLICY "Users can insert their own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow users to view their own profile
CREATE POLICY "Users can view their own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Allow public to view profiles (for browsing)
CREATE POLICY "Public can view profiles" ON profiles
    FOR SELECT USING (true);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON profiles TO authenticated;
GRANT SELECT ON profiles TO anon;
```

## Important Notes

- The `auth.uid()` function returns the current user's UUID when they're authenticated
- The `WITH CHECK (auth.uid() = id)` ensures users can only create profiles with their own user ID
- The RPC function `create_user_profile_on_signup` is set as `SECURITY DEFINER` to bypass RLS when necessary
- Public read access allows customers to browse vendor profiles without authentication

After applying these fixes, the profile creation error should be resolved!
