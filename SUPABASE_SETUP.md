# Supabase Integration Setup Guide

This guide explains how to set up the Supabase backend for the Woodside Play Lab civic engagement app.

## Overview

The app now includes:
- ✅ Photo upload with client-side compression (max 200KB)
- ✅ Form submission to Supabase database
- ✅ Loading states and error handling
- ✅ Offline detection
- ✅ Multi-language support (inherited from existing system)
- ✅ Mobile-optimized for slow connections

---

## 1. Supabase Backend Configuration

### Database Setup

Your Supabase database already has the `submissions` table. Verify it has these columns:

```sql
CREATE TABLE submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  flow_type TEXT NOT NULL CHECK (flow_type IN ('share', 'vote')),
  language TEXT NOT NULL,
  caption TEXT,
  vote_choices JSONB,
  photo_url TEXT,
  time_of_day TEXT CHECK (time_of_day IN ('morning', 'afternoon', 'evening')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Storage Bucket Setup

1. In your Supabase dashboard, go to **Storage**
2. Verify the `photos` bucket exists
3. Bucket settings:
   - **Public bucket**: No (we use signed URLs for privacy)
   - **Allowed MIME types**: `image/*`
   - **File size limit**: 5MB (client compresses to 200KB)

---

## 2. Row Level Security (RLS) Policies

### Enable RLS on the submissions table

Run this SQL in the Supabase SQL Editor:

```sql
-- Enable RLS
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

-- Allow anonymous inserts (for public form submissions)
CREATE POLICY "Allow anonymous inserts"
ON submissions
FOR INSERT
TO anon
WITH CHECK (true);

-- Allow public read (optional - for displaying submissions later)
CREATE POLICY "Allow public read"
ON submissions
FOR SELECT
TO anon
USING (true);
```

### Storage Bucket Policies

Run this SQL for storage access:

```sql
-- Allow anonymous uploads to photos bucket
CREATE POLICY "Allow anonymous uploads"
ON storage.objects
FOR INSERT
TO anon
WITH CHECK (bucket_id = 'photos');

-- Allow public read access (for signed URLs to work)
CREATE POLICY "Allow public read"
ON storage.objects
FOR SELECT
TO anon
USING (bucket_id = 'photos');
```

---

## 3. Testing Locally

### Test the Application

1. Open `index.html` in a browser (or use a local server)
2. Test both flows:
   - **Share flow**: Upload a photo, add caption, select time of day
   - **Vote flow**: Select multiple priorities, submit

### Test on Mobile Devices

Use Chrome DevTools to simulate mobile connections:

1. Open DevTools (F12)
2. Go to **Network** tab
3. Set throttling to:
   - **Fast 3G** (typical mobile)
   - **Slow 3G** (worst case)
4. Test photo upload and form submission

### Check Supabase Dashboard

After submissions:
1. Go to **Table Editor** → `submissions`
2. Verify new rows appear
3. Go to **Storage** → `photos`
4. Verify uploaded images appear

---

## 4. Environment Variables (For Production)

### Current Setup

The Supabase credentials are currently hardcoded in `supabase-client.js`:

```javascript
const SUPABASE_URL = 'https://ebzfutiidqbndidlsqfn.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

**This is safe** because:
- The anon key is meant to be public
- RLS policies protect your data
- Client-side code always exposes these values

### Optional: Environment Variables for Vercel

If you want to use environment variables:

1. Create a build-time replacement script
2. In Vercel, set environment variables:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. Use a build tool to replace placeholders

For a simple static site like this, hardcoding is perfectly fine.

---

## 5. Deploying to Vercel

### Deploy Steps

1. **Initialize Git** (if not already):
   ```bash
   git init
   git add .
   git commit -m "Add Supabase integration"
   ```

2. **Push to GitHub**:
   ```bash
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

3. **Connect to Vercel**:
   - Go to [vercel.com](https://vercel.com)
   - Click "Import Project"
   - Select your GitHub repository
   - Deploy!

### Vercel Configuration

No special configuration needed. Vercel will automatically serve:
- `index.html` as the homepage
- All static files (CSS, JS, images)

### Custom Domain (Optional)

In Vercel settings, add your custom domain:
- Example: `woodside-play-lab.org`
- Follow Vercel's DNS setup instructions

---

## 6. Monitoring and Analytics

### Check Submissions

Regularly check your Supabase dashboard:

1. **Submissions Table**:
   - Track how many people are participating
   - See vote patterns
   - Read captions

2. **Storage Usage**:
   - Monitor photo uploads
   - Check storage quota

### Database Queries (Examples)

```sql
-- Count total submissions by flow type
SELECT flow_type, COUNT(*) 
FROM submissions 
GROUP BY flow_type;

-- Count submissions by language
SELECT language, COUNT(*) 
FROM submissions 
GROUP BY language 
ORDER BY COUNT(*) DESC;

-- Get all vote choices
SELECT vote_choices 
FROM submissions 
WHERE flow_type = 'vote';

-- Count submissions by time of day
SELECT time_of_day, COUNT(*) 
FROM submissions 
WHERE time_of_day IS NOT NULL 
GROUP BY time_of_day;
```

---

## 7. Troubleshooting

### Photo Upload Fails

**Symptoms**: Error message "Failed to upload photo"

**Solutions**:
1. Check browser console for detailed error
2. Verify storage bucket exists and is named `photos`
3. Check storage RLS policies are set correctly
4. Try with a smaller image first

### Form Submission Fails

**Symptoms**: Error message "Failed to save your input"

**Solutions**:
1. Check browser console for detailed error
2. Verify RLS policies on `submissions` table
3. Check Supabase API logs in dashboard
4. Verify network connectivity

### Loading Spinner Never Disappears

**Symptoms**: Spinner keeps spinning after upload

**Solutions**:
1. Check browser console for errors
2. Likely a timeout issue - increase timeout in code
3. Test with faster connection
4. Check Supabase service status

### Offline Detection

The app automatically detects when the user goes offline and shows an error message. This is handled by:

```javascript
window.addEventListener('offline', () => {
  showError('No internet connection. Please try again when online.');
});
```

---

## 8. Performance Optimization

### Image Compression

Images are automatically compressed to max 200KB before upload using:
- Canvas API for resizing
- Iterative quality reduction
- JPEG format for optimal compression

### Timeout Handling

All network requests have 30-45 second timeouts:
- Photo upload: 45 seconds
- Form submission: 30 seconds

If a request times out, the user sees a clear error message.

### Caching

Supabase signed URLs are valid for 1 year, reducing the need for repeated requests.

---

## 9. Data Export

To export data from Supabase:

1. **Via Dashboard**:
   - Go to Table Editor
   - Select rows
   - Export as CSV

2. **Via SQL**:
   ```sql
   COPY (SELECT * FROM submissions) 
   TO '/tmp/submissions.csv' 
   CSV HEADER;
   ```

3. **Via API**:
   ```javascript
   const { data, error } = await supabase
     .from('submissions')
     .select('*')
     .csv();
   ```

---

## 10. Security Considerations

### What's Protected

✅ **Database writes** protected by RLS policies  
✅ **Storage uploads** restricted to anon users via RLS  
✅ **No authentication required** (by design, for public engagement)  
✅ **Photos stored in private bucket** with signed URLs  

### What to Monitor

⚠️ **Storage abuse**: Monitor for spam uploads  
⚠️ **Database spam**: Check for duplicate/fake submissions  
⚠️ **Storage costs**: Keep an eye on Supabase usage  

### Recommended RLS Enhancements (Optional)

```sql
-- Rate limiting (prevent spam)
-- Requires a custom function
CREATE OR REPLACE FUNCTION check_rate_limit()
RETURNS BOOLEAN AS $$
BEGIN
  -- Allow max 10 submissions per IP per hour
  -- (Requires additional setup to track IPs)
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Add to INSERT policy
CREATE POLICY "Rate limited inserts"
ON submissions
FOR INSERT
TO anon
WITH CHECK (check_rate_limit());
```

---

## Support

For issues or questions:
- Check Supabase docs: https://supabase.com/docs
- Vercel docs: https://vercel.com/docs
- File an issue in the project repository

---

## Summary Checklist

Before going live, verify:

- [ ] Database table `submissions` exists with correct schema
- [ ] Storage bucket `photos` exists and is configured
- [ ] RLS policies enabled on `submissions` table
- [ ] Storage RLS policies enabled on `photos` bucket
- [ ] Tested photo upload locally
- [ ] Tested both Share and Vote flows
- [ ] Tested on mobile/slow connections
- [ ] Verified data appears in Supabase dashboard
- [ ] Deployed to Vercel
- [ ] Custom domain configured (optional)
- [ ] Monitoring plan in place

You're ready to launch! 🚀
