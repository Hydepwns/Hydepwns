/**
 * Viewport Detector Hook
 * ---------------------
 * Detects viewport size changes and communicates them to the server.
 * Enables responsive design by tracking the current viewport size.
 */

const ViewportDetector = {
  mounted() {
    // Store initial values
    this.currentSize = this.getViewportSize();
    
    // Send initial viewport size to the server
    this.pushSize();
    
    // Listen for window resize events
    window.addEventListener('resize', this.handleResize.bind(this));
    
    // Debug logging if available
    if (window.DEBUG) {
      window.DEBUG.log('ViewportDetector mounted - Current size:', this.currentSize);
    }
  },
  
  disconnected() {
    // Clean up event listeners
    window.removeEventListener('resize', this.handleResize.bind(this));
  },
  
  handleResize() {
    // Throttle resize events for better performance
    if (this.resizeTimeout) {
      clearTimeout(this.resizeTimeout);
    }
    
    this.resizeTimeout = setTimeout(() => {
      const newSize = this.getViewportSize();
      
      // Only send update if the size category changed
      if (newSize !== this.currentSize) {
        this.currentSize = newSize;
        this.pushSize();
        
        if (window.DEBUG) {
          window.DEBUG.log('ViewportDetector - Size changed to:', this.currentSize);
        }
      }
    }, 250); // 250ms throttle
  },
  
  getViewportSize() {
    const width = window.innerWidth;
    
    // Define breakpoints for different device sizes
    if (width < 768) {
      return 'mobile';
    } else if (width < 1024) {
      return 'tablet';
    } else {
      return 'desktop';
    }
  },
  
  pushSize() {
    // Push event to the server with current viewport size
    this.pushEvent('update_viewport_size', { 
      size: this.currentSize,
      width: window.innerWidth,
      height: window.innerHeight
    });
    
    // Update CSS variable for use in styling
    document.documentElement.style.setProperty('--viewport-size', `"${this.currentSize}"`);
    
    // Add class to body for CSS targeting
    document.body.classList.remove('viewport-mobile', 'viewport-tablet', 'viewport-desktop');
    document.body.classList.add(`viewport-${this.currentSize}`);
  }
};

export default ViewportDetector; 