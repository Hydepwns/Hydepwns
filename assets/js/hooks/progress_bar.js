/**
 * Progress Bar Hook
 * ----------------
 * 
 * This hook has been migrated to use the robust component system.
 * It serves as a thin wrapper around the ProgressBarComponent.
 * 
 * @see ../components/progress_bar.js for the full implementation
 */
import { ProgressBarComponent } from '../components/progress_bar';

const ProgressBar = {
  mounted() {
    this.component = new ProgressBarComponent({
      liveViewHook: this,
      container: this.el,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
    
    // Make the progress bar component accessible via window for testing/debugging
    if (window.DEBUG && window.DEBUG.enabled) {
      window.progressBar = this.component;
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
    if (window.DEBUG && window.DEBUG.enabled && window.progressBar === this.component) {
      delete window.progressBar;
    }
  },
  
  handleEvent(event, payload) {
    // Events are handled in the component's _setupLiveViewHandlers method
  }
};

export default ProgressBar; 