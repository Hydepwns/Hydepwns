/**
 * Keyboard Navigation Hook
 * -----------------------
 * Provides global keyboard shortcuts for navigating the site.
 * Implements skip links, focus trapping, and enhanced navigation for keyboard users.
 */

const KeyboardNavigation = {
  mounted() {
    // Store elements and state
    this.focusableElements = [
      'a[href]',
      'button:not([disabled])',
      'input:not([disabled])',
      'select:not([disabled])',
      'textarea:not([disabled])',
      '[tabindex="0"]'
    ].join(',');
    
    // Set up the keydown event listener
    this.keydownHandler = this.handleKeydown.bind(this);
    document.addEventListener('keydown', this.keydownHandler);
    
    // Set up focus management
    this.setupFocusTraps();
    
    // Debug logging if available
    if (window.DEBUG) {
      window.DEBUG.log('KeyboardNavigation hook mounted');
    }
  },
  
  disconnected() {
    // Clean up event listeners
    document.removeEventListener('keydown', this.keydownHandler);
    
    // Clean up any modal focus traps
    const focusTraps = document.querySelectorAll('[data-focus-trap]');
    focusTraps.forEach(trap => {
      trap.removeEventListener('keydown', this.trapFocus);
    });
  },
  
  handleKeydown(event) {
    // Skip if user is typing in an input field
    if (['INPUT', 'TEXTAREA', 'SELECT'].includes(event.target.tagName)) {
      return;
    }
    
    // Handle keyboard shortcuts
    switch (event.key) {
      // Navigation shortcuts
      case '/':
        // Focus on search (if it exists)
        if (event.ctrlKey || event.metaKey) {
          event.preventDefault();
          const searchInput = document.querySelector('#search-input');
          if (searchInput) {
            searchInput.focus();
          }
        }
        break;
        
      case 'h':
        // Home page
        if (event.altKey) {
          event.preventDefault();
          window.location.href = '/';
        }
        break;
        
      case '`':
        // Toggle terminal
        if (!event.ctrlKey && !event.altKey && !event.shiftKey) {
          event.preventDefault();
          this.pushEvent('toggle-terminal');
        }
        break;
        
      case 't':
        // Toggle table of contents
        if (event.altKey) {
          event.preventDefault();
          this.pushEvent('toggle-toc');
        }
        break;
        
      case 'a':
        // Open accessibility menu
        if (event.altKey) {
          event.preventDefault();
          const a11yMenuButton = document.querySelector('#a11y-menu-toggle');
          if (a11yMenuButton) {
            a11yMenuButton.click();
          }
        }
        break;
        
      // Skip links
      case 'Tab':
        // Show skip links when Tab is first pressed
        if (!this.tabPressed) {
          this.tabPressed = true;
          document.body.classList.add('keyboard-navigation');
          
          // Show skip link
          const skipLink = document.querySelector('.skip-to-content');
          if (skipLink) {
            skipLink.classList.add('visible');
          }
        }
        break;
        
      // Escape key handling
      case 'Escape':
        // Close any open menus/modals
        this.handleEscapeKey();
        break;
        
      // Focus navigation
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        // Alt+number to focus on main sections
        if (event.altKey) {
          event.preventDefault();
          this.focusOnSection(parseInt(event.key));
        }
        break;
    }
  },
  
  setupFocusTraps() {
    // Set up focus trapping for modals and dialogs
    const focusTraps = document.querySelectorAll('[data-focus-trap]');
    focusTraps.forEach(trap => {
      trap.addEventListener('keydown', this.trapFocus);
    });
  },
  
  trapFocus(event) {
    // Skip if not tab key
    if (event.key !== 'Tab') return;
    
    // Get all focusable elements in the trap
    const focusableElements = Array.from(
      event.currentTarget.querySelectorAll(this.focusableElements)
    ).filter(el => el.offsetParent !== null); // Filter out hidden elements
    
    if (focusableElements.length === 0) return;
    
    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];
    
    // Handle tabbing forward and backward
    if (event.shiftKey && document.activeElement === firstElement) {
      event.preventDefault();
      lastElement.focus();
    } else if (!event.shiftKey && document.activeElement === lastElement) {
      event.preventDefault();
      firstElement.focus();
    }
  },
  
  handleEscapeKey() {
    // Close modals and dialogs
    const openModals = document.querySelectorAll('[role="dialog"][aria-modal="true"]');
    if (openModals.length > 0) {
      // Find the top-most modal and close it
      const topModal = Array.from(openModals).pop();
      const closeButton = topModal.querySelector('[data-close]');
      if (closeButton) {
        closeButton.click();
      }
      return;
    }
    
    // Close menus
    const openMenus = document.querySelectorAll('[aria-expanded="true"]');
    if (openMenus.length > 0) {
      openMenus.forEach(menu => {
        // Trigger the click event on the menu button
        menu.click();
      });
      return;
    }
    
    // Handle terminal visibility
    this.pushEvent('close-terminal');
  },
  
  focusOnSection(sectionNumber) {
    // Map section numbers to selectors
    const sectionMap = {
      1: '#main-content',
      2: '#terminal-container',
      3: '#table-of-contents',
      4: '#site-header',
      5: '#site-footer',
      6: '#projects-section',
      7: '#about-section',
      8: '#contact-section',
      9: '#a11y-menu-toggle'
    };
    
    const selector = sectionMap[sectionNumber];
    if (selector) {
      const element = document.querySelector(selector);
      if (element) {
        element.focus();
        // Scroll into view if not visible
        element.scrollIntoView({ behavior: 'smooth', block: 'start' });
        this.announceToScreenReader(`Navigated to ${element.getAttribute('aria-label') || element.textContent.trim() || 'section ' + sectionNumber}`);
      }
    }
  },
  
  announceToScreenReader(message) {
    // Find the announcer element
    const announcer = document.getElementById('accessibility-announcer');
    if (announcer) {
      // Update the content to trigger screen reader announcement
      announcer.textContent = message;
    }
  }
};

export default KeyboardNavigation; 