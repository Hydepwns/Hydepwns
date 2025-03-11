/**
 * Progress Indicator Hook
 * Provides interactive functionality for the monospace progress indicators.
 * 
 * Features:
 * - Handles animation of progress bars
 * - Manages spinner animations
 * - Updates progress values dynamically
 * - Implements accessibility features
 */

const ProgressIndicatorHook = {
  mounted() {
    // Check if user prefers reduced motion
    this.animationAllowed = !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    
    // Store reference to the element
    this.element = this.el;
    
    // Determine the type of progress indicator
    if (this.element.classList.contains('spinner')) {
      this.setupSpinner();
    } else if (this.element.classList.contains('linear') && this.element.classList.contains('animate')) {
      this.setupAnimatedProgressBar();
    }
    
    // Set up intersection observer for performance optimization
    this.setupIntersectionObserver();
  },
  
  // Set up spinner animation
  setupSpinner() {
    // Get animation frames and speed from data attributes
    try {
      this.frames = JSON.parse(this.element.dataset.frames || '["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]');
      this.speed = parseInt(this.element.dataset.speed || '100', 10);
    } catch (e) {
      console.error('Error parsing spinner frames:', e);
      this.frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
      this.speed = 100;
    }
    
    // Get the spinner animation element
    this.spinnerElement = this.element.querySelector('.spinner-animation');
    
    // Start animation if allowed
    if (this.animationAllowed) {
      this.startSpinnerAnimation();
    }
  },
  
  // Start spinner animation
  startSpinnerAnimation() {
    if (!this.spinnerElement || !this.inViewport) return;
    
    let frameIndex = 0;
    
    // Clear any existing interval
    if (this.spinnerInterval) {
      clearInterval(this.spinnerInterval);
    }
    
    // Set up animation interval
    this.spinnerInterval = setInterval(() => {
      if (!this.inViewport) return;
      
      // Update spinner with next frame
      this.spinnerElement.textContent = this.frames[frameIndex];
      
      // Increment frame index and loop back to start if needed
      frameIndex = (frameIndex + 1) % this.frames.length;
    }, this.speed);
  },
  
  // Stop spinner animation
  stopSpinnerAnimation() {
    if (this.spinnerInterval) {
      clearInterval(this.spinnerInterval);
      this.spinnerInterval = null;
    }
  },
  
  // Set up animated progress bar
  setupAnimatedProgressBar() {
    if (!this.animationAllowed) return;
    
    // Get the progress bar element
    this.progressBarElement = this.element.querySelector('.progress-bar');
    
    // Get current progress value
    const valueNow = parseInt(this.progressBarElement.getAttribute('aria-valuenow') || '0', 10);
    const valueMax = parseInt(this.progressBarElement.getAttribute('aria-valuemax') || '100', 10);
    
    // Animate from 0 to current value
    this.animateProgressBar(0, valueNow, valueMax);
  },
  
  // Animate progress bar from start to end value
  animateProgressBar(startValue, endValue, maxValue) {
    if (!this.progressBarElement || !this.inViewport) return;
    
    // Calculate animation duration based on the difference
    const difference = Math.abs(endValue - startValue);
    const duration = Math.min(1500, Math.max(500, difference * 20)); // Between 500ms and 1500ms
    const startTime = performance.now();
    
    // Clear any existing animation
    if (this.progressAnimation) {
      cancelAnimationFrame(this.progressAnimation);
    }
    
    // Animation function
    const animate = (currentTime) => {
      // Calculate progress of the animation (0 to 1)
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);
      
      // Calculate current value using easing function
      const currentValue = startValue + (endValue - startValue) * this.easeOutQuad(progress);
      
      // Update progress bar
      this.updateProgressBar(Math.round(currentValue), maxValue);
      
      // Continue animation if not complete
      if (progress < 1) {
        this.progressAnimation = requestAnimationFrame(animate);
      }
    };
    
    // Start animation
    this.progressAnimation = requestAnimationFrame(animate);
  },
  
  // Update progress bar with new value
  updateProgressBar(value, maxValue) {
    if (!this.progressBarElement) return;
    
    // Calculate percentage
    const percentage = Math.min(100, Math.round((value / maxValue) * 100));
    
    // Update aria attributes
    this.progressBarElement.setAttribute('aria-valuenow', value);
    
    // Find the text content to update
    const textNode = Array.from(this.progressBarElement.childNodes)
      .find(node => node.nodeType === Node.TEXT_NODE);
    
    if (textNode) {
      // Update percentage text
      textNode.nodeValue = textNode.nodeValue.replace(/\d+%/, `${percentage}%`);
    }
    
    // Update progress bar visually
    // This depends on the specific implementation, but typically involves
    // updating the width of a filled area or the number of filled characters
    const filledChars = this.progressBarElement.textContent.match(/\[([^\]]+)\]/);
    if (filledChars && filledChars[1]) {
      const totalWidth = filledChars[1].length;
      const filledWidth = Math.round((percentage / 100) * totalWidth);
      
      // Get the characters used for filled and empty
      const filledChar = filledChars[1].charAt(0);
      const emptyChar = filledChars[1].charAt(filledChars[1].length - 1);
      
      // Create new progress bar string
      const newBar = `[${filledChar.repeat(filledWidth)}${emptyChar.repeat(totalWidth - filledWidth)}] ${percentage}%`;
      
      // Update the progress bar text
      this.progressBarElement.textContent = newBar;
    }
  },
  
  // Easing function for smoother animation
  easeOutQuad(t) {
    return t * (2 - t);
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
            // Element is visible
            this.inViewport = true;
            
            // Start spinner animation if this is a spinner
            if (this.element.classList.contains('spinner') && this.animationAllowed) {
              this.startSpinnerAnimation();
            }
          } else {
            // Element is not visible
            this.inViewport = false;
            
            // Stop spinner animation to save resources
            if (this.element.classList.contains('spinner')) {
              this.stopSpinnerAnimation();
            }
          }
        });
      }, options);
      
      this.observer.observe(this.element);
    }
  },
  
  // Update progress value (can be called from LiveView)
  updateProgress(value, max) {
    if (this.element.classList.contains('linear') || this.element.classList.contains('circular')) {
      const progressElement = this.element.querySelector('[role="progressbar"]');
      if (progressElement) {
        const currentValue = parseInt(progressElement.getAttribute('aria-valuenow') || '0', 10);
        const maxValue = parseInt(max || progressElement.getAttribute('aria-valuemax') || '100', 10);
        
        // Update aria attributes
        progressElement.setAttribute('aria-valuenow', value);
        progressElement.setAttribute('aria-valuemax', maxValue);
        
        // Animate the change if animation is allowed
        if (this.animationAllowed && this.inViewport) {
          this.animateProgressBar(currentValue, value, maxValue);
        } else {
          // Just update without animation
          this.updateProgressBar(value, maxValue);
        }
      }
    }
  },
  
  // Clean up when element is destroyed
  destroyed() {
    // Stop any animations
    if (this.spinnerInterval) {
      clearInterval(this.spinnerInterval);
    }
    
    if (this.progressAnimation) {
      cancelAnimationFrame(this.progressAnimation);
    }
    
    // Disconnect observer
    if (this.observer) {
      this.observer.disconnect();
    }
  }
};

export default ProgressIndicatorHook; 