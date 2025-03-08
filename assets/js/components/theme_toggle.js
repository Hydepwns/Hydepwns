/**
 * Theme Toggle Component
 * Handles switching between light, dark, and dim themes
 */

const ThemeToggle = {
  mounted() {
    // Cache DOM elements
    this.themeButtons = document.querySelectorAll('.theme-toggle button');
    
    // Get current theme from localStorage or set default
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    this.currentTheme = localStorage.getItem('theme') || (prefersDark ? 'dark-theme' : 'light-theme');
    
    // Set initial theme
    this.applyTheme(this.currentTheme);
    
    // Set up event listeners for theme buttons
    this.themeButtons.forEach(btn => {
      btn.addEventListener('click', () => {
        const theme = btn.getAttribute('data-theme') + '-theme';
        this.setTheme(theme);
      });
    });
    
    // Listen for theme change events from outside
    window.addEventListener('theme-set', e => {
      this.setTheme(e.detail.theme);
    });
    
    // Listen for phx:click events from LiveView
    this.handleEvent('change_theme', ({ theme }) => {
      this.setTheme(theme + '-theme');
    });
  },
  
  // Main method to set the theme
  setTheme(theme) {
    this.currentTheme = theme;
    this.applyTheme(theme);
    localStorage.setItem('theme', theme);
  },
  
  // Helper to apply the theme to the DOM
  applyTheme(theme) {
    document.documentElement.className = theme;
    
    // Update body class
    document.body.classList.remove('light-theme', 'dark-theme', 'dim-theme');
    document.body.classList.add(theme);
    
    // Update UI
    this.highlightActiveTheme(theme);
  },
  
  // Helper to highlight the active theme button
  highlightActiveTheme(theme) {
    this.themeButtons.forEach(btn => {
      const btnTheme = btn.getAttribute('data-theme') + '-theme';
      const isActive = btnTheme === theme;
      
      btn.style.fontWeight = isActive ? 'var(--font-weight-bold)' : 'var(--font-weight-normal)';
      btn.style.color = isActive ? 'var(--text-color)' : 'var(--text-color-alt)';
      btn.setAttribute('aria-pressed', isActive);
    });
  }
};

export default ThemeToggle; 