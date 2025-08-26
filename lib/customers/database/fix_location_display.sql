-- Fix full_address field to match location field
-- This will update all profiles where full_address doesn't match location
UPDATE profiles 
SET full_address = location 
WHERE location IS NOT NULL 
  AND location != '' 
  AND (full_address IS NULL OR full_address != location);
