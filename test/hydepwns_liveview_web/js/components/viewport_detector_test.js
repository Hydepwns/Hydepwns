/**
 * Viewport Detector Component Tests
 * --------------------------------
 * Tests for the ViewportDetectorComponent class.
 */

import { ViewportDetectorComponent } from '../../../../assets/js/components/viewport_detector';
import EventManager from '../../../../assets/js/components/event_manager';
import DOMCleanup from '../../../../assets/js/utils/dom_cleanup';

// Mock dependencies
jest.mock('../../../../assets/js/components/event_manager', () => {
  // Create a mock function that stores handlers
  const eventHandlers = new Map();
  
  const addEventListener = jest.fn((element, eventName, handler) => {
    // Store the handler for retrieval in tests
    const key = `${element.toString()}-${eventName}`;
    eventHandlers.set(key, handler);
  });
  
  return {
    registerComponent: jest.fn().mockReturnValue({
      addEventListener,
      addDelegatedEventListener: jest.fn()
    }),
    unregisterComponent: jest.fn(),
    // Helper for tests to access the stored handlers
    __getHandler: (element, eventName) => {
      const key = `${element.toString()}-${eventName}`;
      return eventHandlers.get(key);
    }
  };
});

jest.mock('../../../../assets/js/utils/dom_cleanup', () => ({
  register: jest.fn().mockReturnValue({
    cleanup: jest.fn(),
    registerElement: jest.fn(),
    registerInterval: jest.fn(),
    registerTimeout: jest.fn(),
    registerCleanupFunction: jest.fn()
  })
}));

describe('ViewportDetectorComponent', () => {
  let component;
  let mockLiveViewHook;
  let originalInnerWidth;
  let originalInnerHeight;
  let dispatchEventSpy;
  let originalClearTimeout;
  
  // Setup for tests
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Store original window dimensions
    originalInnerWidth = window.innerWidth;
    originalInnerHeight = window.innerHeight;
    
    // Store original clearTimeout
    originalClearTimeout = window.clearTimeout;
    window.clearTimeout = jest.fn();
    
    // Set initial window dimensions for testing
    Object.defineProperty(window, 'innerWidth', { value: 1200, configurable: true });
    Object.defineProperty(window, 'innerHeight', { value: 800, configurable: true });
    
    // Mock document functions
    document.documentElement.style.setProperty = jest.fn();
    document.body.classList.remove = jest.fn();
    document.body.classList.add = jest.fn();
    
    // Create spy for window.dispatchEvent
    dispatchEventSpy = jest.spyOn(window, 'dispatchEvent');
    
    // Create mock LiveView hook
    mockLiveViewHook = {
      pushEvent: jest.fn(),
      pushEventTo: jest.fn()
    };

    // Create component instance
    component = new ViewportDetectorComponent({
      throttleTime: 100,
      liveViewHook: mockLiveViewHook,
      debug: false
    });
  });
  
  // Cleanup after tests
  afterEach(() => {
    // Restore clearTimeout before destroying component
    // to avoid the error in the destroy method
    window.clearTimeout = originalClearTimeout;
    
    if (component) {
      component.destroy();
    }
    
    // Restore original window dimensions
    Object.defineProperty(window, 'innerWidth', { value: originalInnerWidth, configurable: true });
    Object.defineProperty(window, 'innerHeight', { value: originalInnerHeight, configurable: true });
    
    // Restore window.dispatchEvent
    dispatchEventSpy.mockRestore();
    
    component = null;
    
    // Clear any timeouts
    jest.clearAllTimers();
  });
  
  test('should initialize with correct default properties', () => {
    expect(component.componentId).toMatch(/^viewport-detector-[a-z0-9]{7}$/);
    expect(component.options.throttleTime).toBe(100);
    expect(component.options.liveViewHook).toBe(mockLiveViewHook);
    expect(component.options.debug).toBe(false);
    expect(component._state.currentSize).toBeNull();
    expect(component._state.resizeTimeout).toBeNull();
  });
  
  test('should properly mount the component', () => {
    // Mount the component
    component.mount();
    
    // Verify EventManager and DOMCleanup were used correctly
    expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
    expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
    
    // Verify current size was set to desktop (1200px width)
    expect(component._state.currentSize).toBe('desktop');
    
    // Verify event listener was set up
    expect(component.events.addEventListener).toHaveBeenCalledWith(
      window,
      'resize',
      expect.any(Function)
    );
    
    // Verify initial size was pushed
    expect(mockLiveViewHook.pushEvent).toHaveBeenCalledWith(
      'update_viewport_size',
      {
        size: 'desktop',
        width: 1200,
        height: 800
      }
    );
    
    // Verify CSS variables and classes were set
    expect(document.documentElement.style.setProperty).toHaveBeenCalledWith(
      '--viewport-size',
      '"desktop"'
    );
    expect(document.body.classList.add).toHaveBeenCalledWith('viewport-desktop');
    
    // Verify custom event was dispatched
    expect(dispatchEventSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        type: 'viewport-changed',
        detail: {
          size: 'desktop',
          width: 1200,
          height: 800
        }
      })
    );
  });
  
  test('should properly destroy the component', () => {
    // Mount first, then destroy
    component.mount();
    
    // Verify component is properly set up
    expect(component.cleanup).toBeTruthy();
    expect(component.events).toBeTruthy();
    
    // Destroy the component
    component.destroy();
    
    // Verify cleanup was called
    expect(component.cleanup.cleanup).toHaveBeenCalled();
    expect(EventManager.unregisterComponent).toHaveBeenCalledWith(component.componentId);
    
    // Verify viewport classes were removed
    expect(document.body.classList.remove).toHaveBeenCalledWith(
      'viewport-mobile',
      'viewport-tablet',
      'viewport-desktop'
    );
    
    // Verify references were cleared
    expect(component._state).toEqual({});
  });
  
  test('should detect mobile viewport size', () => {
    // Set mobile viewport size
    Object.defineProperty(window, 'innerWidth', { value: 480, configurable: true });
    
    // Mount component
    component.mount();
    
    // Verify correct size detection
    expect(component._state.currentSize).toBe('mobile');
    
    // Verify CSS and event data
    expect(document.documentElement.style.setProperty).toHaveBeenCalledWith(
      '--viewport-size',
      '"mobile"'
    );
    expect(document.body.classList.add).toHaveBeenCalledWith('viewport-mobile');
    expect(mockLiveViewHook.pushEvent).toHaveBeenCalledWith(
      'update_viewport_size',
      {
        size: 'mobile',
        width: 480,
        height: 800
      }
    );
  });
  
  test('should detect tablet viewport size', () => {
    // Set tablet viewport size
    Object.defineProperty(window, 'innerWidth', { value: 900, configurable: true });
    
    // Mount component
    component.mount();
    
    // Verify correct size detection
    expect(component._state.currentSize).toBe('tablet');
    
    // Verify CSS and event data
    expect(document.documentElement.style.setProperty).toHaveBeenCalledWith(
      '--viewport-size',
      '"tablet"'
    );
    expect(document.body.classList.add).toHaveBeenCalledWith('viewport-tablet');
    expect(mockLiveViewHook.pushEvent).toHaveBeenCalledWith(
      'update_viewport_size',
      {
        size: 'tablet',
        width: 900,
        height: 800
      }
    );
  });
  
  test('should handle resize events with throttling', () => {
    // Setup
    jest.useFakeTimers();
    component.mount();
    
    // Clear initial calls
    jest.clearAllMocks();
    
    // Get the resize handler from our custom helper
    const resizeHandler = EventManager.__getHandler(window, 'resize');
    
    // Make sure we found a handler
    expect(resizeHandler).toBeTruthy();
    
    // Trigger resize event
    resizeHandler();
    
    // Verify timeout was set
    expect(component.cleanup.registerTimeout).toHaveBeenCalled();
    
    // Change viewport size
    Object.defineProperty(window, 'innerWidth', { value: 500, configurable: true });
    
    // Fast-forward timers
    jest.advanceTimersByTime(100);
    
    // Verify size update was processed after throttle time
    expect(component._state.currentSize).toBe('mobile');
    expect(mockLiveViewHook.pushEvent).toHaveBeenCalledWith(
      'update_viewport_size',
      {
        size: 'mobile',
        width: 500,
        height: 800
      }
    );
    
    jest.useRealTimers();
  });
  
  test('should not update if size category remains the same', () => {
    // Setup
    jest.useFakeTimers();
    component.mount();
    
    // Clear initial calls
    jest.clearAllMocks();
    
    // Get the resize handler from our custom helper
    const resizeHandler = EventManager.__getHandler(window, 'resize');
    
    // Make sure we found a handler
    expect(resizeHandler).toBeTruthy();
    
    // Change viewport size but stay in same category (desktop > 1024px)
    Object.defineProperty(window, 'innerWidth', { value: 1100, configurable: true });
    
    // Trigger resize event
    resizeHandler();
    
    // Fast-forward timers
    jest.advanceTimersByTime(100);
    
    // Verify no update was sent since the category is still desktop
    expect(mockLiveViewHook.pushEvent).not.toHaveBeenCalled();
    expect(document.documentElement.style.setProperty).not.toHaveBeenCalled();
    
    jest.useRealTimers();
  });
  
  test('should handle multiple resize events within throttle time', () => {
    // Setup
    jest.useFakeTimers();
    component.mount();
    
    // Clear initial calls
    jest.clearAllMocks();
    
    // Get the resize handler from our custom helper
    const resizeHandler = EventManager.__getHandler(window, 'resize');
    
    // Make sure we found a handler
    expect(resizeHandler).toBeTruthy();
    
    // Trigger first resize event
    resizeHandler();
    
    // Verify a timeout was registered
    expect(component.cleanup.registerTimeout).toHaveBeenCalledTimes(1);
    
    // Trigger second resize event before throttle time completes
    resizeHandler();
    
    // Verify a new timeout was registered
    expect(component.cleanup.registerTimeout).toHaveBeenCalledTimes(2);
    
    jest.useRealTimers();
  });
  
  test('should update component state correctly', () => {
    // Set new state
    component._setState({ currentSize: 'mobile', testValue: 'test' });
    
    // Verify state was updated correctly
    expect(component._state.currentSize).toBe('mobile');
    expect(component._state.testValue).toBe('test');
  });
  
  test('should handle missing LiveView hook gracefully', () => {
    // Create component without LiveView hook
    const noHookComponent = new ViewportDetectorComponent({
      debug: true
    });
    
    // Mount component
    noHookComponent.mount();
    
    // Verify no error occurs
    expect(noHookComponent._state.currentSize).toBe('desktop');
    
    // Restore clearTimeout before destroying component
    window.clearTimeout = originalClearTimeout;
    
    // Clean up
    noHookComponent.destroy();
  });
  
  test('should dispatch custom event when viewport changes', () => {
    // Setup
    jest.useFakeTimers();
    component.mount();
    
    // Clear initial calls
    dispatchEventSpy.mockClear();
    
    // Get the resize handler from our custom helper
    const resizeHandler = EventManager.__getHandler(window, 'resize');
    
    // Make sure we found a handler
    expect(resizeHandler).toBeTruthy();
    
    // Change viewport size
    Object.defineProperty(window, 'innerWidth', { value: 500, configurable: true });
    
    // Trigger resize event
    resizeHandler();
    
    // Fast-forward timers
    jest.advanceTimersByTime(100);
    
    // Verify event was dispatched
    expect(dispatchEventSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        type: 'viewport-changed',
        detail: {
          size: 'mobile',
          width: 500,
          height: 800
        }
      })
    );
    
    jest.useRealTimers();
  });
}); 