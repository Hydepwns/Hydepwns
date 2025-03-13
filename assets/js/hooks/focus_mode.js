/**
 * Focus Mode Hook
 * --------------
 * Implements a keyboard-only focus mode that enhances navigation and interaction
 * for users who rely solely on keyboard input.
 * 
 * This hook now uses the new FocusModeComponent class.
 */

import { FocusModeComponent } from '../components/focus_mode';

const FocusMode = {
  mounted() {
    // Create an instance of the new component class
    this.component = new FocusModeComponent({
      liveViewHook: this,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  disconnected() {
    // Clean up the component when the hook is disconnected
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default FocusMode; 