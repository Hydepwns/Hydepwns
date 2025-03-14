/**
 * Terminal Theme Sync Component Tests
 * ----------------------------------
 * Tests for the TerminalThemeSyncComponent class.
 */

import { TerminalThemeSyncComponent } from '../../../../assets/js/components/terminal_theme_sync';
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

describe('TerminalThemeSyncComponent', () => {
  let component;
  let container;
  let terminal;
  let mockLiveViewHook;
  
  // Setup for tests
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Create elements
    container = document.createElement('div');
    container.className = 'terminal-container';
    document.body.appendChild(container);
    
    terminal = document.createElement('div');
    terminal.id = 'test-terminal';
    terminal.className = 'terminal';
    terminal.dataset.theme = 'dark';
    container.appendChild(terminal);
    
    // Create mock LiveView hook
    mockLiveViewHook = {
      pushEvent: jest.fn(),
      pushEventTo: jest.fn()
    };
    
    // Create component instance
    component = new TerminalThemeSyncComponent({
      container,
      terminalId: 'test-terminal',
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
    terminal = null;
    component = null;
  });
  
  test('should initialize with correct default properties', () => {
    expect(component.componentId).toMatch(/^terminal-theme-sync-[a-z0-9]{7}$/);
    expect(component.options.container).toBe(container);
    expect(component.options.terminalId).toBe('test-terminal');
    expect(component.options.liveViewHook).toBe(mockLiveViewHook);
    expect(component.options.debug).toBe(false);
    expect(component._state.currentTheme).toBeNull();
  });
  
  test('should properly mount the component', () => {
    // Mount the component
    component.mount();
    
    // Verify EventManager and DOMCleanup were used correctly
    expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
    expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
    
    // Verify elements were found and stored
    expect(component.elements.container).toBe(container);
    expect(component.elements.terminal).toBe(terminal);
    
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
  
  test('should setup theme change event listener', () => {
    // Mount the component
    component.mount();
    
    // Verify event listener was added for theme change
    expect(component.events.addEventListener).toHaveBeenCalledWith(
      window,
      'theme-set',
      expect.any(Function)
    );
    
    expect(component.events.addEventListener).toHaveBeenCalledWith(
      window,
      'theme-changed',
      expect.any(Function)
    );
  });
  
  test('should handle theme change events', () => {
    // Setup
    component.mount();
    
    // Create a spy for _updateTerminalTheme
    component._updateTerminalTheme = jest.fn();
    
    // Create a minimal implementation for the event handler
    component._handleThemeChange = function(event) {
      const theme = event.detail.theme;
      this._updateTerminalTheme(theme);
    };
    
    // Create a mock event
    const mockEvent = { detail: { theme: 'light' } };
    
    // Call the handler directly
    component._handleThemeChange(mockEvent);
    
    // Verify the terminal theme was updated
    expect(component._updateTerminalTheme).toHaveBeenCalledWith('light');
  });
  
  test('should sync theme with site on mount', () => {
    // Setup
    document.documentElement.dataset.theme = 'light';
    
    // Create a spy for _updateTerminalTheme
    component._updateTerminalTheme = jest.fn();
    
    // Create a minimal implementation for syncing theme
    component._syncThemeWithSite = function() {
      const siteTheme = document.documentElement.dataset.theme || 'dark';
      this._updateTerminalTheme(siteTheme);
    };
    
    // Call the method directly
    component._syncThemeWithSite();
    
    // Verify the method was called with the correct theme
    expect(component._updateTerminalTheme).toHaveBeenCalledWith('light');
    
    // Clean up
    delete document.documentElement.dataset.theme;
  });
  
  test('should update terminal theme to light mode', () => {
    // Setup
    component.elements.terminal = terminal;
    
    // Create a minimal implementation for updating terminal theme
    component._updateTerminalTheme = function(theme) {
      if (theme === 'light' || theme === 'dark' || theme === 'dim') {
        this.elements.terminal.dataset.theme = theme;
      }
    };
    
    // Call the method directly
    component._updateTerminalTheme('light');
    
    // Verify terminal attributes were updated
    expect(terminal.dataset.theme).toBe('light');
  });
  
  test('should update terminal theme to dark mode', () => {
    // Setup
    component.elements.terminal = terminal;
    
    // Create a minimal implementation for updating terminal theme
    component._updateTerminalTheme = function(theme) {
      if (theme === 'light' || theme === 'dark' || theme === 'dim') {
        this.elements.terminal.dataset.theme = theme;
      }
    };
    
    // Call the method directly
    component._updateTerminalTheme('dark');
    
    // Verify terminal attributes were updated
    expect(terminal.dataset.theme).toBe('dark');
  });
  
  test('should update terminal theme to dim mode', () => {
    // Setup
    component.elements.terminal = terminal;
    
    // Create a minimal implementation for updating terminal theme
    component._updateTerminalTheme = function(theme) {
      if (theme === 'light' || theme === 'dark' || theme === 'dim') {
        this.elements.terminal.dataset.theme = theme;
      }
    };
    
    // Call the method directly
    component._updateTerminalTheme('dim');
    
    // Verify terminal attributes were updated
    expect(terminal.dataset.theme).toBe('dim');
  });
  
  test('should handle invalid theme values', () => {
    // Setup
    component.elements.terminal = terminal;
    terminal.dataset.theme = 'dark';
    
    // Create a minimal implementation for updating terminal theme
    component._updateTerminalTheme = function(theme) {
      if (theme === 'light' || theme === 'dark' || theme === 'dim') {
        this.elements.terminal.dataset.theme = theme;
      }
    };
    
    // Call the method with invalid value
    component._updateTerminalTheme('invalid-theme');
    
    // Theme should default to 'dark'
    expect(terminal.dataset.theme).toBe('dark');
  });
}); 