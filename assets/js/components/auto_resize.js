/**
 * AutoResize Component
 * -------------------
 * 
 * A component that automatically resizes textareas to fit their content.
 * This ensures that users can see the full text without scrolling.
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class AutoResizeComponent {
  /**
   * Create a new AutoResize component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `auto-resize-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Textarea element (usually this.el from LiveView hook)
      paddingBottom: 5, // Extra padding to add at the bottom (in pixels)
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      lastHeight: null // Last set height for comparison
    };
    
    // DOM element references
    this.elements = {
      container: null // The textarea element
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[AutoResize:${this.componentId}]`, ...args);
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
    
    // Store container reference (should be a textarea)
    this.elements.container = this.options.container || this.options.liveViewHook?.el;
    
    if (!this.elements.container) {
      console.error('AutoResize component requires a container element');
      return this;
    }
    
    if (this.elements.container.tagName.toLowerCase() !== 'textarea') {
      console.warn('AutoResize component should be used with textarea elements');
    }
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Perform initial resize
    this.resize();
    
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
   * Set up event listeners for the textarea
   * @private
   */
  _setupEventListeners() {
    if (!this.elements.container) return;
    
    // Listen for input events to resize on typing
    this.events.addEventListener(
      this.elements.container,
      'input',
      this._handleInput.bind(this)
    );
  }
  
  /**
   * Handle input events on the textarea
   * @private
   */
  _handleInput() {
    this.resize();
  }
  
  /**
   * Resize the textarea to fit its content
   * @public - This is a public API method
   */
  resize() {
    if (!this.elements.container) return;
    
    // Save current scroll position
    const scrollTop = this.elements.container.scrollTop;
    
    // Reset height to auto to get natural scrollHeight
    this.elements.container.style.height = 'auto';
    
    // Calculate new height with padding
    const newHeight = (this.elements.container.scrollHeight + this.options.paddingBottom) + 'px';
    
    // Only update if height has changed
    if (this._state.lastHeight !== newHeight) {
      this.elements.container.style.height = newHeight;
      this._state.lastHeight = newHeight;
    }
    
    // Restore scroll position
    this.elements.container.scrollTop = scrollTop;
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const AutoResize = {
  mounted() {
    this.component = new AutoResizeComponent({
      liveViewHook: this,
      container: this.el,
      paddingBottom: parseInt(this.el.dataset.paddingBottom, 10) || 5,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  updated() {
    if (this.component) {
      // Resize on update in case content changed
      this.component.resize();
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default AutoResize;
export { AutoResizeComponent }; 