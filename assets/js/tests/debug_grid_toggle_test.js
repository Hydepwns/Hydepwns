/**
 * Debug Grid Toggle Component Tests
 * -------------------------------
 * Jest test suite for the DebugGridToggleComponent class.
 */

import { DebugGridToggleComponent } from '../components/debug_grid_toggle';
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
    createElement: jest.fn()
  })
}));

describe('DebugGridToggleComponent', () => {
  let component;
  let container;
  let checkbox;
  let mockLiveViewHook;
  let localStorageMock;
  
  // Helper to create test container with required elements
  const createTestContainer = () => {
    container = document.createElement('div');
    container.className = 'debug-grid-toggle';
    
    checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.id = 'debug-grid-toggle';
    container.appendChild(checkbox);
    
    // Create debug grid element
    const debugGrid = document.createElement('div');
    debugGrid.className = 'debug-grid';
    document.body.appendChild(debugGrid);
    
    document.body.appendChild(container);
    return container;
  };
  
  beforeEach(() => {
    // Mock localStorage
    localStorageMock = {
      getItem: jest.fn(),
      setItem: jest.fn(),
      removeItem: jest.fn()
    };
    Object.defineProperty(window, 'localStorage', {
      value: localStorageMock
    });
    
    // Reset all mocks
    jest.clearAllMocks();
    
    // Create test container
    container = createTestContainer();
    
    // Create mock LiveView hook
    mockLiveViewHook = {
      el: container,
      handleEvent: jest.fn(),
      pushEvent: jest.fn()
    };
    
    // Create component instance
    component = new DebugGridToggleComponent({
      container,
      liveViewHook: mockLiveViewHook,
      debug: true
    });
  });
  
  afterEach(() => {
    if (component) {
      component.destroy();
    }
    if (container && container.parentNode) {
      container.parentNode.removeChild(container);
    }
    // Remove debug grid element
    const debugGrid = document.querySelector('.debug-grid');
    if (debugGrid) {
      debugGrid.parentNode.removeChild(debugGrid);
    }
    // Reset document body classes
    document.body.className = '';
    
    container = null;
    checkbox = null;
    component = null;
    
    // Clear localStorage mock
    jest.clearAllMocks();
  });
  
  describe('Initialization', () => {
    test('should initialize with correct default properties', () => {
      expect(component.componentId).toMatch(/^debug-grid-toggle-[a-z0-9]{7}$/);
      expect(component.options.container).toBe(container);
      expect(component.options.liveViewHook).toBe(mockLiveViewHook);
      expect(component.options.debug).toBe(true);
    });
    
    test('should mount successfully', () => {
      component.mount();
      
      expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
      expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
      expect(component.elements.container).toBe(container);
      expect(component.elements.checkbox).toBe(checkbox);
    });
    
    test('should load state from localStorage on mount', () => {
      localStorageMock.getItem.mockReturnValue('true');
      
      component.mount();
      
      expect(localStorageMock.getItem).toHaveBeenCalledWith('debugGrid');
      expect(checkbox.checked).toBe(true);
      expect(document.body.classList.contains('debug')).toBe(true);
    });
  });
  
  describe('Toggle Functionality', () => {
    beforeEach(() => {
      component.mount();
    });
    
    test('should toggle debug grid on checkbox change', () => {
      const event = new Event('change');
      checkbox.checked = true;
      checkbox.dispatchEvent(event);
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith('debugGrid', 'true');
      expect(document.body.classList.contains('debug')).toBe(true);
      expect(document.querySelector('.debug-grid').style.display).toBe('block');
      
      checkbox.checked = false;
      checkbox.dispatchEvent(event);
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith('debugGrid', 'false');
      expect(document.body.classList.contains('debug')).toBe(false);
      expect(document.querySelector('.debug-grid').style.display).toBe('none');
    });
    
    test('should toggle state programmatically', () => {
      component.toggle();
      
      expect(checkbox.checked).toBe(true);
      expect(document.body.classList.contains('debug')).toBe(true);
      
      component.toggle();
      
      expect(checkbox.checked).toBe(false);
      expect(document.body.classList.contains('debug')).toBe(false);
    });
    
    test('should enable debug grid', () => {
      component.enable();
      
      expect(checkbox.checked).toBe(true);
      expect(document.body.classList.contains('debug')).toBe(true);
      expect(document.querySelector('.debug-grid').style.display).toBe('block');
    });
    
    test('should disable debug grid', () => {
      // First enable it
      component.enable();
      
      // Then disable it
      component.disable();
      
      expect(checkbox.checked).toBe(false);
      expect(document.body.classList.contains('debug')).toBe(false);
      expect(document.querySelector('.debug-grid').style.display).toBe('none');
    });
  });
  
  describe('LiveView Integration', () => {
    test('should integrate with LiveView hooks', () => {
      const hook = {
        el: container,
        handleEvent: jest.fn()
      };
      
      // Test mounted hook
      const DebugGridToggle = require('../components/debug_grid_toggle').default;
      DebugGridToggle.mounted.call(hook);
      
      expect(hook.component).toBeTruthy();
      expect(hook.component instanceof DebugGridToggleComponent).toBe(true);
      
      // Test destroyed hook
      DebugGridToggle.destroyed.call(hook);
      expect(hook.component).toBeNull();
    });
  });
  
  describe('Cleanup', () => {
    test('should clean up resources on destroy', () => {
      component.mount();
      
      const cleanupSpy = jest.spyOn(DOMCleanup.register(), 'cleanup');
      const unregisterSpy = jest.spyOn(EventManager, 'unregisterComponent');
      
      component.destroy();
      
      expect(cleanupSpy).toHaveBeenCalled();
      expect(unregisterSpy).toHaveBeenCalledWith(component.componentId);
      
      expect(component.elements).toEqual({});
      expect(component._state).toEqual({});
      
      cleanupSpy.mockRestore();
      unregisterSpy.mockRestore();
    });
    
    test('should handle multiple destroy calls gracefully', () => {
      component.mount();
      
      // First destroy
      component.destroy();
      
      // Second destroy should not throw
      expect(() => component.destroy()).not.toThrow();
    });
    
    test('should clean up event listeners', () => {
      component.mount();
      
      const eventListenerSpy = jest.spyOn(EventManager.registerComponent(), 'addEventListener');
      
      component.destroy();
      
      expect(eventListenerSpy).toHaveBeenCalled();
      
      eventListenerSpy.mockRestore();
    });
  });
}); 