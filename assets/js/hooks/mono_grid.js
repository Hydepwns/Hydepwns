/**
 * MonoGrid
 * --------
 * LiveView hook for managing the monospace grid system.
 * 
 * Features:
 * - Debug mode with real-time grid dimensions
 * - Responsive adjustments for different screen sizes
 * - Maintains character alignment and spacing
 * - Supports keyboard navigation within grid cells
 */

const MonoGrid = {
  mounted() {
    this.setupGrid();
    this.setupDebugMode();
    this.setupKeyboardNavigation();
    
    // Handle window resize events with debouncing
    this.resizeTimeout = null;
    window.addEventListener('resize', this.handleResize.bind(this));
  },
  
  updated() {
    this.updateDebugInfo();
  },
  
  destroyed() {
    window.removeEventListener('resize', this.handleResize.bind(this));
  },
  
  setupGrid() {
    // Get grid dimensions from data attributes or CSS variables
    this.cols = parseInt(this.el.dataset.cols) || 
                parseInt(getComputedStyle(this.el).getPropertyValue('--mono-grid-cols')) || 
                80;
    
    this.cellWidth = this.el.dataset.cellWidth || 
                     getComputedStyle(this.el).getPropertyValue('--mono-grid-cell-width') || 
                     '1ch';
    
    this.cellHeight = this.el.dataset.cellHeight || 
                      getComputedStyle(this.el).getPropertyValue('--mono-grid-cell-height') || 
                      '1.5rem';
    
    // Set CSS custom properties
    this.el.style.setProperty('--mono-grid-cols', this.cols);
    this.el.style.setProperty('--mono-grid-cell-width', this.cellWidth);
    this.el.style.setProperty('--mono-grid-cell-height', this.cellHeight);
  },
  
  setupDebugMode() {
    this.isDebugMode = this.el.classList.contains('mono-grid--debug');
    
    if (this.isDebugMode) {
      this.updateDebugInfo();
      
      // Add toggle button for debug grid
      const debugToggle = document.createElement('button');
      debugToggle.className = 'mono-grid-debug-toggle';
      debugToggle.setAttribute('aria-label', 'Toggle grid debug view');
      debugToggle.textContent = 'Grid';
      debugToggle.addEventListener('click', () => this.toggleDebugGrid());
      this.el.parentNode.insertBefore(debugToggle, this.el);
    }
  },
  
  updateDebugInfo() {
    if (!this.isDebugMode) return;
    
    // Calculate actual grid dimensions
    const gridWidth = this.el.clientWidth;
    const gridHeight = this.el.clientHeight;
    const charCount = Math.floor(gridWidth / parseFloat(getComputedStyle(document.documentElement).fontSize));
    
    // Update debug info attribute
    this.el.dataset.debugInfo = `${this.cols}×${Math.round(gridHeight / parseFloat(this.cellHeight))} grid | ${charCount} chars wide`;
  },
  
  toggleDebugGrid() {
    // Toggle grid visualization
    this.el.classList.toggle('mono-grid--debug-lines');
    
    // Find all cells and toggle their debug state
    const cells = this.el.querySelectorAll('.mono-grid-cell');
    cells.forEach(cell => cell.classList.toggle('mono-grid-cell--debug'));
    
    // Find all rows and toggle their debug state
    const rows = this.el.querySelectorAll('.mono-grid-row');
    rows.forEach(row => row.classList.toggle('mono-grid-row--debug'));
  },
  
  setupKeyboardNavigation() {
    // Find all focusable cells
    const focusableCells = this.el.querySelectorAll('.mono-grid-cell[tabindex="0"]');
    
    // Set up keyboard navigation between cells
    focusableCells.forEach(cell => {
      cell.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowRight' || e.key === 'ArrowDown' || 
            e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
          this.navigateGrid(cell, e.key);
          e.preventDefault();
        }
      });
    });
  },
  
  navigateGrid(currentCell, direction) {
    const cells = Array.from(this.el.querySelectorAll('.mono-grid-cell[tabindex="0"]'));
    const currentIndex = cells.indexOf(currentCell);
    
    if (currentIndex === -1) return;
    
    let targetIndex;
    
    switch (direction) {
      case 'ArrowRight':
        targetIndex = currentIndex + 1;
        break;
      case 'ArrowLeft':
        targetIndex = currentIndex - 1;
        break;
      case 'ArrowDown':
        // Find the cell below in the next row
        // This is a simplistic approach - a more precise one would use grid positions
        targetIndex = currentIndex + this.cols;
        break;
      case 'ArrowUp':
        // Find the cell above in the previous row
        targetIndex = currentIndex - this.cols;
        break;
    }
    
    // Check if target index is valid
    if (targetIndex >= 0 && targetIndex < cells.length) {
      cells[targetIndex].focus();
    }
  },
  
  handleResize() {
    // Debounce resize events
    clearTimeout(this.resizeTimeout);
    this.resizeTimeout = setTimeout(() => {
      this.updateDebugInfo();
      
      // Responsive adjustments if needed
      const viewportWidth = window.innerWidth;
      
      // Adjust grid for small screens if needed
      if (viewportWidth < 480) {
        // Smaller grid for mobile
        this.adjustForSmallScreen();
      } else if (viewportWidth < 768) {
        // Medium-sized grid for tablets
        this.adjustForMediumScreen();
      } else {
        // Reset to default for larger screens
        this.resetToDefaultGrid();
      }
    }, 100);
  },
  
  adjustForSmallScreen() {
    // Example: Reduce columns on small screens
    const newCols = Math.min(40, this.cols);
    this.el.style.setProperty('--mono-grid-cols', newCols);
  },
  
  adjustForMediumScreen() {
    // Example: Adjust for tablets
    const newCols = Math.min(60, this.cols);
    this.el.style.setProperty('--mono-grid-cols', newCols);
  },
  
  resetToDefaultGrid() {
    // Restore original column count
    this.el.style.setProperty('--mono-grid-cols', this.cols);
  }
};

export default MonoGrid; 