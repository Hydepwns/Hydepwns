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
 */

const Terminal = {
  mounted() {
    this.terminalId = this.el.dataset.terminalId;
    this.fullscreenEnabled = this.el.dataset.fullscreen === 'true';
    this.isFullscreen = false;
    this.isMinimized = false;
    
    // Set up main elements
    this.inputEl = this.el.querySelector(`#${this.terminalId}-input`);
    this.gridEl = this.el.querySelector(`#${this.terminalId}-grid`);
    
    // Load command history from localStorage
    this.loadCommandHistory();
    
    // Set up event listeners
    this.setupEventListeners();
    
    // Focus the input element
    setTimeout(() => this.inputEl.focus(), 100);
    
    // Set up mutation observer to scroll to bottom on content changes
    this.setupMutationObserver();
  },
  
  destroyed() {
    // Clean up event listeners
    this.cleanupEventListeners();
  },
  
  setupEventListeners() {
    // Terminal control events
    this.el.addEventListener('terminal:fullscreen', this.handleFullscreen.bind(this));
    this.el.addEventListener('terminal:minimize', this.handleMinimize.bind(this));
    this.el.addEventListener('terminal:close', this.handleClose.bind(this));
    
    // Input element focus event to ensure it stays focused when clicking inside the terminal
    this.gridEl.addEventListener('click', this.handleTerminalClick.bind(this));
    
    // Global keydown event for keyboard shortcuts
    this.keydownHandler = this.handleGlobalKeydown.bind(this);
    document.addEventListener('keydown', this.keydownHandler);
    
    // Command result handlers
    this.pushEventHandlers = {
      clear: this.handleClearCommand.bind(this),
      theme_change: this.handleThemeChange.bind(this),
      clear_history: this.handleClearHistory.bind(this)
    };
  },
  
  cleanupEventListeners() {
    this.el.removeEventListener('terminal:fullscreen', this.handleFullscreen);
    this.el.removeEventListener('terminal:minimize', this.handleMinimize);
    this.el.removeEventListener('terminal:close', this.handleClose);
    this.gridEl.removeEventListener('click', this.handleTerminalClick);
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
    // Remove all theme classes
    this.el.classList.remove(
      'terminal-theme-light',
      'terminal-theme-dark',
      'terminal-theme-dim',
      'terminal-theme-high-contrast'
    );
    
    // Add the new theme class
    this.el.classList.add(`terminal-theme-${theme}`);
  },
  
  handleClearHistory() {
    // Clear command history in localStorage
    this.saveCommandHistory([]);
  },
  
  // Utility functions
  scrollToBottom() {
    this.gridEl.scrollTop = this.gridEl.scrollHeight;
  }
};

export default Terminal; 