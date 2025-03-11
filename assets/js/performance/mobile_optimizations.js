/**
 * Mobile Performance Optimizations
 * 
 * This module contains optimizations specifically targeted at mobile devices,
 * including lazy loading, deferred execution, and touch interaction improvements.
 */

const MobilePerformance = {
  /**
   * Initialize mobile performance optimizations
   */
  init() {
    // Only apply mobile optimizations on small devices
    if (this.isMobileDevice()) {
      this.setupLazyLoading();
      this.deferNonEssentialJS();
      this.optimizeEventListeners();
      this.setupIntersectionObserver();
      
      // Add mobile device class to body for CSS optimizations
      document.body.classList.add('mobile-device');
      
      // Apply appropriate optimizations based on device capability
      this.applyDeviceSpecificOptimizations();
    }
  },

  /**
   * Check if the current device is a mobile device
   * 
   * @returns {boolean} True if the device is a mobile device
   */
  isMobileDevice() {
    return (window.innerWidth <= 768) || 
           (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent));
  },

  /**
   * Setup lazy loading for images and other content
   */
  setupLazyLoading() {
    // Find all images with data-src attribute
    const lazyImages = document.querySelectorAll('img[data-src]');
    
    lazyImages.forEach(img => {
      // Replace src with a tiny placeholder if not already done
      if (!img.src || img.src !== img.getAttribute('data-placeholder')) {
        img.src = img.getAttribute('data-placeholder') || 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"%3E%3C/svg%3E';
      }
      
      // Add loading="lazy" attribute for native lazy loading
      img.setAttribute('loading', 'lazy');
    });
    
    // Find iframes that should be lazy loaded
    const lazyIframes = document.querySelectorAll('iframe[data-src]');
    
    lazyIframes.forEach(iframe => {
      iframe.setAttribute('loading', 'lazy');
    });
  },

  /**
   * Defer non-essential JavaScript execution
   */
  deferNonEssentialJS() {
    // Create a queue for deferred functions
    window.deferredFunctions = window.deferredFunctions || [];
    
    // Execute deferred functions after initial page load
    window.addEventListener('load', () => {
      setTimeout(() => {
        this.executeDeferredFunctions();
      }, 1000); // Delay by 1 second after load
    });
  },

  /**
   * Execute deferred functions from the queue
   */
  executeDeferredFunctions() {
    if (window.deferredFunctions && window.deferredFunctions.length) {
      // Execute functions in the queue
      while (window.deferredFunctions.length) {
        const fn = window.deferredFunctions.shift();
        try {
          fn();
        } catch (e) {
          console.error('Error executing deferred function:', e);
        }
      }
    }
  },

  /**
   * Optimize event listeners for mobile performance
   */
  optimizeEventListeners() {
    // Use passive event listeners where appropriate
    const passiveEvents = ['touchstart', 'touchmove', 'scroll', 'wheel'];
    
    // Override addEventListener to make events passive by default where appropriate
    const originalAddEventListener = EventTarget.prototype.addEventListener;
    EventTarget.prototype.addEventListener = function(type, listener, options) {
      let newOptions = options;
      
      // If this is a passive-beneficial event and options doesn't specify passive
      if (passiveEvents.includes(type)) {
        if (options === undefined || options === false || options === true) {
          newOptions = {
            passive: true,
            capture: options === true
          };
        } else if (options && typeof options === 'object' && options.passive === undefined) {
          newOptions = {
            ...options,
            passive: true
          };
        }
      }
      
      return originalAddEventListener.call(this, type, listener, newOptions);
    };
    
    // Debounce scroll and resize events
    this.setupDebouncing();
  },

  /**
   * Setup debouncing for expensive events
   */
  setupDebouncing() {
    // Create a debounce function
    const debounce = (func, delay) => {
      let timeout;
      return function() {
        const context = this;
        const args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(context, args), delay);
      };
    };
    
    // Save original window event handlers
    const originalResize = window.onresize;
    const originalScroll = window.onscroll;
    
    // Override with debounced versions
    if (typeof originalResize === 'function') {
      window.onresize = debounce(originalResize, 150);
    }
    
    if (typeof originalScroll === 'function') {
      window.onscroll = debounce(originalScroll, 100);
    }
  },

  /**
   * Setup intersection observer for lazy loading
   */
  setupIntersectionObserver() {
    if ('IntersectionObserver' in window) {
      const observerOptions = {
        root: null,
        rootMargin: '100px', // Load when within 100px of viewport
        threshold: 0.1 // Trigger when at least 10% visible
      };
      
      const observer = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const element = entry.target;
            
            // Handle different element types
            if (element.tagName === 'IMG' && element.dataset.src) {
              // Load image
              element.src = element.dataset.src;
              element.onload = () => element.classList.add('loaded');
              
              // Remove from observation
              observer.unobserve(element);
            } else if (element.classList.contains('defer-load')) {
              // Execute any deferred loading logic
              element.classList.add('loaded');
              element.classList.remove('defer-load');
              
              // Trigger custom event for deferred content
              element.dispatchEvent(new CustomEvent('content:loaded'));
              
              // Remove from observation
              observer.unobserve(element);
            }
          }
        });
      }, observerOptions);
      
      // Observe images with data-src
      document.querySelectorAll('img[data-src]').forEach(img => {
        observer.observe(img);
      });
      
      // Observe elements with defer-load class
      document.querySelectorAll('.defer-load').forEach(el => {
        observer.observe(el);
      });
    }
  },

  /**
   * Apply device-specific optimizations based on capabilities
   */
  applyDeviceSpecificOptimizations() {
    // Check for low memory devices
    const isLowMemoryDevice = navigator.deviceMemory && navigator.deviceMemory <= 4;
    
    if (isLowMemoryDevice) {
      // Reduce animations and effects for low memory devices
      document.body.classList.add('reduce-animations');
      
      // Limit concurrent operations
      this.limitConcurrentOperations();
    }
    
    // Check for slow CPU
    const isSlowCPU = navigator.hardwareConcurrency && navigator.hardwareConcurrency <= 4;
    
    if (isSlowCPU) {
      // Apply optimizations for slower CPUs
      document.body.classList.add('optimize-cpu');
      
      // Reduce JavaScript workload
      this.throttleExpensiveOperations();
    }
    
    // Check for data-saver mode
    const isDataSaverEnabled = navigator.connection && 
                              navigator.connection.saveData === true;
    
    if (isDataSaverEnabled) {
      // Apply optimizations for data saving
      document.body.classList.add('data-saver');
      
      // Prevent loading of non-essential resources
      this.enableDataSaverMode();
    }
  },

  /**
   * Limit concurrent operations for low memory devices
   */
  limitConcurrentOperations() {
    // Implement queue for operations
    window.operationQueue = [];
    window.maxConcurrentOperations = 2;
    window.runningOperations = 0;
    
    // Create operation queue handler
    window.queueOperation = function(operation) {
      return new Promise((resolve, reject) => {
        const wrappedOperation = async () => {
          try {
            window.runningOperations++;
            const result = await operation();
            resolve(result);
          } catch (error) {
            reject(error);
          } finally {
            window.runningOperations--;
            processQueue();
          }
        };
        
        window.operationQueue.push(wrappedOperation);
        processQueue();
      });
    };
    
    function processQueue() {
      if (window.operationQueue.length === 0) return;
      if (window.runningOperations >= window.maxConcurrentOperations) return;
      
      const operation = window.operationQueue.shift();
      operation();
    }
  },

  /**
   * Throttle expensive operations for CPU-constrained devices
   */
  throttleExpensiveOperations() {
    // Reduce animation frame rate
    window.requestAnimationFrame = (() => {
      const originalRequestAnimationFrame = window.requestAnimationFrame;
      const targetFPS = 30; // Target 30fps instead of 60fps
      const interval = 1000 / targetFPS;
      let lastTime = 0;
      
      return function(callback) {
        const currentTime = performance.now();
        const timeUntilNextFrame = Math.max(0, interval - (currentTime - lastTime));
        
        if (timeUntilNextFrame === 0) {
          lastTime = currentTime;
          return originalRequestAnimationFrame(callback);
        } else {
          return setTimeout(() => {
            lastTime = performance.now();
            callback(lastTime);
          }, timeUntilNextFrame);
        }
      };
    })();
  },

  /**
   * Enable data-saver mode for users with limited data
   */
  enableDataSaverMode() {
    // Don't load non-essential images
    document.querySelectorAll('img[data-nonessential="true"]').forEach(img => {
      // Replace with placeholder
      img.src = img.getAttribute('data-placeholder') || 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"%3E%3C/svg%3E';
      
      // Add data-saver indicator
      img.setAttribute('data-saver-mode', 'active');
      
      // Add click handler to load on demand
      img.addEventListener('click', function() {
        if (this.getAttribute('data-src')) {
          this.src = this.getAttribute('data-src');
          this.removeAttribute('data-saver-mode');
        }
      });
    });
  }
};

// Initialize performance optimizations when DOM content is loaded
document.addEventListener('DOMContentLoaded', () => {
  MobilePerformance.init();
});

export default MobilePerformance; 