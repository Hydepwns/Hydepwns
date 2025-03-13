/**
 * Animation Components
 * 
 * Provides various text and grid-based animations that respect the monospace grid
 * with performance optimizations using requestAnimationFrame and respect for 
 * user's preferred reduced motion settings.
 * 
 * Implements the robust component pattern with proper isolation and cleanup.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

/**
 * Utility function to check if user prefers reduced motion
 * @returns {boolean} Whether reduced motion is preferred
 */
const prefersReducedMotion = () => {
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
};

/**
 * Character Animation Component
 * Handles text-based animations like typewriter and character fading
 */
class CharacterAnimationComponent {
  /**
   * Create a new CharacterAnimation component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `char-animation-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: document.body,
      element: null,
      animationType: 'typewriter', // typewriter, char-fade
      replayKey: 'r',
      replayModifier: 'alt',
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      animationAllowed: !prefersReducedMotion(),
      inViewport: false,
      originalText: ''
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      root: null,
      spans: []
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug) {
          console.log(`[CharAnimation:${this.componentId}]`, ...args);
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
    
    // Store reference to elements
    this.elements.container = this.options.container;
    this.elements.root = this.options.element || this.elements.container;
    
    this.debug.log('Mounting animation component', this.elements.root);
    
    // Determine animation type if not specified
    if (!this.options.animationType) {
      if (this.elements.root.classList.contains('typewriter')) {
        this.options.animationType = 'typewriter';
      } else if (this.elements.root.classList.contains('char-fade')) {
        this.options.animationType = 'char-fade';
      }
    }
    
    // Setup the appropriate animation
    if (this.options.animationType === 'typewriter') {
      this._setupTypewriter();
    } else if (this.options.animationType === 'char-fade') {
      this._setupCharFade();
    }
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Setup intersection observer for performance
    this._setupIntersectionObserver();
    
    return this;
  }
  
  /**
   * Remove the component and clean up resources
   */
  destroy() {
    this.debug.log('Destroying animation component');
    
    // Clean up DOM elements and event listeners
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    // Unregister from event manager
    if (this.events) {
      EventManager.unregisterComponent(this.componentId);
    }
    
    // Disconnect intersection observer
    if (this.observer) {
      this.observer.disconnect();
    }
    
    // Clear references
    this.elements = {};
  }
  
  /**
   * Replay the animation
   * @returns {this} - For method chaining
   */
  replay() {
    if (!this._state.animationAllowed || !this._state.inViewport) {
      this.debug.log('Animation replay skipped - not allowed or not in viewport');
      return this;
    }
    
    this.debug.log('Replaying animation', this.options.animationType);
    
    if (this.options.animationType === 'typewriter') {
      this._replayTypewriter();
    } else if (this.options.animationType === 'char-fade') {
      this._replayCharFade();
    }
    
    return this;
  }
  
  /**
   * Set up event listeners for the component
   * @private
   */
  _setupEventListeners() {
    // Listen for keyboard events to replay animations
    this.events.addEventListener(window, 'keydown', this._handleKeydown.bind(this));
  }
  
  /**
   * Handle keyboard event for animation replay
   * @param {KeyboardEvent} event - The keyboard event
   * @private
   */
  _handleKeydown(event) {
    // Check if the replay key combination was pressed
    if ((this.options.replayModifier === 'alt' && event.altKey) ||
        (this.options.replayModifier === 'ctrl' && event.ctrlKey) ||
        (this.options.replayModifier === 'shift' && event.shiftKey)) {
      if (event.key.toLowerCase() === this.options.replayKey.toLowerCase()) {
        this.replay();
        event.preventDefault();
      }
    }
  }
  
  /**
   * Setup intersection observer to only animate when visible
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
          if (entry.isIntersecting) {
            // Element is visible
            this._state.inViewport = true;
            this.debug.log('Element in viewport');
          } else {
            // Element is not visible
            this._state.inViewport = false;
            this.debug.log('Element outside viewport');
          }
        });
      }, options);
      
      this.observer.observe(this.elements.root);
      
      // Register cleanup function
      this.cleanup.registerCleanupFunction(() => {
        if (this.observer) {
          this.observer.disconnect();
        }
      });
    }
  }
  
  /**
   * Setup typewriter animation
   * @private
   */
  _setupTypewriter() {
    const text = this.elements.root.textContent.trim();
    this._state.originalText = text;
    const charCount = text.length;
    
    // Ensure a minimum character count for very short text
    const minCharCount = Math.max(charCount, 10);
    
    this.elements.root.style.setProperty('--char-count', minCharCount);
    
    // Make sure the animation can complete
    if (this.elements.root.style.width === '0px') {
      this.elements.root.style.width = '0';
    }
    
    // If reduced motion is preferred, just show the text without animation
    if (!this._state.animationAllowed) {
      this.elements.root.style.width = '100%';
      this.elements.root.style.animation = 'none';
    }
  }
  
  /**
   * Setup character fade-in animation
   * @private
   */
  _setupCharFade() {
    const text = this.elements.root.textContent;
    this._state.originalText = text;
    const fragment = document.createDocumentFragment();
    
    // Clear original content
    this.elements.root.textContent = '';
    
    // Create span for each character with staggered animation delay
    for (let i = 0; i < text.length; i++) {
      const span = DOMCleanup.createElement('span', {}, '', this.cleanup);
      
      // Preserve whitespace by using non-breaking space for space characters
      if (text[i] === ' ') {
        span.innerHTML = '&nbsp;';
      } else {
        span.textContent = text[i];
      }
      
      if (this._state.animationAllowed) {
        span.style.animationDelay = `${i * 0.05}s`;
      } else {
        span.style.opacity = 1; // Immediately visible if reduced motion is preferred
        span.style.animation = 'none';
      }
      
      fragment.appendChild(span);
      this.elements.spans.push(span);
    }
    
    // Add all spans at once for better performance
    this.elements.root.appendChild(fragment);
  }
  
  /**
   * Replay typewriter animation
   * @private
   */
  _replayTypewriter() {
    // Remove existing animation
    this.elements.root.style.animation = 'none';
    
    // Force reflow
    void this.elements.root.offsetWidth;
    
    // Restart animation
    this.elements.root.style.width = '0';
    
    requestAnimationFrame(() => {
      this.elements.root.style.animation = `
        typewriter 3.5s steps(var(--char-count, 20)) 0.5s 1 forwards,
        typewriter-cursor-blink 0.8s step-end infinite
      `;
    });
  }
  
  /**
   * Replay character fade-in animation
   * @private
   */
  _replayCharFade() {
    // Reset opacity and animation for all spans
    this.elements.spans.forEach((span, i) => {
      span.style.opacity = 0;
      span.style.animation = 'none';
      
      // Force reflow
      void span.offsetWidth;
      
      // Apply new animation with requestAnimationFrame
      requestAnimationFrame(() => {
        span.style.animation = 'char-fade-in 0.1s ease-in-out forwards';
        span.style.animationDelay = `${i * 0.05}s`;
      });
    });
  }
}

/**
 * Grid Fade-in Animation Component
 * Handles grid-based fade-in animations for sections
 */
class GridFadeInComponent {
  /**
   * Create a new GridFadeIn component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `grid-fade-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: document.body,
      element: null,
      replayKey: 'r',
      replayModifier: 'alt',
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      animationAllowed: !prefersReducedMotion(),
      inViewport: false,
      lineCount: 0
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      root: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug) {
          console.log(`[GridFade:${this.componentId}]`, ...args);
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
    
    // Store reference to elements
    this.elements.container = this.options.container;
    this.elements.root = this.options.element || this.elements.container;
    
    this.debug.log('Mounting grid fade component', this.elements.root);
    
    // Calculate line count based on element height and line-height variable
    const lineHeight = parseFloat(
      getComputedStyle(document.documentElement)
        .getPropertyValue('--line-height')
    );
    
    this._state.lineCount = Math.ceil(this.elements.root.offsetHeight / lineHeight);
    this.elements.root.style.setProperty('--line-count', this._state.lineCount);
    
    // If reduced motion is preferred, just show the content without animation
    if (!this._state.animationAllowed) {
      this.elements.root.style.animation = 'none';
      this.elements.root.style.clipPath = 'none';
    }
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Setup intersection observer for performance
    this._setupIntersectionObserver();
    
    return this;
  }
  
  /**
   * Remove the component and clean up resources
   */
  destroy() {
    this.debug.log('Destroying grid fade component');
    
    // Clean up DOM elements and event listeners
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    // Unregister from event manager
    if (this.events) {
      EventManager.unregisterComponent(this.componentId);
    }
    
    // Disconnect intersection observer
    if (this.observer) {
      this.observer.disconnect();
    }
    
    // Clear references
    this.elements = {};
  }
  
  /**
   * Replay the animation
   * @returns {this} - For method chaining
   */
  replay() {
    if (!this._state.animationAllowed || !this._state.inViewport) {
      this.debug.log('Animation replay skipped - not allowed or not in viewport');
      return this;
    }
    
    this.debug.log('Replaying grid fade animation');
    
    // Remove existing animation
    this.elements.root.style.animation = 'none';
    
    // Force reflow
    void this.elements.root.offsetWidth;
    
    // Restart animation with requestAnimationFrame
    requestAnimationFrame(() => {
      this.elements.root.style.animation = 'grid-fade 0.5s steps(var(--line-count, 10)) forwards';
    });
    
    return this;
  }
  
  /**
   * Set up event listeners for the component
   * @private
   */
  _setupEventListeners() {
    // Listen for keyboard events to replay animations
    this.events.addEventListener(window, 'keydown', this._handleKeydown.bind(this));
  }
  
  /**
   * Handle keyboard event for animation replay
   * @param {KeyboardEvent} event - The keyboard event
   * @private
   */
  _handleKeydown(event) {
    // Check if the replay key combination was pressed
    if ((this.options.replayModifier === 'alt' && event.altKey) ||
        (this.options.replayModifier === 'ctrl' && event.ctrlKey) ||
        (this.options.replayModifier === 'shift' && event.shiftKey)) {
      if (event.key.toLowerCase() === this.options.replayKey.toLowerCase()) {
        this.replay();
        event.preventDefault();
      }
    }
  }
  
  /**
   * Setup intersection observer to only animate when visible
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
          if (entry.isIntersecting) {
            // Element is visible
            this._state.inViewport = true;
            this.debug.log('Element in viewport');
          } else {
            // Element is not visible
            this._state.inViewport = false;
            this.debug.log('Element outside viewport');
          }
        });
      }, options);
      
      this.observer.observe(this.elements.root);
      
      // Register cleanup function
      this.cleanup.registerCleanupFunction(() => {
        if (this.observer) {
          this.observer.disconnect();
        }
      });
    }
  }
}

/**
 * Legacy LiveView Hook for CharacterAnimation
 * For backward compatibility
 */
const CharacterAnimation = {
  mounted() {
    this.animation = new CharacterAnimationComponent({
      element: this.el,
      animationType: this.el.classList.contains('typewriter') ? 'typewriter' : 'char-fade',
      debug: false
    }).mount();
  },
  
  destroyed() {
    if (this.animation) {
      this.animation.destroy();
      this.animation = null;
    }
  }
};

/**
 * Legacy LiveView Hook for GridFadeIn
 * For backward compatibility
 */
const GridFadeIn = {
  mounted() {
    this.animation = new GridFadeInComponent({
      element: this.el,
      debug: false
    }).mount();
  },
  
  destroyed() {
    if (this.animation) {
      this.animation.destroy();
      this.animation = null;
    }
  }
};

export { CharacterAnimation, GridFadeIn, CharacterAnimationComponent, GridFadeInComponent }; 