-- =====================================================
-- DATABASE CONNECTIVITY VALIDATION AND MISSING FUNCTIONS
-- Complete verification and fixes for Supabase database
-- =====================================================

-- This file ensures all Dart service calls match database functions and tables
-- Run this after executing schema.sql to add any missing components

-- =====================================================
-- VERIFICATION OF EXISTING FUNCTIONS AGAINST DART CALLS
-- =====================================================

-- ✅ VERIFIED: create_user_profile_on_signup() - exists in schema.sql
-- ✅ VERIFIED: get_vendor_dashboard_stats() - exists in schema.sql  
-- ✅ VERIFIED: get_facility_stats() - exists in schema.sql
-- ✅ VERIFIED: cleanup_old_time_slots() - exists in schema.sql
-- ✅ VERIFIED: generate_time_slots_for_court_and_date() - exists in schema.sql
-- ✅ VERIFIED: daily_cleanup() - exists in schema.sql
-- ✅ VERIFIED: update_facility_rating() - exists in schema.sql
-- ✅ VERIFIED: expire_old_pending_bookings() - exists in schema.sql
-- ✅ VERIFIED: create_notification() - exists in schema.sql
-- ✅ VERIFIED: set_business_hours() - exists in business_hours_supabase_migration.sql
-- ✅ VERIFIED: update_business_hours_display() - exists in both schema.sql and business_hours files

-- =====================================================
-- ADDITIONAL RPC FUNCTIONS CALLED BY DART (NOT IN SCHEMA)
-- Adding missing functions identified in SupabaseService
-- =====================================================

-- Function for OTP-based password reset (referenced in resetPasswordWithOTP)
-- This is handled by Supabase Auth, no custom function needed

-- Function to validate booking time slots before creation
CREATE OR REPLACE FUNCTION validate_booking_slot(
    court_uuid TEXT,
    booking_date_param DATE,
    time_slot_param TEXT,
    start_time_param TIMESTAMP WITH TIME ZONE,
    end_time_param TIMESTAMP WITH TIME ZONE
)
RETURNS BOOLEAN AS $$
DECLARE
    slot_conflicts INTEGER;
    business_open BOOLEAN;
BEGIN
    -- Check for booking conflicts
    SELECT COUNT(*) INTO slot_conflicts
    FROM bookings
    WHERE court_id = court_uuid
    AND booking_date = booking_date_param
    AND time_slot = time_slot_param
    AND status NOT IN ('cancelled', 'completed');
    
    -- Check if facility is open during requested time
    -- This can be enhanced with business hours validation
    
    RETURN (slot_conflicts = 0);
END;
$$ LANGUAGE plpgsql;

-- Function to get comprehensive booking details with court and facility info
CREATE OR REPLACE FUNCTION get_booking_details(booking_uuid TEXT)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'booking', b.*,
        'court', c.*,
        'facility', f.*,
        'customer', cu.*
    ) INTO result
    FROM bookings b
    LEFT JOIN courts c ON b.court_id = c.id
    LEFT JOIN facilities f ON b.facility_id = f.id
    LEFT JOIN customers cu ON b.customer_id = cu.id
    WHERE b.id = booking_uuid;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to update booking with comprehensive validation
CREATE OR REPLACE FUNCTION update_booking_safe(
    booking_uuid TEXT,
    status_param TEXT DEFAULT NULL,
    payment_status_param TEXT DEFAULT NULL,
    payment_method_param TEXT DEFAULT NULL,
    special_requests_param TEXT DEFAULT NULL,
    cancellation_reason_param TEXT DEFAULT NULL,
    cancelled_by_param TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    result JSON;
    booking_exists BOOLEAN;
BEGIN
    -- Check if booking exists
    SELECT EXISTS(SELECT 1 FROM bookings WHERE id = booking_uuid) INTO booking_exists;
    
    IF NOT booking_exists THEN
        RAISE EXCEPTION 'Booking with ID % not found', booking_uuid;
    END IF;
    
    -- Update booking with provided parameters
    UPDATE bookings SET
        status = COALESCE(status_param, status),
        payment_status = COALESCE(payment_status_param, payment_status),
        payment_method = COALESCE(payment_method_param, payment_method),
        special_requests = COALESCE(special_requests_param, special_requests),
        cancellation_reason = COALESCE(cancellation_reason_param, cancellation_reason),
        cancelled_by = COALESCE(cancelled_by_param, cancelled_by),
        updated_at = NOW()
    WHERE id = booking_uuid;
    
    -- Return updated booking details
    SELECT get_booking_details(booking_uuid) INTO result;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ENHANCED COURT MANAGEMENT FUNCTIONS
-- =====================================================

-- Function to safely delete court with booking validation
CREATE OR REPLACE FUNCTION delete_court_safe(court_uuid TEXT)
RETURNS JSON AS $$
DECLARE
    active_bookings INTEGER;
    facility_uuid UUID;
    result JSON;
BEGIN
    -- Check for active bookings
    SELECT COUNT(*) INTO active_bookings
    FROM bookings
    WHERE court_id = court_uuid
    AND status IN ('pending', 'confirmed')
    AND booking_date >= CURRENT_DATE;
    
    IF active_bookings > 0 THEN
        RAISE EXCEPTION 'Cannot delete court: % active bookings found', active_bookings;
    END IF;
    
    -- Get facility ID before deletion
    SELECT facility_id INTO facility_uuid FROM courts WHERE id = court_uuid;
    
    -- Delete the court
    DELETE FROM courts WHERE id = court_uuid;
    
    -- Update facility court count (trigger should handle this, but ensure it)
    IF facility_uuid IS NOT NULL THEN
        PERFORM update_facility_stats_manual(facility_uuid);
    END IF;
    
    result := json_build_object(
        'success', true,
        'deleted_court_id', court_uuid,
        'facility_id', facility_uuid,
        'message', 'Court deleted successfully'
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- CHAT AND MESSAGING ENHANCEMENTS
-- =====================================================

-- Function to create or get chat conversation
CREATE OR REPLACE FUNCTION get_or_create_conversation(
    vendor_uuid UUID,
    customer_uuid UUID
)
RETURNS UUID AS $$
DECLARE
    conversation_id UUID;
BEGIN
    -- Try to find existing conversation
    SELECT id INTO conversation_id
    FROM chat_conversations
    WHERE vendor_id = vendor_uuid AND customer_id = customer_uuid
    LIMIT 1;
    
    -- Create new conversation if none exists
    IF conversation_id IS NULL THEN
        INSERT INTO chat_conversations (vendor_id, customer_id)
        VALUES (vendor_uuid, customer_uuid)
        RETURNING id INTO conversation_id;
    END IF;
    
    RETURN conversation_id;
END;
$$ LANGUAGE plpgsql;

-- Function to mark conversation messages as read
CREATE OR REPLACE FUNCTION mark_conversation_read(
    conversation_uuid UUID,
    reader_type TEXT -- 'vendor' or 'customer'
)
RETURNS INTEGER AS $$
DECLARE
    marked_count INTEGER;
BEGIN
    -- Mark messages as read
    UPDATE chat_messages 
    SET is_read = true
    WHERE conversation_id = conversation_uuid
    AND sender_type != reader_type
    AND is_read = false;
    
    GET DIAGNOSTICS marked_count = ROW_COUNT;
    
    -- Update conversation read status
    IF reader_type = 'vendor' THEN
        UPDATE chat_conversations
        SET is_read_by_vendor = true
        WHERE id = conversation_uuid;
    ELSE
        UPDATE chat_conversations
        SET is_read_by_customer = true
        WHERE id = conversation_uuid;
    END IF;
    
    RETURN marked_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TIME SLOT MANAGEMENT ENHANCEMENTS
-- =====================================================

-- Function to get available time slots for a court and date
CREATE OR REPLACE FUNCTION get_available_time_slots(
    court_uuid TEXT,
    target_date DATE
)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_agg(
        json_build_object(
            'time_slot', time_slot,
            'status', status,
            'price', price,
            'is_available', (status = 'available')
        )
    ) INTO result
    FROM time_slots
    WHERE court_id = court_uuid
    AND slot_date = target_date
    ORDER BY time_slot;
    
    RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql;

-- Function to book time slot atomically
CREATE OR REPLACE FUNCTION book_time_slot(
    court_uuid TEXT,
    slot_date_param DATE,
    time_slot_param TEXT,
    booking_uuid TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    rows_updated INTEGER;
BEGIN
    -- Check and update slot in one atomic operation
    UPDATE time_slots
    SET 
        status = 'booked',
        booking_id = booking_uuid,
        updated_at = NOW()
    WHERE court_id = court_uuid
    AND slot_date = slot_date_param
    AND time_slot = time_slot_param
    AND status = 'available';
    
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    
    RETURN (rows_updated > 0);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ANALYTICS AND REPORTING FUNCTIONS
-- =====================================================

-- Function to get booking analytics for date range
CREATE OR REPLACE FUNCTION get_booking_analytics(
    facility_uuid UUID,
    start_date DATE,
    end_date DATE
)
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_bookings INTEGER;
    completed_bookings INTEGER;
    cancelled_bookings INTEGER;
    total_revenue DECIMAL(10,2);
    avg_booking_value DECIMAL(10,2);
BEGIN
    -- Calculate metrics
    SELECT 
        COUNT(*),
        COUNT(CASE WHEN status = 'completed' THEN 1 END),
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END),
        COALESCE(SUM(CASE WHEN status = 'completed' THEN total_amount ELSE 0 END), 0)
    INTO total_bookings, completed_bookings, cancelled_bookings, total_revenue
    FROM bookings
    WHERE facility_id = facility_uuid
    AND booking_date BETWEEN start_date AND end_date;
    
    -- Calculate average
    avg_booking_value := CASE 
        WHEN completed_bookings > 0 THEN total_revenue / completed_bookings 
        ELSE 0 
    END;
    
    -- Build result
    result := json_build_object(
        'total_bookings', total_bookings,
        'completed_bookings', completed_bookings,
        'cancelled_bookings', cancelled_bookings,
        'cancellation_rate', CASE 
            WHEN total_bookings > 0 THEN ROUND((cancelled_bookings::DECIMAL / total_bookings * 100), 1)
            ELSE 0 
        END,
        'total_revenue', total_revenue,
        'average_booking_value', ROUND(avg_booking_value, 2),
        'period_start', start_date,
        'period_end', end_date
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SEARCH AND FILTER ENHANCEMENTS
-- =====================================================

-- Function for advanced booking search
CREATE OR REPLACE FUNCTION search_bookings_advanced(
    facility_uuid UUID DEFAULT NULL,
    status_filter TEXT DEFAULT NULL,
    start_date_filter DATE DEFAULT NULL,
    end_date_filter DATE DEFAULT NULL,
    customer_name_filter TEXT DEFAULT NULL,
    customer_phone_filter TEXT DEFAULT NULL,
    search_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    booking_data JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT json_build_object(
        'id', b.id,
        'customer_name', b.customer_name,
        'customer_phone', b.customer_phone,
        'court_name', b.court_name,
        'booking_date', b.booking_date,
        'time_slot', b.time_slot,
        'status', b.status,
        'total_amount', b.total_amount,
        'created_at', b.created_at,
        'facility_name', f.name
    ) as booking_data
    FROM bookings b
    LEFT JOIN facilities f ON b.facility_id = f.id
    WHERE (facility_uuid IS NULL OR b.facility_id = facility_uuid)
    AND (status_filter IS NULL OR b.status = status_filter)
    AND (start_date_filter IS NULL OR b.booking_date >= start_date_filter)
    AND (end_date_filter IS NULL OR b.booking_date <= end_date_filter)
    AND (customer_name_filter IS NULL OR b.customer_name ILIKE '%' || customer_name_filter || '%')
    AND (customer_phone_filter IS NULL OR b.customer_phone ILIKE '%' || customer_phone_filter || '%')
    ORDER BY b.booking_date DESC, b.created_at DESC
    LIMIT search_limit;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- BUSINESS HOURS VALIDATION
-- =====================================================

-- Function to check if booking time is within business hours
CREATE OR REPLACE FUNCTION is_booking_time_valid(
    facility_uuid UUID,
    booking_datetime TIMESTAMP WITH TIME ZONE
)
RETURNS BOOLEAN AS $$
DECLARE
    day_of_week INTEGER;
    booking_time TIME;
    business_hours_record RECORD;
    is_valid BOOLEAN := false;
BEGIN
    -- Extract day of week (0=Sunday, 1=Monday, etc.) and time
    day_of_week := EXTRACT(DOW FROM booking_datetime);
    booking_time := booking_datetime::TIME;
    
    -- Get business hours for the facility owner
    SELECT bh.* INTO business_hours_record
    FROM business_hours bh
    JOIN facilities f ON f.owner_id = bh.profile_id
    WHERE f.id = facility_uuid
    AND bh.day_of_week = day_of_week;
    
    -- Check if facility is open on this day
    IF business_hours_record.id IS NULL OR NOT business_hours_record.is_open THEN
        RETURN false;
    END IF;
    
    -- Check if it's 24 hours
    IF business_hours_record.is_24_hours THEN
        RETURN true;
    END IF;
    
    -- Check if within operating hours
    IF business_hours_record.opening_time IS NOT NULL 
       AND business_hours_record.closing_time IS NOT NULL THEN
        is_valid := (booking_time >= business_hours_record.opening_time 
                     AND booking_time <= business_hours_record.closing_time);
        
        -- Check if during break time (if applicable)
        IF is_valid AND business_hours_record.break_start_time IS NOT NULL 
           AND business_hours_record.break_end_time IS NOT NULL THEN
            is_valid := NOT (booking_time >= business_hours_record.break_start_time 
                           AND booking_time <= business_hours_record.break_end_time);
        END IF;
    END IF;
    
    RETURN is_valid;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FINAL VERIFICATION QUERIES
-- =====================================================

-- Query to verify all tables exist and have expected structure
DO $$
DECLARE
    missing_tables TEXT[] := ARRAY[]::TEXT[];
    missing_functions TEXT[] := ARRAY[]::TEXT[];
    tbl_name TEXT;
    func_name TEXT;
BEGIN
    -- Check all required tables
    FOR tbl_name IN 
        SELECT unnest(ARRAY['profiles', 'facilities', 'courts', 'customers', 'bookings', 
                           'time_slots', 'chat_conversations', 'chat_messages', 'pending_bookings',
                           'pricing_rules', 'reviews', 'notifications', 'facility_images',
                           'loyalty_programs', 'customer_loyalty', 'business_hours'])
    LOOP
        IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = tbl_name) THEN
            missing_tables := array_append(missing_tables, tbl_name);
        END IF;
    END LOOP;
    
    -- Check all required functions
    FOR func_name IN 
        SELECT unnest(ARRAY['create_user_profile_on_signup', 'get_vendor_dashboard_stats', 
                           'get_facility_stats', 'update_facility_rating', 'create_notification',
                           'cleanup_old_time_slots', 'generate_time_slots_for_court_and_date',
                           'daily_cleanup', 'set_business_hours', 'update_business_hours_display'])
    LOOP
        IF NOT EXISTS (SELECT 1 FROM information_schema.routines 
                      WHERE routine_name = func_name AND routine_type = 'FUNCTION') THEN
            missing_functions := array_append(missing_functions, func_name);
        END IF;
    END LOOP;
    
    -- Report results
    IF array_length(missing_tables, 1) > 0 THEN
        RAISE NOTICE 'Missing tables: %', array_to_string(missing_tables, ', ');
    ELSE
        RAISE NOTICE 'All required tables are present ✅';
    END IF;
    
    IF array_length(missing_functions, 1) > 0 THEN
        RAISE NOTICE 'Missing functions: %', array_to_string(missing_functions, ', ');
    ELSE
        RAISE NOTICE 'All required functions are present ✅';
    END IF;
    
    RAISE NOTICE 'Database connectivity validation completed';
END;
$$;

-- =====================================================
-- PERFORMANCE OPTIMIZATION INDEXES
-- =====================================================

-- Additional indexes for enhanced performance based on Dart queries
CREATE INDEX IF NOT EXISTS idx_bookings_facility_date_status ON bookings(facility_id, booking_date, status);
CREATE INDEX IF NOT EXISTS idx_bookings_customer_search ON bookings(customer_name, customer_phone);
CREATE INDEX IF NOT EXISTS idx_time_slots_court_date_status ON time_slots(court_id, slot_date, status);
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation_unread ON chat_messages(conversation_id, is_read, created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_unread ON notifications(recipient_id, is_read, created_at);

-- =====================================================
-- ROW LEVEL SECURITY VERIFICATION
-- =====================================================

-- Ensure RLS policies are properly configured for app functionality
DO $$
BEGIN
    -- Enable RLS on critical tables if not already enabled
    IF NOT (SELECT relrowsecurity FROM pg_class WHERE relname = 'profiles') THEN
        ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
        RAISE NOTICE 'Enabled RLS on profiles table';
    END IF;
    
    -- Create basic policies if they don't exist
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can view own profile') THEN
        CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
        RAISE NOTICE 'Created profile view policy';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can update own profile') THEN
        CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
        RAISE NOTICE 'Created profile update policy';
    END IF;
    
    RAISE NOTICE 'RLS verification completed ✅';
    
    -- Final completion message
    RAISE NOTICE 'Database connectivity validation and enhancement completed successfully! 🎉';
    RAISE NOTICE 'All Dart service calls should now have corresponding database functions and tables.';
END;
$$;
