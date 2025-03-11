/**
 * HierarchicalTOC Hook
 * 
 * This hook provides functionality for the hierarchical table of contents:
 * - Collapsing/expanding nested sections with toggles
 * - Section tracking as user scrolls the page (scroll spy)
 * - Keyboard navigation for accessibility
 * - Mobile-friendly interactions
 */
const HierarchicalTOC = {
  mounted() {
    // Initialize debug
    this.debug = this.getDebug();
    this.debug.log('HierarchicalTOC hook mounted');
    
    // Store DOM elements and initialize state
    this.tocItems = this.el.querySelectorAll('.toc-item');
    this.toggleIndicators = this.el.querySelectorAll('.toggle-indicator');
    this.tocLinks = this.el.querySelectorAll('.toc-link');
    this.headingElements = [];
    
    // Track active section and IntersectionObserver
    this.activeSection = null;
    this.intersectionObserver = null;
    
    // Initialize TOC functionality
    this.initToggleHandlers();
    this.initKeyboardNavigation();
    this.setupScrollSpy();

    // Handle hash change for direct links to sections
    window.addEventListener('hashchange', this.handleHashChange.bind(this));
    
    // Initial check for hash in URL
    this.handleInitialHash();
  },

  updated() {
    // Refresh elements and re-initialize when component updates
    this.debug.log('HierarchicalTOC hook updated');
    
    this.tocItems = this.el.querySelectorAll('.toc-item');
    this.toggleIndicators = this.el.querySelectorAll('.toggle-indicator');
    this.tocLinks = this.el.querySelectorAll('.toc-link');
    
    // Disconnect previous observer if exists
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect();
    }
    
    // Reinitialize functionality
    this.initToggleHandlers();
    this.initKeyboardNavigation();
    this.setupScrollSpy();
  },

  destroyed() {
    // Clean up event listeners and observers
    this.debug.log('HierarchicalTOC hook destroyed');
    
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect();
    }
    
    window.removeEventListener('hashchange', this.handleHashChange.bind(this));
  },
  
  getDebug() {
    return {
      enabled: window.hydepwnsDebug || false,
      log: function(message, ...args) {
        if (this.enabled) {
          console.log(`[HierarchicalTOC] ${message}`, ...args);
        }
      },
      error: function(message, ...args) {
        if (this.enabled) {
          console.error(`[HierarchicalTOC] ${message}`, ...args);
        }
      }
    };
  },
  
  // Initialize toggle functionality for collapsible sections
  initToggleHandlers() {
    this.debug.log('Initializing toggle handlers');
    
    this.tocItems.forEach(item => {
      const toggle = item.querySelector('.toggle-indicator');
      const link = item.querySelector('.toc-link');
      const sublist = item.querySelector('.toc-sublist');
      
      if (toggle && sublist) {
        // Click on toggle indicators
        toggle.addEventListener('click', (e) => {
          e.preventDefault();
          e.stopPropagation();
          this.toggleSection(item, toggle, sublist);
        });
        
        // Special handling for links with children
        if (link) {
          link.addEventListener('click', (e) => {
            // If this is a parent item, toggle it on click (after navigation)
            if (e.target === toggle) {
              e.preventDefault();
              e.stopPropagation();
              this.toggleSection(item, toggle, sublist);
            }
          });
        }
      }
    });
  },
  
  // Toggle section visibility
  toggleSection(item, toggle, sublist) {
    const isCollapsed = sublist.classList.contains('collapsed');
    
    if (isCollapsed) {
      // Expand section
      sublist.classList.remove('collapsed');
      toggle.innerHTML = '▼';
      this.debug.log('Expanded section', item);
    } else {
      // Collapse section
      sublist.classList.add('collapsed');
      toggle.innerHTML = '▶';
      this.debug.log('Collapsed section', item);
    }
  },
  
  // Initialize keyboard navigation for accessibility
  initKeyboardNavigation() {
    this.debug.log('Initializing keyboard navigation');
    
    this.tocLinks.forEach(link => {
      link.addEventListener('keydown', (e) => {
        const item = link.closest('.toc-item');
        const toggle = item.querySelector('.toggle-indicator');
        const sublist = item.querySelector('.toc-sublist');
        
        // Space key toggles section expansion
        if (e.key === ' ' && toggle && sublist) {
          e.preventDefault();
          this.toggleSection(item, toggle, sublist);
        }
        
        // Arrow keys for navigation
        if (e.key === 'ArrowRight' && toggle && sublist) {
          // Right arrow expands a collapsed section
          e.preventDefault();
          if (sublist.classList.contains('collapsed')) {
            this.toggleSection(item, toggle, sublist);
          }
        } else if (e.key === 'ArrowLeft' && toggle && sublist) {
          // Left arrow collapses an expanded section
          e.preventDefault();
          if (!sublist.classList.contains('collapsed')) {
            this.toggleSection(item, toggle, sublist);
          }
        }
      });
    });
  },
  
  // Set up scroll spy to track current section
  setupScrollSpy() {
    this.debug.log('Setting up scroll spy');
    
    // Find all headings that match our TOC
    this.headingElements = [];
    
    this.tocLinks.forEach(link => {
      const href = link.getAttribute('href');
      if (href && href.startsWith('#')) {
        const id = href.substring(1);
        const heading = document.getElementById(id);
        
        if (heading) {
          this.headingElements.push({ id, element: heading, tocLink: link });
        }
      }
    });
    
    this.debug.log('Found heading elements:', this.headingElements.length);
    
    // Create IntersectionObserver to track visible headings
    const options = {
      root: null, // viewport
      rootMargin: '-100px 0px -80% 0px', // slightly below the top
      threshold: 0 // trigger as soon as any part is visible
    };
    
    this.intersectionObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        const id = entry.target.id;
        
        if (entry.isIntersecting) {
          this.setActiveSection(id);
        }
      });
    }, options);
    
    // Observe all heading elements
    this.headingElements.forEach(({ element }) => {
      this.intersectionObserver.observe(element);
    });
  },
  
  // Set the active section in the TOC
  setActiveSection(id) {
    this.debug.log('Setting active section:', id);
    
    // Remove active class from all items
    this.tocItems.forEach(item => {
      item.classList.remove('active');
    });
    
    // Add active class to the current section
    const activeItem = this.el.querySelector(`.toc-item a[href="#${id}"]`).closest('.toc-item');
    if (activeItem) {
      activeItem.classList.add('active');
      
      // Ensure parent sections are expanded
      let parent = activeItem.parentElement.closest('.toc-item');
      while (parent) {
        const sublist = parent.querySelector('.toc-sublist');
        const toggle = parent.querySelector('.toggle-indicator');
        
        if (sublist && sublist.classList.contains('collapsed') && toggle) {
          this.toggleSection(parent, toggle, sublist);
        }
        
        parent = parent.parentElement.closest('.toc-item');
      }
      
      // Scroll active item into view if not already visible
      if (!this.isElementInViewport(activeItem)) {
        activeItem.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      }
    }
    
    this.activeSection = id;
  },
  
  // Handle hash change (direct links to sections)
  handleHashChange() {
    const hash = window.location.hash;
    if (hash) {
      const id = hash.substring(1);
      this.setActiveSection(id);
    }
  },
  
  // Handle initial hash in URL on page load
  handleInitialHash() {
    // Allow time for the page to render
    setTimeout(() => {
      const hash = window.location.hash;
      if (hash) {
        const id = hash.substring(1);
        this.setActiveSection(id);
      } else if (this.headingElements.length > 0) {
        // Default to first section if no hash
        this.setActiveSection(this.headingElements[0].id);
      }
    }, 500);
  },
  
  // Helper to check if an element is in the viewport
  isElementInViewport(el) {
    const rect = el.getBoundingClientRect();
    return (
      rect.top >= 0 &&
      rect.left >= 0 &&
      rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
      rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
  }
};

export default HierarchicalTOC; 