/**
 * Advanced Diagram Editor Component Tests
 * -------------------------------------
 * Additional test coverage for edge cases, resource management,
 * error handling, accessibility, and theme integration.
 */

import { DiagramEditorComponent } from '../components/diagram_editor';
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

describe('DiagramEditorComponent - Advanced Features', () => {
  let component;
  let container;
  let textarea;
  let preview;
  let mockLiveViewHook;
  
  // Helper to create test container with required elements
  const createTestContainer = () => {
    container = document.createElement('div');
    container.className = 'diagram-editor';
    
    textarea = document.createElement('textarea');
    textarea.className = 'diagram-editor';
    container.appendChild(textarea);
    
    const previewSection = document.createElement('div');
    previewSection.className = 'diagram-preview';
    
    preview = document.createElement('code');
    previewSection.appendChild(preview);
    container.appendChild(previewSection);
    
    document.body.appendChild(container);
    return container;
  };
  
  beforeEach(() => {
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
    component = new DiagramEditorComponent({
      container,
      liveViewHook: mockLiveViewHook,
      debug: true,
      tabSize: 2
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
    textarea = null;
    preview = null;
    component = null;
  });

  describe('Resource Management', () => {
    test('should properly clean up event listeners on destroy', () => {
      component.mount();
      
      const events = EventManager.registerComponent(component.componentId);
      const cleanup = DOMCleanup.register(component.componentId);
      
      component.destroy();
      
      expect(cleanup.cleanup).toHaveBeenCalled();
      expect(EventManager.unregisterComponent).toHaveBeenCalledWith(component.componentId);
    });
    
    test('should handle multiple mount/destroy cycles', () => {
      // First cycle
      component.mount();
      component.destroy();
      
      // Second cycle
      component.mount();
      component.destroy();
      
      expect(EventManager.registerComponent).toHaveBeenCalledTimes(2);
      expect(EventManager.unregisterComponent).toHaveBeenCalledTimes(2);
    });
    
    test('should clean up notification elements', () => {
      component.mount();
      
      // Mock createElement to track created elements
      const mockElement = document.createElement('div');
      DOMCleanup.register().createElement.mockReturnValue(mockElement);
      
      // Trigger notification
      mockLiveViewHook.handleEvent('copy-to-clipboard', {
        text: 'test',
        message: 'Copied!'
      });
      
      // Fast-forward timers
      jest.runAllTimers();
      
      expect(mockElement.parentNode).toBeNull();
    });
  });

  describe('Error Handling', () => {
    test('should handle missing preview element gracefully', () => {
      // Remove preview element
      preview.remove();
      
      const consoleSpy = jest.spyOn(console, 'warn');
      component.mount();
      
      expect(consoleSpy).toHaveBeenCalledWith(
        'DiagramEditor: Preview element not found'
      );
      
      consoleSpy.mockRestore();
    });
    
    test('should handle missing textarea element gracefully', () => {
      // Remove textarea element
      textarea.remove();
      
      const consoleSpy = jest.spyOn(console, 'warn');
      component.mount();
      
      expect(consoleSpy).toHaveBeenCalledWith(
        'DiagramEditor: Textarea element not found'
      );
      
      consoleSpy.mockRestore();
    });
    
    test('should handle invalid text insertion gracefully', () => {
      component.mount();
      
      // Try to insert text when textarea is not available
      textarea.remove();
      component.insertAtCursor('test');
      
      // Should not throw and should return this for chaining
      expect(component.insertAtCursor('test')).toBe(component);
    });
  });

  describe('Edge Cases', () => {
    test('should handle rapid text changes', () => {
      component.mount();
      
      // Simulate rapid text changes
      for (let i = 0; i < 100; i++) {
        component.setText(`Rapid change ${i}`);
      }
      
      expect(preview.textContent).toBe('Rapid change 99');
    });
    
    test('should handle large text content', () => {
      component.mount();
      
      // Create large text content
      const largeText = 'x'.repeat(10000);
      component.setText(largeText);
      
      expect(component.getText()).toBe(largeText);
      expect(preview.textContent).toBe(largeText);
    });
    
    test('should handle special characters', () => {
      component.mount();
      
      const specialChars = '←→↑↓⇄⇅★☆♠♣♥♦';
      component.setText(specialChars);
      
      expect(component.getText()).toBe(specialChars);
      expect(preview.textContent).toBe(specialChars);
    });
  });

  describe('Accessibility', () => {
    test('should maintain proper ARIA attributes', () => {
      component.mount();
      
      expect(textarea.getAttribute('role')).toBe('textbox');
      expect(textarea.getAttribute('aria-multiline')).toBe('true');
      expect(preview.getAttribute('aria-live')).toBe('polite');
    });
    
    test('should handle keyboard navigation', () => {
      component.mount();
      
      // Test tab key handling
      const tabEvent = new KeyboardEvent('keydown', {
        key: 'Tab',
        bubbles: true,
        cancelable: true
      });
      
      textarea.dispatchEvent(tabEvent);
      expect(tabEvent.defaultPrevented).toBe(true);
      
      // Verify spaces were inserted
      expect(textarea.value).toBe('  ');
    });
    
    test('should maintain focus state', () => {
      component.mount();
      
      textarea.focus();
      expect(document.activeElement).toBe(textarea);
      
      component.setText('New text');
      expect(document.activeElement).toBe(textarea);
    });
  });

  describe('Theme Integration', () => {
    test('should apply theme variables', () => {
      component.mount();
      
      const styles = window.getComputedStyle(container);
      
      expect(styles.getPropertyValue('--background-color-alt')).toBeTruthy();
      expect(styles.getPropertyValue('--border-color')).toBeTruthy();
      expect(styles.getPropertyValue('--text-color')).toBeTruthy();
    });
    
    test('should handle theme changes', () => {
      component.mount();
      
      // Simulate theme change
      document.documentElement.setAttribute('data-theme', 'dark');
      
      const styles = window.getComputedStyle(container);
      expect(styles.backgroundColor).toBeTruthy();
    });
  });
}); 