/**
 * Advanced MonoTabs Component Tests
 * --------------------------------
 * Tests for complex functionality, edge cases, and advanced features of the MonoTabs component.
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
    cleanup: jest.fn()
  })
}));

describe('MonoTabs Advanced Features', () => {
  let component;
  let container;
  let tabs;
  let panels;
  let localStorageMock;

  // Setup for tests
  beforeEach(() => {
    jest.clearAllMocks();

    // Create mock localStorage
    localStorageMock = (() => {
      let store = {};
      return {
        getItem: jest.fn((key) => store[key] || null),
        setItem: jest.fn((key, value) => {
          store[key] = value.toString();
        }),
        removeItem: jest.fn((key) => {
          delete store[key];
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

    // Create DOM structure
    container = document.createElement('div');
    container.dataset.tabsId = 'test-tabs';
    container.className = 'mono-tabs';

    // Create tabs with various states and attributes
    tabs = Array.from({ length: 4 }, (_, i) => {
      const tab = document.createElement('button');
      tab.setAttribute('id', `test-tabs-tab-${i}`);
      tab.className = 'mono-tabs__tab';
      tab.textContent = `Tab ${i}`;
      tab.setAttribute('role', 'tab');
      tab.setAttribute('aria-selected', i === 0 ? 'true' : 'false');
      
      if (i === 0) {
        tab.classList.add('mono-tabs__tab--active');
      }
      
      // Add icon to one tab
      if (i === 2) {
        const icon = document.createElement('span');
        icon.className = 'mono-tabs__icon';
        icon.textContent = '📎';
        tab.prepend(icon);
      }

      // Mock click and focus methods
      tab.click = jest.fn(() => {
        tabs.forEach((t, idx) => {
          if (t === tab) {
            t.classList.add('mono-tabs__tab--active');
            t.setAttribute('aria-selected', 'true');
            panels[idx].classList.add('mono-tabs__panel--active');
            panels[idx].removeAttribute('hidden');
          } else {
            t.classList.remove('mono-tabs__tab--active');
            t.setAttribute('aria-selected', 'false');
            panels[idx].classList.remove('mono-tabs__panel--active');
            panels[idx].setAttribute('hidden', 'true');
          }
        });
      });
      
      tab.focus = jest.fn();
      
      container.appendChild(tab);
      return tab;
    });

    // Create panels with various content types
    panels = Array.from({ length: 4 }, (_, i) => {
      const panel = document.createElement('div');
      panel.setAttribute('id', `test-tabs-panel-${i}`);
      panel.className = 'mono-tabs__panel';
      panel.setAttribute('role', 'tabpanel');
      panel.setAttribute('aria-labelledby', `test-tabs-tab-${i}`);
      
      if (i === 0) {
        panel.classList.add('mono-tabs__panel--active');
      } else {
        panel.setAttribute('hidden', 'true');
      }

      // Add different types of content
      switch (i) {
        case 0:
          panel.innerHTML = '<p>Simple text content</p>';
          break;
        case 1:
          panel.innerHTML = '<div class="mono-grid"><div class="mono-grid__row">Grid content</div></div>';
          break;
        case 2:
          panel.innerHTML = '<form><input type="text"><button type="submit">Submit</button></form>';
          break;
        case 3:
          panel.innerHTML = '<pre><code>Code block content</code></pre>';
          break;
      }

      container.appendChild(panel);
      return panel;
    });

    document.body.appendChild(container);
    container.dispatchEvent = jest.fn();
  });

  afterEach(() => {
    if (component) {
      component.destroy();
    }
    document.body.removeChild(container);
    localStorage.clear();
  });

  describe('Keyboard Navigation', () => {
    beforeEach(() => {
      component = new MonoTabsComponent({ container }).mount();
    });

    test('should handle arrow key navigation', () => {
      const events = [
        { key: 'ArrowRight', expectedIndex: 1 },
        { key: 'ArrowRight', expectedIndex: 2 },
        { key: 'ArrowLeft', expectedIndex: 1 },
        { key: 'ArrowDown', expectedIndex: 2 },
        { key: 'ArrowUp', expectedIndex: 1 }
      ];

      events.forEach(({ key, expectedIndex }) => {
        const event = new KeyboardEvent('keydown', { key });
        tabs[component.getActiveTabIndex()].dispatchEvent(event);
        expect(tabs[expectedIndex].click).toHaveBeenCalled();
        expect(tabs[expectedIndex].focus).toHaveBeenCalled();
      });
    });

    test('should wrap around when navigating past edges', () => {
      // Navigate past end
      const rightEvent = new KeyboardEvent('keydown', { key: 'ArrowRight' });
      for (let i = 0; i < tabs.length + 1; i++) {
        tabs[component.getActiveTabIndex()].dispatchEvent(rightEvent);
      }
      expect(component.getActiveTabIndex()).toBe(0);

      // Navigate past start
      const leftEvent = new KeyboardEvent('keydown', { key: 'ArrowLeft' });
      tabs[0].dispatchEvent(leftEvent);
      expect(component.getActiveTabIndex()).toBe(tabs.length - 1);
    });

    test('should handle Home and End keys', () => {
      // Press End key
      const endEvent = new KeyboardEvent('keydown', { key: 'End' });
      tabs[0].dispatchEvent(endEvent);
      expect(tabs[tabs.length - 1].click).toHaveBeenCalled();
      expect(tabs[tabs.length - 1].focus).toHaveBeenCalled();

      // Press Home key
      const homeEvent = new KeyboardEvent('keydown', { key: 'Home' });
      tabs[tabs.length - 1].dispatchEvent(homeEvent);
      expect(tabs[0].click).toHaveBeenCalled();
      expect(tabs[0].focus).toHaveBeenCalled();
    });
  });

  describe('State Persistence', () => {
    test('should persist tab state to localStorage', () => {
      component = new MonoTabsComponent({
        container,
        enablePersistence: true
      }).mount();

      // Click second tab
      tabs[1].click();
      expect(localStorage.setItem).toHaveBeenCalledWith('tab-state-test-tabs', '1');

      // Click fourth tab
      tabs[3].click();
      expect(localStorage.setItem).toHaveBeenCalledWith('tab-state-test-tabs', '3');
    });

    test('should restore persisted tab state on mount', () => {
      // Set persisted state
      localStorage.setItem('tab-state-test-tabs', '2');

      component = new MonoTabsComponent({
        container,
        enablePersistence: true
      }).mount();

      expect(tabs[2].click).toHaveBeenCalled();
    });

    test('should handle invalid persisted state', () => {
      // Set invalid state
      localStorage.setItem('tab-state-test-tabs', '999');

      component = new MonoTabsComponent({
        container,
        enablePersistence: true
      }).mount();

      // Should default to first tab
      expect(component.getActiveTabIndex()).toBe(0);
    });
  });

  describe('Accessibility', () => {
    beforeEach(() => {
      component = new MonoTabsComponent({ container }).mount();
    });

    test('should maintain proper ARIA attributes', () => {
      // Check initial state
      tabs.forEach((tab, i) => {
        expect(tab.getAttribute('role')).toBe('tab');
        expect(tab.getAttribute('aria-selected')).toBe(i === 0 ? 'true' : 'false');
        expect(panels[i].getAttribute('role')).toBe('tabpanel');
        expect(panels[i].getAttribute('aria-labelledby')).toBe(tab.id);
      });

      // Change active tab
      tabs[2].click();

      // Check updated state
      tabs.forEach((tab, i) => {
        expect(tab.getAttribute('aria-selected')).toBe(i === 2 ? 'true' : 'false');
        expect(panels[i].hasAttribute('hidden')).toBe(i !== 2);
      });
    });

    test('should dispatch custom events for screen readers', () => {
      const event = new KeyboardEvent('keydown', { key: 'ArrowRight' });
      tabs[0].dispatchEvent(event);

      expect(container.dispatchEvent).toHaveBeenCalledWith(
        expect.objectContaining({
          type: 'monoTabsNavigation',
          detail: expect.objectContaining({
            fromIndex: 0,
            toIndex: 1
          })
        })
      );
    });
  });

  describe('Edge Cases', () => {
    test('should handle rapid tab switching', () => {
      component = new MonoTabsComponent({ container }).mount();

      // Rapidly switch between tabs
      tabs[1].click();
      tabs[2].click();
      tabs[3].click();
      tabs[0].click();

      expect(component.getActiveTabIndex()).toBe(0);
      expect(panels[0].classList.contains('mono-tabs__panel--active')).toBe(true);
    });

    test('should handle disabled tabs', () => {
      // Disable a tab
      tabs[2].setAttribute('disabled', '');
      component = new MonoTabsComponent({ container }).mount();

      const event = new KeyboardEvent('keydown', { key: 'ArrowRight' });
      tabs[1].dispatchEvent(event);

      // Should skip disabled tab
      expect(tabs[3].click).toHaveBeenCalled();
    });

    test('should handle empty tab panels', () => {
      // Create empty panel
      const emptyPanel = document.createElement('div');
      emptyPanel.className = 'mono-tabs__panel';
      container.appendChild(emptyPanel);

      component = new MonoTabsComponent({ container }).mount();
      expect(() => component.update()).not.toThrow();
    });

    test('should handle dynamic tab updates', () => {
      component = new MonoTabsComponent({ container }).mount();

      // Add new tab dynamically
      const newTab = document.createElement('button');
      newTab.className = 'mono-tabs__tab';
      newTab.textContent = 'New Tab';
      container.appendChild(newTab);

      const newPanel = document.createElement('div');
      newPanel.className = 'mono-tabs__panel';
      container.appendChild(newPanel);

      // Update component
      component.update();
      expect(component.elements.tabs.length).toBe(5);
      expect(component.elements.panels.length).toBe(5);
    });
  });

  describe('Debug Mode', () => {
    test('should log debug information when enabled', () => {
      const consoleSpy = jest.spyOn(console, 'log').mockImplementation();

      component = new MonoTabsComponent({
        container,
        debug: true
      }).mount();

      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('[MonoTabs:'),
        'Component mounted',
        expect.any(Object)
      );

      consoleSpy.mockRestore();
    });
  });
}); 