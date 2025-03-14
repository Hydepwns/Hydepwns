/**
 * Toast Component
 * --------------
 * Provides lightweight, temporary notification toasts that appear briefly 
 * and then disappear. Designed for simple success/error/info messages that
 * don't require user interaction.
 * 
 * Built using the robust component system.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class ToastComponent {
  /**
   * Create a new Toast component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `toast-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: document.body,
      position: 'bottom-center', // 'top-right', 'top-center', 'top-left', 'bottom-right', 'bottom-center', 'bottom-left'
      duration: 3000, // Default display duration in milliseconds
      maxToasts: 3, // Maximum number of toasts to show at once
      gap: 8, // Gap between toasts in pixels
      zIndex: 9000, // z-index for the toast container
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      toasts: [],
      toastTimeouts: new Map() // Map to track auto-dismiss timeouts
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      toastContainer: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[Toast:${this.componentId}]`, ...args);
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
    
    // Create toast container
    this._createToastContainer();
    
    // Register with LiveView hook's custom event handling
    if (this.options.liveViewHook) {
      // If LiveView pushes a "show_toast" event, we'll handle it
      // This allows server-side code to trigger toasts
    }
    
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
    
    // Clear all toasts
    this._clearAllToasts();
    
    // Clear references
    this.elements = {};
    this._state = {
      toasts: [],
      toastTimeouts: new Map()
    };
  }
  
  /**
   * Show a toast notification
   * @param {Object} options - Toast options
   * @param {string} options.message - Toast message
   * @param {string} options.type - Toast type ('success', 'error', 'info', 'warning')
   * @param {number} options.duration - Duration to show toast in ms
   * @returns {string} - ID of the created toast
   */
  show(options) {
    const toastId = `toast-${Math.random().toString(36).substring(2, 9)}`;
    const toastOptions = {
      id: toastId,
      message: '',
      type: 'info',
      duration: this.options.duration,
      ...options
    };
    
    // Create the toast element
    const toast = this._createToastElement(toastOptions);
    
    // Add to state
    this._state.toasts.push({
      id: toastId,
      element: toast,
      options: toastOptions
    });
    
    // Manage maximum toasts
    this._manageMaxToasts();
    
    // Set timeout for auto-dismissal
    const timeoutId = setTimeout(() => {
      this.hide(toastId);
    }, toastOptions.duration);
    
    // Register timeout for cleanup
    this.cleanup.registerTimeout(timeoutId);
    
    // Store timeout ID
    this._state.toastTimeouts.set(toastId, timeoutId);
    
    this.debug.log('Toast shown', toastOptions);
    
    return toastId;
  }
  
  /**
   * Hide a specific toast
   * @param {string} toastId - ID of the toast to hide
   */
  hide(toastId) {
    const toastIndex = this._state.toasts.findIndex(t => t.id === toastId);
    
    if (toastIndex === -1) return;
    
    const toast = this._state.toasts[toastIndex];
    
    // Clear timeout if exists
    if (this._state.toastTimeouts.has(toastId)) {
      clearTimeout(this._state.toastTimeouts.get(toastId));
      this._state.toastTimeouts.delete(toastId);
    }
    
    // Animate toast out
    toast.element.style.opacity = '0';
    toast.element.style.transform = 'translateY(10px)';
    
    // Remove toast after animation
    setTimeout(() => {
      if (toast.element.parentNode) {
        toast.element.parentNode.removeChild(toast.element);
      }
      
      // Remove from state
      this._state.toasts.splice(toastIndex, 1);
    }, 300);
    
    this.debug.log('Toast hidden', toastId);
  }
  
  /**
   * Clear all toasts
   */
  clearAll() {
    this._clearAllToasts();
    this.debug.log('All toasts cleared');
  }
  
  /**
   * Convenience method to show a success toast
   * @param {string} message - Toast message
   * @param {Object} options - Additional options
   * @returns {string} - Toast ID
   */
  success(message, options = {}) {
    return this.show({
      message,
      type: 'success',
      ...options
    });
  }
  
  /**
   * Convenience method to show an error toast
   * @param {string} message - Toast message
   * @param {Object} options - Additional options
   * @returns {string} - Toast ID
   */
  error(message, options = {}) {
    return this.show({
      message,
      type: 'error',
      ...options
    });
  }
  
  /**
   * Convenience method to show an info toast
   * @param {string} message - Toast message
   * @param {Object} options - Additional options
   * @returns {string} - Toast ID
   */
  info(message, options = {}) {
    return this.show({
      message,
      type: 'info',
      ...options
    });
  }
  
  /**
   * Convenience method to show a warning toast
   * @param {string} message - Toast message
   * @param {Object} options - Additional options
   * @returns {string} - Toast ID
   */
  warning(message, options = {}) {
    return this.show({
      message,
      type: 'warning',
      ...options
    });
  }
  
  /**
   * Create the toast container element
   * @private
   */
  _createToastContainer() {
    const position = this.options.position;
    const positionClasses = {
      'top-right': 'top-0 right-0',
      'top-center': 'top-0 left-1/2 transform -translate-x-1/2',
      'top-left': 'top-0 left-0',
      'bottom-right': 'bottom-0 right-0',
      'bottom-center': 'bottom-0 left-1/2 transform -translate-x-1/2',
      'bottom-left': 'bottom-0 left-0'
    };
    
    this.elements.toastContainer = DOMCleanup.createElement('div', {
      className: `toast-container fixed p-4 flex flex-col z-${this.options.zIndex} ${positionClasses[position] || 'bottom-center'}`,
      style: {
        pointerEvents: 'none'
      }
    }, '', this.cleanup);
    
    // Reverse flex direction for bottom positions
    if (position.startsWith('bottom')) {
      this.elements.toastContainer.style.flexDirection = 'column-reverse';
    }
    
    this.elements.container.appendChild(this.elements.toastContainer);
  }
  
  /**
   * Create a toast element
   * @param {Object} options - Toast options
   * @returns {HTMLElement} - The created toast element
   * @private
   */
  _createToastElement(options) {
    const { id, message, type } = options;
    
    // Determine toast color based on type
    const typeClasses = {
      success: 'bg-green-500 text-white',
      error: 'bg-red-500 text-white',
      info: 'bg-blue-500 text-white',
      warning: 'bg-yellow-500 text-white'
    };
    
    // Create the toast element
    const toast = DOMCleanup.createElement('div', {
      id,
      className: `toast-item my-2 px-4 py-3 rounded-lg shadow-lg max-w-md transform transition-all duration-300 opacity-0 ${typeClasses[type] || typeClasses.info}`,
      role: 'alert',
      style: {
        pointerEvents: 'auto',
        marginTop: `${this.options.gap}px`,
        marginBottom: `${this.options.gap}px`
      }
    }, message, this.cleanup);
    
    // Add close button
    const closeButton = DOMCleanup.createElement('button', {
      className: 'ml-3 text-white opacity-70 hover:opacity-100 focus:opacity-100 focus:outline-none absolute top-2 right-2',
      type: 'button',
      'aria-label': 'Close toast'
    }, 'x', this.cleanup);
    
    // Add click event to close button
    this.events.addEventListener(closeButton, 'click', () => {
      this.hide(id);
    });
    
    toast.appendChild(closeButton);
    
    // Add to container
    this.elements.toastContainer.appendChild(toast);
    
    // Trigger animation after a small delay (allows DOM to update)
    setTimeout(() => {
      toast.style.opacity = '1';
      toast.style.transform = 'translateY(0)';
    }, 10);
    
    return toast;
  }
  
  /**
   * Manage maximum number of toasts
   * @private
   */
  _manageMaxToasts() {
    // If we have more toasts than allowed, remove the oldest ones
    while (this._state.toasts.length > this.options.maxToasts) {
      const oldestToastId = this._state.toasts[0].id;
      this.hide(oldestToastId);
    }
  }
  
  /**
   * Clear all toasts and their timeouts
   * @private
   */
  _clearAllToasts() {
    // Clear all timeouts
    this._state.toastTimeouts.forEach(timeoutId => {
      clearTimeout(timeoutId);
    });
    this._state.toastTimeouts.clear();
    
    // Remove all toast elements
    this._state.toasts.forEach(toast => {
      if (toast.element.parentNode) {
        toast.element.parentNode.removeChild(toast.element);
      }
    });
    
    // Clear state
    this._state.toasts = [];
  }
  
  /**
   * Update component state and trigger re-render if needed
   * @param {Object} newState - New state values
   * @private
   */
  _setState(newState) {
    const prevState = { ...this._state };
    this._state = { ...this._state, ...newState };
    
    // Only re-render if something changed
    if (JSON.stringify(prevState) !== JSON.stringify(this._state)) {
      this.debug.log('State updated', this._state);
    }
  }
}

/**
 * LiveView hook for backward compatibility
 */
const ToastHook = {
  mounted() {
    this.component = new ToastComponent({
      liveViewHook: this,
      container: this.el,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
    
    // Make the toast component accessible via window for testing/debugging
    if (window.DEBUG && window.DEBUG.enabled) {
      window.toast = this.component;
    }
  },
  
  updated() {
    // Handle updates if necessary
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
    
    // Remove from global scope if it was added
    if (window.DEBUG && window.DEBUG.enabled && window.toast === this.component) {
      delete window.toast;
    }
  },
  
  handleEvent(event, payload) {
    if (event === "show_toast" && this.component) {
      this.component.show(payload);
    }
  }
};

export default ToastHook;
export { ToastComponent }; 