/**
 * Terminal Theme Synchronization Hook
 * ----------------------------------
 * This hook synchronizes the terminal theme with the site theme
 * and ensures that theme changes are reflected in the terminal component.
 */

const TerminalThemeSync = {
  mounted() {
    // Store references to key elements
    this.terminal = document.querySelector(`#${this.el.getAttribute('data-terminal-id')}`);
    
    // Debug logging
    if (window.DEBUG) {
      window.DEBUG.log('TerminalThemeSync mounted - Terminal theme synchronization enabled');
      window.DEBUG.log('Terminal element found:', !!this.terminal);
    }
    
    // Listen for all theme change events
    window.addEventListener('theme-set', this.handleThemeChange.bind(this));
    window.addEventListener('theme-changed', this.handleThemeChange.bind(this));
    
    // Set initial theme with a slight delay to ensure component is fully mounted
    setTimeout(() => this.syncThemeWithSite(), 100);
  },
  
  disconnected() {
    // Clean up event listeners
    window.removeEventListener('theme-set', this.handleThemeChange.bind(this));
    window.removeEventListener('theme-changed', this.handleThemeChange.bind(this));
    
    if (window.DEBUG) {
      window.DEBUG.log('TerminalThemeSync disconnected - Theme sync cleanup completed');
    }
  },
  
  handleThemeChange(event) {
    if (window.DEBUG) {
      window.DEBUG.log('TerminalThemeSync: Theme change event received', event);
    }
    
    // Sync theme after a small delay to ensure the site theme has been updated
    setTimeout(() => this.syncThemeWithSite(), 50);
  },
  
  syncThemeWithSite() {
    // Determine current theme
    const html = document.documentElement;
    let currentTheme = '';
    
    if (html.classList.contains('light-theme') || html.getAttribute('data-theme') === 'light-theme') {
      currentTheme = 'light';
    } else if (html.classList.contains('dark-theme') || html.getAttribute('data-theme') === 'dark-theme') {
      currentTheme = 'dark';
    } else if (html.classList.contains('dim-theme') || html.getAttribute('data-theme') === 'dim-theme') {
      currentTheme = 'dim';
    } else if (html.classList.contains('high-contrast-theme') || html.getAttribute('data-theme') === 'high-contrast-theme') {
      currentTheme = 'high-contrast';
    } else if (html.classList.contains('synthwave-theme') || html.getAttribute('data-theme') === 'synthwave-theme') {
      currentTheme = 'synthwave';
    } else {
      // Default to dark theme if none is set
      currentTheme = 'dark';
    }
    
    if (window.DEBUG) {
      window.DEBUG.log('TerminalThemeSync: Current site theme detected as', currentTheme);
    }
    
    // Update terminal theme
    this.updateTerminalTheme(currentTheme);
  },
  
  updateTerminalTheme(theme) {
    if (!this.terminal) {
      if (window.DEBUG) {
        window.DEBUG.log('TerminalThemeSync: Cannot update theme - terminal element not found');
      }
      return;
    }
    
    if (window.DEBUG) {
      window.DEBUG.log('TerminalThemeSync: Updating terminal theme to', theme);
    }
    
    // If we have access to the LiveComponent, update it via push_event
    this.pushEvent('update_terminal_theme', { theme });
    
    // Also update classes directly for immediate visual feedback
    this.terminal.classList.remove(
      'terminal-theme-light', 
      'terminal-theme-dark', 
      'terminal-theme-dim', 
      'terminal-theme-high-contrast',
      'terminal-theme-synthwave'
    );
    this.terminal.classList.add(`terminal-theme-${theme}`);
    
    // Dispatch an event that can be listened to by other components
    this.terminal.dispatchEvent(new CustomEvent('terminal:theme-changed', {
      bubbles: true,
      detail: { theme }
    }));
    
    if (window.DEBUG) {
      window.DEBUG.log('TerminalThemeSync: Terminal theme updated to', theme);
    }
  }
};

export default TerminalThemeSync; 