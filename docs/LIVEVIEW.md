# Monospace Web for LiveView

This document explains how to use the Monospace Web styling with your Phoenix LiveView application and how to run a development server.

## Overview

The Monospace Web styling provides a clean, typography-focused design inspired by [The Monospace Web](https://github.com/owickstrom/the-monospace-web) project, using monospace fonts and a minimal aesthetic. Our implementation uses Monaspace Argon as the primary font with JetBrains Mono as a fallback.

The design focuses on:
- Character-based grid layout
- Consistent spacing using `ch` units
- Minimal styling that emphasizes content and typography
- Grid-based animations that respect the character grid
- Light, dark, and dim theme options

## Setup and Installation

### 1. Add Font Files

Download the Monaspace Argon font files and place them in your project:

```bash
mkdir -p priv/static/fonts
# Copy font files to priv/static/fonts/
```

### 2. Add CSS Files

The styling is split across several files for better organization:

- `reset.css` - Base browser reset
- `themes/monaspace.css` - Typography and monospace styling
- `themes/themes.css` - Theme variables and dark mode
- `themes/animations.css` - Grid-based animations

### 3. Import CSS in Your App

In your `assets/css/app.css` file, import the monospace styling:

```css
/* Base reset */
@import "./reset.css";

/* Typography and monospace styling */
@import "./themes/monaspace.css";

/* Theme variables and dark mode support */
@import "./themes/themes.css";

/* Grid-based animations */
@import "./themes/animations.css";
```

### 4. Configure Theme in LiveView

In your root layout file (`lib/your_app_web/templates/layout/root.html.heex`), add the theme class to your body tag:

```html
<body class={@theme_class}>
  <%= @inner_content %>
</body>
```

### 5. Add LiveView Hooks for Animations

Set up hooks in your `app.js` file:

```javascript
let Hooks = {}

// Character animation hook
Hooks.CharacterAnimation = {
  mounted() {
    // Handle typewriter effect
    if (this.el.classList.contains('typewriter')) {
      const charCount = this.el.textContent.length;
      this.el.style.setProperty('--char-count', charCount);
    }

    // Handle character fade-in effect
    if (this.el.classList.contains('char-fade')) {
      const text = this.el.textContent;
      this.el.textContent = '';
      
      for (let i = 0; i < text.length; i++) {
        const span = document.createElement('span');
        span.textContent = text[i];
        span.style.animationDelay = `${i * 0.05}s`;
        this.el.appendChild(span);
      }
    }
  }
};

// Register hooks with LiveView
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})
```

### 6. Manage Theme Switching

Add theme switching functionality in your LiveView module:

```elixir
def mount(_params, _session, socket) do
  system_theme = if connected?(socket), do: get_system_theme(), else: "light"
  {:ok, assign(socket, theme_class: "#{system_theme}-theme")}
end

def handle_event("change_theme", %{"theme" => theme}, socket) do
  {:noreply, 
    socket
    |> assign(:theme_class, "#{theme}-theme")
    |> push_event("change_theme", %{theme: theme})
  }
end
```

Add theme toggles in your template:

```html
<div class="theme-toggle">
  <button
    phx-click="change_theme"
    phx-value-theme="light"
    aria-label="Switch to light theme"
    data-theme="light"
    title="Light theme"
  >
    □
  </button>
  <button
    phx-click="change_theme"
    phx-value-theme="dark"
    aria-label="Switch to dark theme"
    data-theme="dark"
    title="Dark theme"
  >
    ■
  </button>
  <button
    phx-click="change_theme"
    phx-value-theme="dim"
    aria-label="Switch to dim theme"
    data-theme="dim"
    title="Dim theme"
  >
    ▣
  </button>
</div>
```

## Grid-Based Animations

Our implementation includes several character-grid based animations that maintain the monospace aesthetic:

### Typewriter Effect

Reveals text one character at a time, like a typewriter:

```html
<p phx-hook="CharacterAnimation" class="typewriter">This text appears character by character.</p>
```

### Character Fade In

Each character fades in separately with calculated timing:

```html
<p phx-hook="CharacterAnimation" class="char-fade">Each character fades in separately.</p>
```

### Grid Slide In

Content slides in using character-width steps:

```html
<p class="grid-slide-in">This text slides in by character increments.</p>
```

### Cursor Blink

A classic terminal cursor that blinks in place:

```html
<p>Command prompt <span class="cursor-blink"></span></p>
```

### ASCII Spinner

A loading indicator made from ASCII characters:

```html
<p>Loading <span class="ascii-spinner"></span></p>
```

### Border Draw Animation

Animates a border drawing around content, following the character grid:

```html
<div class="border-draw">
  This box has an animated border that follows the character grid.
</div>
```

### Grid Fade In

Page transition that reveals content line by line:

```html
<main phx-hook="GridFadeIn" class="grid-fade-in">
  Content here
</main>
```

## Debug Grid

The implementation includes a debug grid to help visualize the character grid alignment:

```html
<div class="debug-toggle">
  <label class="debug-toggle-label">
    <input
      type="checkbox"
      id="debug-grid-toggle"
      phx-hook="DebugGridToggle"
    /> Show grid
  </label>
</div>
<div class="debug-grid" style="display: none;"></div>
```

Enable it in your layout to check alignment of all elements.

## Style Guide

The project includes a comprehensive style guide that showcases all monospace components and grid-based animations. Access it at `/style-guide` to see:

- Typography examples (headings, paragraphs, formatting)
- Grid and layout examples
- UI components
- All grid-based animations
- Theme previews
- Debug tools

The style guide serves as both documentation and a testing ground for your monospace components.

## Running the Development Server

### Prerequisites

- Elixir and Erlang installed
- Phoenix framework installed
- Node.js and npm installed (for assets)

### Starting the Server

```bash
# Install Elixir dependencies
mix deps.get

# Create and migrate your database (if applicable):
mix ecto.create
mix ecto.migrate

# Start the Phoenix server:
mix phx.server
```

Your application will be available at [`localhost:4000`](http://localhost:4000) by default.

### Development Workflow

- Edit CSS in the appropriate theme files
- LiveView templates go in `lib/your_app_web/live/`
- Components go in `lib/your_app_web/components/`
- The Phoenix server will automatically reload when you save changes

## Customization

### Theme Variables

You can customize colors and spacing by modifying the CSS variables in the `:root` selector:

```css
:root {
  --font-family: 'Monaspace Argon', 'JetBrains Mono', monospace;
  --line-height: 1.20rem;
  --border-thickness: 2px;
  --text-color: #000;
  --text-color-alt: #666;
  --background-color: #fff;
  --background-color-alt: #eee;
  /* ... other variables ... */
}
```

### Adding Custom Themes

Create additional theme classes in your CSS:

```css
.custom-theme {
  --text-color: #342e37;
  --text-color-alt: #a2d729;
  --background-color: #fafffd;
  --background-color-alt: #e6e8e6;
}
```

### Creating Custom Grid-Based Animations

When creating custom animations, follow these principles to maintain grid alignment:

1. Use `ch` units for horizontal movement
2. Use `var(--line-height)` for vertical spacing
3. Use the `steps()` function for discrete animations
4. Ensure elements maintain their place in the grid

## Troubleshooting

### Fonts Not Loading

If the Monaspace fonts aren't loading:

1. Ensure font files are in `priv/static/fonts/`
2. Check the paths in your `@font-face` declarations
3. Verify the fonts are being compiled into your assets

The system will fall back to JetBrains Mono, which is loaded from CDN.

### CSS Changes Not Appearing

If CSS changes aren't visible:

1. Hard refresh your browser (Ctrl/Cmd + Shift + R)
2. Check browser console for errors
3. Ensure asset compilation is working correctly

### Animation Issues

If animations aren't working:

1. Make sure LiveView hooks are properly registered
2. Check for JavaScript errors in the console
3. Verify that the proper classes are applied to elements

## Resources

- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view)
- [The Monospace Web GitHub](https://github.com/owickstrom/the-monospace-web)
- [Monaspace Fonts](https://github.com/githubnext/monaspace)
