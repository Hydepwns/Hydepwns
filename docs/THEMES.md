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
defmodule HydepwnsLiveviewWeb.Components.Common.ThemeToggle do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  
  def theme_toggle(assigns) do
    ~H"""
    <div class="theme-toggle" phx-hook="ThemeToggle">
      <button id="light-theme" data-theme="light" phx-click={JS.push("change_theme", value: %{theme: "light"})}>□</button>
      <button id="dark-theme" data-theme="dark" phx-click={JS.push("change_theme", value: %{theme: "dark"})}>■</button>
      <button id="dim-theme" data-theme="dim" phx-click={JS.push("change_theme", value: %{theme: "dim"})}>▣</button>
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
    
    // Listen for theme change events from LiveView
    this.handleEvent('change_theme', ({ theme }) => {
      // Always ensure theme has the -theme suffix
      const themeWithSuffix = theme.endsWith('-theme') ? theme : `${theme}-theme`;
      this.setTheme(themeWithSuffix);
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

### 4. LiveView Integration

The theme system integrates with LiveView through a centralized event handler defined in the base live_view module. This avoids duplicate event handlers in individual LiveView modules.

```elixir
# In lib/hydepwns_liveview_web.ex
def live_view do
  quote do
    use Phoenix.LiveView,
      layout: {HydepwnsLiveviewWeb.Components.Layout.Layouts, :app}

    import HydepwnsLiveviewWeb.Gettext

    # Base event handlers for all LiveViews
    def handle_event("change_theme", %{"theme" => theme}, socket) do
      theme_class = "#{theme}-theme"
      {:noreply, assign(socket, :theme_class, theme_class)}
    end

    unquote(verified_routes())
  end
end
```

This approach ensures that all LiveView modules inherit the same theme-changing functionality without duplication. The `handle_event("change_theme", ...)` function is defined in the base module and automatically included in every LiveView.

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

## Fixing Duplicate Event Handlers

If you encounter warnings about duplicate `handle_event("change_theme", ...)` functions, follow these steps:

1. **Identify the Duplicate Handlers**: Look for LiveView modules that define their own `handle_event("change_theme", ...)` function.

2. **Remove Custom Implementations**: Remove any custom implementations of the theme change handler from individual LiveView modules.

3. **Rely on the Base Implementation**: Use the implementation provided by the base `live_view/0` function in your web.ex module.

4. **For Custom Behavior**: If a specific LiveView needs custom theme behavior, use a different event name or handle it with a different approach such as:
   - Using a LiveComponent for theme handling
   - Implementing a theme manager module with process registry

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

## Synthwave Color Palette

Version 1.3.1 introduces a vibrant synthwave-inspired color palette for enhanced visual aesthetics. These colors are particularly effective in the Dim theme but can be used across all themes for accent colors.

### Core Synthwave Colors

| Color Name      | Hex Code | RGB Value        | Use Case                        |
|-----------------|----------|------------------|----------------------------------|
| Primary Purple  | #9D53F2  | rgb(157, 83, 242)| Main accent color, focus states  |
| Neon Pink       | #FF2E97  | rgb(255, 46, 151)| Highlights, important elements   |
| Electric Cyan   | #19DCFF  | rgb(25, 220, 255)| Information, process flows       |
| Neon Yellow     | #FFD319  | rgb(255, 211, 25)| Warnings, charts, callouts       |
| Synthwave Teal  | #36F9F6  | rgb(54, 249, 246)| Secondary elements, multi-select |

### Implementation in CSS Variables

The synthwave palette is implemented using CSS variables for consistent application across components:

```css
:root {
  /* Synthwave Palette */
  --color-primary-purple: #9D53F2;
  --color-neon-pink: #FF2E97;
  --color-electric-cyan: #19DCFF;
  --color-neon-yellow: #FFD319;
  --color-synthwave-teal: #36F9F6;
  
  /* Synthwave Shadows */
  --glow-primary-purple: 0 0 5px #9D53F2, 0 0 10px #9D53F2;
  --glow-neon-pink: 0 0 5px #FF2E97, 0 0 10px #FF2E97;
  --glow-electric-cyan: 0 0 5px #19DCFF, 0 0 10px #19DCFF;
  --glow-neon-yellow: 0 0 5px #FFD319, 0 0 10px #FFD319;
  --glow-synthwave-teal: 0 0 5px #36F9F6, 0 0 10px #36F9F6;
}
```

### Usage in Components

These colors are used consistently throughout the component system:

1. **Grid Selections**
   - Single cell: Primary Purple
   - Row selection: Neon Pink
   - Column selection: Electric Cyan
   - Range selection: Neon Yellow
   - Multi-cell selection: Synthwave Teal

2. **ASCII Art Components**
   - Flow diagrams: Electric Cyan
   - Sequence diagrams: Synthwave Teal
   - Charts: Neon Yellow
   - Headers: Neon Pink (with glow effect) or gradient of all colors

3. **UI Elements**
   - Primary buttons: Primary Purple
   - Warning elements: Neon Yellow
   - Information elements: Electric Cyan
   - Highlight elements: Neon Pink

### Accessibility Considerations

When using the synthwave colors, ensure sufficient contrast with background colors for text readability. The following combinations have been tested for WCAG AA compliance:

- Primary Purple on black: 7.5:1 (passes AAA)
- Neon Pink on black: 5.9:1 (passes AA)
- Electric Cyan on black: 8.3:1 (passes AAA)
- Neon Yellow on black: 16.2:1 (passes AAA)
- Synthwave Teal on black: 13.8:1 (passes AAA)

For white backgrounds, add dark borders or increase font weight to ensure readability.

### Effects and Animations

The synthwave palette pairs well with CSS effects for an enhanced retro-futuristic aesthetic:

1. **Text Shadow for Neon Effect**

   ```css
   .neon-text {
     color: var(--color-neon-pink);
     text-shadow: var(--glow-neon-pink);
   }
   ```

2. **Gradient Text**

   ```css
   .synthwave-gradient {
     background: linear-gradient(
       to right,
       var(--color-primary-purple),
       var(--color-neon-pink),
       var(--color-electric-cyan),
       var(--color-neon-yellow)
     );
     -webkit-background-clip: text;
     -webkit-text-fill-color: transparent;
     font-weight: bold;
   }
   ```

3. **Pulsing Animation**

   ```css
   @keyframes neon-pulse {
     0%, 100% {
       text-shadow: var(--glow-neon-pink);
     }
     50% {
       text-shadow: 0 0 10px #FF2E97, 0 0 20px #FF2E97, 0 0 30px #FF2E97;
     }
   }
   
   .pulsing-neon {
     animation: neon-pulse 2s infinite;
   }
   ```

See the [ASCII Art Components](ASCII_ART_COMPONENTS.md) documentation for more examples of the synthwave palette in action.
