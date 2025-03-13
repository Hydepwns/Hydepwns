/**
 * ProgressIndicatorComponent
 * -------------------------
 * Component for managing interactive progress indicators including spinners and progress bars.
 * 
 * Features:
 * - Handles animation of progress bars
 * - Manages spinner animations
 * - Updates progress values dynamically
 * - Implements accessibility features
 * - Optimizes performance with intersection observer
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class ProgressIndicatorComponent {
  /**
   * Create a new ProgressIndicator component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `progress-indicator-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      defaultSpinnerFrames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"],
      defaultSpinnerSpeed: 100,
      ...options
    };
    
    // Component state (private)
    this._state = {
      animationAllowed: true, // Will be updated based on user preferences
      inViewport: false, // Whether the element is currently visible
      type: null, // 'spinner' or 'linear'
    };
    
    // DOM element references
    this.elements = {
      container: null,
      spinnerElement: null,
      progressBarElement: null
    };
    
    // Animation timers and handlers
    this.spinnerInterval = null;
    this.progressAnimation = null;
    this.observer = null;
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[ProgressIndicator:${this.componentId}]`, ...args);
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
      console.error('ProgressIndicator component requires a container element');
      return this;
    }
    
    // Check if user prefers reduced motion
    this._state.animationAllowed = !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    
    // Determine the type of progress indicator
    if (this.elements.container.classList.contains('spinner')) {
      this._state.type = 'spinner';
      this._setupSpinner();
    } else if (this.elements.container.classList.contains('linear') && 
               this.elements.container.classList.contains('animate')) {
      this._state.type = 'linear';
      this._setupAnimatedProgressBar();
    }
    
    // Set up intersection observer for performance optimization
    this._setupIntersectionObserver();
    
    this.debug.log('Component mounted', { 
      type: this._state.type, 
      animationAllowed: this._state.animationAllowed 
    });
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
    // Stop any animations
    this._stopSpinnerAnimation();
    
    if (this.progressAnimation) {
      cancelAnimationFrame(this.progressAnimation);
      this.progressAnimation = null;
    }
    
    // Disconnect observer
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
   * Update progress value
   * @param {number} value - New progress value
   * @param {number} max - Maximum progress value
   * @returns {this} - For method chaining
   */
  updateProgress(value, max) {
    if (this._state.type === 'linear' || this.elements.container.classList.contains('circular')) {
      const progressElement = this.elements.container.querySelector('[role="progressbar"]');
      if (progressElement) {
        const currentValue = parseInt(progressElement.getAttribute('aria-valuenow') || '0', 10);
        const maxValue = parseInt(max || progressElement.getAttribute('aria-valuemax') || '100', 10);
        
        // Update aria attributes
        progressElement.setAttribute('aria-valuenow', value);
        progressElement.setAttribute('aria-valuemax', maxValue);
        
        // Animate the change if animation is allowed
        if (this._state.animationAllowed && this._state.inViewport) {
          this._animateProgressBar(currentValue, value, maxValue);
        } else {
          // Just update without animation
          this._updateProgressBar(value, maxValue);
        }
        
        // Dispatch custom event for progress update
        const event = new CustomEvent('progressUpdate', {
          detail: {
            componentId: this.componentId,
            value: value,
            maxValue: maxValue,
            percentage: Math.min(100, Math.round((value / maxValue) * 100))
          },
          bubbles: true
        });
        
        this.elements.container.dispatchEvent(event);
      }
    }
    
    return this;
  }
  
  /**
   * Manually start spinner animation
   * @returns {this} - For method chaining
   */
  startSpinner() {
    if (this._state.type === 'spinner') {
      this._startSpinnerAnimation();
    }
    return this;
  }
  
  /**
   * Manually stop spinner animation
   * @returns {this} - For method chaining
   */
  stopSpinner() {
    if (this._state.type === 'spinner') {
      this._stopSpinnerAnimation();
    }
    return this;
  }
  
  /**
   * Set up spinner animation
   * @private
   */
  _setupSpinner() {
    // Get animation frames and speed from data attributes
    try {
      this.frames = JSON.parse(this.elements.container.dataset.frames || 
                              JSON.stringify(this.options.defaultSpinnerFrames));
      this.speed = parseInt(this.elements.container.dataset.speed || 
                           this.options.defaultSpinnerSpeed, 10);
    } catch (e) {
      console.error('Error parsing spinner frames:', e);
      this.frames = this.options.defaultSpinnerFrames;
      this.speed = this.options.defaultSpinnerSpeed;
    }
    
    // Get the spinner animation element
    this.elements.spinnerElement = this.elements.container.querySelector('.spinner-animation');
    
    this.debug.log('Spinner setup complete', { frames: this.frames, speed: this.speed });
  }
  
  /**
   * Start spinner animation
   * @private
   */
  _startSpinnerAnimation() {
    if (!this.elements.spinnerElement || !this._state.inViewport) return;
    
    // Stop any existing animation
    this._stopSpinnerAnimation();
    
    let frameIndex = 0;
    
    // Set up animation interval
    this.spinnerInterval = setInterval(() => {
      if (!this._state.inViewport) return;
      
      // Update spinner with next frame
      this.elements.spinnerElement.textContent = this.frames[frameIndex];
      
      // Increment frame index and loop back to start if needed
      frameIndex = (frameIndex + 1) % this.frames.length;
    }, this.speed);
    
    this.debug.log('Spinner animation started');
  }
  
  /**
   * Stop spinner animation
   * @private
   */
  _stopSpinnerAnimation() {
    if (this.spinnerInterval) {
      clearInterval(this.spinnerInterval);
      this.spinnerInterval = null;
      
      this.debug.log('Spinner animation stopped');
    }
  }
  
  /**
   * Set up animated progress bar
   * @private
   */
  _setupAnimatedProgressBar() {
    if (!this._state.animationAllowed) return;
    
    // Get the progress bar element
    this.elements.progressBarElement = this.elements.container.querySelector('.progress-bar');
    
    if (!this.elements.progressBarElement) {
      this.elements.progressBarElement = this.elements.container.querySelector('[role="progressbar"]');
    }
    
    if (this.elements.progressBarElement) {
      // Get current progress value
      const valueNow = parseInt(this.elements.progressBarElement.getAttribute('aria-valuenow') || '0', 10);
      const valueMax = parseInt(this.elements.progressBarElement.getAttribute('aria-valuemax') || '100', 10);
      
      // Animate from 0 to current value
      this._animateProgressBar(0, valueNow, valueMax);
      
      this.debug.log('Animated progress bar setup complete', { 
        initialValue: valueNow, 
        maxValue: valueMax 
      });
    }
  }
  
  /**
   * Animate progress bar from start to end value
   * @param {number} startValue - Starting progress value
   * @param {number} endValue - Ending progress value
   * @param {number} maxValue - Maximum progress value
   * @private
   */
  _animateProgressBar(startValue, endValue, maxValue) {
    if (!this.elements.progressBarElement || !this._state.inViewport) return;
    
    // Calculate animation duration based on the difference
    const difference = Math.abs(endValue - startValue);
    const duration = Math.min(1500, Math.max(500, difference * 20)); // Between 500ms and 1500ms
    const startTime = performance.now();
    
    // Clear any existing animation
    if (this.progressAnimation) {
      cancelAnimationFrame(this.progressAnimation);
    }
    
    // Animation function
    const animate = (currentTime) => {
      // Calculate progress of the animation (0 to 1)
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);
      
      // Calculate current value using easing function
      const currentValue = startValue + (endValue - startValue) * this._easeOutQuad(progress);
      
      // Update progress bar
      this._updateProgressBar(Math.round(currentValue), maxValue);
      
      // Continue animation if not complete
      if (progress < 1) {
        this.progressAnimation = requestAnimationFrame(animate);
      } else {
        this.progressAnimation = null;
      }
    };
    
    // Start animation
    this.progressAnimation = requestAnimationFrame(animate);
    
    this.debug.log('Progress bar animation started', { 
      startValue, 
      endValue, 
      duration 
    });
  }
  
  /**
   * Update progress bar with new value
   * @param {number} value - New progress value
   * @param {number} maxValue - Maximum progress value
   * @private
   */
  _updateProgressBar(value, maxValue) {
    if (!this.elements.progressBarElement) return;
    
    // Calculate percentage
    const percentage = Math.min(100, Math.round((value / maxValue) * 100));
    
    // Update aria attributes
    this.elements.progressBarElement.setAttribute('aria-valuenow', value);
    
    // Find the text content to update
    const textNode = Array.from(this.elements.progressBarElement.childNodes)
      .find(node => node.nodeType === Node.TEXT_NODE);
    
    if (textNode) {
      // Update percentage text
      textNode.nodeValue = textNode.nodeValue.replace(/\d+%/, `${percentage}%`);
    }
    
    // Update progress bar visually
    // This depends on the specific implementation, but typically involves
    // updating the width of a filled area or the number of filled characters
    const filledChars = this.elements.progressBarElement.textContent.match(/\[([^\]]+)\]/);
    if (filledChars && filledChars[1]) {
      const totalWidth = filledChars[1].length;
      const filledWidth = Math.round((percentage / 100) * totalWidth);
      
      // Get the characters used for filled and empty
      const filledChar = filledChars[1].charAt(0);
      const emptyChar = filledChars[1].charAt(filledChars[1].length - 1);
      
      // Create new progress bar string
      const newBar = `[${filledChar.repeat(filledWidth)}${emptyChar.repeat(totalWidth - filledWidth)}] ${percentage}%`;
      
      // Update the progress bar text
      this.elements.progressBarElement.textContent = newBar;
      
      this.debug.log('Progress bar updated', { value, percentage, filledWidth });
    }
  }
  
  /**
   * Easing function for smoother animation
   * @param {number} t - Progress value between 0 and 1
   * @returns {number} - Eased value between 0 and 1
   * @private
   */
  _easeOutQuad(t) {
    return t * (2 - t);
  }
  
  /**
   * Set up intersection observer to only animate when visible
   * @private
   */
  _setupIntersectionObserver() {
    if ('IntersectionObserver' in window) {
      const options = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1
      };
      
      this.observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          const wasInViewport = this._state.inViewport;
          this._state.inViewport = entry.isIntersecting;
          
          if (entry.isIntersecting) {
            // Element is visible
            this.debug.log('Component entered viewport');
            
            // Start spinner animation if this is a spinner
            if (this._state.type === 'spinner' && this._state.animationAllowed) {
              this._startSpinnerAnimation();
            }
            
            // Dispatch custom event for visibility change
            if (!wasInViewport) {
              const event = new CustomEvent('progressVisibilityChange', {
                detail: {
                  componentId: this.componentId,
                  visible: true
                },
                bubbles: true
              });
              
              this.elements.container.dispatchEvent(event);
            }
          } else {
            // Element is not visible
            this.debug.log('Component left viewport');
            
            // Stop spinner animation to save resources
            if (this._state.type === 'spinner') {
              this._stopSpinnerAnimation();
            }
            
            // Dispatch custom event for visibility change
            if (wasInViewport) {
              const event = new CustomEvent('progressVisibilityChange', {
                detail: {
                  componentId: this.componentId,
                  visible: false
                },
                bubbles: true
              });
              
              this.elements.container.dispatchEvent(event);
            }
          }
        });
      }, options);
      
      // Add observer to cleanup registry
      this.cleanup.addCleanupFunction(() => {
        if (this.observer) {
          this.observer.disconnect();
          this.observer = null;
        }
      });
      
      // Observe the element
      this.observer.observe(this.elements.container);
      
      this.debug.log('Intersection observer setup complete');
    }
  }
}

export { ProgressIndicatorComponent }; 