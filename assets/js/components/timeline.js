/**
 * TimelineComponent
 * ----------------
 * Component for managing interactive monospace timeline.
 * 
 * Features:
 * - Handles animation of timeline elements
 * - Supports keyboard navigation between timeline events
 * - Implements accessibility features
 * - Optimizes performance with IntersectionObserver
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class TimelineComponent {
  /**
   * Create a new Timeline component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `timeline-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      animationEnabled: true, // Enable animations
      ...options
    };
    
    // Component state (private)
    this._state = {
      animationAllowed: true, // Will be updated based on user preferences
      inViewport: false, // Whether the element is currently visible
      isVertical: false, // Whether the timeline is vertical or horizontal
      hasAnimated: false, // Whether the animation has played once
    };
    
    // DOM element references
    this.elements = {
      container: null,
      timelineItems: [] // Timeline items (either .timeline-item or .timeline-event)
    };
    
    // Resource management
    this.observer = null;
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[Timeline:${this.componentId}]`, ...args);
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
      console.error('Timeline component requires a container element');
      return this;
    }
    
    // Check if user prefers reduced motion
    this._state.animationAllowed = this.options.animationEnabled && 
                                  !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    
    // Determine orientation
    this._state.isVertical = this.elements.container.classList.contains('vertical');
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Set up intersection observer for performance optimization
    this._setupIntersectionObserver();
    
    // Initialize animation if allowed
    if (this._state.animationAllowed) {
      this._animateTimelineItems();
    }
    
    // Add keyboard navigation for accessibility
    this._setupKeyboardNavigation();
    
    this.debug.log('Component mounted', { 
      isVertical: this._state.isVertical, 
      animationAllowed: this._state.animationAllowed 
    });
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
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
   * Focus a specific timeline item
   * @param {number} index - Index of the timeline item to focus
   * @returns {this} - For method chaining
   */
  focusItem(index) {
    this._focusTimelineItem(index);
    return this;
  }
  
  /**
   * Replay the animation sequence
   * @returns {this} - For method chaining
   */
  replayAnimation() {
    this._replayAnimation();
    return this;
  }
  
  /**
   * Get the number of timeline items
   * @returns {number} - Number of timeline items
   */
  getItemCount() {
    return this.elements.timelineItems.length;
  }
  
  /**
   * Set up event listeners
   * @private
   */
  _setupEventListeners() {
    // Listen for keyboard events to replay animations
    this.events.addEventListener(
      window,
      'keydown',
      this._handleKeydown.bind(this)
    );
    
    // Find timeline items
    const timelineItems = this._state.isVertical 
      ? this.elements.container.querySelectorAll('.timeline-item')
      : this.elements.container.querySelectorAll('.timeline-event');
    
    // Store reference to items
    this.elements.timelineItems = Array.from(timelineItems);
    
    // Add click event listeners to timeline items
    this.elements.timelineItems.forEach((item, index) => {
      this.events.addEventListener(
        item,
        'click',
        () => {
          this._focusTimelineItem(index);
          
          // Dispatch custom event for item click
          const event = new CustomEvent('timelineItemClick', {
            detail: {
              componentId: this.componentId,
              index: index,
              element: item
            },
            bubbles: true
          });
          
          this.elements.container.dispatchEvent(event);
        }
      );
      
      // Set tabindex for keyboard accessibility
      item.setAttribute('tabindex', '0');
    });
    
    this.debug.log('Event listeners set up', { itemCount: this.elements.timelineItems.length });
  }
  
  /**
   * Handle keyboard events
   * @param {KeyboardEvent} event - Keyboard event
   * @private
   */
  _handleKeydown(event) {
    // Use Alt+R as keyboard shortcut to replay animations
    if (event.altKey && event.key === 'r') {
      this._replayAnimation();
      event.preventDefault();
    }
  }
  
  /**
   * Set up keyboard navigation
   * @private
   */
  _setupKeyboardNavigation() {
    // Add keyboard navigation for each timeline item
    this.elements.timelineItems.forEach((item, index) => {
      this.events.addEventListener(
        item,
        'keydown',
        (event) => {
          // Handle arrow key navigation
          if (this._state.isVertical) {
            // Vertical timeline: up/down navigation
            if (event.key === 'ArrowDown' && index < this.elements.timelineItems.length - 1) {
              this._focusTimelineItem(index + 1);
              event.preventDefault();
            } else if (event.key === 'ArrowUp' && index > 0) {
              this._focusTimelineItem(index - 1);
              event.preventDefault();
            }
          } else {
            // Horizontal timeline: left/right navigation
            if (event.key === 'ArrowRight' && index < this.elements.timelineItems.length - 1) {
              this._focusTimelineItem(index + 1);
              event.preventDefault();
            } else if (event.key === 'ArrowLeft' && index > 0) {
              this._focusTimelineItem(index - 1);
              event.preventDefault();
            }
          }
          
          // Handle Enter/Space to activate item
          if (event.key === 'Enter' || event.key === ' ') {
            // Trigger click event
            item.click();
            event.preventDefault();
          }
        }
      );
    });
    
    this.debug.log('Keyboard navigation set up');
  }
  
  /**
   * Focus a specific timeline item
   * @param {number} index - Index of the timeline item to focus
   * @private
   */
  _focusTimelineItem(index) {
    if (index >= 0 && index < this.elements.timelineItems.length) {
      this.elements.timelineItems[index].focus();
      
      // Scroll item into view if needed
      this.elements.timelineItems[index].scrollIntoView({
        behavior: 'smooth',
        block: 'nearest'
      });
      
      // Dispatch custom event for navigation
      const event = new CustomEvent('timelineNavigation', {
        detail: {
          componentId: this.componentId,
          index: index,
          element: this.elements.timelineItems[index]
        },
        bubbles: true
      });
      
      this.elements.container.dispatchEvent(event);
      
      this.debug.log('Timeline item focused', { index });
    }
  }
  
  /**
   * Animate timeline items with staggered delay
   * @private
   */
  _animateTimelineItems() {
    if (!this._state.animationAllowed || !this._state.inViewport) return;
    
    this.elements.timelineItems.forEach((item, index) => {
      // Reset animation
      item.style.opacity = '0';
      item.style.transform = this._state.isVertical 
        ? 'translateX(-10px)' 
        : 'translateY(10px)';
      
      // Apply animation with staggered delay
      setTimeout(() => {
        item.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
        item.style.opacity = '1';
        item.style.transform = 'translate(0, 0)';
      }, 100 + (index * 150));
    });
    
    this.debug.log('Timeline items animated');
  }
  
  /**
   * Replay the animation
   * @private
   */
  _replayAnimation() {
    if (!this._state.animationAllowed || !this._state.inViewport) return;
    
    // Reset all animations
    this.elements.timelineItems.forEach(item => {
      item.style.transition = 'none';
      item.style.opacity = '0';
      item.style.transform = this._state.isVertical 
        ? 'translateX(-10px)' 
        : 'translateY(10px)';
      
      // Force reflow
      void item.offsetWidth;
    });
    
    // Reapply animations with staggered delay
    requestAnimationFrame(() => {
      this._animateTimelineItems();
    });
    
    // Dispatch custom event for animation replay
    const event = new CustomEvent('timelineAnimationReplay', {
      detail: {
        componentId: this.componentId
      },
      bubbles: true
    });
    
    this.elements.container.dispatchEvent(event);
    
    this.debug.log('Animation replayed');
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
            // Element is visible, ensure animation plays
            this.debug.log('Component entered viewport');
            
            // Trigger animation when element becomes visible
            if (this._state.animationAllowed && !this._state.hasAnimated) {
              this._animateTimelineItems();
              this._state.hasAnimated = true;
            }
            
            // Dispatch custom event for visibility change
            if (!wasInViewport) {
              const event = new CustomEvent('timelineVisibilityChange', {
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
            
            // Dispatch custom event for visibility change
            if (wasInViewport) {
              const event = new CustomEvent('timelineVisibilityChange', {
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

export { TimelineComponent }; 