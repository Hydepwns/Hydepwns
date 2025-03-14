/**
 * EventBus Tests
 * 
 * Unit tests for the EventBus functionality, covering:
 * - Global publish/subscribe
 * - Scoped events
 * - Direct component messaging
 * - Subscription management and cleanup
 */

import EventBus from '../components/core/event_bus';
import Registry from '../components/core/component_registry';

// Mock component for testing
class MockComponent {
  constructor(id) {
    this.id = id;
    this.messageReceived = null;
    this.eventReceived = null;
  }
  
  onMessage(message) {
    this.messageReceived = message;
  }
}

// Reset before each test
beforeEach(() => {
  // Use the private _reset method to clear event bus state
  EventBus._reset();
  
  // Reset the Registry as well (it's a singleton too)
  Registry._components = new Map();
  Registry._typeIndex = new Map();
  Registry._contextIndex = new Map();
  Registry._tagIndex = new Map();
});

describe('EventBus - Global Events', () => {
  test('should subscribe to and publish global events', () => {
    // Setup
    const mockHandler = jest.fn();
    const testData = { message: 'Hello World' };
    
    // Subscribe to event
    const subscriptionId = EventBus.subscribe('test-event', mockHandler);
    
    // Verify subscription created
    expect(subscriptionId).toBeTruthy();
    
    // Publish event
    const notifiedCount = EventBus.publish('test-event', testData);
    
    // Verify handler was called
    expect(notifiedCount).toBe(1);
    expect(mockHandler).toHaveBeenCalledTimes(1);
    expect(mockHandler).toHaveBeenCalledWith(
      expect.objectContaining({
        name: 'test-event',
        data: testData
      })
    );
  });
  
  test('should allow multiple subscribers to same event', () => {
    // Setup
    const handler1 = jest.fn();
    const handler2 = jest.fn();
    const handler3 = jest.fn();
    
    // Subscribe multiple handlers
    EventBus.subscribe('multi-event', handler1);
    EventBus.subscribe('multi-event', handler2);
    EventBus.subscribe('multi-event', handler3);
    
    // Publish event
    const notifiedCount = EventBus.publish('multi-event', { value: 42 });
    
    // Verify all handlers were called
    expect(notifiedCount).toBe(3);
    expect(handler1).toHaveBeenCalledTimes(1);
    expect(handler2).toHaveBeenCalledTimes(1);
    expect(handler3).toHaveBeenCalledTimes(1);
  });
  
  test('should not notify when no subscribers exist', () => {
    // Publish to non-existent event
    const notifiedCount = EventBus.publish('no-subscribers', { value: 'test' });
    
    // Verify no notifications
    expect(notifiedCount).toBe(0);
  });
  
  test('should handle errors in subscribers without affecting others', () => {
    // Setup
    const goodHandler1 = jest.fn();
    const badHandler = jest.fn().mockImplementation(() => {
      throw new Error('Subscriber error');
    });
    const goodHandler2 = jest.fn();
    
    // Mock console.error to prevent test output clutter
    const originalConsoleError = console.error;
    console.error = jest.fn();
    
    // Subscribe handlers
    EventBus.subscribe('error-test', goodHandler1);
    EventBus.subscribe('error-test', badHandler);
    EventBus.subscribe('error-test', goodHandler2);
    
    // Publish event
    const notifiedCount = EventBus.publish('error-test', { value: 'test' });
    
    // Restore console.error
    console.error = originalConsoleError;
    
    // Verify error handling
    expect(notifiedCount).toBe(2); // Only successful handlers are counted
    expect(goodHandler1).toHaveBeenCalledTimes(1);
    expect(badHandler).toHaveBeenCalledTimes(1);
    expect(goodHandler2).toHaveBeenCalledTimes(1);
  });
});

describe('EventBus - Scoped Events', () => {
  test('should subscribe to and publish scoped events', () => {
    // Setup
    const mockHandler = jest.fn();
    const testData = { message: 'Scoped Hello' };
    const testScope = 'test-scope';
    
    // Subscribe to scoped event
    const subscriptionId = EventBus.subscribeScoped(testScope, 'scoped-event', mockHandler);
    
    // Verify subscription created
    expect(subscriptionId).toBeTruthy();
    
    // Publish scoped event
    const notifiedCount = EventBus.publishScoped(testScope, 'scoped-event', testData);
    
    // Verify handler was called
    expect(notifiedCount).toBe(1);
    expect(mockHandler).toHaveBeenCalledTimes(1);
    expect(mockHandler).toHaveBeenCalledWith(
      expect.objectContaining({
        name: 'scoped-event',
        scope: testScope,
        data: testData
      })
    );
  });
  
  test('should keep scoped events isolated from other scopes', () => {
    // Setup
    const handlerScopeA = jest.fn();
    const handlerScopeB = jest.fn();
    
    // Subscribe to events in different scopes
    EventBus.subscribeScoped('scope-a', 'isolated-event', handlerScopeA);
    EventBus.subscribeScoped('scope-b', 'isolated-event', handlerScopeB);
    
    // Publish event to scope A only
    const notifiedCount = EventBus.publishScoped('scope-a', 'isolated-event', { value: 'test' });
    
    // Verify only scope A handler was called
    expect(notifiedCount).toBe(1);
    expect(handlerScopeA).toHaveBeenCalledTimes(1);
    expect(handlerScopeB).not.toHaveBeenCalled();
  });
});

describe('EventBus - Direct Messaging', () => {
  test('should send messages directly to components', () => {
    // Register mock component
    const mockComponent = new MockComponent('test-component');
    Registry.register(mockComponent, 'MockComponent');
    
    // Send direct message
    const result = EventBus.sendToComponent('test-component', 'direct-message', { value: 42 });
    
    // Verify message was received
    expect(result).toBe(true);
    expect(mockComponent.messageReceived).toEqual(
      expect.objectContaining({
        name: 'direct-message',
        data: { value: 42 },
        target: 'test-component'
      })
    );
  });
  
  test('should fail gracefully when component not found', () => {
    // Attempt to send to non-existent component
    const result = EventBus.sendToComponent('nonexistent-component', 'test-message', {});
    
    // Verify failure
    expect(result).toBe(false);
  });
  
  test('should fail gracefully when component does not implement onMessage', () => {
    // Register component without onMessage
    const invalidComponent = { id: 'invalid-component' };
    Registry.register(invalidComponent, 'InvalidComponent');
    
    // Attempt to send message
    const result = EventBus.sendToComponent('invalid-component', 'test-message', {});
    
    // Verify failure
    expect(result).toBe(false);
  });
});

describe('EventBus - Subscription Management', () => {
  test('should unsubscribe individual subscriptions', () => {
    // Setup
    const handler = jest.fn();
    
    // Subscribe
    const subscriptionId = EventBus.subscribe('unsubscribe-test', handler);
    
    // Unsubscribe
    const result = EventBus.unsubscribe(subscriptionId);
    
    // Verify unsubscription
    expect(result).toBe(true);
    
    // Publish event
    EventBus.publish('unsubscribe-test', { value: 'test' });
    
    // Verify handler not called
    expect(handler).not.toHaveBeenCalled();
  });
  
  test('should unsubscribe all component subscriptions', () => {
    // Setup
    const handler1 = jest.fn();
    const handler2 = jest.fn();
    const componentId = 'test-component-123';
    
    // Subscribe with component ID
    EventBus.subscribe('event1', handler1, { componentId });
    EventBus.subscribeScoped('test-scope', 'event2', handler2, { componentId });
    
    // Unsubscribe all for component
    const removedCount = EventBus.unsubscribeComponent(componentId);
    
    // Verify unsubscription
    expect(removedCount).toBe(2);
    
    // Publish events
    EventBus.publish('event1', { value: 'test' });
    EventBus.publishScoped('test-scope', 'event2', { value: 'test' });
    
    // Verify handlers not called
    expect(handler1).not.toHaveBeenCalled();
    expect(handler2).not.toHaveBeenCalled();
  });
});

describe('EventBus - Statistics and History', () => {
  test('should track event statistics', () => {
    // Perform various operations
    EventBus.subscribe('stats-test', () => {});
    EventBus.subscribeScoped('stats-scope', 'stats-test', () => {});
    
    EventBus.publish('stats-test', { value: 1 });
    EventBus.publish('stats-test', { value: 2 });
    EventBus.publishScoped('stats-scope', 'stats-test', { value: 3 });
    
    // Register mock component for direct messaging
    const mockComponent = new MockComponent('stats-component');
    Registry.register(mockComponent, 'MockComponent');
    EventBus.sendToComponent('stats-component', 'stats-message', { value: 4 });
    
    // Get stats
    const stats = EventBus.getStats();
    
    // Verify stats tracking
    expect(stats.eventsPublished).toBe(2);
    expect(stats.scopedEventsPublished).toBe(1);
    expect(stats.directMessagesPublished).toBe(1);
  });
  
  test('should maintain event history', () => {
    // Publish various events
    EventBus.publish('history-test-1', { value: 1 });
    EventBus.publishScoped('history-scope', 'history-test-2', { value: 2 });
    
    // Register mock component for direct messaging
    const mockComponent = new MockComponent('history-component');
    Registry.register(mockComponent, 'MockComponent');
    EventBus.sendToComponent('history-component', 'history-message', { value: 3 });
    
    // Get history
    const history = EventBus.getHistory();
    
    // Verify history tracking
    expect(history.length).toBe(3);
    expect(history[0].type).toBe('global');
    expect(history[1].type).toBe('scoped');
    expect(history[2].type).toBe('direct');
  });
  
  test('should respect history limit', () => {
    // Set small history limit
    EventBus.setHistoryLimit(2);
    
    // Publish events
    EventBus.publish('limit-test-1', { value: 1 });
    EventBus.publish('limit-test-2', { value: 2 });
    EventBus.publish('limit-test-3', { value: 3 });
    
    // Get history
    const history = EventBus.getHistory();
    
    // Verify only most recent events kept
    expect(history.length).toBe(2);
    expect(history[0].name).toBe('limit-test-2');
    expect(history[1].name).toBe('limit-test-3');
  });
}); 