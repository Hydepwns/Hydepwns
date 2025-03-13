/**
 * AsciiArtGenerator Hook
 * 
 * This hook has been migrated to use the robust component system.
 * It now serves as a thin wrapper around the AsciiArtGeneratorComponent.
 * 
 * @see ../components/ascii_art_generator.js for the full implementation
 */
import { AsciiArtGeneratorComponent } from '../components/ascii_art_generator';

const AsciiArtGenerator = {
  mounted() {
    this.component = new AsciiArtGeneratorComponent({
      liveViewHook: this,
      container: this.el,
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
  },
  
  updated() {
    if (this.component) {
      // If the component was updated via LiveView, we need to remount
      // to ensure we have the latest DOM references
      this.component.destroy();
      this.component = new AsciiArtGeneratorComponent({
        liveViewHook: this,
        container: this.el,
        debug: window.DEBUG && window.DEBUG.enabled
      }).mount();
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
    }
  }
};

export default AsciiArtGenerator; 