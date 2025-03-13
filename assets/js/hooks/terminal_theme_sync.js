/**
 * Terminal Theme Synchronization Hook
 * ----------------------------------
 * This hook synchronizes the terminal theme with the site theme
 * and ensures that theme changes are reflected in the terminal component.
 * 
 * This hook has been migrated to use the robust component system.
 * It now serves as a thin wrapper around the TerminalThemeSyncComponent.
 * 
 * @see ../components/terminal_theme_sync.js for the full implementation
 */

import { TerminalThemeSyncComponent } from '../components/terminal_theme_sync';

const TerminalThemeSync = {
  mounted() {
    this.component = new TerminalThemeSyncComponent({
      liveViewHook: this,
      container: this.el,
      terminalId: this.el.getAttribute('data-terminal-id'),
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

export default TerminalThemeSync; 