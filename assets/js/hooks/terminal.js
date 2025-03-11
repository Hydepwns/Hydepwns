/**
 * Terminal Hook
 * -------------
 * Hook for the interactive terminal component.
 * 
 * Features:
 * - Command history management with localStorage persistence
 * - Keyboard navigation and shortcuts
 * - Terminal UI controls (fullscreen, minimize, close)
 * - Syntax highlighting for output
 * - Theme customization
 * - Command autocomplete functionality
 */

const Terminal = {
  mounted() {
    this.terminalId = this.el.dataset.terminalId;
    this.fullscreenEnabled = this.el.dataset.fullscreen === 'true';
    this.isFullscreen = false;
    this.isMinimized = false;
    
    // Get customization options from data attributes
    this.fontFamily = this.el.dataset.fontFamily || 'monospace';
    this.cursorStyle = this.el.dataset.cursorStyle || 'block';
    this.highlightColor = this.el.dataset.highlightColor || '#FF2E97';
    
    // Set up main elements
    this.inputEl = this.el.querySelector(`#${this.terminalId}-input`);
    this.gridEl = this.el.querySelector(`#${this.terminalId}-grid`);
    
    // Apply customization options to input element
    this.applyCustomizations();
    
    // Load command history from localStorage
    this.loadCommandHistory();
    
    // Initialize autocomplete state
    this.autocompleteOptions = [];
    this.autocompleteIndex = -1;
    this.showAutocomplete = false;
    this.autocompleteEl = null;
    
    // Create autocomplete popup element
    this.createAutocompleteElement();
    
    // Set up event listeners
    this.setupEventListeners();
    
    // Focus the input element
    setTimeout(() => this.inputEl.focus(), 100);
    
    // Set up mutation observer to scroll to bottom on content changes
    this.setupMutationObserver();
    
    // Load user preferences
    this.loadUserPreferences();
  },
  
  destroyed() {
    // Clean up event listeners
    this.cleanupEventListeners();
    
    // Clean up autocomplete element
    if (this.autocompleteEl && this.autocompleteEl.parentNode) {
      this.autocompleteEl.parentNode.removeChild(this.autocompleteEl);
    }
  },
  
  setupEventListeners() {
    // Terminal control events
    this.el.addEventListener('terminal:fullscreen', this.handleFullscreen.bind(this));
    this.el.addEventListener('terminal:minimize', this.handleMinimize.bind(this));
    this.el.addEventListener('terminal:close', this.handleClose.bind(this));
    
    // Input element focus event to ensure it stays focused when clicking inside the terminal
    this.gridEl.addEventListener('click', this.handleTerminalClick.bind(this));
    
    // Input event for autocomplete
    this.inputEl.addEventListener('input', this.handleInput.bind(this));
    
    // Global keydown event for keyboard shortcuts
    this.keydownHandler = this.handleGlobalKeydown.bind(this);
    document.addEventListener('keydown', this.keydownHandler);
    
    // Command result handlers
    this.pushEventHandlers = {
      clear: this.handleClearCommand.bind(this),
      theme_change: this.handleThemeChange.bind(this),
      preferences_changed: this.handlePreferencesChanged.bind(this),
      clear_history: this.handleClearHistory.bind(this),
      autocomplete_options: this.handleAutocompleteOptions.bind(this)
    };
  },
  
  cleanupEventListeners() {
    this.el.removeEventListener('terminal:fullscreen', this.handleFullscreen);
    this.el.removeEventListener('terminal:minimize', this.handleMinimize);
    this.el.removeEventListener('terminal:close', this.handleClose);
    this.gridEl.removeEventListener('click', this.handleTerminalClick);
    this.inputEl.removeEventListener('input', this.handleInput);
    document.removeEventListener('keydown', this.keydownHandler);
  },
  
  setupMutationObserver() {
    // Create a mutation observer to scroll to bottom when content changes
    this.observer = new MutationObserver((mutations) => {
      this.scrollToBottom();
    });
    
    // Start observing the terminal grid for changes
    this.observer.observe(this.gridEl, { 
      childList: true, 
      subtree: true,
      characterData: true 
    });
  },
  
  loadCommandHistory() {
    try {
      const historyJson = localStorage.getItem(`terminal_history_${this.terminalId}`);
      this.commandHistory = historyJson ? JSON.parse(historyJson) : [];
      
      // Send command history to the server component
      if (this.commandHistory.length > 0) {
        this.pushEvent("set_command_history", { history: this.commandHistory });
      }
    } catch (e) {
      console.error("Error loading command history:", e);
      this.commandHistory = [];
    }
  },
  
  saveCommandHistory(history) {
    try {
      localStorage.setItem(`terminal_history_${this.terminalId}`, JSON.stringify(history));
      this.commandHistory = history;
    } catch (e) {
      console.error("Error saving command history:", e);
    }
  },
  
  loadUserPreferences() {
    try {
      const prefsJson = localStorage.getItem(`terminal_prefs_${this.terminalId}`);
      if (prefsJson) {
        const prefs = JSON.parse(prefsJson);
        
        // Apply saved theme if available
        if (prefs.theme) {
          this.handleThemeChange(prefs.theme);
        }
        
        // Send preferences to server component
        this.pushEvent("set_user_preferences", { preferences: prefs });
      }
    } catch (e) {
      console.error("Error loading user preferences:", e);
    }
  },
  
  saveUserPreferences(prefs) {
    try {
      const currentPrefsJson = localStorage.getItem(`terminal_prefs_${this.terminalId}`);
      const currentPrefs = currentPrefsJson ? JSON.parse(currentPrefsJson) : {};
      const updatedPrefs = { ...currentPrefs, ...prefs };
      
      localStorage.setItem(`terminal_prefs_${this.terminalId}`, JSON.stringify(updatedPrefs));
      
      // Send updated preferences to server component
      this.pushEvent("set_user_preferences", { preferences: updatedPrefs });
      
      return updatedPrefs;
    } catch (e) {
      console.error("Error saving user preferences:", e);
      return null;
    }
  },
  
  // Handle command results from server
  handleEvent(event, payload) {
    // Handle special command results from the server
    if (event === 'command_result' && payload.result) {
      const { type, data } = payload.result;
      
      // Call the appropriate handler based on the result type
      if (type && this.pushEventHandlers[type]) {
        this.pushEventHandlers[type](data);
      }
      
      // If the command changes the history, update our local copy
      if (payload.history) {
        this.saveCommandHistory(payload.history);
      }
      
      // If the command updates user preferences, save them
      if (payload.preferences) {
        this.saveUserPreferences(payload.preferences);
      }
    }
  },
  
  // Handlers for terminal controls
  handleFullscreen(event) {
    if (!this.fullscreenEnabled) return;
    
    this.isFullscreen = !this.isFullscreen;
    
    if (this.isFullscreen) {
      this.el.classList.add('terminal-fullscreen');
      document.body.classList.add('terminal-open-fullscreen');
    } else {
      this.el.classList.remove('terminal-fullscreen');
      document.body.classList.remove('terminal-open-fullscreen');
    }
    
    // Focus the input after toggling fullscreen
    setTimeout(() => this.inputEl.focus(), 100);
  },
  
  handleMinimize(event) {
    this.isMinimized = !this.isMinimized;
    
    if (this.isMinimized) {
      this.el.classList.add('terminal-minimized');
    } else {
      this.el.classList.remove('terminal-minimized');
      // Focus the input when restoring from minimized state
      setTimeout(() => this.inputEl.focus(), 100);
    }
  },
  
  handleClose(event) {
    // Hide the terminal (implementation depends on your app requirements)
    this.el.classList.add('terminal-closed');
    
    // Optionally notify the parent component
    this.pushEvent('terminal_closed', {});
  },
  
  // Event handlers for terminal actions
  handleTerminalClick(event) {
    // Focus the input element when clicking anywhere in the terminal
    // (unless user is selecting text or clicking a button)
    if (window.getSelection().toString() === '' && 
        !event.target.closest('button') &&
        !event.target.closest('a')) {
      this.inputEl.focus();
    }
  },
  
  handleInput(event) {
    // Get current input value
    const input = this.inputEl.value;
    
    // If input is not empty, request autocomplete options
    if (input.trim() !== '') {
      this.pushEvent('terminal_autocomplete', { input });
    } else {
      this.hideAutocomplete();
    }
  },
  
  handleGlobalKeydown(event) {
    // Only handle shortcuts when terminal is active/focused
    if (!this.el.contains(document.activeElement)) return;
    
    // Handle keyboard shortcuts
    if (event.ctrlKey || event.metaKey) {
      switch (event.key) {
        case 'l':  // Clear terminal (Ctrl+L)
          event.preventDefault();
          this.pushEvent("terminal_command", { command: "clear" });
          break;
        case 'k':  // Clear line (Ctrl+K)
          event.preventDefault();
          this.inputEl.value = '';
          this.pushEvent("terminal_keyup", { key: "", target: { value: "" } });
          this.hideAutocomplete();
          break;
        case 'c':  // Copy (Ctrl+C)
          if (window.getSelection().toString() !== '') {
            // Let the browser handle the copy if text is selected
            return;
          }
          // Otherwise, handle interrupt or other terminal-specific behavior
          break;
      }
    } else {
      // Handle navigation keys
      switch (event.key) {
        case 'Tab':  // Tab for autocomplete
          if (this.showAutocomplete && this.autocompleteOptions.length > 0) {
            event.preventDefault();
            this.completeSelection();
          } else if (this.inputEl.value.trim() !== '') {
            event.preventDefault();
            this.pushEvent('terminal_autocomplete', { input: this.inputEl.value });
          }
          break;
        case 'ArrowUp':  // Navigate command history or autocomplete
          if (this.showAutocomplete && this.autocompleteOptions.length > 0) {
            event.preventDefault();
            this.navigateAutocomplete(-1);
          } else {
            // Let the LiveView component handle history navigation
          }
          break;
        case 'ArrowDown':  // Navigate command history or autocomplete
          if (this.showAutocomplete && this.autocompleteOptions.length > 0) {
            event.preventDefault();
            this.navigateAutocomplete(1);
          } else {
            // Let the LiveView component handle history navigation
          }
          break;
        case 'Escape':  // Close autocomplete
          if (this.showAutocomplete) {
            event.preventDefault();
            this.hideAutocomplete();
          }
          break;
        case 'Enter':  // Select autocomplete option or submit command
          if (this.showAutocomplete && this.autocompleteIndex >= 0) {
            event.preventDefault();
            this.completeSelection();
          } else {
            // Let the LiveView component handle command submission
            this.hideAutocomplete();
          }
          break;
      }
    }
  },
  
  // Command result handlers
  handleClearCommand() {
    // Clear the terminal output
    const outputLines = this.el.querySelectorAll('.terminal-line');
    outputLines.forEach(line => line.remove());
  },
  
  handleThemeChange(theme) {
    // Remove existing theme classes
    const themeClasses = [
      'terminal-theme-light',
      'terminal-theme-dark',
      'terminal-theme-dim',
      'terminal-theme-high-contrast',
      'terminal-theme-synthwave'
    ];
    
    themeClasses.forEach(cls => this.el.classList.remove(cls));
    
    // Add new theme class
    this.el.classList.add(`terminal-theme-${theme}`);
    
    // Save theme preference
    this.saveUserPreferences({ theme });
  },
  
  handlePreferencesChanged() {
    // Get the updated preferences from the server
    const preferences = this.pushEventPayload.preferences;
    
    if (preferences) {
      // Update our local references
      if (preferences.font_family) {
        this.fontFamily = preferences.font_family;
      }
      
      if (preferences.cursor_style) {
        this.cursorStyle = preferences.cursor_style;
      }
      
      if (preferences.highlight_color) {
        this.highlightColor = preferences.highlight_color;
      }
      
      // Apply the changes
      this.applyCustomizations();
      
      // Save the preferences
      this.saveUserPreferences(preferences);
    }
  },
  
  handleClearHistory() {
    // Clear command history in localStorage
    this.saveCommandHistory([]);
  },
  
  handleAutocompleteOptions(options) {
    if (!options || !Array.isArray(options) || options.length === 0) {
      this.hideAutocomplete();
      return;
    }
    
    this.autocompleteOptions = options;
    this.autocompleteIndex = 0; // Select first option by default
    this.showAutocomplete = true;
    
    this.updateAutocompleteDisplay();
  },
  
  // Autocomplete methods
  createAutocompleteElement() {
    // Create autocomplete popup if it doesn't exist
    if (!this.autocompleteEl) {
      this.autocompleteEl = document.createElement('div');
      this.autocompleteEl.className = 'terminal-autocomplete';
      this.autocompleteEl.setAttribute('role', 'listbox');
      this.autocompleteEl.setAttribute('aria-label', 'Command suggestions');
      this.el.appendChild(this.autocompleteEl);
      
      // Add click handler for selecting options
      this.autocompleteEl.addEventListener('click', (e) => {
        const option = e.target.closest('.terminal-autocomplete-option');
        if (option) {
          const index = parseInt(option.dataset.index, 10);
          if (!isNaN(index)) {
            this.autocompleteIndex = index;
            this.completeSelection();
          }
        }
      });
    }
  },
  
  updateAutocompleteDisplay() {
    if (!this.showAutocomplete || !this.autocompleteOptions.length) {
      this.hideAutocomplete();
      return;
    }
    
    // Update position based on input element
    const inputRect = this.inputEl.getBoundingClientRect();
    const containerRect = this.el.getBoundingClientRect();
    
    this.autocompleteEl.style.display = 'block';
    this.autocompleteEl.style.left = `${inputRect.left - containerRect.left}px`;
    this.autocompleteEl.style.top = `${inputRect.bottom - containerRect.top}px`;
    this.autocompleteEl.style.minWidth = `${inputRect.width}px`;
    
    // Generate option elements
    const optionsHtml = this.autocompleteOptions.map((option, index) => {
      const isSelected = index === this.autocompleteIndex;
      return `
        <div 
          class="terminal-autocomplete-option ${isSelected ? 'selected' : ''}" 
          data-index="${index}"
          role="option"
          aria-selected="${isSelected ? 'true' : 'false'}"
        >
          ${option}
        </div>
      `;
    }).join('');
    
    this.autocompleteEl.innerHTML = optionsHtml;
  },
  
  hideAutocomplete() {
    this.showAutocomplete = false;
    this.autocompleteOptions = [];
    this.autocompleteIndex = -1;
    
    if (this.autocompleteEl) {
      this.autocompleteEl.style.display = 'none';
    }
  },
  
  navigateAutocomplete(direction) {
    if (!this.showAutocomplete || this.autocompleteOptions.length === 0) return;
    
    // Calculate new index with wrapping
    let newIndex = this.autocompleteIndex + direction;
    
    if (newIndex < 0) {
      newIndex = this.autocompleteOptions.length - 1;
    } else if (newIndex >= this.autocompleteOptions.length) {
      newIndex = 0;
    }
    
    this.autocompleteIndex = newIndex;
    this.updateAutocompleteDisplay();
  },
  
  completeSelection() {
    if (!this.showAutocomplete || this.autocompleteIndex < 0 || this.autocompleteIndex >= this.autocompleteOptions.length) {
      return;
    }
    
    // Get the selected completion
    const completion = this.autocompleteOptions[this.autocompleteIndex];
    
    // Update input field
    this.inputEl.value = completion;
    
    // Move cursor to end of input
    this.inputEl.setSelectionRange(completion.length, completion.length);
    
    // Hide autocomplete
    this.hideAutocomplete();
    
    // Focus on input
    this.inputEl.focus();
  },
  
  // Utility functions
  scrollToBottom() {
    this.gridEl.scrollTop = this.gridEl.scrollHeight;
  },
  
  applyCustomizations() {
    // Apply font family
    this.el.style.setProperty('--terminal-font-family', this.fontFamily);
    
    // Apply highlight color
    this.el.style.setProperty('--terminal-highlight-color', this.highlightColor);
    
    // Apply cursor style by updating classes
    this.inputEl.classList.remove('cursor-style-block', 'cursor-style-underline', 'cursor-style-bar');
    this.inputEl.classList.add(`cursor-style-${this.cursorStyle}`);
    
    // Update data attributes
    this.el.dataset.fontFamily = this.fontFamily;
    this.el.dataset.cursorStyle = this.cursorStyle;
    this.el.dataset.highlightColor = this.highlightColor;
  }
};

export default Terminal; 