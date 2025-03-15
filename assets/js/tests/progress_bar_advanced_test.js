/**
 * Advanced Progress Bar Component Tests
 * -----------------------------------
 * Tests for complex functionality, edge cases, and advanced features
 * of the ProgressBar component.
 */

import { ProgressBarComponent } from '../components/progress_bar';
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
      if (content) element.textContent = content;
      return element;
    })
  })
}));

describe('ProgressBarComponent - Advanced Features', () => {
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
    component = new ProgressBarComponent({
      container,
      liveViewHook: mockLiveViewHook,
      initialProgress: 0,
      height: '8px',
      width: '100%',
      color: 'var(--accent-color)',
      backgroundColor: 'var(--accent-color-light)',
      animated: true,
      showPercentage: true,
      striped: true,
      rounded: true,
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
  });

  describe('Initialization and DOM Structure', () => {
    test('should create proper DOM structure with all features enabled', () => {
      component.mount();

      const progressBarContainer = container.querySelector('.progress-bar-container');
      expect(progressBarContainer).toBeTruthy();
      expect(progressBarContainer.style.height).toBe('8px');
      expect(progressBarContainer.style.width).toBe('100%');
      expect(progressBarContainer.style.borderRadius).toBe('9999px');

      const progressBar = progressBarContainer.querySelector('.progress-bar');
      expect(progressBar).toBeTruthy();
      expect(progressBar.classList.contains('progress-bar-striped')).toBe(true);
      expect(progressBar.classList.contains('progress-bar-animated')).toBe(true);

      const percentageText = progressBarContainer.querySelector('.progress-bar-percentage');
      expect(percentageText).toBeTruthy();
      expect(percentageText.textContent).toBe('0%');
    });

    test('should handle missing options gracefully', () => {
      component = new ProgressBarComponent({ container }).mount();

      const progressBarContainer = container.querySelector('.progress-bar-container');
      expect(progressBarContainer).toBeTruthy();
      expect(progressBarContainer.style.height).toBeTruthy();
      expect(progressBarContainer.style.width).toBeTruthy();
    });

    test('should generate unique component IDs', () => {
      const component1 = new ProgressBarComponent({ container }).mount();
      const component2 = new ProgressBarComponent({ container }).mount();

      expect(component1.componentId).not.toBe(component2.componentId);
      expect(component1.componentId).toMatch(/^progress-bar-[a-z0-9]+$/);
      expect(component2.componentId).toMatch(/^progress-bar-[a-z0-9]+$/);
    });
  });

  describe('Progress Updates and Animations', () => {
    beforeEach(() => {
      component.mount();
      // Mock requestAnimationFrame
      jest.spyOn(window, 'requestAnimationFrame').mockImplementation(cb => setTimeout(cb, 0));
      jest.spyOn(window, 'cancelAnimationFrame').mockImplementation(id => clearTimeout(id));
    });

    afterEach(() => {
      window.requestAnimationFrame.mockRestore();
      window.cancelAnimationFrame.mockRestore();
    });

    test('should update progress with animation', () => {
      const progressBar = container.querySelector('.progress-bar');
      
      component.setProgress(50);
      expect(progressBar.style.width).toBe('50%');
      
      if (component.options.showPercentage) {
        const percentageText = container.querySelector('.progress-bar-percentage');
        expect(percentageText.textContent).toBe('50%');
      }
    });

    test('should handle rapid progress updates', () => {
      const updates = [10, 20, 30, 40, 50];
      updates.forEach(value => {
        component.setProgress(value);
      });

      const progressBar = container.querySelector('.progress-bar');
      expect(progressBar.style.width).toBe('50%');
    });

    test('should handle completion state', () => {
      component.setProgress(100);

      const container = component.elements.progressBarContainer;
      expect(container.classList.contains('progress-complete')).toBe(true);
      
      // Test callback
      const onComplete = jest.fn();
      component.options.onComplete = onComplete;
      component.setProgress(50); // Reset
      component.setProgress(100);
      expect(onComplete).toHaveBeenCalled();
    });

    test('should handle progress reset', () => {
      component.setProgress(50);
      component.reset();

      const progressBar = container.querySelector('.progress-bar');
      expect(progressBar.style.width).toBe('0%');
      
      if (component.options.showPercentage) {
        const percentageText = container.querySelector('.progress-bar-percentage');
        expect(percentageText.textContent).toBe('0%');
      }
    });
  });

  describe('Edge Cases', () => {
    beforeEach(() => {
      component.mount();
    });

    test('should handle invalid progress values', () => {
      // Test negative values
      component.setProgress(-20);
      expect(component._state.progress).toBe(0);

      // Test values over 100
      component.setProgress(150);
      expect(component._state.progress).toBe(100);

      // Test non-numeric values
      component.setProgress('not a number');
      expect(component._state.progress).toBe(0);
    });

    test('should handle rapid mount/unmount cycles', () => {
      for (let i = 0; i < 10; i++) {
        component.mount();
        component.destroy();
      }

      // Should not throw errors and should clean up properly
      expect(EventManager.unregisterComponent).toHaveBeenCalledTimes(10);
    });

    test('should handle missing container', () => {
      container.remove();
      expect(() => component._updateProgressBar(50)).not.toThrow();
    });

    test('should handle disabled animations', () => {
      component.options.animated = false;
      component.setProgress(50);

      const progressBar = container.querySelector('.progress-bar');
      expect(progressBar.style.transition).toBe('none');
    });
  });

  describe('Accessibility', () => {
    beforeEach(() => {
      component.mount();
    });

    test('should maintain proper ARIA attributes', () => {
      const progressBarContainer = container.querySelector('.progress-bar-container');
      expect(progressBarContainer.getAttribute('role')).toBe('progressbar');
      expect(progressBarContainer.getAttribute('aria-valuemin')).toBe('0');
      expect(progressBarContainer.getAttribute('aria-valuemax')).toBe('100');
      expect(progressBarContainer.getAttribute('aria-valuenow')).toBe('0');

      component.setProgress(50);
      expect(progressBarContainer.getAttribute('aria-valuenow')).toBe('50');
    });

    test('should handle focus management', () => {
      const progressBarContainer = container.querySelector('.progress-bar-container');
      progressBarContainer.focus();

      expect(document.activeElement).toBe(progressBarContainer);
      expect(window.getComputedStyle(progressBarContainer).outlineStyle).not.toBe('none');
    });
  });

  describe('Theme Support', () => {
    beforeEach(() => {
      component.mount();
    });

    test('should use CSS custom properties for theming', () => {
      const progressBar = container.querySelector('.progress-bar');
      expect(progressBar.style.backgroundColor).toBe('var(--accent-color)');

      const progressBarContainer = container.querySelector('.progress-bar-container');
      expect(progressBarContainer.style.backgroundColor).toBe('var(--accent-color-light)');
    });

    test('should handle theme changes', () => {
      // Simulate theme change
      document.documentElement.style.setProperty('--accent-color', '#ff0000');
      document.documentElement.style.setProperty('--accent-color-light', '#ffcccc');

      // Force update
      component._updateProgressBar(component._state.progress);

      // Note: We can't test computed styles in Jest DOM, but we can verify the variables are used
      const progressBar = container.querySelector('.progress-bar');
      expect(progressBar.style.backgroundColor).toBe('var(--accent-color)');
    });
  });

  describe('LiveView Integration', () => {
    beforeEach(() => {
      component.mount();
    });

    test('should handle LiveView progress updates', () => {
      // Simulate LiveView event
      mockLiveViewHook.handleEvent('progress_update', { value: 75 });
      
      const progressBar = container.querySelector('.progress-bar');
      expect(progressBar.style.width).toBe('75%');
    });

    test('should clean up LiveView hooks on destroy', () => {
      component.destroy();
      
      expect(EventManager.unregisterComponent).toHaveBeenCalledWith(component.componentId);
      expect(component.elements).toEqual({});
      expect(component._state).toEqual({});
    });
  });

  describe('Debug Mode', () => {
    test('should log debug information when enabled', () => {
      const consoleSpy = jest.spyOn(console, 'log').mockImplementation();

      component.mount();

      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('[ProgressBar:'),
        'Component mounted'
      );

      component.setProgress(50);
      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('[ProgressBar:'),
        expect.any(String),
        expect.any(Object)
      );

      consoleSpy.mockRestore();
    });
  });
}); 