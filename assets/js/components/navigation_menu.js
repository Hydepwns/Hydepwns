/**
 * Navigation Menu Component
 * ----------------------
 * Provides enhanced functionality for the site navigation menu, including
 * mobile responsiveness, keyboard navigation, and animation effects.
 * 
 * Built using the robust component system.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class NavigationMenuComponent {
  /**
   * Create a new NavigationMenu component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `navigation-menu-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (required)
      menuSelector: '.site-nav', // Selector for navigation menu container
      toggleSelector: '.mobile-nav-toggle', // Selector for mobile menu toggle button
      activeClass: 'active', // Class to apply to active navigation item
      expandedClass: 'expanded', // Class to apply when menu is expanded
      collapseBreakpoint: 768, // Viewport width at which menu collapses to mobile view
      animationDuration: 300, // Duration of animations in milliseconds
      currentPath: null, // Current path to highlight the active item
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      isExpanded: false, // Whether the mobile menu is expanded
      isMobileView: false, // Whether we're in mobile view
      currentPath: this.options.currentPath, // Current active path
      activeIndex: -1, // Index of active menu item for keyboard navigation
      isKeyboardNavigation: false // Whether user is navigating with keyboard
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      menu: null,
      toggle: null,
      menuItems: [],
      mobileNav: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[NavigationMenu:${this.componentId}]`, ...args);
        }
      }
    };
  }
  
  /**
   * Initialize the component and mount it to the DOM
   * @returns {this} - For method chaining
   */
  mount() {
    // Get event manager for this component
    this.events = EventManager.registerComponent(this.componentId);
    
    // Get cleanup registry for this component
    this.cleanup = DOMCleanup.register(this.componentId);
    
    // Store reference to container
    this.elements.container = this.options.container;
    
    // Find navigation elements
    this._findElements();
    
    // Set up responsive behavior
    this._setupResponsiveBehavior();
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Initial UI update
    this._updateUI();
    
    this.debug.log('Component mounted');
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
    // Clean up DOM elements and event listeners
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    // Unregister from event manager
    if (this.events) {
      EventManager.unregisterComponent(this.componentId);
    }
    
    // Clear references
    this.elements = {
      container: null,
      menu: null,
      toggle: null,
      menuItems: [],
      mobileNav: null
    };
    
    this._state = {
      isExpanded: false,
      isMobileView: false,
      currentPath: null,
      activeIndex: -1,
      isKeyboardNavigation: false
    };
  }
  
  /**
   * Find navigation elements in the DOM
   * @private
   */
  _findElements() {
    // Find main menu
    this.elements.menu = this.elements.container.querySelector(this.options.menuSelector);
    
    // Find mobile toggle
    this.elements.toggle = this.elements.container.querySelector(this.options.toggleSelector);
    
    // Find menu items
    if (this.elements.menu) {
      this.elements.menuItems = Array.from(this.elements.menu.querySelectorAll('a'));
    }
    
    // Find mobile nav if it exists
    this.elements.mobileNav = document.querySelector('.mobile-nav-menu');
    
    this.debug.log('Elements found:', {
      menu: !!this.elements.menu,
      toggle: !!this.elements.toggle,
      menuItems: this.elements.menuItems.length,
      mobileNav: !!this.elements.mobileNav
    });
  }
  
  /**
   * Set up event listeners
   * @private
   */
  _setupEventListeners() {
    // Toggle button click
    if (this.elements.toggle) {
      this.events.addEventListener(
        this.elements.toggle,
        'click',
        this._handleToggleClick.bind(this)
      );
    }
    
    // Keyboard navigation in menu
    if (this.elements.menu) {
      this.events.addEventListener(
        this.elements.menu,
        'keydown',
        this._handleMenuKeydown.bind(this)
      );
    }
    
    // Navigation item clicks
    this.elements.menuItems.forEach((item, index) => {
      this.events.addEventListener(
        item,
        'click',
        (e) => this._handleMenuItemClick(e, index)
      );
      
      // Mouse interactions
      this.events.addEventListener(
        item,
        'mouseenter',
        () => this._setState({ isKeyboardNavigation: false })
      );
    });
    
    // Handle clicks outside to close mobile menu
    this.events.addEventListener(
      document,
      'click',
      this._handleDocumentClick.bind(this)
    );
    
    // Synchronize mobile and desktop navigation active items
    if (this.elements.mobileNav) {
      const mobileLinks = Array.from(this.elements.mobileNav.querySelectorAll('a'));
      mobileLinks.forEach((link, index) => {
        this.events.addEventListener(
          link,
          'click',
          () => this._syncActiveItem(link.getAttribute('href'))
        );
      });
    }
  }
  
  /**
   * Set up responsive behavior
   * @private
   */
  _setupResponsiveBehavior() {
    // Create media query for mobile breakpoint
    const mediaQuery = window.matchMedia(`(max-width: ${this.options.collapseBreakpoint}px)`);
    
    // Initial check
    this._handleBreakpointChange(mediaQuery);
    
    // Add listener for changes
    const mediaQueryListener = this._handleBreakpointChange.bind(this);
    mediaQuery.addEventListener('change', mediaQueryListener);
    
    // Register cleanup for media query listener
    this.cleanup.registerCleanupFunction(() => {
      mediaQuery.removeEventListener('change', mediaQueryListener);
    });
  }
  
  /**
   * Handle breakpoint changes
   * @param {MediaQueryListEvent} event - Media query change event
   * @private
   */
  _handleBreakpointChange(event) {
    const isMobileView = event.matches;
    
    if (isMobileView !== this._state.isMobileView) {
      this._setState({ isMobileView });
      
      // Reset expanded state when switching to desktop
      if (!isMobileView && this._state.isExpanded) {
        this._setState({ isExpanded: false });
      }
      
      this._updateUI();
      this.debug.log(`Switched to ${isMobileView ? 'mobile' : 'desktop'} view`);
    }
  }
  
  /**
   * Handle toggle button click
   * @param {Event} event - Click event
   * @private
   */
  _handleToggleClick(event) {
    event.preventDefault();
    event.stopPropagation();
    
    this._setState({ isExpanded: !this._state.isExpanded });
    this._updateUI();
    
    this.debug.log(`Menu ${this._state.isExpanded ? 'expanded' : 'collapsed'}`);
  }
  
  /**
   * Handle menu item click
   * @param {Event} event - Click event
   * @param {number} index - Index of clicked item
   * @private
   */
  _handleMenuItemClick(event, index) {
    const href = this.elements.menuItems[index].getAttribute('href');
    
    // Update active state
    this._setState({ 
      activeIndex: index,
      currentPath: href
    });
    
    // Close mobile menu after navigation
    if (this._state.isMobileView && this._state.isExpanded) {
      // Delay closing to allow for navigation
      setTimeout(() => {
        this._setState({ isExpanded: false });
        this._updateUI();
      }, 150);
    }
    
    this._syncActiveItem(href);
    this.debug.log(`Menu item clicked: ${index}, href: ${href}`);
  }
  
  /**
   * Handle document clicks (for closing mobile menu)
   * @param {Event} event - Click event
   * @private
   */
  _handleDocumentClick(event) {
    // Only applicable in mobile view when menu is expanded
    if (!this._state.isMobileView || !this._state.isExpanded) {
      return;
    }
    
    // Check if click is outside the menu and toggle
    const isClickInside = 
      this.elements.menu?.contains(event.target) || 
      this.elements.toggle?.contains(event.target);
    
    if (!isClickInside) {
      this._setState({ isExpanded: false });
      this._updateUI();
      this.debug.log('Menu closed by outside click');
    }
  }
  
  /**
   * Handle keyboard navigation in menu
   * @param {KeyboardEvent} event - Keydown event
   * @private
   */
  _handleMenuKeydown(event) {
    // Only handle if we have menu items
    if (!this.elements.menuItems.length) return;
    
    let index = this._state.activeIndex;
    const max = this.elements.menuItems.length - 1;
    
    // If no item is active, start with the first one
    if (index === -1) {
      index = 0;
    }
    
    switch (event.key) {
      case 'ArrowRight':
      case 'ArrowDown':
        event.preventDefault();
        index = index >= max ? 0 : index + 1;
        this._setState({ activeIndex: index, isKeyboardNavigation: true });
        this._focusMenuItem(index);
        break;
        
      case 'ArrowLeft':
      case 'ArrowUp':
        event.preventDefault();
        index = index <= 0 ? max : index - 1;
        this._setState({ activeIndex: index, isKeyboardNavigation: true });
        this._focusMenuItem(index);
        break;
        
      case 'Home':
        event.preventDefault();
        this._setState({ activeIndex: 0, isKeyboardNavigation: true });
        this._focusMenuItem(0);
        break;
        
      case 'End':
        event.preventDefault();
        this._setState({ activeIndex: max, isKeyboardNavigation: true });
        this._focusMenuItem(max);
        break;
        
      case 'Escape':
        // Close mobile menu on escape
        if (this._state.isMobileView && this._state.isExpanded) {
          event.preventDefault();
          this._setState({ isExpanded: false });
          this._updateUI();
          
          // Focus the toggle button
          if (this.elements.toggle) {
            this.elements.toggle.focus();
          }
        }
        break;
    }
  }
  
  /**
   * Focus a menu item by index
   * @param {number} index - Index of item to focus
   * @private
   */
  _focusMenuItem(index) {
    if (index >= 0 && index < this.elements.menuItems.length) {
      this.elements.menuItems[index].focus();
      this.debug.log(`Focused menu item: ${index}`);
    }
  }
  
  /**
   * Synchronize active item between mobile and desktop navigation
   * @param {string} href - The href to mark as active
   * @private
   */
  _syncActiveItem(href) {
    if (!href) return;
    
    // Update current path
    this._setState({ currentPath: href });
    
    // Find and update desktop menu item
    if (this.elements.menuItems.length) {
      this.elements.menuItems.forEach((item, i) => {
        const itemHref = item.getAttribute('href');
        if (itemHref === href) {
          this._setState({ activeIndex: i });
        }
      });
    }
    
    // Find and update mobile menu item if it exists
    if (this.elements.mobileNav) {
      const mobileLinks = Array.from(this.elements.mobileNav.querySelectorAll('a'));
      mobileLinks.forEach(link => {
        const linkHref = link.getAttribute('href');
        const isCurrent = linkHref === href;
        
        // Update aria-current
        link.setAttribute('aria-current', isCurrent ? 'page' : 'false');
        
        // Update active class
        if (isCurrent) {
          link.classList.add(this.options.activeClass);
        } else {
          link.classList.remove(this.options.activeClass);
        }
      });
    }
    
    this.debug.log(`Synchronized active item: ${href}`);
  }
  
  /**
   * Update the UI based on current state
   * @private
   */
  _updateUI() {
    // Update toggle button state
    if (this.elements.toggle) {
      this.elements.toggle.setAttribute('aria-expanded', this._state.isExpanded.toString());
      this.elements.toggle.setAttribute('aria-label', 
        this._state.isExpanded ? 'Close menu' : 'Open menu'
      );
    }
    
    // Update menu expanded state
    if (this.elements.menu) {
      if (this._state.isExpanded) {
        this.elements.menu.classList.add(this.options.expandedClass);
      } else {
        this.elements.menu.classList.remove(this.options.expandedClass);
      }
    }
    
    // Update active menu item
    this.elements.menuItems.forEach((item, index) => {
      const itemHref = item.getAttribute('href');
      const isCurrent = itemHref === this._state.currentPath;
      
      // Update aria-current
      item.setAttribute('aria-current', isCurrent ? 'page' : 'false');
      
      // Update active class
      if (isCurrent) {
        item.classList.add(this.options.activeClass);
      } else {
        item.classList.remove(this.options.activeClass);
      }
    });
  }
  
  /**
   * Set component state
   * @param {Object} newState - New state to merge with existing state
   * @private
   */
  _setState(newState) {
    this._state = { ...this._state, ...newState };
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const NavigationMenu = {
  mounted() {
    // Get current path from data-attributes or location
    const currentPath = this.el.dataset.currentPath || window.location.pathname;
    
    this.component = new NavigationMenuComponent({
      liveViewHook: this,
      container: this.el,
      currentPath: currentPath,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  updated() {
    // Update current path if it changed
    if (this.el.dataset.currentPath) {
      this.component._syncActiveItem(this.el.dataset.currentPath);
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default NavigationMenu;
export { NavigationMenuComponent }; 