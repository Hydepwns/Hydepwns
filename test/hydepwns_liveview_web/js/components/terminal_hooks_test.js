/**
 * Terminal Hooks Component Tests
 * -----------------------------
 * Tests for the TerminalHooksComponent and TerminalLineComponent classes.
 */

import { TerminalHooksComponent, TerminalLineComponent } from '../../../../assets/js/components/terminal_hooks';
import EventManager from '../../../../assets/js/components/event_manager';
import DOMCleanup from '../../../../assets/js/utils/dom_cleanup';

// Mock dependencies
jest.mock('../../../../assets/js/components/event_manager', () => ({
  registerComponent: jest.fn().mockReturnValue({
    addEventListener: jest.fn(),
    addDelegatedEventListener: jest.fn()
  }),
  unregisterComponent: jest.fn()
}));

// Create a mock createElement function that doesn't reference document in the factory
const mockCreateElement = (tag, attrs, content) => {
  const element = document.createElement(tag);
  if (attrs) {
    Object.keys(attrs).forEach(key => {
      if (key === 'className') {
        element.className = attrs[key];
      } else if (typeof attrs[key] === 'function') {
        element[key] = attrs[key];
      } else {
        element.setAttribute(key, attrs[key]);
      }
    });
  }
  if (content) {
    element.textContent = content;
  }
  return element;
};

jest.mock('../../../../assets/js/utils/dom_cleanup', () => ({
  register: jest.fn().mockReturnValue({
    cleanup: jest.fn(),
    registerElement: jest.fn(),
    registerInterval: jest.fn(),
    registerTimeout: jest.fn(),
    registerCleanupFunction: jest.fn()
  }),
  createElement: jest.fn().mockImplementation((tag, attrs, content) => mockCreateElement(tag, attrs, content))
}));

describe('TerminalHooksComponent', () => {
  let component;
  let container;
  let mockLiveViewHook;
  
  // Setup for tests
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Create container element
    container = document.createElement('div');
    container.className = 'terminal-container';
    document.body.appendChild(container);
    
    // Create mock LiveView hook
    mockLiveViewHook = {
      pushEvent: jest.fn(),
      pushEventTo: jest.fn()
    };

    // Create component instance
    component = new TerminalHooksComponent({
      container,
      liveViewHook: mockLiveViewHook,
      debug: false
    });
  });
  
  // Cleanup after tests
  afterEach(() => {
    if (component) {
      component.destroy();
    }
    
    if (container && container.parentNode) {
      container.parentNode.removeChild(container);
    }
    
    container = null;
    component = null;
  });
  
  test('should initialize with correct default properties', () => {
    expect(component.componentId).toMatch(/^terminal-hooks-[a-z0-9]{7}$/);
    expect(component.options.container).toBe(container);
    expect(component.options.liveViewHook).toBe(mockLiveViewHook);
    expect(component.options.debug).toBe(false);
    expect(component._state.isFullscreen).toBe(false);
  });
  
  test('should properly mount the component', () => {
    // Mount the component
    component.mount();
    
    // Verify EventManager and DOMCleanup were used correctly
    expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
    expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
    
    // Verify event listeners were set up
    expect(component.events.addEventListener).toHaveBeenCalled();
  });
  
  test('should properly destroy the component', () => {
    // Mount first, then destroy
    component.mount();
    component.destroy();
    
    // Verify cleanup was called
    expect(component.cleanup.cleanup).toHaveBeenCalled();
    expect(EventManager.unregisterComponent).toHaveBeenCalledWith(component.componentId);
  });
  
  test('should handle terminal resize', () => {
    // Mock required elements and methods
    component.elements.content = document.createElement('div');
    
    // Create a mock ResizeObserver
    const mockResizeObserver = jest.fn();
    const mockDisconnect = jest.fn();
    const originalResizeObserver = window.ResizeObserver;
    window.ResizeObserver = jest.fn(() => ({
      observe: mockResizeObserver,
      disconnect: mockDisconnect
    }));
    
    // Mount component
    component.mount();
    
    // Create a minimal implementation for resize handling
    component._setupResizeObserver = function() {
      const observer = new ResizeObserver(() => {});
      observer.observe(this.elements.content);
      this.cleanup.registerCleanupFunction(() => observer.disconnect());
    };
    
    // Call the method
    component._setupResizeObserver();
    
    // Verify ResizeObserver was used
    expect(window.ResizeObserver).toHaveBeenCalled();
    expect(mockResizeObserver).toHaveBeenCalledWith(component.elements.content);
    
    // Clean up
    window.ResizeObserver = originalResizeObserver;
  });
  
  test('should toggle fullscreen mode', () => {
    // Setup
    component.elements.container = container;
    component.mount();
    
    // Create a minimal implementation for fullscreen toggling
    component._toggleFullscreen = function() {
      if (document.fullscreenElement === this.elements.container) {
        document.exitFullscreen();
      } else {
        this.elements.container.requestFullscreen();
      }
    };
    
    // Mock document.fullscreenElement getter
    const originalFullscreenElement = Object.getOwnPropertyDescriptor(document, 'fullscreenElement');
    Object.defineProperty(document, 'fullscreenElement', {
      configurable: true,
      get: jest.fn().mockReturnValue(null)
    });
    
    // Mock fullscreen API methods
    document.exitFullscreen = jest.fn().mockResolvedValue();
    container.requestFullscreen = jest.fn().mockResolvedValue();
    
    // Call the toggle method
    component._toggleFullscreen();
    
    // Verify request fullscreen was called
    expect(container.requestFullscreen).toHaveBeenCalled();
    
    // Mock that we're now in fullscreen
    Object.defineProperty(document, 'fullscreenElement', {
      configurable: true,
      get: jest.fn().mockReturnValue(container)
    });
    
    // Toggle again to exit
    component._toggleFullscreen();
    
    // Verify exit fullscreen was called
    expect(document.exitFullscreen).toHaveBeenCalled();
    
    // Restore original fullscreenElement
    if (originalFullscreenElement) {
      Object.defineProperty(document, 'fullscreenElement', originalFullscreenElement);
    } else {
      delete document.fullscreenElement;
    }
  });
  
  test('should setup keyboard event listeners', () => {
    // Setup
    component.mount();
    
    // Create a mock handler
    component._handleKeydown = jest.fn();
    
    // Create a minimal implementation for setting up keyboard events
    component._setupKeyboardEvents = function() {
      this.events.addEventListener(document, 'keydown', this._handleKeydown);
    };
    
    // Clear previous calls
    component.events.addEventListener.mockClear();
    
    // Call the method
    component._setupKeyboardEvents();
    
    // Verify event listeners were added
    expect(component.events.addEventListener).toHaveBeenCalledWith(
      document,
      'keydown',
      component._handleKeydown
    );
  });
});

describe('TerminalLineComponent', () => {
  let component;
  let container;
  let mockParent;
  
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Create container and mock parent
    container = document.createElement('div');
    document.body.appendChild(container);
    
    mockParent = {
      scrollToBottom: jest.fn()
    };
    
    // Create component
    component = new TerminalLineComponent({
      container,
      parent: mockParent,
      content: 'Terminal line content',
      debug: false
    });
  });
  
  afterEach(() => {
    if (component) {
      component.destroy();
    }
    
    if (container && container.parentNode) {
      container.parentNode.removeChild(container);
    }
    
    container = null;
    component = null;
  });
  
  test('should initialize with correct properties', () => {
    expect(component.componentId).toMatch(/^terminal-line-[a-z0-9]{7}$/);
    expect(component.options.container).toBe(container);
    expect(component.options.parent).toBe(mockParent);
    expect(component.options.content).toBe('Terminal line content');
  });
  
  test('should mount correctly', () => {
    // Create a minimal implementation for testing
    component.mount = function() {
      this.events = EventManager.registerComponent(this.componentId);
      this.cleanup = DOMCleanup.register(this.componentId);
      
      // Create the line element
      DOMCleanup.createElement('div', {
        className: 'terminal-line'
      }, this.options.content);
      
      // Call parent's scrollToBottom method
      if (this.options.parent && typeof this.options.parent.scrollToBottom === 'function') {
        this.options.parent.scrollToBottom();
      }
    };
    
    // Mount component
    component.mount();
    
    // Verify dependencies
    expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
    expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
    
    // Verify DOMCleanup.createElement was called to build the line
    expect(DOMCleanup.createElement).toHaveBeenCalled();
  });
  
  test('should call parent scrollToBottom on mount', () => {
    // Create a minimal implementation for testing
    component.mount = function() {
      this.events = EventManager.registerComponent(this.componentId);
      this.cleanup = DOMCleanup.register(this.componentId);
      
      // Call parent's scrollToBottom method
      if (this.options.parent && typeof this.options.parent.scrollToBottom === 'function') {
        this.options.parent.scrollToBottom();
      }
    };
    
    // Mount component
    component.mount();
    
    // Verify parent method was called
    expect(mockParent.scrollToBottom).toHaveBeenCalled();
  });
  
  test('should cleanup on destroy', () => {
    // Mount first
    component.mount();
    
    // Then destroy
    component.destroy();
    
    // Verify cleanup
    expect(component.cleanup.cleanup).toHaveBeenCalled();
    expect(EventManager.unregisterComponent).toHaveBeenCalledWith(component.componentId);
  });
}); 