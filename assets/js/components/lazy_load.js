/**
 * Lazy Load Component
 * ------------------
 * 
 * Provides client-side functionality for lazy loading elements, only showing content
 * when it's approaching or entering the viewport.
 * 
 * Features:
 * - Uses IntersectionObserver for efficient viewport detection
 * - Configurable root margin and threshold via options
 * - Accessibility announcements for loaded content
 * - Event dispatching for parent component awareness
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class LazyLoadComponent {
  /**
   * Create a new LazyLoad component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `lazy-load-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      liveViewHook: null, // LiveView hook instance if used in a hook
      rootMargin: '100px', // Margin around root for early loading
      threshold: 0.1, // Percentage visibility required to trigger loading
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      isLoaded: false,
      isObserving: false
    };
    
    // DOM element references
    this.elements = {
      container: null,
      placeholder: null,
      content: null
    };
    
    // IntersectionObserver instance
    this.observer = null;
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[LazyLoad:${this.componentId}]`, ...args);
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
      console.error('LazyLoad component requires a container element');
      return this;
    }
    
    // Find content elements
    this._findElements();
    
    // Check if content is already marked as loaded
    const isPreLoaded = this.elements.container.dataset.loaded === 'true';
    
    if (isPreLoaded) {
      // Already loaded, just show content
      this._state.isLoaded = true;
      this._showContent();
      this.debug.log('Content pre-loaded, skipping lazy loading');
    } else {
      // Create and start the observer
      this._createObserver();
    }
    
    this.debug.log('Component mounted');
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
    // Disconnect the observer if it exists
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
    
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
   * Find and store references to necessary DOM elements
   * @private
   */
  _findElements() {
    this.elements.placeholder = this.elements.container.querySelector('[data-lazy-placeholder]');
    this.elements.content = this.elements.container.querySelector('[data-lazy-content]');
    
    if (!this.elements.placeholder) {
      this.debug.log('Placeholder element not found');
    }
    
    if (!this.elements.content) {
      this.debug.log('Content element not found');
    }
  }
  
  /**
   * Create and start the IntersectionObserver
   * @private
   */
  _createObserver() {
    // Get configuration from options or data attributes
    const rootMargin = this.elements.container.dataset.margin || this.options.rootMargin;
    const threshold = parseFloat(this.elements.container.dataset.threshold || this.options.threshold);
    
    // Create the IntersectionObserver
    this.observer = new IntersectionObserver(
      this._handleIntersection.bind(this),
      {
        rootMargin,
        threshold
      }
    );
    
    // Start observing this element
    this.observer.observe(this.elements.container);
    this._state.isObserving = true;
    
    this.debug.log('IntersectionObserver started', { rootMargin, threshold });
    
    // Register the observer for cleanup
    this.cleanup.registerCleanupFunction(() => {
      if (this.observer) {
        this.observer.disconnect();
        this.observer = null;
      }
    });
  }
  
  /**
   * Handle intersection events from the IntersectionObserver
   * @param {IntersectionObserverEntry[]} entries - Intersection entries
   * @private
   */
  _handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        // Element is now visible (or approaching visibility)
        this._showContent();
        
        // Stop observing once content is loaded
        if (this.observer) {
          this.observer.disconnect();
          this.observer = null;
          this._state.isObserving = false;
        }
      }
    });
  }
  
  /**
   * Show the actual content and hide placeholder
   * @private
   */
  _showContent() {
    if (this.elements.content && this.elements.placeholder) {
      // Show content
      this.elements.content.style.display = '';
      
      // Hide placeholder
      this.elements.placeholder.style.display = 'none';
      
      // Mark as loaded
      this.elements.container.dataset.loaded = 'true';
      this._state.isLoaded = true;
      
      // Emit a custom event that can be captured by parent components if needed
      const event = new CustomEvent('lazy-content-loaded', {
        bubbles: true,
        detail: { 
          id: this.elements.container.id,
          componentId: this.componentId
        }
      });
      this.elements.container.dispatchEvent(event);
      
      // Announce to screen readers that content has loaded
      this._announceContentLoaded();
      
      this.debug.log('Content displayed');
    }
  }
  
  /**
   * Announce content loaded for accessibility
   * @private
   */
  _announceContentLoaded() {
    // Find the accessibility announcer if it exists
    const announcer = document.getElementById('accessibility-announcer');
    if (announcer) {
      announcer.textContent = 'Content loaded';
    }
  }
  
  /**
   * Check if content is currently loaded
   * @returns {boolean} - Whether content is loaded
   */
  isLoaded() {
    return this._state.isLoaded;
  }
  
  /**
   * Force content to load immediately, bypassing the lazy loading
   * @returns {this} - For method chaining
   */
  loadNow() {
    if (!this._state.isLoaded) {
      this._showContent();
      
      // Stop observing if we're forcing a load
      if (this.observer) {
        this.observer.disconnect();
        this.observer = null;
        this._state.isObserving = false;
      }
    }
    
    return this;
  }
}

// Legacy LiveView hook for backward compatibility
const LazyLoad = {
  mounted() {
    this.component = new LazyLoadComponent({
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

export default LazyLoad;
export { LazyLoadComponent }; 