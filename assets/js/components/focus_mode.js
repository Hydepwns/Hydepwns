/**
 * Focus Mode Component
 * -----------------------
 * Implements a keyboard-only focus mode that enhances navigation and interaction
 * for users who rely solely on keyboard input.
 * 
 * Features:
 * - Enhanced focus visibility
 * - Simplified UI with fewer distractions
 * - Additional keyboard shortcuts specific to focus mode
 * - Context-aware navigation assistance
 * - Persistent focus mode preference
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class FocusModeComponent {
  /**
   * Create a new FocusMode component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `focus-mode-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      toggleButtonContainer: document.querySelector('header'),
      statusAnnouncerId: 'accessibility-announcer',
      preferenceKey: 'focus_mode_active',
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      focusModeActive: false
    };
    
    // References to DOM elements
    this.elements = {
      body: document.body,
      focusModeToggle: null,
      statusAnnouncer: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[FocusMode:${this.componentId}]`, ...args);
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
    
    // Restore user preference
    this._restoreFocusModePreference();
    
    // Create status announcer for screen readers if it doesn't exist
    this.elements.statusAnnouncer = document.getElementById(this.options.statusAnnouncerId);
    if (!this.elements.statusAnnouncer) {
      this._createStatusAnnouncer();
    }
    
    // Create toggle button
    this._createFocusModeToggle();
    
    // Set up event listeners
    this._setupEventListeners();
    
    this.debug.log('Component mounted, focus mode active:', this._state.focusModeActive);
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
    // Remove focus mode class if active
    if (this._state.focusModeActive) {
      this.elements.body.classList.remove('focus-mode');
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
   * Create the focus mode toggle button
   * @private
   */
  _createFocusModeToggle() {
    // Create toggle button
    this.elements.focusModeToggle = DOMCleanup.createElement('button', {
      className: 'focus-mode-toggle',
      'aria-pressed': this._state.focusModeActive,
      'aria-label': 'Toggle keyboard focus mode'
    }, '', this.cleanup);
    
    // Add inner elements
    const icon = DOMCleanup.createElement('span', {
      className: 'focus-mode-icon'
    }, this._state.focusModeActive ? '◉' : '○', this.cleanup);
    
    const text = DOMCleanup.createElement('span', {
      className: 'focus-mode-text'
    }, 'Focus Mode', this.cleanup);
    
    const shortcut = DOMCleanup.createElement('span', {
      className: 'focus-mode-shortcut',
      'aria-hidden': 'true'
    }, 'Alt+F', this.cleanup);
    
    this.elements.focusModeToggle.appendChild(icon);
    this.elements.focusModeToggle.appendChild(text);
    this.elements.focusModeToggle.appendChild(shortcut);
    
    // Add to DOM
    const container = this.options.toggleButtonContainer || this.elements.body;
    
    if (container === this.elements.body) {
      container.insertBefore(this.elements.focusModeToggle, container.firstChild);
    } else {
      container.appendChild(this.elements.focusModeToggle);
    }
  }
  
  /**
   * Set up event listeners
   * @private
   */
  _setupEventListeners() {
    // Focus mode toggle button click
    if (this.elements.focusModeToggle) {
      this.events.addEventListener(
        this.elements.focusModeToggle,
        'click',
        this._toggleFocusMode.bind(this)
      );
    }
    
    // Keyboard shortcuts
    this.events.addEventListener(
      document,
      'keydown',
      this._handleKeydown.bind(this)
    );
    
    // LiveView event handler
    if (this.options.liveViewHook) {
      this.options.liveViewHook.handleEvent('toggle_focus_mode', () => {
        this._toggleFocusMode();
      });
    }
  }
  
  /**
   * Toggle focus mode on/off
   * @private
   */
  _toggleFocusMode() {
    // Update state
    this._setState({ focusModeActive: !this._state.focusModeActive });
    
    // Update UI
    if (this._state.focusModeActive) {
      this.elements.body.classList.add('focus-mode');
      this._announceStatus('Focus mode activated. Press Alt+F to exit focus mode.');
    } else {
      this.elements.body.classList.remove('focus-mode');
      this._announceStatus('Focus mode deactivated.');
    }
    
    // Update toggle button state
    if (this.elements.focusModeToggle) {
      this.elements.focusModeToggle.setAttribute('aria-pressed', this._state.focusModeActive);
      const icon = this.elements.focusModeToggle.querySelector('.focus-mode-icon');
      if (icon) {
        icon.textContent = this._state.focusModeActive ? '◉' : '○';
      }
    }
    
    // Save preference
    this._saveFocusModePreference();
    
    // Trigger custom event that other components can listen to
    window.dispatchEvent(new CustomEvent('focusModeChanged', {
      detail: { active: this._state.focusModeActive }
    }));
    
    // Send event to server
    if (this.options.liveViewHook) {
      this.options.liveViewHook.pushEvent('focus_mode_changed', { 
        active: this._state.focusModeActive 
      });
    }
    
    this.debug.log('Focus mode toggled:', this._state.focusModeActive);
  }
  
  /**
   * Handle keydown events
   * @param {KeyboardEvent} e - Keyboard event
   * @private
   */
  _handleKeydown(e) {
    // Alt+F toggles focus mode
    if (e.altKey && e.key.toLowerCase() === 'f') {
      e.preventDefault();
      this._toggleFocusMode();
      return;
    }
    
    // Only process other shortcuts if focus mode is active
    if (!this._state.focusModeActive) return;
    
    // When in focus mode, provide additional shortcuts
    if (e.altKey) {
      switch (e.key.toLowerCase()) {
        case 'n': // Next interactive element
          e.preventDefault();
          this._navigateToNextInteractive();
          break;
        case 'p': // Previous interactive element
          e.preventDefault();
          this._navigateToPreviousInteractive();
          break;
        case 'i': // Show context information about current element
          e.preventDefault();
          this._showElementContext();
          break;
        case 'c': // Read current section content
          e.preventDefault();
          this._readCurrentSection();
          break;
      }
    }
  }
  
  /**
   * Navigate to the next interactive element
   * @private
   */
  _navigateToNextInteractive() {
    const interactiveElements = this._getInteractiveElements();
    const currentFocused = document.activeElement;
    let currentIndex = interactiveElements.indexOf(currentFocused);
    
    if (currentIndex === -1 || currentIndex === interactiveElements.length - 1) {
      currentIndex = 0;
    } else {
      currentIndex++;
    }
    
    if (interactiveElements[currentIndex]) {
      interactiveElements[currentIndex].focus();
      this._announceElementContext(interactiveElements[currentIndex]);
    }
  }
  
  /**
   * Navigate to the previous interactive element
   * @private
   */
  _navigateToPreviousInteractive() {
    const interactiveElements = this._getInteractiveElements();
    const currentFocused = document.activeElement;
    let currentIndex = interactiveElements.indexOf(currentFocused);
    
    if (currentIndex <= 0) {
      currentIndex = interactiveElements.length - 1;
    } else {
      currentIndex--;
    }
    
    if (interactiveElements[currentIndex]) {
      interactiveElements[currentIndex].focus();
      this._announceElementContext(interactiveElements[currentIndex]);
    }
  }
  
  /**
   * Get all interactive elements on the page
   * @returns {Array} - Array of interactive elements
   * @private
   */
  _getInteractiveElements() {
    return Array.from(document.querySelectorAll(
      'a[href], button, input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )).filter(el => {
      // Filter out hidden elements
      const style = window.getComputedStyle(el);
      return !(style.display === 'none' || style.visibility === 'hidden');
    });
  }
  
  /**
   * Announce context information about an element
   * @param {HTMLElement} element - Element to announce context for
   * @private
   */
  _announceElementContext(element) {
    let message = '';
    
    // Get element type and name
    const tagName = element.tagName.toLowerCase();
    const ariaLabel = element.getAttribute('aria-label');
    const label = ariaLabel || element.innerText || element.value || element.placeholder;
    
    // Build informative message
    message = `${tagName}`;
    if (label) message += `, ${label}`;
    
    // Add context about parent section if available
    const section = this._findParentSection(element);
    if (section) {
      const heading = section.querySelector('h1, h2, h3, h4, h5, h6');
      if (heading) {
        message += `. In section: ${heading.innerText}`;
      }
    }
    
    this._announceStatus(message);
  }
  
  /**
   * Find the parent section of an element
   * @param {HTMLElement} element - Element to find parent section for
   * @returns {HTMLElement|null} - Parent section element or null
   * @private
   */
  _findParentSection(element) {
    let parent = element.parentElement;
    while (parent && parent !== document.body) {
      if (parent.tagName.toLowerCase() === 'section') {
        return parent;
      }
      parent = parent.parentElement;
    }
    return null;
  }
  
  /**
   * Show context information about the current active element
   * @private
   */
  _showElementContext() {
    const element = document.activeElement;
    if (element && element !== document.body) {
      this._announceElementContext(element);
    }
  }
  
  /**
   * Read the content of the current section
   * @private
   */
  _readCurrentSection() {
    const element = document.activeElement;
    const section = this._findParentSection(element);
    
    if (section) {
      // Get text content, but filter out scripts, etc.
      const text = Array.from(section.childNodes)
        .filter(node => {
          return node.nodeType === Node.TEXT_NODE || 
            (node.nodeType === Node.ELEMENT_NODE && 
             !['SCRIPT', 'STYLE'].includes(node.tagName));
        })
        .map(node => node.textContent)
        .join(' ')
        .replace(/\s+/g, ' ')
        .trim();
      
      this._announceStatus(`Current section content: ${text}`);
    }
  }
  
  /**
   * Create a status announcer for screen readers
   * @private
   */
  _createStatusAnnouncer() {
    this.elements.statusAnnouncer = DOMCleanup.createElement('div', {
      id: this.options.statusAnnouncerId,
      className: 'sr-only',
      'aria-live': 'polite',
      'aria-atomic': 'true'
    }, '', this.cleanup);
    
    document.body.appendChild(this.elements.statusAnnouncer);
  }
  
  /**
   * Announce a status message to screen readers
   * @param {string} message - Message to announce
   * @private
   */
  _announceStatus(message) {
    if (this.elements.statusAnnouncer) {
      this.elements.statusAnnouncer.textContent = message;
    }
    this.debug.log('Focus Mode announcement:', message);
  }
  
  /**
   * Save the focus mode preference to localStorage
   * @private
   */
  _saveFocusModePreference() {
    try {
      localStorage.setItem(this.options.preferenceKey, this._state.focusModeActive);
    } catch (e) {
      this.debug.log('Error saving focus mode preference:', e);
    }
  }
  
  /**
   * Restore the focus mode preference from localStorage
   * @private
   */
  _restoreFocusModePreference() {
    try {
      const savedPreference = localStorage.getItem(this.options.preferenceKey);
      if (savedPreference !== null) {
        const isActive = savedPreference === 'true';
        this._setState({ focusModeActive: isActive });
        
        if (isActive) {
          this.elements.body.classList.add('focus-mode');
        }
      }
    } catch (e) {
      this.debug.log('Error restoring focus mode preference:', e);
    }
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
const FocusMode = {
  mounted() {
    this.component = new FocusModeComponent({
      liveViewHook: this,
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

export default FocusMode;
export { FocusModeComponent }; 