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
    this.debug.log('ThemeToggle: Applying theme', theme);
    
    // Strip any suffix if present and add it back consistently
    const baseTheme = theme.replace('-theme', '');
    const formattedTheme = `${baseTheme}-theme`;
    
    // Cache current theme
    this.currentTheme = formattedTheme;
    
    // Update DOM
    document.documentElement.setAttribute('data-theme', formattedTheme);
    document.body.className = document.body.className
      .replace(/light-theme|dark-theme|dim-theme|high-contrast-theme/g, '')
      .trim();
    document.body.classList.add(formattedTheme);
    
    // Update UI components
    this.highlightActiveTheme(formattedTheme);
    this.updateThemeSourceIndicator();
    
    // Announce the theme change to screen readers
    this.announceThemeChange(formattedTheme);
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
   */
  setupKeyboardShortcuts() {
    document.addEventListener('keydown', (e) => {
      // Check if Shift key is pressed with arrow keys
      if (e.shiftKey && (e.key === 'ArrowUp' || e.key === 'ArrowRight' || e.key === 'ArrowDown' || e.key === 'ArrowLeft')) {
        e.preventDefault(); // Prevent default scroll behavior
        
        // Define theme cycle order
        const themeCycle = ['light-theme', 'dim-theme', 'dark-theme', 'high-contrast-theme'];
        
        // Find current theme in cycle
        const currentIndex = themeCycle.indexOf(this.currentTheme);
        
        // Calculate next/previous theme
        let newIndex;
        if (e.key === 'ArrowUp' || e.key === 'ArrowRight') {
          // Next theme (cycling back to first if at end)
          newIndex = (currentIndex + 1) % themeCycle.length;
        } else {
          // Previous theme (cycling to last if at beginning)
          newIndex = (currentIndex - 1 + themeCycle.length) % themeCycle.length;
        }
        
        // Set the new theme
        this.setTheme(themeCycle[newIndex]);
        
        // Announce theme change to screen readers
        this.announceThemeChange(themeCycle[newIndex]);
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
  },
  
  /**
   * Announces the theme change to screen readers
   * 
   * @param {string} theme - The theme that was just applied
   */
  announceThemeChange(theme) {
    // Create a live region for screen reader announcements if it doesn't exist
    let announcer = document.getElementById('theme-change-announcer');
    if (!announcer) {
      announcer = document.createElement('div');
      announcer.id = 'theme-change-announcer';
      announcer.setAttribute('aria-live', 'polite');
      announcer.className = 'sr-only';
      document.body.appendChild(announcer);
    }
    
    // Format the theme name for announcement
    const themeName = theme.replace('-theme', '').replace('-', ' ');
    
    // Set the message
    announcer.textContent = `Theme changed to ${themeName}`;
    
    // Clear the announcement after a short delay (optional)
    setTimeout(() => {
      announcer.textContent = '';
    }, 1000);
  }
};

export default ThemeToggle; 