# Woodside Play Lab - Community Engagement App

A multilingual civic engagement platform for gathering community input on the redesign of General Hart Playground in Woodside, Queens.

## Features

- 🌍 **7 Languages**: English, Spanish, Tagalog, Bengali, Nepali, Chinese, Sanskrit
- 📸 **Photo Sharing**: Community members can share photos of how they use the playground
- 🗳️ **Priority Voting**: Vote on design priorities that matter most
- 📱 **Mobile-Optimized**: Works on slow connections (3G/4G)
- 🔒 **Privacy-First**: No authentication required, photos in private storage
- ⚡ **Real-time**: Powered by Supabase backend

## Project Structure

```
woodside-play-lab/
├── index.html           # Landing page with language selector
├── share.html           # Photo sharing flow (3 steps)
├── vote.html            # Priority voting flow (2 steps)
├── style.css            # All styles (includes loading/error states)
├── languages.js         # Translation strings for 7 languages
├── language-toggle.js   # Language switching logic
├── supabase-client.js   # Supabase integration & helpers
├── SUPABASE_SETUP.md    # Complete backend setup guide
└── README.md            # This file
```

## Quick Start

### 1. Set up Supabase Backend

Follow the complete guide in `SUPABASE_SETUP.md` to:
- Configure database table and RLS policies
- Set up storage bucket for photos
- Verify API credentials

### 2. Update Supabase Credentials

In `supabase-client.js`, verify your credentials:

```javascript
const SUPABASE_URL = 'https://YOUR_PROJECT.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';
```

Get these from: Supabase Dashboard → Settings → API

### 3. Test Locally

Open `index.html` in a browser or use a local server:

```bash
# Using Python
python -m http.server 8000

# Using Node.js
npx serve

# Or just open index.html in your browser
```

### 4. Deploy to Vercel

```bash
# Initialize git
git init
git add .
git commit -m "Initial commit"

# Push to GitHub
git remote add origin <your-repo-url>
git push -u origin main

# Deploy on Vercel
# Go to vercel.com and import your GitHub repo
```

## User Flows

### Share Flow (3 Steps)

1. **Upload Photo** (optional)
   - Take or upload photo
   - Automatic compression to 200KB
   - Stored in private Supabase bucket

2. **Add Context** (optional)
   - Write caption in any language
   - Describe what's happening in the photo

3. **Select Time of Day**
   - Morning, Afternoon, or Evening
   - Helps understand usage patterns

### Vote Flow (2 Steps)

1. **Select Priorities** (minimum 2)
   - More shade for hot days
   - Seating for grandparents and caregivers
   - Play for different ages together
   - Cultural connection
   - Creative movement
   - Gathering spaces
   - Other (with custom text)

2. **Thank You**
   - Confirmation message
   - Option to share a photo
   - Email signup for updates

## Technology Stack

- **Frontend**: Vanilla HTML/CSS/JavaScript (no build step)
- **Backend**: Supabase (PostgreSQL + Storage)
- **Hosting**: Vercel (static site)
- **Image Processing**: Canvas API (client-side compression)

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile Safari (iOS 13+)
- Chrome Mobile (Android 8+)

## Performance

- ✅ Works on slow 3G connections
- ✅ Images compressed to max 200KB
- ✅ 30-45 second timeouts for uploads
- ✅ Offline detection
- ✅ Loading states and error messages

## Data Schema

### `submissions` table

```sql
- id: UUID (primary key)
- flow_type: "share" | "vote"
- language: language code (e.g., "en", "es", "tl")
- caption: text (nullable)
- vote_choices: JSONB array (nullable)
- photo_url: text (signed URL, nullable)
- time_of_day: "morning" | "afternoon" | "evening" (nullable)
- created_at: timestamp
```

### `photos` storage bucket

- Private bucket with signed URLs (1 year validity)
- Compressed JPEG images (<200KB)
- Unique filename: `{timestamp}_{random}.jpg`

## Customization

### Adding a New Language

1. Add translation object to `languages.js`:
   ```javascript
   fr: {
     kicker: "Woodside Play Lab",
     headline: "COMMENT UTILISEZ-VOUS CETTE AIRE DE JEUX?",
     // ... etc
   }
   ```

2. Add language button to HTML files:
   ```html
   <button data-lang="fr" onclick="setLanguage('fr')">Français</button>
   ```

### Changing Colors

Colors are defined in `style.css` using CSS custom properties:

```css
body.page-index {
  --background: #e0ddd5;
  --primary: #e63946;
  --secondary: #d4a359;
  --accent: #c77dff;
}
```

## Analytics & Monitoring

Track submissions in Supabase Dashboard:

```sql
-- Count submissions by type
SELECT flow_type, COUNT(*) 
FROM submissions 
GROUP BY flow_type;

-- Count by language
SELECT language, COUNT(*) 
FROM submissions 
GROUP BY language;

-- Popular vote choices
SELECT jsonb_array_elements(vote_choices)->>'choice' as choice, COUNT(*) 
FROM submissions 
WHERE flow_type = 'vote' 
GROUP BY choice 
ORDER BY COUNT(*) DESC;
```

## Security

- ✅ Row Level Security (RLS) enabled
- ✅ Anonymous insert allowed (public forms)
- ✅ Private photo storage
- ✅ No personal data collected
- ✅ GDPR-friendly (no cookies, no tracking)

## Troubleshooting

### Common Issues

**Photo upload fails**
- Check Supabase storage bucket exists and is named "photos"
- Verify storage RLS policies are set correctly
- Try with a smaller image

**Form submission fails**
- Check RLS policies on submissions table
- Verify anon key is correct
- Check browser console for errors

**Language not switching**
- Clear browser cache
- Check console for JavaScript errors
- Verify translation key exists in languages.js

See `SUPABASE_SETUP.md` for detailed troubleshooting steps.

## Contributing

This is a community project for Woodside, Queens. Suggestions welcome!

## License

Created by Alex Tudela for STREETOYSTER QUEENS
2026 David Prize applicant

---

## Contact

Follow the project: [@streetoyster.nyc](https://instagram.com/streetoyster.nyc)

In conversation with NYC Parks & Community Board 2
