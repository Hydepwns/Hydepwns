/**
 * Debug Grid Toggle Hook
 * Connects the UI toggle button to the debug grid functionality
 * 
 * This hook has been updated to use the class-based DebugGridToggleComponent
 */
import { DebugGridToggleComponent } from '../components/debug_grid_toggle';

const DebugGridToggle = {
  mounted() {
    this.component = new DebugGridToggleComponent({
      container: this.el,
      liveViewHook: this
    }).mount();
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default DebugGridToggle; 