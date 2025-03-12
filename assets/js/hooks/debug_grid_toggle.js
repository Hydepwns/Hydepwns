/**
 * Debug Grid Toggle Hook
 * Connects the UI toggle button to the debug grid functionality
 */
import DebugGrid from './debug_grid';

const DebugGridToggle = {
  mounted() {
    this.debugGrid = window.debugGrid;
    
    // Initialize checkbox state from localStorage
    const savedState = localStorage.getItem('debugGridEnabled') === 'true';
    this.el.checked = savedState;
    
    // If grid was previously enabled, enable it on page load
    if (savedState && !this.debugGrid?.debugEnabled) {
      // Wait a moment for the DOM to be ready
      setTimeout(() => {
        DebugGrid.toggleDebugGrid();
      }, 200);
    }
    
    // Add event listener to toggle debug grid on checkbox change
    this.el.addEventListener('change', () => {
      const newState = DebugGrid.toggleDebugGrid();
      localStorage.setItem('debugGridEnabled', newState);
    });
  }
};

export default DebugGridToggle; 