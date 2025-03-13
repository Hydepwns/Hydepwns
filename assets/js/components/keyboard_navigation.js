/**
 * Keyboard Navigation Component
 * -----------------------
 * Provides global keyboard shortcuts for navigating the site.
 * Implements skip links, focus trapping, and enhanced navigation for keyboard users.
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class KeyboardNavigationComponent {
  /**
   * Create a new KeyboardNavigation component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `keyboard-navigation-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: document.body,
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      tabPressed: false
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      skipLink: null
    };
    
    // Store selector for focusable elements
    this.focusableElements = [
      'a[href]',
      'button:not([disabled])',
      'input:not([disabled])',
      'select:not([disabled])',
      'textarea:not([disabled])',
      '[tabindex="0"]'
    ].join(',');
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[KeyboardNavigation:${this.componentId}]`, ...args);
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
    
    // Find the skip link
    this.elements.skipLink = document.querySelector('.skip-to-content');
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Set up focus traps
    this._setupFocusTraps();
    
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
    
    // Remove keyboard navigation class
    document.body.classList.remove('keyboard-navigation');
    
    // Hide skip link
    if (this.elements.skipLink) {
      this.elements.skipLink.classList.remove('visible');
    }
    
    // Clear references
    this.elements = {};
    this._state = {};
  }
  
  /**
   * Set up event listeners for keyboard navigation
   * @private
   */
  _setupEventListeners() {
    // Set up the global keydown handler
    this.events.addEventListener(document, 'keydown', this._handleKeydown.bind(this));
    
    // Add mouse movement handler to detect if user is using mouse
    this.events.addEventListener(document, 'mousemove', this._handleMouseMove.bind(this));
  }
  
  /**
   * Set up focus trapping for modals and dialogs
   * @private
   */
  _setupFocusTraps() {
    const focusTraps = document.querySelectorAll('[data-focus-trap]');
    focusTraps.forEach(trap => {
      this.events.addEventListener(trap, 'keydown', this._trapFocus.bind(this));
    });
  }
  
  /**
   * Handle keydown events for keyboard navigation
   * @param {KeyboardEvent} event - The keydown event
   * @private
   */
  _handleKeydown(event) {
    // Skip if user is typing in an input field
    if (['INPUT', 'TEXTAREA', 'SELECT'].includes(event.target.tagName)) {
      return;
    }
    
    // Handle keyboard shortcuts
    switch (event.key) {
      // Navigation shortcuts
      case '/':
        // Focus on search (if it exists)
        if (event.ctrlKey || event.metaKey) {
          event.preventDefault();
          const searchInput = document.querySelector('#search-input');
          if (searchInput) {
            searchInput.focus();
          }
        }
        break;
        
      case 'h':
        // Home page
        if (event.altKey) {
          event.preventDefault();
          window.location.href = '/';
        }
        break;
        
      case '`':
        // Toggle terminal
        if (!event.ctrlKey && !event.altKey && !event.shiftKey) {
          event.preventDefault();
          if (this.options.liveViewHook) {
            this.options.liveViewHook.pushEvent('toggle-terminal');
          }
        }
        break;
        
      case 't':
        // Toggle table of contents
        if (event.altKey) {
          event.preventDefault();
          if (this.options.liveViewHook) {
            this.options.liveViewHook.pushEvent('toggle-toc');
          }
        }
        break;
        
      case 'a':
        // Open accessibility menu
        if (event.altKey) {
          event.preventDefault();
          const a11yMenuButton = document.querySelector('#a11y-menu-toggle');
          if (a11yMenuButton) {
            a11yMenuButton.click();
          }
        }
        break;
        
      // Skip links
      case 'Tab':
        // Show skip links when Tab is first pressed
        if (!this._state.tabPressed) {
          this._setState({ tabPressed: true });
          document.body.classList.add('keyboard-navigation');
          
          // Show skip link
          if (this.elements.skipLink) {
            this.elements.skipLink.classList.add('visible');
          }
        }
        break;
        
      // Escape key handling
      case 'Escape':
        // Close any open menus/modals
        this._handleEscapeKey();
        break;
        
      // Focus navigation
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        // Alt+number to focus on main sections
        if (event.altKey) {
          event.preventDefault();
          this._focusOnSection(parseInt(event.key));
        }
        break;
    }
  }
  
  /**
   * Handle mouse movement to detect if user switches to mouse
   * @param {MouseEvent} event - The mouse event
   * @private
   */
  _handleMouseMove(event) {
    // If we detect significant mouse movement, hide keyboard navigation indicators
    if (this._state.tabPressed) {
      this._setState({ tabPressed: false });
      document.body.classList.remove('keyboard-navigation');
      
      // Hide skip link
      if (this.elements.skipLink) {
        this.elements.skipLink.classList.remove('visible');
      }
    }
  }
  
  /**
   * Trap focus within modal dialogs
   * @param {KeyboardEvent} event - The keydown event
   * @private
   */
  _trapFocus(event) {
    // Skip if not tab key
    if (event.key !== 'Tab') return;
    
    // Get all focusable elements in the trap
    const focusableElements = Array.from(
      event.currentTarget.querySelectorAll(this.focusableElements)
    ).filter(el => el.offsetParent !== null); // Filter out hidden elements
    
    if (focusableElements.length === 0) return;
    
    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];
    
    // Handle tabbing forward and backward
    if (event.shiftKey && document.activeElement === firstElement) {
      event.preventDefault();
      lastElement.focus();
    } else if (!event.shiftKey && document.activeElement === lastElement) {
      event.preventDefault();
      firstElement.focus();
    }
  }
  
  /**
   * Handle the escape key to close modals and menus
   * @private
   */
  _handleEscapeKey() {
    // Close modals and dialogs
    const openModals = document.querySelectorAll('[role="dialog"][aria-modal="true"]');
    if (openModals.length > 0) {
      // Find the top-most modal and close it
      const topModal = Array.from(openModals).pop();
      const closeButton = topModal.querySelector('[data-close]');
      if (closeButton) {
        closeButton.click();
      }
      return;
    }
    
    // Close menus
    const openMenus = document.querySelectorAll('[aria-expanded="true"]');
    if (openMenus.length > 0) {
      openMenus.forEach(menu => {
        // Trigger the click event on the menu button
        menu.click();
      });
      return;
    }
    
    // Handle terminal visibility
    if (this.options.liveViewHook) {
      this.options.liveViewHook.pushEvent('close-terminal');
    }
  }
  
  /**
   * Focus on a specific section of the page
   * @param {number} sectionNumber - The section number (1-9)
   * @private
   */
  _focusOnSection(sectionNumber) {
    // Map section numbers to selectors
    const sectionMap = {
      1: '#main-content',
      2: '#terminal-container',
      3: '#table-of-contents',
      4: '#site-header',
      5: '#site-footer',
      6: '#projects-section',
      7: '#about-section',
      8: '#contact-section',
      9: '#a11y-menu-toggle'
    };
    
    const selector = sectionMap[sectionNumber];
    if (selector) {
      const element = document.querySelector(selector);
      if (element) {
        element.focus();
        // Scroll into view if not visible
        element.scrollIntoView({ behavior: 'smooth', block: 'start' });
        this._announceToScreenReader(`Navigated to ${element.getAttribute('aria-label') || element.textContent.trim() || 'section ' + sectionNumber}`);
      }
    }
  }
  
  /**
   * Make an announcement to screen readers
   * @param {string} message - The message to announce
   * @private
   */
  _announceToScreenReader(message) {
    // Find the announcer element
    const announcer = document.getElementById('accessibility-announcer');
    if (announcer) {
      // Update the content to trigger screen reader announcement
      announcer.textContent = message;
    }
  }
  
  /**
   * Update component state and trigger re-render if needed
   * @param {Object} newState - State changes to apply
   * @private
   */
  _setState(newState) {
    const prevState = { ...this._state };
    this._state = { ...this._state, ...newState };
    
    // Only re-render if something changed
    if (JSON.stringify(prevState) !== JSON.stringify(this._state)) {
      this.debug.log('State updated:', this._state);
    }
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const KeyboardNavigation = {
  mounted() {
    this.component = new KeyboardNavigationComponent({
      container: document.body,
      liveViewHook: this,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
    
    if (window.DEBUG) {
      window.DEBUG.log('KeyboardNavigation hook mounted');
    }
  },
  
  disconnected() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default KeyboardNavigation;
export { KeyboardNavigationComponent }; 