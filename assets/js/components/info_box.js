/**
 * Info Box Component
 * -----------------
 * 
 * Provides client-side functionality for information boxes, including
 * animations, dismissal actions, and persistence of dismissal state.
 * 
 * Features:
 * - Smooth dismissal animations
 * - Persistent dismissal state using localStorage
 * - Proper cleanup of resources
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class InfoBoxComponent {
  /**
   * Create a new InfoBox component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `info-box-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      liveViewHook: null, // LiveView hook instance if used in a hook
      dismissAnimationDuration: 500, // Duration of dismiss animation in ms
      storageKey: 'dismissedInfoBoxes', // localStorage key for dismissed boxes
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      boxId: null,
      isDismissed: false
    };
    
    // DOM element references
    this.elements = {
      container: null,
      closeButton: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[InfoBox:${this.componentId}]`, ...args);
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
      console.error('InfoBox component requires a container element');
      return this;
    }
    
    // Store box ID if available
    this._state.boxId = this.elements.container.id || null;
    
    // Find close button
    this._findElements();
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Check if this info box was previously dismissed
    this._checkDismissalState();
    
    this.debug.log('Component mounted', { boxId: this._state.boxId });
    
    return this;
  }
  
  /**
   * Handle component updates (e.g., from LiveView)
   * @returns {this} - For method chaining
   */
  update() {
    // Re-check dismissal state when component updates
    this._checkDismissalState();
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
   * Find and store references to necessary DOM elements
   * @private
   */
  _findElements() {
    this.elements.closeButton = this.elements.container.querySelector('.info-box__close');
    
    if (!this.elements.closeButton) {
      this.debug.log('Close button not found');
    }
  }
  
  /**
   * Set up event listeners for the component
   * @private
   */
  _setupEventListeners() {
    if (this.elements.closeButton) {
      this.events.addEventListener(
        this.elements.closeButton,
        'click',
        this._handleCloseClick.bind(this)
      );
    }
  }
  
  /**
   * Handle close button click events
   * @param {Event} event - Click event
   * @private
   */
  _handleCloseClick(event) {
    event.preventDefault();
    this.dismiss();
  }
  
  /**
   * Check if this box was previously dismissed and hide it if needed
   * @private
   */
  _checkDismissalState() {
    // If this box has an ID, check if it was previously dismissed
    if (this._state.boxId) {
      const dismissedBoxes = this._getDismissedBoxes();
      
      if (dismissedBoxes.includes(this._state.boxId)) {
        // Hide immediately without animation
        this._state.isDismissed = true;
        
        if (this.elements.container && this.elements.container.parentNode) {
          this.elements.container.parentNode.removeChild(this.elements.container);
        }
      }
    }
  }
  
  /**
   * Store the box ID in localStorage as dismissed
   * @private
   */
  _storeDismissalState() {
    // If this box has an ID, store it as dismissed
    if (this._state.boxId) {
      const dismissedBoxes = this._getDismissedBoxes();
      
      if (!dismissedBoxes.includes(this._state.boxId)) {
        dismissedBoxes.push(this._state.boxId);
        localStorage.setItem(this.options.storageKey, JSON.stringify(dismissedBoxes));
      }
    }
  }
  
  /**
   * Get array of dismissed box IDs from localStorage
   * @returns {Array} - Array of dismissed box IDs
   * @private
   */
  _getDismissedBoxes() {
    // Get array of dismissed box IDs from localStorage
    const stored = localStorage.getItem(this.options.storageKey);
    return stored ? JSON.parse(stored) : [];
  }
  
  /**
   * Dismiss the info box with animation
   * @returns {this} - For method chaining
   */
  dismiss() {
    if (this._state.isDismissed || !this.elements.container) {
      return this;
    }
    
    // Mark as dismissed
    this._state.isDismissed = true;
    
    // Animate the dismissal
    this.elements.container.style.transition = `opacity 0.3s, max-height ${this.options.dismissAnimationDuration/1000}s, margin ${this.options.dismissAnimationDuration/1000}s`;
    this.elements.container.style.opacity = '0';
    this.elements.container.style.maxHeight = '0';
    this.elements.container.style.margin = '0';
    this.elements.container.style.overflow = 'hidden';
    
    // Remove from DOM after animation completes
    this.cleanup.registerTimeout(setTimeout(() => {
      if (this.elements.container && this.elements.container.parentNode) {
        this.elements.container.parentNode.removeChild(this.elements.container);
      }
    }, this.options.dismissAnimationDuration));
    
    // Store dismissal state
    this._storeDismissalState();
    
    this.debug.log('Info box dismissed', { boxId: this._state.boxId });
    
    return this;
  }
  
  /**
   * Check if the info box is currently dismissed
   * @returns {boolean} - Whether the box is dismissed
   */
  isDismissed() {
    return this._state.isDismissed;
  }
  
  /**
   * Get the box ID if available
   * @returns {string|null} - The box ID or null
   */
  getBoxId() {
    return this._state.boxId;
  }
  
  /**
   * Clear all dismissed boxes from localStorage
   * @returns {this} - For method chaining
   */
  static clearAllDismissed(storageKey = 'dismissedInfoBoxes') {
    localStorage.removeItem(storageKey);
    return this;
  }
}

// Legacy LiveView hook for backward compatibility
const DismissibleInfoBox = {
  mounted() {
    this.component = new InfoBoxComponent({
      container: this.el,
      liveViewHook: this
    }).mount();
  },
  
  updated() {
    if (this.component) {
      this.component.update();
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export { DismissibleInfoBox, InfoBoxComponent }; 