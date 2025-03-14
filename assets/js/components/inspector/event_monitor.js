/**
 * Event Monitor
 * 
 * Monitors and visualizes event flow between components.
 * Provides tools for debugging event-based communication.
 */

import ComponentRegistry from '../core/component_registry';
import EventBus from '../core/event_bus';

class EventMonitor {
  constructor() {
    this._eventHistory = [];
    this._isMonitoring = false;
    this._maxHistorySize = 100;
    this._filter = null;
    this._listeners = new Map();
    
    // Original event methods we patch
    this._originalPublish = null;
    this._originalSubscribe = null;
    this._originalUnsubscribe = null;
    
    // Bind methods that will be used as callbacks
    this._handleEventPublished = this._handleEventPublished.bind(this);
    this._handleEventSubscribed = this._handleEventSubscribed.bind(this);
    this._handleEventUnsubscribed = this._handleEventUnsubscribed.bind(this);
  }
  
  /**
   * Start monitoring events
   * @param {Object} filter - Filter options for events
   * @param {String[]} filter.eventTypes - Event types to monitor
   * @param {String[]} filter.componentIds - Component IDs to monitor
   * @param {Boolean} filter.includePayloads - Whether to include event payloads
   */
  startMonitoring(filter = {}) {
    if (this._isMonitoring) {
      this.stopMonitoring();
    }
    
    this._filter = {
      eventTypes: filter.eventTypes || [],
      componentIds: filter.componentIds || [],
      includePayloads: filter.includePayloads !== false
    };
    
    // Patch event bus methods to intercept events
    this._patchEventBusMethods();
    
    this._isMonitoring = true;
    
    return true;
  }
  
  /**
   * Stop monitoring events
   */
  stopMonitoring() {
    if (!this._isMonitoring) return false;
    
    // Restore original event bus methods
    this._unpatchEventBusMethods();
    
    // Remove any event listeners we added
    this._removeEventListeners();
    
    this._isMonitoring = false;
    
    return true;
  }
  
  /**
   * Clear the event history
   */
  clearHistory() {
    this._eventHistory = [];
  }
  
  /**
   * Get the event history
   * @param {Number} limit - Maximum number of events to return
   * @returns {Array} - Event history
   */
  getHistory(limit = this._maxHistorySize) {
    return this._eventHistory.slice(-limit);
  }
  
  /**
   * Get event flow data for visualization
   * @returns {Object} - Event flow data
   */
  getEventFlow() {
    const nodes = new Map(); // Component nodes
    const edges = new Map(); // Event connections
    
    // Build graph from event history
    this._eventHistory.forEach(event => {
      if (event.type === 'publish') {
        const { sourceComponentId, eventName, targetComponentId } = event;
        
        // Add source node if needed
        if (sourceComponentId && !nodes.has(sourceComponentId)) {
          const component = this._getComponentInfo(sourceComponentId);
          nodes.set(sourceComponentId, component);
        }
        
        // Add target node if needed
        if (targetComponentId && !nodes.has(targetComponentId)) {
          const component = this._getComponentInfo(targetComponentId);
          nodes.set(targetComponentId, component);
        }
        
        // Add edge
        if (sourceComponentId && targetComponentId) {
          const edgeKey = `${sourceComponentId}:${targetComponentId}:${eventName}`;
          
          if (!edges.has(edgeKey)) {
            edges.set(edgeKey, {
              source: sourceComponentId,
              target: targetComponentId,
              eventName,
              count: 1
            });
          } else {
            const edge = edges.get(edgeKey);
            edge.count++;
          }
        }
      }
    });
    
    return {
      nodes: Array.from(nodes.values()),
      edges: Array.from(edges.values()),
      events: this._getEventSummary()
    };
  }
  
  /**
   * Get a summary of events by type
   * @returns {Object} - Event summary
   * @private
   */
  _getEventSummary() {
    const eventCounts = {};
    
    this._eventHistory.forEach(event => {
      if (event.type === 'publish') {
        const { eventName } = event;
        eventCounts[eventName] = (eventCounts[eventName] || 0) + 1;
      }
    });
    
    return Object.entries(eventCounts).map(([name, count]) => ({ name, count }));
  }
  
  /**
   * Get component information
   * @param {String} componentId - Component ID
   * @returns {Object} - Component info
   * @private
   */
  _getComponentInfo(componentId) {
    const registry = ComponentRegistry.getInstance();
    const component = registry.getById(componentId);
    
    if (!component) {
      return {
        id: componentId,
        name: 'Unknown Component',
        type: 'unknown'
      };
    }
    
    return {
      id: componentId,
      name: component.name || 'Unnamed Component',
      type: component.constructor ? component.constructor.name : 'Component'
    };
  }
  
  /**
   * Patch event bus methods to intercept events
   * @private
   */
  _patchEventBusMethods() {
    const eventBus = EventBus.getInstance();
    
    // Save original methods
    if (!this._originalPublish) {
      this._originalPublish = eventBus.publish;
    }
    
    if (!this._originalSubscribe) {
      this._originalSubscribe = eventBus.subscribe;
    }
    
    if (!this._originalUnsubscribe) {
      this._originalUnsubscribe = eventBus.unsubscribe;
    }
    
    // Patch publish method
    eventBus.publish = (eventName, payload, options = {}) => {
      // Record the event
      this._handleEventPublished(eventName, payload, options);
      
      // Call the original method
      return this._originalPublish.call(eventBus, eventName, payload, options);
    };
    
    // Patch subscribe method
    eventBus.subscribe = (eventName, callback, options = {}) => {
      const result = this._originalSubscribe.call(eventBus, eventName, callback, options);
      
      // Record the subscription
      this._handleEventSubscribed(eventName, callback, options);
      
      return result;
    };
    
    // Patch unsubscribe method
    eventBus.unsubscribe = (eventName, callback) => {
      const result = this._originalUnsubscribe.call(eventBus, eventName, callback);
      
      // Record the unsubscription
      this._handleEventUnsubscribed(eventName, callback);
      
      return result;
    };
  }
  
  /**
   * Restore original event bus methods
   * @private
   */
  _unpatchEventBusMethods() {
    const eventBus = EventBus.getInstance();
    
    if (this._originalPublish) {
      eventBus.publish = this._originalPublish;
    }
    
    if (this._originalSubscribe) {
      eventBus.subscribe = this._originalSubscribe;
    }
    
    if (this._originalUnsubscribe) {
      eventBus.unsubscribe = this._originalUnsubscribe;
    }
  }
  
  /**
   * Remove any event listeners
   * @private
   */
  _removeEventListeners() {
    this._listeners.forEach((callback, key) => {
      const [eventName, componentId] = key.split(':');
      const eventBus = EventBus.getInstance();
      
      eventBus.unsubscribe(eventName, callback);
    });
    
    this._listeners.clear();
  }
  
  /**
   * Handle event publication
   * @param {String} eventName - Event name
   * @param {*} payload - Event payload
   * @param {Object} options - Publication options
   * @private
   */
  _handleEventPublished(eventName, payload, options) {
    const timestamp = Date.now();
    const sourceComponentId = options.sourceComponentId || 'unknown';
    const targetComponentId = options.targetComponentId || null;
    
    // Check if we should record this event
    if (this._shouldRecordEvent(eventName, sourceComponentId, targetComponentId)) {
      // Create event record
      const eventRecord = {
        type: 'publish',
        timestamp,
        eventName,
        sourceComponentId,
        targetComponentId,
        payload: this._filter.includePayloads ? this._safeClonePayload(payload) : null
      };
      
      // Add to history
      this._addToHistory(eventRecord);
      
      // Log to console in development
      if (process.env.NODE_ENV === 'development') {
        console.debug(`[Event Monitor] Event published: ${eventName}`,
          sourceComponentId ? `from: ${sourceComponentId}` : '',
          targetComponentId ? `to: ${targetComponentId}` : '');
      }
    }
  }
  
  /**
   * Handle event subscription
   * @param {String} eventName - Event name
   * @param {Function} callback - Event callback
   * @param {Object} options - Subscription options
   * @private
   */
  _handleEventSubscribed(eventName, callback, options) {
    const timestamp = Date.now();
    const componentId = options.componentId || 'unknown';
    
    // Create event record
    const eventRecord = {
      type: 'subscribe',
      timestamp,
      eventName,
      componentId
    };
    
    // Add to history
    this._addToHistory(eventRecord);
  }
  
  /**
   * Handle event unsubscription
   * @param {String} eventName - Event name
   * @param {Function} callback - Event callback
   * @private
   */
  _handleEventUnsubscribed(eventName, callback) {
    const timestamp = Date.now();
    
    // Create event record
    const eventRecord = {
      type: 'unsubscribe',
      timestamp,
      eventName
    };
    
    // Add to history
    this._addToHistory(eventRecord);
  }
  
  /**
   * Add an event to history
   * @param {Object} eventRecord - Event record
   * @private
   */
  _addToHistory(eventRecord) {
    this._eventHistory.push(eventRecord);
    
    // Limit history size
    if (this._eventHistory.length > this._maxHistorySize) {
      this._eventHistory.shift();
    }
  }
  
  /**
   * Check if an event should be recorded based on filters
   * @param {String} eventName - Event name
   * @param {String} sourceComponentId - Source component ID
   * @param {String} targetComponentId - Target component ID
   * @returns {Boolean} - Whether to record the event
   * @private
   */
  _shouldRecordEvent(eventName, sourceComponentId, targetComponentId) {
    // If no filter is set, record everything
    if (!this._filter) return true;
    
    // Check event type filter
    if (this._filter.eventTypes.length > 0) {
      // Check for exact match or pattern match
      const matches = this._filter.eventTypes.some(pattern => {
        if (pattern.includes('*')) {
          // Convert pattern to regex
          const regexPattern = pattern.replace(/\*/g, '.*');
          const regex = new RegExp(`^${regexPattern}$`);
          return regex.test(eventName);
        }
        return pattern === eventName;
      });
      
      if (!matches) return false;
    }
    
    // Check component ID filter
    if (this._filter.componentIds.length > 0) {
      const componentMatches = this._filter.componentIds.includes(sourceComponentId) ||
                              (targetComponentId && this._filter.componentIds.includes(targetComponentId));
      
      if (!componentMatches) return false;
    }
    
    return true;
  }
  
  /**
   * Safely clone a payload for storage
   * @param {*} payload - Event payload
   * @returns {*} - Cloned payload
   * @private
   */
  _safeClonePayload(payload) {
    if (payload === null || payload === undefined) {
      return payload;
    }
    
    try {
      // Try to JSON stringify/parse for a deep clone
      return JSON.parse(JSON.stringify(payload));
    } catch (error) {
      // If that fails, return a simple representation
      return `[Complex Object: ${typeof payload}]`;
    }
  }
}

// Singleton instance
let instance = null;

export default {
  getInstance() {
    if (!instance) {
      instance = new EventMonitor();
    }
    return instance;
  }
}; 