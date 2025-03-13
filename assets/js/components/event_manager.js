/**
 * Event Management System
 * 
 * Provides a centralized event management system to prevent event handler conflicts
 * and ensure proper cleanup when components are unmounted.
 * 
 * Features:
 * - Event registration and deregistration
 * - Scoped event handlers tied to component lifecycle
 * - Event delegation for improved performance
 * - Automatic cleanup on component unmount
 */

const EventManager = {
  // Store all registered event handlers by component ID and event type
  _eventRegistry: {},
  
  // Store all DOM event listeners for cleanup
  _domListeners: {},
  
  /**
   * Register a component with the event manager
   * @param {string} componentId - Unique identifier for the component
   * @returns {Object} - Component event API
   */
  registerComponent(componentId) {
    if (!componentId) {
      console.error('EventManager: Component ID is required');
      return null;
    }
    
    // Initialize registry entry for this component if it doesn't exist
    if (!this._eventRegistry[componentId]) {
      this._eventRegistry[componentId] = {};
    }
    
    // Create and return component-specific event API
    return {
      /**
       * Add an event listener scoped to this component
       * @param {HTMLElement} element - DOM element to attach the listener to
       * @param {string} eventType - Type of event (e.g., 'click', 'mousemove')
       * @param {Function} handler - Event handler function
       * @param {Object} options - Additional options (e.g., { capture: true })
       */
      addEventListener: (element, eventType, handler, options = {}) => {
        if (!element || !eventType || !handler) {
          console.error('EventManager: Missing required parameters for addEventListener');
          return;
        }
        
        // Create unique key for this listener
        const listenerId = `${componentId}_${eventType}_${this._generateUniqueId()}`;
        
        // Store the original handler and element for cleanup
        if (!this._domListeners[listenerId]) {
          this._domListeners[listenerId] = { element, eventType, handler, options };
        }
        
        // Add the event listener to the DOM
        element.addEventListener(eventType, handler, options);
        
        // Register this event in the component's registry
        if (!this._eventRegistry[componentId][eventType]) {
          this._eventRegistry[componentId][eventType] = [];
        }
        
        this._eventRegistry[componentId][eventType].push(listenerId);
        
        return listenerId;
      },
      
      /**
       * Remove a specific event listener
       * @param {string} listenerId - ID of the listener to remove
       */
      removeEventListener: (listenerId) => {
        if (!listenerId || !this._domListeners[listenerId]) {
          return;
        }
        
        const { element, eventType, handler, options } = this._domListeners[listenerId];
        element.removeEventListener(eventType, handler, options);
        
        // Remove from DOM listeners registry
        delete this._domListeners[listenerId];
        
        // Remove from component registry if possible
        const eventTypeFromId = listenerId.split('_')[1];
        if (this._eventRegistry[componentId][eventTypeFromId]) {
          this._eventRegistry[componentId][eventTypeFromId] = 
            this._eventRegistry[componentId][eventTypeFromId].filter(id => id !== listenerId);
        }
      },
      
      /**
       * Add a delegated event listener for better performance with many elements
       * @param {HTMLElement} parentElement - Parent element to attach the listener to
       * @param {string} eventType - Type of event (e.g., 'click')
       * @param {string} selector - CSS selector for target elements
       * @param {Function} handler - Event handler function
       */
      addDelegatedEventListener: (parentElement, eventType, selector, handler) => {
        if (!parentElement || !eventType || !selector || !handler) {
          console.error('EventManager: Missing required parameters for addDelegatedEventListener');
          return;
        }
        
        const delegatedHandler = (event) => {
          const targetElement = event.target.closest(selector);
          if (targetElement) {
            handler.call(targetElement, event, targetElement);
          }
        };
        
        return this.addEventListener(parentElement, eventType, delegatedHandler);
      },
      
      /**
       * Remove all event listeners registered by this component
       */
      cleanup: () => {
        if (!this._eventRegistry[componentId]) {
          return;
        }
        
        // Iterate through all event types registered for this component
        Object.keys(this._eventRegistry[componentId]).forEach(eventType => {
          const listenerIds = this._eventRegistry[componentId][eventType];
          
          // Remove each listener
          listenerIds.forEach(listenerId => {
            if (this._domListeners[listenerId]) {
              const { element, eventType: listenerEventType, handler, options } = this._domListeners[listenerId];
              element.removeEventListener(listenerEventType, handler, options);
              delete this._domListeners[listenerId];
            }
          });
        });
        
        // Clear component from registry
        delete this._eventRegistry[componentId];
      }
    };
  },
  
  /**
   * Generate a unique ID for event listeners
   * @returns {string} Unique ID
   * @private
   */
  _generateUniqueId() {
    return Math.random().toString(36).substring(2, 9);
  },
  
  /**
   * Unregister a component and cleanup all its event listeners
   * @param {string} componentId - ID of the component to unregister
   */
  unregisterComponent(componentId) {
    if (!componentId || !this._eventRegistry[componentId]) {
      return;
    }
    
    // Call cleanup to remove all event listeners
    const component = this.registerComponent(componentId);
    component.cleanup();
  }
};

export default EventManager; 