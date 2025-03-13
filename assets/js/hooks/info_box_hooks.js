/**
 * Hooks for InfoBox component.
 * 
 * This hook has been updated to use the class-based InfoBoxComponent
 * for better organization, isolation, and resource management.
 */

import { InfoBoxComponent } from '../components/info_box';

const DismissibleInfoBox = {
  mounted() {
    this.component = new InfoBoxComponent({
      container: this.el,
      liveViewHook: this
    }).mount();
  },
  
  updated() {
    if (this.component) {
      this.component.update();
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export { DismissibleInfoBox }; 