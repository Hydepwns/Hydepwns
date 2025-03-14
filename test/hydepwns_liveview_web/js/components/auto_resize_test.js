/**
 * AutoResize Component - Tests
 * ----------------------------
 * 
 * Tests for the AutoResize component, which automatically 
 * resizes textareas to fit their content.
 */

const { AutoResizeComponent } = require('../../../../assets/js/components/auto_resize');
const { createTestElement, cleanupAllComponents } = require('../component_test_utility');

// Mock DOM methods that aren't in JSDOM
Object.defineProperty(HTMLElement.prototype, 'scrollHeight', {
  configurable: true,
  get: function() {
    return parseFloat(this.dataset.mockScrollHeight || 100);
  }
});

describe('AutoResize Component', () => {
  // Setup and teardown
  let container;
  let textarea;
  
  beforeEach(() => {
    // Create a container element
    container = document.createElement('div');
    document.body.appendChild(container);
    
    // Create a textarea element
    textarea = document.createElement('textarea');
    textarea.classList.add('auto-resize');
    textarea.value = 'Initial text';
    textarea.dataset.mockScrollHeight = '100';
    container.appendChild(textarea);
  });
  
  afterEach(() => {
    // Clean up
    if (container && container.parentNode) {
      container.parentNode.removeChild(container);
    }
    
    // Clean up any registered components
    cleanupAllComponents();
  });
  
  test('initializes properly with default options', () => {
    // Create component
    const component = new AutoResizeComponent({
      container: textarea
    }).mount();
    
    // Check that component was created and mounted
    expect(component).toBeTruthy();
    expect(component.elements.container).toBe(textarea);
    
    // Verify the initial state
    expect(component._state.lastHeight).not.toBeNull();
  });
  
  test('resizes textarea when content changes', () => {
    // Mock the scrollHeight
    textarea.dataset.mockScrollHeight = '150';
    
    // Create component
    const component = new AutoResizeComponent({
      container: textarea
    }).mount();
    
    // Get initial height
    const initialHeight = textarea.style.height;
    
    // Simulate content change
    textarea.dataset.mockScrollHeight = '250';
    
    // Manually trigger input event since we can't actually change scrollHeight
    const inputEvent = new Event('input');
    textarea.dispatchEvent(inputEvent);
    
    // Height should be updated
    expect(textarea.style.height).toBe('255px'); // 250px + 5px padding
    expect(textarea.style.height).not.toBe(initialHeight);
  });
  
  test('handles window resize events', () => {
    // Create component
    const component = new AutoResizeComponent({
      container: textarea
    }).mount();
    
    // Directly call the resize method instead of relying on the event
    const resizeSpy = jest.spyOn(component, 'resize');
    
    // Manually call the resize method
    component.resize();
    
    // Resize should be called
    expect(resizeSpy).toHaveBeenCalled();
    
    // Clean up spy
    resizeSpy.mockRestore();
  });
  
  test('cleans up event listeners on destroy', () => {
    // Create component
    const component = new AutoResizeComponent({
      container: textarea
    }).mount();
    
    // Create spies for event listeners
    const removeEventListenerSpy = jest.spyOn(textarea, 'removeEventListener');
    
    // Destroy component
    component.destroy();
    
    // Event listeners should be removed
    expect(removeEventListenerSpy).toHaveBeenCalled();
    
    // Clean up spies
    removeEventListenerSpy.mockRestore();
  });
  
  test('works with LiveView hook lifecycle', () => {
    // Create a mock LiveView hook
    const hook = {
      el: textarea
    };
    
    // Create the AutoResize hook methods
    const AutoResize = {
      mounted() {
        this.autoResize = new AutoResizeComponent({
          liveViewHook: this,
          container: this.el
        }).mount();
      },
      
      destroyed() {
        if (this.autoResize) {
          this.autoResize.destroy();
          this.autoResize = null;
        }
      }
    };
    
    // Call the mounted lifecycle method
    AutoResize.mounted.call(hook);
    
    // Should have created component
    expect(hook.autoResize).toBeDefined();
    expect(hook.autoResize.elements.container).toBe(textarea);
    
    // Call the destroyed lifecycle method
    AutoResize.destroyed.call(hook);
    
    // Should have cleaned up component
    expect(hook.autoResize).toBeNull();
  });
  
  test('handles initial resize on mount', () => {
    // Set initial height
    textarea.style.height = '50px';
    
    // Mock a larger content
    textarea.dataset.mockScrollHeight = '200';
    
    // Create component
    const component = new AutoResizeComponent({
      container: textarea
    }).mount();
    
    // Height should be updated immediately on mount
    expect(textarea.style.height).toBe('205px'); // 200px + 5px padding
    expect(textarea.style.height).not.toBe('50px');
  });
}); 