/**
 * Progress Indicator Hook
 * Provides interactive functionality for the monospace progress indicators.
 * 
 * Features:
 * - Handles animation of progress bars
 * - Manages spinner animations
 * - Updates progress values dynamically
 * - Implements accessibility features
 */

import { ProgressIndicatorComponent } from '../components/progress_indicator';

const ProgressIndicatorHook = {
  mounted() {
    // Create and mount the ProgressIndicatorComponent
    this.component = new ProgressIndicatorComponent({
      liveViewHook: this,
      debug: this.el.hasAttribute('data-debug')
    }).mount();
  },
  
  // Update progress value (can be called from LiveView)
  updateProgress(value, max) {
    if (this.component) {
      this.component.updateProgress(value, max);
    }
  },
  
  destroyed() {
    // Clean up the component
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default ProgressIndicatorHook; 