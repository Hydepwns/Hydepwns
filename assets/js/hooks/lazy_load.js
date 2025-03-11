/**
 * LazyLoad Hook
 * -------------
 * This hook implements lazy loading for components that shouldn't be rendered
 * until they're close to being visible in the viewport.
 * 
 * It uses IntersectionObserver to efficiently track when elements are approaching
 * the viewport without causing layout calculations or affecting scroll performance.
 */

const LazyLoad = {
  mounted() {
    // Store references to DOM elements
    this.container = this.el;
    this.placeholderEl = this.el.querySelector('[data-lazy-placeholder]');
    this.contentEl = this.el.querySelector('[data-lazy-content]');
    
    // Check if content is already marked as loaded (skip_lazy was true)
    const isLoaded = this.el.dataset.loaded === 'true';
    
    if (isLoaded) {
      // Already loaded, no need for observer
      this.showContent();
      return;
    }
    
    // Get configuration options from data attributes
    const margin = this.el.dataset.margin || '100px';
    const threshold = parseFloat(this.el.dataset.threshold || 0.1);
    
    // Create and configure the IntersectionObserver
    this.observer = new IntersectionObserver(this.handleIntersection.bind(this), {
      rootMargin: margin,
      threshold: threshold
    });
    
    // Start observing this element
    this.observer.observe(this.container);
  },
  
  // Handle intersection events
  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        // Element is now visible (or approaching visibility)
        this.showContent();
        
        // Stop observing once content is loaded
        if (this.observer) {
          this.observer.disconnect();
          this.observer = null;
        }
      }
    });
  },
  
  // Show the actual content and hide placeholder
  showContent() {
    if (this.contentEl && this.placeholderEl) {
      // Show content
      this.contentEl.style.display = '';
      
      // Hide placeholder
      this.placeholderEl.style.display = 'none';
      
      // Mark as loaded
      this.container.dataset.loaded = 'true';
      
      // Emit a custom event that can be captured by parent components if needed
      const event = new CustomEvent('lazy-content-loaded', {
        bubbles: true,
        detail: { id: this.container.id }
      });
      this.container.dispatchEvent(event);
      
      // Announce to screen readers that content has loaded
      this.announceContentLoaded();
    }
  },
  
  // Announce content loaded for accessibility
  announceContentLoaded() {
    // Find the accessibility announcer if it exists
    const announcer = document.getElementById('accessibility-announcer');
    if (announcer) {
      announcer.textContent = 'Content loaded';
    }
  },
  
  // Clean up when the component is removed
  destroyed() {
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
  }
};

export default LazyLoad; 