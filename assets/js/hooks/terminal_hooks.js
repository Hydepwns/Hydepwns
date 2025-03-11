const TerminalHooks = {
  Terminal: {
    mounted() {
      this.handleTerminalResize();
      this.handleFullScreenToggle();
      this.scrollToBottom();
      this.setupKeyboardEventListeners();
      this.setupPasteEventListener();
      this.setupClickFocusListener();
      
      // Save a reference to this hook for event handlers
      window.terminalHooks = window.terminalHooks || {};
      window.terminalHooks[this.el.id] = this;
    },
    
    updated() {
      this.scrollToBottom();
    },
    
    destroyed() {
      if (window.terminalHooks && window.terminalHooks[this.el.id]) {
        delete window.terminalHooks[this.el.id];
      }
    },
    
    scrollToBottom() {
      const content = this.el.querySelector('.terminal-content');
      if (content) {
        content.scrollTop = content.scrollHeight;
      }
    },
    
    handleTerminalResize() {
      // Implementation for terminal resize functionality
      // ...existing code...
    },
    
    handleFullScreenToggle() {
      // Implementation for fullscreen toggle functionality
      // ...existing code...
    },
    
    setupKeyboardEventListeners() {
      // Implementation for keyboard event listeners
      // ...existing code...
    },
    
    setupPasteEventListener() {
      // Setup paste event listener for the terminal
      this.el.addEventListener('paste', (event) => {
        const clipboardData = event.clipboardData || window.clipboardData;
        const pastedText = clipboardData.getData('text');
        
        if (pastedText && this.el) {
          // Prevent the default paste
          event.preventDefault();
          
          // Push the paste event to the server
          this.pushEvent('paste', { content: pastedText });
        }
      });
    },
    
    setupClickFocusListener() {
      // Focus the input when clicking anywhere in the terminal
      this.el.addEventListener('click', (event) => {
        const input = this.el.querySelector('.terminal-input');
        if (input && event.target !== input) {
          input.focus();
          
          // Set cursor position to end of input
          const len = input.value.length;
          input.setSelectionRange(len, len);
        }
      });
    }
  },
  
  TerminalLine: {
    mounted() {
      // When a new line is added, scroll the terminal to the bottom
      const terminalContent = this.el.closest('.terminal-content');
      if (terminalContent) {
        terminalContent.scrollTop = terminalContent.scrollHeight;
      }
    }
  }
};

export default TerminalHooks; 