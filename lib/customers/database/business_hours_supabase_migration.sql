-- =====================================================
-- BUSINESS HOURS MIGRATION - SUPABASE COMMANDS
-- Execute these commands in your Supabase SQL Editor
-- =====================================================

-- Step 1: Add new columns to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS timezone TEXT DEFAULT 'Asia/Kolkata',
ADD COLUMN IF NOT EXISTS business_hours_display JSONB;

-- Step 2: Update the opening_hours column comment
COMMENT ON COLUMN profiles.opening_hours IS 'Legacy field - use business_hours table for structured hours';

-- Step 3: Create business_hours table
CREATE TABLE IF NOT EXISTS business_hours (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Sunday, 1=Monday, ..., 6=Saturday
    is_open BOOLEAN DEFAULT true,
    opening_time TIME,
    closing_time TIME,
    break_start_time TIME, -- Optional lunch/break time
    break_end_time TIME,   -- Optional lunch/break time
    is_24_hours BOOLEAN DEFAULT false,
    notes TEXT, -- Special notes for the day (e.g., "Holiday hours", "By appointment only")
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(profile_id, day_of_week)
);

-- Step 4: Create indexes for business_hours table
CREATE INDEX IF NOT EXISTS idx_business_hours_profile ON business_hours(profile_id);
CREATE INDEX IF NOT EXISTS idx_business_hours_day ON business_hours(day_of_week);
CREATE INDEX IF NOT EXISTS idx_business_hours_open ON business_hours(is_open);

-- Step 5: Create or replace the business hours functions
CREATE OR REPLACE FUNCTION update_business_hours_display(profile_uuid UUID)
RETURNS VOID AS $$
DECLARE
    hours_json JSONB;
BEGIN
    -- Build business hours JSON from business_hours table
    SELECT json_agg(
        json_build_object(
            'day_of_week', day_of_week,
            'day_name', CASE day_of_week
                WHEN 0 THEN 'Sunday'
                WHEN 1 THEN 'Monday'
                WHEN 2 THEN 'Tuesday'
                WHEN 3 THEN 'Wednesday'
                WHEN 4 THEN 'Thursday'
                WHEN 5 THEN 'Friday'
                WHEN 6 THEN 'Saturday'
            END,
            'is_open', is_open,
            'opening_time', opening_time::TEXT,
            'closing_time', closing_time::TEXT,
            'break_start_time', break_start_time::TEXT,
            'break_end_time', break_end_time::TEXT,
            'is_24_hours', is_24_hours,
            'notes', notes
        ) ORDER BY day_of_week
    )::JSONB INTO hours_json
    FROM business_hours
    WHERE profile_id = profile_uuid;
    
    -- Update profiles table with computed display JSON
    UPDATE profiles 
    SET 
        business_hours_display = hours_json,
        updated_at = NOW()
    WHERE id = profile_uuid;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_business_hours(
    profile_uuid UUID,
    day_num INTEGER,
    is_open_param BOOLEAN DEFAULT true,
    open_time TIME DEFAULT NULL,
    close_time TIME DEFAULT NULL,
    break_start TIME DEFAULT NULL,
    break_end TIME DEFAULT NULL,
    is_24h BOOLEAN DEFAULT false,
    day_notes TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO business_hours (
        profile_id, day_of_week, is_open, opening_time, closing_time,
        break_start_time, break_end_time, is_24_hours, notes
    ) VALUES (
        profile_uuid, day_num, is_open_param, open_time, close_time,
        break_start, break_end, is_24h, day_notes
    )
    ON CONFLICT (profile_id, day_of_week) DO UPDATE SET
        is_open = EXCLUDED.is_open,
        opening_time = EXCLUDED.opening_time,
        closing_time = EXCLUDED.closing_time,
        break_start_time = EXCLUDED.break_start_time,
        break_end_time = EXCLUDED.break_end_time,
        is_24_hours = EXCLUDED.is_24_hours,
        notes = EXCLUDED.notes,
        updated_at = NOW();
    
    -- Update the display JSON
    PERFORM update_business_hours_display(profile_uuid);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_business_currently_open(profile_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    current_day INTEGER;
    current_time TIME;
    business_info RECORD;
    is_open BOOLEAN := false;
BEGIN
    -- Get current day (0=Sunday) and time in profile's timezone
    SELECT 
        EXTRACT(DOW FROM NOW() AT TIME ZONE COALESCE(p.timezone, 'Asia/Kolkata'))::INTEGER,
        (NOW() AT TIME ZONE COALESCE(p.timezone, 'Asia/Kolkata'))::TIME
    INTO current_day, current_time
    FROM profiles p WHERE p.id = profile_uuid;
    
    -- Get business hours for current day
    SELECT * INTO business_info
    FROM business_hours
    WHERE profile_id = profile_uuid AND day_of_week = current_day;
    
    IF business_info IS NULL OR business_info.is_open = false THEN
        RETURN false;
    END IF;
    
    -- Check if 24 hours
    IF business_info.is_24_hours = true THEN
        RETURN true;
    END IF;
    
    -- Check if within business hours
    IF business_info.opening_time IS NOT NULL AND business_info.closing_time IS NOT NULL THEN
        -- Handle cases where closing time is next day (e.g., 10 PM to 2 AM)
        IF business_info.closing_time < business_info.opening_time THEN
            -- Business hours span midnight
            is_open := (current_time >= business_info.opening_time OR current_time <= business_info.closing_time);
        ELSE
            -- Normal business hours within same day
            is_open := (current_time >= business_info.opening_time AND current_time <= business_info.closing_time);
        END IF;
        
        -- Check if currently in break time
        IF is_open AND business_info.break_start_time IS NOT NULL AND business_info.break_end_time IS NOT NULL THEN
            IF current_time >= business_info.break_start_time AND current_time <= business_info.break_end_time THEN
                is_open := false;
            END IF;
        END IF;
    END IF;
    
    RETURN is_open;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_default_business_hours(profile_uuid UUID)
RETURNS VOID AS $$
BEGIN
    -- Monday to Friday: 9 AM - 6 PM
    FOR i IN 1..5 LOOP
        PERFORM set_business_hours(
            profile_uuid, 
            i, 
            true, 
            '09:00'::TIME, 
            '18:00'::TIME,
            NULL,
            NULL,
            false,
            'Regular business hours'
        );
    END LOOP;
    
    -- Saturday: 9 AM - 2 PM
    PERFORM set_business_hours(
        profile_uuid, 
        6, 
        true, 
        '09:00'::TIME, 
        '14:00'::TIME,
        NULL,
        NULL,
        false,
        'Half day'
    );
    
    -- Sunday: Closed
    PERFORM set_business_hours(
        profile_uuid, 
        0, 
        false,
        NULL,
        NULL,
        NULL,
        NULL,
        false,
        'Closed on Sundays'
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_business_hours_formatted(profile_uuid UUID)
RETURNS TEXT AS $$
DECLARE
    result TEXT := '';
    hours_record RECORD;
    day_text TEXT;
BEGIN
    FOR hours_record IN 
        SELECT 
            day_of_week,
            CASE day_of_week
                WHEN 0 THEN 'Sunday'
                WHEN 1 THEN 'Monday'
                WHEN 2 THEN 'Tuesday'
                WHEN 3 THEN 'Wednesday'
                WHEN 4 THEN 'Thursday'
                WHEN 5 THEN 'Friday'
                WHEN 6 THEN 'Saturday'
            END as day_name,
            is_open,
            opening_time,
            closing_time,
            break_start_time,
            break_end_time,
            is_24_hours,
            notes
        FROM business_hours
        WHERE profile_id = profile_uuid
        ORDER BY day_of_week
    LOOP
        day_text := hours_record.day_name || ': ';
        
        IF NOT hours_record.is_open THEN
            day_text := day_text || 'Closed';
        ELSIF hours_record.is_24_hours THEN
            day_text := day_text || '24 Hours';
        ELSIF hours_record.opening_time IS NOT NULL AND hours_record.closing_time IS NOT NULL THEN
            day_text := day_text || hours_record.opening_time::TEXT || ' - ' || hours_record.closing_time::TEXT;
            
            IF hours_record.break_start_time IS NOT NULL AND hours_record.break_end_time IS NOT NULL THEN
                day_text := day_text || ' (Break: ' || hours_record.break_start_time::TEXT || ' - ' || hours_record.break_end_time::TEXT || ')';
            END IF;
        ELSE
            day_text := day_text || 'By Appointment';
        END IF;
        
        IF hours_record.notes IS NOT NULL AND hours_record.notes != '' THEN
            day_text := day_text || ' - ' || hours_record.notes;
        END IF;
        
        result := result || day_text || E'\n';
    END LOOP;
    
    RETURN TRIM(result);
END;
$$ LANGUAGE plpgsql;

-- Step 6: Create triggers
CREATE OR REPLACE FUNCTION trigger_update_business_hours_display()
RETURNS TRIGGER AS $$
BEGIN
    -- Update display for the affected profile
    PERFORM update_business_hours_display(COALESCE(NEW.profile_id, OLD.profile_id));
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_business_hours_display_trigger ON business_hours;
CREATE TRIGGER update_business_hours_display_trigger
    AFTER INSERT OR UPDATE OR DELETE ON business_hours
    FOR EACH ROW EXECUTE FUNCTION trigger_update_business_hours_display();

DROP TRIGGER IF EXISTS update_business_hours_timestamp ON business_hours;
CREATE TRIGGER update_business_hours_timestamp
    BEFORE UPDATE ON business_hours
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Step 7: Create the business hours view
CREATE OR REPLACE VIEW vendor_business_hours AS
SELECT 
    p.id as profile_id,
    p.name as vendor_name,
    p.facility_name,
    p.timezone,
    bh.day_of_week,
    CASE bh.day_of_week
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as day_name,
    bh.is_open,
    bh.opening_time,
    bh.closing_time,
    bh.break_start_time,
    bh.break_end_time,
    bh.is_24_hours,
    bh.notes
FROM profiles p
LEFT JOIN business_hours bh ON p.id = bh.profile_id
WHERE p.user_type = 'vendor'
ORDER BY p.name, bh.day_of_week;

-- =====================================================
-- OPTIONAL: Set default business hours for existing vendors
-- =====================================================
-- Uncomment the following lines to set default business hours for existing vendor profiles

/*
-- Set default business hours for all existing vendor profiles
DO $$
DECLARE
    vendor_record RECORD;
BEGIN
    FOR vendor_record IN 
        SELECT id FROM profiles WHERE user_type = 'vendor'
    LOOP
        PERFORM set_default_business_hours(vendor_record.id);
    END LOOP;
END $$;
*/

-- =====================================================
-- USAGE EXAMPLES
-- =====================================================

-- Example 1: Set business hours for a specific vendor
-- SELECT set_business_hours('your-vendor-uuid-here', 1, true, '09:00', '17:00', NULL, NULL, false, 'Monday hours');

-- Example 2: Set default hours for a new vendor
-- SELECT set_default_business_hours('your-vendor-uuid-here');

-- Example 3: Check if a business is currently open
-- SELECT is_business_currently_open('your-vendor-uuid-here');

-- Example 4: Get formatted business hours text
-- SELECT get_business_hours_formatted('your-vendor-uuid-here');

-- Example 5: View all business hours for a vendor
-- SELECT * FROM vendor_business_hours WHERE profile_id = 'your-vendor-uuid-here';

-- Example 6: Get all vendors with their current open/closed status
-- SELECT 
--     p.id,
--     p.name,
--     p.facility_name,
--     is_business_currently_open(p.id) as is_currently_open,
--     get_business_hours_formatted(p.id) as formatted_hours
-- FROM profiles p 
-- WHERE p.user_type = 'vendor';
