/**
 * Focus Mode Hook
 * --------------
 * Implements a keyboard-only focus mode that enhances navigation and interaction
 * for users who rely solely on keyboard input.
 * 
 * Features:
 * - Enhanced focus visibility
 * - Simplified UI with fewer distractions
 * - Additional keyboard shortcuts specific to focus mode
 * - Context-aware navigation assistance
 * - Persistent focus mode preference
 */

const FocusMode = {
  mounted() {
    // Access debug utility from window
    this.debug = window.DEBUG || { log: () => {} };
    this.debug.log('FocusMode mounted - Hook initialized');
    
    // Initialize focus mode components
    this.initFocusMode();
    
    // Handle server-side events
    this.handleEvents();
  },
  
  initFocusMode() {
    // Cache frequently accessed elements
    this.body = document.body;
    this.focusModeActive = false;
    
    // Check if user previously enabled focus mode
    this.restoreFocusModePreference();
    
    // Create focus mode toggle button
    this.createFocusModeToggle();
    
    // Add keyboard shortcuts listener
    document.addEventListener('keydown', this.handleKeydown.bind(this));
    
    // Create status announcer for screen readers
    this.statusAnnouncer = document.getElementById('accessibility-announcer') || 
      this.createStatusAnnouncer();
  },
  
  handleEvents() {
    // Listen to server-side events for focus mode
    this.handleEvent('toggle_focus_mode', () => {
      this.toggleFocusMode();
    });
  },
  
  createFocusModeToggle() {
    // Check if button already exists
    if (document.querySelector('.focus-mode-toggle')) {
      return;
    }
    
    // Create toggle button
    const toggleButton = document.createElement('button');
    toggleButton.className = 'focus-mode-toggle';
    toggleButton.setAttribute('aria-pressed', this.focusModeActive);
    toggleButton.setAttribute('aria-label', 'Toggle keyboard focus mode');
    toggleButton.innerHTML = `
      <span class="focus-mode-icon">${this.focusModeActive ? '◉' : '○'}</span>
      <span class="focus-mode-text">Focus Mode</span>
      <span class="focus-mode-shortcut" aria-hidden="true">Alt+F</span>
    `;
    
    // Add click handler
    toggleButton.addEventListener('click', () => {
      this.toggleFocusMode();
    });
    
    // Add to DOM
    const header = document.querySelector('header');
    if (header) {
      header.appendChild(toggleButton);
    } else {
      document.body.insertBefore(toggleButton, document.body.firstChild);
    }
    
    this.focusModeToggle = toggleButton;
  },
  
  toggleFocusMode() {
    this.focusModeActive = !this.focusModeActive;
    
    // Update UI
    if (this.focusModeActive) {
      this.body.classList.add('focus-mode');
      this.announceStatus('Focus mode activated. Press Alt+F to exit focus mode.');
    } else {
      this.body.classList.remove('focus-mode');
      this.announceStatus('Focus mode deactivated.');
    }
    
    // Update toggle button state
    if (this.focusModeToggle) {
      this.focusModeToggle.setAttribute('aria-pressed', this.focusModeActive);
      const icon = this.focusModeToggle.querySelector('.focus-mode-icon');
      if (icon) {
        icon.textContent = this.focusModeActive ? '◉' : '○';
      }
    }
    
    // Save preference
    this.saveFocusModePreference();
    
    // Trigger custom event that other components can listen to
    const event = new CustomEvent('focusModeChanged', {
      detail: { active: this.focusModeActive }
    });
    document.dispatchEvent(event);
    
    // Send event to server
    this.pushEvent('focus_mode_changed', { active: this.focusModeActive });
  },
  
  handleKeydown(e) {
    // Alt+F toggles focus mode
    if (e.altKey && e.key.toLowerCase() === 'f') {
      e.preventDefault();
      this.toggleFocusMode();
      return;
    }
    
    // Only process other shortcuts if focus mode is active
    if (!this.focusModeActive) return;
    
    // When in focus mode, provide additional shortcuts
    if (e.altKey) {
      switch (e.key.toLowerCase()) {
        case 'n': // Next interactive element
          e.preventDefault();
          this.navigateToNextInteractive();
          break;
        case 'p': // Previous interactive element
          e.preventDefault();
          this.navigateToPreviousInteractive();
          break;
        case 'i': // Show context information about current element
          e.preventDefault();
          this.showElementContext();
          break;
        case 'c': // Read current section content
          e.preventDefault();
          this.readCurrentSection();
          break;
      }
    }
  },
  
  navigateToNextInteractive() {
    const interactiveElements = this.getInteractiveElements();
    const currentFocused = document.activeElement;
    let currentIndex = interactiveElements.indexOf(currentFocused);
    
    if (currentIndex === -1 || currentIndex === interactiveElements.length - 1) {
      currentIndex = 0;
    } else {
      currentIndex++;
    }
    
    if (interactiveElements[currentIndex]) {
      interactiveElements[currentIndex].focus();
      this.announceElementContext(interactiveElements[currentIndex]);
    }
  },
  
  navigateToPreviousInteractive() {
    const interactiveElements = this.getInteractiveElements();
    const currentFocused = document.activeElement;
    let currentIndex = interactiveElements.indexOf(currentFocused);
    
    if (currentIndex <= 0) {
      currentIndex = interactiveElements.length - 1;
    } else {
      currentIndex--;
    }
    
    if (interactiveElements[currentIndex]) {
      interactiveElements[currentIndex].focus();
      this.announceElementContext(interactiveElements[currentIndex]);
    }
  },
  
  getInteractiveElements() {
    return Array.from(document.querySelectorAll(
      'a[href], button, input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )).filter(el => {
      // Filter out hidden elements
      const style = window.getComputedStyle(el);
      return !(style.display === 'none' || style.visibility === 'hidden');
    });
  },
  
  announceElementContext(element) {
    let message = '';
    
    // Get element type and name
    const tagName = element.tagName.toLowerCase();
    const ariaLabel = element.getAttribute('aria-label');
    const label = ariaLabel || element.innerText || element.value || element.placeholder;
    
    // Build informative message
    message = `${tagName}`;
    if (label) message += `, ${label}`;
    
    // Add context about parent section if available
    const section = this.findParentSection(element);
    if (section) {
      const heading = section.querySelector('h1, h2, h3, h4, h5, h6');
      if (heading) {
        message += `. In section: ${heading.innerText}`;
      }
    }
    
    this.announceStatus(message);
  },
  
  findParentSection(element) {
    let parent = element.parentElement;
    while (parent && parent !== document.body) {
      if (parent.tagName.toLowerCase() === 'section') {
        return parent;
      }
      parent = parent.parentElement;
    }
    return null;
  },
  
  showElementContext() {
    const element = document.activeElement;
    if (element && element !== document.body) {
      this.announceElementContext(element);
    }
  },
  
  readCurrentSection() {
    const element = document.activeElement;
    const section = this.findParentSection(element);
    
    if (section) {
      // Get text content, but filter out scripts, etc.
      const text = Array.from(section.childNodes)
        .filter(node => {
          return node.nodeType === Node.TEXT_NODE || 
            (node.nodeType === Node.ELEMENT_NODE && 
             !['SCRIPT', 'STYLE'].includes(node.tagName));
        })
        .map(node => node.textContent)
        .join(' ')
        .replace(/\s+/g, ' ')
        .trim();
      
      this.announceStatus(`Current section content: ${text}`);
    }
  },
  
  createStatusAnnouncer() {
    const announcer = document.createElement('div');
    announcer.id = 'accessibility-announcer';
    announcer.className = 'sr-only';
    announcer.setAttribute('aria-live', 'polite');
    announcer.setAttribute('aria-atomic', 'true');
    document.body.appendChild(announcer);
    return announcer;
  },
  
  announceStatus(message) {
    if (this.statusAnnouncer) {
      this.statusAnnouncer.textContent = message;
    }
    this.debug.log('Focus Mode announcement:', message);
  },
  
  saveFocusModePreference() {
    try {
      localStorage.setItem('focus_mode_active', this.focusModeActive);
    } catch (e) {
      this.debug.log('Error saving focus mode preference:', e);
    }
  },
  
  restoreFocusModePreference() {
    try {
      const savedPreference = localStorage.getItem('focus_mode_active');
      if (savedPreference !== null) {
        this.focusModeActive = savedPreference === 'true';
        if (this.focusModeActive) {
          this.body.classList.add('focus-mode');
        }
      }
    } catch (e) {
      this.debug.log('Error restoring focus mode preference:', e);
    }
  },
  
  disconnected() {
    // Clean up event listeners
    document.removeEventListener('keydown', this.handleKeydown);
  }
};

export default FocusMode; 