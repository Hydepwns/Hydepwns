/**
 * AsciiArtGenerator Component
 * 
 * Provides client-side functionality for the ASCII art generator component.
 * Handles form interactions and live preview updates.
 * 
 * Features:
 * - Dynamic form state updates based on selected art type
 * - Keyboard navigation support for accessibility
 * - Clean event handling and resource management
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class AsciiArtGeneratorComponent {
  /**
   * Create a new AsciiArtGenerator component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `ascii-art-generator-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      artType: null, // Current art type selection
    };
    
    // DOM element references
    this.elements = {
      container: null,
      form: null,
      artTypeSelect: null,
      styleSelect: null,
      widthInput: null,
      heightInput: null,
      textInput: null,
      previewSection: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[AsciiArtGenerator:${this.componentId}]`, ...args);
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
      console.error('AsciiArtGenerator component requires a container element');
      return this;
    }
    
    // Find form elements
    this._findFormElements();
    
    // Initialize event listeners to handle form interactions
    this._setupEventListeners();
    
    // Add keyboard accessibility
    this._initKeyboardNavigation();
    
    // Focus on the form when component is mounted
    if (this.elements.artTypeSelect) {
      this.elements.artTypeSelect.focus();
    }
    
    // Initialize form state based on current art type
    if (this.elements.artTypeSelect) {
      this._updateFormState(this.elements.artTypeSelect.value);
      this._state.artType = this.elements.artTypeSelect.value;
    }
    
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
    this.elements = {};
    this._state = {};
  }
  
  /**
   * Find and store references to form elements
   * @private
   */
  _findFormElements() {
    this.elements.form = this.elements.container.querySelector('form');
    this.elements.artTypeSelect = this.elements.container.querySelector('select[name="art_type"]');
    this.elements.styleSelect = this.elements.container.querySelector('select[name="style"]');
    this.elements.widthInput = this.elements.container.querySelector('input[name="width"]');
    this.elements.heightInput = this.elements.container.querySelector('input[name="height"]');
    this.elements.textInput = this.elements.container.querySelector('input[name="text"]');
    this.elements.previewSection = this.elements.container.querySelector('.preview-section');
  }
  
  /**
   * Set up event listeners for the component
   * @private
   */
  _setupEventListeners() {
    // When art type changes, adjust the visibility of relevant controls
    if (this.elements.artTypeSelect) {
      this.events.addEventListener(
        this.elements.artTypeSelect,
        'change',
        this._handleArtTypeChange.bind(this)
      );
    }
    
    // Add aria-live region for screen readers to announce changes
    if (this.elements.previewSection) {
      this.elements.previewSection.setAttribute('aria-live', 'polite');
    }
  }
  
  /**
   * Handle art type selection change
   * @param {Event} event - Change event
   * @private
   */
  _handleArtTypeChange(event) {
    const artType = event.target.value;
    this._updateFormState(artType);
    this._state.artType = artType;
  }
  
  /**
   * Update form controls based on the selected art type
   * @param {string} artType - Selected art type
   * @private
   */
  _updateFormState(artType) {
    if (!this.elements.heightInput) return;
    
    // Show/hide or adjust controls based on the selected art type
    const heightControl = this.elements.heightInput.closest('.form-group');
    
    // For arrow type, height is not relevant
    if (artType === 'arrow') {
      heightControl.style.opacity = '0.5';
      this.elements.heightInput.setAttribute('tabindex', '-1');
    } else {
      heightControl.style.opacity = '1';
      this.elements.heightInput.setAttribute('tabindex', '0');
    }
    
    // For custom type, temporarily disable other controls
    if (artType === 'custom') {
      this.elements.container.querySelectorAll('.form-row:first-of-type .form-group:nth-of-type(2), .form-row:nth-of-type(2)').forEach(el => {
        el.style.opacity = '0.5';
      });
      this.elements.styleSelect.setAttribute('tabindex', '-1');
      this.elements.widthInput.setAttribute('tabindex', '-1');
      this.elements.heightInput.setAttribute('tabindex', '-1');
    } else {
      this.elements.container.querySelectorAll('.form-row:first-of-type .form-group:nth-of-type(2), .form-row:nth-of-type(2)').forEach(el => {
        el.style.opacity = '1';
      });
      this.elements.styleSelect.setAttribute('tabindex', '0');
      this.elements.widthInput.setAttribute('tabindex', '0');
      // Height input is controlled by the artType check above
    }
  }
  
  /**
   * Initialize keyboard navigation for accessibility
   * @private
   */
  _initKeyboardNavigation() {
    // Add appropriate ARIA attributes
    this.elements.container.setAttribute('role', 'region');
    this.elements.container.setAttribute('aria-label', 'ASCII Art Generator');
    
    // Add keyboard shortcuts for focus management
    this.events.addEventListener(
      this.elements.container,
      'keydown',
      this._handleKeyDown.bind(this)
    );
  }
  
  /**
   * Handle keyboard events for the component
   * @param {KeyboardEvent} event - Keyboard event
   * @private
   */
  _handleKeyDown(event) {
    // Alt+P to jump to preview section
    if (event.altKey && event.key.toLowerCase() === 'p') {
      event.preventDefault();
      if (this.elements.previewSection) {
        this.elements.previewSection.setAttribute('tabindex', '0');
        this.elements.previewSection.focus();
      }
    }
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const AsciiArtGenerator = {
  mounted() {
    this.component = new AsciiArtGeneratorComponent({
      container: this.el,
      liveViewHook: this
    }).mount();
  },
  
  updated() {
    // Handle updates if component has an update method
    if (this.component && typeof this.component.update === 'function') {
      this.component.update();
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default AsciiArtGenerator;
export { AsciiArtGeneratorComponent }; 