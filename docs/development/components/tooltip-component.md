---
title: Tooltip-Component
description: '## Overview'
topics:
  - development
  - components
  - tooltip-component
  - overview
  - prerequisites
  - main-content
  - troubleshooting
  - related-documents
  - features
  - usage
  - configuration-options
  - accessibility
  - implementation-details
  - css-customization
  - examples
  - browser-support
  - dependencies
  - event-handling
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Tooltip-Component

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

This document provides information about Tooltip-Component.


---
title: Tooltip Component
description: Implementation guide for the customizable tooltip component for displaying helpful information
category: development
subcategory: components
order: 5
---

# Tooltip Component

The Tooltip component provides a configurable way to display additional information or context when users hover over or focus on an element. It supports multiple positioning options, custom styling, and ensures accessibility compliance.

## Features

- Multiple positions: top, right, bottom, left, with alignment options
- Custom themes and styling via CSS variables
- Automatic positioning to stay within viewport
- Arrow indicator that points to the target element
- Accessible focus management and keyboard navigation
- Animation options with configurable timing
- Support for HTML content and rich formatting
- Delay options for showing and hiding
- Integration with the component system for proper cleanup

## Usage

### Basic Usage with LiveView

Add the Tooltip hook to your LiveView template:

```html
<div class="tooltip-container">
  <button 
    id="help-button" 
    aria-describedby="help-tooltip"
    data-tooltip-target="help-tooltip">
    Help
  </button>
  
  <div 
    id="help-tooltip" 
    class="tooltip" 
    role="tooltip"
    data-position="top"
    phx-hook="Tooltip">
    Click for additional help information
  </div>
</div>
```markdown

### JavaScript Configuration

```javascript
// Global configuration (optional)
window.HydepwnsConfig = window.HydepwnsConfig || {};
window.HydepwnsConfig.tooltips = {
  defaultPosition: 'bottom',
  showDelay: 200,
  hideDelay: 100,
  animation: true,
  animationDuration: 300
};
```markdown

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `data-position` | String | `"top"` | Tooltip position: `"top"`, `"right"`, `"bottom"`, `"left"` |
| `data-alignment` | String | `"center"` | Alignment within position: `"start"`, `"center"`, `"end"` |
| `data-show-delay` | Number | `200` | Delay before showing tooltip (ms) |
| `data-hide-delay` | Number | `100` | Delay before hiding tooltip (ms) |
| `data-animate` | Boolean | `true` | Whether to animate tooltip |
| `data-animation-duration` | Number | `300` | Duration of animation (ms) |
| `data-max-width` | String | `"20rem"` | Maximum width of tooltip |
| `data-interactive` | Boolean | `false` | Whether tooltip is interactive (can receive focus/clicks) |
| `data-offset` | Number | `8` | Offset from target element (px) |
| `data-auto-hide` | Boolean | `true` | Auto-hide on mouseout/blur |

## Accessibility

The Tooltip component follows accessibility best practices:

- Uses `role="tooltip"` attribute
- Associates tooltip with target using `aria-describedby`
- Ensures keyboard accessibility for focus and navigation
- Manages focus appropriately for interactive tooltips
- Uses appropriate contrast for visibility
- Handles screen reader announcements correctly

## Implementation Details

### Component Structure

```html
<div class="tooltip-container">
  <!-- Target element -->
  <button id="example-button" aria-describedby="example-tooltip" data-tooltip-target="example-tooltip">
    Help
  </button>
  
  <!-- Tooltip element -->
  <div id="example-tooltip" class="tooltip" role="tooltip" data-position="top">
    <div class="tooltip__content">
      Helpful information goes here
    </div>
    <div class="tooltip__arrow"></div>
  </div>
</div>
```markdown

### Technical Implementation

The Tooltip component uses the following technical approaches:

- Leverages the Popper.js positioning engine for accurate placement
- Implements event delegation for performance with multiple tooltips
- Uses IntersectionObserver to detect when tooltips are in viewport
- Manages event listeners according to component lifecycle
- Implements custom positioning logic when needed
- Uses CSS transitions for smooth animations
- Follows the component system patterns for initialization and cleanup

## CSS Customization

Tooltips can be customized with CSS variables:

```css
.tooltip {
  --tooltip-bg-color: var(--color-tooltip-bg, #333);
  --tooltip-text-color: var(--color-tooltip-text, #fff);
  --tooltip-border-radius: 4px;
  --tooltip-padding: 0.5rem 0.75rem;
  --tooltip-font-size: 0.875rem;
  --tooltip-line-height: 1.4;
  --tooltip-arrow-size: 6px;
  --tooltip-drop-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
}

.tooltip--info {
  --tooltip-bg-color: var(--color-info-500);
}

.tooltip--warning {
  --tooltip-bg-color: var(--color-warning-500);
}

.tooltip--error {
  --tooltip-bg-color: var(--color-error-500);
}
```markdown

## Examples

### Basic Usage

```html
<button data-tooltip-target="basic-tooltip">Hover me</button>
<div id="basic-tooltip" class="tooltip" phx-hook="Tooltip">Simple tooltip content</div>
```markdown

### Bottom Positioned with Delay

```html
<button data-tooltip-target="delayed-tooltip">Hover with delay</button>
<div id="delayed-tooltip" 
     class="tooltip" 
     data-position="bottom" 
     data-show-delay="500" 
     phx-hook="Tooltip">
  This tooltip appears after a 500ms delay
</div>
```markdown

### Interactive Tooltip with Rich Content

```html
<button data-tooltip-target="interactive-tooltip">Interactive tooltip</button>
<div id="interactive-tooltip" 
     class="tooltip tooltip--interactive" 
     data-interactive="true"
     data-auto-hide="false"
     phx-hook="Tooltip">
  <h4>Interactive Tooltip</h4>
  <p>This tooltip contains interactive elements.</p>
  <button class="tooltip__close-btn">Close</button>
</div>
```markdown

### Custom Styled Tooltip

```html
<button data-tooltip-target="custom-tooltip">Custom styled</button>
<div id="custom-tooltip" 
     class="tooltip tooltip--custom" 
     style="--tooltip-bg-color: #6200ee; --tooltip-max-width: 15rem;"
     phx-hook="Tooltip">
  This tooltip has custom styling
</div>
```markdown

## Browser Support

- Chrome 60+
- Firefox 55+
- Safari 11+
- Edge 16+

## Dependencies

- Component system core modules
- Optional: Popper.js for advanced positioning

## Event Handling

The Tooltip component listens for and manages these events:

- `mouseenter`/`mouseleave` on target element
- `focus`/`blur` on target element
- `keydown` events for keyboard navigation
- `click` events for interactive tooltips
- `resize` and `scroll` events for repositioning

All events are properly cleaned up when the component is destroyed, following the component system guidelines. 

## References

- [Project Documentation](../README.md)
