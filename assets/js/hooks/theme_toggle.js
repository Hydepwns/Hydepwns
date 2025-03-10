/**
 * Theme Toggle Hook
 * ----------------
 * Handles switching between light, dark, and dim themes in integration with Phoenix LiveView.
 * 
 * This hook provides bidirectional communication:
 * 1. It listens for "change_theme" events from LiveView to update the theme
 * 2. It responds to "get_saved_theme" events to provide the stored theme to LiveView
 * 
 * The hook manages theme persistence in localStorage and applies theme changes
 * to both the documentElement (as a data-attribute) and body (as a class).
 */

const ThemeToggle = {
  /**
   * Initialization function called when LiveView attaches the hook to the DOM.
   */
  mounted() {
    // Access debug utility from window
    this.debug = window.DEBUG || { log: () => {} };
    this.debug.log('ThemeToggle mounted - Hook initialized');
    
    // Cache DOM elements for performance
    this.themeButtons = Array.from(document.querySelectorAll('.theme-toggle button'));
    this.themeSourceIndicator = document.getElementById('theme-source-indicator');
    this.debug.log('ThemeToggle: Found theme buttons', this.themeButtons.length);
    
    // For performance optimization
    this.debounceTimeout = null;
    this.themeChangeCount = 0;
    
    // Get current theme from localStorage or set default based on system preference
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    this.currentTheme = localStorage.getItem('theme') || (prefersDark ? 'dark-theme' : 'light-theme');
    this.debug.log('ThemeToggle: Initial theme from storage', this.currentTheme);
    
    // Set initial theme
    this.applyTheme(this.currentTheme);
    
    // Initialize custom tooltips for better usability
    this.initializeTooltips();
    
    // Handle request to get the saved theme
    this.handleEvent('get_saved_theme', () => {
      const savedTheme = localStorage.getItem('theme') || '';
      this.debug.log('ThemeToggle: Responding with saved theme', savedTheme);
      return savedTheme;
    });
    
    // Listen for theme change events from LiveView
    this.handleEvent('change_theme', ({ theme }) => {
      this.debug.log('ThemeToggle: LiveView event received', theme);
      
      // Always ensure theme has the -theme suffix
      const themeWithSuffix = theme.endsWith('-theme') ? theme : `${theme}-theme`;
      this.setTheme(themeWithSuffix);
    });
    
    // Listen for system preference changes
    this.setupSystemPreferenceListener();
    
    // Setup keyboard shortcuts for theme switching
    this.setupKeyboardShortcuts();
  },
  
  /**
   * Debounce function to prevent rapid theme changes
   * @param {Function} fn - The function to debounce
   * @param {number} delay - Delay in milliseconds
   */
  debounce(fn, delay) {
    clearTimeout(this.debounceTimeout);
    this.debounceTimeout = setTimeout(fn, delay);
  },
  
  /**
   * Sets up a listener for system color scheme preference changes
   */
  setupSystemPreferenceListener() {
    const darkModeMediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    // Add listener for preference changes
    darkModeMediaQuery.addEventListener('change', (e) => {
      // Only apply system preference if no user preference is stored
      if (!localStorage.getItem('theme')) {
        const newTheme = e.matches ? 'dark-theme' : 'light-theme';
        this.debug.log('ThemeToggle: System preference changed', newTheme);
        this.setTheme(newTheme);
      }
    });
  },
  
  /**
   * Sets the active theme and stores it in localStorage for persistence.
   * 
   * @param {string} theme - The theme name with "-theme" suffix (e.g., "dark-theme")
   */
  setTheme(theme) {
    // Ensure theme always has the -theme suffix
    const normalizedTheme = theme.endsWith('-theme') ? theme : `${theme}-theme`;
    
    this.debug.log('Setting theme to', normalizedTheme);
    
    // Increment theme change count for performance monitoring
    this.themeChangeCount++;
    const changeCount = this.themeChangeCount;
    
    // Use debounce for rapid theme changes to prevent performance issues
    if (changeCount > 2 && changeCount % 3 === 0) {
      this.debug.log('ThemeToggle: Debouncing theme change due to rapid changes', changeCount);
      this.debounce(() => {
        this.currentTheme = normalizedTheme;
        this.applyTheme(normalizedTheme);
        localStorage.setItem('theme', normalizedTheme);
      }, 50);
    } else {
      this.currentTheme = normalizedTheme;
      this.applyTheme(normalizedTheme);
      localStorage.setItem('theme', normalizedTheme);
    }
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
    
    // Apply transition animation
    document.body.classList.add('theme-transition');
    
    // Use will-change to optimize transition performance
    document.documentElement.style.willChange = 'background-color, color';
    document.body.style.willChange = 'background-color, color';
    
    // Remove animation class after animation completes
    setTimeout(() => {
      document.body.classList.remove('theme-transition');
      // Remove will-change once transition is complete to free up resources
      document.documentElement.style.willChange = 'auto';
      document.body.style.willChange = 'auto';
    }, 500); // Match the animation duration
    
    // Use requestAnimationFrame for better performance
    requestAnimationFrame(() => {
      // Update documentElement attribute for CSS variable inheritance
      document.documentElement.setAttribute('data-theme', theme);
      
      // Update body class for class-based styling - efficiently remove all possible themes first
      document.body.classList.remove('light-theme', 'dark-theme', 'dim-theme');
      document.body.classList.add(theme);
      
      // Set data attribute to indicate if theme is user-selected or system default
      const isUsingSystemPreference = !localStorage.getItem('theme');
      document.body.setAttribute('data-theme-mode', isUsingSystemPreference ? 'system' : 'user');
      
      // Update UI to reflect current theme
      this.highlightActiveTheme(theme);
      
      // Update theme source indicator
      this.updateThemeSourceIndicator();
    });
  },
  
  /**
   * Updates the theme source indicator text based on whether the theme
   * is from system preference or user selection
   */
  updateThemeSourceIndicator() {
    if (this.themeSourceIndicator) {
      // Always just show "Theme" regardless of theme source
      this.themeSourceIndicator.textContent = "";
    }
  },
  
  /**
   * Updates the theme toggle buttons to visually indicate the active theme.
   * 
   * @param {string} theme - The theme name with "-theme" suffix (e.g., "dark-theme")
   */
  highlightActiveTheme(theme) {
    const themeBase = theme.replace('-theme', '');
    this.debug.log('ThemeToggle: Highlighting active theme', themeBase);
    
    // Check if we're using system preference (no stored theme)
    const isUsingSystemPreference = !localStorage.getItem('theme');
    
    this.themeButtons.forEach(btn => {
      const btnTheme = btn.getAttribute('data-theme');
      
      // Handle special case for system preference button
      if (btnTheme === 'system') {
        const isActive = isUsingSystemPreference;
        btn.setAttribute('aria-pressed', isActive);
        btn.classList.toggle('active-theme', isActive);
      } else {
        const isActive = btnTheme === themeBase;
        btn.setAttribute('aria-pressed', isActive);
        btn.classList.toggle('active-theme', isActive);
      }
    });
  },
  
  /**
   * Sets up keyboard shortcuts for theme switching
   * Shift+Up/Down: Cycle through themes (light -> dim -> dark -> light)
   * Shift+Left/Right: Cycle through themes
   */
  setupKeyboardShortcuts() {
    // Keep track of the current themes array and index
    const themes = ['light-theme', 'dim-theme', 'dark-theme'];
    
    document.addEventListener('keydown', (e) => {
      // Only respond to Shift + arrow key combinations
      if (e.shiftKey && !e.altKey && !e.ctrlKey && !e.metaKey) {
        // Get current theme to determine current index
        const currentTheme = this.currentTheme;
        let currentIndex = themes.indexOf(currentTheme);
        if (currentIndex === -1) {
          // If current theme is not in the array (system default), start with first
          currentIndex = 0;
        }
        
        switch (e.key) {
          case 'ArrowUp':
          case 'ArrowRight':
            // Move to next theme in the cycle
            const nextIndex = (currentIndex + 1) % themes.length;
            this.debug.log('ThemeToggle: Keyboard shortcut - next theme', themes[nextIndex]);
            this.setTheme(themes[nextIndex]);
            e.preventDefault(); // Prevent default scrolling
            break;
            
          case 'ArrowDown':
          case 'ArrowLeft':
            // Move to previous theme in the cycle
            const prevIndex = (currentIndex - 1 + themes.length) % themes.length;
            this.debug.log('ThemeToggle: Keyboard shortcut - previous theme', themes[prevIndex]);
            this.setTheme(themes[prevIndex]);
            e.preventDefault(); // Prevent default scrolling
            break;
        }
      }
    });
  },
  
  /**
   * Initializes custom tooltips for theme buttons with better UX
   */
  initializeTooltips() {
    // Add event listeners for better tooltip experience
    this.themeButtons.forEach(btn => {
      const title = btn.getAttribute('title');
      if (!title) return;
      
      // Create and append tooltip element
      const tooltip = document.createElement('span');
      tooltip.className = 'theme-tooltip';
      tooltip.textContent = title;
      tooltip.style.display = 'none';
      btn.appendChild(tooltip);
      
      // Show tooltip on hover or focus
      btn.addEventListener('mouseenter', () => {
        tooltip.style.display = 'block';
      });
      
      btn.addEventListener('focus', () => {
        tooltip.style.display = 'block';
      });
      
      // Hide tooltip on mouse leave or blur
      btn.addEventListener('mouseleave', () => {
        tooltip.style.display = 'none';
      });
      
      btn.addEventListener('blur', () => {
        tooltip.style.display = 'none';
      });
    });
  }
};

export default ThemeToggle; 