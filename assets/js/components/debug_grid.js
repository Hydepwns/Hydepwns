/**
 * Debug Grid Component
 * Provides a grid overlay to help align elements to the monospace grid
 */

const DebugGrid = {
  mounted() {
    // Cache DOM elements and state
    this.grid = document.querySelector('.debug-grid');
    this.enableDebug = localStorage.getItem('debugGrid') === 'true';
    this.el.checked = this.enableDebug;
    
    // Initialize debug mode
    this.setDebugMode(this.enableDebug);
    
    // Set up event listener for toggle changes
    this.el.addEventListener('change', () => {
      this.enableDebug = this.el.checked;
      localStorage.setItem('debugGrid', this.enableDebug);
      this.setDebugMode(this.enableDebug);
    });
  },
  
  // Helper method to set debug mode
  setDebugMode(enabled) {
    document.body.classList.toggle('debug', enabled);
    this.grid.style.display = enabled ? 'block' : 'none';
    
    if (enabled) {
      this.highlightMisalignedElements();
    } else {
      document.querySelectorAll('.off-grid').forEach(el => {
        el.classList.remove('off-grid');
      });
    }
  },
  
  // Helper method to highlight elements that might be misaligned
  highlightMisalignedElements() {
    // Cache CSS variables for performance
    const charWidth = parseFloat(getComputedStyle(document.documentElement).fontSize);
    const lineHeight = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height'));
    
    // Use requestAnimationFrame to avoid layout thrashing
    requestAnimationFrame(() => {
      document.querySelectorAll('*').forEach(el => {
        const rect = el.getBoundingClientRect();
        const isOffGridX = rect.width % charWidth !== 0;
        const isOffGridY = rect.height % lineHeight !== 0;
        
        if (isOffGridX || isOffGridY) {
          el.classList.add('off-grid');
        } else {
          el.classList.remove('off-grid');
        }
      });
    });
  }
};

export default DebugGrid; 