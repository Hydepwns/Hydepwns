/**
 * Accessibility Menu Toggle Hook
 * -----------------------------
 * Manages the accessibility menu dropdown behavior.
 * 
 * This hook has been migrated to use the robust component system.
 * It now serves as a thin wrapper around the AccessibilityMenuToggleComponent.
 * 
 * @see ../components/accessibility_menu_toggle.js for the full implementation
 */

import { AccessibilityMenuToggleComponent } from '../components/accessibility_menu_toggle';

const AccessibilityMenuToggle = {
  mounted() {
    this.component = new AccessibilityMenuToggleComponent({
      liveViewHook: this,
      container: this.el,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  disconnected() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default AccessibilityMenuToggle; 