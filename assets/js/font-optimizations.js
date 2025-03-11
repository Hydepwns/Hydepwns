/**
 * Font Loading Optimizations
 * 
 * This module implements optimized font loading strategies to improve performance
 * and reduce layout shifts caused by font loading.
 */

// Font loading configuration
const FONT_CONFIG = {
  monaspace: {
    family: 'Monaspace Argon',
    variants: [
      { weight: 400, style: 'normal' },
      { weight: 700, style: 'normal' },
      { weight: 800, style: 'normal' },
      { weight: 400, style: 'italic' },
      { weight: 700, style: 'italic' },
      { weight: 800, style: 'italic' }
    ],
    timeout: 3000, // Timeout in ms
    fallback: 'JetBrains Mono, monospace'
  },
  jetbrains: {
    family: 'JetBrains Mono',
    variants: [
      { weight: 400, style: 'normal' },
      { weight: 700, style: 'normal' }
    ],
    timeout: 2000,
    fallback: 'monospace'
  }
};

/**
 * Initialize font loading optimizations
 */
export function initFontOptimizations() {
  // Add font-display swap to all @font-face rules
  addFontDisplaySwap();
  
  // Implement native font loading API if available
  if ('fonts' in document) {
    // Add session storage for font caching
    implementSessionFontCaching();
    
    // Use Font Loading API to preload fonts
    preloadCriticalFonts();
  } else {
    // Fallback for browsers without Font Loading API
    implementFallbackFontLoading();
  }
  
  // Add font-related CSS custom properties for easier debugging
  addFontStatusProperties();
}

/**
 * Add font-display: swap to all @font-face rules dynamically
 */
function addFontDisplaySwap() {
  // Get all stylesheets
  Array.from(document.styleSheets).forEach(stylesheet => {
    try {
      // Access CSS rules
      const rules = stylesheet.cssRules || stylesheet.rules;
      
      if (rules) {
        for (let i = 0; i < rules.length; i++) {
          const rule = rules[i];
          
          // Check if it's a @font-face rule
          if (rule.type === CSSRule.FONT_FACE_RULE) {
            // Check if font-display is already set
            if (!rule.style.getPropertyValue('font-display')) {
              rule.style.setProperty('font-display', 'swap');
            }
          }
        }
      }
    } catch (e) {
      // Skip cross-origin stylesheets
      console.log('Could not access stylesheet:', e);
    }
  });
}

/**
 * Implement session-based font caching
 */
function implementSessionFontCaching() {
  // Use sessionStorage to store font loading status
  const FONTS_LOADED_KEY = 'hydepwns_fonts_loaded';
  
  if (sessionStorage.getItem(FONTS_LOADED_KEY) === 'true') {
    // If fonts were previously loaded in this session, add a class
    document.documentElement.classList.add('fonts-cached');
  } else {
    // Add a load event listener to detect when fonts are loaded
    document.fonts.ready.then(() => {
      // Mark fonts as loaded for this session
      sessionStorage.setItem(FONTS_LOADED_KEY, 'true');
      document.documentElement.classList.add('fonts-loaded');
    });
  }
}

/**
 * Preload critical fonts using the Font Loading API
 */
function preloadCriticalFonts() {
  // Start with loading the primary font for body text
  const primaryFont = FONT_CONFIG.monaspace.variants.map(variant => {
    return new FontFace(
      FONT_CONFIG.monaspace.family,
      `url('/assets/fonts/MonaspaceArgon-${getVariantFilename(variant)}.woff2') format('woff2')`,
      {
        weight: variant.weight.toString(),
        style: variant.style,
        display: 'swap'
      }
    );
  });
  
  // Load fallback font as well
  const fallbackFont = FONT_CONFIG.jetbrains.variants.map(variant => {
    return new FontFace(
      FONT_CONFIG.jetbrains.family,
      `url('https://fonts.cdnfonts.com/s/41339/JetBrainsMono-${getVariantFilename(variant)}.woff2') format('woff2')`,
      {
        weight: variant.weight.toString(),
        style: variant.style,
        display: 'swap'
      }
    );
  });
  
  // Combine all font promises
  const allFonts = [...primaryFont, ...fallbackFont];
  
  // Load all fonts in parallel with timeout to prevent blocking
  Promise.all(
    allFonts.map(font => {
      return Promise.race([
        font.load().then(loadedFont => {
          // Add each loaded font to the document
          document.fonts.add(loadedFont);
          return loadedFont;
        }),
        // Add timeout to prevent infinite waiting
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Font loading timed out')), 
          FONT_CONFIG.monaspace.timeout)
        )
      ]).catch(err => {
        console.warn(`Failed to load font: ${err.message}`);
        return null;
      });
    })
  ).then(loadedFonts => {
    // Filter out any nulls from failed loads
    const successfullyLoaded = loadedFonts.filter(Boolean);
    
    if (successfullyLoaded.length > 0) {
      // Add a class to indicate fonts are loaded
      document.documentElement.classList.add('fonts-loaded');
      
      // Trigger a reflow to apply fonts immediately
      document.body.style.visibility = 'hidden';
      setTimeout(() => {
        document.body.style.visibility = '';
      }, 0);
    }
  });
}

/**
 * Fallback font loading for browsers without Font Loading API
 */
function implementFallbackFontLoading() {
  // Add a class to indicate we're using the fallback loading method
  document.documentElement.classList.add('fonts-fallback-loading');
  
  // Use a timeout to simulate font loading completion
  setTimeout(() => {
    document.documentElement.classList.add('fonts-loaded');
  }, 2000); // Conservative estimate for font loading
}

/**
 * Helper to get the variant filename from weight and style
 */
function getVariantFilename(variant) {
  if (variant.style === 'italic') {
    if (variant.weight === 700) return 'BoldItalic';
    if (variant.weight === 800) return 'ExtraBoldItalic';
    return 'Italic';
  } else {
    if (variant.weight === 700) return 'Bold';
    if (variant.weight === 800) return 'ExtraBold';
    return 'Regular';
  }
}

/**
 * Add CSS custom properties for font status monitoring
 */
function addFontStatusProperties() {
  document.documentElement.style.setProperty('--fonts-loaded', 'false');
  
  document.fonts.ready.then(() => {
    document.documentElement.style.setProperty('--fonts-loaded', 'true');
  });
}

export default {
  initFontOptimizations
}; 