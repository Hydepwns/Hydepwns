/**
 * Toast Hook
 * ----------
 * 
 * This hook has been migrated to use the robust component system.
 * It serves as a thin wrapper around the ToastComponent.
 * 
 * @see ../components/toast.js for the full implementation
 */
import { ToastComponent } from '../components/toast';

const Toast = {
  mounted() {
    this.component = new ToastComponent({
      liveViewHook: this,
      container: this.el,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
    
    // Make the toast component accessible via window for testing/debugging
    if (window.DEBUG && window.DEBUG.enabled) {
      window.toast = this.component;
    }
  },
  
  updated() {
    // Handle updates if necessary
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
    
    // Remove from global scope if it was added
    if (window.DEBUG && window.DEBUG.enabled && window.toast === this.component) {
      delete window.toast;
    }
  },
  
  handleEvent(event, payload) {
    if (event === "show_toast" && this.component) {
      this.component.show(payload);
    }
  }
};

export default Toast; 