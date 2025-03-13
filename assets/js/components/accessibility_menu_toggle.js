/**
 * Accessibility Menu Toggle Component
 * ---------------------------------
 * Manages the accessibility menu dropdown behavior.
 * Handles keyboard interaction, focus management, and click outside closing.
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class AccessibilityMenuToggleComponent {
  /**
   * Create a new Accessibility Menu Toggle component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `accessibility-menu-toggle-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      dropdownId: 'a11y-menu-dropdown', // ID of the dropdown element
      announcerId: 'accessibility-announcer', // ID of the screen reader announcer
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      isOpen: false
    };
    
    // DOM element references
    this.elements = {
      container: null, // The toggle button
      dropdown: null, // The dropdown menu
      radioButtons: [], // Radio buttons in the menu
      announcer: null // Screen reader announcer
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[AccessibilityMenuToggle:${this.componentId}]`, ...args);
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
    
    // Store container (button) reference
    this.elements.container = this.options.container || this.options.liveViewHook?.el;
    
    if (!this.elements.container) {
      console.error('Accessibility Menu Toggle component requires a container element');
      return this;
    }
    
    // Find dropdown and radio buttons
    this.elements.dropdown = document.getElementById(this.options.dropdownId);
    
    if (!this.elements.dropdown) {
      console.error(`Dropdown element with ID "${this.options.dropdownId}" not found`);
      return this;
    }
    
    this.elements.radioButtons = Array.from(this.elements.dropdown.querySelectorAll('[role="radio"]'));
    
    // Find announcer element
    this.elements.announcer = document.getElementById(this.options.announcerId);
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Load and apply saved preferences
    this._loadSavedPreferences();
    
    this.debug.log('Component mounted');
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
    // If menu is open, close it before cleaning up
    if (this._state.isOpen) {
      this.closeMenu();
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
    this.elements = {};
    this._state = {};
  }
  
  /**
   * Set up event listeners
   * @private
   */
  _setupEventListeners() {
    // Set up button click and keydown handling
    this.events.addEventListener(
      this.elements.container,
      'click',
      this.toggleMenu.bind(this)
    );
    
    this.events.addEventListener(
      this.elements.container,
      'keydown',
      this._handleKeydown.bind(this)
    );
    
    // Set up dropdown event delegation
    this.events.addEventListener(
      this.elements.dropdown,
      'click',
      this._handleRadioClick.bind(this)
    );
    
    this.events.addEventListener(
      this.elements.dropdown,
      'keydown',
      this._handleDropdownKeydown.bind(this)
    );
    
    // Close when clicking outside
    this.events.addEventListener(
      document,
      'click',
      this._handleOutsideClick.bind(this)
    );
  }
  
  /**
   * Toggle menu open/closed state
   */
  toggleMenu() {
    if (this._state.isOpen) {
      this.closeMenu();
    } else {
      this.openMenu();
    }
  }
  
  /**
   * Open the accessibility menu
   */
  openMenu() {
    // Show the dropdown
    this.elements.dropdown.hidden = false;
    this.elements.container.setAttribute('aria-expanded', 'true');
    
    // Update state
    this._state.isOpen = true;
    
    // Focus the first radio button
    const firstRadio = this.elements.dropdown.querySelector('[role="radio"]');
    if (firstRadio) {
      firstRadio.focus();
    }
    
    // Announce to screen readers
    this._announceToScreenReader('Accessibility menu opened');
    
    this.debug.log('Menu opened');
  }
  
  /**
   * Close the accessibility menu
   */
  closeMenu() {
    // Hide the dropdown
    this.elements.dropdown.hidden = true;
    this.elements.container.setAttribute('aria-expanded', 'false');
    
    // Update state
    this._state.isOpen = false;
    
    // Return focus to the toggle button
    this.elements.container.focus();
    
    // Announce to screen readers
    this._announceToScreenReader('Accessibility menu closed');
    
    this.debug.log('Menu closed');
  }
  
  /**
   * Handle button keydown events
   * @param {Event} event - Keydown event
   * @private
   */
  _handleKeydown(event) {
    switch (event.key) {
      case 'Enter':
      case ' ':
        event.preventDefault();
        this.toggleMenu();
        break;
      case 'Escape':
        if (this._state.isOpen) {
          event.preventDefault();
          this.closeMenu();
        }
        break;
      case 'ArrowDown':
        if (this._state.isOpen) {
          event.preventDefault();
          const firstRadio = this.elements.dropdown.querySelector('[role="radio"]');
          if (firstRadio) {
            firstRadio.focus();
          }
        } else {
          this.openMenu();
        }
        break;
    }
  }
  
  /**
   * Handle dropdown keydown events
   * @param {Event} event - Keydown event
   * @private
   */
  _handleDropdownKeydown(event) {
    // Handle Escape to close the menu
    if (event.key === 'Escape') {
      event.preventDefault();
      this.closeMenu();
      return;
    }
    
    // Handle arrow keys for navigation within radiogroups
    if (event.key === 'ArrowUp' || event.key === 'ArrowDown') {
      // Find the radiogroup that contains the active element
      const radiogroup = event.target.closest('[role="radiogroup"]');
      if (!radiogroup) return;
      
      const radios = Array.from(radiogroup.querySelectorAll('[role="radio"]'));
      const currentIndex = radios.indexOf(document.activeElement);
      
      if (currentIndex === -1) return;
      
      event.preventDefault();
      
      // Calculate next focus index
      let nextIndex;
      if (event.key === 'ArrowDown') {
        nextIndex = (currentIndex + 1) % radios.length;
      } else {
        nextIndex = (currentIndex - 1 + radios.length) % radios.length;
      }
      
      // Focus the new element
      radios[nextIndex].focus();
    }
  }
  
  /**
   * Handle radio button click events
   * @param {Event} event - Click event
   * @private
   */
  _handleRadioClick(event) {
    const radio = event.target.closest('[role="radio"]');
    if (!radio) return;
    
    // Handle radio button selection
    const radiogroup = radio.closest('[role="radiogroup"]');
    if (!radiogroup) return;
    
    // Update all radio buttons in the group
    const radios = radiogroup.querySelectorAll('[role="radio"]');
    radios.forEach(r => {
      r.setAttribute('aria-checked', 'false');
      r.classList.remove('active');
    });
    
    // Set the clicked one as checked
    radio.setAttribute('aria-checked', 'true');
    radio.classList.add('active');
    
    // Get option information for saving preferences
    const optionName = radio.dataset.a11yOption;
    
    if (optionName) {
      this._savePreference(optionName);
      this._applyPreference(optionName);
    }
  }
  
  /**
   * Handle click outside to close menu
   * @param {Event} event - Click event
   * @private
   */
  _handleOutsideClick(event) {
    // Close menu when clicking outside
    if (this._state.isOpen &&
        !this.elements.dropdown.contains(event.target) &&
        !this.elements.container.contains(event.target)) {
      this.closeMenu();
    }
  }
  
  /**
   * Save accessibility preference to localStorage
   * @param {string} optionName - Name of the option to save
   * @private
   */
  _savePreference(optionName) {
    try {
      localStorage.setItem('a11y_preference_' + optionName, 'true');
      
      // Store the timestamp for when preferences were last updated
      localStorage.setItem('a11y_preferences_updated', Date.now().toString());
      
      this.debug.log('Saved accessibility preference:', optionName);
    } catch (e) {
      // Handle localStorage errors
      console.error('Failed to save accessibility preference:', e);
    }
  }
  
  /**
   * Load saved preferences from localStorage
   * @private
   */
  _loadSavedPreferences() {
    try {
      // Get all stored preferences
      const preferences = [];
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith('a11y_preference_')) {
          const optionName = key.replace('a11y_preference_', '');
          preferences.push(optionName);
        }
      }
      
      // Apply each saved preference
      preferences.forEach(option => {
        const radio = this.elements.dropdown.querySelector(`[data-a11y-option="${option}"]`);
        if (radio) {
          // Update the radio button state
          const radiogroup = radio.closest('[role="radiogroup"]');
          if (radiogroup) {
            const radios = radiogroup.querySelectorAll('[role="radio"]');
            radios.forEach(r => {
              r.setAttribute('aria-checked', 'false');
              r.classList.remove('active');
            });
          }
          
          radio.setAttribute('aria-checked', 'true');
          radio.classList.add('active');
          
          // Apply the preference
          this._applyPreference(option);
        }
      });
      
      if (preferences.length > 0) {
        this.debug.log('Loaded accessibility preferences:', preferences);
      }
    } catch (e) {
      // Handle localStorage errors
      console.error('Failed to load accessibility preferences:', e);
    }
  }
  
  /**
   * Apply accessibility preference to the UI
   * @param {string} optionName - Name of the option to apply
   * @private
   */
  _applyPreference(optionName) {
    // Text size preferences
    if (optionName === 'text-size-small') {
      document.documentElement.style.setProperty('--text-size-factor', '0.85');
      this._announceToScreenReader('Text size set to small');
    } else if (optionName === 'text-size-normal') {
      document.documentElement.style.setProperty('--text-size-factor', '1');
      this._announceToScreenReader('Text size set to normal');
    } else if (optionName === 'text-size-large') {
      document.documentElement.style.setProperty('--text-size-factor', '1.2');
      this._announceToScreenReader('Text size set to large');
    }
    
    // Animation preferences
    else if (optionName === 'animations-disabled') {
      document.documentElement.classList.add('animations-disabled');
      document.documentElement.classList.remove('animations-reduced');
      this._announceToScreenReader('Animations disabled');
    } else if (optionName === 'animations-reduced') {
      document.documentElement.classList.add('animations-reduced');
      document.documentElement.classList.remove('animations-disabled');
      this._announceToScreenReader('Animations reduced');
    } else if (optionName === 'animations-enabled') {
      document.documentElement.classList.remove('animations-disabled', 'animations-reduced');
      this._announceToScreenReader('Animations enabled');
    }
    
    // Contrast preferences
    else if (optionName === 'contrast-high') {
      document.documentElement.classList.add('high-contrast');
      this._announceToScreenReader('High contrast mode enabled');
    } else if (optionName === 'contrast-normal') {
      document.documentElement.classList.remove('high-contrast');
      this._announceToScreenReader('Normal contrast mode enabled');
    }
  }
  
  /**
   * Announce message to screen readers
   * @param {string} message - Message to announce
   * @private
   */
  _announceToScreenReader(message) {
    // Find the announcer element
    if (this.elements.announcer) {
      // Update the content to trigger screen reader announcement
      this.elements.announcer.textContent = message;
    }
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const AccessibilityMenuToggle = {
  mounted() {
    this.component = new AccessibilityMenuToggleComponent({
      liveViewHook: this,
      container: this.el,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  disconnected() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default AccessibilityMenuToggle;
export { AccessibilityMenuToggleComponent }; 