/**
 * CopyableCode Hook
 * Allows users to click on code blocks to copy the content to clipboard
 * Shows a visual feedback when code is copied
 */
const CopyableCode = {
  mounted() {
    this.el.addEventListener('click', () => this.copyToClipboard());
    
    // Add visual indicator that the element is clickable
    this.el.classList.add('copyable');
    
    // Create tooltip element for feedback
    this.tooltip = document.createElement('div');
    this.tooltip.className = 'copy-tooltip';
    this.tooltip.textContent = 'Click to copy';
    this.el.parentNode.appendChild(this.tooltip);
    
    // Show tooltip on hover
    this.el.addEventListener('mouseenter', () => {
      this.tooltip.classList.add('visible');
    });
    
    this.el.addEventListener('mouseleave', () => {
      this.tooltip.classList.remove('visible');
      // Also remove the 'copied' class if it exists
      this.tooltip.classList.remove('copied');
      this.tooltip.textContent = 'Click to copy';
    });
  },
  
  copyToClipboard() {
    const content = this.el.textContent;
    
    // Using the Clipboard API if available
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(content)
        .then(() => this.showCopySuccess())
        .catch(err => {
          console.error('Failed to copy: ', err);
          this.showCopyError();
        });
    } else {
      // Fallback method for older browsers
      const textarea = document.createElement('textarea');
      textarea.value = content;
      textarea.style.position = 'fixed';  // Avoid scrolling to bottom
      document.body.appendChild(textarea);
      textarea.select();
      
      try {
        const successful = document.execCommand('copy');
        if (successful) {
          this.showCopySuccess();
        } else {
          this.showCopyError();
        }
      } catch (err) {
        console.error('Failed to copy: ', err);
        this.showCopyError();
      }
      
      document.body.removeChild(textarea);
    }
  },
  
  showCopySuccess() {
    // Update tooltip to show success message
    this.tooltip.textContent = 'Copied!';
    this.tooltip.classList.add('copied');
    this.tooltip.classList.add('visible');
    
    // Add a brief flash effect to the code element
    this.el.classList.add('flash');
    setTimeout(() => {
      this.el.classList.remove('flash');
    }, 300);
    
    // Reset tooltip after a delay
    setTimeout(() => {
      if (!this.el.matches(':hover')) {
        this.tooltip.classList.remove('visible');
        this.tooltip.classList.remove('copied');
        this.tooltip.textContent = 'Click to copy';
      }
    }, 2000);
  },
  
  showCopyError() {
    // Update tooltip to show error message
    this.tooltip.textContent = 'Copy failed!';
    this.tooltip.classList.add('error');
    this.tooltip.classList.add('visible');
    
    // Reset tooltip after a delay
    setTimeout(() => {
      this.tooltip.classList.remove('visible');
      this.tooltip.classList.remove('error');
      this.tooltip.textContent = 'Click to copy';
    }, 2000);
  },
  
  // Clean up when element is destroyed
  destroyed() {
    if (this.tooltip && this.tooltip.parentNode) {
      this.tooltip.parentNode.removeChild(this.tooltip);
    }
  }
};

export default CopyableCode; 