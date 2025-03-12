/**
 * Accessibility Menu Toggle Hook
 * -----------------------------
 * Manages the accessibility menu dropdown behavior.
 * Handles keyboard interaction, focus management, and click outside closing.
 */

const AccessibilityMenuToggle = {
  mounted() {
    // Store references to elements
    this.button = this.el;
    this.dropdown = document.getElementById('a11y-menu-dropdown');
    this.radioButtons = this.dropdown.querySelectorAll('[role="radio"]');
    
    // Set up event listeners
    this.button.addEventListener('click', this.toggleMenu.bind(this));
    this.button.addEventListener('keydown', this.handleKeydown.bind(this));
    
    // Set up event delegation for radio buttons
    this.dropdown.addEventListener('click', this.handleRadioClick.bind(this));
    this.dropdown.addEventListener('keydown', this.handleDropdownKeydown.bind(this));
    
    // Close when clicking outside
    document.addEventListener('click', this.handleOutsideClick.bind(this));
    
    // Load and apply saved preferences
    this.loadSavedPreferences();
    
    // Debug logging if available
    if (window.DEBUG) {
      window.DEBUG.log('AccessibilityMenuToggle mounted');
    }
  },
  
  disconnected() {
    // Clean up event listeners
    this.button.removeEventListener('click', this.toggleMenu.bind(this));
    this.button.removeEventListener('keydown', this.handleKeydown.bind(this));
    this.dropdown.removeEventListener('click', this.handleRadioClick.bind(this));
    this.dropdown.removeEventListener('keydown', this.handleDropdownKeydown.bind(this));
    document.removeEventListener('click', this.handleOutsideClick.bind(this));
  },
  
  toggleMenu(event) {
    const isExpanded = this.button.getAttribute('aria-expanded') === 'true';
    
    if (isExpanded) {
      this.closeMenu();
    } else {
      this.openMenu();
    }
  },
  
  openMenu() {
    // Show the dropdown
    this.dropdown.hidden = false;
    this.button.setAttribute('aria-expanded', 'true');
    
    // Focus the first radio button
    const firstRadio = this.dropdown.querySelector('[role="radio"]');
    if (firstRadio) {
      firstRadio.focus();
    }
    
    // Announce to screen readers
    this.announceToScreenReader('Accessibility menu opened');
  },
  
  closeMenu() {
    // Hide the dropdown
    this.dropdown.hidden = true;
    this.button.setAttribute('aria-expanded', 'false');
    
    // Return focus to the toggle button
    this.button.focus();
    
    // Announce to screen readers
    this.announceToScreenReader('Accessibility menu closed');
  },
  
  handleKeydown(event) {
    switch (event.key) {
      case 'Enter':
      case ' ':
        event.preventDefault();
        this.toggleMenu();
        break;
      case 'Escape':
        if (this.button.getAttribute('aria-expanded') === 'true') {
          event.preventDefault();
          this.closeMenu();
        }
        break;
      case 'ArrowDown':
        if (this.button.getAttribute('aria-expanded') === 'true') {
          event.preventDefault();
          const firstRadio = this.dropdown.querySelector('[role="radio"]');
          if (firstRadio) {
            firstRadio.focus();
          }
        } else {
          this.openMenu();
        }
        break;
    }
  },
  
  handleDropdownKeydown(event) {
    // Handle Escape to close the menu
    if (event.key === 'Escape') {
      event.preventDefault();
      this.closeMenu();
      return;
    }
    
    // Handle arrow keys for navigation within radiogroups
    if (event.key === 'ArrowUp' || event.key === 'ArrowDown') {
      // Find the radiogroup that contains the active element
      const radiogroup = event.target.closest('[role="radiogroup"]');
      if (!radiogroup) return;
      
      const radios = Array.from(radiogroup.querySelectorAll('[role="radio"]'));
      const currentIndex = radios.indexOf(document.activeElement);
      
      if (currentIndex === -1) return;
      
      event.preventDefault();
      
      // Calculate next focus index
      let nextIndex;
      if (event.key === 'ArrowDown') {
        nextIndex = (currentIndex + 1) % radios.length;
      } else {
        nextIndex = (currentIndex - 1 + radios.length) % radios.length;
      }
      
      // Focus the new element
      radios[nextIndex].focus();
    }
  },
  
  handleRadioClick(event) {
    const radio = event.target.closest('[role="radio"]');
    if (!radio) return;
    
    // Handle radio button selection
    const radiogroup = radio.closest('[role="radiogroup"]');
    if (!radiogroup) return;
    
    // Update all radio buttons in the group
    const radios = radiogroup.querySelectorAll('[role="radio"]');
    radios.forEach(r => {
      r.setAttribute('aria-checked', 'false');
      r.classList.remove('active');
    });
    
    // Set the clicked one as checked
    radio.setAttribute('aria-checked', 'true');
    radio.classList.add('active');
    
    // Get option information for saving preferences
    const optionName = radio.dataset.a11yOption;
    
    if (optionName) {
      this.savePreference(optionName);
      this.applyPreference(optionName);
    }
  },
  
  handleOutsideClick(event) {
    // Close menu when clicking outside
    if (this.button.getAttribute('aria-expanded') === 'true' &&
        !this.dropdown.contains(event.target) &&
        !this.button.contains(event.target)) {
      this.closeMenu();
    }
  },
  
  savePreference(optionName) {
    try {
      localStorage.setItem('a11y_preference_' + optionName, 'true');
      
      // Store the timestamp for when preferences were last updated
      localStorage.setItem('a11y_preferences_updated', Date.now().toString());
      
      if (window.DEBUG) {
        window.DEBUG.log('Saved accessibility preference:', optionName);
      }
    } catch (e) {
      // Handle localStorage errors
      console.error('Failed to save accessibility preference:', e);
    }
  },
  
  loadSavedPreferences() {
    try {
      // Get all stored preferences
      const preferences = [];
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key.startsWith('a11y_preference_')) {
          const optionName = key.replace('a11y_preference_', '');
          preferences.push(optionName);
        }
      }
      
      // Apply each saved preference
      preferences.forEach(option => {
        const radio = this.dropdown.querySelector(`[data-a11y-option="${option}"]`);
        if (radio) {
          // Update the radio button state
          const radiogroup = radio.closest('[role="radiogroup"]');
          if (radiogroup) {
            const radios = radiogroup.querySelectorAll('[role="radio"]');
            radios.forEach(r => {
              r.setAttribute('aria-checked', 'false');
              r.classList.remove('active');
            });
          }
          
          radio.setAttribute('aria-checked', 'true');
          radio.classList.add('active');
          
          // Apply the preference
          this.applyPreference(option);
        }
      });
      
      if (window.DEBUG && preferences.length > 0) {
        window.DEBUG.log('Loaded accessibility preferences:', preferences);
      }
    } catch (e) {
      // Handle localStorage errors
      console.error('Failed to load accessibility preferences:', e);
    }
  },
  
  applyPreference(optionName) {
    // Text size preferences
    if (optionName === 'text-size-small') {
      document.documentElement.style.setProperty('--text-size-factor', '0.85');
      this.announceToScreenReader('Text size set to small');
    } else if (optionName === 'text-size-normal') {
      document.documentElement.style.setProperty('--text-size-factor', '1');
      this.announceToScreenReader('Text size set to normal');
    } else if (optionName === 'text-size-large') {
      document.documentElement.style.setProperty('--text-size-factor', '1.2');
      this.announceToScreenReader('Text size set to large');
    }
    
    // Animation preferences
    else if (optionName === 'animations-disabled') {
      document.documentElement.classList.add('animations-disabled');
      document.documentElement.classList.remove('animations-reduced');
      this.announceToScreenReader('Animations disabled');
    } else if (optionName === 'animations-reduced') {
      document.documentElement.classList.add('animations-reduced');
      document.documentElement.classList.remove('animations-disabled');
      this.announceToScreenReader('Animations reduced');
    } else if (optionName === 'animations-enabled') {
      document.documentElement.classList.remove('animations-disabled', 'animations-reduced');
      this.announceToScreenReader('Animations enabled');
    }
    
    // Contrast preferences
    else if (optionName === 'contrast-high') {
      document.documentElement.classList.add('high-contrast');
      this.announceToScreenReader('High contrast mode enabled');
    } else if (optionName === 'contrast-normal') {
      document.documentElement.classList.remove('high-contrast');
      this.announceToScreenReader('Normal contrast mode enabled');
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

export default AccessibilityMenuToggle; 