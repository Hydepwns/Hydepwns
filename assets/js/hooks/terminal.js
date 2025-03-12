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
 * - Offline support with command synchronization
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
    
    // Initialize offline support
    this.initializeOfflineSupport();
  },
  
  initializeOfflineSupport() {
    // Flag to track offline status
    this.isOffline = !navigator.onLine;
    
    // Listen for online/offline events from the TerminalOffline module
    document.addEventListener('terminal:online', this.handleOnlineEvent.bind(this));
    document.addEventListener('terminal:offline', this.handleOfflineEvent.bind(this));
    
    // Listen for command results from the offline handler
    document.addEventListener('terminal:commandresult', this.handleOfflineCommandResult.bind(this));
    
    // Listen for system messages from the offline handler
    document.addEventListener('terminal:addsystemmessage', this.handleSystemMessage.bind(this));
    
    // If currently offline, set offline UI state
    if (this.isOffline) {
      this.el.classList.add('terminal-offline');
    }
    
    console.log(`Terminal ${this.terminalId} initialized with offline support. Status: ${this.isOffline ? 'Offline' : 'Online'}`);
  },
  
  handleOnlineEvent() {
    this.isOffline = false;
    this.el.classList.remove('terminal-offline');
    
    // Update any UI elements for online state if needed
    console.log(`Terminal ${this.terminalId} is now online`);
  },
  
  handleOfflineEvent() {
    this.isOffline = true;
    this.el.classList.add('terminal-offline');
    
    // Update any UI elements for offline state if needed
    console.log(`Terminal ${this.terminalId} is now offline`);
  },
  
  handleOfflineCommandResult(event) {
    const { terminalId, result, offline } = event.detail;
    
    // Only process events for this terminal
    if (terminalId !== this.terminalId) return;
    
    console.log(`Received offline command result for terminal ${this.terminalId}:`, result);
    
    // Process the result similar to how normal commands are processed
    if (result.clear) {
      // Clear terminal output
      this.clearTerminalOutput();
    }
    
    // Add output lines
    if (result.output && result.output.length > 0) {
      for (const line of result.output) {
        this.addOutputLine(line.content, line.type, true);
      }
    }
    
    // Scroll to bottom
    this.scrollToBottom();
  },
  
  handleSystemMessage(event) {
    const { terminalId, message } = event.detail;
    
    // Only process events for this terminal
    if (terminalId !== this.terminalId) return;
    
    // Add message to output
    this.addOutputLine(message, 'system', true);
    
    // Scroll to bottom
    this.scrollToBottom();
  },
  
  clearTerminalOutput() {
    // Remove all output lines
    const outputLines = this.gridEl.querySelectorAll('.terminal-line');
    outputLines.forEach(line => line.remove());
  },
  
  addOutputLine(content, type = 'output', isOffline = false) {
    // Create new line element
    const line = document.createElement('div');
    line.className = `terminal-line terminal-line-${type}`;
    
    if (isOffline && this.isOffline) {
      line.classList.add('terminal-line-offline');
    }
    
    // Add type-specific content
    if (type === 'command') {
      const promptSpan = document.createElement('span');
      promptSpan.className = 'terminal-prompt';
      promptSpan.textContent = this.getPrompt();
      line.appendChild(promptSpan);
      line.appendChild(document.createTextNode(content));
    } else {
      line.textContent = content;
    }
    
    // Insert before the input line
    const inputLine = this.gridEl.querySelector('.terminal-input-line');
    this.gridEl.insertBefore(line, inputLine);
    
    return line;
  },
  
  scrollToBottom() {
    if (this.gridEl) {
      this.gridEl.scrollTop = this.gridEl.scrollHeight;
    }
  },
  
  getPrompt() {
    // Get prompt from the existing prompt element or use default
    const promptEl = this.el.querySelector('.terminal-prompt');
    return promptEl ? promptEl.textContent : '> ';
  },
  
  setupEventListeners() {
    // Process command submission
    this.inputEl.addEventListener('keydown', (event) => {
      if (event.key === 'Enter') {
        event.preventDefault();
        this.handleCommandSubmission();
      } else if (event.key === 'Tab') {
        event.preventDefault();
        this.handleTabCompletion();
      } else if (event.key === 'ArrowUp') {
        event.preventDefault();
        this.navigateHistory(-1);
      } else if (event.key === 'ArrowDown') {
        event.preventDefault();
        this.navigateHistory(1);
      } else if (event.key === 'Escape') {
        if (this.showAutocomplete) {
          this.hideAutocomplete();
        } else if (this.isFullscreen) {
          this.toggleFullscreen();
        }
      } else if (this.showAutocomplete && 
                (event.key === 'ArrowRight' || event.key === 'ArrowLeft')) {
        // Prevent cursor navigation when autocomplete is shown
        event.preventDefault();
      }
    });
    
    // Handle fullscreen toggle
    this.el.addEventListener('terminal:fullscreen', () => {
      if (this.fullscreenEnabled) {
        this.toggleFullscreen();
      }
    });
    
    // Handle minimize
    this.el.addEventListener('terminal:minimize', () => {
      this.toggleMinimize();
    });
    
    // Handle close
    this.el.addEventListener('terminal:close', () => {
      this.handleClose();
    });
    
    // Re-focus input when clicking anywhere in the terminal
    this.gridEl.addEventListener('click', (event) => {
      // Only focus if not selecting text
      if (window.getSelection().toString().length === 0) {
        this.inputEl.focus();
      }
    });
    
    // Prevent focus loss when clicking autocomplete
    if (this.autocompleteEl) {
      this.autocompleteEl.addEventListener('mousedown', (event) => {
        event.preventDefault();
      });
    }
  },
  
  handleCommandSubmission() {
    const command = this.inputEl.value.trim();
    
    if (command === '') return;
    
    // Add command to history
    this.addToHistory(command);
    
    // Add command to output
    this.addOutputLine(command, 'command');
    
    // Clear input
    this.inputEl.value = '';
    
    // Reset history navigation
    this.historyIndex = -1;
    
    // Hide autocomplete if visible
    if (this.showAutocomplete) {
      this.hideAutocomplete();
    }
    
    // Check if offline and dispatch event instead
    if (this.isOffline) {
      // Dispatch event for offline handler
      document.dispatchEvent(new CustomEvent('terminal:command', {
        detail: {
          terminalId: this.terminalId,
          command: command
        }
      }));
      return;
    }
    
    // Send command to server
    this.sendCommandToServer(command);
  },
  
  sendCommandToServer(command) {
    try {
      this.pushEvent('terminal_command', { command }, (result) => {
        if (result.error) {
          this.addOutputLine(`Error: ${result.error}`, 'error');
        } else if (result.output) {
          // Process output lines
          for (const line of result.output) {
            this.addOutputLine(line.content, line.type);
          }
        }
        
        // Add any supplementary output or handle special actions
        if (result.clear) {
          this.clearTerminalOutput();
        }
        
        // Scroll to bottom
        this.scrollToBottom();
      });
    } catch (error) {
      console.error('Failed to send command to server:', error);
      
      // If sending fails, maybe we've gone offline after the check
      this.addOutputLine(`Error: Failed to send command. You may be offline.`, 'error');
      this.scrollToBottom();
    }
  },
  
  // ... the rest of the Terminal hook code ...
  
  updateUserPreferences(preferences) {
    // Save preferences to localStorage
    const key = `terminal_preferences_${this.terminalId}`;
    try {
      localStorage.setItem(key, JSON.stringify(preferences));
      
      // Dispatch event for offline handler to cache preferences
      document.dispatchEvent(new CustomEvent('terminal:preferences:update', {
        detail: {
          terminalId: this.terminalId,
          preferences: preferences
        }
      }));
      
      // If online, send to server
      if (!this.isOffline) {
        this.pushEvent('terminal_preferences_update', { preferences });
      }
    } catch (error) {
      console.error('Failed to save preferences:', error);
    }
  },
  
  loadUserPreferences() {
    const key = `terminal_preferences_${this.terminalId}`;
    try {
      const savedPreferences = localStorage.getItem(key);
      if (savedPreferences) {
        const preferences = JSON.parse(savedPreferences);
        this.applyPreferences(preferences);
      }
    } catch (error) {
      console.error('Failed to load preferences:', error);
    }
  },
  
  applyPreferences(preferences) {
    // Apply font family
    if (preferences.fontFamily) {
      this.fontFamily = preferences.fontFamily;
    }
    
    // Apply cursor style
    if (preferences.cursorStyle) {
      this.cursorStyle = preferences.cursorStyle;
    }
    
    // Apply highlight color
    if (preferences.highlightColor) {
      this.highlightColor = preferences.highlightColor;
    }
    
    // Apply visual customizations
    this.applyCustomizations();
  },
  
  handleClose(event) {
    // Hide the terminal (implementation depends on your app requirements)
    this.el.classList.add('terminal-closed');
    
    // Optionally notify the parent component
    this.pushEvent('terminal_closed', {});
  }
};

export default Terminal; 