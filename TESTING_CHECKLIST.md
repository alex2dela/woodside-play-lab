# Testing Checklist

Use this checklist to verify your Supabase integration is working correctly.

## Before Testing

- [ ] Supabase project URL is correct in `supabase-client.js`
- [ ] Supabase anon key is correct in `supabase-client.js`
- [ ] Database table `submissions` exists
- [ ] Storage bucket `photos` exists
- [ ] RLS policies enabled on `submissions` table
- [ ] RLS policies enabled on storage bucket

---

## 1. Landing Page (`index.html`)

### Language Switching
- [ ] Click English - page updates to English
- [ ] Click Español - page updates to Spanish
- [ ] Click Tagalog - page updates to Tagalog
- [ ] Click বাংলা - page updates to Bengali
- [ ] Click नेपाली - page updates to Nepali
- [ ] Click 中文 - page updates to Chinese
- [ ] Click संस्कृत - page updates to Sanskrit
- [ ] Refresh page - language preference persists

### Navigation
- [ ] Click "Share" button - navigates to `share.html`
- [ ] Click "Vote" button - navigates to `vote.html`

---

## 2. Share Flow (`share.html`)

### Step 1: Photo Upload

**Test Photo Upload:**
- [ ] Click "TAKE OR UPLOAD PHOTO" button
- [ ] File picker opens
- [ ] Select a large image (>1MB)
- [ ] Loading spinner appears with message "Compressing and uploading photo..."
- [ ] Loading spinner disappears after upload
- [ ] Automatically moves to Step 2

**Test Photo Skip:**
- [ ] Refresh page
- [ ] Click "SKIP THIS STEP"
- [ ] Moves to Step 2 without uploading

**Test Error Handling:**
- [ ] Turn off WiFi/internet
- [ ] Try to upload a photo
- [ ] Red error toast appears: "Failed to upload photo..."
- [ ] Turn WiFi back on

### Step 2: Add Context

**Test Caption Entry:**
- [ ] Type a caption in English
- [ ] Click "CONTINUE"
- [ ] Moves to Step 3

**Test Empty Caption:**
- [ ] Leave caption empty
- [ ] Click "CONTINUE"
- [ ] Still moves to Step 3 (caption is optional)

**Test Unicode Characters:**
- [ ] Type a caption in Spanish: "¡Hola! ¿Cómo estás?"
- [ ] Type a caption in Bengali: "আমার বাচ্চারা এখানে খেলে"
- [ ] Click "CONTINUE"
- [ ] Moves to Step 3

### Step 3: Time of Day

**Test Time Selection:**
- [ ] Select "Morning"
- [ ] Option highlights in lime green
- [ ] Click "FINISH"
- [ ] Loading spinner appears: "Saving your input..."
- [ ] Loading spinner disappears
- [ ] Moves to Step 4 (Thank You)

**Test Without Selection:**
- [ ] Refresh page
- [ ] Go through Steps 1-2
- [ ] Don't select any time
- [ ] Click "FINISH"
- [ ] Still submits (time is optional)

### Step 4: Thank You

**Visual Check:**
- [ ] "THANK YOU" heading displays
- [ ] Timeline section displays
- [ ] Email signup field displays
- [ ] "DONE" button displays
- [ ] Click "DONE" - returns to `index.html`

### Database Verification

After completing the Share flow, check Supabase:
- [ ] Open Supabase Dashboard → Table Editor → `submissions`
- [ ] New row exists with:
  - `flow_type` = "share"
  - `language` = selected language (e.g., "en")
  - `caption` = your caption text (if provided)
  - `photo_url` = signed URL (if photo uploaded)
  - `time_of_day` = selected time (if provided)
  - `created_at` = current timestamp

### Storage Verification

If photo was uploaded:
- [ ] Open Supabase Dashboard → Storage → `photos`
- [ ] New file exists (format: `{timestamp}_{random}.jpg`)
- [ ] File size < 200KB
- [ ] Click file to preview - image displays correctly

---

## 3. Vote Flow (`vote.html`)

### Step 1: Vote Selection

**Test Minimum Selection:**
- [ ] Click only 1 checkbox
- [ ] Click "SUBMIT"
- [ ] Alert appears: "Please select at least two options."
- [ ] Click OK
- [ ] Select 1 more checkbox (total 2)
- [ ] Click "SUBMIT"
- [ ] Moves to Step 2

**Test Multiple Selection:**
- [ ] Refresh page
- [ ] Select "More shade for hot days"
- [ ] Select "Seating for grandparents and caregivers"
- [ ] Select "Creative movement (not just standard equipment)"
- [ ] All 3 checkboxes show selected state (green background)

**Test "Other" Option:**
- [ ] Select "Other" checkbox
- [ ] Text input becomes enabled
- [ ] Try to submit without entering text
- [ ] Alert appears: "Please describe what 'Other' means to you."
- [ ] Enter text in "Other" field: "More water fountains"
- [ ] Click "SUBMIT"
- [ ] Loading spinner appears: "Submitting your votes..."
- [ ] Moves to Step 2

**Test Network Error:**
- [ ] Turn off WiFi/internet
- [ ] Select 2+ options
- [ ] Click "SUBMIT"
- [ ] Error toast appears: "Failed to submit your votes..."
- [ ] Turn WiFi back on

### Step 2: Thank You

**Visual Check:**
- [ ] "YOUR INPUT HAS BEEN COUNTED" heading displays
- [ ] "SEE DESIGN REFERENCES →" link displays
- [ ] Timeline section displays
- [ ] "SHARE A PHOTO" button displays in yellow section
- [ ] Email signup field displays
- [ ] "DONE" button displays

**Navigation Check:**
- [ ] Click "SHARE A PHOTO" - navigates to `share.html`
- [ ] Go back
- [ ] Click "DONE" - navigates to `index.html`

### Database Verification

After completing the Vote flow, check Supabase:
- [ ] Open Supabase Dashboard → Table Editor → `submissions`
- [ ] New row exists with:
  - `flow_type` = "vote"
  - `language` = selected language
  - `vote_choices` = JSONB array like:
    ```json
    [
      {"choice": "shade"},
      {"choice": "seating"},
      {"choice": "other", "text": "More water fountains"}
    ]
    ```
  - `created_at` = current timestamp

---

## 4. Mobile Testing

### Chrome DevTools Network Throttling

**Test on Fast 3G:**
- [ ] Open DevTools (F12)
- [ ] Network tab → Throttling → "Fast 3G"
- [ ] Complete Share flow with photo upload
- [ ] Takes longer but completes successfully

**Test on Slow 3G:**
- [ ] Network tab → Throttling → "Slow 3G"
- [ ] Complete Vote flow
- [ ] Takes longer but completes successfully
- [ ] Loading spinner shows appropriate messages

### Mobile Device Testing

Test on actual mobile devices:
- [ ] iPhone - Safari
- [ ] Android - Chrome
- [ ] Language selector works
- [ ] Photo camera picker works
- [ ] Form inputs work
- [ ] Loading states display correctly
- [ ] Error toasts are readable

---

## 5. Multi-Language Testing

Test each language to ensure translations work:

- [ ] **English**: All text displays correctly
- [ ] **Spanish**: All text displays correctly
- [ ] **Tagalog**: All text displays correctly
- [ ] **Bengali**: All text displays correctly (RTL if needed)
- [ ] **Nepali**: All text displays correctly
- [ ] **Chinese**: All text displays correctly
- [ ] **Sanskrit**: All text displays correctly

### Test Form Submissions in Different Languages

- [ ] Switch to Spanish
- [ ] Complete Share flow with Spanish caption
- [ ] Check database: `language` = "es"
- [ ] Switch to Tagalog
- [ ] Complete Vote flow
- [ ] Check database: `language` = "tl"

---

## 6. Edge Cases

### Empty Submissions
- [ ] Share flow: Skip photo, skip caption, skip time → Still submits
- [ ] Vote flow: Select exactly 2 options → Submits successfully

### Large Images
- [ ] Upload 5MB image → Compresses to <200KB
- [ ] Upload 10MB image → Compresses to <200KB
- [ ] Check Supabase storage: File size < 200KB

### Special Characters
- [ ] Enter caption with emojis: "🎈🎨🎭"
- [ ] Enter "Other" text with special chars: "¡¿Más espacios!"
- [ ] Check database: Special chars stored correctly

### Timeout Handling
- [ ] Throttle to "Offline" in DevTools
- [ ] Try to submit form
- [ ] Error appears immediately

### Rapid Submissions
- [ ] Complete Share flow
- [ ] Immediately go to Vote flow
- [ ] Submit vote
- [ ] Check database: Both submissions recorded

---

## 7. Browser Compatibility

Test in different browsers:

- [ ] **Chrome** (latest): All features work
- [ ] **Firefox** (latest): All features work
- [ ] **Safari** (latest): All features work
- [ ] **Edge** (latest): All features work
- [ ] **Mobile Safari** (iOS): All features work
- [ ] **Chrome Mobile** (Android): All features work

---

## 8. Performance

### Loading Times
- [ ] Index page loads in < 2 seconds
- [ ] Share page loads in < 2 seconds
- [ ] Vote page loads in < 2 seconds
- [ ] Language switching is instant

### Upload Times (Fast 3G)
- [ ] Photo compression: < 5 seconds
- [ ] Photo upload: < 10 seconds
- [ ] Form submission: < 3 seconds

---

## 9. Accessibility

### Keyboard Navigation
- [ ] Tab through form elements
- [ ] Enter key submits forms
- [ ] Space bar toggles checkboxes

### Screen Readers (Optional)
- [ ] Form labels read correctly
- [ ] Button purposes clear
- [ ] Error messages announced

---

## 10. Production Readiness

### Deployment
- [ ] Deploy to Vercel
- [ ] Live site loads correctly
- [ ] All flows work on production
- [ ] Custom domain configured (if applicable)

### Monitoring
- [ ] Submissions appearing in Supabase
- [ ] Photos uploading to storage
- [ ] No errors in Supabase logs
- [ ] Storage quota sufficient

### Documentation
- [ ] README.md complete
- [ ] SUPABASE_SETUP.md reviewed
- [ ] API credentials secured

---

## Troubleshooting

If any test fails:

1. **Check browser console** for errors
2. **Check Supabase logs** in dashboard
3. **Verify RLS policies** are set correctly
4. **Check network requests** in DevTools Network tab
5. **Refer to SUPABASE_SETUP.md** for detailed troubleshooting

---

## Sign Off

Once all checks pass:

✅ **Ready for launch!**

Date tested: _______________  
Tested by: _______________  
Browser versions: _______________  
Mobile devices: _______________
