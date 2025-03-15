/**
 * Lazy Load Component Tests
 * -----------------------
 * Jest test suite for the LazyLoadComponent class.
 */

import { LazyLoadComponent } from '../components/lazy_load';
import EventManager from '../components/event_manager';
import DOMCleanup from '../utils/dom_cleanup';

// Mock dependencies
jest.mock('../components/event_manager', () => ({
  registerComponent: jest.fn().mockReturnValue({
    addEventListener: jest.fn(),
    addDelegatedEventListener: jest.fn()
  }),
  unregisterComponent: jest.fn()
}));

jest.mock('../utils/dom_cleanup', () => ({
  register: jest.fn().mockReturnValue({
    cleanup: jest.fn(),
    registerCleanupFunction: jest.fn()
  })
}));

describe('LazyLoadComponent', () => {
  let component;
  let container;
  let mockLiveViewHook;
  let observerCallback;
  
  // Helper function to create test container
  const createTestContainer = () => {
    const container = document.createElement('div');
    container.id = 'lazy-load-test';
    container.className = 'lazy-load-container';
    
    // Create placeholder
    const placeholder = document.createElement('div');
    placeholder.setAttribute('data-lazy-placeholder', '');
    placeholder.textContent = 'Loading...';
    container.appendChild(placeholder);
    
    // Create content (initially hidden)
    const content = document.createElement('div');
    content.setAttribute('data-lazy-content', '');
    content.style.display = 'none';
    content.textContent = 'Lazy loaded content';
    container.appendChild(content);
    
    document.body.appendChild(container);
    return container;
  };
  
  beforeEach(() => {
    // Create container
    container = createTestContainer();
    
    // Create mock LiveView hook
    mockLiveViewHook = {
      el: container,
      handleEvent: jest.fn(),
      pushEvent: jest.fn()
    };
    
    // Mock IntersectionObserver
    window.IntersectionObserver = jest.fn((callback) => {
      observerCallback = callback;
      return {
        observe: jest.fn(),
        unobserve: jest.fn(),
        disconnect: jest.fn()
      };
    });
    
    // Create accessibility announcer
    const announcer = document.createElement('div');
    announcer.id = 'accessibility-announcer';
    document.body.appendChild(announcer);
  });
  
  afterEach(() => {
    if (component) {
      component.destroy();
    }
    if (container && container.parentNode) {
      container.parentNode.removeChild(container);
    }
    const announcer = document.getElementById('accessibility-announcer');
    if (announcer && announcer.parentNode) {
      announcer.parentNode.removeChild(announcer);
    }
    container = null;
    component = null;
    jest.clearAllMocks();
  });
  
  describe('Initialization', () => {
    test('should initialize with correct default properties', () => {
      component = new LazyLoadComponent({
        container,
        liveViewHook: mockLiveViewHook,
        debug: true
      });
      
      expect(component.componentId).toMatch(/^lazy-load-[a-z0-9]{7}$/);
      expect(component.options.container).toBe(container);
      expect(component.options.rootMargin).toBe('100px');
      expect(component.options.threshold).toBe(0.1);
      expect(component.options.liveViewHook).toBe(mockLiveViewHook);
      expect(component.options.debug).toBe(true);
    });
    
    test('should mount successfully', () => {
      component = new LazyLoadComponent({
        container,
        liveViewHook: mockLiveViewHook
      });
      
      component.mount();
      
      expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
      expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
      expect(component.elements.container).toBe(container);
      expect(component.elements.placeholder).toBeTruthy();
      expect(component.elements.content).toBeTruthy();
      expect(component._state.isLoaded).toBe(false);
      expect(component._state.isObserving).toBe(true);
    });
    
    test('should handle pre-loaded content', () => {
      container.dataset.loaded = 'true';
      
      component = new LazyLoadComponent({
        container,
        liveViewHook: mockLiveViewHook
      });
      
      component.mount();
      
      expect(component._state.isLoaded).toBe(true);
      expect(component.elements.content.style.display).toBe('');
      expect(component.elements.placeholder.style.display).toBe('none');
    });
  });
  
  describe('Lazy Loading', () => {
    beforeEach(() => {
      component = new LazyLoadComponent({
        container,
        liveViewHook: mockLiveViewHook
      });
      component.mount();
    });
    
    test('should show content when intersecting', () => {
      // Simulate intersection
      observerCallback([{
        target: container,
        isIntersecting: true
      }]);
      
      expect(component._state.isLoaded).toBe(true);
      expect(component.elements.content.style.display).toBe('');
      expect(component.elements.placeholder.style.display).toBe('none');
      expect(container.dataset.loaded).toBe('true');
    });
    
    test('should emit event when content is loaded', () => {
      const eventHandler = jest.fn();
      container.addEventListener('lazy-content-loaded', eventHandler);
      
      // Simulate intersection
      observerCallback([{
        target: container,
        isIntersecting: true
      }]);
      
      expect(eventHandler).toHaveBeenCalled();
      const event = eventHandler.mock.calls[0][0];
      expect(event.detail).toEqual({
        id: container.id,
        componentId: component.componentId
      });
    });
    
    test('should announce content loaded for accessibility', () => {
      // Simulate intersection
      observerCallback([{
        target: container,
        isIntersecting: true
      }]);
      
      const announcer = document.getElementById('accessibility-announcer');
      expect(announcer.textContent).toBe('Content loaded');
    });
    
    test('should load content immediately when loadNow is called', () => {
      component.loadNow();
      
      expect(component._state.isLoaded).toBe(true);
      expect(component.elements.content.style.display).toBe('');
      expect(component.elements.placeholder.style.display).toBe('none');
      expect(container.dataset.loaded).toBe('true');
      expect(component._state.isObserving).toBe(false);
    });
  });
  
  describe('LiveView Integration', () => {
    test('should integrate with LiveView hooks', () => {
      const hook = {
        el: container,
        handleEvent: jest.fn(),
        pushEvent: jest.fn()
      };
      
      // Test mounted hook
      const LazyLoad = require('../components/lazy_load').default;
      LazyLoad.mounted.call(hook);
      
      expect(hook.component).toBeTruthy();
      expect(hook.component instanceof LazyLoadComponent).toBe(true);
      
      // Test destroyed hook
      LazyLoad.destroyed.call(hook);
      expect(hook.component).toBeNull();
    });
  });
  
  describe('Cleanup', () => {
    beforeEach(() => {
      component = new LazyLoadComponent({
        container,
        liveViewHook: mockLiveViewHook
      });
      component.mount();
    });
    
    test('should clean up resources on destroy', () => {
      const cleanupSpy = jest.spyOn(DOMCleanup.register(), 'cleanup');
      const unregisterSpy = jest.spyOn(EventManager, 'unregisterComponent');
      const disconnectSpy = jest.spyOn(component.observer, 'disconnect');
      
      component.destroy();
      
      expect(cleanupSpy).toHaveBeenCalled();
      expect(unregisterSpy).toHaveBeenCalledWith(component.componentId);
      expect(disconnectSpy).toHaveBeenCalled();
      expect(component.elements).toEqual({});
      expect(component._state).toEqual({});
      
      cleanupSpy.mockRestore();
      unregisterSpy.mockRestore();
      disconnectSpy.mockRestore();
    });
    
    test('should handle multiple destroy calls gracefully', () => {
      component.destroy();
      expect(() => component.destroy()).not.toThrow();
    });
  });
}); 