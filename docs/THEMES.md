# Theme System

This document provides a comprehensive guide for the theme system implementation in Hydepwns.

## Overview

Hydepwns features a robust theme system with three options:

- **Light**: Clean white background with dark text (default)
- **Dark**: Black background with white text
- **Dim**: Dark purple background with neon accents (synthwave inspired)

Themes can be toggled using buttons in the top-right corner of the application. User preferences are stored in localStorage for persistence across sessions.

## Implementation Details

### 1. CSS Architecture

The theme system uses CSS variables for consistent styling across themes:

```css
/* Base theme variables */
:root {
  --color-dark-bg: #000;
  --color-dark-text: #fff;
  /* other base colors */
}

/* Theme application via attribute selectors */
html[data-theme="dark-theme"], .dark-theme {
  --background-color: var(--color-dark-bg);
  --text-color: var(--color-dark-text);
  /* other dark theme variables */
}

html[data-theme="light-theme"], .light-theme {
  --background-color: var(--color-light-bg);
  --text-color: var(--color-light-text);
  /* other light theme variables */
}

html[data-theme="dim-theme"], .dim-theme {
  --background-color: var(--color-dim-bg);
  --text-color: var(--color-dim-text);
  /* other dim theme variables */
}
```

### 2. Theme Toggle Component

The theme toggle component is implemented as a LiveView component:

```elixir
defmodule HydepwnsLiveviewWeb.Components.UI.ThemeToggle do
  use Phoenix.Component
  
  def theme_toggle(assigns) do
    ~H"""
    <div class="theme-toggle" phx-hook="ThemeToggle">
      <button id="light-theme" data-theme="light" title="Light theme">□</button>
      <button id="dark-theme" data-theme="dark" title="Dark theme">■</button>
      <button id="dim-theme" data-theme="dim" title="Dim theme">▣</button>
    </div>
    """
  end
end
```

### 3. JavaScript Implementation

#### Initial Theme Setup (app.js)

This code runs before the DOM is fully loaded to prevent flash of unstyled content:

```javascript
const setInitialTheme = () => {
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const savedTheme = localStorage.getItem('theme') || 
                    (prefersDark ? 'dark-theme' : 'light-theme');
  
  // Apply theme to both document element and body
  document.documentElement.setAttribute('data-theme', savedTheme);
  document.body.classList.remove('light-theme', 'dark-theme', 'dim-theme');
  document.body.classList.add(savedTheme);
};

setInitialTheme();
```

#### LiveView Hook (theme_toggle.js)

```javascript
const ThemeToggle = {
  mounted() {
    // Cache DOM elements
    this.themeButtons = document.querySelectorAll('.theme-toggle button');
    
    // Get current theme from localStorage or set default
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    this.currentTheme = localStorage.getItem('theme') || 
                        (prefersDark ? 'dark-theme' : 'light-theme');
    
    // Set initial theme
    this.applyTheme(this.currentTheme);
    
    // Set up event listeners for theme buttons
    this.themeButtons.forEach(btn => {
      btn.addEventListener('click', () => {
        const theme = btn.getAttribute('data-theme') + '-theme';
        this.setTheme(theme);
      });
    });
    
    // Listen for theme change events
    window.addEventListener('theme-set', e => {
      this.setTheme(e.detail.theme);
    });
  },
  
  // Set theme and store in localStorage
  setTheme(theme) {
    this.currentTheme = theme;
    this.applyTheme(theme);
    localStorage.setItem('theme', theme);
  },
  
  // Apply theme to DOM
  applyTheme(theme) {
    // Update documentElement attribute
    document.documentElement.setAttribute('data-theme', theme);
    
    // Update body class
    document.body.classList.remove('light-theme', 'dark-theme', 'dim-theme');
    document.body.classList.add(theme);
    
    // Update UI
    this.highlightActiveTheme(theme);
  },
  
  // Highlight active theme button
  highlightActiveTheme(theme) {
    const themeBase = theme.replace('-theme', '');
    
    this.themeButtons.forEach(btn => {
      const btnTheme = btn.getAttribute('data-theme');
      const isActive = btnTheme === themeBase;
      
      btn.style.fontWeight = isActive ? 'var(--font-weight-bold)' : 'var(--font-weight-normal)';
      btn.style.color = isActive ? 'var(--text-color)' : 'var(--text-color-alt)';
      btn.setAttribute('aria-pressed', isActive);
    });
  }
};
```

### 4. Integration with Phoenix

To use the theme system in your Phoenix application:

1. Register the theme hook in `assets/js/app.js`:

    ```javascript
    import ThemeToggle from "./hooks/theme_toggle"

    let Hooks = {}
    Hooks.ThemeToggle = ThemeToggle

    let liveSocket = new LiveSocket("/live", Socket, {
    params: {_csrf_token: csrfToken},
    hooks: Hooks
    })
    ```

2. Add the theme toggle component to your layout:

    ```elixir
    # In your layout template
    <HydepwnsLiveviewWeb.Components.UI.ThemeToggle.theme_toggle />
    ```

3. Import the theme CSS in your main CSS file.

## User Experience Considerations

### Accessibility

- Each theme meets WCAG 2.1 AA contrast requirements
- Theme buttons have appropriate ARIA attributes
- Themes can be toggled via keyboard navigation
- System preference detection supports reduced motion and prefers-color-scheme

### Performance

- Theme changes happen instantly without page reloads
- Initial theme is applied before DOM is fully loaded to prevent flashing
- CSS variables are optimized for performance

## Troubleshooting

If themes aren't rendering correctly:

1. **Check Browser Console**: Look for JavaScript errors in the console log
2. **Verify CSS Loading**: Ensure theme CSS files are loaded in the correct order
3. **Check Theme Application**: Verify these elements have correct attributes/classes:
   - `document.documentElement` should have `data-theme="[theme-name]"`
   - `document.body` should have class `[theme-name]`
4. **CSS Specificity**: Ensure theme variables aren't being overridden by more specific CSS
5. **Clear Cache**: Try clearing browser cache to load fresh CSS assets
6. **Sass Functions**: When using Sass mathematical functions:
   - The `round()` function from `sass:math` accepts only 1 argument.
   - Do not use `round(down, value, unit)` - use direct values instead.
   - For other mathematical operations, consult the [Sass documentation](https://sass-lang.com/documentation/modules/math/).
7. **Asset Path References**: Ensure all asset references are correct
   - CSS files should be referenced from `/assets/app.css` and not from subdirectories
   - All theme styles should be compiled into the main CSS file

## Extending the Theme System

### Adding New Themes

To add a new theme:

1. Define color variables in `:root` section of themes.css
2. Create new theme selector in themes.css:

   ```css
   html[data-theme="new-theme"], .new-theme {
     --background-color: var(--color-new-bg);
     --text-color: var(--color-new-text);
     /* other variables */
   }
   ```

3. Add new button to theme toggle component
4. Update JavaScript to handle the new theme

### Custom Theme Properties

To add new theme-specific properties:

1. Define base variables in `:root`
2. Add theme-specific values in each theme selector
3. Use the variables in your components with `var(--property-name)`
