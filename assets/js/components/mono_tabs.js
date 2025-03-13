/**
 * MonoTabsComponent
 * ----------------
 * Component for managing the tabbed interface functionality.
 * 
 * Features:
 * - Keyboard navigation between tabs
 * - Tab state persistence using localStorage
 * - Accessible focus management
 * - Support for multiple tab instances on the same page
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class MonoTabsComponent {
  /**
   * Create a new MonoTabs component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `mono-tabs-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      enablePersistence: true, // Enable tab state persistence
      ...options
    };
    
    // Component state (private)
    this._state = {
      activeIndex: 0, // Currently active tab index
      tabsId: null, // ID of the tabs container for persistence
    };
    
    // DOM element references
    this.elements = {
      container: null,
      tabs: [],
      panels: []
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[MonoTabs:${this.componentId}]`, ...args);
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
    
    // Store container reference
    this.elements.container = this.options.container || this.options.liveViewHook?.el;
    
    if (!this.elements.container) {
      console.error('MonoTabs component requires a container element');
      return this;
    }
    
    // Get tabs ID for persistence
    this._state.tabsId = this.elements.container.dataset.tabsId;
    
    // Get tabs and panels
    this.elements.tabs = Array.from(this.elements.container.querySelectorAll('.mono-tabs__tab'));
    this.elements.panels = Array.from(this.elements.container.querySelectorAll('.mono-tabs__panel'));
    
    // Set up keyboard navigation
    this._setupKeyboardNavigation();
    
    // Set up persistence if enabled
    if (this.options.enablePersistence) {
      this._setupPersistence();
    }
    
    // Find and store the active tab index
    this._state.activeIndex = this._findActiveTabIndex();
    
    this.debug.log('Component mounted', { 
      tabsId: this._state.tabsId, 
      tabCount: this.elements.tabs.length,
      activeIndex: this._state.activeIndex
    });
    
    return this;
  }
  
  /**
   * Update the component
   * @returns {this} - For method chaining
   */
  update() {
    // Refresh tab and panel references
    this.elements.tabs = Array.from(this.elements.container.querySelectorAll('.mono-tabs__tab'));
    this.elements.panels = Array.from(this.elements.container.querySelectorAll('.mono-tabs__panel'));
    
    // Update active index
    this._state.activeIndex = this._findActiveTabIndex();
    
    this.debug.log('Component updated', { activeIndex: this._state.activeIndex });
    
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
    this.elements = {};
    this._state = {};
  }
  
  /**
   * Activate a specific tab
   * @param {number} index - Index of the tab to activate
   * @returns {this} - For method chaining
   */
  activateTab(index) {
    if (index < 0 || index >= this.elements.tabs.length) {
      this.debug.log('Invalid tab index', { index });
      return this;
    }
    
    // Activate the specified tab
    this.elements.tabs[index].click();
    
    return this;
  }
  
  /**
   * Get the currently active tab index
   * @returns {number} - Index of the active tab
   */
  getActiveTabIndex() {
    return this._state.activeIndex;
  }
  
  /**
   * Set up keyboard navigation for tabs
   * @private
   */
  _setupKeyboardNavigation() {
    // Add keyboard event listeners to tabs
    this.elements.tabs.forEach(tab => {
      this.events.addEventListener(
        tab,
        'keydown',
        this._handleTabKeyDown.bind(this)
      );
    });
    
    this.debug.log('Keyboard navigation setup complete');
  }
  
  /**
   * Handle keyboard events for tab navigation
   * @param {KeyboardEvent} event - Keyboard event
   * @private
   */
  _handleTabKeyDown(event) {
    const tabsArray = this.elements.tabs;
    const currentIndex = tabsArray.indexOf(event.target);
    let nextIndex;
    
    switch (event.key) {
      case 'ArrowRight':
      case 'ArrowDown':
        // Move to the next tab
        nextIndex = currentIndex < tabsArray.length - 1 ? currentIndex + 1 : 0;
        tabsArray[nextIndex].click();
        tabsArray[nextIndex].focus();
        event.preventDefault();
        break;
        
      case 'ArrowLeft':
      case 'ArrowUp':
        // Move to the previous tab
        nextIndex = currentIndex > 0 ? currentIndex - 1 : tabsArray.length - 1;
        tabsArray[nextIndex].click();
        tabsArray[nextIndex].focus();
        event.preventDefault();
        break;
        
      case 'Home':
        // Move to the first tab
        tabsArray[0].click();
        tabsArray[0].focus();
        event.preventDefault();
        break;
        
      case 'End':
        // Move to the last tab
        nextIndex = tabsArray.length - 1;
        tabsArray[nextIndex].click();
        tabsArray[nextIndex].focus();
        event.preventDefault();
        break;
    }
    
    // Dispatch custom event for integrations
    if (nextIndex !== undefined && nextIndex !== currentIndex) {
      const event = new CustomEvent('monoTabsNavigation', {
        detail: {
          componentId: this.componentId,
          fromIndex: currentIndex,
          toIndex: nextIndex,
          fromTab: tabsArray[currentIndex],
          toTab: tabsArray[nextIndex]
        },
        bubbles: true
      });
      
      this.elements.container.dispatchEvent(event);
    }
  }
  
  /**
   * Set up tab state persistence using localStorage
   * @private
   */
  _setupPersistence() {
    // Only proceed if localStorage is available
    if (typeof localStorage === 'undefined' || !this._state.tabsId) {
      this.debug.log('Persistence not available or no tabs ID');
      return;
    }
    
    // Store the tab ID when it's changed
    this.elements.tabs.forEach(tab => {
      this.events.addEventListener(
        tab,
        'click',
        () => {
          const tabId = tab.getAttribute('id').replace(`${this._state.tabsId}-tab-`, '');
          localStorage.setItem(`tab-state-${this._state.tabsId}`, tabId);
          this._state.activeIndex = this.elements.tabs.indexOf(tab);
          
          // Dispatch custom event for tab change
          const event = new CustomEvent('monoTabsChange', {
            detail: {
              componentId: this.componentId,
              activeIndex: this._state.activeIndex,
              tabId: tabId
            },
            bubbles: true
          });
          
          this.elements.container.dispatchEvent(event);
        }
      );
    });
    
    // Check if there's a stored tab state and activate that tab
    const storedTabId = localStorage.getItem(`tab-state-${this._state.tabsId}`);
    if (storedTabId) {
      const tabToActivate = document.getElementById(`${this._state.tabsId}-tab-${storedTabId}`);
      if (tabToActivate) {
        tabToActivate.click();
      }
    }
    
    this.debug.log('Persistence setup complete');
  }
  
  /**
   * Find the index of the currently active tab
   * @returns {number} - Index of the active tab
   * @private
   */
  _findActiveTabIndex() {
    // Find the active tab
    const activeTab = this.elements.container.querySelector('.mono-tabs__tab--active');
    return activeTab ? this.elements.tabs.indexOf(activeTab) : 0;
  }
}

export { MonoTabsComponent }; 