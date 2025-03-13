/**
 * Terminal Hooks Component
 * -----------------------
 * Provides additional terminal functionality beyond the core terminal component.
 * Includes resize handling, fullscreen toggle, keyboard events, and more.
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class TerminalHooksComponent {
  /**
   * Create a new Terminal Hooks component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `terminal-hooks-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      isFullscreen: false
    };
    
    // DOM element references
    this.elements = {
      container: null,
      content: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[TerminalHooks:${this.componentId}]`, ...args);
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
      console.error('Terminal Hooks component requires a container element');
      return this;
    }
    
    // Find content element
    this.elements.content = this.elements.container.querySelector('.terminal-content');
    
    // Store component reference in window for event handlers
    window.terminalHooks = window.terminalHooks || {};
    window.terminalHooks[this.elements.container.id] = this.options.liveViewHook;
    
    // Register cleanup function to remove reference
    this.cleanup.registerCleanupFunction(() => {
      if (window.terminalHooks && window.terminalHooks[this.elements.container.id]) {
        delete window.terminalHooks[this.elements.container.id];
      }
    });
    
    // Set up event listeners and functionality
    this._handleTerminalResize();
    this._handleFullScreenToggle();
    this._scrollToBottom();
    this._setupKeyboardEventListeners();
    this._setupPasteEventListener();
    this._setupClickFocusListener();
    
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
   * Scroll terminal content to bottom
   */
  _scrollToBottom() {
    if (this.elements.content) {
      this.elements.content.scrollTop = this.elements.content.scrollHeight;
    }
  }
  
  /**
   * Set up terminal resize functionality
   * @private
   */
  _handleTerminalResize() {
    // Implementation for terminal resize functionality
    // This would typically include resize observer setup
    // or window resize event handling
    
    // For this migration, we'll leave as a placeholder
    // to be implemented as needed
    this.debug.log('Terminal resize handler set up');
  }
  
  /**
   * Set up fullscreen toggle functionality
   * @private
   */
  _handleFullScreenToggle() {
    // Find fullscreen toggle button
    const fullscreenToggle = this.elements.container.querySelector('.terminal-fullscreen-toggle');
    
    if (fullscreenToggle) {
      this.events.addEventListener(
        fullscreenToggle,
        'click',
        (event) => {
          event.preventDefault();
          this._toggleFullscreen();
        }
      );
    }
  }
  
  /**
   * Toggle fullscreen state
   * @private
   */
  _toggleFullscreen() {
    this._state.isFullscreen = !this._state.isFullscreen;
    
    if (this._state.isFullscreen) {
      this.elements.container.classList.add('terminal-fullscreen');
      document.body.classList.add('terminal-active-fullscreen');
    } else {
      this.elements.container.classList.remove('terminal-fullscreen');
      document.body.classList.remove('terminal-active-fullscreen');
    }
    
    // Notify server about fullscreen change
    if (this.options.liveViewHook) {
      this.options.liveViewHook.pushEvent('terminal_fullscreen', {
        fullscreen: this._state.isFullscreen
      });
    }
    
    // Focus input element
    const input = this.elements.container.querySelector('.terminal-input');
    if (input) {
      setTimeout(() => input.focus(), 50);
    }
  }
  
  /**
   * Set up keyboard event listeners
   * @private
   */
  _setupKeyboardEventListeners() {
    // Find input element
    const input = this.elements.container.querySelector('.terminal-input');
    
    if (input) {
      this.events.addEventListener(
        input,
        'keydown',
        (event) => {
          // Handle keyboard shortcuts
          // Customize as needed based on specific keyboard requirements
          
          // Example: ESC to exit fullscreen
          if (event.key === 'Escape' && this._state.isFullscreen) {
            event.preventDefault();
            this._toggleFullscreen();
          }
          
          // Example: Ctrl+L to clear terminal
          if (event.key === 'l' && event.ctrlKey) {
            event.preventDefault();
            
            if (this.options.liveViewHook) {
              this.options.liveViewHook.pushEvent('terminal_clear', {});
            }
          }
        }
      );
    }
  }
  
  /**
   * Set up paste event listener
   * @private
   */
  _setupPasteEventListener() {
    this.events.addEventListener(
      this.elements.container,
      'paste',
      (event) => {
        const clipboardData = event.clipboardData || window.clipboardData;
        const pastedText = clipboardData.getData('text');
        
        if (pastedText && this.elements.container) {
          // Prevent the default paste
          event.preventDefault();
          
          // Push the paste event to the server
          if (this.options.liveViewHook) {
            this.options.liveViewHook.pushEvent('paste', { content: pastedText });
          }
        }
      }
    );
  }
  
  /**
   * Set up click focus listener
   * @private
   */
  _setupClickFocusListener() {
    this.events.addEventListener(
      this.elements.container,
      'click',
      (event) => {
        const input = this.elements.container.querySelector('.terminal-input');
        if (input && event.target !== input) {
          input.focus();
          
          // Set cursor position to end of input
          const len = input.value.length;
          input.setSelectionRange(len, len);
        }
      }
    );
  }
  
  /**
   * Update the component, typically after DOM changes
   */
  update() {
    this._scrollToBottom();
  }
}

/**
 * TerminalLine Component for handling individual terminal lines
 */
class TerminalLineComponent {
  /**
   * Create a new Terminal Line component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `terminal-line-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[TerminalLine:${this.componentId}]`, ...args);
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
    this.elements = {
      container: this.options.container || this.options.liveViewHook?.el
    };
    
    if (!this.elements.container) {
      console.error('Terminal Line component requires a container element');
      return this;
    }
    
    // Scroll terminal content to bottom when line is added
    this._scrollParentToBottom();
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
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
  }
  
  /**
   * Scroll parent terminal content to bottom
   * @private
   */
  _scrollParentToBottom() {
    const terminalContent = this.elements.container.closest('.terminal-content');
    if (terminalContent) {
      terminalContent.scrollTop = terminalContent.scrollHeight;
    }
  }
}

/**
 * Legacy LiveView hooks for backward compatibility
 */
const TerminalHooks = {
  Terminal: {
    mounted() {
      this.component = new TerminalHooksComponent({
        liveViewHook: this,
        container: this.el,
        debug: window.DEBUG && window.DEBUG.enabled
      }).mount();
    },
    
    updated() {
      if (this.component) {
        this.component.update();
      }
    },
    
    destroyed() {
      if (this.component) {
        this.component.destroy();
        this.component = null;
      }
    },
    
    // Preserve original API methods for backward compatibility
    scrollToBottom() {
      if (this.component) {
        this.component._scrollToBottom();
      }
    },
    
    handleTerminalResize() {
      if (this.component) {
        this.component._handleTerminalResize();
      }
    },
    
    handleFullScreenToggle() {
      if (this.component) {
        this.component._handleFullScreenToggle();
      }
    }
  },
  
  TerminalLine: {
    mounted() {
      this.component = new TerminalLineComponent({
        liveViewHook: this,
        container: this.el,
        debug: window.DEBUG && window.DEBUG.enabled
      }).mount();
    },
    
    destroyed() {
      if (this.component) {
        this.component.destroy();
        this.component = null;
      }
    }
  }
};

export default TerminalHooks;
export { TerminalHooksComponent, TerminalLineComponent }; 