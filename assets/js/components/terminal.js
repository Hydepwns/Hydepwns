/**
 * Terminal Component
 * -----------------
 * Component for the interactive terminal interface.
 * 
 * Features:
 * - Command history management with localStorage persistence
 * - Keyboard navigation and shortcuts
 * - Terminal UI controls (fullscreen, minimize, close)
 * - Syntax highlighting for output
 * - Theme customization
 * - Command autocomplete functionality
 * - Offline support with command synchronization
 * 
 * Migrated to use the robust component system following the component migration guide.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class TerminalComponent {
  /**
   * Create a new Terminal component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `terminal-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      terminalId: null, // Unique ID for this terminal instance
      fullscreenEnabled: true, // Whether fullscreen mode is enabled
      liveViewHook: null, // LiveView hook instance if used in a hook
      fontFamily: 'monospace', // Font family for terminal text
      cursorStyle: 'block', // Cursor style (block, bar, underline)
      highlightColor: '#FF2E97', // Color for highlighting
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      isFullscreen: false,
      isMinimized: false,
      isOffline: !navigator.onLine,
      commandHistory: [],
      historyIndex: -1,
      autocompleteOptions: [],
      autocompleteIndex: -1,
      showAutocomplete: false,
      mutationObserver: null
    };
    
    // DOM element references
    this.elements = {
      container: null,
      terminal: null,
      inputEl: null,
      gridEl: null,
      autocompleteEl: null
    };
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[Terminal:${this.componentId}]`, ...args);
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
      console.error('Terminal component requires a container element');
      return this;
    }
    
    // Store terminal ID
    this.terminalId = this.options.terminalId || this.elements.container.dataset.terminalId;
    
    // Get fullscreen setting
    this.options.fullscreenEnabled = this.options.fullscreenEnabled || 
      this.elements.container.dataset.fullscreen === 'true';
    
    // Get customization options from data attributes if not specified in options
    this.options.fontFamily = this.options.fontFamily || this.elements.container.dataset.fontFamily || 'monospace';
    this.options.cursorStyle = this.options.cursorStyle || this.elements.container.dataset.cursorStyle || 'block';
    this.options.highlightColor = this.options.highlightColor || this.elements.container.dataset.highlightColor || '#FF2E97';
    
    // Store terminal element references
    this.elements.terminal = this.elements.container;
    this.elements.inputEl = this.elements.terminal.querySelector(`#${this.terminalId}-input`);
    this.elements.gridEl = this.elements.terminal.querySelector(`#${this.terminalId}-grid`);
    
    // Apply customizations
    this._applyCustomizations();
    
    // Load command history
    this._loadCommandHistory();
    
    // Create autocomplete element
    this._createAutocompleteElement();
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Set up mutation observer
    this._setupMutationObserver();
    
    // Load user preferences
    this._loadUserPreferences();
    
    // Initialize offline support
    this._initializeOfflineSupport();
    
    // Focus the input element
    setTimeout(() => this.elements.inputEl?.focus(), 100);
    
    this.debug.log('Component mounted');
    
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
    // Disconnect mutation observer
    if (this._state.mutationObserver) {
      this._state.mutationObserver.disconnect();
    }
    
    // Exit fullscreen if active
    if (this._state.isFullscreen) {
      this.toggleFullscreen();
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
   * Initialize offline support
   * @private
   */
  _initializeOfflineSupport() {
    // Register event listeners for online/offline status
    this.events.addEventListener(window, 'online', this._handleOnlineEvent.bind(this));
    this.events.addEventListener(window, 'offline', this._handleOfflineEvent.bind(this));
    
    // Listen for terminal-specific events
    this.events.addEventListener(document, 'terminal:online', this._handleOnlineEvent.bind(this));
    this.events.addEventListener(document, 'terminal:offline', this._handleOfflineEvent.bind(this));
    
    // Listen for command results from the offline handler
    this.events.addEventListener(
      document, 
      'terminal:commandresult', 
      this._handleOfflineCommandResult.bind(this)
    );
    
    // Listen for system messages from the offline handler
    this.events.addEventListener(
      document, 
      'terminal:addsystemmessage', 
      this._handleSystemMessage.bind(this)
    );
    
    // Set initial offline state if needed
    if (this._state.isOffline) {
      this.elements.terminal.classList.add('terminal-offline');
    }
    
    this.debug.log(`Terminal initialized with offline support. Status: ${this._state.isOffline ? 'Offline' : 'Online'}`);
  }
  
  /**
   * Handle online event
   * @private
   */
  _handleOnlineEvent() {
    this._state.isOffline = false;
    this.elements.terminal.classList.remove('terminal-offline');
    this.debug.log('Terminal is now online');
  }
  
  /**
   * Handle offline event
   * @private
   */
  _handleOfflineEvent() {
    this._state.isOffline = true;
    this.elements.terminal.classList.add('terminal-offline');
    this.debug.log('Terminal is now offline');
  }
  
  /**
   * Handle offline command result
   * @param {Event} event - Custom event with command result
   * @private
   */
  _handleOfflineCommandResult(event) {
    const { terminalId, result, offline } = event.detail;
    
    // Only process events for this terminal
    if (terminalId !== this.terminalId) return;
    
    this.debug.log('Received offline command result:', result);
    
    // Process the result similar to how normal commands are processed
    if (result.clear) {
      // Clear terminal output
      this._clearTerminalOutput();
    }
    
    // Add output lines
    if (result.output && result.output.length > 0) {
      for (const line of result.output) {
        this._addOutputLine(line.content, line.type, true);
      }
    }
    
    // Scroll to bottom
    this._scrollToBottom();
  }
  
  /**
   * Handle system message
   * @param {Event} event - Custom event with system message
   * @private
   */
  _handleSystemMessage(event) {
    const { terminalId, message } = event.detail;
    
    // Only process events for this terminal
    if (terminalId !== this.terminalId) return;
    
    // Add message to output
    this._addOutputLine(message, 'system', true);
    
    // Scroll to bottom
    this._scrollToBottom();
  }
  
  /**
   * Clear terminal output
   * @private
   */
  _clearTerminalOutput() {
    // Remove all output lines
    const outputLines = this.elements.gridEl.querySelectorAll('.terminal-line');
    outputLines.forEach(line => line.remove());
  }
  
  /**
   * Add output line to terminal
   * @param {string} content - Line content
   * @param {string} type - Line type (output, command, error, system)
   * @param {boolean} isOffline - Whether this line was generated offline
   * @returns {HTMLElement} - The created line element
   * @private
   */
  _addOutputLine(content, type = 'output', isOffline = false) {
    // Create new line element using DOMCleanup
    const line = DOMCleanup.createElement('div', {
      className: `terminal-line terminal-line-${type}${isOffline && this._state.isOffline ? ' terminal-line-offline' : ''}`
    }, '', this.cleanup);
    
    // Add type-specific content
    if (type === 'command') {
      const promptSpan = DOMCleanup.createElement('span', {
        className: 'terminal-prompt'
      }, this._getPrompt(), this.cleanup);
      
      line.appendChild(promptSpan);
      line.appendChild(document.createTextNode(content));
    } else {
      line.textContent = content;
    }
    
    // Insert before the input line
    const inputLine = this.elements.gridEl.querySelector('.terminal-input-line');
    this.elements.gridEl.insertBefore(line, inputLine);
    
    return line;
  }
  
  /**
   * Scroll terminal to bottom
   * @private
   */
  _scrollToBottom() {
    if (this.elements.gridEl) {
      this.elements.gridEl.scrollTop = this.elements.gridEl.scrollHeight;
    }
  }
  
  /**
   * Get terminal prompt
   * @returns {string} - Terminal prompt
   * @private
   */
  _getPrompt() {
    // Get prompt from the existing prompt element or use default
    const promptEl = this.elements.terminal.querySelector('.terminal-prompt');
    return promptEl ? promptEl.textContent : '> ';
  }
  
  /**
   * Set up event listeners
   * @private
   */
  _setupEventListeners() {
    // Process command submission
    this.events.addEventListener(
      this.elements.inputEl,
      'keydown',
      this._handleInputKeyDown.bind(this)
    );
    
    // Handle fullscreen toggle
    this.events.addEventListener(
      this.elements.terminal,
      'terminal:fullscreen',
      () => {
        if (this.options.fullscreenEnabled) {
          this.toggleFullscreen();
        }
      }
    );
    
    // Handle minimize
    this.events.addEventListener(
      this.elements.terminal,
      'terminal:minimize',
      this.toggleMinimize.bind(this)
    );
    
    // Handle close
    this.events.addEventListener(
      this.elements.terminal,
      'terminal:close',
      this._handleClose.bind(this)
    );
    
    // Re-focus input when clicking anywhere in the terminal
    this.events.addEventListener(
      this.elements.gridEl,
      'click',
      (event) => {
        // Only focus if not selecting text
        if (window.getSelection().toString().length === 0) {
          this.elements.inputEl.focus();
        }
      }
    );
    
    // Add paste event listener
    this.events.addEventListener(
      this.elements.terminal,
      'paste',
      this._handlePaste.bind(this)
    );
    
    // Prevent focus loss when clicking autocomplete
    if (this.elements.autocompleteEl) {
      this.events.addEventListener(
        this.elements.autocompleteEl,
        'mousedown',
        (event) => {
          event.preventDefault();
        }
      );
    }
  }
  
  /**
   * Handle input keydown events
   * @param {Event} event - Keydown event
   * @private
   */
  _handleInputKeyDown(event) {
    if (event.key === 'Enter') {
      event.preventDefault();
      this._handleCommandSubmission();
    } else if (event.key === 'Tab') {
      event.preventDefault();
      this._handleTabCompletion();
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      this._navigateHistory(-1);
    } else if (event.key === 'ArrowDown') {
      event.preventDefault();
      this._navigateHistory(1);
    } else if (event.key === 'Escape') {
      if (this._state.showAutocomplete) {
        this._hideAutocomplete();
      } else if (this._state.isFullscreen) {
        this.toggleFullscreen();
      }
    } else if (this._state.showAutocomplete && 
              (event.key === 'ArrowRight' || event.key === 'ArrowLeft')) {
      // Prevent cursor navigation when autocomplete is shown
      event.preventDefault();
    }
  }
  
  /**
   * Handle paste events
   * @param {Event} event - Paste event
   * @private
   */
  _handlePaste(event) {
    const clipboardData = event.clipboardData || window.clipboardData;
    const pastedText = clipboardData.getData('text');
    
    if (pastedText) {
      // Prevent the default paste
      event.preventDefault();
      
      // Push the paste event to the server
      if (this.options.liveViewHook) {
        this.options.liveViewHook.pushEvent('paste', { content: pastedText });
      }
    }
  }
  
  /**
   * Handle command submission
   * @private
   */
  _handleCommandSubmission() {
    const command = this.elements.inputEl.value.trim();
    
    if (command === '') return;
    
    // Add command to history
    this._addToCommandHistory(command);
    
    // Add command to output
    this._addOutputLine(command, 'command');
    
    // Clear input
    this.elements.inputEl.value = '';
    
    // Hide autocomplete if shown
    if (this._state.showAutocomplete) {
      this._hideAutocomplete();
    }
    
    // Reset history navigation
    this._state.historyIndex = -1;
    
    // Send command to server
    this._sendCommandToServer(command);
    
    // Scroll to bottom
    this._scrollToBottom();
  }
  
  /**
   * Send command to server
   * @param {string} command - Command to send
   * @private
   */
  _sendCommandToServer(command) {
    // If we're offline, process command locally via the offline handler
    if (this._state.isOffline) {
      document.dispatchEvent(new CustomEvent('terminal:processcommand', {
        detail: {
          terminalId: this.terminalId,
          command,
          timestamp: new Date().getTime()
        }
      }));
      return;
    }
    
    // Otherwise, send command to server via LiveView hook
    if (this.options.liveViewHook) {
      this.options.liveViewHook.pushEvent('terminal_command', {
        command,
        timestamp: new Date().getTime()
      });
    } else {
      console.error('No LiveView hook provided and terminal is online.');
    }
  }
  
  /**
   * Add command to history
   * @param {string} command - Command to add
   * @private
   */
  _addToCommandHistory(command) {
    // Don't add duplicate consecutive commands
    if (this._state.commandHistory.length > 0 &&
        this._state.commandHistory[0] === command) {
      return;
    }
    
    // Add to local history
    this._state.commandHistory.unshift(command);
    
    // Limit history size
    if (this._state.commandHistory.length > 100) {
      this._state.commandHistory.pop();
    }
    
    // Save to localStorage
    try {
      localStorage.setItem(
        `terminal_history_${this.terminalId}`,
        JSON.stringify(this._state.commandHistory)
      );
    } catch (e) {
      this.debug.log('Failed to save command history to localStorage:', e);
    }
  }
  
  /**
   * Load command history from localStorage
   * @private
   */
  _loadCommandHistory() {
    try {
      const historyJson = localStorage.getItem(`terminal_history_${this.terminalId}`);
      if (historyJson) {
        this._state.commandHistory = JSON.parse(historyJson);
      }
    } catch (e) {
      this.debug.log('Failed to load command history from localStorage:', e);
      this._state.commandHistory = [];
    }
  }
  
  /**
   * Navigate command history
   * @param {number} direction - Direction to navigate (-1 for up, 1 for down)
   * @private
   */
  _navigateHistory(direction) {
    if (this._state.commandHistory.length === 0) return;
    
    // Calculate new index
    const newIndex = this._state.historyIndex + direction;
    
    // Bounds check
    if (newIndex < -1 || newIndex >= this._state.commandHistory.length) return;
    
    // Update index
    this._state.historyIndex = newIndex;
    
    // Set input value
    if (newIndex === -1) {
      // Clear input when at beginning
      this.elements.inputEl.value = '';
    } else {
      this.elements.inputEl.value = this._state.commandHistory[newIndex];
    }
    
    // Move cursor to end
    setTimeout(() => {
      const length = this.elements.inputEl.value.length;
      this.elements.inputEl.setSelectionRange(length, length);
    }, 0);
  }
  
  /**
   * Toggle fullscreen mode
   */
  toggleFullscreen() {
    this._state.isFullscreen = !this._state.isFullscreen;
    
    if (this._state.isFullscreen) {
      this.elements.terminal.classList.add('terminal-fullscreen');
      document.body.classList.add('terminal-active-fullscreen');
    } else {
      this.elements.terminal.classList.remove('terminal-fullscreen');
      document.body.classList.remove('terminal-active-fullscreen');
    }
    
    // Focus input
    setTimeout(() => this.elements.inputEl.focus(), 50);
    
    // Dispatch event for other components
    this.elements.terminal.dispatchEvent(
      new CustomEvent('terminal:fullscreen-changed', {
        bubbles: true,
        detail: { isFullscreen: this._state.isFullscreen }
      })
    );
  }
  
  /**
   * Toggle minimize state
   */
  toggleMinimize() {
    this._state.isMinimized = !this._state.isMinimized;
    
    if (this._state.isMinimized) {
      this.elements.terminal.classList.add('terminal-minimized');
    } else {
      this.elements.terminal.classList.remove('terminal-minimized');
      
      // Focus input when restoring
      setTimeout(() => this.elements.inputEl.focus(), 50);
    }
    
    // Dispatch event for other components
    this.elements.terminal.dispatchEvent(
      new CustomEvent('terminal:minimize-changed', {
        bubbles: true,
        detail: { isMinimized: this._state.isMinimized }
      })
    );
  }
  
  /**
   * Handle terminal close
   * @private
   */
  _handleClose() {
    // Dispatch event for other components
    this.elements.terminal.dispatchEvent(
      new CustomEvent('terminal:closed', {
        bubbles: true
      })
    );
    
    // If we have a LiveView hook, let the server know
    if (this.options.liveViewHook) {
      this.options.liveViewHook.pushEvent('terminal_close', {});
    }
  }
  
  /**
   * Create autocomplete element
   * @private
   */
  _createAutocompleteElement() {
    this.elements.autocompleteEl = DOMCleanup.createElement('div', {
      className: 'terminal-autocomplete hidden',
      id: `${this.terminalId}-autocomplete`
    }, '', this.cleanup);
    
    this.elements.terminal.appendChild(this.elements.autocompleteEl);
  }
  
  /**
   * Show autocomplete dropdown
   * @param {Array} options - Autocomplete options
   * @private
   */
  _showAutocomplete(options) {
    // Store options
    this._state.autocompleteOptions = options;
    this._state.autocompleteIndex = -1;
    this._state.showAutocomplete = true;
    
    // Clear existing items
    this.elements.autocompleteEl.innerHTML = '';
    
    // Create list items
    options.forEach((option, index) => {
      const item = DOMCleanup.createElement('div', {
        className: 'terminal-autocomplete-item',
        'data-index': index
      }, option, this.cleanup);
      
      this.events.addEventListener(
        item,
        'click',
        () => this._selectAutocompleteOption(index)
      );
      
      this.elements.autocompleteEl.appendChild(item);
    });
    
    // Show dropdown
    this.elements.autocompleteEl.classList.remove('hidden');
    
    // Position dropdown
    this._positionAutocomplete();
  }
  
  /**
   * Hide autocomplete dropdown
   * @private
   */
  _hideAutocomplete() {
    this._state.showAutocomplete = false;
    this.elements.autocompleteEl.classList.add('hidden');
  }
  
  /**
   * Position autocomplete dropdown
   * @private
   */
  _positionAutocomplete() {
    // Get input position
    const inputRect = this.elements.inputEl.getBoundingClientRect();
    const terminalRect = this.elements.terminal.getBoundingClientRect();
    
    // Calculate position
    const top = inputRect.bottom - terminalRect.top;
    const left = inputRect.left - terminalRect.left;
    
    // Set position
    this.elements.autocompleteEl.style.top = `${top}px`;
    this.elements.autocompleteEl.style.left = `${left}px`;
    this.elements.autocompleteEl.style.minWidth = `${inputRect.width}px`;
  }
  
  /**
   * Handle tab completion
   * @private
   */
  _handleTabCompletion() {
    const input = this.elements.inputEl.value;
    
    // If autocomplete is already shown, cycle through options
    if (this._state.showAutocomplete) {
      this._cycleAutocompleteOptions(1);
      return;
    }
    
    // Otherwise, check for autocomplete options
    if (this.options.liveViewHook) {
      this.options.liveViewHook.pushEvent('terminal_autocomplete', {
        input,
        callback: (options) => {
          if (options && options.length > 0) {
            this._showAutocomplete(options);
          }
        }
      });
    }
  }
  
  /**
   * Cycle through autocomplete options
   * @param {number} direction - Direction to cycle (1 for forward, -1 for backward)
   * @private
   */
  _cycleAutocompleteOptions(direction) {
    if (this._state.autocompleteOptions.length === 0) return;
    
    // Calculate new index
    let newIndex = this._state.autocompleteIndex + direction;
    
    // Wrap around
    if (newIndex < 0) {
      newIndex = this._state.autocompleteOptions.length - 1;
    } else if (newIndex >= this._state.autocompleteOptions.length) {
      newIndex = 0;
    }
    
    // Update index
    this._state.autocompleteIndex = newIndex;
    
    // Update highlighted item
    const items = this.elements.autocompleteEl.querySelectorAll('.terminal-autocomplete-item');
    items.forEach((item, i) => {
      if (i === newIndex) {
        item.classList.add('selected');
      } else {
        item.classList.remove('selected');
      }
    });
  }
  
  /**
   * Select autocomplete option
   * @param {number} index - Option index
   * @private
   */
  _selectAutocompleteOption(index) {
    if (index < 0 || index >= this._state.autocompleteOptions.length) return;
    
    // Set input value
    this.elements.inputEl.value = this._state.autocompleteOptions[index];
    
    // Hide autocomplete
    this._hideAutocomplete();
    
    // Focus input
    this.elements.inputEl.focus();
    
    // Move cursor to end
    const length = this.elements.inputEl.value.length;
    this.elements.inputEl.setSelectionRange(length, length);
  }
  
  /**
   * Set up mutation observer for auto-scrolling
   * @private
   */
  _setupMutationObserver() {
    // Create mutation observer
    this._state.mutationObserver = new MutationObserver((mutations) => {
      this._scrollToBottom();
    });
    
    // Observe grid element for content changes
    if (this.elements.gridEl) {
      this._state.mutationObserver.observe(this.elements.gridEl, {
        childList: true,
        subtree: true,
        characterData: true
      });
    }
    
    // Register for cleanup
    this.cleanup.registerCleanupFunction(() => {
      if (this._state.mutationObserver) {
        this._state.mutationObserver.disconnect();
      }
    });
  }
  
  /**
   * Apply customizations to terminal
   * @private
   */
  _applyCustomizations() {
    // Apply font family
    if (this.elements.terminal && this.options.fontFamily) {
      this.elements.terminal.style.setProperty('--terminal-font-family', this.options.fontFamily);
    }
    
    // Apply cursor style
    if (this.elements.inputEl && this.options.cursorStyle) {
      switch (this.options.cursorStyle) {
        case 'block':
          this.elements.inputEl.style.caretShape = 'block';
          break;
        case 'bar':
          this.elements.inputEl.style.caretShape = 'bar';
          break;
        case 'underline':
          this.elements.inputEl.style.caretShape = 'underscore';
          break;
      }
    }
    
    // Apply highlight color
    if (this.elements.terminal && this.options.highlightColor) {
      this.elements.terminal.style.setProperty('--terminal-highlight-color', this.options.highlightColor);
    }
  }
  
  /**
   * Load user preferences from localStorage
   * @private
   */
  _loadUserPreferences() {
    try {
      const preferencesJson = localStorage.getItem(`terminal_preferences_${this.terminalId}`);
      if (preferencesJson) {
        const preferences = JSON.parse(preferencesJson);
        this._applyPreferences(preferences);
      }
    } catch (e) {
      this.debug.log('Failed to load user preferences from localStorage:', e);
    }
  }
  
  /**
   * Apply user preferences
   * @param {Object} preferences - User preferences object
   * @private
   */
  _applyPreferences(preferences) {
    if (!preferences) return;
    
    // Apply font family
    if (preferences.fontFamily) {
      this.options.fontFamily = preferences.fontFamily;
    }
    
    // Apply cursor style
    if (preferences.cursorStyle) {
      this.options.cursorStyle = preferences.cursorStyle;
    }
    
    // Apply highlight color
    if (preferences.highlightColor) {
      this.options.highlightColor = preferences.highlightColor;
    }
    
    // Apply customizations
    this._applyCustomizations();
  }
  
  /**
   * Update user preferences
   * @param {Object} preferences - User preferences object
   */
  updateUserPreferences(preferences) {
    // Apply preferences
    this._applyPreferences(preferences);
    
    // Save to localStorage
    try {
      localStorage.setItem(
        `terminal_preferences_${this.terminalId}`,
        JSON.stringify({
          fontFamily: this.options.fontFamily,
          cursorStyle: this.options.cursorStyle,
          highlightColor: this.options.highlightColor,
          ...preferences
        })
      );
    } catch (e) {
      this.debug.log('Failed to save user preferences to localStorage:', e);
    }
    
    // Notify server about preference change
    if (this.options.liveViewHook) {
      this.options.liveViewHook.pushEvent('terminal_preferences', {
        preferences: {
          fontFamily: this.options.fontFamily,
          cursorStyle: this.options.cursorStyle,
          highlightColor: this.options.highlightColor,
          ...preferences
        }
      });
    }
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const Terminal = {
  mounted() {
    this.component = new TerminalComponent({
      liveViewHook: this,
      container: this.el,
      terminalId: this.el.dataset.terminalId,
      fullscreenEnabled: this.el.dataset.fullscreen === 'true',
      fontFamily: this.el.dataset.fontFamily,
      cursorStyle: this.el.dataset.cursorStyle,
      highlightColor: this.el.dataset.highlightColor,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  updated() {
    // If already mounted, nothing to do
  },
  
  disconnected() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  },
  
  // Handle custom events from the server
  handleEvent(event, payload) {
    if (event === 'update_preferences' && this.component) {
      this.component.updateUserPreferences(payload);
    }
  }
};

export default Terminal;
export { TerminalComponent }; 