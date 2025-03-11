/**
 * Timeline Hook
 * Provides interactive functionality for the monospace timeline component.
 * 
 * Features:
 * - Handles animation of timeline elements
 * - Supports keyboard navigation between timeline events
 * - Implements accessibility features
 * - Optimizes performance with IntersectionObserver
 */

const TimelineHook = {
  mounted() {
    // Check if user prefers reduced motion
    this.animationAllowed = !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    
    // Store reference to the element
    this.element = this.el;
    this.isVertical = this.element.classList.contains('vertical');
    
    // Set up event listeners
    this.setupEventListeners();
    
    // Set up intersection observer for performance optimization
    this.setupIntersectionObserver();
    
    // Initialize animation if allowed
    if (this.animationAllowed) {
      this.animateTimelineItems();
    }
    
    // Add keyboard navigation for accessibility
    this.setupKeyboardNavigation();
  },
  
  // Set up event listeners
  setupEventListeners() {
    // Listen for keyboard events to replay animations
    window.addEventListener('keydown', this.handleKeydown.bind(this));
    
    // Add click event listeners to timeline items
    const timelineItems = this.isVertical 
      ? this.element.querySelectorAll('.timeline-item')
      : this.element.querySelectorAll('.timeline-event');
      
    timelineItems.forEach((item, index) => {
      item.addEventListener('click', () => {
        this.focusTimelineItem(index);
      });
      
      // Set tabindex for keyboard accessibility
      item.setAttribute('tabindex', '0');
    });
  },
  
  // Handle keyboard events
  handleKeydown(event) {
    // Use Alt+R as keyboard shortcut to replay animations
    if (event.altKey && event.key === 'r') {
      this.replayAnimation();
      event.preventDefault();
    }
  },
  
  // Set up keyboard navigation
  setupKeyboardNavigation() {
    const timelineItems = this.isVertical 
      ? this.element.querySelectorAll('.timeline-item')
      : this.element.querySelectorAll('.timeline-event');
    
    timelineItems.forEach((item, index) => {
      item.addEventListener('keydown', (event) => {
        // Handle arrow key navigation
        if (this.isVertical) {
          // Vertical timeline: up/down navigation
          if (event.key === 'ArrowDown' && index < timelineItems.length - 1) {
            this.focusTimelineItem(index + 1);
            event.preventDefault();
          } else if (event.key === 'ArrowUp' && index > 0) {
            this.focusTimelineItem(index - 1);
            event.preventDefault();
          }
        } else {
          // Horizontal timeline: left/right navigation
          if (event.key === 'ArrowRight' && index < timelineItems.length - 1) {
            this.focusTimelineItem(index + 1);
            event.preventDefault();
          } else if (event.key === 'ArrowLeft' && index > 0) {
            this.focusTimelineItem(index - 1);
            event.preventDefault();
          }
        }
        
        // Handle Enter/Space to activate item
        if (event.key === 'Enter' || event.key === ' ') {
          // Trigger click event
          item.click();
          event.preventDefault();
        }
      });
    });
  },
  
  // Focus a specific timeline item
  focusTimelineItem(index) {
    const timelineItems = this.isVertical 
      ? this.element.querySelectorAll('.timeline-item')
      : this.element.querySelectorAll('.timeline-event');
    
    if (index >= 0 && index < timelineItems.length) {
      timelineItems[index].focus();
      
      // Scroll item into view if needed
      timelineItems[index].scrollIntoView({
        behavior: 'smooth',
        block: 'nearest'
      });
    }
  },
  
  // Animate timeline items with staggered delay
  animateTimelineItems() {
    if (!this.animationAllowed || !this.inViewport) return;
    
    const timelineItems = this.isVertical 
      ? this.element.querySelectorAll('.timeline-item')
      : this.element.querySelectorAll('.timeline-event');
    
    timelineItems.forEach((item, index) => {
      // Reset animation
      item.style.opacity = '0';
      item.style.transform = this.isVertical 
        ? 'translateX(-10px)' 
        : 'translateY(10px)';
      
      // Apply animation with staggered delay
      setTimeout(() => {
        item.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
        item.style.opacity = '1';
        item.style.transform = 'translate(0, 0)';
      }, 100 + (index * 150));
    });
  },
  
  // Replay the animation
  replayAnimation() {
    if (!this.animationAllowed || !this.inViewport) return;
    
    const timelineItems = this.isVertical 
      ? this.element.querySelectorAll('.timeline-item')
      : this.element.querySelectorAll('.timeline-event');
    
    // Reset all animations
    timelineItems.forEach(item => {
      item.style.transition = 'none';
      item.style.opacity = '0';
      item.style.transform = this.isVertical 
        ? 'translateX(-10px)' 
        : 'translateY(10px)';
      
      // Force reflow
      void item.offsetWidth;
    });
    
    // Reapply animations with staggered delay
    requestAnimationFrame(() => {
      this.animateTimelineItems();
    });
  },
  
  // Set up intersection observer to only animate when visible
  setupIntersectionObserver() {
    if ('IntersectionObserver' in window) {
      const options = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1
      };
      
      this.observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            // Element is visible, ensure animation plays
            this.inViewport = true;
            
            // Trigger animation when element becomes visible
            if (this.animationAllowed && !this.hasAnimated) {
              this.animateTimelineItems();
              this.hasAnimated = true;
            }
          } else {
            // Element is not visible
            this.inViewport = false;
          }
        });
      }, options);
      
      this.observer.observe(this.element);
    }
  },
  
  // Clean up event listeners when element is destroyed
  destroyed() {
    window.removeEventListener('keydown', this.handleKeydown.bind(this));
    
    if (this.observer) {
      this.observer.disconnect();
    }
  }
};

export default TimelineHook; 