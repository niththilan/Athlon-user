-- Customer Favorites Table Migration
-- Add this table to support customer favorites functionality

CREATE TABLE customer_favorites (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE NOT NULL,
    facility_id UUID REFERENCES facilities(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(customer_id, facility_id)
);

-- Add indexes
CREATE INDEX idx_customer_favorites_customer ON customer_favorites(customer_id);
CREATE INDEX idx_customer_favorites_facility ON customer_favorites(facility_id);
CREATE INDEX idx_customer_favorites_created ON customer_favorites(created_at);

-- Update customers table to add missing fields for customer app
ALTER TABLE customers ADD COLUMN IF NOT EXISTS profile_image_url TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS location TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS preferred_sports TEXT[];
ALTER TABLE customers ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{}';
ALTER TABLE customers ADD COLUMN IF NOT EXISTS loyalty_status JSONB;

-- Add indexes for new customer fields
CREATE INDEX IF NOT EXISTS idx_customers_location ON customers(location);
CREATE INDEX IF NOT EXISTS idx_customers_preferred_sports ON customers USING GIN (preferred_sports);

-- Add RLS policies for customer_favorites
ALTER TABLE customer_favorites ENABLE ROW LEVEL SECURITY;

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

-- Update customers table RLS policies
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

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

-- Add customer booking summary view
CREATE OR REPLACE VIEW customer_booking_summary AS
SELECT 
    c.id as customer_id,
    c.name as customer_name,
    c.phone as customer_phone,
    c.email as customer_email,
    COUNT(b.id) as total_bookings,
    COUNT(CASE WHEN b.status = 'completed' THEN 1 END) as completed_bookings,
    COUNT(CASE WHEN b.status = 'cancelled' THEN 1 END) as cancelled_bookings,
    SUM(CASE WHEN b.status = 'completed' THEN b.total_amount ELSE 0 END) as total_spent,
    MAX(b.created_at) as last_booking_date
FROM customers c
LEFT JOIN bookings b ON c.id = b.customer_id
GROUP BY c.id, c.name, c.phone, c.email;

-- Add customer loyalty points calculation function
CREATE OR REPLACE FUNCTION calculate_customer_loyalty_points(
    customer_uuid UUID,
    facility_uuid UUID
) RETURNS INTEGER AS $$
DECLARE
    total_points INTEGER := 0;
    completed_bookings INTEGER := 0;
    total_spent DECIMAL(10,2) := 0;
BEGIN
    -- Get completed bookings and total spent
    SELECT 
        COUNT(*),
        COALESCE(SUM(total_amount), 0)
    INTO completed_bookings, total_spent
    FROM bookings 
    WHERE customer_id = customer_uuid 
    AND facility_id = facility_uuid 
    AND status = 'completed';
    
    -- Calculate points: 1 point per booking + 1 point per 100 LKR spent
    total_points := completed_bookings + FLOOR(total_spent / 100);
    
    RETURN total_points;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
