-- Migration: Add country_code and google_signin columns to profiles table
-- Date: 2025-01-16
-- Purpose: Support automatic country code detection and Google Sign-In tracking

-- Add country_code column to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS country_code TEXT DEFAULT '+94';

-- Add google_signin flag to track Google Sign-In registrations
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS is_google_signin BOOLEAN DEFAULT false;

-- Update the create_user_profile_on_signup function to support country code
DROP FUNCTION IF EXISTS create_user_profile_on_signup(UUID, TEXT, TEXT, TEXT, TEXT, TEXT);
CREATE OR REPLACE FUNCTION create_user_profile_on_signup(
    user_id UUID,
    user_name TEXT,
    user_phone TEXT DEFAULT NULL,
    user_facility_name TEXT DEFAULT NULL,
    user_type TEXT DEFAULT 'vendor',
    user_location TEXT DEFAULT NULL,
    user_country_code TEXT DEFAULT '+94',
    is_google_signin BOOLEAN DEFAULT false
)
RETURNS VOID AS $$
BEGIN
    -- Validate input parameters
    IF user_id IS NULL OR user_name IS NULL OR user_name = '' THEN
        RAISE EXCEPTION 'user_id and user_name are required';
    END IF;
    
    -- Create or update profile with country code support
    INSERT INTO profiles (
        id, 
        name, 
        phone, 
        facility_name, 
        user_type, 
        location, 
        country_code,
        is_google_signin
    )
    VALUES (
        user_id, 
        user_name, 
        NULLIF(user_phone, ''), 
        NULLIF(user_facility_name, ''), 
        COALESCE(user_type, 'vendor'), 
        NULLIF(user_location, ''),
        COALESCE(user_country_code, '+94'),
        COALESCE(is_google_signin, false)
    )
    ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        phone = EXCLUDED.phone,
        facility_name = EXCLUDED.facility_name,
        user_type = EXCLUDED.user_type,
        location = EXCLUDED.location,
        country_code = EXCLUDED.country_code,
        is_google_signin = EXCLUDED.is_google_signin,
        updated_at = NOW();
    
EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Error creating user profile: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Update existing profiles with default country code if null
UPDATE profiles 
SET country_code = '+94' 
WHERE country_code IS NULL;
