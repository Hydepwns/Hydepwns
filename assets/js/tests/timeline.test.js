/**
 * TimelineComponent Tests
 * ----------------------
 * Tests for the TimelineComponent class.
 */

import { TimelineComponent } from '../components/timeline';
import EventManager from '../components/event_manager';
import DOMCleanup from '../utils/dom_cleanup';

// Mock dependencies
jest.mock('../components/event_manager', () => ({
  registerComponent: jest.fn().mockReturnValue({
    addEventListener: jest.fn()
  }),
  unregisterComponent: jest.fn()
}));

jest.mock('../utils/dom_cleanup', () => ({
  register: jest.fn().mockReturnValue({
    cleanup: jest.fn(),
    addNode: jest.fn(),
    addCleanupFunction: jest.fn()
  })
}));

describe('TimelineComponent', () => {
  let component;
  let container;
  let timelineItems;
  
  // Mock requestAnimationFrame and setTimeout
  const originalRaf = window.requestAnimationFrame;
  
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Mock requestAnimationFrame
    window.requestAnimationFrame = jest.fn(callback => {
      return setTimeout(() => callback(Date.now()), 0);
    });
    
    // Mock performance.now
    if (!window.performance) {
      window.performance = {};
    }
    window.performance.now = jest.fn(() => Date.now());
    
    // Mock matchMedia
    window.matchMedia = jest.fn().mockReturnValue({
      matches: false
    });
    
    // Create container element
    container = document.createElement('div');
    container.className = 'timeline';
    document.body.appendChild(container);
    
    // Create timeline items
    timelineItems = [];
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.className = 'timeline-event';
      item.textContent = `Event ${i}`;
      
      // Mock focus and scrollIntoView methods
      item.focus = jest.fn();
      item.scrollIntoView = jest.fn();
      
      container.appendChild(item);
      timelineItems.push(item);
    }
    
    // Set up spies
    jest.spyOn(window, 'setTimeout');
    
    // Create spy for dispatchEvent
    container.dispatchEvent = jest.fn();
  });
  
  afterEach(() => {
    if (component) {
      component.destroy();
    }
    document.body.removeChild(container);
    
    // Restore original functions
    window.requestAnimationFrame = originalRaf;
    
    // Clear any timers that might be pending
    jest.clearAllTimers();
  });
  
  test('should initialize with default options', () => {
    component = new TimelineComponent({
      container
    });
    
    expect(component.options.animationEnabled).toBe(true);
    expect(component.options.debug).toBe(false);
  });
  
  test('should mount component and register with services', () => {
    component = new TimelineComponent({
      container
    }).mount();
    
    expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
    expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
    expect(component.elements.container).toBe(container);
    expect(component._state.isVertical).toBe(false);
  });
  
  test('should detect vertical timeline orientation', () => {
    // Add vertical class to container
    container.classList.add('vertical');
    
    component = new TimelineComponent({
      container
    }).mount();
    
    expect(component._state.isVertical).toBe(true);
  });
  
  test('should set up IntersectionObserver', () => {
    // Mock IntersectionObserver
    const mockObserve = jest.fn();
    const mockDisconnect = jest.fn();
    
    window.IntersectionObserver = jest.fn(() => ({
      observe: mockObserve,
      disconnect: mockDisconnect
    }));
    
    component = new TimelineComponent({
      container
    }).mount();
    
    expect(window.IntersectionObserver).toHaveBeenCalled();
    expect(mockObserve).toHaveBeenCalledWith(container);
    
    // Check that the cleanup function was registered
    expect(component.cleanup.addCleanupFunction).toHaveBeenCalled();
  });
  
  test('should handle keyboard navigation for horizontal timeline', () => {
    component = new TimelineComponent({
      container
    }).mount();
    
    expect(component._state.isVertical).toBe(false);
    
    // Get event listener callback for keydown
    const events = EventManager.registerComponent.mock.results[0].value;
    const keydownCallbacks = events.addEventListener.mock.calls
      .filter(call => call[1] === 'keydown')
      .map(call => call[2]);
    
    // The first item's keydown handler
    const firstItemCallback = keydownCallbacks[0];
    
    // Mock right arrow press on first item
    firstItemCallback({ 
      key: 'ArrowRight', 
      preventDefault: jest.fn() 
    });
    
    // Check that second item was focused
    expect(timelineItems[1].focus).toHaveBeenCalled();
    expect(timelineItems[1].scrollIntoView).toHaveBeenCalled();
    
    // Check that event was dispatched
    expect(container.dispatchEvent).toHaveBeenCalled();
    expect(container.dispatchEvent.mock.calls[0][0].type).toBe('timelineNavigation');
    expect(container.dispatchEvent.mock.calls[0][0].detail.index).toBe(1);
    
    // The second item's keydown handler
    const secondItemCallback = keydownCallbacks[1];
    
    // Mock left arrow press on second item
    secondItemCallback({ 
      key: 'ArrowLeft', 
      preventDefault: jest.fn() 
    });
    
    // Check that first item was focused
    expect(timelineItems[0].focus).toHaveBeenCalled();
  });
  
  test('should handle keyboard navigation for vertical timeline', () => {
    // Add vertical class to container
    container.classList.add('vertical');
    
    component = new TimelineComponent({
      container
    }).mount();
    
    expect(component._state.isVertical).toBe(true);
    
    // Get event listener callback for keydown
    const events = EventManager.registerComponent.mock.results[0].value;
    const keydownCallbacks = events.addEventListener.mock.calls
      .filter(call => call[1] === 'keydown')
      .map(call => call[2]);
    
    // The first item's keydown handler
    const firstItemCallback = keydownCallbacks[0];
    
    // Mock down arrow press on first item
    firstItemCallback({ 
      key: 'ArrowDown', 
      preventDefault: jest.fn() 
    });
    
    // Check that second item was focused
    expect(timelineItems[1].focus).toHaveBeenCalled();
    
    // The second item's keydown handler
    const secondItemCallback = keydownCallbacks[1];
    
    // Mock up arrow press on second item
    secondItemCallback({ 
      key: 'ArrowUp', 
      preventDefault: jest.fn() 
    });
    
    // Check that first item was focused
    expect(timelineItems[0].focus).toHaveBeenCalled();
  });
  
  test('should handle Enter/Space to activate item', () => {
    component = new TimelineComponent({
      container
    }).mount();
    
    // Get event listener callback for keydown
    const events = EventManager.registerComponent.mock.results[0].value;
    const keydownCallbacks = events.addEventListener.mock.calls
      .filter(call => call[1] === 'keydown')
      .map(call => call[2]);
    
    // Mock item click for testing
    timelineItems[0].click = jest.fn();
    
    // The first item's keydown handler
    const firstItemCallback = keydownCallbacks[0];
    
    // Mock Enter keypress
    firstItemCallback({ 
      key: 'Enter', 
      preventDefault: jest.fn() 
    });
    
    // Check that item was clicked
    expect(timelineItems[0].click).toHaveBeenCalled();
    
    // Mock Space keypress
    firstItemCallback({ 
      key: ' ', 
      preventDefault: jest.fn() 
    });
    
    // Check that item was clicked again
    expect(timelineItems[0].click).toHaveBeenCalledTimes(2);
  });
  
  test('should animate timeline items when visible', () => {
    // Mock IntersectionObserver to trigger visibility
    let observerCallback;
    window.IntersectionObserver = jest.fn(callback => {
      observerCallback = callback;
      return {
        observe: jest.fn(),
        disconnect: jest.fn()
      };
    });
    
    jest.useFakeTimers();
    
    component = new TimelineComponent({
      container
    }).mount();
    
    // Make it visible
    observerCallback([{ isIntersecting: true }]);
    expect(component._state.inViewport).toBe(true);
    
    // Check that setTimeout was called for each timeline item
    expect(window.setTimeout).toHaveBeenCalledTimes(3);
    
    // Verify event dispatch for visibility change
    expect(container.dispatchEvent).toHaveBeenCalled();
    expect(container.dispatchEvent.mock.calls[0][0].type).toBe('timelineVisibilityChange');
    expect(container.dispatchEvent.mock.calls[0][0].detail.visible).toBe(true);
    
    // Fast-forward timers
    jest.runAllTimers();
    
    // Check that styles were applied to animate items
    expect(timelineItems[0].style.opacity).toBe('1');
    expect(timelineItems[0].style.transform).toBe('translate(0, 0)');
  });
  
  test('should respect prefers-reduced-motion setting', () => {
    // Mock matchMedia to simulate reduced motion preference
    window.matchMedia = jest.fn().mockReturnValue({
      matches: true
    });
    
    component = new TimelineComponent({
      container
    }).mount();
    
    expect(component._state.animationAllowed).toBe(false);
  });
  
  test('should allow replaying animation via the API', () => {
    component = new TimelineComponent({
      container
    }).mount();
    
    // Set inViewport to true to allow animation
    component._state.inViewport = true;
    
    // Clear previous calls
    window.requestAnimationFrame.mockClear();
    
    // Replay animation
    component.replayAnimation();
    
    // Should use requestAnimationFrame for animation
    expect(window.requestAnimationFrame).toHaveBeenCalled();
    
    // Verify event dispatch for animation replay
    expect(container.dispatchEvent).toHaveBeenCalled();
    expect(container.dispatchEvent.mock.calls[0][0].type).toBe('timelineAnimationReplay');
  });
  
  test('should handle Alt+R keyboard shortcut for replaying animation', () => {
    component = new TimelineComponent({
      container
    }).mount();
    
    // Mock replayAnimation method
    component._replayAnimation = jest.fn();
    
    // Get global keydown handler
    const globalKeydownHandler = EventManager.registerComponent.mock.results[0].value.addEventListener.mock.calls
      .find(call => call[0] === window && call[1] === 'keydown')[2];
    
    // Mock Alt+R keypress
    const preventDefaultMock = jest.fn();
    globalKeydownHandler({ 
      altKey: true, 
      key: 'r', 
      preventDefault: preventDefaultMock 
    });
    
    // Check that animation was replayed
    expect(component._replayAnimation).toHaveBeenCalled();
    expect(preventDefaultMock).toHaveBeenCalled();
  });
  
  test('should provide focusItem API method', () => {
    component = new TimelineComponent({
      container
    }).mount();
    
    // Focus second item
    component.focusItem(1);
    
    // Second item should be focused and scrolled into view
    expect(timelineItems[1].focus).toHaveBeenCalled();
    expect(timelineItems[1].scrollIntoView).toHaveBeenCalled();
  });
  
  test('should provide getItemCount API method', () => {
    component = new TimelineComponent({
      container
    }).mount();
    
    expect(component.getItemCount()).toBe(3);
  });
  
  test('should properly clean up resources when destroyed', () => {
    // Mock IntersectionObserver
    window.IntersectionObserver = jest.fn(() => ({
      observe: jest.fn(),
      disconnect: jest.fn()
    }));
    
    component = new TimelineComponent({
      container
    }).mount();
    
    // Spy on observer disconnect
    const disconnect = jest.fn();
    component.observer = { disconnect };
    
    // Destroy component
    component.destroy();
    
    // Check that observer was disconnected
    expect(disconnect).toHaveBeenCalled();
    
    // Check that cleanup was called
    expect(component.cleanup.cleanup).toHaveBeenCalled();
    expect(EventManager.unregisterComponent).toHaveBeenCalledWith(component.componentId);
    
    // Check that resources were cleared
    expect(component.elements).toEqual({});
    expect(component._state).toEqual({});
  });
}); 