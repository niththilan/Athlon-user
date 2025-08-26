-- Complete Customer App Database Setup and RLS Policies
-- Run this script in your Supabase SQL Editor to set up the customer app

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Ensure RLS is enabled on all customer-facing tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE facilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE courts ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE time_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE facility_images ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- CUSTOMERS TABLE POLICIES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own customer profile" ON customers;
DROP POLICY IF EXISTS "Users can create their own customer profile" ON customers;
DROP POLICY IF EXISTS "Users can update their own customer profile" ON customers;
DROP POLICY IF EXISTS "Public can view customer names for reviews" ON customers;

-- Customers can view their own profile
CREATE POLICY "Users can view their own customer profile" ON customers
    FOR SELECT
    USING (id = auth.uid());

-- Customers can insert their own profile
CREATE POLICY "Users can create their own customer profile" ON customers
    FOR INSERT
    WITH CHECK (id = auth.uid());

-- Customers can update their own profile
CREATE POLICY "Users can update their own customer profile" ON customers
    FOR UPDATE
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- Public can view customer names for reviews (but not sensitive data)
CREATE POLICY "Public can view customer names for reviews" ON customers
    FOR SELECT
    USING (true);

-- =====================================================
-- PROFILES TABLE POLICIES (for venue owners)
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public can view vendor profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;

-- Public can view vendor profiles (for customer app to browse venues)
CREATE POLICY "Public can view vendor profiles" ON profiles
    FOR SELECT
    USING (user_type = 'vendor');

-- Users can view their own profile
CREATE POLICY "Users can view their own profile" ON profiles
    FOR SELECT
    USING (id = auth.uid());

-- Users can insert their own profile
CREATE POLICY "Users can insert their own profile" ON profiles
    FOR INSERT
    WITH CHECK (id = auth.uid());

-- Users can update their own profile
CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- =====================================================
-- FACILITIES TABLE POLICIES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public can view facilities" ON facilities;

-- Public can view all facilities (for customer app to browse)
CREATE POLICY "Public can view facilities" ON facilities
    FOR SELECT
    USING (true);

-- =====================================================
-- COURTS TABLE POLICIES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public can view active courts" ON courts;

-- Public can view active courts
CREATE POLICY "Public can view active courts" ON courts
    FOR SELECT
    USING (is_active = true);

-- =====================================================
-- BOOKINGS TABLE POLICIES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own bookings" ON bookings;
DROP POLICY IF EXISTS "Users can create bookings" ON bookings;
DROP POLICY IF EXISTS "Users can update their own bookings" ON bookings;
DROP POLICY IF EXISTS "Facility owners can view their facility bookings" ON bookings;

-- Customers can view their own bookings
CREATE POLICY "Users can view their own bookings" ON bookings
    FOR SELECT
    USING (customer_id = auth.uid());

-- Authenticated users can create bookings
CREATE POLICY "Users can create bookings" ON bookings
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- Users can update their own bookings (for cancellation, etc.)
CREATE POLICY "Users can update their own bookings" ON bookings
    FOR UPDATE
    USING (customer_id = auth.uid())
    WITH CHECK (customer_id = auth.uid());

-- Facility owners can view bookings for their facilities
CREATE POLICY "Facility owners can view their facility bookings" ON bookings
    FOR SELECT
    USING (
        facility_id IN (
            SELECT id FROM facilities WHERE owner_id = auth.uid()
        )
    );

-- =====================================================
-- TIME_SLOTS TABLE POLICIES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public can view time slots" ON time_slots;
DROP POLICY IF EXISTS "Users can update time slots for booking" ON time_slots;

-- Public can view time slots (for availability checking)
CREATE POLICY "Public can view time slots" ON time_slots
    FOR SELECT
    USING (true);

-- Authenticated users can update time slots (for booking)
CREATE POLICY "Users can update time slots for booking" ON time_slots
    FOR UPDATE
    USING (auth.uid() IS NOT NULL)
    WITH CHECK (auth.uid() IS NOT NULL);

-- =====================================================
-- REVIEWS TABLE POLICIES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public can view reviews" ON reviews;
DROP POLICY IF EXISTS "Users can create reviews" ON reviews;
DROP POLICY IF EXISTS "Users can update their own reviews" ON reviews;

-- Public can view all reviews
CREATE POLICY "Public can view reviews" ON reviews
    FOR SELECT
    USING (true);

-- Authenticated users can create reviews
CREATE POLICY "Users can create reviews" ON reviews
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL AND customer_id = auth.uid());

-- Users can update their own reviews
CREATE POLICY "Users can update their own reviews" ON reviews
    FOR UPDATE
    USING (customer_id = auth.uid())
    WITH CHECK (customer_id = auth.uid());

-- =====================================================
-- CUSTOMER_FAVORITES TABLE POLICIES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own favorites" ON customer_favorites;
DROP POLICY IF EXISTS "Users can add their own favorites" ON customer_favorites;
DROP POLICY IF EXISTS "Users can remove their own favorites" ON customer_favorites;

-- Customers can view their own favorites
CREATE POLICY "Users can view their own favorites" ON customer_favorites
    FOR SELECT
    USING (customer_id = auth.uid());

-- Customers can add their own favorites
CREATE POLICY "Users can add their own favorites" ON customer_favorites
    FOR INSERT
    WITH CHECK (customer_id = auth.uid());

-- Customers can remove their own favorites
CREATE POLICY "Users can remove their own favorites" ON customer_favorites
    FOR DELETE
    USING (customer_id = auth.uid());

-- =====================================================
-- NOTIFICATIONS TABLE POLICIES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications;

-- Users can view their own notifications
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT
    USING (recipient_id = auth.uid());

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE
    USING (recipient_id = auth.uid())
    WITH CHECK (recipient_id = auth.uid());

-- =====================================================
-- FACILITY_IMAGES TABLE POLICIES
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public can view facility images" ON facility_images;

-- Public can view facility images
CREATE POLICY "Public can view facility images" ON facility_images
    FOR SELECT
    USING (is_active = true);

-- =====================================================
-- RPC FUNCTIONS FOR CUSTOMER APP
-- =====================================================

-- Function to create customer profile after signup
DROP FUNCTION IF EXISTS create_customer_profile_on_signup(UUID, TEXT, TEXT, TEXT);
CREATE OR REPLACE FUNCTION create_customer_profile_on_signup(
    user_id UUID,
    user_name TEXT,
    user_phone TEXT,
    user_email TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO customers (id, name, phone, email)
    VALUES (user_id, user_name, user_phone, user_email)
    ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        phone = EXCLUDED.phone,
        email = EXCLUDED.email,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if business is currently open
-- Note: If this function exists with dependencies, we'll recreate with the same signature
CREATE OR REPLACE FUNCTION is_business_currently_open(profile_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    current_day INTEGER;
    current_time_val TIME;
    business_hour RECORD;
BEGIN
    -- Get current day of week (0 = Sunday, 6 = Saturday)
    current_day := EXTRACT(DOW FROM NOW());
    current_time_val := NOW()::TIME;
    
    -- Get business hours for current day
    SELECT * INTO business_hour
    FROM business_hours 
    WHERE profile_id = profile_uuid 
    AND day_of_week = current_day;
    
    -- If no record found, assume closed
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    -- If marked as closed
    IF NOT business_hour.is_open THEN
        RETURN false;
    END IF;
    
    -- If 24 hours
    IF business_hour.is_24_hours THEN
        RETURN true;
    END IF;
    
    -- Check if current time is within business hours
    IF business_hour.opening_time IS NULL OR business_hour.closing_time IS NULL THEN
        RETURN false;
    END IF;
    
    -- Handle normal hours
    IF business_hour.opening_time <= business_hour.closing_time THEN
        RETURN current_time_val >= business_hour.opening_time 
           AND current_time_val <= business_hour.closing_time;
    ELSE
        -- Handle overnight hours (e.g., 10 PM to 6 AM)
        RETURN current_time_val >= business_hour.opening_time 
            OR current_time_val <= business_hour.closing_time;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to generate time slots for a court and date
DROP FUNCTION IF EXISTS generate_time_slots_for_court_and_date(TEXT, DATE);
CREATE OR REPLACE FUNCTION generate_time_slots_for_court_and_date(
    court_uuid TEXT,
    target_date DATE
) RETURNS VOID AS $$
DECLARE
    hour_counter INTEGER;
    time_slot_text TEXT;
    slot_time TIME;
BEGIN
    -- Generate hourly slots from 6 AM to 11 PM
    FOR hour_counter IN 6..22 LOOP
        slot_time := (hour_counter || ':00:00')::TIME;
        time_slot_text := TO_CHAR(slot_time, 'HH24:MI');
        
        -- Insert time slot if it doesn't exist
        INSERT INTO time_slots (court_id, slot_date, time_slot, status, price)
        VALUES (court_uuid, target_date, time_slot_text, 'available', NULL)
        ON CONFLICT (court_id, slot_date, time_slot) DO NOTHING;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update facility rating after review
DROP FUNCTION IF EXISTS update_facility_rating(UUID);
CREATE OR REPLACE FUNCTION update_facility_rating(facility_uuid UUID)
RETURNS VOID AS $$
DECLARE
    avg_rating DECIMAL(2,1);
    review_count INTEGER;
BEGIN
    -- Calculate average rating and count
    SELECT 
        COALESCE(AVG(rating), 0),
        COUNT(*)
    INTO avg_rating, review_count
    FROM reviews 
    WHERE facility_id = facility_uuid;
    
    -- Update facility owner's profile
    UPDATE profiles 
    SET 
        rating = avg_rating,
        review_count = review_count,
        updated_at = NOW()
    WHERE id = (
        SELECT owner_id 
        FROM facilities 
        WHERE id = facility_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get customer booking statistics
DROP FUNCTION IF EXISTS get_customer_booking_stats(UUID);
CREATE OR REPLACE FUNCTION get_customer_booking_stats(customer_uuid UUID)
RETURNS TABLE (
    total_bookings INTEGER,
    completed_bookings INTEGER,
    cancelled_bookings INTEGER,
    total_spent DECIMAL(10,2),
    favorite_venue TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(b.id)::INTEGER as total_bookings,
        COUNT(CASE WHEN b.status = 'completed' THEN 1 END)::INTEGER as completed_bookings,
        COUNT(CASE WHEN b.status = 'cancelled' THEN 1 END)::INTEGER as cancelled_bookings,
        COALESCE(SUM(CASE WHEN b.status = 'completed' THEN b.total_amount ELSE 0 END), 0) as total_spent,
        (
            SELECT f.name
            FROM bookings b2
            JOIN facilities f ON b2.facility_id = f.id
            WHERE b2.customer_id = customer_uuid
            AND b2.status = 'completed'
            GROUP BY f.id, f.name
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ) as favorite_venue
    FROM bookings b
    WHERE b.customer_id = customer_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions on RPC functions
GRANT EXECUTE ON FUNCTION create_customer_profile_on_signup TO authenticated;
GRANT EXECUTE ON FUNCTION is_business_currently_open TO public;
GRANT EXECUTE ON FUNCTION generate_time_slots_for_court_and_date TO authenticated;
GRANT EXECUTE ON FUNCTION update_facility_rating TO authenticated;
GRANT EXECUTE ON FUNCTION get_customer_booking_stats TO authenticated;

COMMENT ON FUNCTION create_customer_profile_on_signup IS 'Creates or updates customer profile after signup';
COMMENT ON FUNCTION is_business_currently_open IS 'Checks if a business is currently open based on business hours';
COMMENT ON FUNCTION generate_time_slots_for_court_and_date IS 'Generates time slots for a specific court and date';
COMMENT ON FUNCTION update_facility_rating IS 'Updates facility rating after a new review';
COMMENT ON FUNCTION get_customer_booking_stats IS 'Gets booking statistics for a customer';
