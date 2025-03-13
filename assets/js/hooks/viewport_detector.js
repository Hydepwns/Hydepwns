/**
 * Viewport Detector Hook
 * ---------------------
 * Detects viewport size changes and communicates them to the server.
 * Enables responsive design by tracking the current viewport size.
 * 
 * This hook now uses the new ViewportDetectorComponent class.
 */

import { ViewportDetectorComponent } from '../components/viewport_detector';

const ViewportDetector = {
  mounted() {
    // Create an instance of the new component class
    this.component = new ViewportDetectorComponent({
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

export default ViewportDetector; 