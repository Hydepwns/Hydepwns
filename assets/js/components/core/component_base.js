/**
 * HydeComponent Base Class
 * 
 * The foundation for all components in the enhanced component system,
 * providing standard lifecycle methods, event handling capabilities,
 * and integration with the Component Registry.
 * 
 * Features:
 * - Standardized lifecycle (mount, unmount, update)
 * - Event publication and subscription
 * - Automatic registration with Component Registry
 * - Reactive state management
 * - Debug and logging utilities
 * - DOM element management
 */

import Registry from './component_registry';
import EventBus from './event_bus';
import StateManager from './reactive_state';

/**
 * Generate a unique identifier
 * @returns {string} A unique string ID
 */
function generateUniqueId() {
  return Math.random().toString(36).substring(2, 9);
}

/**
 * Base component class for the enhanced component system
 */
class HydeComponent {
  /**
   * Create a new component
   * @param {Object} options - Component configuration options
   */
  constructor(options = {}) {
    // Component identification
    this.id = options.id || `component-${generateUniqueId()}`;
    this.type = this.constructor.name;
    this.context = options.context || null;
    this.tags = options.tags || [];
    
    // Options and configuration
    this.defaultOptions = {};
    this.options = { ...this.defaultOptions, ...options };
    
    // DOM references
    this.container = null;
    this.elements = {};
    
    // Initialize reactive state management
    this._stateManager = new StateManager({
      updateCallback: this._handleStateUpdate.bind(this),
      historyEnabled: options.enableStateHistory || false,
      historyLimit: options.stateHistoryLimit || 50
    });
    this.state = this._stateManager.defineState(options.initialState || {});
    this._stateSubscriptions = new Map();
    
    // Events, state, and lifecycle management
    this._eventSubscriptions = [];
    this._lifecycleHooks = {
      mount: [],
      unmount: [],
      update: []
    };
    
    // Debug options
    this.debug = {
      enabled: options.debug || false,
      log: (...args) => {
        if (this.debug.enabled) {
          console.log(`[${this.type}:${this.id}]`, ...args);
        }
      }
    };
    
    // Auto-register with Component Registry
    Registry.register(this, this.type);
  }
  
  /**
   * Mount the component to a DOM container
   * @param {HTMLElement} container - The DOM element to mount the component to
   * @returns {HydeComponent} - The component instance (for chaining)
   */
  mount(container) {
    if (!container) {
      throw new Error(`${this.type}: Cannot mount without container`);
    }
    
    this.container = container;
    
    // Add component ID to container for inspector integration
    container.dataset.componentId = this.id;
    
    this._triggerLifecycleHooks('mount');
    return this;
  }
  
  /**
   * Unmount the component and clean up resources
   * @returns {HydeComponent} - The component instance (for chaining)
   */
  unmount() {
    // Clean up event subscriptions
    this._eventSubscriptions.forEach(subscription => {
      EventBus.unsubscribe(subscription);
      this.debug.log('Cleaning up subscription', subscription);
    });
    this._eventSubscriptions = [];
    
    // Unsubscribe all events from EventBus
    EventBus.unsubscribeComponent(this.id);
    
    // Clean up state subscriptions
    this._stateSubscriptions.forEach(unsubscribe => unsubscribe());
    this._stateSubscriptions.clear();
    
    // Remove component ID from container
    if (this.container) {
      delete this.container.dataset.componentId;
    }
    
    this._triggerLifecycleHooks('unmount');
    
    // Unregister from Component Registry
    Registry.unregister(this.id);
    
    // Cleanup container reference
    this.container = null;
    
    return this;
  }
  
  /**
   * Update the component with new options
   * @param {Object} options - New configuration options
   * @returns {HydeComponent} - The component instance (for chaining)
   */
  update(options = {}) {
    this.options = { ...this.options, ...options };
    this._triggerLifecycleHooks('update', options);
    return this;
  }
  
  /**
   * Publish an event globally
   * @param {string} eventName - Name of the event
   * @param {*} data - Event data
   * @returns {number} Number of subscribers notified
   */
  publish(eventName, data) {
    this.debug.log(`Publishing event '${eventName}'`, data);
    return EventBus.publish(eventName, data, { source: this.id });
  }
  
  /**
   * Subscribe to a global event
   * @param {string} eventName - Name of the event
   * @param {Function} handler - Event handler
   * @returns {string} Subscription ID
   */
  subscribe(eventName, handler) {
    this.debug.log(`Subscribing to event '${eventName}'`);
    const subscriptionId = EventBus.subscribe(eventName, handler, { componentId: this.id });
    this._eventSubscriptions.push(subscriptionId);
    return subscriptionId;
  }
  
  /**
   * Send an event to a specific component
   * @param {string} componentId - ID of the target component
   * @param {string} eventName - Name of the event
   * @param {*} data - Event data
   * @returns {boolean} Whether the message was delivered
   */
  sendTo(componentId, eventName, data) {
    this.debug.log(`Sending event '${eventName}' to '${componentId}'`, data);
    return EventBus.sendToComponent(componentId, eventName, data, { source: this.id });
  }
  
  /**
   * Publish an event scoped to a specific context
   * @param {string} scope - The scope context
   * @param {string} eventName - Name of the event
   * @param {*} data - Event data
   * @returns {number} Number of subscribers notified
   */
  publishInScope(scope, eventName, data) {
    this.debug.log(`Publishing event '${eventName}' in scope '${scope}'`, data);
    return EventBus.publishScoped(scope, eventName, data, { source: this.id });
  }
  
  /**
   * Subscribe to an event in a specific scope
   * @param {string} scope - The scope context
   * @param {string} eventName - Name of the event
   * @param {Function} handler - Event handler
   * @returns {string} Subscription ID
   */
  subscribeInScope(scope, eventName, handler) {
    this.debug.log(`Subscribing to event '${eventName}' in scope '${scope}'`);
    const subscriptionId = EventBus.subscribeScoped(scope, eventName, handler, { componentId: this.id });
    this._eventSubscriptions.push(subscriptionId);
    return subscriptionId;
  }
  
  /**
   * Handle a direct message from another component
   * This method should be overridden by components that want to receive direct messages
   * @param {Object} message - The message object
   * @param {string} message.name - Event name
   * @param {*} message.data - Event data
   * @param {string} message.source - Source component ID
   */
  onMessage(message) {
    this.debug.log(`Received message '${message.name}' from '${message.source}'`, message);
    // Default implementation does nothing - components should override this
  }
  
  /**
   * Register a callback for when the component is mounted
   * @param {Function} callback - Function to call on mount
   * @returns {HydeComponent} - The component instance (for chaining)
   */
  onMount(callback) {
    this._lifecycleHooks.mount.push(callback);
    return this;
  }
  
  /**
   * Register a callback for when the component is unmounted
   * @param {Function} callback - Function to call on unmount
   * @returns {HydeComponent} - The component instance (for chaining)
   */
  onUnmount(callback) {
    this._lifecycleHooks.unmount.push(callback);
    return this;
  }
  
  /**
   * Register a callback for when the component is updated
   * @param {Function} callback - Function to call on update
   * @returns {HydeComponent} - The component instance (for chaining)
   */
  onUpdate(callback) {
    this._lifecycleHooks.update.push(callback);
    return this;
  }
  
  /**
   * Create a DOM element with automatic cleanup
   * @param {string} tagName - HTML tag name
   * @param {Object} props - Element properties and attributes
   * @param {string|HTMLElement|Array} children - Child content
   * @returns {HTMLElement} - Created element
   */
  createElement(tagName, props = {}, children = null) {
    const element = document.createElement(tagName);
    
    // Apply properties and attributes
    for (const [key, value] of Object.entries(props)) {
      if (key === 'className') {
        element.className = value;
      } else if (key.startsWith('on') && typeof value === 'function') {
        const eventName = key.slice(2).toLowerCase();
        element.addEventListener(eventName, value);
      } else {
        element.setAttribute(key, value);
      }
    }
    
    // Add children
    if (children !== null) {
      if (Array.isArray(children)) {
        children.forEach(child => {
          if (child instanceof HTMLElement) {
            element.appendChild(child);
          } else {
            element.appendChild(document.createTextNode(String(child)));
          }
        });
      } else if (children instanceof HTMLElement) {
        element.appendChild(children);
      } else {
        element.appendChild(document.createTextNode(String(children)));
      }
    }
    
    return element;
  }
  
  /**
   * Trigger lifecycle hook callbacks
   * @param {string} hookName - Name of the hook to trigger
   * @param {...any} args - Arguments to pass to the callbacks
   * @private
   */
  _triggerLifecycleHooks(hookName, ...args) {
    if (this._lifecycleHooks[hookName]) {
      this._lifecycleHooks[hookName].forEach(callback => {
        try {
          callback.apply(this, args);
        } catch (error) {
          console.error(`Error in ${hookName} hook for ${this.type}:${this.id}`, error);
        }
      });
    }
  }
  
  /**
   * Define a computed property that automatically updates when dependencies change
   * @param {String} key - Property name
   * @param {String[]} dependencies - Array of property paths this computed property depends on
   * @param {Function} computeFn - Function that computes the property value
   * @returns {*} - The computed value
   */
  compute(key, dependencies, computeFn) {
    return this._stateManager.compute(key, dependencies, computeFn);
  }
  
  /**
   * Watch for changes on specific state paths
   * @param {String|String[]} path - Property path or array of paths to watch
   * @param {Function} callback - Function to call when value changes
   * @returns {Function} - Function to remove the watcher
   */
  watch(path, callback) {
    const unsubscribe = this._stateManager.watch(path, callback);
    
    // Store for cleanup during unmount
    const subscriptionId = generateUniqueId();
    this._stateSubscriptions.set(subscriptionId, unsubscribe);
    
    // Return a function to remove this specific watcher
    return () => {
      unsubscribe();
      this._stateSubscriptions.delete(subscriptionId);
    };
  }
  
  /**
   * Batch multiple state updates to trigger only one render
   * @param {Function} callback - Function that makes state changes
   */
  batch(callback) {
    this._stateManager.batch(callback);
  }
  
  /**
   * Perform a transaction that can be rolled back if needed
   * @param {Function} callback - Function that returns true for commit, false for rollback
   * @returns {Boolean} - Whether the transaction was committed
   */
  transaction(callback) {
    return this._stateManager.transaction(callback);
  }
  
  /**
   * Get state change history
   * @returns {Array} - History of state changes
   */
  getStateHistory() {
    return this._stateManager.getHistory();
  }
  
  /**
   * Clear state change history
   */
  clearStateHistory() {
    this._stateManager.clearHistory();
  }
  
  /**
   * Time travel to a previous state
   * @param {Number} steps - Number of steps to go back (positive) or forward (negative)
   * @returns {Boolean} - Whether the time travel was successful
   */
  timeTravel(steps) {
    return this._stateManager.revert(steps);
  }
  
  /**
   * Handle state updates and trigger renders
   * @param {String|String[]} paths - Path or array of paths that were updated
   * @private
   */
  _handleStateUpdate(paths) {
    this.debug.log('State updated', paths);
    
    // Call render method if it exists
    if (typeof this.render === 'function') {
      this.render();
    }
    
    // Dispatch a custom event for debugging and tools
    if (this.container) {
      const event = new CustomEvent('state-change', {
        bubbles: true,
        detail: { 
          componentId: this.id, 
          paths: Array.isArray(paths) ? paths : [paths] 
        }
      });
      this.container.dispatchEvent(event);
    }
  }
}

export default HydeComponent; 