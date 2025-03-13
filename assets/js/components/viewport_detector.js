/**
 * Viewport Detector Component
 * -----------------------
 * Detects viewport size changes and communicates them to the server.
 * Enables responsive design by tracking the current viewport size.
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class ViewportDetectorComponent {
  /**
   * Create a new ViewportDetector component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `viewport-detector-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      throttleTime: 250, // ms to throttle resize events
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      currentSize: null,
      resizeTimeout: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[ViewportDetector:${this.componentId}]`, ...args);
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
    
    // Store initial viewport size
    this._state.currentSize = this._getViewportSize();
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Send initial viewport size
    this._pushSize();
    
    this.debug.log('Component mounted - Current size:', this._state.currentSize);
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
    // Clear any pending resize timeout
    if (this._state.resizeTimeout) {
      clearTimeout(this._state.resizeTimeout);
    }
    
    // Clean up DOM elements and event listeners
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    // Unregister from event manager
    if (this.events) {
      EventManager.unregisterComponent(this.componentId);
    }
    
    // Remove viewport classes from body
    document.body.classList.remove('viewport-mobile', 'viewport-tablet', 'viewport-desktop');
    
    // Clear references
    this.elements = {};
    this._state = {};
  }
  
  /**
   * Set up event listeners for viewport detection
   * @private
   */
  _setupEventListeners() {
    // Listen for window resize events
    this.events.addEventListener(window, 'resize', this._handleResize.bind(this));
  }
  
  /**
   * Handle resize events with throttling
   * @private
   */
  _handleResize() {
    // Throttle resize events for better performance
    if (this._state.resizeTimeout) {
      clearTimeout(this._state.resizeTimeout);
    }
    
    const timeoutId = setTimeout(() => {
      const newSize = this._getViewportSize();
      
      // Only send update if the size category changed
      if (newSize !== this._state.currentSize) {
        this._setState({ currentSize: newSize });
        this._pushSize();
        
        this.debug.log('Size changed to:', this._state.currentSize);
      }
    }, this.options.throttleTime);
    
    // Register timeout for cleanup
    this.cleanup.registerTimeout(timeoutId);
    
    // Store timeout ID in state
    this._state.resizeTimeout = timeoutId;
  }
  
  /**
   * Get the current viewport size category
   * @returns {string} - 'mobile', 'tablet', or 'desktop'
   * @private
   */
  _getViewportSize() {
    const width = window.innerWidth;
    
    // Define breakpoints for different device sizes
    if (width < 768) {
      return 'mobile';
    } else if (width < 1024) {
      return 'tablet';
    } else {
      return 'desktop';
    }
  }
  
  /**
   * Push the current viewport size to the server and update CSS
   * @private
   */
  _pushSize() {
    // Push event to the server with current viewport size
    if (this.options.liveViewHook) {
      this.options.liveViewHook.pushEvent('update_viewport_size', { 
        size: this._state.currentSize,
        width: window.innerWidth,
        height: window.innerHeight
      });
    }
    
    // Update CSS variable for use in styling
    document.documentElement.style.setProperty('--viewport-size', `"${this._state.currentSize}"`);
    
    // Update body classes for CSS targeting
    document.body.classList.remove('viewport-mobile', 'viewport-tablet', 'viewport-desktop');
    document.body.classList.add(`viewport-${this._state.currentSize}`);
    
    // Dispatch custom event for other components
    window.dispatchEvent(new CustomEvent('viewport-changed', {
      detail: {
        size: this._state.currentSize,
        width: window.innerWidth,
        height: window.innerHeight
      }
    }));
  }
  
  /**
   * Update component state
   * @param {Object} newState - New state to merge with current state
   * @private
   */
  _setState(newState) {
    this._state = {
      ...this._state,
      ...newState
    };
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const ViewportDetector = {
  mounted() {
    this.component = new ViewportDetectorComponent({
      liveViewHook: this,
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

export default ViewportDetector;
export { ViewportDetectorComponent }; 