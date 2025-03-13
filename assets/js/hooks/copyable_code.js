/**
 * CopyableCode Hook
 * ---------------------
 * Allows users to click on code blocks to copy the content to clipboard.
 * Shows a visual feedback when code is copied.
 * 
 * This hook now uses the new CopyableCodeComponent class.
 */

import { CopyableCodeComponent } from '../components/copyable_code';

const CopyableCode = {
  mounted() {
    // Create an instance of the new component class
    this.component = new CopyableCodeComponent({
      container: this.el,
      liveViewHook: this,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  destroyed() {
    // Clean up the component when the hook is destroyed
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default CopyableCode; 