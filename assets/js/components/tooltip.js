/**
 * Tooltip Component
 * ----------------
 * Displays a customizable tooltip when hovering over an element.
 * Supports different positions, animations, and can be controlled via JavaScript or LiveView events.
 * 
 * Built using the robust component system.
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class TooltipComponent {
  /**
   * Create a new Tooltip component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `tooltip-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: document.body,
      target: null, // Element to attach tooltip to
      content: '', // Tooltip content (string or HTML)
      position: 'top', // top, right, bottom, left
      offset: 8, // Distance from target in pixels
      showDelay: 200, // Delay before showing tooltip (ms)
      hideDelay: 200, // Delay before hiding tooltip (ms)
      theme: 'default', // default, dark, light
      maxWidth: '200px', // Maximum width of tooltip
      arrow: true, // Whether to show arrow
      interactive: false, // Whether tooltip is interactive (can be hovered)
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      ...options
    };
    
    // Component state (private)
    this._state = {
      isVisible: false,
      showTimeout: null,
      hideTimeout: null
    };
    
    // References to DOM elements
    this.elements = {
      container: null,
      target: null,
      tooltip: null,
      arrow: null
    };
    
    // Debug logger
    this.debug = {
      enabled: this.options.debug,
      log: (...args) => {
        if (this.debug.enabled) {
          console.log(`[Tooltip:${this.componentId}]`, ...args);
        }
      }
    };
  }
  
  /**
   * Initialize the tooltip component
   * @returns {TooltipComponent} The component instance
   */
  mount() {
    this.debug.log('Mounting tooltip component');
    
    // Get event manager for this component
    this.events = EventManager.registerComponent(this.componentId);
    
    // Get cleanup registry for this component
    this.cleanup = DOMCleanup.register(this.componentId);
    
    // Store reference to container
    this.elements.container = this.options.container;
    
    // Store reference to target
    this.elements.target = this.options.target;
    
    if (!this.elements.target) {
      console.error('Tooltip target element is required');
      return this;
    }
    
    // Build DOM structure
    this._buildDOM();
    
    // Set up event listeners
    this._setupEventListeners();
    
    // Set up LiveView handlers if needed
    if (this.options.liveViewHook) {
      this._setupLiveViewHandlers();
    }
    
    return this;
  }
  
  /**
   * Clean up the tooltip component
   */
  destroy() {
    this.debug.log('Destroying tooltip component');
    
    // Hide tooltip if visible
    this.hide();
    
    // Clear any pending timeouts
    if (this._state.showTimeout) {
      clearTimeout(this._state.showTimeout);
    }
    
    if (this._state.hideTimeout) {
      clearTimeout(this._state.hideTimeout);
    }
    
    // Clean up DOM elements and event listeners
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    // Unregister from event manager
    if (this.events) {
      EventManager.unregisterComponent(this.componentId);
    }
    
    // Clear references
    this.elements = {};
    this._state = {};
  }
  
  /**
   * Show the tooltip
   */
  show() {
    if (this._state.isVisible) return;
    
    // Clear any pending hide timeout
    if (this._state.hideTimeout) {
      clearTimeout(this._state.hideTimeout);
      this._state.hideTimeout = null;
    }
    
    // Set show timeout
    this._state.showTimeout = setTimeout(() => {
      this._state.isVisible = true;
      
      // Make tooltip visible
      if (this.elements.tooltip) {
        this.elements.tooltip.style.opacity = '1';
        this.elements.tooltip.style.visibility = 'visible';
        
        // Position the tooltip
        this._positionTooltip();
      }
      
      this._state.showTimeout = null;
    }, this.options.showDelay);
  }
  
  /**
   * Hide the tooltip
   */
  hide() {
    if (!this._state.isVisible) return;
    
    // Clear any pending show timeout
    if (this._state.showTimeout) {
      clearTimeout(this._state.showTimeout);
      this._state.showTimeout = null;
    }
    
    // Set hide timeout
    this._state.hideTimeout = setTimeout(() => {
      this._state.isVisible = false;
      
      // Hide tooltip
      if (this.elements.tooltip) {
        this.elements.tooltip.style.opacity = '0';
        this.elements.tooltip.style.visibility = 'hidden';
      }
      
      this._state.hideTimeout = null;
    }, this.options.hideDelay);
  }
  
  /**
   * Update tooltip content
   * @param {string} content - New tooltip content
   */
  updateContent(content) {
    this.options.content = content;
    
    if (this.elements.tooltip) {
      this.elements.tooltip.innerHTML = content;
      
      // If arrow is enabled, re-append it
      if (this.options.arrow && this.elements.arrow) {
        this.elements.tooltip.appendChild(this.elements.arrow);
      }
      
      // Reposition if visible
      if (this._state.isVisible) {
        this._positionTooltip();
      }
    }
  }
  
  /**
   * Build the tooltip DOM structure
   * @private
   */
  _buildDOM() {
    this.debug.log('Building tooltip DOM');
    
    // Create tooltip element
    this.elements.tooltip = DOMCleanup.createElement('div', {
      className: `tooltip tooltip-${this.options.theme} tooltip-${this.options.position}`,
      id: this.componentId,
      'data-component': 'tooltip',
      style: {
        position: 'absolute',
        maxWidth: this.options.maxWidth,
        zIndex: 'var(--z-index-tooltip, 9000)',
        opacity: '0',
        visibility: 'hidden',
        transition: 'opacity 0.2s, visibility 0.2s'
      }
    }, this.options.content, this.cleanup);
    
    // Create arrow if enabled
    if (this.options.arrow) {
      this.elements.arrow = DOMCleanup.createElement('div', {
        className: 'tooltip-arrow',
        style: {
          position: 'absolute',
          width: '8px',
          height: '8px',
          background: 'inherit',
          transform: 'rotate(45deg)'
        }
      }, '', this.cleanup);
      
      this.elements.tooltip.appendChild(this.elements.arrow);
    }
    
    // Add to container
    this.elements.container.appendChild(this.elements.tooltip);
  }
  
  /**
   * Set up event listeners
   * @private
   */
  _setupEventListeners() {
    this.debug.log('Setting up event listeners');
    
    // Mouse enter on target shows tooltip
    this.events.addEventListener(
      this.elements.target,
      'mouseenter',
      this.show.bind(this)
    );
    
    // Mouse leave on target hides tooltip
    this.events.addEventListener(
      this.elements.target,
      'mouseleave',
      this.hide.bind(this)
    );
    
    // If interactive, add listeners to tooltip itself
    if (this.options.interactive && this.elements.tooltip) {
      this.events.addEventListener(
        this.elements.tooltip,
        'mouseenter',
        this.show.bind(this)
      );
      
      this.events.addEventListener(
        this.elements.tooltip,
        'mouseleave',
        this.hide.bind(this)
      );
    }
    
    // Update position on scroll or resize
    this.events.addEventListener(
      window,
      'scroll',
      () => {
        if (this._state.isVisible) {
          this._positionTooltip();
        }
      }
    );
    
    this.events.addEventListener(
      window,
      'resize',
      () => {
        if (this._state.isVisible) {
          this._positionTooltip();
        }
      }
    );
  }
  
  /**
   * Position the tooltip relative to the target
   * @private
   */
  _positionTooltip() {
    if (!this.elements.tooltip || !this.elements.target) return;
    
    const targetRect = this.elements.target.getBoundingClientRect();
    const tooltipRect = this.elements.tooltip.getBoundingClientRect();
    const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    
    let top, left;
    
    // Position based on specified position
    switch (this.options.position) {
      case 'top':
        top = targetRect.top + scrollTop - tooltipRect.height - this.options.offset;
        left = targetRect.left + scrollLeft + (targetRect.width / 2) - (tooltipRect.width / 2);
        break;
      case 'right':
        top = targetRect.top + scrollTop + (targetRect.height / 2) - (tooltipRect.height / 2);
        left = targetRect.right + scrollLeft + this.options.offset;
        break;
      case 'bottom':
        top = targetRect.bottom + scrollTop + this.options.offset;
        left = targetRect.left + scrollLeft + (targetRect.width / 2) - (tooltipRect.width / 2);
        break;
      case 'left':
        top = targetRect.top + scrollTop + (targetRect.height / 2) - (tooltipRect.height / 2);
        left = targetRect.left + scrollLeft - tooltipRect.width - this.options.offset;
        break;
      default:
        top = targetRect.top + scrollTop - tooltipRect.height - this.options.offset;
        left = targetRect.left + scrollLeft + (targetRect.width / 2) - (tooltipRect.width / 2);
    }
    
    // Position the tooltip
    this.elements.tooltip.style.top = `${Math.round(top)}px`;
    this.elements.tooltip.style.left = `${Math.round(left)}px`;
    
    // Position the arrow if enabled
    if (this.options.arrow && this.elements.arrow) {
      let arrowTop, arrowLeft;
      
      switch (this.options.position) {
        case 'top':
          arrowTop = tooltipRect.height - 4;
          arrowLeft = (tooltipRect.width / 2) - 4;
          break;
        case 'right':
          arrowTop = (tooltipRect.height / 2) - 4;
          arrowLeft = -4;
          break;
        case 'bottom':
          arrowTop = -4;
          arrowLeft = (tooltipRect.width / 2) - 4;
          break;
        case 'left':
          arrowTop = (tooltipRect.height / 2) - 4;
          arrowLeft = tooltipRect.width - 4;
          break;
      }
      
      this.elements.arrow.style.top = `${arrowTop}px`;
      this.elements.arrow.style.left = `${arrowLeft}px`;
    }
  }
  
  /**
   * Set up LiveView event handlers
   * @private
   */
  _setupLiveViewHandlers() {
    this.debug.log('Setting up LiveView handlers');
    
    const hook = this.options.liveViewHook;
    
    // Handle LiveView events
    hook.handleEvent = (event, payload) => {
      switch (event) {
        case 'show_tooltip':
          this.show();
          break;
        case 'hide_tooltip':
          this.hide();
          break;
        case 'update_tooltip_content':
          if (payload && payload.content) {
            this.updateContent(payload.content);
          }
          break;
        default:
          this.debug.log(`Unknown event: ${event}`, payload);
      }
    };
  }
}

// Legacy LiveView hook for backward compatibility
const Tooltip = {
  mounted() {
    this.component = new TooltipComponent({
      liveViewHook: this,
      container: document.body,
      target: this.el,
      content: this.el.getAttribute('data-tooltip') || '',
      position: this.el.getAttribute('data-tooltip-position') || 'top',
      debug: window.DEBUG && window.DEBUG.enabled
    }).mount();
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
    }
  }
};

export default Tooltip;
export { TooltipComponent }; 