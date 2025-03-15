/**
 * Event Manager Tests
 * -----------------
 * Comprehensive test suite for the EventManager singleton that handles
 * event registration, delegation, and cleanup across components.
 */

import EventManager from '../components/event_manager';

describe('EventManager', () => {
  let testContainer;
  let componentId;
  let componentAPI;
  
  beforeEach(() => {
    // Reset any internal state
    EventManager._eventRegistry = {};
    EventManager._domListeners = {};
    
    // Create test container
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Generate unique component ID for each test
    componentId = `test-component-${Math.random().toString(36).substring(2, 9)}`;
    
    // Get component API
    componentAPI = EventManager.registerComponent(componentId);
  });
  
  afterEach(() => {
    // Clean up test container
    if (testContainer && testContainer.parentNode) {
      testContainer.parentNode.removeChild(testContainer);
    }
    testContainer = null;
    
    // Unregister component
    EventManager.unregisterComponent(componentId);
  });
  
  describe('Component Registration', () => {
    test('should register component and return API', () => {
      expect(componentAPI).toBeTruthy();
      expect(typeof componentAPI.addEventListener).toBe('function');
      expect(typeof componentAPI.removeEventListener).toBe('function');
      expect(typeof componentAPI.addDelegatedEventListener).toBe('function');
      expect(typeof componentAPI.cleanup).toBe('function');
    });
    
    test('should handle missing component ID', () => {
      const consoleSpy = jest.spyOn(console, 'error');
      const api = EventManager.registerComponent();
      
      expect(api).toBeNull();
      expect(consoleSpy).toHaveBeenCalledWith('EventManager: Component ID is required');
      
      consoleSpy.mockRestore();
    });
    
    test('should allow multiple registrations of same component', () => {
      const api1 = EventManager.registerComponent(componentId);
      const api2 = EventManager.registerComponent(componentId);
      
      expect(api1).toBeTruthy();
      expect(api2).toBeTruthy();
    });
  });
  
  describe('Event Listeners', () => {
    test('should add and trigger event listener', () => {
      const button = document.createElement('button');
      testContainer.appendChild(button);
      
      const handler = jest.fn();
      componentAPI.addEventListener(button, 'click', handler);
      
      button.click();
      expect(handler).toHaveBeenCalled();
    });
    
    test('should handle missing parameters in addEventListener', () => {
      const consoleSpy = jest.spyOn(console, 'error');
      
      componentAPI.addEventListener();
      expect(consoleSpy).toHaveBeenCalledWith(
        'EventManager: Missing required parameters for addEventListener'
      );
      
      consoleSpy.mockRestore();
    });
    
    test('should remove specific event listener', () => {
      const button = document.createElement('button');
      testContainer.appendChild(button);
      
      const handler = jest.fn();
      const listenerId = componentAPI.addEventListener(button, 'click', handler);
      
      componentAPI.removeEventListener(listenerId);
      button.click();
      
      expect(handler).not.toHaveBeenCalled();
    });
    
    test('should handle removing non-existent listener', () => {
      componentAPI.removeEventListener('non-existent-id');
      // Should not throw error
    });
  });
  
  describe('Event Delegation', () => {
    test('should handle delegated events', () => {
      const parent = document.createElement('div');
      const child = document.createElement('button');
      child.className = 'target-button';
      parent.appendChild(child);
      testContainer.appendChild(parent);
      
      const handler = jest.fn();
      componentAPI.addDelegatedEventListener(parent, 'click', '.target-button', handler);
      
      child.click();
      expect(handler).toHaveBeenCalled();
      expect(handler.mock.calls[0][1]).toBe(child); // Second arg should be target element
    });
    
    test('should not trigger delegated handler for non-matching elements', () => {
      const parent = document.createElement('div');
      const child = document.createElement('button');
      child.className = 'other-button';
      parent.appendChild(child);
      testContainer.appendChild(parent);
      
      const handler = jest.fn();
      componentAPI.addDelegatedEventListener(parent, 'click', '.target-button', handler);
      
      child.click();
      expect(handler).not.toHaveBeenCalled();
    });
    
    test('should handle missing parameters in addDelegatedEventListener', () => {
      const consoleSpy = jest.spyOn(console, 'error');
      
      componentAPI.addDelegatedEventListener();
      expect(consoleSpy).toHaveBeenCalledWith(
        'EventManager: Missing required parameters for addDelegatedEventListener'
      );
      
      consoleSpy.mockRestore();
    });
  });
  
  describe('Cleanup', () => {
    test('should clean up all event listeners for component', () => {
      const button1 = document.createElement('button');
      const button2 = document.createElement('button');
      testContainer.appendChild(button1);
      testContainer.appendChild(button2);
      
      const handler1 = jest.fn();
      const handler2 = jest.fn();
      
      componentAPI.addEventListener(button1, 'click', handler1);
      componentAPI.addEventListener(button2, 'click', handler2);
      
      componentAPI.cleanup();
      
      button1.click();
      button2.click();
      
      expect(handler1).not.toHaveBeenCalled();
      expect(handler2).not.toHaveBeenCalled();
    });
    
    test('should handle cleanup of non-existent component', () => {
      EventManager.unregisterComponent('non-existent-component');
      // Should not throw error
    });
    
    test('should clean up delegated event listeners', () => {
      const parent = document.createElement('div');
      const child = document.createElement('button');
      child.className = 'target-button';
      parent.appendChild(child);
      testContainer.appendChild(parent);
      
      const handler = jest.fn();
      componentAPI.addDelegatedEventListener(parent, 'click', '.target-button', handler);
      
      componentAPI.cleanup();
      
      child.click();
      expect(handler).not.toHaveBeenCalled();
    });
  });
  
  describe('Edge Cases', () => {
    test('should handle rapid registration/unregistration', () => {
      for (let i = 0; i < 100; i++) {
        const tempId = `temp-component-${i}`;
        const api = EventManager.registerComponent(tempId);
        EventManager.unregisterComponent(tempId);
      }
      
      // Original component should still work
      const button = document.createElement('button');
      testContainer.appendChild(button);
      
      const handler = jest.fn();
      componentAPI.addEventListener(button, 'click', handler);
      
      button.click();
      expect(handler).toHaveBeenCalled();
    });
    
    test('should handle cleanup of removed DOM elements', () => {
      const button = document.createElement('button');
      testContainer.appendChild(button);
      
      const handler = jest.fn();
      componentAPI.addEventListener(button, 'click', handler);
      
      // Remove button from DOM
      button.remove();
      
      // Cleanup should not throw error
      componentAPI.cleanup();
    });
    
    test('should handle multiple event types on same element', () => {
      const button = document.createElement('button');
      testContainer.appendChild(button);
      
      const clickHandler = jest.fn();
      const mouseoverHandler = jest.fn();
      
      componentAPI.addEventListener(button, 'click', clickHandler);
      componentAPI.addEventListener(button, 'mouseover', mouseoverHandler);
      
      button.click();
      button.dispatchEvent(new MouseEvent('mouseover'));
      
      expect(clickHandler).toHaveBeenCalled();
      expect(mouseoverHandler).toHaveBeenCalled();
    });
  });
}); 