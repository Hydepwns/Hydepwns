# Monospace Web Styling Guide

This document provides detailed guidance on implementing monospace web styling principles and grid-based animations in your Phoenix LiveView application.

## Core Monospace Principles

### Character-Based Grid

The foundation of monospace web design is the character grid. In this approach:

- Each character occupies the same width (`1ch` unit in CSS)
- Line heights are fixed multiples of the base unit (`var(--line-height)`)
- All elements align to this invisible grid
- Spacing is measured in character units rather than arbitrary pixels

### Typography Focus

Monospace typography emphasizes:

- Clean, consistent spacing
- Readability through proper line height and width
- Character alignment across lines
- Clear hierarchy through font weight rather than size variation

### Minimalist Design

The monospace aesthetic embraces minimalism:

- Limited color palette defined by CSS variables
- Simple borders and structural elements
- Typography as the primary design element
- Elimination of decorative elements that don't serve a purpose

## CSS Variables System

Our implementation uses a flexible CSS variable system for consistent styling:

```css
:root {
  /* Core Variables */
  --font-family: 'Monaspace Argon', 'JetBrains Mono', monospace;
  --line-height: 1.20rem;
  --border-thickness: 2px;
  
  /* Colors */
  --text-color: #000;
  --text-color-alt: #666;
  --background-color: #fff;
  --background-color-alt: #eee;
  
  /* Font weights */
  --font-weight-normal: 500;
  --font-weight-medium: 600;
  --font-weight-bold: 800;
}
```

These variables are then reused throughout the stylesheet, ensuring consistency and making theme changes straightforward.

## Grid-Based Measurements

All measurements in our system are grid-based:

- **Horizontal spacing**: Measured in `ch` units (width of the '0' character)
- **Vertical spacing**: Multiples of `var(--line-height)`
- **Element widths**: Calculated to align with the character grid using functions like `calc(round(down, 100%, 1ch))`
- **Padding & margins**: Character-based (e.g., `padding: var(--line-height) 2ch`)

## Grid-Based Animations

### Animation Principles

For animations to respect the character grid:

1. **Discrete steps**: Use `steps()` timing function instead of smooth animations
2. **Character-based units**: Move in increments of `1ch` horizontally, `var(--line-height)` vertically
3. **Maintain grid alignment**: Elements should always align to the grid, even during animation
4. **Avoid breaking the grid**: Don't use animations that would cause elements to misalign

### Animation Types

#### Typewriter Effect

The typewriter animation reveals text one character at a time:

```css
@keyframes typewriter {
  from { width: 0; }
  to { width: 100%; }
}

.typewriter {
  display: inline-block;
  overflow: hidden;
  white-space: nowrap;
  margin: 0;
  animation: typewriter 2s steps(var(--char-count, 20)) 0.5s 1 normal both;
  border-right: var(--border-thickness) solid var(--text-color);
}
```

Usage:
```html
<p phx-hook="CharacterAnimation" class="typewriter">This text appears character by character.</p>
```

The JavaScript hook counts the characters and sets the `--char-count` CSS variable.

#### Character Fade In

This animation fades in each character separately:

```css
@keyframes char-fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

.char-fade {
  display: inline-block;
}

.char-fade span {
  display: inline-block;
  opacity: 0;
  animation: char-fade-in 0.1s ease-in-out forwards;
}
```

The JavaScript hook splits the text into individual character spans and applies sequential delays.

#### Grid Slide In

This animation slides content in character by character:

```css
@keyframes grid-slide-in {
  from { transform: translateX(-20ch); }
  to { transform: translateX(0); }
}

.grid-slide-in {
  animation: grid-slide-in 0.5s steps(20) forwards;
}
```

#### Cursor Blink

Simulates a terminal cursor:

```css
@keyframes blink-cursor {
  0%, 49% { opacity: 1; }
  50%, 100% { opacity: 0; }
}

.cursor-blink {
  display: inline-block;
  width: 1ch;
  height: var(--line-height);
  background-color: var(--text-color);
  animation: blink-cursor 1s step-end infinite;
  vertical-align: bottom;
}
```

#### ASCII Spinner

Uses ASCII characters for a loading spinner:

```css
@keyframes ascii-spinner {
  0% { content: '|'; }
  25% { content: '/'; }
  50% { content: '-'; }
  75% { content: '\\'; }
  100% { content: '|'; }
}

.ascii-spinner::after {
  content: '|';
  display: inline-block;
  width: 1ch;
  animation: ascii-spinner 1s steps(4) infinite;
}
```

#### Border Draw Animation

Animates a border drawing around content:

```css
@keyframes border-draw {
  0% {
    height: var(--line-height);
    width: 0;
  }
  25% {
    height: var(--line-height);
    width: 100%;
  }
  50% {
    height: 100%;
    width: 100%;
  }
  75% {
    height: 100%;
    width: var(--border-thickness);
  }
  100% {
    height: var(--line-height);
    width: var(--border-thickness);
  }
}

.border-draw {
  position: relative;
  padding: calc(var(--line-height) / 2) 1ch;
}

.border-draw::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: var(--border-thickness);
  height: var(--line-height);
  background-color: var(--text-color);
  animation: border-draw 3s steps(4) infinite;
}
```

#### Grid Fade In

Page transition that reveals content line by line:

```css
@keyframes grid-fade {
  0% {
    clip-path: inset(0 0 100% 0);
  }
  100% {
    clip-path: inset(0 0 0 0);
  }
}

.grid-fade-in {
  animation: grid-fade 0.5s steps(var(--line-count, 10)) forwards;
}
```

The JavaScript hook calculates the line count based on the element height.

## LiveView Hooks for Animations

LiveView hooks add the JavaScript functionality needed for some animations:

```javascript
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

// Grid fade-in effect for pages
Hooks.GridFadeIn = {
  mounted() {
    const lineCount = Math.ceil(this.el.offsetHeight / parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--line-height')));
    this.el.style.setProperty('--line-count', lineCount);
  }
};
```

## Debug Grid

The debug grid helps visualize the character grid for development:

```css
.debug .debug-grid {
  --color: color-mix(in srgb, var(--text-color) 10%, var(--background-color) 90%);
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: -1;
  background-image:
    repeating-linear-gradient(var(--color) 0 1px, transparent 1px 100%),
    repeating-linear-gradient(90deg, var(--color) 0 1px, transparent 1px 100%);
  background-size: 1ch var(--line-height);
  margin: 0;
}

.debug .off-grid {
  background: rgba(255, 0, 0, 0.1);
}
```

The debug grid toggle allows you to see which elements might be misaligned:

```html
<div class="debug-toggle">
  <label class="debug-toggle-label">
    <input type="checkbox" id="debug-grid-toggle" phx-hook="DebugGridToggle" /> 
    Show grid
  </label>
</div>
<div class="debug-grid" style="display: none;"></div>
```

## Creating Custom Components

When creating custom components for a monospace design:

1. **Maintain grid alignment**: All elements should align to the character grid
2. **Use CSS variables**: Leverage the existing variables for consistency
3. **Character-based measurements**: Use `ch` units and line-height multiples
4. **Simple structures**: Focus on typography and clean layouts

## Best Practices

1. **Test with the debug grid**: Use the debug grid to verify alignment
2. **Respect the rhythm**: Maintain consistent vertical rhythm with line-height multiples
3. **Stay minimal**: Avoid unnecessary decorative elements
4. **Functional animations**: Use animations that enhance usability, not distract
5. **Semantic HTML**: Use proper HTML elements for better accessibility
6. **Grid variations**: Use the `.grid` component for multi-column layouts

## Resources and Inspiration

- [The Monospace Web](https://github.com/owickstrom/the-monospace-web) - Original inspiration
- [Monaspace Fonts](https://github.com/githubnext/monaspace) - Character-aligned font family
- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view) - LiveView integration
- [MDN CSS Animations](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_animations) - Animation reference
