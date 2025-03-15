/**
 * Diagram Editor Component Tests
 * ----------------------------
 * Jest test suite for the DiagramEditorComponent class.
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

describe('DiagramEditorComponent', () => {
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
  
  describe('Initialization', () => {
    test('should initialize with correct default properties', () => {
      expect(component.componentId).toMatch(/^diagram-editor-[a-z0-9]{7}$/);
      expect(component.options.container).toBe(container);
      expect(component.options.liveViewHook).toBe(mockLiveViewHook);
      expect(component.options.debug).toBe(true);
      expect(component.options.tabSize).toBe(2);
    });
    
    test('should mount successfully', () => {
      component.mount();
      
      expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
      expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
      expect(component.elements.container).toBe(container);
      expect(component.elements.textarea).toBe(textarea);
      expect(component.elements.preview).toBe(preview);
    });
    
    test('should handle missing container gracefully', () => {
      const consoleSpy = jest.spyOn(console, 'error');
      
      const invalidComponent = new DiagramEditorComponent({
        debug: true
      }).mount();
      
      expect(consoleSpy).toHaveBeenCalledWith(
        'DiagramEditor component requires a container element'
      );
      
      consoleSpy.mockRestore();
    });
  });
  
  describe('Text Manipulation', () => {
    beforeEach(() => {
      component.mount();
    });
    
    test('should get and set text correctly', () => {
      component.setText('Test diagram');
      expect(component.getText()).toBe('Test diagram');
      expect(preview.textContent).toBe('Test diagram');
    });
    
    test('should insert text at cursor position', () => {
      component.setText('Hello world');
      textarea.selectionStart = 6;
      textarea.selectionEnd = 6;
      
      component.insertAtCursor('beautiful ');
      
      expect(component.getText()).toBe('Hello beautiful world');
      expect(preview.textContent).toBe('Hello beautiful world');
    });
    
    test('should handle tab key press', () => {
      const event = new KeyboardEvent('keydown', {
        key: 'Tab',
        bubbles: true,
        cancelable: true
      });
      
      textarea.dispatchEvent(event);
      
      // Should insert spaces based on tabSize option
      expect(textarea.value.startsWith('  ')).toBe(true);
    });
  });
  
  describe('Preview Synchronization', () => {
    beforeEach(() => {
      component.mount();
    });
    
    test('should update preview on text change', () => {
      const inputEvent = new Event('input', { bubbles: true });
      textarea.value = 'New content';
      textarea.dispatchEvent(inputEvent);
      
      expect(preview.textContent).toBe('New content');
    });
    
    test('should maintain preview synchronization after multiple changes', () => {
      component.setText('First update');
      expect(preview.textContent).toBe('First update');
      
      component.setText('Second update');
      expect(preview.textContent).toBe('Second update');
      
      component.insertAtCursor(' with insertion');
      expect(preview.textContent).toBe('Second update with insertion');
    });
  });
  
  describe('Event Handling', () => {
    beforeEach(() => {
      component.mount();
    });
    
    test('should handle LiveView events correctly', () => {
      // Test insert-at-cursor event
      mockLiveViewHook.handleEvent('insert-at-cursor', { text: '→' });
      expect(component.getText()).toContain('→');
      
      // Test copy-to-clipboard event
      const clipboardSpy = jest.spyOn(navigator.clipboard, 'writeText')
        .mockImplementation(() => Promise.resolve());
      
      mockLiveViewHook.handleEvent('copy-to-clipboard', {
        text: 'Copy this',
        message: 'Copied!'
      });
      
      expect(clipboardSpy).toHaveBeenCalledWith('Copy this');
      clipboardSpy.mockRestore();
    });
    
    test('should handle keyboard navigation', () => {
      const arrowEvent = new KeyboardEvent('keydown', {
        key: 'ArrowRight',
        bubbles: true
      });
      
      textarea.dispatchEvent(arrowEvent);
      
      // Verify event listener was added
      expect(EventManager.registerComponent().addEventListener)
        .toHaveBeenCalledWith(textarea, 'keydown', expect.any(Function));
    });
  });
  
  describe('LiveView Integration', () => {
    test('should integrate with LiveView hooks', () => {
      const hook = {
        el: container,
        handleEvent: jest.fn()
      };
      
      // Test mounted hook
      const DiagramEditor = require('../components/diagram_editor').default;
      DiagramEditor.mounted.call(hook);
      
      expect(hook.component).toBeTruthy();
      expect(hook.component instanceof DiagramEditorComponent).toBe(true);
      
      // Test destroyed hook
      DiagramEditor.destroyed.call(hook);
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
  });
}); 