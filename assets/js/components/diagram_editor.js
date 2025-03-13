/**
 * Diagram Editor Component
 * -----------------------
 * 
 * Provides client-side functionality for the ASCII diagram editor component.
 * Handles text area interactions, special character insertion, and preview updates.
 * 
 * Features:
 * - Auto-resize text area based on content
 * - Insert special characters at cursor position
 * - Copy diagram to clipboard
 * - Real-time preview updates
 * - Maintain monospace grid alignment
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class DiagramEditorComponent {
  /**
   * Create a new DiagramEditor component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `diagram-editor-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      tabSize: 2, // Number of spaces to insert for a tab
      ...options
    };
    
    // Component state (private)
    this._state = {
      currentText: ''
    };
    
    // DOM element references
    this.elements = {
      container: null,
      textarea: null,
      preview: null
    };
    
    // Phoenix LiveView hook references for event handling
    this.liveViewHandlers = {};
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[DiagramEditor:${this.componentId}]`, ...args);
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
      console.error('DiagramEditor component requires a container element');
      return this;
    }
    
    // Find key elements
    this._findElements();
    
    // Set up Phoenix LiveView event handlers if hook is provided
    if (this.options.liveViewHook) {
      this._setupLiveViewHandlers();
    }
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Initialize editor
    this._initEditor();
    
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
   * Find and store references to necessary DOM elements
   * @private
   */
  _findElements() {
    this.elements.textarea = this.elements.container.querySelector('textarea');
    this.elements.preview = this.elements.container.querySelector('.diagram-preview code');
    
    if (!this.elements.textarea) {
      console.warn('DiagramEditor: Textarea element not found');
    }
    
    if (!this.elements.preview) {
      console.warn('DiagramEditor: Preview element not found');
    }
  }
  
  /**
   * Set up Phoenix LiveView event handlers
   * @private
   */
  _setupLiveViewHandlers() {
    const hook = this.options.liveViewHook;
    
    // Store original LiveView hook methods
    this.liveViewHandlers.handleEvent = hook.handleEvent;
    
    // Override handleEvent to intercept diagram-specific events
    hook.handleEvent = (event, payload) => {
      if (event === 'insert-at-cursor') {
        this.insertAtCursor(payload.text);
        return;
      } else if (event === 'copy-to-clipboard') {
        this.copyToClipboard(payload.text, payload.message);
        return;
      }
      
      // Pass other events to the original handler
      if (this.liveViewHandlers.handleEvent) {
        this.liveViewHandlers.handleEvent.call(hook, event, payload);
      }
    };
  }
  
  /**
   * Set up DOM event listeners
   * @private
   */
  _setupEventListeners() {
    if (this.elements.textarea) {
      // Track input changes to update preview and resize
      this.events.addEventListener(
        this.elements.textarea,
        'input',
        this._handleTextareaInput.bind(this)
      );
      
      // Handle tab key press
      this.events.addEventListener(
        this.elements.textarea,
        'keydown',
        this._handleKeyDown.bind(this)
      );
    }
  }
  
  /**
   * Initialize the editor with current content
   * @private
   */
  _initEditor() {
    // Get current text and update state
    if (this.elements.textarea) {
      this._state.currentText = this.elements.textarea.value;
      
      // Update preview with current text
      this._updatePreview(this._state.currentText);
      
      // Apply auto-resize
      this._autoResize();
      
      // Focus the textarea after a short delay
      setTimeout(() => {
        this.elements.textarea.focus();
        this._autoResize();
      }, 100);
    }
  }
  
  /**
   * Handle textarea input events
   * @param {Event} event - Input event
   * @private
   */
  _handleTextareaInput(event) {
    // Update state with new text
    this._state.currentText = event.target.value;
    
    // Update preview
    this._updatePreview(this._state.currentText);
    
    // Auto-resize the textarea
    this._autoResize();
  }
  
  /**
   * Handle keydown events on the textarea
   * @param {KeyboardEvent} event - Keyboard event
   * @private
   */
  _handleKeyDown(event) {
    // Insert spaces on tab press instead of changing focus
    if (event.key === 'Tab') {
      event.preventDefault();
      
      // Create tab string with specified number of spaces
      const tabString = ' '.repeat(this.options.tabSize);
      this.insertAtCursor(tabString);
    }
  }
  
  /**
   * Update the preview element with the current text
   * @param {string} text - The text to display in the preview
   * @private
   */
  _updatePreview(text) {
    if (this.elements.preview) {
      this.elements.preview.textContent = text;
    }
  }
  
  /**
   * Auto-resize the textarea based on content
   * @private
   */
  _autoResize() {
    if (!this.elements.textarea) return;
    
    // Reset height to calculate actual content height
    this.elements.textarea.style.height = 'auto';
    
    // Set new height based on scrollHeight, with a small padding
    const newHeight = this.elements.textarea.scrollHeight + 5;
    this.elements.textarea.style.height = `${newHeight}px`;
    
    // Also resize the preview to match
    if (this.elements.preview && this.elements.preview.parentNode) {
      this.elements.preview.parentNode.style.height = `${newHeight}px`;
    }
  }
  
  /**
   * Show a notification message
   * @param {string} message - The message to display
   * @private
   */
  _showNotification(message) {
    // Create notification element
    const notification = DOMCleanup.createElement('div', {
      className: 'copy-notification',
      style: {
        position: 'fixed',
        bottom: '20px',
        right: '20px',
        backgroundColor: 'var(--background-color-alt)',
        color: 'var(--text-color)',
        padding: '10px 15px',
        borderRadius: '4px',
        boxShadow: '0 2px 10px rgba(0, 0, 0, 0.2)',
        zIndex: '1000',
        opacity: '0',
        transform: 'translateY(20px)',
        transition: 'opacity 0.3s, transform 0.3s'
      }
    }, message, this.cleanup);
    
    // Add to body
    document.body.appendChild(notification);
    
    // Trigger animation
    setTimeout(() => {
      notification.style.opacity = '1';
      notification.style.transform = 'translateY(0)';
    }, 10);
    
    // Remove after delay
    setTimeout(() => {
      notification.style.opacity = '0';
      notification.style.transform = 'translateY(20px)';
      
      setTimeout(() => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
      }, 300);
    }, 3000);
  }
  
  /**
   * Insert text at the current cursor position
   * @param {string} text - Text to insert
   * @returns {this} - For method chaining
   */
  insertAtCursor(text) {
    if (!this.elements.textarea) return this;
    
    const textarea = this.elements.textarea;
    const startPos = textarea.selectionStart;
    const endPos = textarea.selectionEnd;
    const scrollTop = textarea.scrollTop;
    
    // Insert the text at cursor position
    const value = textarea.value;
    textarea.value = value.substring(0, startPos) + text + value.substring(endPos);
    
    // Update state
    this._state.currentText = textarea.value;
    
    // Move the cursor position after the inserted text
    textarea.selectionStart = startPos + text.length;
    textarea.selectionEnd = startPos + text.length;
    
    // Maintain scroll position
    textarea.scrollTop = scrollTop;
    
    // Focus the textarea and trigger input event to update preview
    textarea.focus();
    textarea.dispatchEvent(new Event('input', { bubbles: true }));
    
    return this;
  }
  
  /**
   * Copy text to clipboard
   * @param {string} text - Text to copy
   * @param {string} message - Success message to show
   * @returns {this} - For method chaining
   */
  copyToClipboard(text, message) {
    try {
      // Use the Clipboard API if available
      navigator.clipboard.writeText(text)
        .then(() => {
          this._showNotification(message || 'Copied to clipboard!');
        })
        .catch(err => {
          this.debug.log('Clipboard write failed:', err);
          this._fallbackCopy(text, message);
        });
    } catch (err) {
      this.debug.log('Clipboard API not available:', err);
      this._fallbackCopy(text, message);
    }
    
    return this;
  }
  
  /**
   * Fallback method for copying to clipboard
   * @param {string} text - Text to copy
   * @param {string} message - Success message to show
   * @private
   */
  _fallbackCopy(text, message) {
    // Create temporary textarea for copying
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();
    
    try {
      const success = document.execCommand('copy');
      if (success) {
        this._showNotification(message || 'Copied to clipboard!');
      } else {
        this._showNotification('Copy failed. Please try manually selecting and copying the text.');
      }
    } catch (err) {
      this.debug.log('execCommand failed:', err);
      this._showNotification('Copy failed. Please try manually selecting and copying the text.');
    }
    
    document.body.removeChild(textarea);
  }
  
  /**
   * Get the current text in the editor
   * @returns {string} - Current text
   */
  getText() {
    return this._state.currentText;
  }
  
  /**
   * Set the text in the editor
   * @param {string} text - Text to set
   * @returns {this} - For method chaining
   */
  setText(text) {
    if (this.elements.textarea) {
      this.elements.textarea.value = text;
      this._state.currentText = text;
      this._updatePreview(text);
      this._autoResize();
      
      // Trigger input event for any listeners
      this.elements.textarea.dispatchEvent(new Event('input', { bubbles: true }));
    }
    
    return this;
  }
  
  /**
   * Focus the editor
   * @returns {this} - For method chaining
   */
  focus() {
    if (this.elements.textarea) {
      this.elements.textarea.focus();
    }
    
    return this;
  }
}

// Legacy LiveView hook for backward compatibility
const DiagramEditor = {
  mounted() {
    this.component = new DiagramEditorComponent({
      container: this.el,
      liveViewHook: this
    }).mount();
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default DiagramEditor;
export { DiagramEditorComponent }; 