/**
 * Navigation Menu Hook
 * ------------------
 * Manages the navigation menu behavior including mobile responsiveness,
 * keyboard navigation, and active item highlighting.
 * 
 * This hook has been migrated to use the robust component system.
 * It now serves as a thin wrapper around the NavigationMenuComponent.
 * 
 * @see ../components/navigation_menu.js for the full implementation
 */

import { NavigationMenuComponent } from '../components/navigation_menu';

const NavigationMenu = {
  mounted() {
    // Get current path from data-attributes or location
    const currentPath = this.el.dataset.currentPath || window.location.pathname;
    
    this.component = new NavigationMenuComponent({
      liveViewHook: this,
      container: this.el,
      currentPath: currentPath,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  updated() {
    // Update current path if it changed
    if (this.el.dataset.currentPath && this.component) {
      this.component._syncActiveItem(this.el.dataset.currentPath);
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default NavigationMenu; 