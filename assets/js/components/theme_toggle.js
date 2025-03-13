/**
 * Theme Toggle Component
 * ---------------------
 * Handles switching between light, dark, and dim themes in integration with Phoenix LiveView.
 * 
 * Features:
 * - Manages theme persistence in localStorage
 * - Syncs with system preference for dark mode
 * - Responds to LiveView events for changing themes
 * - Provides bidirectional communication with LiveView
 * - Implements robust component pattern with proper cleanup
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class ThemeToggleComponent {
  /**
   * Create a new ThemeToggle component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `theme-toggle-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: document.body,
      defaultTheme: 'light',
      storageKey: 'theme',
      debug: false,
      liveViewHook: null, // LiveView hook instance if used in a hook
      ...options
    };
    
    // Component state (private)
    this._state = {
      currentTheme: null,
      systemPrefersDark: false
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      themeButtons: []
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug) {
          console.log(`[ThemeToggle:${this.componentId}]`, ...args);
        }
      }
    };
  }
  
  /**
   * Initialize the component and mount it to the DOM
   * @returns {this} - For method chaining
   */
  mount() {
    // Get event manager for this component
    this.events = EventManager.registerComponent(this.componentId);
    
    // Get cleanup registry for this component
    this.cleanup = DOMCleanup.register(this.componentId);
    
    // Store reference to container
    this.elements.container = this.options.container;
    
    // Find theme toggle buttons
    this.elements.themeButtons = this.elements.container.querySelectorAll('.theme-toggle button');
    this.debug.log('Found theme buttons:', this.elements.themeButtons.length);
    
    // Check system preference for dark mode
    this._state.systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    
    // Get current theme from localStorage or use default
    const savedTheme = localStorage.getItem(this.options.storageKey);
    this._state.currentTheme = savedTheme || 
      (this._state.systemPrefersDark ? 'dark-theme' : 'light-theme');
    
    this.debug.log('Initial theme:', this._state.currentTheme);
    
    // Apply the initial theme
    this._applyTheme(this._state.currentTheme);
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Set up LiveView event handlers if in a hook
    if (this.options.liveViewHook) {
      this._setupLiveViewHandlers();
    }
    
    return this;
  }
  
  /**
   * Remove the component and clean up resources
   */
  destroy() {
    this.debug.log('Destroying theme toggle component');
    
    // Clean up DOM elements and event listeners
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    // Unregister from event manager
    if (this.events) {
      EventManager.unregisterComponent(this.componentId);
    }
    
    // Clear references
    this.elements = {};
  }
  
  /**
   * Set a new theme
   * @param {string} theme - The theme name (with or without '-theme' suffix)
   * @returns {this} - For method chaining
   */
  setTheme(theme) {
    const themeWithSuffix = theme.endsWith('-theme') ? theme : `${theme}-theme`;
    this.debug.log('Setting theme to:', themeWithSuffix);
    
    this._state.currentTheme = themeWithSuffix;
    this._applyTheme(themeWithSuffix);
    localStorage.setItem(this.options.storageKey, themeWithSuffix);
    
    // Notify LiveView if in a hook
    if (this.options.liveViewHook) {
      this.options.liveViewHook.pushEvent('theme_changed', { theme: themeWithSuffix });
    }
    
    return this;
  }
  
  /**
   * Get the current theme
   * @returns {string} The current theme
   */
  getCurrentTheme() {
    return this._state.currentTheme;
  }
  
  /**
   * Set up event listeners for the component
   * @private
   */
  _setupEventListeners() {
    // Add click handlers to theme toggle buttons
    this.elements.themeButtons.forEach(button => {
      this.events.addEventListener(button, 'click', (event) => {
        const theme = button.getAttribute('data-theme');
        if (theme) {
          this.setTheme(theme);
        }
      });
    });
    
    // Listen for system color scheme changes
    const colorSchemeMediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    // Handle system preference changes using modern API if available
    if (typeof colorSchemeMediaQuery.addEventListener === 'function') {
      const mediaQueryHandler = (event) => {
        this._state.systemPrefersDark = event.matches;
        this.debug.log('System preference changed to:', event.matches ? 'dark' : 'light');
        
        // Only update theme if user hasn't explicitly set one
        if (!localStorage.getItem(this.options.storageKey)) {
          this.setTheme(event.matches ? 'dark' : 'light');
        }
      };
      
      colorSchemeMediaQuery.addEventListener('change', mediaQueryHandler);
      
      // Register for cleanup
      this.cleanup.registerCleanupFunction(() => {
        colorSchemeMediaQuery.removeEventListener('change', mediaQueryHandler);
      });
    }
  }
  
  /**
   * Set up LiveView event handlers if used in a hook
   * @private
   */
  _setupLiveViewHandlers() {
    const hook = this.options.liveViewHook;
    this.debug.log('Setting up LiveView event handlers');
    
    // Listen for theme change events from LiveView
    hook.handleEvent('change_theme', ({ theme }) => {
      this.debug.log('LiveView event received:', theme);
      this.setTheme(theme);
    });
    
    // Handle request to get the saved theme
    hook.handleEvent('get_saved_theme', () => {
      const savedTheme = localStorage.getItem(this.options.storageKey) || '';
      return savedTheme;
    });
  }
  
  /**
   * Apply the theme to the DOM
   * @param {string} theme - The theme name with "-theme" suffix
   * @private
   */
  _applyTheme(theme) {
    this.debug.log('Applying theme:', theme);
    
    // Update documentElement attribute for CSS variable inheritance
    document.documentElement.setAttribute('data-theme', theme);
    
    // Update body class for class-based styling
    document.body.classList.remove('light-theme', 'dark-theme', 'dim-theme');
    document.body.classList.add(theme);
    
    // Update UI to reflect current theme
    this._highlightActiveTheme(theme);
  }
  
  /**
   * Update the theme toggle buttons to visually indicate the active theme
   * @param {string} theme - The theme name with "-theme" suffix
   * @private
   */
  _highlightActiveTheme(theme) {
    const themeBase = theme.replace('-theme', '');
    this.debug.log('Highlighting active theme:', themeBase);
    
    this.elements.themeButtons.forEach(btn => {
      const btnTheme = btn.getAttribute('data-theme');
      const isActive = btnTheme === themeBase;
      
      // Update button styling to indicate active state
      btn.style.fontWeight = isActive ? 'var(--font-weight-bold)' : 'var(--font-weight-normal)';
      btn.style.color = isActive ? 'var(--text-color)' : 'var(--text-color-alt)';
      btn.setAttribute('aria-pressed', isActive);
    });
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const ThemeToggle = {
  mounted() {
    this.themeToggle = new ThemeToggleComponent({
      container: document,
      debug: window.DEBUG && window.DEBUG.log,
      liveViewHook: this
    }).mount();
  },
  
  destroyed() {
    if (this.themeToggle) {
      this.themeToggle.destroy();
      this.themeToggle = null;
    }
  }
};

export default ThemeToggle;
export { ThemeToggleComponent }; 