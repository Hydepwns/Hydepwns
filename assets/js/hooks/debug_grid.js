/**
 * Debug Grid Hook
 * Shows a visual grid for monospace layout debugging
 * Uses CSS grid visualizer to show character and line boundaries
 */
const DebugGrid = {
  mounted() {
    this.bodyElement = document.body;
    this.debugEnabled = false;
    
    // Add event listener to handle debug key press
    document.addEventListener('keydown', this.handleKeyPress.bind(this));
    
    // Handle window resize events to recalculate grid size
    window.addEventListener('phx:resize', this.updateGridSizing.bind(this));
    
    this.updateGridSizing();
  },
  
  /**
   * Handle keyboard shortcut to toggle debug grid
   * Uses Alt+G as the keyboard shortcut
   */
  handleKeyPress(event) {
    // Use Alt+G as a keyboard shortcut to toggle debug grid
    if (event.altKey && event.key === 'g') {
      this.toggleDebugGrid();
      event.preventDefault();
    }
  },
  
  /**
   * Toggle the debug grid visibility
   */
  toggleDebugGrid() {
    this.debugEnabled = !this.debugEnabled;
    
    if (this.debugEnabled) {
      this.bodyElement.classList.add('debug-grid');
      this.showDebugNotification('Debug grid enabled. Press Alt+G to disable.');
    } else {
      this.bodyElement.classList.remove('debug-grid');
      this.showDebugNotification('Debug grid disabled.');
    }
  },
  
  /**
   * Show a temporary notification about debug grid state
   */
  showDebugNotification(message) {
    // Create or reuse notification element
    let notification = document.getElementById('debug-notification');
    if (!notification) {
      notification = document.createElement('div');
      notification.id = 'debug-notification';
      notification.style.position = 'fixed';
      notification.style.bottom = '20px';
      notification.style.right = '20px';
      notification.style.padding = '10px';
      notification.style.backgroundColor = 'rgba(0, 0, 0, 0.8)';
      notification.style.color = 'white';
      notification.style.borderRadius = '4px';
      notification.style.zIndex = '9999';
      notification.style.transition = 'opacity 0.3s';
      document.body.appendChild(notification);
    }
    
    // Set message and ensure it's visible
    notification.textContent = message;
    notification.style.opacity = '1';
    
    // Hide after a delay
    setTimeout(() => {
      notification.style.opacity = '0';
    }, 3000);
  },
  
  /**
   * Update grid sizing based on current font metrics
   * Recalculates when window is resized
   */
  updateGridSizing() {
    if (!this.debugEnabled) return;
    
    const root = document.documentElement;
    const computedStyle = getComputedStyle(root);
    
    // Get font metrics
    const fontSizeInPx = parseFloat(computedStyle.fontSize);
    const lineHeightInRem = parseFloat(computedStyle.getPropertyValue('--line-height'));
    const lineHeightInPx = lineHeightInRem * fontSizeInPx;
    
    // Set CSS variables to adjust the grid
    root.style.setProperty('--debug-grid-cell-width', '1ch');
    root.style.setProperty('--debug-grid-cell-height', `${lineHeightInPx}px`);
    
    console.log('Debug grid updated:', {
      fontSizeInPx,
      lineHeightInRem,
      lineHeightInPx
    });
  },
  
  /**
   * Clean up event listeners when element is destroyed
   */
  destroyed() {
    document.removeEventListener('keydown', this.handleKeyPress.bind(this));
    window.removeEventListener('phx:resize', this.updateGridSizing.bind(this));
  }
};

export default DebugGrid; 