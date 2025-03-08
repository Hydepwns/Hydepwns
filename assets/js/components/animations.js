/**
 * Animation Components
 * Provides various text and grid-based animations that respect the monospace grid
 */

// Character animation effects
const CharacterAnimation = {
  mounted() {
    if (this.el.classList.contains('typewriter')) {
      this.setupTypewriter();
    } else if (this.el.classList.contains('char-fade')) {
      this.setupCharFade();
    }
  },

  // Setup typewriter animation
  setupTypewriter() {
    const charCount = this.el.textContent.length;
    this.el.style.setProperty('--char-count', charCount);
  },

  // Setup character fade-in animation
  setupCharFade() {
    const text = this.el.textContent;
    const fragment = document.createDocumentFragment();
    
    // Clear original content
    this.el.textContent = '';
    
    // Create span for each character with staggered animation delay
    for (let i = 0; i < text.length; i++) {
      const span = document.createElement('span');
      span.textContent = text[i];
      span.style.animationDelay = `${i * 0.05}s`;
      fragment.appendChild(span);
    }
    
    // Add all spans at once for better performance
    this.el.appendChild(fragment);
  }
};

// Grid fade-in effect for pages
const GridFadeIn = {
  mounted() {
    // Calculate line count based on element height and line-height variable
    const lineHeight = parseFloat(
      getComputedStyle(document.documentElement)
        .getPropertyValue('--line-height')
    );
    
    const lineCount = Math.ceil(this.el.offsetHeight / lineHeight);
    this.el.style.setProperty('--line-count', lineCount);
  }
};

export { CharacterAnimation, GridFadeIn }; 