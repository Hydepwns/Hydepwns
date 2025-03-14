/**
 * Tooltip Hook
 * ------------
 * 
 * This hook has been implemented using the robust component system.
 * It serves as a thin wrapper around the TooltipComponent.
 * 
 * @see ../components/tooltip.js for the full implementation
 */
import { TooltipComponent } from '../components/tooltip';

const Tooltip = {
  mounted() {
    this.component = new TooltipComponent({
      liveViewHook: this,
      container: document.body,
      target: this.el,
      content: this.el.getAttribute('data-tooltip') || '',
      position: this.el.getAttribute('data-tooltip-position') || 'top',
      theme: this.el.getAttribute('data-tooltip-theme') || 'default',
      interactive: this.el.hasAttribute('data-tooltip-interactive'),
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
    
    // Make the tooltip component accessible via window for testing/debugging
    if (window.DEBUG && window.DEBUG.enabled) {
      window.tooltips = window.tooltips || {};
      window.tooltips[this.el.id || this.component.componentId] = this.component;
    }
  },
  
  updated() {
    if (this.component) {
      // Update content if data-tooltip attribute changed
      const newContent = this.el.getAttribute('data-tooltip') || '';
      if (newContent !== this.component.options.content) {
        this.component.updateContent(newContent);
      }
      
      // Update position if data-tooltip-position attribute changed
      const newPosition = this.el.getAttribute('data-tooltip-position') || 'top';
      if (newPosition !== this.component.options.position) {
        this.component.options.position = newPosition;
        if (this.component._state.isVisible) {
          this.component._positionTooltip();
        }
      }
    }
  },
  
  destroyed() {
    if (this.component) {
      this.component.destroy();
      this.component = null;
      
      // Remove from global scope if it was added
      if (window.DEBUG && window.DEBUG.enabled && window.tooltips) {
        delete window.tooltips[this.el.id || this.component.componentId];
      }
    }
  },
  
  handleEvent(event, payload) {
    // Events are handled in the component's _setupLiveViewHandlers method
  }
};

export default Tooltip; 