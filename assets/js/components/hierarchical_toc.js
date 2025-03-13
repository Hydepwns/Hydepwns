/**
 * Hierarchical TOC Component
 * -----------------------
 * Provides functionality for the hierarchical table of contents:
 * - Collapsing/expanding nested sections with toggles
 * - Section tracking as user scrolls the page (scroll spy)
 * - Keyboard navigation for accessibility
 * - Mobile-friendly interactions
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class HierarchicalTOCComponent {
  /**
   * Create a new HierarchicalTOC component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `hierarchical-toc-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // The TOC container element
      scrollSpyRootMargin: '-100px 0px -80% 0px', // Margin for intersection observer
      scrollSpyThreshold: 0, // Threshold for intersection observer
      initialHashDelay: 500, // Delay for handling initial hash in ms
      expandedToggleSymbol: '▼', // Symbol for expanded state
      collapsedToggleSymbol: '▶', // Symbol for collapsed state
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      activeSection: null,
      headingElements: []
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      tocItems: [],
      toggleIndicators: [],
      tocLinks: []
    };
    
    // IntersectionObserver for scroll spy
    this.intersectionObserver = null;
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.hydepwnsDebug)) {
          console.log(`[HierarchicalTOC:${this.componentId}]`, ...args);
        }
      },
      error: (...args) => {
        if (this.options.debug || (window.hydepwnsDebug)) {
          console.error(`[HierarchicalTOC:${this.componentId}]`, ...args);
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
    
    // Set container reference
    this.elements.container = this.options.container;
    
    if (!this.elements.container) {
      console.error('HierarchicalTOC: No container element provided');
      return this;
    }
    
    // Store DOM elements
    this._cacheElements();
    
    // Initialize TOC functionality
    this._initToggleHandlers();
    this._initKeyboardNavigation();
    this._setupScrollSpy();
    
    // Set up hash change handling
    this._setupHashChangeHandling();
    
    // Initial check for hash in URL
    this._handleInitialHash();
    
    this.debug.log('Component mounted');
    
    return this;
  }
  
  /**
   * Update the component when content changes
   * @returns {this} - For method chaining
   */
  update() {
    this.debug.log('Updating component');
    
    // Re-cache elements
    this._cacheElements();
    
    // Disconnect previous observer if exists
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect();
    }
    
    // Reinitialize functionality
    this._initToggleHandlers();
    this._initKeyboardNavigation();
    this._setupScrollSpy();
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
    // Disconnect intersection observer
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect();
      this.intersectionObserver = null;
    }
    
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
      tocItems: [],
      toggleIndicators: [],
      tocLinks: []
    };
    this._state = {
      activeSection: null,
      headingElements: []
    };
  }
  
  /**
   * Cache DOM elements for better performance
   * @private
   */
  _cacheElements() {
    this.elements.tocItems = Array.from(this.elements.container.querySelectorAll('.toc-item'));
    this.elements.toggleIndicators = Array.from(this.elements.container.querySelectorAll('.toggle-indicator'));
    this.elements.tocLinks = Array.from(this.elements.container.querySelectorAll('.toc-link'));
  }
  
  /**
   * Initialize toggle functionality for collapsible sections
   * @private
   */
  _initToggleHandlers() {
    this.debug.log('Initializing toggle handlers');
    
    this.elements.tocItems.forEach(item => {
      const toggle = item.querySelector('.toggle-indicator');
      const link = item.querySelector('.toc-link');
      const sublist = item.querySelector('.toc-sublist');
      
      if (toggle && sublist) {
        // Click on toggle indicators
        this.events.addEventListener(
          toggle,
          'click',
          (e) => {
            e.preventDefault();
            e.stopPropagation();
            this._toggleSection(item, toggle, sublist);
          }
        );
        
        // Special handling for links with children
        if (link) {
          this.events.addEventListener(
            link,
            'click',
            (e) => {
              // If this is a parent item, toggle it on click (after navigation)
              if (e.target === toggle) {
                e.preventDefault();
                e.stopPropagation();
                this._toggleSection(item, toggle, sublist);
              }
            }
          );
        }
      }
    });
  }
  
  /**
   * Toggle section visibility
   * @param {HTMLElement} item - The TOC item element
   * @param {HTMLElement} toggle - The toggle indicator element
   * @param {HTMLElement} sublist - The sublist element to toggle
   * @private
   */
  _toggleSection(item, toggle, sublist) {
    const isCollapsed = sublist.classList.contains('collapsed');
    
    if (isCollapsed) {
      // Expand section
      sublist.classList.remove('collapsed');
      toggle.innerHTML = this.options.expandedToggleSymbol;
      this.debug.log('Expanded section', item);
    } else {
      // Collapse section
      sublist.classList.add('collapsed');
      toggle.innerHTML = this.options.collapsedToggleSymbol;
      this.debug.log('Collapsed section', item);
    }
  }
  
  /**
   * Initialize keyboard navigation for accessibility
   * @private
   */
  _initKeyboardNavigation() {
    this.debug.log('Initializing keyboard navigation');
    
    this.elements.tocLinks.forEach(link => {
      this.events.addEventListener(
        link,
        'keydown',
        (e) => {
          const item = link.closest('.toc-item');
          const toggle = item.querySelector('.toggle-indicator');
          const sublist = item.querySelector('.toc-sublist');
          
          // Space key toggles section expansion
          if (e.key === ' ' && toggle && sublist) {
            e.preventDefault();
            this._toggleSection(item, toggle, sublist);
          }
          
          // Arrow keys for navigation
          if (e.key === 'ArrowRight' && toggle && sublist) {
            // Right arrow expands a collapsed section
            e.preventDefault();
            if (sublist.classList.contains('collapsed')) {
              this._toggleSection(item, toggle, sublist);
            }
          } else if (e.key === 'ArrowLeft' && toggle && sublist) {
            // Left arrow collapses an expanded section
            e.preventDefault();
            if (!sublist.classList.contains('collapsed')) {
              this._toggleSection(item, toggle, sublist);
            }
          }
        }
      );
    });
  }
  
  /**
   * Set up scroll spy to track current section
   * @private
   */
  _setupScrollSpy() {
    this.debug.log('Setting up scroll spy');
    
    // Find all headings that match our TOC
    this._state.headingElements = [];
    
    this.elements.tocLinks.forEach(link => {
      const href = link.getAttribute('href');
      if (href && href.startsWith('#')) {
        const id = href.substring(1);
        const heading = document.getElementById(id);
        
        if (heading) {
          this._state.headingElements.push({ id, element: heading, tocLink: link });
        }
      }
    });
    
    this.debug.log('Found heading elements:', this._state.headingElements.length);
    
    // Create IntersectionObserver to track visible headings
    const options = {
      root: null, // viewport
      rootMargin: this.options.scrollSpyRootMargin,
      threshold: this.options.scrollSpyThreshold
    };
    
    this.intersectionObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        const id = entry.target.id;
        
        if (entry.isIntersecting) {
          this._setActiveSection(id);
        }
      });
    }, options);
    
    // Register the observer for cleanup
    this.cleanup.registerCleanupFunction(() => {
      if (this.intersectionObserver) {
        this.intersectionObserver.disconnect();
      }
    });
    
    // Observe all heading elements
    this._state.headingElements.forEach(({ element }) => {
      this.intersectionObserver.observe(element);
    });
  }
  
  /**
   * Set up hash change handling
   * @private
   */
  _setupHashChangeHandling() {
    this.events.addEventListener(
      window,
      'hashchange',
      this._handleHashChange.bind(this)
    );
  }
  
  /**
   * Set the active section in the TOC
   * @param {string} id - ID of the active section
   * @private
   */
  _setActiveSection(id) {
    this.debug.log('Setting active section:', id);
    
    // Update state
    this._setState({ activeSection: id });
    
    // Remove active class from all items
    this.elements.tocItems.forEach(item => {
      item.classList.remove('active');
    });
    
    // Add active class to the current section
    const activeLink = this.elements.container.querySelector(`.toc-link[href="#${id}"]`);
    if (activeLink) {
      const activeItem = activeLink.closest('.toc-item');
      if (activeItem) {
        activeItem.classList.add('active');
        
        // Ensure parent sections are expanded
        let parent = activeItem.parentElement.closest('.toc-item');
        while (parent) {
          const sublist = parent.querySelector('.toc-sublist');
          const toggle = parent.querySelector('.toggle-indicator');
          
          if (sublist && sublist.classList.contains('collapsed') && toggle) {
            this._toggleSection(parent, toggle, sublist);
          }
          
          parent = parent.parentElement.closest('.toc-item');
        }
        
        // Scroll active item into view if not already visible
        if (!this._isElementInViewport(activeItem)) {
          activeItem.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
      }
    }
  }
  
  /**
   * Handle hash change (direct links to sections)
   * @private
   */
  _handleHashChange() {
    const hash = window.location.hash;
    if (hash) {
      const id = hash.substring(1);
      this._setActiveSection(id);
    }
  }
  
  /**
   * Handle initial hash in URL on page load
   * @private
   */
  _handleInitialHash() {
    // Create a timeout that will be cleaned up if component is destroyed
    const timeoutId = setTimeout(() => {
      const hash = window.location.hash;
      if (hash) {
        const id = hash.substring(1);
        this._setActiveSection(id);
      } else if (this._state.headingElements.length > 0) {
        // Default to first section if no hash
        this._setActiveSection(this._state.headingElements[0].id);
      }
    }, this.options.initialHashDelay);
    
    // Register the timeout for cleanup
    this.cleanup.registerTimeout(timeoutId);
  }
  
  /**
   * Helper to check if an element is in the viewport
   * @param {HTMLElement} el - Element to check
   * @returns {boolean} - Whether the element is fully visible in the viewport
   * @private
   */
  _isElementInViewport(el) {
    const rect = el.getBoundingClientRect();
    return (
      rect.top >= 0 &&
      rect.left >= 0 &&
      rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
      rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
  }
  
  /**
   * Update component state
   * @param {Object} newState - New state to merge with current state
   * @private
   */
  _setState(newState) {
    this._state = {
      ...this._state,
      ...newState
    };
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const HierarchicalTOC = {
  mounted() {
    this.component = new HierarchicalTOCComponent({
      container: this.el,
      liveViewHook: this,
      debug: window.hydepwnsDebug
    }).mount();
  },
  
  updated() {
    if (this.component) {
      this.component.update();
    }
  },
  
  disconnected() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default HierarchicalTOC;
export { HierarchicalTOCComponent }; 