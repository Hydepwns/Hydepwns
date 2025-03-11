/**
 * Keyboard Navigation Hook
 * -----------------------
 * Enhances site accessibility by providing keyboard navigation throughout the site.
 * 
 * Features:
 * - Tab key navigation between focusable elements
 * - Arrow key navigation for TOC items
 * - Skip-to-content functionality
 * - Enhanced focus visibility
 * - Section navigation with shortcut keys
 * - Focus trap for modals and dialogs
 * - Main navigation keyboard shortcuts
 * - Interactive element keyboard controls
 */

const KeyboardNavigation = {
  mounted() {
    // Access debug utility from window
    this.debug = window.DEBUG || { log: () => {} };
    this.debug.log('KeyboardNavigation mounted - Hook initialized');
    
    // Initialize navigation elements
    this.initNavigation();
    
    // Add keyboard event listeners
    this.addEventListeners();
    
    // Create skip to content link if it doesn't exist
    this.createSkipToContentLink();
    
    // Initialize focus ring visibility
    this.initFocusRingVisibility();
    
    // Initialize focus trap for modals
    this.initFocusTraps();
    
    // Track active element for focus restoration
    this.lastActiveElement = null;
  },
  
  initNavigation() {
    // Cache DOM elements for performance
    this.tocItems = Array.from(document.querySelectorAll('.toc a'));
    this.headings = Array.from(document.querySelectorAll('h2, h3, h4, h5, h6'));
    this.focusableElements = this.getFocusableElements();
    this.sectionLinks = this.getSectionLinks();
    this.mainNavLinks = Array.from(document.querySelectorAll('nav.main-nav a, .app-header a'));

    // Track keyboard users
    this.isKeyboardUser = false;
    
    // Create accessible announcement element
    this.announcementElement = this.createAnnouncementElement();
    
    this.debug.log('KeyboardNavigation: Found TOC items', this.tocItems.length);
    this.debug.log('KeyboardNavigation: Found headings', this.headings.length);
    this.debug.log('KeyboardNavigation: Found main nav links', this.mainNavLinks.length);
  },
  
  addEventListeners() {
    // Global keyboard event listener
    document.addEventListener('keydown', (e) => {
      this.handleKeyDown(e);
      
      // Mark as keyboard user on first key press
      if (!this.isKeyboardUser) {
        this.isKeyboardUser = true;
        document.body.classList.add('keyboard-user');
      }
    });

    // Mouse events - detect non-keyboard users
    document.addEventListener('mousedown', () => {
      this.isKeyboardUser = false;
      document.body.classList.remove('keyboard-user');
    });
    
    // Handle TOC item keyboard navigation
    this.tocItems.forEach(item => {
      item.addEventListener('keydown', (e) => {
        this.handleTocNavigation(e);
      });
    });
    
    // Handle main navigation keyboard navigation
    this.mainNavLinks.forEach(item => {
      item.addEventListener('keydown', (e) => {
        this.handleMainNavigation(e);
      });
    });
    
    // Monitor for dynamic modals to apply focus traps
    const observer = new MutationObserver(mutations => {
      mutations.forEach(mutation => {
        if (mutation.addedNodes.length) {
          mutation.addedNodes.forEach(node => {
            if (node.nodeType === 1 && 
                (node.getAttribute('role') === 'dialog' || 
                 node.classList.contains('modal') || 
                 node.querySelector('[role="dialog"], .modal'))) {
              this.debug.log('Dialog/modal added to DOM, initializing focus trap');
              this.setupFocusTrap(node);
            }
          });
        }
      });
    });
    
    observer.observe(document.body, { 
      childList: true, 
      subtree: true 
    });
  },
  
  handleKeyDown(e) {
    // Store last active element for focus restoration
    if (document.activeElement !== document.body) {
      this.lastActiveElement = document.activeElement;
    }
    
    // Handle keyboard shortcuts
    if (e.altKey) {
      switch (e.key) {
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
          // Navigate to section by number (Alt+1 through Alt+9)
          e.preventDefault();
          this.navigateToSection(parseInt(e.key) - 1);
          break;
        case 'h':
          // Navigate to home/top (Alt+H)
          e.preventDefault();
          window.scrollTo({ top: 0, behavior: 'smooth' });
          this.announceAction('Navigated to top of page');
          break;
        case 't':
          // Navigate to TOC (Alt+T)
          e.preventDefault();
          this.focusTOC();
          break;
        case 's':
          // Toggle TOC visibility (Alt+S)
          e.preventDefault();
          this.toggleTOC();
          break;
        case 'n':
          // Navigate to main navigation (Alt+N)
          e.preventDefault();
          this.focusMainNav();
          break;
        case 'm':
          // Navigate to main content (Alt+M)
          e.preventDefault();
          this.focusMainContent();
          break;
      }
    }
    
    // Handle main navigation with arrow keys (when focused)
    if (document.activeElement && this.mainNavLinks.includes(document.activeElement)) {
      if (e.key === 'ArrowLeft' || e.key === 'ArrowRight') {
        this.handleMainNavigation(e);
      }
    }
    
    // Handle ESC key for custom components
    if (e.key === 'Escape') {
      // If a menu or dropdown is open, close it
      const openMenus = document.querySelectorAll('[aria-expanded="true"]');
      if (openMenus.length > 0) {
        openMenus.forEach(menu => {
          // Trigger click to close the menu
          menu.click();
        });
        e.preventDefault();
      }
      
      // Close open dialogs/modals
      const openModals = document.querySelectorAll('.modal[aria-hidden="false"], [role="dialog"][aria-hidden="false"]');
      if (openModals.length > 0) {
        // Find close button and click it, or trigger custom close event
        openModals.forEach(modal => {
          const closeButton = modal.querySelector('.close-button, .modal-close, [data-dismiss]');
          if (closeButton) {
            closeButton.click();
            e.preventDefault();
          }
        });
      }
      
      // Restore focus if we closed something
      if (this.lastActiveElement && (openMenus.length > 0 || openModals.length > 0)) {
        setTimeout(() => {
          this.lastActiveElement.focus();
        }, 100);
      }
    }
  },
  
  handleTocNavigation(e) {
    const currentIndex = this.tocItems.indexOf(e.target);
    
    if (currentIndex === -1) return;
    
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        if (currentIndex < this.tocItems.length - 1) {
          this.tocItems[currentIndex + 1].focus();
        }
        break;
      case 'ArrowUp':
        e.preventDefault();
        if (currentIndex > 0) {
          this.tocItems[currentIndex - 1].focus();
        }
        break;
      case 'Home':
        e.preventDefault();
        if (this.tocItems.length > 0) {
          this.tocItems[0].focus();
        }
        break;
      case 'End':
        e.preventDefault();
        if (this.tocItems.length > 0) {
          this.tocItems[this.tocItems.length - 1].focus();
        }
        break;
    }
  },
  
  handleMainNavigation(e) {
    const currentIndex = this.mainNavLinks.indexOf(e.target);
    
    if (currentIndex === -1) return;
    
    switch (e.key) {
      case 'ArrowRight':
        e.preventDefault();
        if (currentIndex < this.mainNavLinks.length - 1) {
          this.mainNavLinks[currentIndex + 1].focus();
        }
        break;
      case 'ArrowLeft':
        e.preventDefault();
        if (currentIndex > 0) {
          this.mainNavLinks[currentIndex - 1].focus();
        }
        break;
      case 'Home':
        e.preventDefault();
        if (this.mainNavLinks.length > 0) {
          this.mainNavLinks[0].focus();
        }
        break;
      case 'End':
        e.preventDefault();
        if (this.mainNavLinks.length > 0) {
          this.mainNavLinks[this.mainNavLinks.length - 1].focus();
        }
        break;
    }
  },
  
  navigateToSection(index) {
    if (index >= 0 && index < this.headings.length) {
      const heading = this.headings[index];
      heading.setAttribute('tabindex', '-1');
      heading.focus();
      heading.scrollIntoView({ behavior: 'smooth', block: 'start' });
      
      // Announce the navigation
      this.announceAction(`Navigated to ${heading.textContent}`);
      
      // Remove tabindex after focus
      setTimeout(() => {
        heading.removeAttribute('tabindex');
      }, 1000);
    }
  },
  
  focusTOC() {
    if (this.tocItems.length > 0) {
      this.tocItems[0].focus();
      this.announceAction('Navigated to Table of Contents');
    }
  },
  
  focusMainNav() {
    if (this.mainNavLinks.length > 0) {
      this.mainNavLinks[0].focus();
      this.announceAction('Navigated to main navigation');
    }
  },
  
  focusMainContent() {
    const mainContent = document.querySelector('main, #main-content, #introduction');
    if (mainContent) {
      mainContent.setAttribute('tabindex', '-1');
      mainContent.focus();
      mainContent.scrollIntoView({ behavior: 'smooth', block: 'start' });
      this.announceAction('Navigated to main content');
      
      // Remove tabindex after focus
      setTimeout(() => {
        mainContent.removeAttribute('tabindex');
      }, 1000);
    }
  },
  
  toggleTOC() {
    const tocToggleButton = document.querySelector('.toc-toggle');
    if (tocToggleButton) {
      tocToggleButton.click();
      this.announceAction('Table of Contents toggled');
    }
  },
  
  createSkipToContentLink() {
    // Check if skip link already exists
    if (document.querySelector('.skip-to-content')) {
      return;
    }
    
    // Create skip to content link
    const skipLink = document.createElement('a');
    skipLink.href = '#introduction';
    skipLink.className = 'skip-to-content';
    skipLink.textContent = 'Skip to content';
    skipLink.addEventListener('click', (e) => {
      e.preventDefault();
      const targetElement = document.getElementById('introduction');
      if (targetElement) {
        targetElement.setAttribute('tabindex', '-1');
        targetElement.focus();
        targetElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
        
        // Announce the navigation
        this.announceAction('Skipped to main content');
        
        // Remove tabindex after focus
        setTimeout(() => {
          targetElement.removeAttribute('tabindex');
        }, 1000);
      }
    });
    
    // Insert as first element in the body
    document.body.insertBefore(skipLink, document.body.firstChild);
  },
  
  createAnnouncementElement() {
    // Create or get existing element
    let announcer = document.getElementById('accessibility-announcer');
    
    if (!announcer) {
      announcer = document.createElement('div');
      announcer.id = 'accessibility-announcer';
      announcer.className = 'sr-only';
      announcer.setAttribute('aria-live', 'polite');
      announcer.setAttribute('aria-atomic', 'true');
      document.body.appendChild(announcer);
    }
    
    return announcer;
  },
  
  announceAction(message) {
    if (this.announcementElement) {
      this.announcementElement.textContent = message;
    }
  },
  
  getFocusableElements() {
    // Get all focusable elements in the document
    return Array.from(document.querySelectorAll(
      'a[href], button, input, textarea, select, details, [tabindex]:not([tabindex="-1"])'
    )).filter(el => {
      // Filter out hidden elements
      const style = window.getComputedStyle(el);
      return !(style.display === 'none' || style.visibility === 'hidden');
    });
  },
  
  getSectionLinks() {
    // Get all section links (typically h2 elements with ids)
    return Array.from(document.querySelectorAll('h2[id]')).map(heading => {
      return {
        id: heading.id,
        text: heading.textContent
      };
    });
  },
  
  initFocusRingVisibility() {
    // Create style element if it doesn't exist
    if (!document.getElementById('focus-styles')) {
      const styleEl = document.createElement('style');
      styleEl.id = 'focus-styles';
      
      // CSS that only shows focus rings for keyboard navigation
      styleEl.textContent = `
        /* Hide focus outline by default */
        :focus:not(:focus-visible) {
          outline: none !important;
        }
        
        /* Show focus outline for keyboard users */
        .keyboard-user :focus,
        :focus-visible {
          outline: 2px solid var(--accent-color, #0097fc) !important;
          outline-offset: 2px !important;
        }
        
        /* Skip to content link */
        .skip-to-content {
          position: absolute;
          top: -100px;
          left: 0;
          background: var(--accent-color, #0097fc);
          color: var(--text-color-inverse, #fff);
          padding: 8px 16px;
          z-index: 9999;
          transition: top 0.3s;
          font-family: var(--font-family);
        }
        
        .skip-to-content:focus {
          top: 0;
        }
      `;
      
      document.head.appendChild(styleEl);
    }
    
    // Add initial class based on input method
    if (window.matchMedia('(hover: none)').matches) {
      // Likely touch device, keep focus rings
      document.body.classList.add('keyboard-user');
    }
  },
  
  initFocusTraps() {
    // Find all existing modals/dialogs and set up focus traps
    const dialogs = document.querySelectorAll('.modal, [role="dialog"]');
    dialogs.forEach(dialog => {
      this.setupFocusTrap(dialog);
    });
  },
  
  setupFocusTrap(element) {
    if (!element || element.hasAttribute('data-focus-trap-initialized')) {
      return;
    }
    
    // Mark as initialized
    element.setAttribute('data-focus-trap-initialized', 'true');
    
    // Find all focusable elements within the container
    const focusableElements = Array.from(
      element.querySelectorAll(
        'a[href], button, input, textarea, select, details, [tabindex]:not([tabindex="-1"])'
      )
    ).filter(el => {
      const style = window.getComputedStyle(el);
      return !(style.display === 'none' || style.visibility === 'hidden' || el.disabled);
    });
    
    // If no focusable elements found, do nothing
    if (focusableElements.length === 0) {
      return;
    }
    
    const firstFocusableElement = focusableElements[0];
    const lastFocusableElement = focusableElements[focusableElements.length - 1];
    
    // Store previous active element for focus restoration
    const previousActiveElement = document.activeElement;
    
    // Focus the first element when dialog opens
    if (element.getAttribute('aria-hidden') === 'false' || getComputedStyle(element).display !== 'none') {
      setTimeout(() => {
        firstFocusableElement.focus();
      }, 100);
    }
    
    // Add keydown event handler to the dialog
    const trapFocus = (e) => {
      if (e.key === 'Tab') {
        // Detect if shift key was pressed
        if (e.shiftKey) {
          // If shift+tab on first element, loop to last
          if (document.activeElement === firstFocusableElement) {
            e.preventDefault();
            lastFocusableElement.focus();
          }
        } else {
          // If tab on last element, loop to first
          if (document.activeElement === lastFocusableElement) {
            e.preventDefault();
            firstFocusableElement.focus();
          }
        }
      }
    };
    
    // Handle dialog close to restore focus
    const handleClose = () => {
      if (previousActiveElement) {
        previousActiveElement.focus();
      }
      element.removeEventListener('keydown', trapFocus);
    };
    
    // Add event listeners
    element.addEventListener('keydown', trapFocus);
    
    // Detect close events
    const closeButton = element.querySelector('.close-button, .modal-close, [data-dismiss]');
    if (closeButton) {
      closeButton.addEventListener('click', handleClose);
    }
    
    // Hook into dialog hiding
    const observer = new MutationObserver(mutations => {
      mutations.forEach(mutation => {
        if (mutation.type === 'attributes' && 
            (mutation.attributeName === 'aria-hidden' || 
             mutation.attributeName === 'style')) {
          if (element.getAttribute('aria-hidden') === 'true' || 
              getComputedStyle(element).display === 'none') {
            handleClose();
          }
        }
      });
    });
    
    observer.observe(element, { 
      attributes: true,
      attributeFilter: ['style', 'aria-hidden', 'class']
    });
  }
};

export default KeyboardNavigation; 