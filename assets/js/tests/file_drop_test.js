/**
 * File Drop Component Tests
 * -----------------------
 * Jest test suite for the FileDropComponent class.
 */

import { FileDropComponent } from '../components/file_drop';
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
          } else if (key === 'style' && typeof value === 'string') {
            element.style.cssText = value;
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

describe('FileDropComponent', () => {
  let component;
  let container;
  let mockLiveViewHook;
  let fileDroppedCallback;
  let fileRejectedCallback;
  
  // Helper to create test files
  const createTestFile = (name, type, size) => {
    return new File(['test content'], name, { type });
  };
  
  beforeEach(() => {
    // Create container
    container = document.createElement('div');
    container.id = 'file-drop-test';
    document.body.appendChild(container);
    
    // Create mock callbacks
    fileDroppedCallback = jest.fn();
    fileRejectedCallback = jest.fn();
    
    // Create mock LiveView hook
    mockLiveViewHook = {
      el: container,
      handleEvent: jest.fn(),
      pushEvent: jest.fn()
    };
    
    // Create component instance
    component = new FileDropComponent({
      container,
      liveViewHook: mockLiveViewHook,
      debug: true,
      accept: 'image/*,.pdf',
      multiple: true,
      maxSize: 5 * 1024 * 1024,
      maxFiles: 3,
      fileDroppedCallback,
      fileRejectedCallback
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
      expect(component.componentId).toMatch(/^file-drop-[a-z0-9]{7}$/);
      expect(component.options.container).toBe(container);
      expect(component.options.liveViewHook).toBe(mockLiveViewHook);
      expect(component.options.accept).toBe('image/*,.pdf');
      expect(component.options.multiple).toBe(true);
      expect(component.options.maxSize).toBe(5 * 1024 * 1024);
      expect(component.options.maxFiles).toBe(3);
    });
    
    test('should mount successfully', () => {
      component.mount();
      
      expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
      expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
      expect(component.elements.container).toBe(container);
      expect(component.elements.dropZone).toBeTruthy();
      expect(component.elements.fileInput).toBeTruthy();
      expect(component.elements.fileList).toBeTruthy();
    });
    
    test('should handle missing container gracefully', () => {
      const consoleSpy = jest.spyOn(console, 'error');
      
      const invalidComponent = new FileDropComponent({
        debug: true
      }).mount();
      
      expect(consoleSpy).toHaveBeenCalledWith(
        'FileDrop component requires a container element'
      );
      
      consoleSpy.mockRestore();
    });
  });
  
  describe('File Handling', () => {
    beforeEach(() => {
      component.mount();
    });
    
    test('should accept valid files', () => {
      const validFile = createTestFile('test.jpg', 'image/jpeg', 1024 * 1024);
      const dataTransfer = { files: [validFile] };
      
      const dropEvent = new Event('drop');
      Object.defineProperty(dropEvent, 'dataTransfer', { value: dataTransfer });
      
      component.elements.dropZone.dispatchEvent(dropEvent);
      
      expect(fileDroppedCallback).toHaveBeenCalledWith([validFile]);
      expect(component.getFiles()).toHaveLength(1);
      expect(component.getFiles()[0].name).toBe('test.jpg');
    });
    
    test('should reject invalid file types', () => {
      const invalidFile = createTestFile('test.txt', 'text/plain', 1024);
      const dataTransfer = { files: [invalidFile] };
      
      const dropEvent = new Event('drop');
      Object.defineProperty(dropEvent, 'dataTransfer', { value: dataTransfer });
      
      component.elements.dropZone.dispatchEvent(dropEvent);
      
      expect(fileRejectedCallback).toHaveBeenCalled();
      expect(fileRejectedCallback.mock.calls[0][0][0].reason).toContain('File type not accepted');
      expect(component.getFiles()).toHaveLength(0);
    });
    
    test('should reject files exceeding size limit', () => {
      const largeFile = createTestFile('large.jpg', 'image/jpeg', 10 * 1024 * 1024);
      const dataTransfer = { files: [largeFile] };
      
      const dropEvent = new Event('drop');
      Object.defineProperty(dropEvent, 'dataTransfer', { value: dataTransfer });
      
      component.elements.dropZone.dispatchEvent(dropEvent);
      
      expect(fileRejectedCallback).toHaveBeenCalled();
      expect(fileRejectedCallback.mock.calls[0][0][0].reason).toContain('exceeds maximum allowed size');
      expect(component.getFiles()).toHaveLength(0);
    });
    
    test('should enforce maxFiles limit', () => {
      const files = [
        createTestFile('1.jpg', 'image/jpeg', 1024),
        createTestFile('2.jpg', 'image/jpeg', 1024),
        createTestFile('3.jpg', 'image/jpeg', 1024),
        createTestFile('4.jpg', 'image/jpeg', 1024)
      ];
      
      const dataTransfer = { files };
      const dropEvent = new Event('drop');
      Object.defineProperty(dropEvent, 'dataTransfer', { value: dataTransfer });
      
      component.elements.dropZone.dispatchEvent(dropEvent);
      
      expect(component.getFiles()).toHaveLength(3);
      expect(fileRejectedCallback).toHaveBeenCalled();
      expect(fileRejectedCallback.mock.calls[0][0][0].reason).toContain('Maximum number of files');
    });
  });
  
  describe('UI Interaction', () => {
    beforeEach(() => {
      component.mount();
    });
    
    test('should handle drag events', () => {
      const dragEnterEvent = new Event('dragenter');
      const dragLeaveEvent = new Event('dragleave');
      
      component.elements.dropZone.dispatchEvent(dragEnterEvent);
      expect(component.elements.dropZone.classList.contains('file-drop__zone--active')).toBe(true);
      
      component.elements.dropZone.dispatchEvent(dragLeaveEvent);
      expect(component.elements.dropZone.classList.contains('file-drop__zone--active')).toBe(false);
    });
    
    test('should handle file removal', () => {
      const file = createTestFile('test.jpg', 'image/jpeg', 1024);
      const dataTransfer = { files: [file] };
      
      const dropEvent = new Event('drop');
      Object.defineProperty(dropEvent, 'dataTransfer', { value: dataTransfer });
      
      component.elements.dropZone.dispatchEvent(dropEvent);
      expect(component.getFiles()).toHaveLength(1);
      
      component.removeFile(0);
      expect(component.getFiles()).toHaveLength(0);
    });
    
    test('should trigger file input on dropzone click', () => {
      const clickSpy = jest.spyOn(component.elements.fileInput, 'click');
      
      component.elements.dropZone.click();
      
      expect(clickSpy).toHaveBeenCalled();
      clickSpy.mockRestore();
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
      const FileDrop = require('../components/file_drop').default;
      FileDrop.mounted.call(hook);
      
      expect(hook.component).toBeTruthy();
      expect(hook.component instanceof FileDropComponent).toBe(true);
      
      // Test destroyed hook
      FileDrop.destroyed.call(hook);
      expect(hook.component).toBeNull();
    });
    
    test('should push events to LiveView on file selection', () => {
      component.mount();
      
      const file = createTestFile('test.jpg', 'image/jpeg', 1024);
      const dataTransfer = { files: [file] };
      
      const dropEvent = new Event('drop');
      Object.defineProperty(dropEvent, 'dataTransfer', { value: dataTransfer });
      
      component.elements.dropZone.dispatchEvent(dropEvent);
      
      expect(mockLiveViewHook.pushEvent).toHaveBeenCalledWith('files_selected', {
        files: [{
          name: 'test.jpg',
          size: expect.any(Number),
          type: 'image/jpeg'
        }]
      });
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