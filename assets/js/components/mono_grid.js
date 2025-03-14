/**
 * MonoGridComponent
 * ----------------
 * Component for managing the monospace grid system.
 * 
 * Features:
 * - Debug mode with real-time grid dimensions
 * - Responsive adjustments for different screen sizes
 * - Maintains character alignment and spacing
 * - Supports keyboard navigation within grid cells
 */

import EventManager from './event_manager';
import DOMCleanup from '../utils/dom_cleanup';

class MonoGridComponent {
  /**
   * Create a new MonoGrid component
   * @param {Object} options - Configuration options
   */
  constructor(options = {}) {
    // Generate unique component ID
    this.componentId = `mono-grid-${Math.random().toString(36).substring(2, 9)}`;
    
    // Default options merged with user-provided options
    this.options = {
      container: null, // Container element (usually this.el from LiveView hook)
      liveViewHook: null, // LiveView hook instance if used in a hook
      debug: false,
      cols: 80, // Default column count
      cellWidth: '1ch', // Default cell width
      cellHeight: '1.5rem', // Default cell height
      ...options
    };
    
    // Component state (private)
    this._state = {
      isDebugMode: false,
      originalCols: this.options.cols, // Store original column count for responsive resets
    };
    
    // DOM element references
    this.elements = {
      container: null,
      debugToggle: null,
      focusableCells: []
    };
    
    // Timers and lifecycle flags
    this.resizeTimeout = null;
    
    // Debug logging
    this.debug = {
      log: (...args) => {
        if (this.options.debug || (window.DEBUG && window.DEBUG.enabled)) {
          console.log(`[MonoGrid:${this.componentId}]`, ...args);
        }
      }
    };
  }
  
  /**
   * Initialize the component and mount it to the DOM
   * @returns {this} - For method chaining
   */
  mount() {
    // Get event manager for this component
    this.events = EventManager.registerComponent(this.componentId);
    
    // Get cleanup registry for this component
    this.cleanup = DOMCleanup.register(this.componentId);
    
    // Store container reference
    this.elements.container = this.options.container || this.options.liveViewHook?.el;
    
    if (!this.elements.container) {
      console.error('MonoGrid component requires a container element');
      return this;
    }
    
    // Initialize the grid
    this._setupGrid();
    
    // Initialize debug mode if applicable
    this._setupDebugMode();
    
    // Setup keyboard navigation
    this._setupKeyboardNavigation();
    
    // Set up resize handler
    this.events.addEventListener(
      window,
      'resize',
      this._handleResize.bind(this)
    );
    
    this.debug.log('Component mounted');
    
    return this;
  }
  
  /**
   * Update the component (similar to updated() hook in LiveView)
   * @returns {this} - For method chaining
   */
  update() {
    this._updateDebugInfo();
    return this;
  }
  
  /**
   * Remove the component from the DOM and clean up resources
   */
  destroy() {
    this.debug.log('Destroying component');
    
    // Clean up DOM elements and event listeners
    if (this.cleanup) {
      this.cleanup.cleanup();
    }
    
    // Unregister from event manager
    if (this.events) {
      EventManager.unregisterComponent(this.componentId);
    }
    
    // Clear timeouts
    if (this.resizeTimeout) {
      clearTimeout(this.resizeTimeout);
    }
    
    // Clear references
    this.elements = {};
    this._state = {};
  }
  
  /**
   * Set up initial grid configuration
   * @private
   */
  _setupGrid() {
    const el = this.elements.container;
    
    // Get grid dimensions from data attributes, options, or CSS variables
    const cols = parseInt(el.dataset.cols) || 
                this.options.cols || 
                parseInt(getComputedStyle(el).getPropertyValue('--mono-grid-cols')) || 
                80;
    
    const cellWidth = el.dataset.cellWidth || 
                     this.options.cellWidth || 
                     getComputedStyle(el).getPropertyValue('--mono-grid-cell-width') || 
                     '1ch';
    
    const cellHeight = el.dataset.cellHeight || 
                      this.options.cellHeight || 
                      getComputedStyle(el).getPropertyValue('--mono-grid-cell-height') || 
                      '1.5rem';
    
    // Store values in state
    this._state.originalCols = cols;
    
    // Set CSS custom properties
    el.style.setProperty('--mono-grid-cols', cols);
    el.style.setProperty('--mono-grid-cell-width', cellWidth);
    el.style.setProperty('--mono-grid-cell-height', cellHeight);
    
    this.debug.log('Grid setup complete', { cols, cellWidth, cellHeight });
  }
  
  /**
   * Set up debug mode if enabled
   * @private
   */
  _setupDebugMode() {
    const el = this.elements.container;
    
    this._state.isDebugMode = el.classList.contains('mono-grid--debug');
    
    if (this._state.isDebugMode) {
      this._updateDebugInfo();
      
      // Add toggle button for debug grid
      const debugToggle = document.createElement('button');
      debugToggle.className = 'mono-grid-debug-toggle';
      debugToggle.setAttribute('aria-label', 'Toggle grid debug view');
      debugToggle.textContent = 'Grid';
      
      // Add to cleanup
      this.cleanup.addNode(debugToggle);
      
      // Add event listener
      this.events.addEventListener(
        debugToggle,
        'click',
        () => this.toggleDebugGrid()
      );
      
      // Insert into DOM
      el.parentNode.insertBefore(debugToggle, el);
      
      // Store reference
      this.elements.debugToggle = debugToggle;
    }
  }
  
  /**
   * Update debug information display
   * @private
   */
  _updateDebugInfo() {
    if (!this._state.isDebugMode) return;
    
    const el = this.elements.container;
    
    // Calculate actual grid dimensions
    const gridWidth = el.clientWidth;
    const gridHeight = el.clientHeight;
    const charCount = Math.floor(gridWidth / parseFloat(getComputedStyle(document.documentElement).fontSize));
    
    // Get current cell height
    const cellHeight = getComputedStyle(el).getPropertyValue('--mono-grid-cell-height') || this.options.cellHeight;
    
    // Calculate rows
    const rows = Math.round(gridHeight / parseFloat(cellHeight));
    
    // Get current columns
    const cols = parseInt(getComputedStyle(el).getPropertyValue('--mono-grid-cols')) || this._state.originalCols;
    
    // Update debug info attribute
    el.dataset.debugInfo = `${cols}×${rows} grid | ${charCount} chars wide`;
    
    this.debug.log('Debug info updated', { cols, rows, charCount });
  }
  
  /**
   * Toggle debug grid visualization
   * @returns {this} - For method chaining
   */
  toggleDebugGrid() {
    const el = this.elements.container;
    
    // Toggle grid visualization
    el.classList.toggle('mono-grid--debug-lines');
    
    // Find all cells and toggle their debug state
    const cells = el.querySelectorAll('.mono-grid-cell');
    cells.forEach(cell => cell.classList.toggle('mono-grid-cell--debug'));
    
    // Find all rows and toggle their debug state
    const rows = el.querySelectorAll('.mono-grid-row');
    rows.forEach(row => row.classList.toggle('mono-grid-row--debug'));
    
    this.debug.log('Debug grid toggled');
    
    return this;
  }
  
  /**
   * Set up keyboard navigation between grid cells
   * @private
   */
  _setupKeyboardNavigation() {
    const el = this.elements.container;
    
    // Find all focusable cells
    const focusableCells = el.querySelectorAll('.mono-grid-cell[tabindex="0"]');
    this.elements.focusableCells = Array.from(focusableCells);
    
    // Set up keyboard navigation between cells
    focusableCells.forEach(cell => {
      this.events.addEventListener(
        cell,
        'keydown',
        (e) => {
          if (e.key === 'ArrowRight' || e.key === 'ArrowDown' || 
              e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
            this._navigateGrid(cell, e.key);
            e.preventDefault();
          }
        }
      );
    });
    
    this.debug.log('Keyboard navigation setup complete', { cellCount: focusableCells.length });
  }
  
  /**
   * Handle grid navigation via keyboard
   * @param {HTMLElement} currentCell - Current focused cell
   * @param {string} direction - Navigation direction (ArrowRight, ArrowLeft, ArrowDown, ArrowUp)
   * @private
   */
  _navigateGrid(currentCell, direction) {
    const cells = this.elements.focusableCells;
    const currentIndex = cells.indexOf(currentCell);
    
    if (currentIndex === -1) return;
    
    let targetIndex;
    
    // Get current columns
    const cols = parseInt(getComputedStyle(this.elements.container).getPropertyValue('--mono-grid-cols')) || 
                this._state.originalCols;
    
    switch (direction) {
      case 'ArrowRight':
        targetIndex = currentIndex + 1;
        break;
      case 'ArrowLeft':
        targetIndex = currentIndex - 1;
        break;
      case 'ArrowDown':
        // Find the cell below in the next row
        targetIndex = currentIndex + cols;
        break;
      case 'ArrowUp':
        // Find the cell above in the previous row
        targetIndex = currentIndex - cols;
        break;
    }
    
    // Check if target index is valid
    if (targetIndex >= 0 && targetIndex < cells.length) {
      cells[targetIndex].focus();
      
      // Dispatch custom event for integrations
      const event = new CustomEvent('monoGridNavigation', {
        detail: {
          componentId: this.componentId,
          direction,
          fromIndex: currentIndex,
          toIndex: targetIndex,
          fromCell: currentCell,
          toCell: cells[targetIndex]
        },
        bubbles: true
      });
      
      this.elements.container.dispatchEvent(event);
    }
  }
  
  /**
   * Handle window resize with debouncing
   * @private
   */
  _handleResize() {
    // Debounce resize events
    clearTimeout(this.resizeTimeout);
    
    this.resizeTimeout = setTimeout(() => {
      this._updateDebugInfo();
      
      // Responsive adjustments based on viewport width
      const viewportWidth = window.innerWidth;
      
      // Adjust grid for small screens if needed
      if (viewportWidth < 480) {
        // Smaller grid for mobile
        this._adjustForSmallScreen();
      } else if (viewportWidth < 768) {
        // Medium-sized grid for tablets
        this._adjustForMediumScreen();
      } else {
        // Reset to default for larger screens
        this._resetToDefaultGrid();
      }
      
      // Dispatch resize event
      const event = new CustomEvent('monoGridResize', {
        detail: {
          componentId: this.componentId,
          viewportWidth,
        },
        bubbles: true
      });
      
      this.elements.container.dispatchEvent(event);
      
    }, 100);
  }
  
  /**
   * Adjust grid for small screens
   * @private
   */
  _adjustForSmallScreen() {
    // Reduce columns on small screens
    const newCols = Math.min(40, this._state.originalCols);
    this.elements.container.style.setProperty('--mono-grid-cols', newCols);
    
    this.debug.log('Adjusted for small screen', { cols: newCols });
  }
  
  /**
   * Adjust grid for medium screens
   * @private
   */
  _adjustForMediumScreen() {
    // Adjust for tablets
    const newCols = Math.min(60, this._state.originalCols);
    this.elements.container.style.setProperty('--mono-grid-cols', newCols);
    
    this.debug.log('Adjusted for medium screen', { cols: newCols });
  }
  
  /**
   * Reset grid to default dimensions
   * @private
   */
  _resetToDefaultGrid() {
    // Restore original column count
    this.elements.container.style.setProperty('--mono-grid-cols', this._state.originalCols);
    
    this.debug.log('Reset to default grid', { cols: this._state.originalCols });
  }
}

/**
 * Legacy LiveView hook for backward compatibility
 */
const MonoGrid = {
  mounted() {
    this.component = new MonoGridComponent({
      liveViewHook: this,
      container: this.el,
      cols: parseInt(this.el.dataset.cols, 10) || 80,
      cellWidth: this.el.dataset.cellWidth || '1ch',
      cellHeight: this.el.dataset.cellHeight || '1.5rem',
      debug: window.DEBUG && window.DEBUG.enabled
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

export default MonoGrid;
export { MonoGridComponent }; 