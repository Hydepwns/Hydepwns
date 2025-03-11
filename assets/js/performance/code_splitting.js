/**
 * Code Splitting and Dynamic Import Handler
 * 
 * This module handles dynamic imports and code splitting for better
 * performance on mobile devices by loading only what's needed.
 */

const CodeSplitting = {
  /**
   * Initialize code splitting functionality
   */
  init() {
    // Create a registry of module loaders
    this.moduleRegistry = {};
    this.loadedModules = {};

    // Register core modules that can be dynamically loaded
    this.registerCoreModules();

    // Set up observers to load modules when components become visible
    this.setupLazyModuleLoading();
  },

  /**
   * Register core modules that can be dynamically loaded
   */
  registerCoreModules() {
    // Terminal module
    this.registerModule('terminal', () => import('../hooks/terminal'));

    // ASCII art generator module
    this.registerModule('ascii-art', () => import('../hooks/ascii_art_generator'));

    // Grid playground module
    this.registerModule('grid', () => import('../hooks/grid_playground'));

    // Animation modules
    this.registerModule('animations', () => import('../hooks/animations'));

    // Visualization modules
    this.registerModule('visualizations', () => import('../hooks/visualizations'));

    // Charts and diagrams
    this.registerModule('charts', () => import('../hooks/charts'));
  },

  /**
   * Register a module that can be dynamically loaded
   * 
   * @param {string} name - Module name
   * @param {Function} loaderFn - Function that returns a dynamic import
   */
  registerModule(name, loaderFn) {
    this.moduleRegistry[name] = loaderFn;
  },

  /**
   * Load a module by name
   * 
   * @param {string} name - Module name to load
   * @returns {Promise} Promise that resolves to the loaded module
   */
  async loadModule(name) {
    // If already loaded, return from cache
    if (this.loadedModules[name]) {
      return this.loadedModules[name];
    }

    // Check if module is registered
    if (!this.moduleRegistry[name]) {
      console.error(`Module '${name}' is not registered for dynamic loading`);
      return null;
    }

    try {
      // Load the module
      const module = await this.moduleRegistry[name]();
      
      // Cache the loaded module
      this.loadedModules[name] = module;
      
      console.log(`Module '${name}' loaded successfully`);
      return module;
    } catch (error) {
      console.error(`Failed to load module '${name}':`, error);
      return null;
    }
  },

  /**
   * Set up observers to lazy load modules when components become visible
   */
  setupLazyModuleLoading() {
    if (!('IntersectionObserver' in window)) {
      // Fallback for browsers without IntersectionObserver
      this.loadAllEssentialModules();
      return;
    }

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const element = entry.target;
          const moduleName = element.dataset.module;
          
          if (moduleName) {
            this.loadModule(moduleName)
              .then(module => {
                if (module && typeof module.initElement === 'function') {
                  module.initElement(element);
                }
                
                // Stop observing this element
                observer.unobserve(element);
              });
          }
        }
      });
    }, {
      rootMargin: '100px', // Load when within 100px of viewport
      threshold: 0.1 // Trigger when at least 10% visible
    });

    // Observe all elements with data-module attribute
    document.querySelectorAll('[data-module]').forEach(element => {
      observer.observe(element);
    });
  },

  /**
   * Load all essential modules (fallback for older browsers)
   */
  loadAllEssentialModules() {
    // Find all essential modules
    const essentialElements = document.querySelectorAll('[data-module][data-module-essential="true"]');
    
    // Load each essential module
    essentialElements.forEach(element => {
      const moduleName = element.dataset.module;
      
      if (moduleName) {
        this.loadModule(moduleName)
          .then(module => {
            if (module && typeof module.initElement === 'function') {
              module.initElement(element);
            }
          });
      }
    });
  },

  /**
   * Prefetch a module in idle time
   * 
   * @param {string} name - Module name to prefetch
   */
  prefetchModule(name) {
    // Check if module is registered and not already loaded
    if (!this.moduleRegistry[name] || this.loadedModules[name]) {
      return;
    }

    // Use requestIdleCallback if available
    if ('requestIdleCallback' in window) {
      requestIdleCallback(() => {
        this.loadModule(name);
      }, { timeout: 2000 });
    } else {
      // Fallback to setTimeout
      setTimeout(() => {
        this.loadModule(name);
      }, 1000);
    }
  },

  /**
   * Preload modules needed for current page based on data attributes
   */
  preloadCurrentPageModules() {
    // Find current active elements that need modules
    const activeElements = document.querySelectorAll('[data-module-preload="true"]');
    
    activeElements.forEach(element => {
      const moduleName = element.dataset.module;
      if (moduleName) {
        this.loadModule(moduleName);
      }
    });
  }
};

// Initialize when the DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  CodeSplitting.init();
  
  // Preload modules needed for current page
  setTimeout(() => {
    CodeSplitting.preloadCurrentPageModules();
  }, 300);
});

export default CodeSplitting; 