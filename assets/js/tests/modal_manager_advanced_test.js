/**
 * Advanced Modal Component Tests
 * -----------------------------------
 * Tests for complex functionality, edge cases, and advanced features
 * of the Modal component.
 */

import { ModalComponent } from '../components/modal_manager';
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
    createElement: jest.fn((tag, props, content) => {
      const element = document.createElement(tag);
      if (props.className) element.className = props.className;
      if (props.id) element.id = props.id;
      if (props.style) Object.assign(element.style, props.style);
      if (props['aria-label']) element.setAttribute('aria-label', props['aria-label']);
      if (props.role) element.setAttribute('role', props.role);
      if (content) element.textContent = content;
      return element;
    })
  })
}));

describe('ModalComponent - Advanced Features', () => {
  let component;
  let container;
  let mockLiveViewHook;

  beforeEach(() => {
    // Reset all mocks
    jest.clearAllMocks();

    // Create test container
    container = document.createElement('div');
    document.body.appendChild(container);

    // Create mock LiveView hook
    mockLiveViewHook = {
      el: container,
      pushEvent: jest.fn()
    };

    // Create component instance with all features enabled
    component = new ModalComponent({
      container,
      liveViewHook: mockLiveViewHook,
      title: 'Test Modal',
      content: '<p>Test content</p>',
      closeOnEscape: true,
      closeOnBackdropClick: true,
      showCloseButton: true,
      width: '500px',
      maxWidth: '800px',
      position: 'center',
      animation: 'fade',
      animationDuration: 300,
      theme: 'light',
      zIndex: 'modal'
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

  describe('Initialization and DOM Structure', () => {
    test('should create proper DOM structure with all features enabled', () => {
      component.mount();

      const root = container.querySelector('.modal-component');
      expect(root).toBeTruthy();
      expect(root.getAttribute('data-theme')).toBe('light');
      expect(root.classList.contains('modal-component--center')).toBe(true);
      expect(root.classList.contains('modal-component--fade')).toBe(true);

      const dialog = root.querySelector('.modal-component__dialog');
      expect(dialog).toBeTruthy();
      expect(dialog.getAttribute('role')).toBe('dialog');
      expect(dialog.getAttribute('aria-modal')).toBe('true');
      expect(dialog.style.width).toBe('500px');
      expect(dialog.style.maxWidth).toBe('800px');

      const backdrop = container.querySelector('.modal-component__backdrop');
      expect(backdrop).toBeTruthy();
    });

    test('should handle missing options gracefully', () => {
      component = new ModalComponent({ container }).mount();

      const root = container.querySelector('.modal-component');
      expect(root).toBeTruthy();
      expect(root.getAttribute('data-theme')).toBeTruthy();
      expect(root.classList.contains('modal-component--center')).toBe(true);
    });

    test('should generate unique component IDs', () => {
      const component1 = new ModalComponent({ container }).mount();
      const component2 = new ModalComponent({ container }).mount();

      expect(component1.componentId).not.toBe(component2.componentId);
      expect(component1.componentId).toMatch(/^modal-component-[a-z0-9]+$/);
      expect(component2.componentId).toMatch(/^modal-component-[a-z0-9]+$/);
    });
  });

  describe('Animation and Visibility', () => {
    beforeEach(() => {
      component.mount();
      // Mock timers for animation
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    test('should handle open animation', () => {
      component.open();

      expect(component.elements.root.style.display).toBe('');
      expect(component.elements.backdrop.style.display).toBe('');
      expect(document.body.style.overflow).toBe('hidden');

      // After animation frame
      jest.runOnlyPendingTimers();
      expect(component.elements.root.classList.contains('is-open')).toBe(true);
      expect(component.elements.backdrop.classList.contains('is-open')).toBe(true);

      // After animation duration
      jest.advanceTimersByTime(component.options.animationDuration);
      expect(component._state.isVisible).toBe(true);
      expect(component._state.isAnimating).toBe(false);
    });

    test('should handle close animation', () => {
      // Open first
      component.open();
      jest.runAllTimers();

      // Then close
      component.close();

      expect(component.elements.root.classList.contains('is-open')).toBe(false);
      expect(component.elements.backdrop.classList.contains('is-open')).toBe(false);

      // After animation duration
      jest.advanceTimersByTime(component.options.animationDuration);
      expect(component.elements.root.style.display).toBe('none');
      expect(component.elements.backdrop.style.display).toBe('none');
      expect(document.body.style.overflow).toBe('');
      expect(component._state.isVisible).toBe(false);
      expect(component._state.isAnimating).toBe(false);
    });

    test('should handle rapid open/close cycles', () => {
      // Attempt rapid open/close cycles
      component.open();
      component.close();
      component.open();
      component.close();

      // Should not throw errors and should end in a consistent state
      jest.runAllTimers();
      expect(component._state.isVisible).toBe(false);
      expect(component._state.isAnimating).toBe(false);
    });
  });

  describe('Event Handling', () => {
    beforeEach(() => {
      component.mount();
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    test('should handle escape key press', () => {
      component.open();
      jest.runAllTimers();

      // Simulate escape key press
      const event = new KeyboardEvent('keydown', { key: 'Escape' });
      document.dispatchEvent(event);

      expect(component._state.isVisible).toBe(false);
    });

    test('should handle backdrop click', () => {
      component.open();
      jest.runAllTimers();

      // Simulate backdrop click
      const event = new MouseEvent('click', { bubbles: true });
      component.elements.backdrop.dispatchEvent(event);

      expect(component._state.isVisible).toBe(false);
    });

    test('should not close on dialog click', () => {
      component.open();
      jest.runAllTimers();

      // Simulate click on dialog
      const event = new MouseEvent('click', { bubbles: true });
      component.elements.dialog.dispatchEvent(event);

      expect(component._state.isVisible).toBe(true);
    });

    test('should handle close button click', () => {
      component.open();
      jest.runAllTimers();

      // Simulate close button click
      const closeButton = component.elements.closeButton;
      const event = new MouseEvent('click', { bubbles: true });
      closeButton.dispatchEvent(event);

      expect(component._state.isVisible).toBe(false);
    });
  });

  describe('Content Management', () => {
    beforeEach(() => {
      component.mount();
    });

    test('should update content dynamically', () => {
      const newContent = '<p>New content</p>';
      component.setContent(newContent);

      expect(component.elements.content.innerHTML).toBe(newContent);
    });

    test('should handle HTML element content', () => {
      const element = document.createElement('div');
      element.textContent = 'Element content';
      component.setContent(element);

      expect(component.elements.content.contains(element)).toBe(true);
    });

    test('should update title dynamically', () => {
      const newTitle = 'New Title';
      component.setTitle(newTitle);

      expect(component.elements.title.textContent).toBe(newTitle);
    });

    test('should add footer buttons', () => {
      const onClick = jest.fn();
      const button = component.addFooterButton('Test Button', 'test-class', onClick);

      expect(button).toBeTruthy();
      expect(button.textContent).toBe('Test Button');
      expect(button.classList.contains('test-class')).toBe(true);

      // Test click handler
      button.click();
      expect(onClick).toHaveBeenCalled();
    });
  });

  describe('Accessibility', () => {
    beforeEach(() => {
      component.mount();
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    test('should maintain proper ARIA attributes', () => {
      component.open();
      jest.runAllTimers();

      const dialog = component.elements.dialog;
      expect(dialog.getAttribute('role')).toBe('dialog');
      expect(dialog.getAttribute('aria-modal')).toBe('true');
      expect(dialog.getAttribute('aria-labelledby')).toBeTruthy();
      expect(dialog.getAttribute('aria-describedby')).toBeTruthy();
    });

    test('should trap focus within modal', () => {
      component.open();
      jest.runAllTimers();

      // Create element outside modal
      const outsideElement = document.createElement('button');
      document.body.appendChild(outsideElement);

      // Attempt to focus outside element
      const focusEvent = new FocusEvent('focusin', { bubbles: true });
      Object.defineProperty(focusEvent, 'target', { value: outsideElement });
      document.dispatchEvent(focusEvent);

      // Focus should return to dialog
      expect(document.activeElement).toBe(component.elements.dialog);

      // Cleanup
      document.body.removeChild(outsideElement);
    });

    test('should manage focus on open/close', () => {
      // Create trigger button
      const triggerButton = document.createElement('button');
      document.body.appendChild(triggerButton);
      triggerButton.focus();

      component.open();
      jest.runAllTimers();

      expect(document.activeElement).toBe(component.elements.dialog);

      component.close();
      jest.runAllTimers();

      // Cleanup
      document.body.removeChild(triggerButton);
    });
  });

  describe('Theme Support', () => {
    beforeEach(() => {
      component.mount();
    });

    test('should apply theme classes', () => {
      expect(component.elements.root.getAttribute('data-theme')).toBe('light');

      // Change theme
      component.options.theme = 'dark';
      component._render();

      expect(component.elements.root.getAttribute('data-theme')).toBe('dark');
    });

    test('should handle theme-specific styles', () => {
      // Set CSS custom properties
      document.documentElement.style.setProperty('--color-bg-tertiary', '#333');
      document.documentElement.style.setProperty('--color-border-dark', '#666');

      component.options.theme = 'dark';
      component._render();

      // Note: We can't test computed styles in Jest DOM
      expect(component.elements.root.getAttribute('data-theme')).toBe('dark');
    });
  });

  describe('LiveView Integration', () => {
    beforeEach(() => {
      component.mount();
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    test('should handle LiveView events', () => {
      // Test event handling
      mockLiveViewHook.handleEvent('open_modal', {});
      expect(component._state.isVisible).toBe(true);

      mockLiveViewHook.handleEvent('close_modal', {});
      expect(component._state.isVisible).toBe(false);
    });

    test('should clean up LiveView hooks on destroy', () => {
      component.destroy();

      expect(EventManager.unregisterComponent).toHaveBeenCalledWith(component.componentId);
      expect(component.elements).toEqual({});
      expect(component._state).toEqual({});
    });
  });

  describe('Edge Cases', () => {
    beforeEach(() => {
      component.mount();
    });

    test('should handle missing container', () => {
      container.remove();
      expect(() => component._render()).not.toThrow();
    });

    test('should handle disabled animations', () => {
      component.options.animation = 'none';
      component._render();

      expect(component.elements.root.classList.contains('modal-component--none')).toBe(true);
    });

    test('should handle rapid mount/unmount cycles', () => {
      for (let i = 0; i < 10; i++) {
        component.mount();
        component.destroy();
      }

      expect(EventManager.unregisterComponent).toHaveBeenCalledTimes(10);
    });

    test('should handle invalid position values', () => {
      component.options.position = 'invalid';
      component._render();

      // Should default to center
      expect(component.elements.root.classList.contains('modal-component--center')).toBe(true);
    });
  });
}); 