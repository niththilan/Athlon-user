-- =====================================================
-- ATHLON VENDOR APP - DATABASE SCHEMA
-- Production schema (no data insertion - manual setup required)
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Note: This schema assumes Supabase Auth is configured
-- The auth.users table is provided by Supabase Auth service

-- =====================================================
-- 1. PROFILES TABLE (extends auth.users)
-- =====================================================
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    facility_name TEXT,
    user_type TEXT DEFAULT 'vendor' CHECK (user_type IN ('vendor', 'customer', 'admin')),
    location TEXT,
    full_address TEXT,
    website TEXT,
    opening_hours TEXT, -- Legacy field - use business_hours table for structured hours
    established TEXT,
    status TEXT,
    timezone TEXT DEFAULT 'Asia/Kolkata', -- Timezone for business hours
    business_hours_display JSONB, -- Computed from business_hours table
    -- Additional fields needed by vendor profile
    bio TEXT,
    profile_image_url TEXT,
    facilities_list TEXT[], -- Array of facility names/services
    services_list TEXT[], -- Array of services offered
    amenities_list TEXT[], -- Array of general amenities offered
    pricing_info JSONB, -- Store pricing as JSON for flexibility
    rating DECIMAL(2,1) DEFAULT 0.0 CHECK (rating >= 0.0 AND rating <= 5.0),
    review_count INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. FACILITIES TABLE
-- =====================================================
CREATE TABLE facilities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    pending_bookings INTEGER DEFAULT 0,
    today_bookings INTEGER DEFAULT 0,
    total_courts INTEGER DEFAULT 0,
    monthly_revenue DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. COURTS TABLE
-- =====================================================
CREATE TABLE courts (
    id TEXT PRIMARY KEY,
    facility_id UUID REFERENCES facilities(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    hourly_rate DECIMAL(8,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    -- Additional fields for better court management
    description TEXT,
    capacity INTEGER DEFAULT 4, -- Max players/users
    equipment_provided TEXT[], -- Array of available equipment
    amenities TEXT[], -- Array of amenities (AC, lighting, etc.)
    maintenance_notes TEXT,
    last_maintenance_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 4. CUSTOMERS TABLE
-- =====================================================
CREATE TABLE customers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 5. BOOKINGS TABLE
-- =====================================================
CREATE TABLE bookings (
    id TEXT PRIMARY KEY,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    facility_id UUID REFERENCES facilities(id) ON DELETE CASCADE NOT NULL,
    court_id TEXT REFERENCES courts(id) ON DELETE CASCADE NOT NULL,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    customer_email TEXT, -- Add email field
    court_name TEXT NOT NULL,
    court_type TEXT NOT NULL,
    booking_date DATE NOT NULL,
    time_slot TEXT NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    duration INTEGER NOT NULL, -- Duration in minutes
    duration_hours DECIMAL(3,1) DEFAULT 1.0,
    price DECIMAL(8,2) NOT NULL,
    total_amount DECIMAL(8,2) NOT NULL,
    status TEXT DEFAULT 'confirmed' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed', 'occupied', 'no_show')),
    -- Additional booking fields
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded', 'failed')),
    payment_method TEXT, -- cash, card, online, etc.
    special_requests TEXT,
    booking_source TEXT DEFAULT 'app' CHECK (booking_source IN ('app', 'website', 'phone', 'walk_in')),
    check_in_time TIMESTAMP WITH TIME ZONE,
    check_out_time TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    cancelled_by TEXT, -- vendor, customer, system
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 6. TIME_SLOTS TABLE
-- =====================================================
CREATE TABLE time_slots (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    court_id TEXT REFERENCES courts(id) ON DELETE CASCADE NOT NULL,
    slot_date DATE NOT NULL,
    time_slot TEXT NOT NULL,
    status TEXT DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'selected', 'blocked', 'maintenance')),
    booking_id TEXT REFERENCES bookings(id) ON DELETE SET NULL,
    price DECIMAL(8,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(court_id, slot_date, time_slot)
);

-- =====================================================
-- 7. CHAT_CONVERSATIONS TABLE
-- =====================================================
CREATE TABLE chat_conversations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    vendor_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE NOT NULL,
    last_message TEXT,
    last_message_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_read_by_vendor BOOLEAN DEFAULT false,
    is_read_by_customer BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 8. CHAT_MESSAGES TABLE
-- =====================================================
CREATE TABLE chat_messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID REFERENCES chat_conversations(id) ON DELETE CASCADE NOT NULL,
    sender_type TEXT NOT NULL CHECK (sender_type IN ('vendor', 'customer')),
    sender_id UUID NOT NULL,
    message TEXT NOT NULL,
    content TEXT, -- Added for compatibility
    time TEXT, -- Added for time format compatibility (HH:MM)
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file')),
    is_read BOOLEAN DEFAULT false,
    is_sent_by_me BOOLEAN DEFAULT false, -- Added for compatibility
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 9. PENDING_BOOKINGS TABLE
-- =====================================================
CREATE TABLE pending_bookings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    facility_id UUID REFERENCES facilities(id) ON DELETE CASCADE NOT NULL,
    court_id TEXT REFERENCES courts(id) ON DELETE CASCADE NOT NULL,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    customer_email TEXT, -- Add email field
    creator TEXT, -- Added for compatibility with app
    sport TEXT, -- Added for compatibility with app (Badminton, Cricket, etc.)
    match_type TEXT, -- Singles, Doubles, Team Practice, etc.
    booking_date DATE NOT NULL,
    time_slot TEXT NOT NULL,
    time_range TEXT, -- Added for compatibility (e.g., "6:00 PM - 8:00 PM")
    duration_hours DECIMAL(3,1) DEFAULT 1.0,
    total_amount DECIMAL(8,2) NOT NULL,
    price TEXT, -- Added as text for compatibility with app parsing (e.g., "Rs 2000")
    -- Additional fields based on app usage
    player_count INTEGER DEFAULT 1,
    equipment_needed TEXT[], -- Array of required equipment
    special_requests TEXT,
    preferred_court_features TEXT[], -- Indoor/Outdoor, AC, etc.
    booking_source TEXT DEFAULT 'app',
    priority_level TEXT DEFAULT 'normal' CHECK (priority_level IN ('low', 'normal', 'high', 'urgent')),
    notes TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'expired')),
    -- Processing fields
    processed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    processed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '24 hours'), -- Auto-expire after 24 hours
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 10. PRICING_RULES TABLE
-- =====================================================
CREATE TABLE pricing_rules (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    facility_id UUID REFERENCES facilities(id) ON DELETE CASCADE NOT NULL,
    court_id TEXT REFERENCES courts(id) ON DELETE CASCADE,
    day_of_week INTEGER CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME,
    end_time TIME,
    price DECIMAL(8,2) NOT NULL,
    rule_type TEXT DEFAULT 'hourly' CHECK (rule_type IN ('hourly', 'peak', 'off_peak', 'weekend', 'holiday')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 11. REVIEWS TABLE
-- =====================================================
CREATE TABLE reviews (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    facility_id UUID REFERENCES facilities(id) ON DELETE CASCADE NOT NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE NOT NULL,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5) NOT NULL,
    comment TEXT,
    booking_id TEXT REFERENCES bookings(id) ON DELETE SET NULL,
    -- Additional review fields
    service_rating INTEGER CHECK (service_rating BETWEEN 1 AND 5),
    facility_rating INTEGER CHECK (facility_rating BETWEEN 1 AND 5),
    value_rating INTEGER CHECK (value_rating BETWEEN 1 AND 5),
    cleanliness_rating INTEGER CHECK (cleanliness_rating BETWEEN 1 AND 5),
    review_title TEXT,
    pros TEXT[],
    cons TEXT[],
    would_recommend BOOLEAN DEFAULT true,
    photos TEXT[], -- Array of photo URLs
    is_verified BOOLEAN DEFAULT false, -- Verified if from actual booking
    response_from_vendor TEXT, -- Vendor can respond to reviews
    response_date TIMESTAMP WITH TIME ZONE,
    is_featured BOOLEAN DEFAULT false,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 12. NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    recipient_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('booking', 'payment', 'reminder', 'promotion', 'system', 'chat', 'review')),
    entity_type TEXT, -- booking, payment, etc.
    entity_id TEXT, -- ID of related entity
    is_read BOOLEAN DEFAULT false,
    action_url TEXT, -- Deep link for app navigation
    push_sent BOOLEAN DEFAULT false,
    email_sent BOOLEAN DEFAULT false,
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 13. FACILITY_IMAGES TABLE
-- =====================================================
CREATE TABLE facility_images (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    facility_id UUID REFERENCES facilities(id) ON DELETE CASCADE NOT NULL,
    court_id TEXT REFERENCES courts(id) ON DELETE CASCADE, -- Optional: specific to a court
    image_url TEXT NOT NULL,
    image_type TEXT DEFAULT 'general' CHECK (image_type IN ('general', 'court', 'amenity', 'exterior', 'interior')),
    caption TEXT,
    alt_text TEXT,
    display_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT false, -- Primary image for the facility/court
    is_active BOOLEAN DEFAULT true,
    uploaded_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    file_size INTEGER, -- In bytes
    dimensions TEXT, -- e.g., "1920x1080"
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 14. LOYALTY_PROGRAMS TABLE
-- =====================================================
CREATE TABLE loyalty_programs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    facility_id UUID REFERENCES facilities(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('points', 'visits', 'spend', 'subscription')),
    rules JSONB NOT NULL, -- Store program rules as JSON
    rewards JSONB NOT NULL, -- Store rewards structure as JSON
    is_active BOOLEAN DEFAULT true,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 15. CUSTOMER_LOYALTY TABLE
-- =====================================================
CREATE TABLE customer_loyalty (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE NOT NULL,
    facility_id UUID REFERENCES facilities(id) ON DELETE CASCADE NOT NULL,
    program_id UUID REFERENCES loyalty_programs(id) ON DELETE CASCADE NOT NULL,
    points_earned INTEGER DEFAULT 0,
    points_redeemed INTEGER DEFAULT 0,
    total_visits INTEGER DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0.00,
    tier_level TEXT DEFAULT 'bronze',
    last_activity TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(customer_id, facility_id, program_id)
);

-- =====================================================
-- 16. BUSINESS_HOURS TABLE
-- =====================================================
CREATE TABLE business_hours (
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

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
-- Core table indexes
CREATE INDEX idx_profiles_user_type ON profiles(user_type);
CREATE INDEX idx_profiles_location ON profiles(location);
CREATE INDEX idx_profiles_rating ON profiles(rating);
-- Indexes for facilities and amenities arrays (using GIN for better array search performance)
CREATE INDEX idx_profiles_facilities_list ON profiles USING GIN (facilities_list);
CREATE INDEX idx_profiles_services_list ON profiles USING GIN (services_list);
CREATE INDEX idx_profiles_amenities_list ON profiles USING GIN (amenities_list);

-- Court equipment and amenities indexes
CREATE INDEX idx_courts_equipment_provided ON courts USING GIN (equipment_provided);
CREATE INDEX idx_courts_amenities ON courts USING GIN (amenities);

CREATE INDEX idx_facilities_owner ON facilities(owner_id);
CREATE INDEX idx_facilities_location ON facilities(location);

CREATE INDEX idx_courts_facility ON courts(facility_id);
CREATE INDEX idx_courts_active ON courts(is_active);
CREATE INDEX idx_courts_type ON courts(type);

CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_email ON customers(email);

CREATE INDEX idx_bookings_facility ON bookings(facility_id);
CREATE INDEX idx_bookings_court ON bookings(court_id);
CREATE INDEX idx_bookings_date ON bookings(booking_date);
CREATE INDEX idx_bookings_customer ON bookings(customer_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_payment_status ON bookings(payment_status);
CREATE INDEX idx_bookings_customer_phone ON bookings(customer_phone);
CREATE INDEX idx_bookings_date_status ON bookings(booking_date, status);

CREATE INDEX idx_time_slots_court_date ON time_slots(court_id, slot_date);
CREATE INDEX idx_time_slots_status ON time_slots(status);
CREATE INDEX idx_time_slots_date ON time_slots(slot_date);
CREATE INDEX idx_time_slots_booking ON time_slots(booking_id);

CREATE INDEX idx_chat_conversations_vendor ON chat_conversations(vendor_id);
CREATE INDEX idx_chat_conversations_customer ON chat_conversations(customer_id);
CREATE INDEX idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_sender ON chat_messages(sender_id);

CREATE INDEX idx_pending_bookings_facility ON pending_bookings(facility_id);
CREATE INDEX idx_pending_bookings_status ON pending_bookings(status);
CREATE INDEX idx_pending_bookings_sport ON pending_bookings(sport);
CREATE INDEX idx_pending_bookings_date ON pending_bookings(booking_date);
CREATE INDEX idx_pending_bookings_expires ON pending_bookings(expires_at);

CREATE INDEX idx_pricing_rules_facility ON pricing_rules(facility_id);
CREATE INDEX idx_pricing_rules_court ON pricing_rules(court_id);
CREATE INDEX idx_pricing_rules_active ON pricing_rules(is_active);

-- New table indexes
CREATE INDEX idx_reviews_facility ON reviews(facility_id);
CREATE INDEX idx_reviews_customer ON reviews(customer_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_verified ON reviews(is_verified);
CREATE INDEX idx_reviews_featured ON reviews(is_featured);

CREATE INDEX idx_notifications_recipient ON notifications(recipient_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at);
CREATE INDEX idx_notifications_priority ON notifications(priority);

CREATE INDEX idx_facility_images_facility ON facility_images(facility_id);
CREATE INDEX idx_facility_images_court ON facility_images(court_id);
CREATE INDEX idx_facility_images_primary ON facility_images(is_primary);
CREATE INDEX idx_facility_images_active ON facility_images(is_active);

CREATE INDEX idx_loyalty_programs_facility ON loyalty_programs(facility_id);
CREATE INDEX idx_loyalty_programs_active ON loyalty_programs(is_active);

CREATE INDEX idx_customer_loyalty_customer ON customer_loyalty(customer_id);
CREATE INDEX idx_customer_loyalty_facility ON customer_loyalty(facility_id);
CREATE INDEX idx_customer_loyalty_program ON customer_loyalty(program_id);

CREATE INDEX idx_business_hours_profile ON business_hours(profile_id);
CREATE INDEX idx_business_hours_day ON business_hours(day_of_week);
CREATE INDEX idx_business_hours_open ON business_hours(is_open);

-- =====================================================
-- VIEWS FOR EFFICIENT DATA LOADING
-- =====================================================

-- View for facility stats (matches getFacilityStats in SupabaseService)
CREATE OR REPLACE VIEW facility_stats AS
SELECT 
    f.id as facility_id,
    f.name as facility_name,
    f.owner_id,
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
LEFT JOIN courts c ON f.id = c.facility_id
LEFT JOIN bookings b ON f.id = b.facility_id
GROUP BY f.id, f.name, f.owner_id;

-- View for available courts (used for quick availability checks)
CREATE OR REPLACE VIEW available_courts AS
SELECT 
    c.*,
    f.name as facility_name,
    f.location as facility_location
FROM courts c
JOIN facilities f ON c.facility_id = f.id
WHERE c.is_active = true;

-- View for vendor business hours with current status
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
-- FUNCTIONS FOR APP COMPATIBILITY AND DATA MANAGEMENT
-- =====================================================

-- Function to get facility statistics efficiently (matches app's getFacilityStats)
DROP FUNCTION IF EXISTS get_facility_stats(UUID);
CREATE OR REPLACE FUNCTION get_facility_stats(facility_uuid UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    pending_count INTEGER;
    today_count INTEGER;
    courts_count INTEGER;
    revenue DECIMAL(10,2);
BEGIN
    -- Get pending bookings count
    SELECT COUNT(*) INTO pending_count
    FROM bookings 
    WHERE facility_id = facility_uuid 
    AND status = 'pending';
    
    -- Get today's bookings count
    SELECT COUNT(*) INTO today_count
    FROM bookings 
    WHERE facility_id = facility_uuid 
    AND booking_date = CURRENT_DATE;
    
    -- Get active courts count
    SELECT COUNT(*) INTO courts_count
    FROM courts 
    WHERE facility_id = facility_uuid 
    AND is_active = true;
    
    -- Get monthly revenue (completed bookings)
    SELECT COALESCE(SUM(total_amount), 0) INTO revenue
    FROM bookings 
    WHERE facility_id = facility_uuid 
    AND status = 'completed'
    AND EXTRACT(MONTH FROM booking_date) = EXTRACT(MONTH FROM CURRENT_DATE)
    AND EXTRACT(YEAR FROM booking_date) = EXTRACT(YEAR FROM CURRENT_DATE);
    
    -- Build JSON response matching app expectations
    result := json_build_object(
        'pending_bookings', pending_count,
        'today_bookings', today_count,
        'total_courts', courts_count,
        'monthly_revenue', revenue
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNCTIONS FOR APP COMPATIBILITY (NO AUTO DATA CREATION)
-- =====================================================

-- Function to create user profile only (no facility creation)
DROP FUNCTION IF EXISTS create_user_profile_on_signup(UUID, TEXT, TEXT, TEXT, TEXT, TEXT);
CREATE OR REPLACE FUNCTION create_user_profile_on_signup(
    user_id UUID,
    user_name TEXT,
    user_phone TEXT DEFAULT NULL,
    user_facility_name TEXT DEFAULT NULL,
    user_type TEXT DEFAULT 'vendor',
    user_location TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    -- Validate input parameters
    IF user_id IS NULL OR user_name IS NULL OR user_name = '' THEN
        RAISE EXCEPTION 'user_id and user_name are required';
    END IF;
    
    -- Create or update profile only - no automatic facility creation
    INSERT INTO profiles (id, name, phone, facility_name, user_type, location)
    VALUES (
        user_id, 
        user_name, 
        NULLIF(user_phone, ''), 
        NULLIF(user_facility_name, ''), 
        COALESCE(user_type, 'vendor'), 
        NULLIF(user_location, '')
    )
    ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        phone = EXCLUDED.phone,
        facility_name = EXCLUDED.facility_name,
        user_type = EXCLUDED.user_type,
        location = EXCLUDED.location,
        updated_at = NOW();
    
EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Error creating user profile: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Function to manually update facility stats (call when needed)
DROP FUNCTION IF EXISTS update_facility_stats_manual(UUID);
CREATE OR REPLACE FUNCTION update_facility_stats_manual(facility_uuid UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE facilities 
    SET 
        total_courts = (
            SELECT COUNT(*) 
            FROM courts 
            WHERE facility_id = facility_uuid 
            AND is_active = true
        ),
        pending_bookings = (
            SELECT COUNT(*) 
            FROM bookings 
            WHERE facility_id = facility_uuid 
            AND status = 'pending'
        ),
        today_bookings = (
            SELECT COUNT(*) 
            FROM bookings 
            WHERE facility_id = facility_uuid 
            AND booking_date = CURRENT_DATE
        ),
        monthly_revenue = (
            SELECT COALESCE(SUM(total_amount), 0) 
            FROM bookings 
            WHERE facility_id = facility_uuid 
            AND status = 'completed'
            AND EXTRACT(MONTH FROM booking_date) = EXTRACT(MONTH FROM CURRENT_DATE)
            AND EXTRACT(YEAR FROM booking_date) = EXTRACT(YEAR FROM CURRENT_DATE)
        ),
        updated_at = NOW()
    WHERE id = facility_uuid;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up old time slots (manual execution)
DROP FUNCTION IF EXISTS cleanup_old_time_slots();
CREATE OR REPLACE FUNCTION cleanup_old_time_slots()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM time_slots 
    WHERE slot_date < CURRENT_DATE - INTERVAL '7 days'
    AND status = 'available';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to manually generate time slots for a specific date and court
DROP FUNCTION IF EXISTS generate_time_slots_for_court_and_date(TEXT, DATE);
CREATE OR REPLACE FUNCTION generate_time_slots_for_court_and_date(
    court_uuid TEXT, 
    target_date DATE
)
RETURNS INTEGER AS $$
DECLARE
    inserted_count INTEGER := 0;
BEGIN
    -- Insert time slots for the target date if they don't exist
    INSERT INTO time_slots (court_id, slot_date, time_slot, status)
    SELECT 
        court_uuid,
        target_date,
        time_slot,
        'available'
    FROM (VALUES 
        ('07:00 AM'), ('07:30 AM'), ('08:00 AM'), ('08:30 AM'),
        ('09:00 AM'), ('09:30 AM'), ('10:00 AM'), ('10:30 AM'),
        ('11:00 AM'), ('11:30 AM'), ('12:00 PM'), ('12:30 PM'),
        ('01:00 PM'), ('01:30 PM'), ('02:00 PM'), ('02:30 PM'),
        ('03:00 PM'), ('03:30 PM'), ('04:00 PM'), ('04:30 PM'),
        ('05:00 PM'), ('05:30 PM'), ('06:00 PM'), ('06:30 PM'),
        ('07:00 PM'), ('07:30 PM'), ('08:00 PM'), ('08:30 PM'),
        ('09:00 PM'), ('09:30 PM'), ('10:00 PM'), ('10:30 PM')
    ) AS slots(time_slot)
    ON CONFLICT (court_id, slot_date, time_slot) DO NOTHING;
    
    GET DIAGNOSTICS inserted_count = ROW_COUNT;
    RETURN inserted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to update facility rating based on reviews
DROP FUNCTION IF EXISTS update_facility_rating(UUID);
CREATE OR REPLACE FUNCTION update_facility_rating(facility_uuid UUID)
RETURNS VOID AS $$
DECLARE
    avg_rating DECIMAL(2,1);
    review_count INTEGER;
BEGIN
    -- Calculate average rating and review count
    SELECT 
        COALESCE(AVG(rating), 0.0)::DECIMAL(2,1),
        COUNT(*)
    INTO avg_rating, review_count
    FROM reviews 
    WHERE facility_id = facility_uuid;
    
    -- Update profiles table (assuming facility owner's profile)
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
$$ LANGUAGE plpgsql;

-- Function to create notification
DROP FUNCTION IF EXISTS create_notification(UUID, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
CREATE OR REPLACE FUNCTION create_notification(
    recipient_uuid UUID,
    notification_title TEXT,
    notification_message TEXT,
    notification_type TEXT,
    entity_type_param TEXT DEFAULT NULL,
    entity_id_param TEXT DEFAULT NULL,
    priority_level TEXT DEFAULT 'normal'
)
RETURNS UUID AS $$
DECLARE
    notification_id UUID;
BEGIN
    INSERT INTO notifications (
        recipient_id, title, message, type, entity_type, entity_id, priority
    ) VALUES (
        recipient_uuid, notification_title, notification_message, 
        notification_type, entity_type_param, entity_id_param, priority_level
    ) RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ LANGUAGE plpgsql;

-- Function to expire old pending bookings
DROP FUNCTION IF EXISTS expire_old_pending_bookings();
CREATE OR REPLACE FUNCTION expire_old_pending_bookings()
RETURNS INTEGER AS $$
DECLARE
    expired_count INTEGER;
BEGIN
    UPDATE pending_bookings 
    SET 
        status = 'expired',
        updated_at = NOW()
    WHERE status = 'pending' 
    AND expires_at < NOW();
    
    GET DIAGNOSTICS expired_count = ROW_COUNT;
    RETURN expired_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get vendor dashboard stats
DROP FUNCTION IF EXISTS get_vendor_dashboard_stats(UUID);
CREATE OR REPLACE FUNCTION get_vendor_dashboard_stats(vendor_uuid UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_facilities INTEGER;
    total_courts INTEGER;
    today_bookings INTEGER;
    pending_bookings INTEGER;
    monthly_revenue DECIMAL(10,2);
    total_customers INTEGER;
    avg_rating DECIMAL(2,1);
    unread_messages INTEGER;
    pending_requests INTEGER;
BEGIN
    -- Get basic counts
    SELECT COUNT(*) INTO total_facilities
    FROM facilities WHERE owner_id = vendor_uuid;
    
    SELECT COUNT(*) INTO total_courts
    FROM courts c
    JOIN facilities f ON c.facility_id = f.id
    WHERE f.owner_id = vendor_uuid AND c.is_active = true;
    
    SELECT COUNT(*) INTO today_bookings
    FROM bookings b
    JOIN facilities f ON b.facility_id = f.id
    WHERE f.owner_id = vendor_uuid 
    AND b.booking_date = CURRENT_DATE;
    
    SELECT COUNT(*) INTO pending_bookings
    FROM bookings b
    JOIN facilities f ON b.facility_id = f.id
    WHERE f.owner_id = vendor_uuid 
    AND b.status = 'pending';
    
    -- Get monthly revenue
    SELECT COALESCE(SUM(b.total_amount), 0) INTO monthly_revenue
    FROM bookings b
    JOIN facilities f ON b.facility_id = f.id
    WHERE f.owner_id = vendor_uuid 
    AND b.status = 'completed'
    AND EXTRACT(MONTH FROM b.booking_date) = EXTRACT(MONTH FROM CURRENT_DATE)
    AND EXTRACT(YEAR FROM b.booking_date) = EXTRACT(YEAR FROM CURRENT_DATE);
    
    -- Get unique customers this month
    SELECT COUNT(DISTINCT b.customer_id) INTO total_customers
    FROM bookings b
    JOIN facilities f ON b.facility_id = f.id
    WHERE f.owner_id = vendor_uuid
    AND EXTRACT(MONTH FROM b.booking_date) = EXTRACT(MONTH FROM CURRENT_DATE)
    AND EXTRACT(YEAR FROM b.booking_date) = EXTRACT(YEAR FROM CURRENT_DATE);
    
    -- Get average rating
    SELECT COALESCE(AVG(r.rating), 0.0)::DECIMAL(2,1) INTO avg_rating
    FROM reviews r
    JOIN facilities f ON r.facility_id = f.id
    WHERE f.owner_id = vendor_uuid;
    
    -- Get unread chat messages
    SELECT COUNT(*) INTO unread_messages
    FROM chat_messages cm
    JOIN chat_conversations cc ON cm.conversation_id = cc.id
    WHERE cc.vendor_id = vendor_uuid 
    AND cm.sender_type = 'customer'
    AND cm.is_read = false;
    
    -- Get pending booking requests
    SELECT COUNT(*) INTO pending_requests
    FROM pending_bookings pb
    JOIN facilities f ON pb.facility_id = f.id
    WHERE f.owner_id = vendor_uuid 
    AND pb.status = 'pending';
    
    -- Build JSON response
    result := json_build_object(
        'total_facilities', total_facilities,
        'total_courts', total_courts,
        'today_bookings', today_bookings,
        'pending_bookings', pending_bookings,
        'monthly_revenue', monthly_revenue,
        'total_customers', total_customers,
        'avg_rating', avg_rating,
        'unread_messages', unread_messages,
        'pending_requests', pending_requests
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- BUSINESS HOURS FUNCTIONS
-- =====================================================

-- Function to update business hours display in profiles table
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

-- Function to set business hours for a profile
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

-- Function to get current business status (open/closed)
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

-- Function to set default business hours (Monday-Friday 9 AM - 6 PM)
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

-- Function to get business hours in a readable format
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

-- =====================================================
-- ROW LEVEL SECURITY POLICIES (Optional - for enhanced security)
-- =====================================================

-- Enable RLS on sensitive tables (uncomment if needed)
-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE facilities ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE courts ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Example policies (uncomment and customize if using RLS)
-- CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
-- CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
-- CREATE POLICY "Vendors can view own facilities" ON facilities FOR SELECT USING (auth.uid() = owner_id);
-- CREATE POLICY "Vendors can manage own facilities" ON facilities FOR ALL USING (auth.uid() = owner_id);

-- =====================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Function to update timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply timestamp triggers to all tables
CREATE TRIGGER update_profiles_timestamp
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_facilities_timestamp
    BEFORE UPDATE ON facilities
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_courts_timestamp
    BEFORE UPDATE ON courts
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_customers_timestamp
    BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_bookings_timestamp
    BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_time_slots_timestamp
    BEFORE UPDATE ON time_slots
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_chat_conversations_timestamp
    BEFORE UPDATE ON chat_conversations
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_pending_bookings_timestamp
    BEFORE UPDATE ON pending_bookings
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_pricing_rules_timestamp
    BEFORE UPDATE ON pricing_rules
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_reviews_timestamp
    BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_notifications_timestamp
    BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_facility_images_timestamp
    BEFORE UPDATE ON facility_images
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_loyalty_programs_timestamp
    BEFORE UPDATE ON loyalty_programs
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_customer_loyalty_timestamp
    BEFORE UPDATE ON customer_loyalty
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_business_hours_timestamp
    BEFORE UPDATE ON business_hours
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger function to update business hours display when business_hours table changes
CREATE OR REPLACE FUNCTION trigger_update_business_hours_display()
RETURNS TRIGGER AS $$
BEGIN
    -- Update display for the affected profile
    PERFORM update_business_hours_display(COALESCE(NEW.profile_id, OLD.profile_id));
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Create trigger for business hours changes
CREATE TRIGGER update_business_hours_display_trigger
    AFTER INSERT OR UPDATE OR DELETE ON business_hours
    FOR EACH ROW EXECUTE FUNCTION trigger_update_business_hours_display();

-- Function to update facility stats when bookings change
CREATE OR REPLACE FUNCTION update_facility_stats_on_booking_change()
RETURNS TRIGGER AS $$
DECLARE
    facility_uuid UUID;
BEGIN
    -- Get facility ID from the booking
    facility_uuid := COALESCE(NEW.facility_id, OLD.facility_id);
    
    -- Update facility statistics
    UPDATE facilities 
    SET 
        pending_bookings = (
            SELECT COUNT(*) 
            FROM bookings 
            WHERE facility_id = facility_uuid 
            AND status = 'pending'
        ),
        today_bookings = (
            SELECT COUNT(*) 
            FROM bookings 
            WHERE facility_id = facility_uuid 
            AND booking_date = CURRENT_DATE
        ),
        monthly_revenue = (
            SELECT COALESCE(SUM(total_amount), 0) 
            FROM bookings 
            WHERE facility_id = facility_uuid 
            AND status = 'completed'
            AND EXTRACT(MONTH FROM booking_date) = EXTRACT(MONTH FROM CURRENT_DATE)
            AND EXTRACT(YEAR FROM booking_date) = EXTRACT(YEAR FROM CURRENT_DATE)
        ),
        updated_at = NOW()
    WHERE id = facility_uuid;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger for booking changes
CREATE TRIGGER update_facility_stats_on_booking
    AFTER INSERT OR UPDATE OR DELETE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_facility_stats_on_booking_change();

-- Function to update court count when courts change
CREATE OR REPLACE FUNCTION update_facility_court_count()
RETURNS TRIGGER AS $$
DECLARE
    facility_uuid UUID;
BEGIN
    facility_uuid := COALESCE(NEW.facility_id, OLD.facility_id);
    
    UPDATE facilities 
    SET 
        total_courts = (
            SELECT COUNT(*) 
            FROM courts 
            WHERE facility_id = facility_uuid 
            AND is_active = true
        ),
        updated_at = NOW()
    WHERE id = facility_uuid;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger for court changes
CREATE TRIGGER update_facility_court_count_trigger
    AFTER INSERT OR UPDATE OR DELETE ON courts
    FOR EACH ROW EXECUTE FUNCTION update_facility_court_count();

-- Function to update chat conversation when new message is sent
CREATE OR REPLACE FUNCTION update_conversation_on_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE chat_conversations 
    SET 
        last_message = NEW.message,
        last_message_time = NEW.created_at,
        is_read_by_vendor = CASE 
            WHEN NEW.sender_type = 'vendor' THEN true 
            ELSE false 
        END,
        is_read_by_customer = CASE 
            WHEN NEW.sender_type = 'customer' THEN true 
            ELSE false 
        END,
        updated_at = NOW()
    WHERE id = NEW.conversation_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for new chat messages
CREATE TRIGGER update_conversation_on_new_message
    AFTER INSERT ON chat_messages
    FOR EACH ROW EXECUTE FUNCTION update_conversation_on_message();

-- Function to update facility rating when reviews change
CREATE OR REPLACE FUNCTION update_rating_on_review_change()
RETURNS TRIGGER AS $$
DECLARE
    facility_uuid UUID;
BEGIN
    facility_uuid := COALESCE(NEW.facility_id, OLD.facility_id);
    
    -- Update facility rating
    PERFORM update_facility_rating(facility_uuid);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger for review changes
CREATE TRIGGER update_rating_on_review
    AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_rating_on_review_change();

-- =====================================================
-- SCHEDULED FUNCTIONS (Run these manually or with cron)
-- =====================================================

-- Function to clean up expired data (run daily)
DROP FUNCTION IF EXISTS daily_cleanup();
CREATE OR REPLACE FUNCTION daily_cleanup()
RETURNS JSON AS $$
DECLARE
    expired_bookings INTEGER;
    old_slots INTEGER;
    old_notifications INTEGER;
    result JSON;
BEGIN
    -- Expire old pending bookings
    SELECT expire_old_pending_bookings() INTO expired_bookings;
    
    -- Clean up old time slots (older than 7 days)
    SELECT cleanup_old_time_slots() INTO old_slots;
    
    -- Delete old read notifications (older than 30 days)
    DELETE FROM notifications 
    WHERE is_read = true 
    AND created_at < NOW() - INTERVAL '30 days';
    GET DIAGNOSTICS old_notifications = ROW_COUNT;
    
    -- Return cleanup summary
    result := json_build_object(
        'expired_bookings', expired_bookings,
        'cleaned_slots', old_slots,
        'cleaned_notifications', old_notifications,
        'cleanup_date', NOW()
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SAMPLE DATA INSERTION FUNCTIONS (Optional - for testing)
-- =====================================================

-- Function to create sample data for testing
DROP FUNCTION IF EXISTS create_sample_data();
CREATE OR REPLACE FUNCTION create_sample_data()
RETURNS VOID AS $$
DECLARE
    sample_vendor_id UUID;
    sample_facility_id UUID;
    sample_customer_id UUID;
BEGIN
    -- This function can be used to create sample data for testing
    -- Uncomment and modify as needed for your testing requirements
    
    RAISE NOTICE 'Sample data creation function is available but not implemented';
    RAISE NOTICE 'Modify this function to create test data as needed';
END;
$$ LANGUAGE plpgsql;
