/**
 * Hooks for MonoTabs component.
 * 
 * Provides client-side functionality for the tabbed interface, including
 * keyboard navigation, state persistence, and focus management.
 */

import { MonoTabsComponent } from '../components/mono_tabs';

const MonoTabs = {
  mounted() {
    // Create and mount the MonoTabsComponent
    this.component = new MonoTabsComponent({
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

export { MonoTabs }; 