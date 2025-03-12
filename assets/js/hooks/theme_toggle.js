/**
 * Theme Toggle Hook
 * ----------------
 * Handles switching between themes in integration with Phoenix LiveView.
 * 
 * This hook provides bidirectional communication:
 * 1. It listens for "change_theme" events from LiveView to update the theme
 * 2. It handles clicking on the theme buttons to change theme
 * 
 * The hook manages theme persistence in localStorage and applies theme changes
 * to both the documentElement and body elements.
 */

const ThemeToggle = {
  /**
   * Initialization function called when LiveView attaches the hook to the DOM.
   */
  mounted() {
    // Cache DOM elements for performance
    this.themeButtons = Array.from(this.el.querySelectorAll('.theme-button'));
    
    // Get available themes from the buttons
    this.availableThemes = this.themeButtons.map(button => {
      const theme = button.getAttribute('data-theme');
      return `${theme}-theme`;
    });
    
    // Get current theme from localStorage or set default based on system preference
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const defaultTheme = this.findDefaultTheme() || (prefersDark ? 'dark-theme' : 'light-theme');
    this.currentTheme = localStorage.getItem('theme') || defaultTheme;
    
    // Apply the current theme
    this.applyTheme(this.currentTheme);
    
    // Add event listeners to the theme buttons
    this.themeButtons.forEach(button => {
      button.addEventListener('click', () => {
        const theme = button.getAttribute('data-theme');
        const themeWithSuffix = theme.endsWith('-theme') ? theme : `${theme}-theme`;
        this.setTheme(themeWithSuffix);
      });
    });
    
    // Set up system preference listener
    this.setupSystemPreferenceListener();
    
    // Setup keyboard shortcuts
    this.setupKeyboardShortcuts();
    
    // Listen for theme change events from LiveView
    this.handleEvent('change_theme', ({ theme }) => {
      // Always ensure theme has the -theme suffix
      const themeWithSuffix = theme.endsWith('-theme') ? theme : `${theme}-theme`;
      this.setTheme(themeWithSuffix);
    });

    // Listen for theme-set events from button clicks
    window.addEventListener('theme-set', (e) => {
      if (e.detail && e.detail.theme) {
        this.setTheme(e.detail.theme);
      }
    });

    // Add ARIA announcements for screen readers
    this.setupAriaAnnouncements();
  },
  
  /**
   * Find the default theme from the buttons
   */
  findDefaultTheme() {
    const defaultButton = this.themeButtons.find(button => 
      button.getAttribute('aria-pressed') === 'true'
    );
    
    if (defaultButton) {
      const theme = defaultButton.getAttribute('data-theme');
      return `${theme}-theme`;
    }
    
    return null;
  },
  
  /**
   * Sets up a listener for system theme preference changes
   */
  setupSystemPreferenceListener() {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    // Modern browsers
    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener('change', (e) => {
        // Check if we have a system theme option
        const hasSystemTheme = this.availableThemes.includes('system-theme');
        
        if (!localStorage.getItem('theme') || 
            (hasSystemTheme && this.currentTheme === 'system-theme')) {
          // Only set theme based on system if user hasn't set a preference
          // or if they've explicitly chosen to follow system
          this.setTheme(e.matches ? 'dark-theme' : 'light-theme', false);
        }
      });
    }
  },
  
  /**
   * Sets the theme and saves it to localStorage
   * @param {string} theme - The theme to apply (should end with -theme)
   * @param {boolean} saveToStorage - Whether to save to localStorage (default: true)
   */
  setTheme(theme, saveToStorage = true) {
    // Validate theme against available themes
    const themeToApply = this.availableThemes.includes(theme) ? 
      theme : (this.availableThemes[0] || 'light-theme');
    
    // Update current theme
    this.currentTheme = themeToApply;
    
    // Save to localStorage if requested
    if (saveToStorage) {
      localStorage.setItem('theme', themeToApply);
    }
    
    // Apply the theme to the DOM
    this.applyTheme(themeToApply);
    
    // Dispatch an event so other components can react
    window.dispatchEvent(new CustomEvent('theme-changed', { 
      detail: { theme: themeToApply } 
    }));

    // Announce theme change to screen readers
    this.announceThemeChange(themeToApply);
  },
  
  /**
   * Applies the theme to the document
   * @param {string} theme - The theme to apply
   */
  applyTheme(theme) {
    // Special handling for system theme
    if (theme === 'system-theme') {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      const systemTheme = prefersDark ? 'dark-theme' : 'light-theme';
      
      // Remove all theme classes
      this.removeAllThemeClasses();
      
      // Add the system-determined theme class
      document.documentElement.classList.add(systemTheme);
      document.body.classList.add(systemTheme);
      
      // Also add the system-theme class to indicate system preference is active
      document.documentElement.classList.add('system-theme');
      document.body.classList.add('system-theme');
      
      // Set data-theme attribute for CSS variables
      document.documentElement.setAttribute('data-theme', systemTheme);
      document.documentElement.setAttribute('data-theme-source', 'system');
    } else {
      // Remove all theme classes
      this.removeAllThemeClasses();
      
      // Add the new theme class
      document.documentElement.classList.add(theme);
      document.body.classList.add(theme);
      
      // Set data-theme attribute for CSS variables
      document.documentElement.setAttribute('data-theme', theme);
      document.documentElement.setAttribute('data-theme-source', 'user');
    }
    
    // Update aria-pressed on buttons
    this.updateActiveButton(theme);
  },
  
  /**
   * Removes all theme classes from document
   */
  removeAllThemeClasses() {
    // Remove all available themes
    this.availableThemes.forEach(theme => {
      document.documentElement.classList.remove(theme);
      document.body.classList.remove(theme);
    });
    
    // Also remove base theme names without -theme suffix
    this.availableThemes.forEach(theme => {
      const baseTheme = theme.replace('-theme', '');
      document.documentElement.classList.remove(baseTheme);
      document.body.classList.remove(baseTheme);
    });
  },
  
  /**
   * Updates the active state of theme buttons
   * @param {string} theme - The active theme
   */
  updateActiveButton(theme) {
    const themeBase = theme.replace('-theme', '');
    
    this.themeButtons.forEach(button => {
      const buttonTheme = button.getAttribute('data-theme');
      const isActive = buttonTheme === themeBase;
      
      // Update aria-pressed and active class
      button.setAttribute('aria-pressed', isActive ? 'true' : 'false');
      
      if (isActive) {
        button.classList.add('active');
      } else {
        button.classList.remove('active');
      }
    });
  },
  
  /**
   * Sets up keyboard shortcuts for theme toggling
   */
  setupKeyboardShortcuts() {
    document.addEventListener('keydown', (event) => {
      // Support for arrow key navigation (easier for screen readers)
      if (event.shiftKey && (event.key === 'ArrowRight' || event.key === 'ArrowUp')) {
        event.preventDefault();
        this.cycleTheme('next');
      }
      
      if (event.shiftKey && (event.key === 'ArrowLeft' || event.key === 'ArrowDown')) {
        event.preventDefault();
        this.cycleTheme('prev');
      }
      
      // Add shortcuts for each theme
      this.themeButtons.forEach(button => {
        const theme = button.getAttribute('data-theme');
        const firstLetter = theme.charAt(0).toLowerCase();
        
        if (event.key === firstLetter && event.shiftKey) {
          event.preventDefault();
          this.setTheme(`${theme}-theme`);
        }
      });
    });
  },
  
  /**
   * Cycles through themes in sequence
   * @param {string} direction - 'next' or 'prev'
   */
  cycleTheme(direction) {
    const currentIndex = this.availableThemes.indexOf(this.currentTheme);
    
    let newIndex;
    if (direction === 'next') {
      newIndex = (currentIndex + 1) % this.availableThemes.length;
    } else {
      newIndex = (currentIndex - 1 + this.availableThemes.length) % this.availableThemes.length;
    }
    
    this.setTheme(this.availableThemes[newIndex]);
  },

  /**
   * Sets up ARIA announcements for theme changes
   */
  setupAriaAnnouncements() {
    // Create an invisible live region for screen reader announcements
    this.ariaLiveRegion = document.createElement('div');
    this.ariaLiveRegion.setAttribute('aria-live', 'polite');
    this.ariaLiveRegion.setAttribute('class', 'sr-only');
    document.body.appendChild(this.ariaLiveRegion);
  },

  /**
   * Announces theme changes to screen readers
   * @param {string} theme - The new theme
   */
  announceThemeChange(theme) {
    const themeName = theme.replace('-theme', '');
    const message = `Theme changed to ${themeName}`;
    
    if (this.ariaLiveRegion) {
      this.ariaLiveRegion.textContent = message;
    }
  }
};

export default ThemeToggle; 