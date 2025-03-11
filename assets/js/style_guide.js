/**
 * Style Guide JavaScript Hooks
 * 
 * This file contains JS functionality specifically for the style guide
 * component, handling interactive elements and examples.
 */

// Initialize the style guide
export function initStyleGuide() {
  // Enable animations for examples
  initAnimationExamples();
  
  // Initialize high contrast mode toggle
  initHighContrastToggle();
  
  // Make code examples copyable
  initCodeCopy();
}

/**
 * Initialize animation examples with proper timing and sequencing
 */
function initAnimationExamples() {
  // Reset and replay typewriter animations when they come into view
  const typewriterElements = document.querySelectorAll('.typewriter-text');
  
  if (typewriterElements.length > 0) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          // Reset animation by removing and adding the element
          const el = entry.target;
          const text = el.textContent;
          el.style.width = '0';
          
          // Clear and restart animation
          setTimeout(() => {
            el.style.width = null;
          }, 100);
        }
      });
    }, {
      threshold: 0.5
    });
    
    typewriterElements.forEach(el => {
      observer.observe(el);
    });
  }
  
  // Reset grid animations when they come into view
  const gridAnimations = document.querySelectorAll('.grid-animation');
  
  if (gridAnimations.length > 0) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          // Reset animation by removing and adding animation classes
          const cells = entry.target.querySelectorAll('.grid-cell');
          cells.forEach(cell => {
            cell.style.opacity = 0;
            
            // Reset animation
            requestAnimationFrame(() => {
              cell.style.animation = 'none';
              
              requestAnimationFrame(() => {
                cell.style.animation = '';
              });
            });
          });
        }
      });
    }, {
      threshold: 0.3
    });
    
    gridAnimations.forEach(grid => {
      observer.observe(grid);
    });
  }
}

/**
 * Initialize high contrast toggle functionality
 */
function initHighContrastToggle() {
  const highContrastToggles = document.querySelectorAll('.high-contrast-toggle');
  
  highContrastToggles.forEach(toggle => {
    toggle.addEventListener('click', () => {
      const isPressed = toggle.getAttribute('aria-pressed') === 'true';
      
      // Toggle aria-pressed state
      toggle.setAttribute('aria-pressed', isPressed ? 'false' : 'true');
      
      // Update button text
      toggle.textContent = isPressed ? 'Enable High Contrast' : 'Disable High Contrast';
      
      // Apply high contrast to the example container
      const exampleOutput = toggle.closest('.example-output');
      if (exampleOutput) {
        exampleOutput.classList.toggle('high-contrast-mode', !isPressed);
      }
    });
  });
}

/**
 * Make code examples copyable
 */
function initCodeCopy() {
  const codeBlocks = document.querySelectorAll('.code-example pre code');
  
  codeBlocks.forEach(block => {
    // Create copy button
    const copyButton = document.createElement('button');
    copyButton.classList.add('copy-button');
    copyButton.setAttribute('aria-label', 'Copy code to clipboard');
    copyButton.textContent = 'Copy';
    
    // Add button before the code block
    const pre = block.parentNode;
    pre.style.position = 'relative';
    pre.appendChild(copyButton);
    
    // Handle copy functionality
    copyButton.addEventListener('click', () => {
      // Get text content
      const textToCopy = block.textContent;
      
      // Copy to clipboard
      navigator.clipboard.writeText(textToCopy).then(() => {
        // Success feedback
        copyButton.textContent = 'Copied!';
        setTimeout(() => {
          copyButton.textContent = 'Copy';
        }, 2000);
      }).catch(err => {
        // Error feedback
        copyButton.textContent = 'Failed to copy';
        console.error('Failed to copy: ', err);
        setTimeout(() => {
          copyButton.textContent = 'Copy';
        }, 2000);
      });
    });
  });
}

// Export style guide hooks as a module
export default {
  initStyleGuide
}; 