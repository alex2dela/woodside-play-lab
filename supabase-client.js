// Supabase Configuration
// IMPORTANT: Verify your anon key in Supabase Dashboard -> Settings -> API
// The key should be the "anon" public key (usually starts with "eyJ")
var SUPABASE_URL = 'https://ebzfutiidqbndidlsqfn.supabase.co';
var SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImViemZ1dGlpZHFibmRpZGxzcWZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAxMzg2MDEsImV4cCI6MjA4NTcxNDYwMX0.UV7GqN8zewT_YYZi6Oc3dy4mqOLsVxVtdlgJFQMRIMg';

// Initialize Supabase client
var supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Image compression function (max 200KB)
async function compressImage(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    
    reader.onload = (event) => {
      const img = new Image();
      img.src = event.target.result;
      
      img.onload = () => {
        const canvas = document.createElement('canvas');
        let width = img.width;
        let height = img.height;
        
        // Start with original size
        canvas.width = width;
        canvas.height = height;
        
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0, width, height);
        
        // Compress iteratively until under 200KB
        let quality = 0.9;
        let blob;
        
        function tryCompress() {
          canvas.toBlob((result) => {
            blob = result;
            
            if (blob.size > 200000 && quality > 0.1) {
              // Too large, reduce quality
              quality -= 0.1;
              tryCompress();
            } else if (blob.size > 200000) {
              // Still too large, reduce dimensions
              width *= 0.9;
              height *= 0.9;
              canvas.width = width;
              canvas.height = height;
              ctx.drawImage(img, 0, 0, width, height);
              quality = 0.9;
              tryCompress();
            } else {
              // Success!
              resolve(blob);
            }
          }, 'image/jpeg', quality);
        }
        
        tryCompress();
      };
      
      img.onerror = reject;
    };
    
    reader.onerror = reject;
  });
}

// Upload photo to Supabase storage
async function uploadPhoto(file) {
  try {
    // Compress first
    const compressedBlob = await compressImage(file);
    
    // Generate unique filename
    const timestamp = Date.now();
    const randomStr = Math.random().toString(36).substring(7);
    const fileName = `${timestamp}_${randomStr}.jpg`;
    
    // Upload to Supabase storage
    const { data, error } = await supabase.storage
      .from('photos')
      .upload(fileName, compressedBlob, {
        contentType: 'image/jpeg',
        cacheControl: '3600'
      });
    
    if (error) throw error;
    
    // Get signed URL (valid for 1 year)
    const { data: urlData, error: urlError } = await supabase.storage
      .from('photos')
      .createSignedUrl(fileName, 31536000); // 1 year in seconds
    
    if (urlError) throw urlError;
    
    return urlData.signedUrl;
  } catch (error) {
    console.error('Upload error:', error);
    throw error;
  }
}

// Submit to database
async function submitToDatabase(data) {
  try {
    const { data: result, error } = await supabase
      .from('submissions')
      .insert([{
        flow_type: data.flow_type,
        language: currentLanguage || 'en', // Uses global from language-toggle.js
        caption: data.caption || null,
        vote_choices: data.vote_choices || null,
        photo_url: data.photo_url || null,
        time_of_day: data.time_of_day || null
      }])
      .select();
    
    if (error) throw error;
    
    return result;
  } catch (error) {
    console.error('Database error:', error);
    throw error;
  }
}

// Show loading spinner
function showLoading(message = 'Loading...') {
  let loader = document.querySelector('.loading-overlay');
  if (!loader) {
    loader = document.createElement('div');
    loader.className = 'loading-overlay';
    loader.innerHTML = `
      <div class="loading-content">
        <div class="spinner"></div>
        <p class="loading-message">${message}</p>
      </div>
    `;
    document.body.appendChild(loader);
  } else {
    loader.querySelector('.loading-message').textContent = message;
  }
  loader.style.display = 'flex';
  return loader;
}

function hideLoading() {
  const loader = document.querySelector('.loading-overlay');
  if (loader) loader.style.display = 'none';
}

// Show error message
function showError(message) {
  const errorDiv = document.createElement('div');
  errorDiv.className = 'error-toast';
  errorDiv.textContent = message;
  document.body.appendChild(errorDiv);
  
  setTimeout(() => {
    errorDiv.classList.add('show');
  }, 100);
  
  setTimeout(() => {
    errorDiv.classList.remove('show');
    setTimeout(() => errorDiv.remove(), 300);
  }, 4000);
}

// Timeout wrapper for slow connections
function withTimeout(promise, ms = 30000) {
  return Promise.race([
    promise,
    new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Request timed out. Please check your connection and try again.')), ms)
    )
  ]);
}

// Offline detection
window.addEventListener('offline', () => {
  showError('No internet connection. Please try again when online.');
});
