/**
 * Copyable Code Component
 * -----------------------
 * Allows users to click on code blocks to copy the content to clipboard.
 * Shows visual feedback when code is copied.
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class CopyableCodeComponent {
  /**
   * Create a new CopyableCode component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `copyable-code-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // The code block element
      successMessage: 'Copied!',
      initialMessage: 'Click to copy',
      errorMessage: 'Copy failed!',
      flashDuration: 300, // ms
      tooltipDuration: 2000, // ms
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      isCopying: false
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      tooltip: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[CopyableCode:${this.componentId}]`, ...args);
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
    
    // Set container reference
    this.elements.container = this.options.container;
    
    if (!this.elements.container) {
      console.error('CopyableCode: No container element provided');
      return this;
    }
    
    // Add visual indicator that the element is clickable
    this.elements.container.classList.add('copyable');
    
    // Create tooltip element
    this._createTooltip();
    
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
    
    // Remove copyable class
    if (this.elements.container) {
      this.elements.container.classList.remove('copyable', 'flash');
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
   * Create the tooltip element
   * @private
   */
  _createTooltip() {
    // Create tooltip element for feedback
    this.elements.tooltip = DOMCleanup.createElement('div', {
      className: 'copy-tooltip',
    }, this.options.initialMessage, this.cleanup);
    
    // Add to DOM
    if (this.elements.container.parentNode) {
      this.elements.container.parentNode.appendChild(this.elements.tooltip);
    }
  }
  
  /**
   * Set up event listeners
   * @private
   */
  _setupEventListeners() {
    // Click to copy
    this.events.addEventListener(
      this.elements.container, 
      'click', 
      this._copyToClipboard.bind(this)
    );
    
    // Show tooltip on hover
    this.events.addEventListener(
      this.elements.container,
      'mouseenter',
      () => {
        this.elements.tooltip.classList.add('visible');
      }
    );
    
    this.events.addEventListener(
      this.elements.container,
      'mouseleave',
      () => {
        this.elements.tooltip.classList.remove('visible', 'copied');
        this.elements.tooltip.textContent = this.options.initialMessage;
      }
    );
  }
  
  /**
   * Copy the content to clipboard
   * @private
   */
  _copyToClipboard() {
    // Prevent multiple copy operations at once
    if (this._state.isCopying) return;
    
    this._setState({ isCopying: true });
    
    const content = this.elements.container.textContent;
    
    // Using the Clipboard API if available
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(content)
        .then(() => this._showCopySuccess())
        .catch(err => {
          console.error('Failed to copy: ', err);
          this._showCopyError();
        })
        .finally(() => {
          this._setState({ isCopying: false });
        });
    } else {
      // Fallback method for older browsers
      const textarea = document.createElement('textarea');
      textarea.value = content;
      textarea.style.position = 'fixed';  // Avoid scrolling to bottom
      document.body.appendChild(textarea);
      textarea.select();
      
      try {
        const successful = document.execCommand('copy');
        if (successful) {
          this._showCopySuccess();
        } else {
          this._showCopyError();
        }
      } catch (err) {
        console.error('Failed to copy: ', err);
        this._showCopyError();
      }
      
      document.body.removeChild(textarea);
      this._setState({ isCopying: false });
    }
  }
  
  /**
   * Show success message after copying
   * @private
   */
  _showCopySuccess() {
    // Update tooltip to show success message
    this.elements.tooltip.textContent = this.options.successMessage;
    this.elements.tooltip.classList.add('copied', 'visible');
    
    // Add a brief flash effect to the code element
    this.elements.container.classList.add('flash');
    
    // Register the timeout for cleanup
    const flashTimeoutId = setTimeout(() => {
      this.elements.container.classList.remove('flash');
    }, this.options.flashDuration);
    
    this.cleanup.registerTimeout(flashTimeoutId);
    
    // Reset tooltip after a delay
    const tooltipTimeoutId = setTimeout(() => {
      if (!this.elements.container.matches(':hover')) {
        this.elements.tooltip.classList.remove('visible', 'copied');
        this.elements.tooltip.textContent = this.options.initialMessage;
      }
    }, this.options.tooltipDuration);
    
    this.cleanup.registerTimeout(tooltipTimeoutId);
  }
  
  /**
   * Show error message if copying fails
   * @private
   */
  _showCopyError() {
    // Update tooltip to show error message
    this.elements.tooltip.textContent = this.options.errorMessage;
    this.elements.tooltip.classList.add('error', 'visible');
    
    // Reset tooltip after a delay
    const tooltipTimeoutId = setTimeout(() => {
      this.elements.tooltip.classList.remove('visible', 'error');
      this.elements.tooltip.textContent = this.options.initialMessage;
    }, this.options.tooltipDuration);
    
    this.cleanup.registerTimeout(tooltipTimeoutId);
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
const CopyableCode = {
  mounted() {
    this.component = new CopyableCodeComponent({
      container: this.el,
      liveViewHook: this,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default CopyableCode;
export { CopyableCodeComponent };