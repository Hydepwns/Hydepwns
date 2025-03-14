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
 * - Debug and logging utilities
 * - DOM element management
 */

import Registry from './component_registry';

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
      // For now, this is a placeholder. We'll implement the EventBus next
      // EventBus.unsubscribe(subscription);
      this.debug.log('Cleaning up subscription', subscription);
    });
    this._eventSubscriptions = [];
    
    // Trigger lifecycle hooks
    this._triggerLifecycleHooks('unmount');
    
    // Unregister from registry
    Registry.unregister(this.id);
    
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
   * Publish an event
   * Placeholder - will be implemented with EventBus
   * @param {string} eventName - Name of the event
   * @param {*} data - Event data
   */
  publish(eventName, data) {
    this.debug.log(`Publishing event '${eventName}'`, data);
    // Will be implemented with EventBus
    return null;
  }
  
  /**
   * Subscribe to an event
   * Placeholder - will be implemented with EventBus
   * @param {string} eventName - Name of the event
   * @param {Function} handler - Event handler
   */
  subscribe(eventName, handler) {
    this.debug.log(`Subscribing to event '${eventName}'`);
    // Will be implemented with EventBus
    const subscription = { eventName, handler };
    this._eventSubscriptions.push(subscription);
    return subscription;
  }
  
  /**
   * Send an event to a specific component
   * Placeholder - will be implemented with EventBus
   * @param {string} componentId - ID of the target component
   * @param {string} eventName - Name of the event
   * @param {*} data - Event data
   */
  sendTo(componentId, eventName, data) {
    this.debug.log(`Sending event '${eventName}' to '${componentId}'`, data);
    // Will be implemented with EventBus
    return null;
  }
  
  /**
   * Publish an event scoped to a specific context
   * Placeholder - will be implemented with EventBus
   * @param {string} scope - The scope context
   * @param {string} eventName - Name of the event
   * @param {*} data - Event data
   */
  publishInScope(scope, eventName, data) {
    this.debug.log(`Publishing event '${eventName}' in scope '${scope}'`, data);
    // Will be implemented with EventBus
    return null;
  }
  
  /**
   * Subscribe to an event in a specific scope
   * Placeholder - will be implemented with EventBus
   * @param {string} scope - The scope context
   * @param {string} eventName - Name of the event
   * @param {Function} handler - Event handler
   */
  subscribeInScope(scope, eventName, handler) {
    this.debug.log(`Subscribing to event '${eventName}' in scope '${scope}'`);
    // Will be implemented with EventBus
    const subscription = { scope, eventName, handler };
    this._eventSubscriptions.push(subscription);
    return subscription;
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
        element.textContent = String(children);
      }
    }
    
    // Store reference for cleanup
    this.elements[element.id || `element-${generateUniqueId()}`] = element;
    
    return element;
  }
  
  /**
   * Trigger lifecycle hooks
   * @private
   * @param {string} hookName - Name of the lifecycle hook
   * @param {...any} args - Arguments to pass to the hook
   */
  _triggerLifecycleHooks(hookName, ...args) {
    const hooks = this._lifecycleHooks[hookName] || [];
    hooks.forEach(hook => {
      try {
        hook.call(this, ...args);
      } catch (error) {
        console.error(`Error in ${hookName} hook for ${this.type}:${this.id}`, error);
      }
    });
  }
}

export default HydeComponent; 