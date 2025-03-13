/**
 * HierarchicalTOC Hook
 * 
 * This hook provides functionality for the hierarchical table of contents:
 * - Collapsing/expanding nested sections with toggles
 * - Section tracking as user scrolls the page (scroll spy)
 * - Keyboard navigation for accessibility
 * - Mobile-friendly interactions
 * 
 * This hook now uses the new HierarchicalTOCComponent class.
 */

import { HierarchicalTOCComponent } from '../components/hierarchical_toc';

const HierarchicalTOC = {
  mounted() {
    // Create an instance of the new component class
    this.component = new HierarchicalTOCComponent({
      container: this.el,
      liveViewHook: this,
      debug: window.hydepwnsDebug
    }).mount();
  },
  
  updated() {
    // Update the component when the hook is updated
    if (this.component) {
      this.component.update();
    }
  },
  
  disconnected() {
    // Clean up the component when the hook is disconnected
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default HierarchicalTOC; 