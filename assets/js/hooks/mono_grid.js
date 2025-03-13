/**
 * MonoGrid
 * --------
 * LiveView hook for managing the monospace grid system.
 * 
 * Features:
 * - Debug mode with real-time grid dimensions
 * - Responsive adjustments for different screen sizes
 * - Maintains character alignment and spacing
 * - Supports keyboard navigation within grid cells
 */

import { MonoGridComponent } from '../components/mono_grid';

const MonoGrid = {
  mounted() {
    // Create and mount the MonoGridComponent
    this.component = new MonoGridComponent({
      liveViewHook: this,
      debug: this.el.hasAttribute('data-debug')
    }).mount();
  },
  
  updated() {
    // Update the component
    if (this.component) {
      this.component.update();
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

export default MonoGrid; 