/**
 * Terminal Hook
 * -------------
 * Hook for the interactive terminal component.
 * 
 * This hook has been migrated to use the robust component system.
 * It now serves as a thin wrapper around the TerminalComponent.
 * 
 * @see ../components/terminal.js for the full implementation
 */

import { TerminalComponent } from '../components/terminal';

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