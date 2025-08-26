-- Fix opening hours formatting to remove seconds
-- This updates the get_business_hours_formatted function to format times without seconds

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
                WHEN 1 THEN 'Monday'
                WHEN 2 THEN 'Tuesday'
                WHEN 3 THEN 'Wednesday'
                WHEN 4 THEN 'Thursday'
                WHEN 5 THEN 'Friday'
                WHEN 6 THEN 'Saturday'
                WHEN 7 THEN 'Sunday'
            END as day_name,
            is_open,
            is_24_hours,
            opening_time,
            closing_time,
            break_start_time,
            break_end_time,
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
            -- Format times without seconds using TO_CHAR
            day_text := day_text || TO_CHAR(hours_record.opening_time, 'HH24:MI') || ' - ' || TO_CHAR(hours_record.closing_time, 'HH24:MI');
            
            IF hours_record.break_start_time IS NOT NULL AND hours_record.break_end_time IS NOT NULL THEN
                day_text := day_text || ' (Break: ' || TO_CHAR(hours_record.break_start_time, 'HH24:MI') || ' - ' || TO_CHAR(hours_record.break_end_time, 'HH24:MI') || ')';
            END IF;
        ELSE
            day_text := day_text || 'By Appointment';
        END IF;
        
        IF hours_record.notes IS NOT NULL AND hours_record.notes != '' THEN
            day_text := day_text || ' - ' || hours_record.notes;
        END IF;
        
        IF result != '' THEN
            result := result || E'\n';
        END IF;
        result := result || day_text;
    END LOOP;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Update all existing profiles to refresh their opening_hours field without seconds
DO $$
DECLARE
    profile_record RECORD;
    formatted_hours TEXT;
BEGIN
    FOR profile_record IN 
        SELECT DISTINCT profile_id 
        FROM business_hours 
    LOOP
        SELECT get_business_hours_formatted(profile_record.profile_id) INTO formatted_hours;
        
        UPDATE profiles 
        SET 
            opening_hours = formatted_hours,
            updated_at = NOW()
        WHERE id = profile_record.profile_id;
    END LOOP;
    
    RAISE NOTICE 'Updated opening hours format for all profiles to remove seconds';
END $$;