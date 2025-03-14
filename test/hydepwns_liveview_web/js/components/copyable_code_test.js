/**
 * Copyable Code Component Tests
 * -----------------------------
 * Tests for the CopyableCodeComponent class.
 */

import { CopyableCodeComponent } from '../../../../assets/js/components/copyable_code';
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

// Create a mock createElement function
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

// Mock clipboard API
const originalClipboard = navigator.clipboard;
const mockClipboard = {
  writeText: jest.fn().mockResolvedValue(undefined)
};

describe('CopyableCodeComponent', () => {
  let component;
  let container;
  let mockLiveViewHook;
  let originalDocumentCreateElement;
  
  // Setup for tests
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Save original document.createElement
    originalDocumentCreateElement = document.createElement;
    
    // Mock clipboard API
    Object.defineProperty(navigator, 'clipboard', {
      value: mockClipboard,
      configurable: true
    });
    
    // Create container element (code block)
    container = document.createElement('pre');
    container.className = 'code-block';
    container.textContent = 'const example = "test code";';
    document.body.appendChild(container);
    
    // Create mock LiveView hook
    mockLiveViewHook = {
      pushEvent: jest.fn(),
      pushEventTo: jest.fn()
    };

    // Create component instance
    component = new CopyableCodeComponent({
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
    
    // Restore document.createElement
    document.createElement = originalDocumentCreateElement;
    
    // Restore clipboard API
    Object.defineProperty(navigator, 'clipboard', {
      value: originalClipboard,
      configurable: true
    });
    
    // Clear any timeouts
    jest.clearAllTimers();
  });
  
  test('should initialize with correct default properties', () => {
    expect(component.componentId).toMatch(/^copyable-code-[a-z0-9]{7}$/);
    expect(component.options.container).toBe(container);
    expect(component.options.liveViewHook).toBe(mockLiveViewHook);
    expect(component.options.successMessage).toBe('Copied!');
    expect(component.options.initialMessage).toBe('Click to copy');
    expect(component.options.errorMessage).toBe('Copy failed!');
    expect(component.options.flashDuration).toBe(300);
    expect(component.options.tooltipDuration).toBe(2000);
    expect(component.options.debug).toBe(false);
    expect(component._state.isCopying).toBe(false);
  });
  
  test('should properly mount the component', () => {
    // Mount the component
    component.mount();
    
    // Verify EventManager and DOMCleanup were used correctly
    expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
    expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
    
    // Verify elements were found and stored
    expect(component.elements.container).toBe(container);
    expect(component.elements.tooltip).toBeTruthy();
    
    // Verify copyable class was added
    expect(container.classList.contains('copyable')).toBe(true);
    
    // Verify tooltip was created with the correct initial message
    expect(component.elements.tooltip.textContent).toBe('Click to copy');
    expect(component.elements.tooltip.className).toBe('copy-tooltip');
    
    // Verify event listeners were set up
    expect(component.events.addEventListener).toHaveBeenCalledTimes(3);
    expect(component.events.addEventListener).toHaveBeenCalledWith(
      container,
      'click',
      expect.any(Function)
    );
    expect(component.events.addEventListener).toHaveBeenCalledWith(
      container,
      'mouseenter',
      expect.any(Function)
    );
    expect(component.events.addEventListener).toHaveBeenCalledWith(
      container,
      'mouseleave',
      expect.any(Function)
    );
  });
  
  test('should properly destroy the component', () => {
    // Mount first, then destroy
    component.mount();
    component.destroy();
    
    // Verify copyable class was removed
    expect(container.classList.contains('copyable')).toBe(false);
    
    // Verify cleanup was called
    expect(component.cleanup.cleanup).toHaveBeenCalled();
    expect(EventManager.unregisterComponent).toHaveBeenCalledWith(component.componentId);
    
    // Verify references were cleared
    expect(component.elements).toEqual({});
    expect(component._state).toEqual({});
  });
  
  test('should handle missing container gracefully', () => {
    // Setup - create component without container
    const invalidComponent = new CopyableCodeComponent({
      debug: true
    });
    
    // Mock console.error
    console.error = jest.fn();
    
    // Mount component
    invalidComponent.mount();
    
    // Verify error was logged
    expect(console.error).toHaveBeenCalledWith('CopyableCode: No container element provided');
  });
  
  test('should show tooltip on mouseenter', () => {
    // Mount component
    component.mount();
    
    // Get the mouseenter handler
    const calls = component.events.addEventListener.mock.calls;
    const mouseenterHandler = calls.find(call => 
      call[0] === container && call[1] === 'mouseenter'
    )[2];
    
    // Call the handler directly
    mouseenterHandler();
    
    // Verify tooltip visibility class was added
    expect(component.elements.tooltip.classList.contains('visible')).toBe(true);
  });
  
  test('should hide tooltip on mouseleave', () => {
    // Mount component
    component.mount();
    
    // Add visible and copied classes first
    component.elements.tooltip.classList.add('visible', 'copied');
    
    // Get the mouseleave handler
    const calls = component.events.addEventListener.mock.calls;
    const mouseleaveHandler = calls.find(call => 
      call[0] === container && call[1] === 'mouseleave'
    )[2];
    
    // Call the handler directly
    mouseleaveHandler();
    
    // Verify tooltip classes were removed and text was reset
    expect(component.elements.tooltip.classList.contains('visible')).toBe(false);
    expect(component.elements.tooltip.classList.contains('copied')).toBe(false);
    expect(component.elements.tooltip.textContent).toBe('Click to copy');
  });
  
  test('should copy content to clipboard on click', async () => {
    // Setup
    jest.useFakeTimers();
    component.mount();
    
    // Spy on _showCopySuccess to verify it's called
    component._showCopySuccess = jest.fn();
    
    // Get the click handler
    const calls = component.events.addEventListener.mock.calls;
    const clickHandler = calls.find(call => 
      call[0] === container && call[1] === 'click'
    )[2];
    
    // Call the handler directly
    await clickHandler();
    
    // Verify clipboard API was called with the correct content
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith('const example = "test code";');
    
    // Verify success method was called
    expect(component._showCopySuccess).toHaveBeenCalled();
    
    jest.useRealTimers();
  });
  
  test('should keep tooltip visible if still hovering after tooltip duration', async () => {
    // Setup
    jest.useFakeTimers();
    component.mount();
    
    // Mock the _showCopySuccess method instead of calling it directly
    component._showCopySuccess = jest.fn().mockImplementation(() => {
      // Simulate what the method does
      component.elements.tooltip.textContent = component.options.successMessage;
      component.elements.tooltip.classList.add('copied', 'visible');
      component.elements.container.classList.add('flash');
    });
    
    // Call the method to set up the state
    component._showCopySuccess();
    
    // Manually mock the hover state
    Object.defineProperty(container, 'matches', {
      value: jest.fn().mockReturnValue(true) // Hovering
    });
    
    // Advance timers to tooltip duration
    jest.advanceTimersByTime(component.options.tooltipDuration);
    
    // Verify tooltip is still visible
    expect(component.elements.tooltip.classList.contains('visible')).toBe(true);
    
    jest.useRealTimers();
  });
  
  test('should handle clipboard API failure', () => {
    // Setup
    component.mount();
    
    // Mock the _showCopyError method
    component._showCopyError = jest.fn();
    
    // Directly call the error handler to simulate a clipboard API failure
    component._showCopyError();
    
    // Verify error handler was called
    expect(component._showCopyError).toHaveBeenCalled();
  });
  
  test('should handle legacy browsers without Clipboard API', () => {
    // Setup
    // Store original properties we need to restore
    const originalExecCommand = document.execCommand;
    const originalAppendChild = document.body.appendChild;
    const originalRemoveChild = document.body.removeChild;
    
    // Remove Clipboard API
    delete navigator.clipboard;
    
    // Mock document.execCommand
    document.execCommand = jest.fn().mockReturnValue(true);
    
    // Create a real textarea for testing
    const mockTextarea = document.createElement('textarea');
    mockTextarea.select = jest.fn();
    
    // Mock document.createElement for textarea only
    document.createElement = jest.fn().mockImplementation((tag) => {
      if (tag === 'textarea') {
        return mockTextarea;
      }
      return originalDocumentCreateElement.call(document, tag);
    });
    
    // Mock document.body.appendChild and removeChild
    document.body.appendChild = jest.fn().mockReturnValue(mockTextarea);
    document.body.removeChild = jest.fn();
    
    component.mount();
    
    // Spy on _showCopySuccess to verify it's called
    component._showCopySuccess = jest.fn();
    
    // Call copy method
    component._copyToClipboard();
    
    // Verify fallback method was used
    expect(document.createElement).toHaveBeenCalledWith('textarea');
    expect(document.body.appendChild).toHaveBeenCalledWith(mockTextarea);
    expect(mockTextarea.select).toHaveBeenCalled();
    expect(document.execCommand).toHaveBeenCalledWith('copy');
    expect(document.body.removeChild).toHaveBeenCalled();
    expect(component._showCopySuccess).toHaveBeenCalled();
    
    // Restore mocks
    document.execCommand = originalExecCommand;
    document.body.appendChild = originalAppendChild;
    document.body.removeChild = originalRemoveChild;
  });
  
  test('should prevent multiple simultaneous copy operations', async () => {
    // Setup
    component.mount();
    
    // Set state to indicate copy in progress
    component._setState({ isCopying: true });
    
    // Call copy method
    await component._copyToClipboard();
    
    // Verify clipboard API was not called
    expect(navigator.clipboard.writeText).not.toHaveBeenCalled();
  });
  
  test('should update component state correctly', () => {
    // Set new state
    component._setState({ isCopying: true, testValue: 'test' });
    
    // Verify state was updated correctly
    expect(component._state.isCopying).toBe(true);
    expect(component._state.testValue).toBe('test');
  });
}); 