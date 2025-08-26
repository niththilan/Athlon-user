-- =====================================================
-- FACILITIES AND AMENITIES ENHANCEMENT
-- Add enhanced support for facilities and amenities
-- =====================================================

-- 1. Add amenities_list column to profiles table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'amenities_list'
    ) THEN
        ALTER TABLE profiles ADD COLUMN amenities_list TEXT[];
    END IF;
END $$;

-- 2. Create indexes for better array search performance (if they don't exist)
DO $$ 
BEGIN
    -- Index for facilities_list
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'profiles' 
        AND indexname = 'idx_profiles_facilities_list'
    ) THEN
        CREATE INDEX idx_profiles_facilities_list ON profiles USING GIN (facilities_list);
    END IF;

    -- Index for services_list
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'profiles' 
        AND indexname = 'idx_profiles_services_list'
    ) THEN
        CREATE INDEX idx_profiles_services_list ON profiles USING GIN (services_list);
    END IF;

    -- Index for amenities_list
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'profiles' 
        AND indexname = 'idx_profiles_amenities_list'
    ) THEN
        CREATE INDEX idx_profiles_amenities_list ON profiles USING GIN (amenities_list);
    END IF;

    -- Index for court equipment_provided
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'courts' 
        AND indexname = 'idx_courts_equipment_provided'
    ) THEN
        CREATE INDEX idx_courts_equipment_provided ON courts USING GIN (equipment_provided);
    END IF;

    -- Index for court amenities
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'courts' 
        AND indexname = 'idx_courts_amenities'
    ) THEN
        CREATE INDEX idx_courts_amenities ON courts USING GIN (amenities);
    END IF;
END $$;

-- 3. Create helper functions for facilities and amenities management

-- Function to get vendor facilities with their facilities and amenities
CREATE OR REPLACE FUNCTION get_vendor_facilities_with_details(vendor_id UUID)
RETURNS TABLE(
    vendor_name TEXT,
    facility_name TEXT,
    facilities_list TEXT[],
    services_list TEXT[],
    amenities_list TEXT[],
    total_courts INTEGER,
    court_details JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.name as vendor_name,
        p.facility_name,
        p.facilities_list,
        p.services_list,
        p.amenities_list,
        COUNT(c.id)::INTEGER as total_courts,
        json_agg(
            json_build_object(
                'court_id', c.id,
                'court_name', c.name,
                'court_type', c.type,
                'equipment_provided', c.equipment_provided,
                'amenities', c.amenities,
                'hourly_rate', c.hourly_rate,
                'is_active', c.is_active
            )
        ) as court_details
    FROM profiles p
    LEFT JOIN facilities f ON p.id = f.owner_id
    LEFT JOIN courts c ON f.id = c.facility_id AND c.is_active = true
    WHERE p.id = vendor_id
    GROUP BY p.id, p.name, p.facility_name, p.facilities_list, p.services_list, p.amenities_list;
END;
$$ LANGUAGE plpgsql;

-- Function to search vendors by facilities or amenities
CREATE OR REPLACE FUNCTION search_vendors_by_facilities_amenities(
    search_facilities TEXT[] DEFAULT NULL,
    search_amenities TEXT[] DEFAULT NULL,
    location_filter TEXT DEFAULT NULL
)
RETURNS TABLE(
    vendor_id UUID,
    vendor_name TEXT,
    facility_name TEXT,
    location TEXT,
    matching_facilities TEXT[],
    matching_amenities TEXT[],
    rating DECIMAL(2,1),
    total_courts INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as vendor_id,
        p.name as vendor_name,
        p.facility_name,
        p.location,
        -- Show which facilities match the search
        CASE 
            WHEN search_facilities IS NOT NULL THEN 
                ARRAY(SELECT unnest(p.facilities_list) INTERSECT SELECT unnest(search_facilities))
            ELSE p.facilities_list
        END as matching_facilities,
        -- Show which amenities match the search
        CASE 
            WHEN search_amenities IS NOT NULL THEN 
                ARRAY(SELECT unnest(p.amenities_list) INTERSECT SELECT unnest(search_amenities))
            ELSE p.amenities_list
        END as matching_amenities,
        p.rating,
        (
            SELECT COUNT(c.id)::INTEGER 
            FROM facilities f 
            JOIN courts c ON f.id = c.facility_id 
            WHERE f.owner_id = p.id AND c.is_active = true
        ) as total_courts
    FROM profiles p
    WHERE p.user_type = 'vendor'
    AND (
        search_facilities IS NULL OR 
        p.facilities_list && search_facilities  -- Array overlap operator
    )
    AND (
        search_amenities IS NULL OR 
        p.amenities_list && search_amenities
    )
    AND (
        location_filter IS NULL OR 
        p.location ILIKE '%' || location_filter || '%'
    )
    ORDER BY p.rating DESC, p.name;
END;
$$ LANGUAGE plpgsql;

-- Function to get all unique facilities and amenities for dropdown suggestions
CREATE OR REPLACE FUNCTION get_all_facilities_amenities()
RETURNS TABLE(
    all_facilities TEXT[],
    all_amenities TEXT[],
    all_services TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ARRAY(
            SELECT DISTINCT unnest(facilities_list) 
            FROM profiles 
            WHERE facilities_list IS NOT NULL 
            AND user_type = 'vendor'
            ORDER BY unnest(facilities_list)
        ) as all_facilities,
        ARRAY(
            SELECT DISTINCT unnest(amenities_list) 
            FROM profiles 
            WHERE amenities_list IS NOT NULL 
            AND user_type = 'vendor'
            ORDER BY unnest(amenities_list)
        ) as all_amenities,
        ARRAY(
            SELECT DISTINCT unnest(services_list) 
            FROM profiles 
            WHERE services_list IS NOT NULL 
            AND user_type = 'vendor'
            ORDER BY unnest(services_list)
        ) as all_services;
END;
$$ LANGUAGE plpgsql;

-- 4. Update the existing view to include facilities and amenities
DROP VIEW IF EXISTS facility_stats;
CREATE OR REPLACE VIEW facility_stats AS
SELECT 
    f.id as facility_id,
    f.name as facility_name,
    f.owner_id,
    p.name as vendor_name,
    p.facilities_list,
    p.amenities_list,
    p.services_list,
    COUNT(DISTINCT CASE WHEN c.is_active = true THEN c.id END) as total_courts,
    COUNT(DISTINCT CASE WHEN b.status = 'pending' THEN b.id END) as pending_bookings,
    COUNT(DISTINCT CASE WHEN b.booking_date = CURRENT_DATE THEN b.id END) as today_bookings,
    COALESCE(SUM(CASE 
        WHEN b.status = 'completed' 
        AND EXTRACT(MONTH FROM b.booking_date) = EXTRACT(MONTH FROM CURRENT_DATE)
        AND EXTRACT(YEAR FROM b.booking_date) = EXTRACT(YEAR FROM CURRENT_DATE)
        THEN b.total_amount 
        ELSE 0 
    END), 0) as monthly_revenue
FROM facilities f
LEFT JOIN profiles p ON f.owner_id = p.id
LEFT JOIN courts c ON f.id = c.facility_id
LEFT JOIN bookings b ON f.id = b.facility_id
GROUP BY f.id, f.name, f.owner_id, p.name, p.facilities_list, p.amenities_list, p.services_list;

-- 5. Sample data for testing (optional - uncomment to add sample data)
/*
-- Add sample facilities and amenities to existing vendor profiles
UPDATE profiles 
SET 
    facilities_list = ARRAY['Cricket Nets', 'Changing Rooms', 'Parking Area'],
    amenities_list = ARRAY['Air Conditioning', 'Professional Lighting', 'CCTV Coverage'],
    services_list = ARRAY['Equipment Rental', 'Coaching', 'Tournament Hosting']
WHERE user_type = 'vendor' 
AND facilities_list IS NULL
LIMIT 1;
*/

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check if the amenities_list column exists
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name IN ('facilities_list', 'services_list', 'amenities_list');

-- Check if indexes exist
SELECT indexname, tablename 
FROM pg_indexes 
WHERE tablename IN ('profiles', 'courts') 
AND indexname LIKE '%facilities%' OR indexname LIKE '%amenities%';

-- Test the search function (example)
-- SELECT * FROM search_vendors_by_facilities_amenities(
--     ARRAY['Cricket Nets', 'Swimming Pool'], 
--     ARRAY['Air Conditioning'], 
--     'Mumbai'
-- );

COMMENT ON FUNCTION get_vendor_facilities_with_details(UUID) IS 'Get comprehensive facilities and amenities information for a vendor';
COMMENT ON FUNCTION search_vendors_by_facilities_amenities(TEXT[], TEXT[], TEXT) IS 'Search vendors by their facilities and amenities with location filter';
COMMENT ON FUNCTION get_all_facilities_amenities() IS 'Get all unique facilities and amenities for dropdown suggestions';
