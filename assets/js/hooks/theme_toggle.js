/**
 * Theme Toggle Hook
 * ----------------
 * Handles switching between light, dark, dim, and high-contrast themes in integration with Phoenix LiveView.
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
    
    // Get current theme from localStorage or set default based on system preference
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    this.currentTheme = localStorage.getItem('theme') || (prefersDark ? 'dark-theme' : 'light-theme');
    
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
  },
  
  /**
   * Sets up a listener for system theme preference changes
   */
  setupSystemPreferenceListener() {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    // Modern browsers
    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener('change', (e) => {
        if (!localStorage.getItem('theme')) {
          // Only set theme based on system if user hasn't set a preference
          this.setTheme(e.matches ? 'dark-theme' : 'light-theme');
        }
      });
    }
  },
  
  /**
   * Sets the theme and saves it to localStorage
   * @param {string} theme - The theme to apply (should end with -theme)
   */
  setTheme(theme) {
    // Validate theme
    const validThemes = ['light-theme', 'dark-theme', 'dim-theme', 'high-contrast-theme'];
    const themeToApply = validThemes.includes(theme) ? theme : 'light-theme';
    
    // Update current theme
    this.currentTheme = themeToApply;
    
    // Save to localStorage
    localStorage.setItem('theme', themeToApply);
    
    // Apply the theme to the DOM
    this.applyTheme(themeToApply);
    
    // Dispatch an event so other components can react
    window.dispatchEvent(new CustomEvent('theme-changed', { 
      detail: { theme: themeToApply }
    }));
  },
  
  /**
   * Applies the theme to the document
   * @param {string} theme - The theme to apply
   */
  applyTheme(theme) {
    // Remove all theme classes
    document.documentElement.classList.remove('light-theme', 'dark-theme', 'dim-theme', 'high-contrast-theme');
    document.body.classList.remove('light-theme', 'dark-theme', 'dim-theme', 'high-contrast-theme');
    
    // Add the new theme class
    document.documentElement.classList.add(theme);
    document.body.classList.add(theme);
    
    // Set data-theme attribute for CSS variables
    document.documentElement.setAttribute('data-theme', theme);
    
    // Update aria-pressed on buttons
    this.updateActiveButton(theme);
  },
  
  /**
   * Updates the active state of theme buttons
   * @param {string} theme - The active theme
   */
  updateActiveButton(theme) {
    this.themeButtons.forEach(button => {
      const buttonTheme = button.getAttribute('data-theme') + '-theme';
      const isActive = buttonTheme === theme;
      
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
      // ⌘+L for Light theme
      if (event.key === 'l' && (event.metaKey || event.ctrlKey)) {
        event.preventDefault();
        this.setTheme('light-theme');
      }
      
      // ⌘+D for Dark theme
      if (event.key === 'd' && (event.metaKey || event.ctrlKey)) {
        event.preventDefault();
        this.setTheme('dark-theme');
      }
      
      // ⌘+M for Dim theme
      if (event.key === 'm' && (event.metaKey || event.ctrlKey)) {
        event.preventDefault();
        this.setTheme('dim-theme');
      }
      
      // ⌘+H for High contrast theme
      if (event.key === 'h' && (event.metaKey || event.ctrlKey)) {
        event.preventDefault();
        this.setTheme('high-contrast-theme');
      }
    });
  }
};

export default ThemeToggle; 