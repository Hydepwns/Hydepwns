/**
 * EventBus - Centralized Event Management System
 * 
 * A singleton providing publish/subscribe functionality for components,
 * with support for scoped events, direct component messaging, and
 * integration with the Component Registry.
 * 
 * Features:
 * - Global event publishing and subscription
 * - Scoped events for context-specific communication
 * - Direct component-to-component messaging
 * - Automatic subscription cleanup
 * - Debug and monitoring capabilities
 */

import Registry from './component_registry';

/**
 * Generate a unique identifier for subscriptions
 * @returns {string} A unique string ID
 * @private
 */
function generateUniqueId() {
  return Math.random().toString(36).substring(2, 9);
}

/**
 * EventBus singleton class
 */
class EventBus {
  constructor() {
    // Singleton pattern implementation
    if (EventBus.instance) {
      return EventBus.instance;
    }
    
    // Main subscription storage
    this._subscriptions = new Map();       // eventName -> Array of subscription objects
    this._scopedSubscriptions = new Map(); // scope -> Map(eventName -> Array of subscription objects)
    this._componentSubscriptions = new Map(); // componentId -> Array of subscription IDs
    
    // Event monitoring for debugging
    this._eventHistory = [];
    this._historyLimit = 100;
    
    // Debug mode
    this._debug = process.env.NODE_ENV === 'development';
    
    // Performance tracking
    this._stats = {
      eventsPublished: 0,
      scopedEventsPublished: 0,
      directMessagesPublished: 0
    };
    
    EventBus.instance = this;
  }
  
  /**
   * Subscribe to a global event
   * @param {string} eventName - Name of the event to subscribe to
   * @param {Function} handler - Function to call when event is published
   * @param {Object} options - Subscription options
   * @param {string} options.componentId - ID of the component subscribing (for cleanup)
   * @returns {string} Subscription ID for unsubscribing
   */
  subscribe(eventName, handler, options = {}) {
    if (!eventName || typeof handler !== 'function') {
      console.error('EventBus: Cannot subscribe without event name and handler');
      return null;
    }
    
    // Get or create subscription array for this event
    if (!this._subscriptions.has(eventName)) {
      this._subscriptions.set(eventName, []);
    }
    
    // Create subscription object
    const subscriptionId = generateUniqueId();
    const subscription = {
      id: subscriptionId,
      handler,
      componentId: options.componentId || null
    };
    
    // Add to subscriptions
    this._subscriptions.get(eventName).push(subscription);
    
    // Track by component ID for cleanup if provided
    if (options.componentId) {
      if (!this._componentSubscriptions.has(options.componentId)) {
        this._componentSubscriptions.set(options.componentId, []);
      }
      
      this._componentSubscriptions.get(options.componentId).push({
        id: subscriptionId,
        eventName,
        scoped: false
      });
    }
    
    if (this._debug) {
      console.log(`EventBus: Subscribed to '${eventName}'`, subscription);
    }
    
    return subscriptionId;
  }
  
  /**
   * Subscribe to an event in a specific scope
   * @param {string} scope - Scope identifier (e.g., section or component context)
   * @param {string} eventName - Name of the scoped event
   * @param {Function} handler - Event handler function
   * @param {Object} options - Subscription options
   * @param {string} options.componentId - ID of the component subscribing (for cleanup)
   * @returns {string} Subscription ID
   */
  subscribeScoped(scope, eventName, handler, options = {}) {
    if (!scope || !eventName || typeof handler !== 'function') {
      console.error('EventBus: Cannot subscribe to scoped event without scope, event name, and handler');
      return null;
    }
    
    // Get or create scope map
    if (!this._scopedSubscriptions.has(scope)) {
      this._scopedSubscriptions.set(scope, new Map());
    }
    
    const scopeMap = this._scopedSubscriptions.get(scope);
    
    // Get or create subscription array for this event in this scope
    if (!scopeMap.has(eventName)) {
      scopeMap.set(eventName, []);
    }
    
    // Create subscription object
    const subscriptionId = generateUniqueId();
    const subscription = {
      id: subscriptionId,
      handler,
      componentId: options.componentId || null
    };
    
    // Add to scoped subscriptions
    scopeMap.get(eventName).push(subscription);
    
    // Track by component ID for cleanup if provided
    if (options.componentId) {
      if (!this._componentSubscriptions.has(options.componentId)) {
        this._componentSubscriptions.set(options.componentId, []);
      }
      
      this._componentSubscriptions.get(options.componentId).push({
        id: subscriptionId,
        eventName,
        scope,
        scoped: true
      });
    }
    
    if (this._debug) {
      console.log(`EventBus: Subscribed to '${eventName}' in scope '${scope}'`, subscription);
    }
    
    return subscriptionId;
  }
  
  /**
   * Publish a global event to all subscribers
   * @param {string} eventName - Name of the event to publish
   * @param {*} data - Data to pass to event handlers
   * @param {Object} options - Additional options
   * @param {string} options.source - ID of the component publishing the event
   * @returns {number} Number of handlers notified
   */
  publish(eventName, data, options = {}) {
    if (!eventName) {
      console.error('EventBus: Cannot publish without event name');
      return 0;
    }
    
    // Skip if no subscribers
    if (!this._subscriptions.has(eventName)) {
      if (this._debug) {
        console.log(`EventBus: No subscribers for '${eventName}'`);
      }
      return 0;
    }
    
    // Get subscribers
    const subscribers = this._subscriptions.get(eventName);
    let notifiedCount = 0;
    
    // Create event object
    const event = {
      name: eventName,
      data,
      source: options.source || null,
      timestamp: Date.now()
    };
    
    // Add to history
    this._addToHistory(event, 'global');
    
    // Notify subscribers
    for (const subscription of subscribers) {
      try {
        subscription.handler(event);
        notifiedCount++;
      } catch (error) {
        console.error(`EventBus: Error in handler for '${eventName}'`, error);
      }
    }
    
    // Update stats
    this._stats.eventsPublished++;
    
    if (this._debug) {
      console.log(`EventBus: Published '${eventName}' to ${notifiedCount} subscribers`, event);
    }
    
    return notifiedCount;
  }
  
  /**
   * Publish an event in a specific scope
   * @param {string} scope - Scope identifier
   * @param {string} eventName - Event name
   * @param {*} data - Event data
   * @param {Object} options - Additional options
   * @param {string} options.source - ID of the source component
   * @returns {number} Number of handlers notified
   */
  publishScoped(scope, eventName, data, options = {}) {
    if (!scope || !eventName) {
      console.error('EventBus: Cannot publish scoped event without scope and event name');
      return 0;
    }
    
    // Skip if no subscribers in this scope
    if (!this._scopedSubscriptions.has(scope) || 
        !this._scopedSubscriptions.get(scope).has(eventName)) {
      if (this._debug) {
        console.log(`EventBus: No subscribers for '${eventName}' in scope '${scope}'`);
      }
      return 0;
    }
    
    // Get subscribers
    const scopeMap = this._scopedSubscriptions.get(scope);
    const subscribers = scopeMap.get(eventName);
    let notifiedCount = 0;
    
    // Create event object
    const event = {
      name: eventName,
      data,
      source: options.source || null,
      scope,
      timestamp: Date.now()
    };
    
    // Add to history
    this._addToHistory(event, 'scoped');
    
    // Notify subscribers
    for (const subscription of subscribers) {
      try {
        subscription.handler(event);
        notifiedCount++;
      } catch (error) {
        console.error(`EventBus: Error in handler for '${eventName}' in scope '${scope}'`, error);
      }
    }
    
    // Update stats
    this._stats.scopedEventsPublished++;
    
    if (this._debug) {
      console.log(`EventBus: Published '${eventName}' in scope '${scope}' to ${notifiedCount} subscribers`, event);
    }
    
    return notifiedCount;
  }
  
  /**
   * Send an event directly to a specific component
   * @param {string} targetComponentId - ID of the target component
   * @param {string} eventName - Event name
   * @param {*} data - Event data
   * @param {Object} options - Additional options
   * @param {string} options.source - ID of the source component
   * @returns {boolean} Whether the message was delivered
   */
  sendToComponent(targetComponentId, eventName, data, options = {}) {
    if (!targetComponentId || !eventName) {
      console.error('EventBus: Cannot send direct message without target component ID and event name');
      return false;
    }
    
    // Find target component in registry
    const targetComponent = Registry.findById(targetComponentId);
    if (!targetComponent) {
      if (this._debug) {
        console.warn(`EventBus: Target component '${targetComponentId}' not found`);
      }
      return false;
    }
    
    // Check if component has an onMessage method
    if (typeof targetComponent.onMessage !== 'function') {
      if (this._debug) {
        console.warn(`EventBus: Component '${targetComponentId}' does not implement onMessage`);
      }
      return false;
    }
    
    // Create message object
    const message = {
      name: eventName,
      data,
      source: options.source || null,
      target: targetComponentId,
      timestamp: Date.now()
    };
    
    // Add to history
    this._addToHistory(message, 'direct');
    
    // Send message to component
    try {
      targetComponent.onMessage(message);
      
      // Update stats
      this._stats.directMessagesPublished++;
      
      if (this._debug) {
        console.log(`EventBus: Sent message '${eventName}' to component '${targetComponentId}'`, message);
      }
      
      return true;
    } catch (error) {
      console.error(`EventBus: Error sending message '${eventName}' to component '${targetComponentId}'`, error);
      return false;
    }
  }
  
  /**
   * Unsubscribe from an event
   * @param {string} subscriptionId - ID of the subscription to remove
   * @returns {boolean} Whether the subscription was found and removed
   */
  unsubscribe(subscriptionId) {
    if (!subscriptionId) {
      return false;
    }
    
    let foundSubscription = false;
    
    // Check global subscriptions
    for (const [eventName, subscriptions] of this._subscriptions.entries()) {
      const initialLength = subscriptions.length;
      const filtered = subscriptions.filter(sub => sub.id !== subscriptionId);
      
      if (filtered.length < initialLength) {
        this._subscriptions.set(eventName, filtered);
        foundSubscription = true;
        
        if (this._debug) {
          console.log(`EventBus: Unsubscribed from '${eventName}' with ID ${subscriptionId}`);
        }
        
        // If no more subscriptions for this event, clean up
        if (filtered.length === 0) {
          this._subscriptions.delete(eventName);
        }
        
        break;
      }
    }
    
    // If not found in global, check scoped
    if (!foundSubscription) {
      for (const [scope, eventMap] of this._scopedSubscriptions.entries()) {
        let scopeMatch = false;
        
        for (const [eventName, subscriptions] of eventMap.entries()) {
          const initialLength = subscriptions.length;
          const filtered = subscriptions.filter(sub => sub.id !== subscriptionId);
          
          if (filtered.length < initialLength) {
            eventMap.set(eventName, filtered);
            foundSubscription = true;
            scopeMatch = true;
            
            if (this._debug) {
              console.log(`EventBus: Unsubscribed from '${eventName}' in scope '${scope}' with ID ${subscriptionId}`);
            }
            
            // If no more subscriptions for this event in this scope, clean up
            if (filtered.length === 0) {
              eventMap.delete(eventName);
            }
            
            break;
          }
        }
        
        // If scope map is now empty, remove it
        if (scopeMatch && eventMap.size === 0) {
          this._scopedSubscriptions.delete(scope);
        }
        
        if (foundSubscription) break;
      }
    }
    
    return foundSubscription;
  }
  
  /**
   * Unsubscribe all events for a component
   * @param {string} componentId - ID of the component
   * @returns {number} Number of subscriptions removed
   */
  unsubscribeComponent(componentId) {
    if (!componentId || !this._componentSubscriptions.has(componentId)) {
      return 0;
    }
    
    const subscriptions = this._componentSubscriptions.get(componentId);
    let removedCount = 0;
    
    // Unsubscribe each subscription
    for (const sub of subscriptions) {
      if (sub.scoped) {
        // Find and remove from scoped subscriptions
        const scopeMap = this._scopedSubscriptions.get(sub.scope);
        if (scopeMap && scopeMap.has(sub.eventName)) {
          const subs = scopeMap.get(sub.eventName);
          const filtered = subs.filter(s => s.id !== sub.id);
          
          if (filtered.length < subs.length) {
            scopeMap.set(sub.eventName, filtered);
            removedCount++;
            
            // Clean up empty event arrays
            if (filtered.length === 0) {
              scopeMap.delete(sub.eventName);
            }
          }
          
          // Clean up empty scope maps
          if (scopeMap.size === 0) {
            this._scopedSubscriptions.delete(sub.scope);
          }
        }
      } else {
        // Find and remove from global subscriptions
        if (this._subscriptions.has(sub.eventName)) {
          const subs = this._subscriptions.get(sub.eventName);
          const filtered = subs.filter(s => s.id !== sub.id);
          
          if (filtered.length < subs.length) {
            this._subscriptions.set(sub.eventName, filtered);
            removedCount++;
            
            // Clean up empty event arrays
            if (filtered.length === 0) {
              this._subscriptions.delete(sub.eventName);
            }
          }
        }
      }
    }
    
    // Remove component from tracking
    this._componentSubscriptions.delete(componentId);
    
    if (this._debug) {
      console.log(`EventBus: Unsubscribed component '${componentId}' from ${removedCount} events`);
    }
    
    return removedCount;
  }
  
  /**
   * Get statistics about event bus usage
   * @returns {Object} Event statistics
   */
  getStats() {
    const globalEvents = Array.from(this._subscriptions.keys());
    const scopedEvents = Array.from(this._scopedSubscriptions.keys()).map(scope => {
      const events = Array.from(this._scopedSubscriptions.get(scope).keys());
      return { scope, events, count: events.length };
    });
    
    return {
      ...this._stats,
      subscriberCount: this._getSubscriberCount(),
      globalEvents: {
        count: globalEvents.length,
        events: globalEvents
      },
      scopedEvents: {
        count: scopedEvents.reduce((acc, scope) => acc + scope.count, 0),
        scopes: scopedEvents
      },
      componentSubscriptions: this._componentSubscriptions.size
    };
  }
  
  /**
   * Get recent event history
   * @param {number} limit - Maximum number of events to return
   * @returns {Array} Recent events
   */
  getHistory(limit = 10) {
    return this._eventHistory.slice(-Math.min(limit, this._eventHistory.length));
  }
  
  /**
   * Enable or disable debug mode
   * @param {boolean} enable - Whether to enable debug mode
   */
  setDebug(enable) {
    this._debug = !!enable;
  }
  
  /**
   * Set history limit for event tracking
   * @param {number} limit - Maximum history size
   */
  setHistoryLimit(limit) {
    this._historyLimit = limit;
    // Trim history if needed
    if (this._eventHistory.length > limit) {
      this._eventHistory = this._eventHistory.slice(-limit);
    }
  }
  
  /**
   * Get the total number of subscribers
   * @returns {number} Total subscribers
   * @private
   */
  _getSubscriberCount() {
    let count = 0;
    
    // Count global subscribers
    for (const subs of this._subscriptions.values()) {
      count += subs.length;
    }
    
    // Count scoped subscribers
    for (const scopeMap of this._scopedSubscriptions.values()) {
      for (const subs of scopeMap.values()) {
        count += subs.length;
      }
    }
    
    return count;
  }
  
  /**
   * Add an event to the history log
   * @param {Object} event - Event object
   * @param {string} type - Event type (global, scoped, direct)
   * @private
   */
  _addToHistory(event, type) {
    const historyEntry = {
      ...event,
      type
    };
    
    this._eventHistory.push(historyEntry);
    
    // Trim history if it exceeds the limit
    if (this._eventHistory.length > this._historyLimit) {
      this._eventHistory.shift();
    }
  }
  
  /**
   * Clear all subscriptions (primarily for testing)
   */
  _reset() {
    this._subscriptions.clear();
    this._scopedSubscriptions.clear();
    this._componentSubscriptions.clear();
    this._eventHistory = [];
    this._stats = {
      eventsPublished: 0,
      scopedEventsPublished: 0,
      directMessagesPublished: 0
    };
  }
}

// Create and export singleton instance
const instance = new EventBus();
export default instance; 