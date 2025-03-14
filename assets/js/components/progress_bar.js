/**
 * Progress Bar Component
 * ---------------------
 * Displays a customizable progress bar that can be used to show the progress
 * of various operations. Supports different styles, animations, and events.
 * 
 * Built using the robust component system.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class ProgressBarComponent {
  /**
   * Create a new ProgressBar component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `progress-bar-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: document.body,
      initialProgress: 0, // Initial progress value (0-100)
      height: '8px', // Height of the progress bar
      width: '100%', // Width of the progress bar container
      color: 'var(--accent-color, #3b82f6)', // Progress bar color
      backgroundColor: 'var(--accent-color-light, #dbeafe)', // Background color
      animated: true, // Whether to animate progress changes
      showPercentage: false, // Whether to show percentage text
      striped: false, // Whether to show striped pattern
      rounded: true, // Whether to use rounded corners
      liveViewHook: null, // LiveView hook instance if used in a hook
      onComplete: null, // Callback when progress reaches 100%
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      progress: this.options.initialProgress,
      isComplete: this.options.initialProgress >= 100,
      isAnimating: false
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      progressBarContainer: null,
      progressBar: null,
      percentageText: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[ProgressBar:${this.componentId}]`, ...args);
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
    
    // Create progress bar elements
    this._buildDOM();
    
    // Set initial progress
    this._updateProgressBar(this._state.progress);
    
    // Set up LiveView event handlers if in a hook
    if (this.options.liveViewHook) {
      this._setupLiveViewHandlers();
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
    
    // Clear references
    this.elements = {};
    this._state = {};
  }
  
  /**
   * Set the progress value
   * @param {number} value - Progress value (0-100)
   * @returns {this} - For method chaining
   */
  setProgress(value) {
    // Ensure value is between 0 and 100
    const progress = Math.max(0, Math.min(100, value));
    
    // Update state
    const wasComplete = this._state.isComplete;
    this._state.progress = progress;
    this._state.isComplete = progress >= 100;
    
    // Update DOM
    this._updateProgressBar(progress);
    
    // Call onComplete callback if progress just reached 100%
    if (!wasComplete && this._state.isComplete && typeof this.options.onComplete === 'function') {
      this.options.onComplete();
    }
    
    return this;
  }
  
  /**
   * Increment the progress by a specified amount
   * @param {number} amount - Amount to increment (default: 10)
   * @returns {this} - For method chaining
   */
  increment(amount = 10) {
    return this.setProgress(this._state.progress + amount);
  }
  
  /**
   * Reset the progress bar to 0
   * @returns {this} - For method chaining
   */
  reset() {
    return this.setProgress(0);
  }
  
  /**
   * Create the progress bar DOM structure
   * @private
   */
  _buildDOM() {
    // Create progress bar container
    this.elements.progressBarContainer = DOMCleanup.createElement('div', {
      className: 'progress-bar-container',
      id: `${this.componentId}-container`,
      style: {
        width: this.options.width,
        height: this.options.height,
        backgroundColor: this.options.backgroundColor,
        borderRadius: this.options.rounded ? '9999px' : '0',
        overflow: 'hidden',
        position: 'relative'
      }
    }, '', this.cleanup);
    
    // Create progress bar
    this.elements.progressBar = DOMCleanup.createElement('div', {
      className: `progress-bar ${this.options.striped ? 'progress-bar-striped' : ''} ${this.options.animated ? 'progress-bar-animated' : ''}`,
      style: {
        height: '100%',
        width: `${this._state.progress}%`,
        backgroundColor: this.options.color,
        transition: this.options.animated ? 'width 0.3s ease-in-out' : 'none',
        position: 'absolute',
        left: 0,
        top: 0
      }
    }, '', this.cleanup);
    
    // Add progress bar to container
    this.elements.progressBarContainer.appendChild(this.elements.progressBar);
    
    // Create percentage text if needed
    if (this.options.showPercentage) {
      this.elements.percentageText = DOMCleanup.createElement('div', {
        className: 'progress-bar-percentage',
        style: {
          position: 'absolute',
          right: '8px',
          top: '50%',
          transform: 'translateY(-50%)',
          fontSize: '12px',
          fontWeight: 'bold',
          color: 'var(--text-color, #000)'
        }
      }, `${this._state.progress}%`, this.cleanup);
      
      this.elements.progressBarContainer.appendChild(this.elements.percentageText);
    }
    
    // Add to container
    this.elements.container.appendChild(this.elements.progressBarContainer);
  }
  
  /**
   * Update the progress bar display
   * @param {number} progress - Progress value (0-100)
   * @private
   */
  _updateProgressBar(progress) {
    if (this.elements.progressBar) {
      this.elements.progressBar.style.width = `${progress}%`;
    }
    
    if (this.options.showPercentage && this.elements.percentageText) {
      this.elements.percentageText.textContent = `${Math.round(progress)}%`;
    }
    
    // Add/remove complete class
    if (this._state.isComplete) {
      this.elements.progressBarContainer.classList.add('progress-complete');
    } else {
      this.elements.progressBarContainer.classList.remove('progress-complete');
    }
  }
  
  /**
   * Set up LiveView event handlers if used in a hook
   * @private
   */
  _setupLiveViewHandlers() {
    const hook = this.options.liveViewHook;
    this.debug.log('Setting up LiveView event handlers');
    
    // Listen for progress update events from LiveView
    hook.handleEvent('update_progress', ({ progress }) => {
      this.debug.log('LiveView progress update received:', progress);
      this.setProgress(progress);
    });
    
    // Listen for reset event
    hook.handleEvent('reset_progress', () => {
      this.debug.log('LiveView reset event received');
      this.reset();
    });
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const ProgressBar = {
  mounted() {
    this.component = new ProgressBarComponent({
      container: this.el,
      liveViewHook: this,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  updated() {
    // Handle updates if necessary
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  },
  
  handleEvent(event, payload) {
    // Events are handled in the component's _setupLiveViewHandlers method
  }
};

export default ProgressBar;
export { ProgressBarComponent }; 