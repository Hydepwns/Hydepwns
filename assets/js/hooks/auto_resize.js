/**
 * AutoResize Hook
 * --------------
 * A simple hook that automatically resizes textareas to fit their content.
 * This ensures that users can see the full text without scrolling.
 */

const AutoResize = {
  mounted() {
    // Set initial size on mount
    this.resize();
    
    // Re-measure on input
    this.el.addEventListener('input', () => this.resize());
  },
  
  resize() {
    // Save current scroll position
    const scrollTop = this.el.scrollTop;
    
    // Reset height to auto to get natural scrollHeight
    this.el.style.height = 'auto';
    
    // Set the height to scrollHeight + a bit of padding
    this.el.style.height = (this.el.scrollHeight + 5) + 'px';
    
    // Restore scroll position
    this.el.scrollTop = scrollTop;
  }
};

export default AutoResize; 