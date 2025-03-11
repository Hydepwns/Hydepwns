/**
 * Animation Components
 * Provides various text and grid-based animations that respect the monospace grid
 * with performance optimizations using requestAnimationFrame and respect for 
 * user's preferred reduced motion settings.
 */

// Check if user prefers reduced motion
const prefersReducedMotion = () => {
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
};

// Character animation effects
const CharacterAnimation = {
  mounted() {
    this.animationAllowed = !prefersReducedMotion();
    
    // Store reference to the element
    this.element = this.el;
    
    if (this.element.classList.contains('typewriter')) {
      this.setupTypewriter();
    } else if (this.element.classList.contains('char-fade')) {
      this.setupCharFade();
    }
    
    // Listen for keyboard events to replay animations
    window.addEventListener('keydown', this.handleKeydown.bind(this));
    
    // Observe element visibility for performance optimization
    this.setupIntersectionObserver();
  },
  
  // Handle keyboard events for replaying animations
  handleKeydown(event) {
    // Use Alt+R as keyboard shortcut to replay animations
    if (event.altKey && event.key === 'r') {
      this.replayAnimation();
      event.preventDefault();
    }
  },
  
  // Replay the animation based on its type
  replayAnimation() {
    if (!this.animationAllowed) return;
    
    if (this.element.classList.contains('typewriter')) {
      this.replayTypewriter();
    } else if (this.element.classList.contains('char-fade')) {
      this.replayCharFade();
    }
  },
  
  // Setup typewriter animation
  setupTypewriter() {
    const text = this.element.textContent.trim();
    const charCount = text.length;
    
    // Ensure a minimum character count for very short text
    const minCharCount = Math.max(charCount, 10);
    
    this.element.style.setProperty('--char-count', minCharCount);
    
    // Make sure the animation can complete
    if (this.element.style.width === '0px') {
      this.element.style.width = '0';
    }
    
    // If reduced motion is preferred, just show the text without animation
    if (!this.animationAllowed) {
      this.element.style.width = '100%';
      this.element.style.animation = 'none';
    }
  },
  
  // Setup character fade-in animation
  setupCharFade() {
    const text = this.element.textContent;
    this.originalText = text;
    const fragment = document.createDocumentFragment();
    
    // Clear original content
    this.element.textContent = '';
    
    // Create span for each character with staggered animation delay
    for (let i = 0; i < text.length; i++) {
      const span = document.createElement('span');
      
      // Preserve whitespace by using non-breaking space for space characters
      if (text[i] === ' ') {
        span.innerHTML = '&nbsp;';
      } else {
        span.textContent = text[i];
      }
      
      if (this.animationAllowed) {
        span.style.animationDelay = `${i * 0.05}s`;
      } else {
        span.style.opacity = 1; // Immediately visible if reduced motion is preferred
        span.style.animation = 'none';
      }
      fragment.appendChild(span);
    }
    
    // Add all spans at once for better performance
    this.element.appendChild(fragment);
  },
  
  // Replay typewriter animation
  replayTypewriter() {
    // Remove existing animation
    this.element.style.animation = 'none';
    
    // Force reflow
    void this.element.offsetWidth;
    
    // Restart animation
    this.element.style.width = '0';
    
    requestAnimationFrame(() => {
      this.element.style.animation = `
        typewriter 3.5s steps(var(--char-count, 20)) 0.5s 1 forwards,
        typewriter-cursor-blink 0.8s step-end infinite
      `;
    });
  },
  
  // Replay character fade-in animation
  replayCharFade() {
    const spans = this.element.querySelectorAll('span');
    
    // Reset opacity and animation for all spans
    spans.forEach((span, i) => {
      span.style.opacity = 0;
      span.style.animation = 'none';
      
      // Force reflow
      void span.offsetWidth;
      
      // Apply new animation with requestAnimationFrame
      requestAnimationFrame(() => {
        span.style.animation = 'char-fade-in 0.1s ease-in-out forwards';
        span.style.animationDelay = `${i * 0.05}s`;
      });
    });
  },
  
  // Setup intersection observer to only animate when visible
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
          } else {
            // Element is not visible, pause animations to save resources
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

// Grid fade-in effect for pages
const GridFadeIn = {
  mounted() {
    this.animationAllowed = !prefersReducedMotion();
    this.element = this.el;
    
    // Calculate line count based on element height and line-height variable
    const lineHeight = parseFloat(
      getComputedStyle(document.documentElement)
        .getPropertyValue('--line-height')
    );
    
    const lineCount = Math.ceil(this.element.offsetHeight / lineHeight);
    this.element.style.setProperty('--line-count', lineCount);
    
    // If reduced motion is preferred, just show the content without animation
    if (!this.animationAllowed) {
      this.element.style.animation = 'none';
      this.element.style.clipPath = 'none';
    }
    
    // Listen for keyboard events to replay animations
    window.addEventListener('keydown', this.handleKeydown.bind(this));
    
    // Observe element visibility
    this.setupIntersectionObserver();
  },
  
  // Handle keyboard events for replaying animations
  handleKeydown(event) {
    // Use Alt+R as keyboard shortcut to replay animations
    if (event.altKey && event.key === 'r') {
      this.replayAnimation();
      event.preventDefault();
    }
  },
  
  // Replay the animation
  replayAnimation() {
    if (!this.animationAllowed || !this.inViewport) return;
    
    // Remove existing animation
    this.element.style.animation = 'none';
    
    // Force reflow
    void this.element.offsetWidth;
    
    // Restart animation with requestAnimationFrame
    requestAnimationFrame(() => {
      this.element.style.animation = 'grid-fade 0.5s steps(var(--line-count, 10)) forwards';
    });
  },
  
  // Setup intersection observer to only animate when visible
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
            this.inViewport = true;
          } else {
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

export { CharacterAnimation, GridFadeIn }; 