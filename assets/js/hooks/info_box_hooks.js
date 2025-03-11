/**
 * Hooks for InfoBox component.
 * 
 * Provides client-side functionality for the information boxes, including
 * animations, dismissal actions, and persistence of dismissal state.
 */

const DismissibleInfoBox = {
  mounted() {
    // Set up event listeners for dismissal
    const closeButton = this.el.querySelector('.info-box__close');
    
    if (closeButton) {
      closeButton.addEventListener('click', (e) => {
        e.preventDefault();
        this.dismissInfoBox();
      });
    }
    
    // Check if this info box was previously dismissed
    this.checkDismissalState();
  },
  
  updated() {
    // Re-check dismissal state when component updates
    this.checkDismissalState();
  },
  
  dismissInfoBox() {
    // Animate the dismissal
    this.el.style.transition = 'opacity 0.3s, max-height 0.5s, margin 0.5s';
    this.el.style.opacity = '0';
    this.el.style.maxHeight = '0';
    this.el.style.margin = '0';
    this.el.style.overflow = 'hidden';
    
    // Remove from DOM after animation completes
    setTimeout(() => {
      if (this.el && this.el.parentNode) {
        this.el.parentNode.removeChild(this.el);
      }
    }, 500);
    
    // Store dismissal state if there's an ID
    this.storeDismissalState();
  },
  
  checkDismissalState() {
    // If this box has an ID, check if it was previously dismissed
    if (this.el.id) {
      const dismissedBoxes = this.getDismissedBoxes();
      if (dismissedBoxes.includes(this.el.id)) {
        // Hide immediately without animation
        if (this.el && this.el.parentNode) {
          this.el.parentNode.removeChild(this.el);
        }
      }
    }
  },
  
  storeDismissalState() {
    // If this box has an ID, store it as dismissed
    if (this.el.id) {
      const dismissedBoxes = this.getDismissedBoxes();
      if (!dismissedBoxes.includes(this.el.id)) {
        dismissedBoxes.push(this.el.id);
        localStorage.setItem('dismissedInfoBoxes', JSON.stringify(dismissedBoxes));
      }
    }
  },
  
  getDismissedBoxes() {
    // Get array of dismissed box IDs from localStorage
    const stored = localStorage.getItem('dismissedInfoBoxes');
    return stored ? JSON.parse(stored) : [];
  }
};

export { DismissibleInfoBox }; 