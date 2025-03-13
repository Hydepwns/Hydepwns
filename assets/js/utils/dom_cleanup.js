/**
 * DOM Cleanup Protocol
 * 
 * Provides a standardized approach for cleaning up DOM elements and event listeners
 * when components are dismounted or destroyed. This helps prevent memory leaks
 * and ensures a clean DOM tree.
 */

import EventManager from '../components/event_manager';

const DOMCleanup = {
  /**
   * Register a component for cleanup
   * @param {string} componentId - Unique component identifier
   * @param {Object} options - Cleanup options
   * @returns {Object} - Cleanup API
   */
  register(componentId, options = {}) {
    if (!componentId) {
      console.error('DOMCleanup: Component ID is required');
      return null;
    }
    
    // Initialize cleanup registry for this component
    const cleanupRegistry = {
      elements: [],
      intervals: [],
      timeouts: [],
      eventEmitters: [],
      miscCleanup: [],
      cleanupFunctions: [],
      ...options
    };
    
    // Get event manager for this component
    const eventManager = EventManager.registerComponent(componentId);
    
    return {
      /**
       * Register a DOM element for cleanup
       * @param {HTMLElement} element - DOM element to clean up
       * @param {Function} cleanupFn - Optional custom cleanup function
       */
      registerElement(element, cleanupFn) {
        if (!element) return;
        
        cleanupRegistry.elements.push({
          element,
          cleanupFn: cleanupFn || ((el) => {
            // Default cleanup just removes the element from DOM if it exists
            if (el && el.parentNode) {
              el.parentNode.removeChild(el);
            }
          })
        });
      },
      
      /**
       * Register an interval ID for cleanup
       * @param {number} intervalId - setInterval ID to clear
       */
      registerInterval(intervalId) {
        if (intervalId) {
          cleanupRegistry.intervals.push(intervalId);
        }
      },
      
      /**
       * Register a timeout ID for cleanup
       * @param {number} timeoutId - setTimeout ID to clear
       */
      registerTimeout(timeoutId) {
        if (timeoutId) {
          cleanupRegistry.timeouts.push(timeoutId);
        }
      },
      
      /**
       * Register an event emitter for cleanup
       * @param {Object} emitter - Event emitter object
       * @param {string} event - Event name
       * @param {Function} listener - Event listener function
       */
      registerEventEmitter(emitter, event, listener) {
        if (emitter && event && listener) {
          cleanupRegistry.eventEmitters.push({ emitter, event, listener });
        }
      },
      
      /**
       * Register a custom cleanup function
       * @param {Function} cleanupFn - Function to call during cleanup
       */
      registerCleanupFunction(cleanupFn) {
        if (typeof cleanupFn === 'function') {
          cleanupRegistry.cleanupFunctions.push(cleanupFn);
        }
      },
      
      /**
       * Register any miscellaneous object for cleanup
       * @param {Object} obj - Object to clean up
       * @param {Function} cleanupFn - Function to call to clean up this object
       */
      registerMisc(obj, cleanupFn) {
        if (obj && typeof cleanupFn === 'function') {
          cleanupRegistry.miscCleanup.push({ obj, cleanupFn });
        }
      },
      
      /**
       * Perform cleanup for this component
       */
      cleanup() {
        console.log(`Cleaning up component: ${componentId}`);
        
        // Clean up DOM elements
        cleanupRegistry.elements.forEach(({ element, cleanupFn }) => {
          try {
            cleanupFn(element);
          } catch (error) {
            console.error('Error cleaning up element:', error);
          }
        });
        
        // Clear intervals
        cleanupRegistry.intervals.forEach(intervalId => {
          clearInterval(intervalId);
        });
        
        // Clear timeouts
        cleanupRegistry.timeouts.forEach(timeoutId => {
          clearTimeout(timeoutId);
        });
        
        // Remove event emitter listeners
        cleanupRegistry.eventEmitters.forEach(({ emitter, event, listener }) => {
          if (emitter && typeof emitter.removeListener === 'function') {
            emitter.removeListener(event, listener);
          } else if (emitter && typeof emitter.off === 'function') {
            emitter.off(event, listener);
          }
        });
        
        // Call custom cleanup functions
        cleanupRegistry.cleanupFunctions.forEach(fn => {
          try {
            fn();
          } catch (error) {
            console.error('Error in custom cleanup function:', error);
          }
        });
        
        // Clean up miscellaneous objects
        cleanupRegistry.miscCleanup.forEach(({ obj, cleanupFn }) => {
          try {
            cleanupFn(obj);
          } catch (error) {
            console.error('Error in miscellaneous cleanup:', error);
          }
        });
        
        // Clean up event listeners via the EventManager
        if (eventManager) {
          eventManager.cleanup();
        }
        
        // Clear all registry arrays
        cleanupRegistry.elements = [];
        cleanupRegistry.intervals = [];
        cleanupRegistry.timeouts = [];
        cleanupRegistry.eventEmitters = [];
        cleanupRegistry.miscCleanup = [];
        cleanupRegistry.cleanupFunctions = [];
      }
    };
  },
  
  /**
   * Helper function to create element with auto-cleanup on component unmount
   * @param {string} tag - HTML tag name
   * @param {Object} attributes - Element attributes
   * @param {string|Node|Array} children - Child nodes
   * @param {Object} cleanupAPI - Cleanup API from register()
   * @returns {HTMLElement} - Created element
   */
  createElement(tag, attributes = {}, children = [], cleanupAPI) {
    const element = document.createElement(tag);
    
    // Set attributes
    Object.entries(attributes).forEach(([key, value]) => {
      if (key === 'style' && typeof value === 'object') {
        Object.entries(value).forEach(([styleProp, styleValue]) => {
          element.style[styleProp] = styleValue;
        });
      } else if (key === 'classList' && Array.isArray(value)) {
        value.forEach(cls => element.classList.add(cls));
      } else if (key.startsWith('on') && typeof value === 'function') {
        const eventType = key.substring(2).toLowerCase();
        if (cleanupAPI) {
          // If we have a cleanup API, use the event manager
          const eventManager = EventManager.getComponentEventManager(cleanupAPI._componentId);
          if (eventManager) {
            eventManager.addEventListener(element, eventType, value);
          } else {
            element.addEventListener(eventType, value);
          }
        } else {
          element.addEventListener(eventType, value);
        }
      } else {
        element.setAttribute(key, value);
      }
    });
    
    // Add children
    if (children) {
      if (Array.isArray(children)) {
        children.forEach(child => {
          if (typeof child === 'string') {
            element.appendChild(document.createTextNode(child));
          } else if (child instanceof Node) {
            element.appendChild(child);
          }
        });
      } else if (typeof children === 'string') {
        element.textContent = children;
      } else if (children instanceof Node) {
        element.appendChild(children);
      }
    }
    
    // Register for cleanup if a cleanup API is provided
    if (cleanupAPI && typeof cleanupAPI.registerElement === 'function') {
      cleanupAPI.registerElement(element);
    }
    
    return element;
  },
  
  /**
   * Remove all children from a DOM element
   * @param {HTMLElement} element - Element to clear
   */
  removeAllChildren(element) {
    if (!element) return;
    
    while (element.firstChild) {
      element.removeChild(element.firstChild);
    }
  }
};

export default DOMCleanup; 