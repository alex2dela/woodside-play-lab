-- ============================================
-- SUPABASE SQL SETUP SCRIPT
-- Woodside Play Lab - Community Engagement App
-- ============================================
-- 
-- Run these commands in your Supabase SQL Editor:
-- Dashboard -> SQL Editor -> New Query
--
-- Copy and paste each section, then click "Run"
-- ============================================

-- ============================================
-- 1. CREATE DATABASE TABLE
-- ============================================
-- Skip this if your table already exists

CREATE TABLE IF NOT EXISTS submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  flow_type TEXT NOT NULL CHECK (flow_type IN ('share', 'vote')),
  language TEXT NOT NULL,
  caption TEXT,
  vote_choices JSONB,
  photo_url TEXT,
  time_of_day TEXT CHECK (time_of_day IN ('morning', 'afternoon', 'evening')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_submissions_flow_type ON submissions(flow_type);
CREATE INDEX IF NOT EXISTS idx_submissions_language ON submissions(language);
CREATE INDEX IF NOT EXISTS idx_submissions_created_at ON submissions(created_at DESC);

-- ============================================
-- 2. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on submissions table
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Allow anonymous inserts" ON submissions;
DROP POLICY IF EXISTS "Allow public read" ON submissions;

-- Allow anonymous users to insert submissions
CREATE POLICY "Allow anonymous inserts"
ON submissions
FOR INSERT
TO anon
WITH CHECK (true);

-- Allow anyone to read submissions (optional - for future features)
-- Comment this out if you don't want submissions to be publicly readable
CREATE POLICY "Allow public read"
ON submissions
FOR SELECT
TO anon
USING (true);

-- ============================================
-- 3. STORAGE BUCKET RLS POLICIES
-- ============================================
-- These allow anonymous photo uploads to the 'photos' bucket

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow anonymous uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;

-- Allow anonymous uploads to 'photos' bucket
CREATE POLICY "Allow anonymous uploads"
ON storage.objects
FOR INSERT
TO anon
WITH CHECK (bucket_id = 'photos');

-- Allow reading photos (needed for signed URLs to work)
CREATE POLICY "Allow public read"
ON storage.objects
FOR SELECT
TO anon
USING (bucket_id = 'photos');

-- ============================================
-- 4. VERIFY SETUP (Optional)
-- ============================================
-- Run these queries to verify everything is set up correctly

-- Check if table exists
SELECT table_name 
FROM information_schema.tables 
WHERE table_name = 'submissions';

-- Check RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'submissions';

-- Check policies
SELECT tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'submissions';

-- ============================================
-- 5. USEFUL QUERIES FOR MONITORING
-- ============================================

-- Count total submissions
SELECT COUNT(*) as total_submissions FROM submissions;

-- Count by flow type
SELECT flow_type, COUNT(*) as count
FROM submissions
GROUP BY flow_type
ORDER BY count DESC;

-- Count by language
SELECT language, COUNT(*) as count
FROM submissions
GROUP BY language
ORDER BY count DESC;

-- Recent submissions (last 10)
SELECT 
  id,
  flow_type,
  language,
  CASE WHEN caption IS NOT NULL THEN LEFT(caption, 50) ELSE NULL END as caption_preview,
  time_of_day,
  created_at
FROM submissions
ORDER BY created_at DESC
LIMIT 10;

-- Vote choices summary
SELECT 
  jsonb_array_elements(vote_choices)->>'choice' as choice,
  COUNT(*) as votes
FROM submissions
WHERE flow_type = 'vote'
GROUP BY choice
ORDER BY votes DESC;

-- Submissions by time of day
SELECT 
  time_of_day,
  COUNT(*) as count
FROM submissions
WHERE time_of_day IS NOT NULL
GROUP BY time_of_day
ORDER BY count DESC;

-- Photos uploaded count
SELECT COUNT(*) as photos_uploaded
FROM submissions
WHERE photo_url IS NOT NULL;

-- Submissions by date
SELECT 
  DATE(created_at) as date,
  COUNT(*) as submissions
FROM submissions
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Language distribution percentage
SELECT 
  language,
  COUNT(*) as count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
FROM submissions
GROUP BY language
ORDER BY count DESC;

-- ============================================
-- 6. DATA CLEANUP (Optional - Use with Caution!)
-- ============================================
-- Only use these if you need to clear test data

-- Delete all test submissions (BE CAREFUL!)
-- DELETE FROM submissions WHERE created_at < NOW() - INTERVAL '1 hour';

-- Delete specific submission by ID
-- DELETE FROM submissions WHERE id = 'your-uuid-here';

-- Delete all submissions (DANGER - Use only in development!)
-- TRUNCATE TABLE submissions;

-- ============================================
-- 7. EXPORT DATA
-- ============================================

-- Export all submissions as CSV
-- Copy the results and paste into a spreadsheet
SELECT 
  id,
  flow_type,
  language,
  caption,
  vote_choices::text as vote_choices,
  photo_url,
  time_of_day,
  created_at
FROM submissions
ORDER BY created_at DESC;

-- Export vote results summary
SELECT 
  jsonb_array_elements(vote_choices)->>'choice' as priority,
  CASE 
    WHEN jsonb_array_elements(vote_choices)->>'text' IS NOT NULL 
    THEN jsonb_array_elements(vote_choices)->>'text'
    ELSE NULL 
  END as custom_text,
  language,
  created_at
FROM submissions
WHERE flow_type = 'vote'
ORDER BY created_at DESC;

-- ============================================
-- 8. PERFORMANCE OPTIMIZATION (Optional)
-- ============================================

-- Add additional indexes if you have lots of data
-- CREATE INDEX IF NOT EXISTS idx_submissions_time_of_day ON submissions(time_of_day) WHERE time_of_day IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_submissions_photo_url ON submissions(photo_url) WHERE photo_url IS NOT NULL;

-- Enable statistics for better query planning
-- ANALYZE submissions;

-- ============================================
-- NOTES:
-- ============================================
-- 1. Storage Bucket Setup:
--    - Create a bucket named 'photos' in Storage section
--    - Set it as PRIVATE (not public)
--    - Signed URLs will be used for access
--
-- 2. API Keys:
--    - Get your Anon Key from: Settings -> API
--    - Update supabase-client.js with your credentials
--
-- 3. RLS Security:
--    - These policies allow anonymous submissions
--    - No authentication required (by design)
--    - Perfect for public civic engagement
--
-- 4. Rate Limiting:
--    - Consider adding rate limiting in production
--    - Can be done at Supabase project level
--    - Or implement in RLS policies with custom functions
--
-- ============================================
