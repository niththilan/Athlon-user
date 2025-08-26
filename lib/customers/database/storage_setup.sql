-- =====================================================
-- SUPABASE STORAGE SETUP FOR VENDOR COURT IMAGES
-- Execute these commands in your Supabase SQL Editor
-- =====================================================

-- Step 1: Create the 'Vendor' storage bucket (if it doesn't exist)
-- Note: This should be done in the Supabase Dashboard Storage section
-- Bucket Name: Vendor
-- Public: true (for public access to images)
-- File Size Limit: 5MB
-- Allowed MIME types: image/jpeg, image/png, image/webp

-- Step 2: Set up RLS (Row Level Security) policies for the storage bucket

-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload to own folder" ON storage.objects
  FOR INSERT 
  TO authenticated 
  WITH CHECK (bucket_id = 'Vendor' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow authenticated users to view all images in the Vendor bucket
CREATE POLICY "Anyone can view vendor images" ON storage.objects
  FOR SELECT 
  TO authenticated 
  USING (bucket_id = 'Vendor');

-- Allow authenticated users to delete their own images
CREATE POLICY "Users can delete own images" ON storage.objects
  FOR DELETE 
  TO authenticated 
  USING (bucket_id = 'Vendor' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow authenticated users to update their own images
CREATE POLICY "Users can update own images" ON storage.objects
  FOR UPDATE 
  TO authenticated 
  USING (bucket_id = 'Vendor' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Step 3: Create indexes for better performance on facility_images table
CREATE INDEX IF NOT EXISTS idx_facility_images_facility_type ON facility_images(facility_id, image_type);
CREATE INDEX IF NOT EXISTS idx_facility_images_uploaded_by ON facility_images(uploaded_by);

-- Step 4: Verification queries to check setup
-- Run these to verify everything is working:

-- Check if bucket exists
-- SELECT * FROM storage.buckets WHERE id = 'Vendor';

-- Check policies
-- SELECT * FROM pg_policies WHERE tablename = 'objects' AND schemaname = 'storage';

-- Check facility_images table structure
-- SELECT column_name, data_type, is_nullable FROM information_schema.columns 
-- WHERE table_name = 'facility_images' ORDER BY ordinal_position;

-- =====================================================
-- NOTES FOR SETUP:
-- =====================================================
-- 1. Create the 'Vendor' bucket in Supabase Dashboard > Storage
-- 2. Set it as public for image access
-- 3. Configure file size limit to 5MB
-- 4. Allow image MIME types: image/jpeg, image/png, image/webp
-- 5. Run the policies above in SQL Editor
-- 6. Test upload functionality from your app
-- =====================================================
