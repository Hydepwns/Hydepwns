/**
 * LazyLoad Hook
 * -------------
 * This hook implements lazy loading for components that shouldn't be rendered
 * until they're close to being visible in the viewport.
 * 
 * This hook has been updated to use the class-based LazyLoadComponent
 * for better organization, isolation, and resource management.
 */

import { LazyLoadComponent } from '../components/lazy_load';

const LazyLoad = {
  mounted() {
    this.component = new LazyLoadComponent({
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

export default LazyLoad; 