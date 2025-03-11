/**
 * AsciiArtGenerator Hook
 * Provides client-side functionality for the ASCII art generator component
 * Handles form interactions and live preview updates
 */
const AsciiArtGenerator = {
  mounted() {
    // Find all form elements
    this.form = this.el.querySelector('form');
    this.artTypeSelect = this.el.querySelector('select[name="art_type"]');
    this.styleSelect = this.el.querySelector('select[name="style"]');
    this.widthInput = this.el.querySelector('input[name="width"]');
    this.heightInput = this.el.querySelector('input[name="height"]');
    this.textInput = this.el.querySelector('input[name="text"]');
    
    // Add keyboard accessibility
    this.initKeyboardNavigation();
    
    // Focus on the form when component is mounted
    if (this.artTypeSelect) {
      this.artTypeSelect.focus();
    }
    
    // Initialize event listeners to handle form interactions
    this.initEventListeners();
  },
  
  initEventListeners() {
    // When art type changes, adjust the visibility of relevant controls
    if (this.artTypeSelect) {
      this.artTypeSelect.addEventListener('change', (e) => {
        this.updateFormState(e.target.value);
      });
      
      // Initialize form state based on current art type
      this.updateFormState(this.artTypeSelect.value);
    }
    
    // Add aria-live region for screen readers to announce changes
    const previewSection = this.el.querySelector('.preview-section');
    if (previewSection) {
      previewSection.setAttribute('aria-live', 'polite');
    }
  },
  
  updateFormState(artType) {
    // Show/hide or adjust controls based on the selected art type
    const heightControl = this.heightInput.closest('.form-group');
    
    // For arrow type, height is not relevant
    if (artType === 'arrow') {
      heightControl.style.opacity = '0.5';
      this.heightInput.setAttribute('tabindex', '-1');
    } else {
      heightControl.style.opacity = '1';
      this.heightInput.setAttribute('tabindex', '0');
    }
    
    // For custom type, temporarily disable other controls
    if (artType === 'custom') {
      this.el.querySelectorAll('.form-row:first-of-type .form-group:nth-of-type(2), .form-row:nth-of-type(2)').forEach(el => {
        el.style.opacity = '0.5';
      });
      this.styleSelect.setAttribute('tabindex', '-1');
      this.widthInput.setAttribute('tabindex', '-1');
      this.heightInput.setAttribute('tabindex', '-1');
    } else {
      this.el.querySelectorAll('.form-row:first-of-type .form-group:nth-of-type(2), .form-row:nth-of-type(2)').forEach(el => {
        el.style.opacity = '1';
      });
      this.styleSelect.setAttribute('tabindex', '0');
      this.widthInput.setAttribute('tabindex', '0');
      // Height input is controlled by the artType check above
    }
  },
  
  initKeyboardNavigation() {
    // Add appropriate ARIA attributes
    this.el.setAttribute('role', 'region');
    this.el.setAttribute('aria-label', 'ASCII Art Generator');
    
    // Add keyboard shortcuts for focus management
    this.el.addEventListener('keydown', (e) => {
      // Alt+P to jump to preview section
      if (e.altKey && e.key.toLowerCase() === 'p') {
        e.preventDefault();
        const previewSection = this.el.querySelector('.preview-section');
        if (previewSection) {
          previewSection.setAttribute('tabindex', '0');
          previewSection.focus();
        }
      }
    });
  }
};

export default AsciiArtGenerator; 