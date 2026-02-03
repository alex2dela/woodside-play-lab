# Quick Start Guide

Get your Woodside Play Lab app running in 10 minutes.

## Step 1: Verify Supabase Credentials (2 minutes)

1. Open your Supabase Dashboard
2. Go to **Settings** → **API**
3. Copy these values:
   - **Project URL**: `https://ebzfutiidqbndidlsqfn.supabase.co`
   - **Anon public key**: Should be a long string starting with `eyJ...`

4. Open `supabase-client.js` in this folder
5. Update lines 4-5 with your actual credentials:

```javascript
const SUPABASE_URL = 'https://ebzfutiidqbndidlsqfn.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ACTUAL_ANON_KEY_HERE'; // Get from Supabase Dashboard
```

**⚠️ IMPORTANT**: The key you provided (`sb_publishable_...`) doesn't look like a standard Supabase anon key. Please verify this in your Supabase Dashboard under Settings → API. The anon key should be a JWT token starting with `eyJ`.

## Step 2: Set Up Database (3 minutes)

1. Open Supabase Dashboard
2. Go to **SQL Editor**
3. Click **New Query**
4. Open the `SUPABASE_SQL.sql` file in this folder
5. Copy **Sections 1, 2, and 3** (table creation + RLS policies)
6. Paste into SQL Editor
7. Click **Run**

You should see: `Success. No rows returned`

## Step 3: Create Storage Bucket (2 minutes)

1. In Supabase Dashboard, go to **Storage**
2. Click **Create new bucket**
3. Name it: `photos` (exactly this name)
4. Set as **Private** (not public)
5. Click **Create bucket**
6. The bucket should appear in the list

## Step 4: Test Locally (3 minutes)

### Option A: Simple (just open the file)
1. Double-click `index.html`
2. It should open in your browser

### Option B: Using Python
```bash
python -m http.server 8000
```
Then open: http://localhost:8000

### Option C: Using Node.js
```bash
npx serve
```
Then open the URL shown (usually http://localhost:3000)

## Step 5: Test the App (5 minutes)

### Test Share Flow:
1. Click **"Share"** button
2. Click **"TAKE OR UPLOAD PHOTO"**
3. Select a large image (>1MB)
4. Wait for compression and upload (loading spinner)
5. Add a caption (optional)
6. Select time of day
7. Click **"FINISH"**
8. Should see "THANK YOU" page

### Test Vote Flow:
1. Go back to homepage
2. Click **"Vote"** button
3. Select 2 or more options
4. Click **"SUBMIT"**
5. Should see "YOUR INPUT HAS BEEN COUNTED"

## Step 6: Verify Data in Supabase (2 minutes)

1. Go to Supabase Dashboard
2. Click **Table Editor** → `submissions`
3. You should see your test submissions

4. Click **Storage** → `photos`
5. You should see your uploaded image (if you uploaded one)

## ✅ Success!

If you see data in Supabase, everything is working!

---

## Troubleshooting

### "Failed to upload photo"
- Check storage bucket is named exactly `photos`
- Check RLS policies on storage (Section 3 of SQL file)
- Check browser console for detailed error

### "Failed to save your input"
- Check RLS policies on submissions table (Section 2 of SQL file)
- Verify anon key is correct in `supabase-client.js`
- Check browser console for detailed error

### "Supabase is not defined"
- Make sure Supabase CDN script is loaded in HTML files
- Check browser console for network errors
- Clear browser cache and reload

### Photo won't upload / takes forever
- Check your internet connection
- Try with a smaller image first
- Check Supabase storage quota (Settings → Usage)

---

## Next Steps

### Deploy to Vercel

1. Create a GitHub account (if you don't have one)
2. Create a new repository
3. Push your code:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```
4. Go to [vercel.com](https://vercel.com)
5. Click **"Import Project"**
6. Connect to GitHub
7. Select your repository
8. Click **"Deploy"**
9. Your app will be live in ~30 seconds!

### Monitor Submissions

Check your Supabase Dashboard regularly:
- **Table Editor**: See all submissions
- **Storage**: See uploaded photos
- Use queries from `SUPABASE_SQL.sql` Section 5

---

## Resources

- **Full Setup Guide**: See `SUPABASE_SETUP.md`
- **Testing Checklist**: See `TESTING_CHECKLIST.md`
- **SQL Commands**: See `SUPABASE_SQL.sql`
- **Project Info**: See `README.md`

---

## Need Help?

1. Check browser console (F12) for errors
2. Check Supabase logs in Dashboard
3. Review `SUPABASE_SETUP.md` for detailed troubleshooting
4. Open an issue in the project repository

Good luck! 🚀
