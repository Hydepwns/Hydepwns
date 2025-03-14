# Inter-component Communication System Implementation

## Overview

The Inter-component Communication System provides a standardized way for components to communicate with each other without direct references. This system implements an event bus pattern with support for both global and scoped events, enabling loose coupling while maintaining a clear communication structure.

## Technical Architecture

### Event Bus Core

The core of the system is an event bus that manages event registration, dispatch, and lifecycle:

```javascript
// assets/js/components/core/event_bus.js
class EventBus {
  constructor() {
    if (EventBus.instance) {
      return EventBus.instance;
    }
    
    // Event handlers storage
    this._globalHandlers = new Map();
    this._scopedHandlers = new Map();
    this._componentHandlers = new Map();
    
    // Event history for debugging
    this._eventHistory = [];
    this._historyLimit = 100;
    this._historyEnabled = process.env.NODE_ENV === 'development';
    
    EventBus.instance = this;
  }
  
  // Public API methods...
}

// Export singleton instance
export const Bus = new EventBus();
```

### Event Publication

The system supports different types of event publication:

```javascript
// Global event publication
publish(eventName, data = {}, options = {}) {
  const event = {
    id: generateUniqueId(),
    name: eventName,
    data,
    timestamp: Date.now(),
    source: options.source || null,
    meta: options.meta || {}
  };
  
  // Record in history if enabled
  if (this._historyEnabled) {
    this._recordEvent(event);
  }
  
  // Dispatch to global handlers
  this._dispatchToHandlers(this._globalHandlers, eventName, event);
  
  return event;
}

// Scoped event publication
publishInScope(scopeId, eventName, data = {}, options = {}) {
  const event = {
    id: generateUniqueId(),
    name: eventName,
    data,
    timestamp: Date.now(),
    source: options.source || null,
    scope: scopeId,
    meta: options.meta || {}
  };
  
  // Record in history if enabled
  if (this._historyEnabled) {
    this._recordEvent(event);
  }
  
  // Dispatch to scoped handlers
  if (this._scopedHandlers.has(scopeId)) {
    this._dispatchToHandlers(this._scopedHandlers.get(scopeId), eventName, event);
  }
  
  return event;
}

// Direct component-to-component communication
sendTo(targetComponentId, eventName, data = {}, options = {}) {
  const event = {
    id: generateUniqueId(),
    name: eventName,
    data,
    timestamp: Date.now(),
    source: options.source || null,
    target: targetComponentId,
    meta: options.meta || {}
  };
  
  // Record in history if enabled
  if (this._historyEnabled) {
    this._recordEvent(event);
  }
  
  // Dispatch to target component
  if (this._componentHandlers.has(targetComponentId)) {
    this._dispatchToHandlers(this._componentHandlers.get(targetComponentId), eventName, event);
  }
  
  return event;
}
```

### Event Subscription

The system provides methods to subscribe to different types of events:

```javascript
// Global event subscription
subscribe(eventName, handler, options = {}) {
  if (!this._globalHandlers.has(eventName)) {
    this._globalHandlers.set(eventName, new Set());
  }
  
  const handlerSet = this._globalHandlers.get(eventName);
  handlerSet.add(handler);
  
  // Return unsubscribe function
  return () => {
    if (this._globalHandlers.has(eventName)) {
      this._globalHandlers.get(eventName).delete(handler);
    }
  };
}

// Scoped event subscription
subscribeInScope(scopeId, eventName, handler, options = {}) {
  if (!this._scopedHandlers.has(scopeId)) {
    this._scopedHandlers.set(scopeId, new Map());
  }
  
  const scopeHandlers = this._scopedHandlers.get(scopeId);
  
  if (!scopeHandlers.has(eventName)) {
    scopeHandlers.set(eventName, new Set());
  }
  
  scopeHandlers.get(eventName).add(handler);
  
  // Return unsubscribe function
  return () => {
    if (
      this._scopedHandlers.has(scopeId) && 
      this._scopedHandlers.get(scopeId).has(eventName)
    ) {
      this._scopedHandlers.get(scopeId).get(eventName).delete(handler);
    }
  };
}

// Component-specific event subscription
subscribeComponent(componentId, eventName, handler, options = {}) {
  if (!this._componentHandlers.has(componentId)) {
    this._componentHandlers.set(componentId, new Map());
  }
  
  const componentHandlers = this._componentHandlers.get(componentId);
  
  if (!componentHandlers.has(eventName)) {
    componentHandlers.set(eventName, new Set());
  }
  
  componentHandlers.get(eventName).add(handler);
  
  // Return unsubscribe function
  return () => {
    if (
      this._componentHandlers.has(componentId) && 
      this._componentHandlers.get(componentId).has(eventName)
    ) {
      this._componentHandlers.get(componentId).get(eventName).delete(handler);
    }
  };
}
```

### Event Dispatch and History

Internal methods for event dispatch and history management:

```javascript
// Internal dispatch method
_dispatchToHandlers(handlersMap, eventName, event) {
  if (!handlersMap.has(eventName)) return;
  
  const handlers = handlersMap.get(eventName);
  
  // Dispatch event to all handlers
  for (const handler of handlers) {
    try {
      handler(event.data, event);
    } catch (error) {
      console.error(`Error in event handler for ${eventName}:`, error);
      
      // Record error in event history
      if (this._historyEnabled) {
        this._recordError(event, error);
      }
    }
  }
}

// Event history recording
_recordEvent(event) {
  this._eventHistory.push(event);
  
  // Trim history if it exceeds limit
  if (this._eventHistory.length > this._historyLimit) {
    this._eventHistory.shift();
  }
}

_recordError(event, error) {
  const errorEvent = {
    ...event,
    id: `error-${event.id}`,
    name: `error:${event.name}`,
    error: {
      message: error.message,
      stack: error.stack
    }
  };
  
  this._recordEvent(errorEvent);
}
```

### Debugging and Monitoring

Methods for debugging and monitoring events:

```javascript
// Retrieve event history
getEventHistory() {
  return [...this._eventHistory];
}

// Clear event history
clearEventHistory() {
  this._eventHistory = [];
}

// Enable/disable event history
setHistoryEnabled(enabled) {
  this._historyEnabled = enabled;
}

// Set history limit
setHistoryLimit(limit) {
  this._historyLimit = limit;
}

// Monitor specific events
monitorEvent(eventName, callback) {
  const wrappedCallback = (data, event) => {
    callback(event);
  };
  
  return this.subscribe(eventName, wrappedCallback, { monitoring: true });
}
```

## Integration with Component System

### Component Base Class Integration

The component base class will be extended with event bus integration:

```javascript
// assets/js/components/core/component_base.js
class HydeComponent {
  constructor(options = {}) {
    // Existing initialization
    
    // Store event unsubscribe functions for cleanup
    this._eventUnsubscribeFunctions = [];
  }
  
  // Event publication methods
  publish(eventName, data = {}) {
    return Bus.publish(eventName, data, {
      source: this.id
    });
  }
  
  publishInScope(scopeId, eventName, data = {}) {
    return Bus.publishInScope(scopeId, eventName, data, {
      source: this.id
    });
  }
  
  sendTo(targetComponentId, eventName, data = {}) {
    return Bus.sendTo(targetComponentId, eventName, data, {
      source: this.id
    });
  }
  
  // Event subscription methods
  subscribe(eventName, handler) {
    const unsubscribe = Bus.subscribe(eventName, handler);
    this._eventUnsubscribeFunctions.push(unsubscribe);
    return unsubscribe;
  }
  
  subscribeInScope(scopeId, eventName, handler) {
    const unsubscribe = Bus.subscribeInScope(scopeId, eventName, handler);
    this._eventUnsubscribeFunctions.push(unsubscribe);
    return unsubscribe;
  }
  
  // Lifecycle method overrides for cleanup
  destroy() {
    // Unsubscribe from all events
    this._eventUnsubscribeFunctions.forEach(unsubscribe => unsubscribe());
    this._eventUnsubscribeFunctions = [];
    
    // Call original destroy method
    if (typeof this._destroy === 'function') {
      this._destroy();
    }
  }
}
```

### Integration with Component Registry

The event bus will integrate with the component registry:

```javascript
// Register component lifecycle events
Registry.onMount('*', (component) => {
  Bus.publish('component:mounted', {
    componentId: component.id,
    componentType: component.type
  });
});

Registry.onUnmount('*', (component) => {
  Bus.publish('component:unmounted', {
    componentId: component.id,
    componentType: component.type
  });
  
  // Clean up component-specific handlers
  if (Bus._componentHandlers.has(component.id)) {
    Bus._componentHandlers.delete(component.id);
  }
});
```

## Usage Examples

### Basic Global Events

```javascript
// Publishing a global event
class Notification extends HydeComponent {
  showError(message) {
    this.publish('notification:error', {
      message,
      timestamp: Date.now()
    });
  }
}

// Subscribing to a global event
class ErrorLogger extends HydeComponent {
  constructor(options) {
    super(options);
    
    this.subscribe('notification:error', (data) => {
      console.error(`Error: ${data.message}`);
      this.logError(data);
    });
  }
}
```

### Scoped Events

```javascript
// Publishing a scoped event
class MenuItem extends HydeComponent {
  constructor(options) {
    super(options);
    this.context = 'main-menu';
  }
  
  select() {
    this.publishInScope('main-menu', 'item:selected', {
      id: this.id,
      label: this.label
    });
  }
}

// Subscribing to a scoped event
class MenuController extends HydeComponent {
  constructor(options) {
    super(options);
    
    this.subscribeInScope('main-menu', 'item:selected', (data) => {
      this.setActiveItem(data.id);
      this.render();
    });
  }
}
```

### Direct Component Communication

```javascript
// Sending a direct message to another component
class ShoppingCartButton extends HydeComponent {
  addToCart(productId, quantity) {
    this.sendTo('shopping-cart', 'add:item', {
      productId,
      quantity
    });
  }
}

// Receiving direct messages
class ShoppingCart extends HydeComponent {
  constructor(options) {
    super(options);
    
    // Register for component-specific messages
    Bus.subscribeComponent(this.id, 'add:item', (data) => {
      this.addItem(data.productId, data.quantity);
      this.updateCartUI();
    });
  }
}
```

### Combined with Component Registry

```javascript
// Using both registry and event bus
class Application extends HydeComponent {
  constructor(options) {
    super(options);
    
    // Listen for new modal components
    Registry.onMount('modal', (modal) => {
      // Update modal container when modal is mounted
      this.updateModalContainer();
    });
    
    // Listen for global user events
    this.subscribe('user:login', (userData) => {
      // Update all authenticated components
      const authComponents = Registry.findByTag('requires-auth');
      authComponents.forEach(component => {
        component.setAuthenticated(true, userData);
      });
    });
  }
}
```

## Integration with Debugging Tools

The event bus system integrates with debugging tools for monitoring and troubleshooting:

```javascript
// Event monitor component
class EventMonitor extends HydeComponent {
  constructor(options) {
    super(options);
    
    this.state = {
      events: [],
      filter: null
    };
    
    // Subscribe to all events for monitoring
    this._monitorAllEvents();
  }
  
  _monitorAllEvents() {
    // Use special wildcard subscription for monitoring
    const monitoringHandler = (data, event) => {
      this.state.events.push(event);
      if (this.state.events.length > 100) {
        this.state.events.shift();
      }
      this.render();
    };
    
    Bus.subscribe('*', monitoringHandler, { monitoring: true });
  }
  
  render() {
    // Render visualization of recent events
    // ...
  }
}
```

## Testing Strategy

The event bus system should be thoroughly tested:

1. **Unit Tests**:
   - Event publication and subscription
   - Scoped event handling
   - Direct component messaging
   - Error handling and recovery

2. **Integration Tests**:
   - Component system integration
   - Event propagation across components
   - Cleanup and memory management

3. **Performance Tests**:
   - High-volume event handling
   - Memory usage under load
   - Event dispatch timing

## Migration Path

To migrate existing components to use the event bus:

1. **Identify Current Patterns**: Document how components currently communicate
2. **Map to Event Patterns**: Create a mapping of current communication patterns to event-based patterns
3. **Incremental Conversion**: Convert one communication flow at a time
4. **Adapter Approach**: Create adapters for components that can't be immediately converted

## Performance Considerations

For optimal performance, the event bus implementation includes:

1. **Efficient Data Structures**: Using Maps and Sets for O(1) operation times
2. **Minimal Event Copying**: Avoid unnecessary object cloning
3. **Batched Updates**: Support for grouped events to reduce update cycles
4. **Error Containment**: Prevent one error from disrupting other handlers
5. **Conditional Debugging**: Performance-impacting features like history are only enabled in development

## Implementation Roadmap

1. **Week 1**:
   - Core event bus implementation
   - Basic publication and subscription methods
   - Component integration
   
2. **Week 2**:
   - Scoped events implementation
   - Direct component messaging
   - Debugging and monitoring tools
   - Testing and documentation
</rewritten_file> 