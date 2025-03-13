/**
 * Terminal Theme Synchronization Component
 * ----------------------------------------
 * This component synchronizes the terminal theme with the site theme
 * and ensures that theme changes are reflected in the terminal component.
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class TerminalThemeSyncComponent {
  /**
   * Create a new Terminal Theme Sync component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `terminal-theme-sync-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      terminalId: null, // ID of the terminal to sync with
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      currentTheme: null
    };
    
    // DOM element references
    this.elements = {
      container: null,
      terminal: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[TerminalThemeSync:${this.componentId}]`, ...args);
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
    
    // Store container reference
    this.elements.container = this.options.container || this.options.liveViewHook?.el;
    
    if (!this.elements.container) {
      console.error('Terminal Theme Sync component requires a container element');
      return this;
    }
    
    // Get terminal ID
    this.terminalId = this.options.terminalId || this.elements.container.getAttribute('data-terminal-id');
    
    // Find terminal element
    this.elements.terminal = document.querySelector(`#${this.terminalId}`);
    
    this.debug.log('Terminal element found:', !!this.elements.terminal);
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Set initial theme with a slight delay to ensure component is fully mounted
    setTimeout(() => this._syncThemeWithSite(), 100);
    
    this.debug.log('Component mounted');
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
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
    this._state = {};
  }
  
  /**
   * Set up event listeners
   * @private
   */
  _setupEventListeners() {
    // Listen for theme change events
    this.events.addEventListener(window, 'theme-set', this._handleThemeChange.bind(this));
    this.events.addEventListener(window, 'theme-changed', this._handleThemeChange.bind(this));
  }
  
  /**
   * Handle theme change events
   * @param {Event} event - Theme change event
   * @private
   */
  _handleThemeChange(event) {
    this.debug.log('Theme change event received', event);
    
    // Sync theme after a small delay to ensure the site theme has been updated
    setTimeout(() => this._syncThemeWithSite(), 50);
  }
  
  /**
   * Synchronize terminal theme with site theme
   * @private
   */
  _syncThemeWithSite() {
    // Determine current theme
    const html = document.documentElement;
    let currentTheme = '';
    
    if (html.classList.contains('light-theme') || html.getAttribute('data-theme') === 'light-theme') {
      currentTheme = 'light';
    } else if (html.classList.contains('dark-theme') || html.getAttribute('data-theme') === 'dark-theme') {
      currentTheme = 'dark';
    } else if (html.classList.contains('dim-theme') || html.getAttribute('data-theme') === 'dim-theme') {
      currentTheme = 'dim';
    } else if (html.classList.contains('high-contrast-theme') || html.getAttribute('data-theme') === 'high-contrast-theme') {
      currentTheme = 'high-contrast';
    } else if (html.classList.contains('synthwave-theme') || html.getAttribute('data-theme') === 'synthwave-theme') {
      currentTheme = 'synthwave';
    } else {
      // Default to dark theme if none is set
      currentTheme = 'dark';
    }
    
    this.debug.log('Current site theme detected as', currentTheme);
    
    // Only update if theme has changed
    if (currentTheme !== this._state.currentTheme) {
      this._state.currentTheme = currentTheme;
      this._updateTerminalTheme(currentTheme);
    }
  }
  
  /**
   * Update terminal theme
   * @param {string} theme - Theme name
   * @private
   */
  _updateTerminalTheme(theme) {
    if (!this.elements.terminal) {
      this.debug.log('Cannot update theme - terminal element not found');
      return;
    }
    
    this.debug.log('Updating terminal theme to', theme);
    
    // If we have access to the LiveComponent, update it via push_event
    if (this.options.liveViewHook) {
      this.options.liveViewHook.pushEvent('update_terminal_theme', { theme });
    }
    
    // Also update classes directly for immediate visual feedback
    this.elements.terminal.classList.remove(
      'terminal-theme-light', 
      'terminal-theme-dark', 
      'terminal-theme-dim', 
      'terminal-theme-high-contrast',
      'terminal-theme-synthwave'
    );
    this.elements.terminal.classList.add(`terminal-theme-${theme}`);
    
    // Dispatch an event that can be listened to by other components
    const eventDetail = { theme };
    const customEvent = new CustomEvent('terminal:theme-changed', {
      bubbles: true,
      detail: eventDetail
    });
    
    this.elements.terminal.dispatchEvent(customEvent);
    
    this.debug.log('Terminal theme updated to', theme);
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const TerminalThemeSync = {
  mounted() {
    this.component = new TerminalThemeSyncComponent({
      liveViewHook: this,
      container: this.el,
      terminalId: this.el.getAttribute('data-terminal-id'),
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  disconnected() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default TerminalThemeSync;
export { TerminalThemeSyncComponent }; 