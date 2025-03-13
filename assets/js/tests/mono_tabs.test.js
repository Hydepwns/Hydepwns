/**
 * MonoTabsComponent Tests
 * -----------------------
 * Tests for the MonoTabsComponent class.
 */

import { MonoTabsComponent } from '../components/mono_tabs';
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
    addNode: jest.fn()
  })
}));

describe('MonoTabsComponent', () => {
  let component;
  let container;
  let tabs;
  let panels;
  
  // Setup for tests
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Create mock localStorage
    const localStorageMock = (() => {
      let store = {};
      return {
        getItem: jest.fn((key) => store[key] || null),
        setItem: jest.fn((key, value) => {
          store[key] = value.toString();
        }),
        clear: () => {
          store = {};
        }
      };
    })();
    
    Object.defineProperty(window, 'localStorage', {
      value: localStorageMock,
      writable: true
    });
    
    // Create DOM structure for tabs
    container = document.createElement('div');
    container.dataset.tabsId = 'test-tabs';
    container.className = 'mono-tabs';
    
    // Create tabs
    tabs = [];
    for (let i = 0; i < 3; i++) {
      const tab = document.createElement('button');
      tab.setAttribute('id', `test-tabs-tab-${i}`);
      tab.className = 'mono-tabs__tab';
      tab.textContent = `Tab ${i}`;
      
      if (i === 0) {
        tab.classList.add('mono-tabs__tab--active');
      }
      
      tab.setAttribute('role', 'tab');
      tab.setAttribute('aria-selected', i === 0 ? 'true' : 'false');
      
      // Mock click method
      tab.click = jest.fn(() => {
        // Simulate tab activation
        tabs.forEach((t, index) => {
          if (t === tab) {
            t.classList.add('mono-tabs__tab--active');
            t.setAttribute('aria-selected', 'true');
            panels[index].classList.add('mono-tabs__panel--active');
          } else {
            t.classList.remove('mono-tabs__tab--active');
            t.setAttribute('aria-selected', 'false');
            panels[index].classList.remove('mono-tabs__panel--active');
          }
        });
      });
      
      // Mock focus method
      tab.focus = jest.fn();
      
      container.appendChild(tab);
      tabs.push(tab);
    }
    
    // Create panels
    panels = [];
    for (let i = 0; i < 3; i++) {
      const panel = document.createElement('div');
      panel.setAttribute('id', `test-tabs-panel-${i}`);
      panel.className = 'mono-tabs__panel';
      if (i === 0) {
        panel.classList.add('mono-tabs__panel--active');
      }
      panel.setAttribute('role', 'tabpanel');
      panel.textContent = `Panel ${i} content`;
      
      container.appendChild(panel);
      panels.push(panel);
    }
    
    // Add to document body
    document.body.appendChild(container);
    
    // Create spy for dispatchEvent
    container.dispatchEvent = jest.fn();
  });
  
  afterEach(() => {
    if (component) {
      component.destroy();
    }
    document.body.removeChild(container);
    localStorage.clear();
  });
  
  test('should initialize with default options', () => {
    component = new MonoTabsComponent({
      container
    });
    
    expect(component.options.enablePersistence).toBe(true);
    expect(component.options.debug).toBe(false);
  });
  
  test('should mount component and register with EventManager and DOMCleanup', () => {
    component = new MonoTabsComponent({
      container
    }).mount();
    
    expect(EventManager.registerComponent).toHaveBeenCalledWith(component.componentId);
    expect(DOMCleanup.register).toHaveBeenCalledWith(component.componentId);
    expect(component.elements.container).toBe(container);
    expect(component.elements.tabs.length).toBe(3);
    expect(component.elements.panels.length).toBe(3);
  });
  
  test('should find the active tab index on mount', () => {
    component = new MonoTabsComponent({
      container
    }).mount();
    
    expect(component._state.activeIndex).toBe(0);
    
    // Change active tab
    tabs[0].classList.remove('mono-tabs__tab--active');
    tabs[1].classList.add('mono-tabs__tab--active');
    
    // Update component
    component.update();
    
    expect(component._state.activeIndex).toBe(1);
  });
  
  test('should set up keyboard navigation for tabs', () => {
    component = new MonoTabsComponent({
      container
    }).mount();
    
    // Get event handler setup
    const events = EventManager.registerComponent.mock.results[0].value;
    
    // Should set up keyboard event listeners for each tab
    expect(events.addEventListener).toHaveBeenCalledTimes(3);
    
    // All should be for keydown events
    expect(events.addEventListener.mock.calls[0][1]).toBe('keydown');
    expect(events.addEventListener.mock.calls[1][1]).toBe('keydown');
    expect(events.addEventListener.mock.calls[2][1]).toBe('keydown');
  });
  
  test('should handle keyboard navigation between tabs', () => {
    component = new MonoTabsComponent({
      container
    }).mount();
    
    // Simulate keyboard events
    const rightKeyEvent = new KeyboardEvent('keydown', { key: 'ArrowRight' });
    
    // Navigate right from first tab
    component._handleTabKeyDown({ 
      key: 'ArrowRight', 
      target: tabs[0],
      preventDefault: jest.fn()
    });
    
    // Second tab should be clicked and focused
    expect(tabs[1].click).toHaveBeenCalled();
    expect(tabs[1].focus).toHaveBeenCalled();
    
    // Check that custom event was fired
    expect(container.dispatchEvent).toHaveBeenCalled();
    expect(container.dispatchEvent.mock.calls[0][0].detail.fromIndex).toBe(0);
    expect(container.dispatchEvent.mock.calls[0][0].detail.toIndex).toBe(1);
    
    // Navigate left from second tab
    component._handleTabKeyDown({ 
      key: 'ArrowLeft', 
      target: tabs[1],
      preventDefault: jest.fn()
    });
    
    // First tab should be clicked and focused
    expect(tabs[0].click).toHaveBeenCalled();
    expect(tabs[0].focus).toHaveBeenCalled();
    
    // Navigate to end
    component._handleTabKeyDown({ 
      key: 'End', 
      target: tabs[0],
      preventDefault: jest.fn()
    });
    
    // Last tab should be clicked and focused
    expect(tabs[2].click).toHaveBeenCalled();
    expect(tabs[2].focus).toHaveBeenCalled();
    
    // Navigate to home
    component._handleTabKeyDown({ 
      key: 'Home', 
      target: tabs[2],
      preventDefault: jest.fn()
    });
    
    // First tab should be clicked and focused
    expect(tabs[0].click).toHaveBeenCalled();
    expect(tabs[0].focus).toHaveBeenCalled();
  });
  
  test('should set up persistence when localStorage is available', () => {
    component = new MonoTabsComponent({
      container
    }).mount();
    
    // Simulate tab click
    tabs[1].click();
    
    // Get the event listener callback
    const clickCallback = EventManager.registerComponent.mock.results[0].value.addEventListener.mock.calls[3][2];
    
    // Manually call it
    clickCallback();
    
    // Check localStorage was updated
    expect(localStorage.setItem).toHaveBeenCalledWith('tab-state-test-tabs', '1');
    
    // Check that custom event was fired
    expect(container.dispatchEvent).toHaveBeenCalled();
  });
  
  test('should restore tab state from localStorage on mount', () => {
    // Set a stored tab state
    localStorage.setItem('tab-state-test-tabs', '2');
    
    // Mock document.getElementById for the stored tab
    document.getElementById = jest.fn().mockImplementation((id) => {
      if (id === 'test-tabs-tab-2') {
        return tabs[2];
      }
      return null;
    });
    
    component = new MonoTabsComponent({
      container
    }).mount();
    
    // Third tab should be activated
    expect(tabs[2].click).toHaveBeenCalled();
  });
  
  test('should activate a specific tab via API', () => {
    component = new MonoTabsComponent({
      container
    }).mount();
    
    // Activate the second tab
    component.activateTab(1);
    
    // Second tab should be clicked
    expect(tabs[1].click).toHaveBeenCalled();
    
    // Try invalid index
    component.activateTab(5);
    
    // No additional tabs should be clicked
    expect(tabs[0].click).toHaveBeenCalledTimes(0);
    expect(tabs[1].click).toHaveBeenCalledTimes(1);
    expect(tabs[2].click).toHaveBeenCalledTimes(0);
  });
  
  test('should get the active tab index', () => {
    component = new MonoTabsComponent({
      container
    }).mount();
    
    // Initially the first tab is active
    expect(component.getActiveTabIndex()).toBe(0);
    
    // Change active tab
    tabs[0].classList.remove('mono-tabs__tab--active');
    tabs[2].classList.add('mono-tabs__tab--active');
    component._state.activeIndex = 2;
    
    // Should return updated index
    expect(component.getActiveTabIndex()).toBe(2);
  });
  
  test('should clean up resources when destroyed', () => {
    component = new MonoTabsComponent({
      container
    }).mount();
    
    // Destroy component
    component.destroy();
    
    // Verify cleanup was called
    expect(component.cleanup.cleanup).toHaveBeenCalled();
    expect(EventManager.unregisterComponent).toHaveBeenCalledWith(component.componentId);
    
    // Verify state and elements were cleared
    expect(component.elements).toEqual({});
    expect(component._state).toEqual({});
  });
}); 