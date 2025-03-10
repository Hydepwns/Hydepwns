/**
 * Theme Toggle Component
 * ---------------------
 * Handles switching between light, dark, and dim themes in integration with Phoenix LiveView.
 * 
 * This component uses the LiveView hook system to provide bidirectional communication:
 * 1. It listens for "change_theme" events from LiveView to update the theme
 * 2. It responds to "get_saved_theme" events to provide the stored theme to LiveView
 * 
 * The component manages theme persistence in localStorage and applies theme changes
 * to both the documentElement (as a data-attribute) and body (as a class) to ensure 
 * proper CSS variable inheritance and class-based styling.
 * 
 * It also includes debugging support through the application's DEBUG utility.
 */

const ThemeToggle = {
  /**
   * Initialization function called when LiveView attaches the hook to the DOM.
   * 
   * Sets up initial theme from localStorage or system preference,
   * applies the theme to the DOM, and registers event handlers for LiveView
   * communication.
   */
  mounted() {
    // Access debug utility from window
    this.debug = window.DEBUG || { log: () => {} };
    this.debug.log('ThemeToggle mounted - Hook initialized');
    
    // Cache DOM elements for performance
    this.themeButtons = document.querySelectorAll('.theme-toggle button');
    this.debug.log('ThemeToggle: Found theme buttons', this.themeButtons.length);
    
    // Get current theme from localStorage or set default based on system preference
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    this.currentTheme = localStorage.getItem('theme') || (prefersDark ? 'dark-theme' : 'light-theme');
    this.debug.log('ThemeToggle: Initial theme from storage', this.currentTheme);
    
    // Set initial theme
    this.applyTheme(this.currentTheme);
    
    // Handle request to get the saved theme
    this.handleEvent('get_saved_theme', () => {
      const savedTheme = localStorage.getItem('theme') || '';
      return savedTheme;
    });
    
    // Listen for theme change events from LiveView
    this.handleEvent('change_theme', ({ theme }) => {
      this.debug.log('ThemeToggle: LiveView event received', theme);
      const themeWithSuffix = theme.endsWith('-theme') ? theme : `${theme}-theme`;
      this.setTheme(themeWithSuffix);
    });
  },
  
  /**
   * Sets the active theme and stores it in localStorage for persistence.
   * 
   * @param {string} theme - The theme name with "-theme" suffix (e.g., "dark-theme")
   */
  setTheme(theme) {
    this.debug.log('Setting theme to', theme);
    this.currentTheme = theme;
    this.applyTheme(theme);
    localStorage.setItem('theme', theme);
  },
  
  /**
   * Applies the theme to the DOM by:
   * 1. Setting data-theme attribute on documentElement for CSS variable inheritance
   * 2. Adding a class to body for class-based styling
   * 3. Updating UI to indicate the active theme
   * 
   * @param {string} theme - The theme name with "-theme" suffix (e.g., "dark-theme")
   */
  applyTheme(theme) {
    this.debug.log('Applying theme', theme);
    
    // Update documentElement attribute for CSS variable inheritance
    document.documentElement.setAttribute('data-theme', theme);
    this.debug.log('ThemeToggle: Applied data-theme to documentElement', 
                document.documentElement.getAttribute('data-theme'));
    
    // Update body class for class-based styling
    document.body.classList.remove('light-theme', 'dark-theme', 'dim-theme');
    document.body.classList.add(theme);
    this.debug.log('ThemeToggle: Applied class to body', 
                document.body.classList.contains(theme), 
                'Current body classes:', document.body.className);
    
    // Update UI to reflect current theme
    this.highlightActiveTheme(theme);
  },
  
  /**
   * Updates the theme toggle buttons to visually indicate the active theme.
   * 
   * @param {string} theme - The theme name with "-theme" suffix (e.g., "dark-theme")
   */
  highlightActiveTheme(theme) {
    const themeBase = theme.replace('-theme', '');
    this.debug.log('ThemeToggle: Highlighting active theme', themeBase);
    
    this.themeButtons.forEach(btn => {
      const btnTheme = btn.getAttribute('data-theme');
      const isActive = btnTheme === themeBase;
      
      // Update button styling to indicate active state
      btn.style.fontWeight = isActive ? 'var(--font-weight-bold)' : 'var(--font-weight-normal)';
      btn.style.color = isActive ? 'var(--text-color)' : 'var(--text-color-alt)';
      btn.setAttribute('aria-pressed', isActive);
      this.debug.log('ThemeToggle: Button state updated', btnTheme, isActive);
    });
  }
};

export default ThemeToggle; 