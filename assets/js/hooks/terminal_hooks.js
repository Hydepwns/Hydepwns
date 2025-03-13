/**
 * Terminal Hooks
 * -------------
 * Provides additional terminal functionality.
 * 
 * This hook has been migrated to use the robust component system.
 * It now serves as a thin wrapper around the TerminalHooksComponent.
 * 
 * @see ../components/terminal_hooks.js for the full implementation
 */

import { TerminalHooksComponent, TerminalLineComponent } from '../components/terminal_hooks';

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
    },
    
    setupKeyboardEventListeners() {
      // Handled by component
    },
    
    setupPasteEventListener() {
      // Handled by component
    },
    
    setupClickFocusListener() {
      // Handled by component
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