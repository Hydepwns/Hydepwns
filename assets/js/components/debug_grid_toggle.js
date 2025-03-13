/**
 * Debug Grid Toggle Component
 * 
 * Provides client-side functionality for the debug grid toggle.
 * Connects the UI toggle button to the debug grid functionality.
 * 
 * Features:
 * - Persists debug grid state in localStorage
 * - Handles toggling the debug grid display
 * - Proper resource cleanup and event management
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class DebugGridToggleComponent {
  /**
   * Create a new DebugGridToggle component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `debug-grid-toggle-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      enabled: false
    };
    
    // DOM element references
    this.elements = {
      container: null,
      checkbox: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[DebugGridToggle:${this.componentId}]`, ...args);
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
      console.error('DebugGridToggle component requires a container element');
      return this;
    }
    
    // Get the checkbox element
    this.elements.checkbox = this.elements.container;
    
    // Load initial state from localStorage
    this._loadState();
    
    // Set up event listeners
    this._setupEventListeners();
    
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
   * Load the debug grid state from localStorage
   * @private
   */
  _loadState() {
    // Get saved state from localStorage
    const savedState = localStorage.getItem('debugGrid') === 'true';
    
    // Update component state
    this._state.enabled = savedState;
    
    // Update checkbox state
    this.elements.checkbox.checked = savedState;
    
    // Apply the current state to the document
    this._applyState();
    
    this.debug.log('State loaded', this._state);
  }
  
  /**
   * Set up event listeners for the component
   * @private
   */
  _setupEventListeners() {
    // Add change event listener to the checkbox
    this.events.addEventListener(
      this.elements.checkbox,
      'change',
      this._handleToggleChange.bind(this)
    );
  }
  
  /**
   * Handle checkbox change events
   * @param {Event} event - Change event
   * @private
   */
  _handleToggleChange(event) {
    // Update state
    this._state.enabled = this.elements.checkbox.checked;
    
    // Save to localStorage
    localStorage.setItem('debugGrid', this._state.enabled);
    
    // Apply the new state
    this._applyState();
    
    this.debug.log('State changed', this._state);
  }
  
  /**
   * Apply the current debug grid state to the document
   * @private
   */
  _applyState() {
    // Toggle debug class on body
    document.body.classList.toggle('debug', this._state.enabled);
    
    // Find the debug grid and update its display
    const debugGrid = document.querySelector('.debug-grid');
    if (debugGrid) {
      debugGrid.style.display = this._state.enabled ? 'block' : 'none';
    }
  }
  
  /**
   * Toggle the debug grid state
   * @returns {this} - For method chaining
   */
  toggle() {
    // Toggle the checkbox
    this.elements.checkbox.checked = !this.elements.checkbox.checked;
    
    // Dispatch a change event to trigger the event handler
    const event = new Event('change');
    this.elements.checkbox.dispatchEvent(event);
    
    return this;
  }
  
  /**
   * Enable the debug grid
   * @returns {this} - For method chaining
   */
  enable() {
    if (!this._state.enabled) {
      this.toggle();
    }
    return this;
  }
  
  /**
   * Disable the debug grid
   * @returns {this} - For method chaining
   */
  disable() {
    if (this._state.enabled) {
      this.toggle();
    }
    return this;
  }
}

// Legacy LiveView hook for backward compatibility
const DebugGridToggle = {
  mounted() {
    this.component = new DebugGridToggleComponent({
      container: this.el,
      liveViewHook: this
    }).mount();
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default DebugGridToggle;
export { DebugGridToggleComponent }; 