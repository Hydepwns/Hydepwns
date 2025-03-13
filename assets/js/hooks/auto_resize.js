/**
 * AutoResize Hook
 * --------------
 * 
 * This hook has been migrated to use the robust component system.
 * It now serves as a thin wrapper around the AutoResizeComponent.
 * 
 * @see ../components/auto_resize.js for the full implementation
 */
import { AutoResizeComponent } from '../components/auto_resize';

const AutoResize = {
  mounted() {
    this.component = new AutoResizeComponent({
      liveViewHook: this,
      container: this.el,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  updated() {
    if (this.component) {
      // Resize on content update
      this.component.resize();
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  },
  
  // Public method for manual resizing from parent components
  resize() {
    if (this.component) {
      this.component.resize();
    }
  }
};

export default AutoResize; 