let currentLanguage = 'en';

function setLanguage(lang) {
  currentLanguage = lang;
  
  // Update text content (convert \n to <br> for HTML rendering)
  const elements = document.querySelectorAll("[data-i18n]");
  elements.forEach(el => {
    const key = el.getAttribute("data-i18n");
    if (translations[lang] && translations[lang][key]) {
      const text = translations[lang][key];
      // Use innerHTML to support line breaks and basic formatting
      el.innerHTML = text.replace(/\n/g, '<br>');
    }
  });
  
  // Update placeholders
  const placeholderElements = document.querySelectorAll("[data-i18n-placeholder]");
  placeholderElements.forEach(el => {
    const key = el.getAttribute("data-i18n-placeholder");
    if (translations[lang] && translations[lang][key]) {
      el.placeholder = translations[lang][key];
    }
  });
  
  // Update active button state
  const languageButtons = document.querySelectorAll(".language button");
  languageButtons.forEach(btn => {
    btn.classList.remove("active");
    if (btn.getAttribute("data-lang") === lang) {
      btn.classList.add("active");
    }
  });
  
  // Save to localStorage
  localStorage.setItem("language", lang);
}

// Load saved language or default to English
document.addEventListener("DOMContentLoaded", () => {
  const savedLang = localStorage.getItem("language") || "en";
  setLanguage(savedLang);
});

// Helper function to get current language for alerts
function getTranslation(key) {
  return translations[currentLanguage] && translations[currentLanguage][key] 
    ? translations[currentLanguage][key] 
    : translations['en'][key];
}
