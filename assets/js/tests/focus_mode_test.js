/**
 * Focus Mode Component Tests
 * -----------------------
 * Jest test suite for the FocusModeComponent class.
 */

import { FocusModeComponent } from '../components/focus_mode';
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
    createElement: jest.fn((tag, props, text) => {
      const element = document.createElement(tag);
      if (props) {
        Object.entries(props).forEach(([key, value]) => {
          if (key === 'className') {
            element.className = value;
          } else {
            element.setAttribute(key, value);
          }
        });
      }
      if (text) {
        element.textContent = text;
      }
      return element;
    })
  })
}));

describe('FocusModeComponent', () => {
  let component;
  let container;
  let mockLiveViewHook;
  let localStorageMock;
  
  beforeEach(() => {
    // Create container and header
    container = document.createElement('div');
    container.id = 'focus-mode-test';
    const header = document.createElement('header');
    container.appendChild(header);
    document.body.appendChild(container);
    
    // Mock localStorage
    localStorageMock = {
      getItem: jest.fn(),
      setItem: jest.fn(),
      clear: jest.fn()
    };
    Object.defineProperty(window, 'localStorage', {
      value: localStorageMock
    });
    
    // Create mock LiveView hook
    mockLiveViewHook = {
      el: container,
      handleEvent: jest.fn(),
      pushEvent: jest.fn()
    };
    
    // Create component instance
    component = new FocusModeComponent({
      toggleButtonContainer: header,
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
    container = null;
    component = null;
    jest.clearAllMocks();
  });
  
  describe('Initialization', () => {
    test('should initialize with correct default properties', () => {
      expect(component.componentId).toMatch(/^focus-mode-[a-z0-9]{7}$/);
      expect(component.options.toggleButtonContainer).toBeTruthy();
      expect(component.options.statusAnnouncerId).toBe('accessibility-announcer');
      expect(component.options.preferenceKey).toBe('focus_mode_active');
      expect(component.options.liveViewHook).toBe(mockLiveViewHook);
      expect(component.options.debug).toBe(true);
    });
    
    test('should mount successfully', () => {
      component.mount();
      
      expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
      expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
      expect(component.elements.body).toBe(document.body);
      expect(component.elements.focusModeToggle).toBeTruthy();
      expect(component.elements.statusAnnouncer).toBeTruthy();
    });
    
    test('should restore focus mode preference from localStorage', () => {
      localStorageMock.getItem.mockReturnValue('true');
      
      component.mount();
      
      expect(localStorageMock.getItem).toHaveBeenCalledWith('focus_mode_active');
      expect(document.body.classList.contains('focus-mode')).toBe(true);
    });
  });
  
  describe('Focus Mode Toggle', () => {
    beforeEach(() => {
      component.mount();
    });
    
    test('should toggle focus mode on button click', () => {
      component.elements.focusModeToggle.click();
      
      expect(document.body.classList.contains('focus-mode')).toBe(true);
      expect(component.elements.focusModeToggle.getAttribute('aria-pressed')).toBe('true');
      expect(component.elements.focusModeToggle.querySelector('.focus-mode-icon').textContent).toBe('◉');
      
      component.elements.focusModeToggle.click();
      
      expect(document.body.classList.contains('focus-mode')).toBe(false);
      expect(component.elements.focusModeToggle.getAttribute('aria-pressed')).toBe('false');
      expect(component.elements.focusModeToggle.querySelector('.focus-mode-icon').textContent).toBe('○');
    });
    
    test('should toggle focus mode with Alt+F shortcut', () => {
      const event = new KeyboardEvent('keydown', {
        key: 'f',
        altKey: true
      });
      
      document.dispatchEvent(event);
      
      expect(document.body.classList.contains('focus-mode')).toBe(true);
      
      document.dispatchEvent(event);
      
      expect(document.body.classList.contains('focus-mode')).toBe(false);
    });
    
    test('should save preference to localStorage', () => {
      component.elements.focusModeToggle.click();
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith('focus_mode_active', true);
      
      component.elements.focusModeToggle.click();
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith('focus_mode_active', false);
    });
    
    test('should announce status changes', () => {
      component.elements.focusModeToggle.click();
      
      expect(component.elements.statusAnnouncer.textContent).toBe(
        'Focus mode activated. Press Alt+F to exit focus mode.'
      );
      
      component.elements.focusModeToggle.click();
      
      expect(component.elements.statusAnnouncer.textContent).toBe(
        'Focus mode deactivated.'
      );
    });
  });
  
  describe('Keyboard Navigation', () => {
    beforeEach(() => {
      component.mount();
      component.elements.focusModeToggle.click(); // Enable focus mode
      
      // Create some interactive elements
      const button1 = document.createElement('button');
      button1.textContent = 'Button 1';
      const button2 = document.createElement('button');
      button2.textContent = 'Button 2';
      const link = document.createElement('a');
      link.href = '#';
      link.textContent = 'Link';
      
      container.appendChild(button1);
      container.appendChild(button2);
      container.appendChild(link);
    });
    
    test('should navigate to next interactive element with Alt+N', () => {
      const event = new KeyboardEvent('keydown', {
        key: 'n',
        altKey: true
      });
      
      document.dispatchEvent(event);
      
      expect(document.activeElement).toBe(
        component._getInteractiveElements()[0]
      );
    });
    
    test('should navigate to previous interactive element with Alt+P', () => {
      const event = new KeyboardEvent('keydown', {
        key: 'p',
        altKey: true
      });
      
      document.dispatchEvent(event);
      
      expect(document.activeElement).toBe(
        component._getInteractiveElements()[
          component._getInteractiveElements().length - 1
        ]
      );
    });
    
    test('should show element context with Alt+I', () => {
      const button = container.querySelector('button');
      button.focus();
      
      const event = new KeyboardEvent('keydown', {
        key: 'i',
        altKey: true
      });
      
      document.dispatchEvent(event);
      
      expect(component.elements.statusAnnouncer.textContent).toContain('button');
      expect(component.elements.statusAnnouncer.textContent).toContain('Button 1');
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
      const FocusMode = require('../components/focus_mode').default;
      FocusMode.mounted.call(hook);
      
      expect(hook.component).toBeTruthy();
      expect(hook.component instanceof FocusModeComponent).toBe(true);
      
      // Test disconnected hook
      FocusMode.disconnected.call(hook);
      expect(hook.component).toBeNull();
    });
    
    test('should handle LiveView events', () => {
      component.mount();
      
      // Simulate LiveView toggle event
      const toggleHandler = mockLiveViewHook.handleEvent.mock.calls.find(
        call => call[0] === 'toggle_focus_mode'
      )[1];
      
      toggleHandler();
      
      expect(document.body.classList.contains('focus-mode')).toBe(true);
      expect(mockLiveViewHook.pushEvent).toHaveBeenCalledWith(
        'focus_mode_changed',
        { active: true }
      );
    });
  });
  
  describe('Cleanup', () => {
    test('should clean up resources on destroy', () => {
      component.mount();
      
      // Enable focus mode
      component.elements.focusModeToggle.click();
      
      const cleanupSpy = jest.spyOn(DOMCleanup.register(), 'cleanup');
      const unregisterSpy = jest.spyOn(EventManager, 'unregisterComponent');
      
      component.destroy();
      
      expect(cleanupSpy).toHaveBeenCalled();
      expect(unregisterSpy).toHaveBeenCalledWith(component.componentId);
      expect(document.body.classList.contains('focus-mode')).toBe(false);
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
  });
}); 