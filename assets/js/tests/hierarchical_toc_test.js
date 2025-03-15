/**
 * Hierarchical TOC Component Tests
 * -----------------------
 * Jest test suite for the HierarchicalTOCComponent class.
 */

import { HierarchicalTOCComponent } from '../components/hierarchical_toc';
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
    createElement: jest.fn(),
    registerCleanupFunction: jest.fn()
  })
}));

describe('HierarchicalTOCComponent', () => {
  let component;
  let container;
  let mockLiveViewHook;
  
  // Helper function to create TOC structure
  const createTOCStructure = () => {
    const tocHTML = `
      <nav id="TOC" role="doc-toc" class="hierarchical-toc-nav">
        <h2 id="toc-title" class="visually-hidden">Contents</h2>
        <ul class="toc-list">
          <li class="toc-item">
            <a href="#section1" id="toc-section1" class="toc-link">
              <span class="toggle-indicator">▼</span>
              <span class="toc-label">Section 1</span>
            </a>
            <ul class="toc-sublist">
              <li class="toc-item">
                <a href="#section1-1" id="toc-section1-1" class="toc-link">
                  <span class="toc-label">Section 1.1</span>
                </a>
              </li>
            </ul>
          </li>
          <li class="toc-item">
            <a href="#section2" id="toc-section2" class="toc-link">
              <span class="toggle-indicator">▼</span>
              <span class="toc-label">Section 2</span>
            </a>
            <ul class="toc-sublist">
              <li class="toc-item">
                <a href="#section2-1" id="toc-section2-1" class="toc-link">
                  <span class="toc-label">Section 2.1</span>
                </a>
              </li>
            </ul>
          </li>
        </ul>
      </nav>
    `;
    container.innerHTML = tocHTML;
    
    // Create corresponding heading elements
    const headings = `
      <h2 id="section1">Section 1</h2>
      <h3 id="section1-1">Section 1.1</h3>
      <h2 id="section2">Section 2</h2>
      <h3 id="section2-1">Section 2.1</h3>
    `;
    const contentContainer = document.createElement('div');
    contentContainer.innerHTML = headings;
    document.body.appendChild(contentContainer);
    
    return contentContainer;
  };
  
  beforeEach(() => {
    // Create container
    container = document.createElement('div');
    container.id = 'hierarchical-toc-test';
    document.body.appendChild(container);
    
    // Create mock LiveView hook
    mockLiveViewHook = {
      el: container,
      handleEvent: jest.fn(),
      pushEvent: jest.fn()
    };
    
    // Mock IntersectionObserver
    window.IntersectionObserver = jest.fn(() => ({
      observe: jest.fn(),
      unobserve: jest.fn(),
      disconnect: jest.fn()
    }));
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
      component = new HierarchicalTOCComponent({
        container,
        liveViewHook: mockLiveViewHook,
        debug: true
      });
      
      expect(component.componentId).toMatch(/^hierarchical-toc-[a-z0-9]{7}$/);
      expect(component.options.container).toBe(container);
      expect(component.options.scrollSpyRootMargin).toBe('-100px 0px -80% 0px');
      expect(component.options.scrollSpyThreshold).toBe(0);
      expect(component.options.initialHashDelay).toBe(500);
      expect(component.options.expandedToggleSymbol).toBe('▼');
      expect(component.options.collapsedToggleSymbol).toBe('▶');
      expect(component.options.liveViewHook).toBe(mockLiveViewHook);
      expect(component.options.debug).toBe(true);
    });
    
    test('should mount successfully', () => {
      const contentContainer = createTOCStructure();
      
      component = new HierarchicalTOCComponent({
        container,
        liveViewHook: mockLiveViewHook
      });
      
      component.mount();
      
      expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
      expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
      expect(component.elements.container).toBe(container);
      expect(component.elements.tocItems.length).toBe(4); // 2 parent + 2 child items
      expect(component.elements.toggleIndicators.length).toBe(2);
      expect(component.elements.tocLinks.length).toBe(4);
      
      contentContainer.remove();
    });
  });
  
  describe('Section Toggling', () => {
    let contentContainer;
    
    beforeEach(() => {
      contentContainer = createTOCStructure();
      component = new HierarchicalTOCComponent({
        container,
        liveViewHook: mockLiveViewHook
      });
      component.mount();
    });
    
    afterEach(() => {
      contentContainer.remove();
    });
    
    test('should toggle section on toggle indicator click', () => {
      const item = container.querySelector('.toc-item');
      const toggle = item.querySelector('.toggle-indicator');
      const sublist = item.querySelector('.toc-sublist');
      
      // Click to collapse
      toggle.click();
      expect(sublist.classList.contains('collapsed')).toBe(true);
      expect(toggle.textContent).toBe('▶');
      
      // Click to expand
      toggle.click();
      expect(sublist.classList.contains('collapsed')).toBe(false);
      expect(toggle.textContent).toBe('▼');
    });
    
    test('should handle toggle click on parent link', () => {
      const item = container.querySelector('.toc-item');
      const link = item.querySelector('.toc-link');
      const toggle = item.querySelector('.toggle-indicator');
      const sublist = item.querySelector('.toc-sublist');
      
      // Click on toggle within link
      const event = new MouseEvent('click', {
        bubbles: true,
        cancelable: true
      });
      Object.defineProperty(event, 'target', { value: toggle });
      link.dispatchEvent(event);
      
      expect(sublist.classList.contains('collapsed')).toBe(true);
      expect(toggle.textContent).toBe('▶');
    });
  });
  
  describe('Keyboard Navigation', () => {
    let contentContainer;
    
    beforeEach(() => {
      contentContainer = createTOCStructure();
      component = new HierarchicalTOCComponent({
        container,
        liveViewHook: mockLiveViewHook
      });
      component.mount();
    });
    
    afterEach(() => {
      contentContainer.remove();
    });
    
    test('should toggle section with Space key', () => {
      const link = container.querySelector('.toc-link');
      const toggle = link.querySelector('.toggle-indicator');
      const sublist = link.closest('.toc-item').querySelector('.toc-sublist');
      
      const event = new KeyboardEvent('keydown', {
        key: ' ',
        bubbles: true
      });
      
      link.dispatchEvent(event);
      
      expect(sublist.classList.contains('collapsed')).toBe(true);
      expect(toggle.textContent).toBe('▶');
    });
    
    test('should handle arrow key navigation', () => {
      const link = container.querySelector('.toc-link');
      const toggle = link.querySelector('.toggle-indicator');
      const sublist = link.closest('.toc-item').querySelector('.toc-sublist');
      
      // Right arrow to expand
      link.dispatchEvent(new KeyboardEvent('keydown', {
        key: 'ArrowRight',
        bubbles: true
      }));
      
      expect(sublist.classList.contains('collapsed')).toBe(false);
      expect(toggle.textContent).toBe('▼');
      
      // Left arrow to collapse
      link.dispatchEvent(new KeyboardEvent('keydown', {
        key: 'ArrowLeft',
        bubbles: true
      }));
      
      expect(sublist.classList.contains('collapsed')).toBe(true);
      expect(toggle.textContent).toBe('▶');
    });
  });
  
  describe('Scroll Spy', () => {
    let contentContainer;
    let observerCallback;
    
    beforeEach(() => {
      contentContainer = createTOCStructure();
      
      // Capture IntersectionObserver callback
      window.IntersectionObserver = jest.fn((callback) => {
        observerCallback = callback;
        return {
          observe: jest.fn(),
          unobserve: jest.fn(),
          disconnect: jest.fn()
        };
      });
      
      component = new HierarchicalTOCComponent({
        container,
        liveViewHook: mockLiveViewHook
      });
      component.mount();
    });
    
    afterEach(() => {
      contentContainer.remove();
    });
    
    test('should update active section on scroll', () => {
      const section = document.getElementById('section1');
      
      // Simulate intersection
      observerCallback([{
        target: section,
        isIntersecting: true
      }]);
      
      const activeLink = container.querySelector('.toc-link[href="#section1"]');
      const activeItem = activeLink.closest('.toc-item');
      
      expect(activeItem.classList.contains('active')).toBe(true);
    });
    
    test('should expand parent sections of active item', () => {
      const section = document.getElementById('section1-1');
      const parentItem = container.querySelector('.toc-link[href="#section1"]').closest('.toc-item');
      const parentSublist = parentItem.querySelector('.toc-sublist');
      
      // Collapse parent section first
      parentSublist.classList.add('collapsed');
      
      // Simulate intersection of child section
      observerCallback([{
        target: section,
        isIntersecting: true
      }]);
      
      expect(parentSublist.classList.contains('collapsed')).toBe(false);
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
      const HierarchicalTOC = require('../components/hierarchical_toc').default;
      HierarchicalTOC.mounted.call(hook);
      
      expect(hook.component).toBeTruthy();
      expect(hook.component instanceof HierarchicalTOCComponent).toBe(true);
      
      // Test updated hook
      HierarchicalTOC.updated.call(hook);
      
      // Test disconnected hook
      HierarchicalTOC.disconnected.call(hook);
      expect(hook.component).toBeNull();
    });
  });
  
  describe('Cleanup', () => {
    let contentContainer;
    
    beforeEach(() => {
      contentContainer = createTOCStructure();
      component = new HierarchicalTOCComponent({
        container,
        liveViewHook: mockLiveViewHook
      });
      component.mount();
    });
    
    afterEach(() => {
      contentContainer.remove();
    });
    
    test('should clean up resources on destroy', () => {
      const cleanupSpy = jest.spyOn(DOMCleanup.register(), 'cleanup');
      const unregisterSpy = jest.spyOn(EventManager, 'unregisterComponent');
      const disconnectSpy = jest.spyOn(component.intersectionObserver, 'disconnect');
      
      component.destroy();
      
      expect(cleanupSpy).toHaveBeenCalled();
      expect(unregisterSpy).toHaveBeenCalledWith(component.componentId);
      expect(disconnectSpy).toHaveBeenCalled();
      expect(component.elements).toEqual({
        container: null,
        tocItems: [],
        toggleIndicators: [],
        tocLinks: []
      });
      expect(component._state).toEqual({
        activeSection: null,
        headingElements: []
      });
      
      cleanupSpy.mockRestore();
      unregisterSpy.mockRestore();
      disconnectSpy.mockRestore();
    });
    
    test('should handle multiple destroy calls gracefully', () => {
      component.destroy();
      expect(() => component.destroy()).not.toThrow();
    });
  });
}); 