/**
 * Advanced Navigation Menu Component Tests
 * -------------------------------------
 * Tests for complex functionality, edge cases, and advanced features
 * of the NavigationMenu component.
 */

import { NavigationMenuComponent } from '../components/navigation_menu';
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
    cleanup: jest.fn()
  })
}));

describe('NavigationMenuComponent - Advanced Features', () => {
  let component;
  let container;
  let menu;
  let toggle;
  let mockLiveViewHook;

  // Helper to create test container with required elements
  const createTestContainer = () => {
    container = document.createElement('div');
    container.className = 'site-navigation';
    container.dataset.currentPath = '/';

    // Create mobile toggle button
    toggle = document.createElement('button');
    toggle.className = 'mobile-nav-toggle';
    toggle.setAttribute('aria-label', 'Toggle menu');
    toggle.setAttribute('aria-expanded', 'false');
    container.appendChild(toggle);

    // Create navigation menu
    menu = document.createElement('nav');
    menu.className = 'site-nav';
    menu.setAttribute('aria-label', 'Main navigation');

    // Create menu items
    const menuItems = [
      { href: '/', text: 'Home' },
      { href: '/docs', text: 'Documentation' },
      { href: '/api', text: 'API' },
      { href: '/about', text: 'About' }
    ];

    const list = document.createElement('ul');
    list.className = 'nav-list';

    menuItems.forEach(item => {
      const li = document.createElement('li');
      li.className = 'nav-item';

      const a = document.createElement('a');
      a.href = item.href;
      a.className = 'nav-link';
      a.textContent = item.text;
      if (item.href === '/') {
        a.classList.add('active');
        a.setAttribute('aria-current', 'page');
      }

      li.appendChild(a);
      list.appendChild(li);
    });

    menu.appendChild(list);
    container.appendChild(menu);

    // Create mobile navigation
    const mobileNav = document.createElement('div');
    mobileNav.className = 'mobile-nav-menu';
    mobileNav.innerHTML = list.outerHTML;
    container.appendChild(mobileNav);

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
      pushEvent: jest.fn()
    };

    // Create component instance
    component = new NavigationMenuComponent({
      container,
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
    menu = null;
    toggle = null;
    component = null;
  });

  describe('Responsive Behavior', () => {
    beforeEach(() => {
      component.mount();
    });

    test('should handle mobile breakpoint changes', () => {
      // Mock matchMedia
      const mockMatchMedia = jest.fn();
      window.matchMedia = mockMatchMedia;

      // Simulate mobile breakpoint
      mockMatchMedia.mockReturnValue({
        matches: true,
        addListener: jest.fn(),
        removeListener: jest.fn()
      });

      // Trigger breakpoint change
      const event = new Event('resize');
      window.dispatchEvent(event);

      expect(component._state.isMobileView).toBe(true);
      expect(container.classList.contains('mobile-view')).toBe(true);
    });

    test('should collapse menu when switching to desktop', () => {
      // Set initial mobile expanded state
      component._setState({ isMobileView: true, isExpanded: true });
      component._updateUI();

      // Simulate switch to desktop
      component._handleBreakpointChange({ matches: false });

      expect(component._state.isExpanded).toBe(false);
      expect(menu.classList.contains('expanded')).toBe(false);
    });

    test('should maintain state during rapid viewport changes', () => {
      const events = [
        { matches: true }, // mobile
        { matches: false }, // desktop
        { matches: true }, // mobile
        { matches: false } // desktop
      ];

      events.forEach(event => {
        component._handleBreakpointChange(event);
      });

      expect(component._state.isMobileView).toBe(false);
      expect(component._state.isExpanded).toBe(false);
    });
  });

  describe('Keyboard Navigation', () => {
    beforeEach(() => {
      component.mount();
    });

    test('should handle arrow key navigation', () => {
      const menuItems = component.elements.menuItems;
      menuItems[0].focus();

      // Test arrow key navigation
      const events = [
        { key: 'ArrowRight', expectedIndex: 1 },
        { key: 'ArrowDown', expectedIndex: 2 },
        { key: 'ArrowLeft', expectedIndex: 1 },
        { key: 'ArrowUp', expectedIndex: 0 }
      ];

      events.forEach(({ key, expectedIndex }) => {
        const event = new KeyboardEvent('keydown', { key });
        menuItems[component._state.activeIndex].dispatchEvent(event);
        expect(component._state.activeIndex).toBe(expectedIndex);
        expect(document.activeElement).toBe(menuItems[expectedIndex]);
      });
    });

    test('should wrap around navigation boundaries', () => {
      const menuItems = component.elements.menuItems;
      const lastIndex = menuItems.length - 1;

      // Navigate past end
      menuItems[lastIndex].focus();
      menuItems[lastIndex].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowRight' })
      );
      expect(component._state.activeIndex).toBe(0);

      // Navigate past start
      menuItems[0].focus();
      menuItems[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowLeft' })
      );
      expect(component._state.activeIndex).toBe(lastIndex);
    });

    test('should handle Home and End keys', () => {
      const menuItems = component.elements.menuItems;
      menuItems[1].focus(); // Start from middle

      // Test End key
      menuItems[1].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'End' })
      );
      expect(component._state.activeIndex).toBe(menuItems.length - 1);

      // Test Home key
      menuItems[menuItems.length - 1].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'Home' })
      );
      expect(component._state.activeIndex).toBe(0);
    });

    test('should handle Escape key in mobile view', () => {
      component._setState({ isMobileView: true, isExpanded: true });
      component._updateUI();

      const event = new KeyboardEvent('keydown', { key: 'Escape' });
      menu.dispatchEvent(event);

      expect(component._state.isExpanded).toBe(false);
      expect(document.activeElement).toBe(toggle);
    });
  });

  describe('State Management', () => {
    test('should sync active item between mobile and desktop navigation', () => {
      component.mount();

      // Click mobile menu item
      const mobileLinks = container.querySelectorAll('.mobile-nav-menu a');
      const targetHref = '/docs';
      mobileLinks[1].click(); // Documentation link

      // Check desktop menu is synced
      const desktopLinks = menu.querySelectorAll('a');
      expect(desktopLinks[1].classList.contains('active')).toBe(true);
      expect(desktopLinks[1].getAttribute('aria-current')).toBe('page');
      expect(component._state.currentPath).toBe(targetHref);
    });

    test('should handle external path updates', () => {
      component.mount();

      // Simulate LiveView path update
      container.dataset.currentPath = '/api';
      mockLiveViewHook.handleEvent('update', { currentPath: '/api' });

      expect(component._state.currentPath).toBe('/api');
      expect(component.elements.menuItems[2].classList.contains('active')).toBe(true);
    });

    test('should maintain state during component updates', () => {
      component.mount();

      // Set initial state
      component._setState({
        activeIndex: 2,
        currentPath: '/api',
        isKeyboardNavigation: true
      });

      // Update component
      component._updateUI();

      // Verify state is maintained
      expect(component._state.activeIndex).toBe(2);
      expect(component._state.currentPath).toBe('/api');
      expect(component._state.isKeyboardNavigation).toBe(true);
    });
  });

  describe('Edge Cases', () => {
    test('should handle missing menu elements gracefully', () => {
      // Remove menu elements
      menu.remove();
      toggle.remove();

      component.mount();

      // Should not throw errors
      expect(() => component._updateUI()).not.toThrow();
      expect(() => component._handleToggleClick({ preventDefault: jest.fn() })).not.toThrow();
    });

    test('should handle rapid toggle clicks', () => {
      component.mount();

      // Rapidly toggle menu multiple times
      for (let i = 0; i < 10; i++) {
        toggle.click();
      }

      // Should end in a consistent state
      const finalState = component._state.isExpanded;
      expect(toggle.getAttribute('aria-expanded')).toBe(finalState.toString());
      expect(menu.classList.contains('expanded')).toBe(finalState);
    });

    test('should handle invalid current path', () => {
      // Set invalid path
      container.dataset.currentPath = '/nonexistent';
      component.mount();

      // Should not throw errors and maintain valid state
      expect(component._state.activeIndex).toBe(-1);
      expect(component.elements.menuItems.some(item => 
        item.classList.contains('active')
      )).toBe(false);
    });

    test('should handle disabled menu items', () => {
      component.mount();

      // Disable a menu item
      const menuItems = component.elements.menuItems;
      menuItems[1].setAttribute('disabled', '');
      menuItems[1].setAttribute('aria-disabled', 'true');

      // Try to navigate to disabled item
      menuItems[0].focus();
      menuItems[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowRight' })
      );

      // Should skip disabled item
      expect(component._state.activeIndex).toBe(2);
    });
  });

  describe('Accessibility', () => {
    beforeEach(() => {
      component.mount();
    });

    test('should maintain proper ARIA attributes', () => {
      // Check toggle button
      expect(toggle.getAttribute('aria-label')).toBe('Toggle menu');
      expect(toggle.getAttribute('aria-expanded')).toBe('false');

      // Check menu
      expect(menu.getAttribute('aria-label')).toBe('Main navigation');

      // Check menu items
      component.elements.menuItems.forEach((item, i) => {
        expect(item.getAttribute('aria-current')).toBe(i === 0 ? 'page' : 'false');
      });
    });

    test('should update ARIA attributes on state changes', () => {
      // Toggle menu
      toggle.click();
      expect(toggle.getAttribute('aria-expanded')).toBe('true');
      expect(toggle.getAttribute('aria-label')).toBe('Close menu');

      // Change active item
      component._setState({ currentPath: '/docs' });
      component._updateUI();

      component.elements.menuItems.forEach((item, i) => {
        expect(item.getAttribute('aria-current')).toBe(i === 1 ? 'page' : 'false');
      });
    });

    test('should handle focus management during keyboard navigation', () => {
      const menuItems = component.elements.menuItems;

      // Start keyboard navigation
      menuItems[0].focus();
      expect(document.activeElement).toBe(menuItems[0]);

      // Navigate with keyboard
      menuItems[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowRight' })
      );
      expect(document.activeElement).toBe(menuItems[1]);
      expect(component._state.isKeyboardNavigation).toBe(true);

      // Mouse interaction should reset keyboard navigation state
      menuItems[1].dispatchEvent(new MouseEvent('mouseenter'));
      expect(component._state.isKeyboardNavigation).toBe(false);
    });
  });

  describe('Debug Mode', () => {
    test('should log debug information when enabled', () => {
      const consoleSpy = jest.spyOn(console, 'log').mockImplementation();

      component = new NavigationMenuComponent({
        container,
        debug: true
      }).mount();

      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('[NavigationMenu:'),
        'Component mounted'
      );

      // Test state changes
      toggle.click();
      expect(consoleSpy).toHaveBeenCalledWith(
        expect.stringContaining('[NavigationMenu:'),
        'Menu expanded'
      );

      consoleSpy.mockRestore();
    });
  });
}); 