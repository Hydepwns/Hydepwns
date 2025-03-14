# Tooltip Component

The Tooltip component provides contextual information when users hover over or focus on an element. It supports different positions, themes, and can be controlled via JavaScript or LiveView events.

## Features

- Customizable appearance (themes, positions, arrow)
- Configurable show/hide delays
- Interactive tooltips that can be hovered
- Automatic positioning based on available space
- Proper cleanup of DOM elements and event listeners
- Dark mode support
- Accessible design with proper ARIA attributes

## Usage

### Basic Usage with LiveView

Add the Tooltip hook to your LiveView template:

```html
<button 
  id="help-button" 
  phx-hook="Tooltip" 
  data-tooltip="This is a helpful tooltip"
  data-tooltip-position="top"
>
  Help
</button>
```

You can also update the tooltip content dynamically from your LiveView:

```elixir
def handle_event("update_help", _params, socket) do
  # Update tooltip content
  {:noreply, push_event(socket, "update_tooltip_content", %{content: "New tooltip content"})}
end
```

### JavaScript API

You can also use the Tooltip component directly in JavaScript:

```javascript
// Import the component
import { TooltipComponent } from './components/tooltip';

// Create a new tooltip
const tooltip = new TooltipComponent({
  container: document.body,
  target: document.getElementById('help-button'),
  content: 'This is a helpful tooltip',
  position: 'top',
  theme: 'primary'
}).mount();

// Show tooltip programmatically
tooltip.show();

// Hide tooltip
tooltip.hide();

// Update tooltip content
tooltip.updateContent('New tooltip content');
```

## Configuration Options

The Tooltip component accepts the following configuration options:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `container` | HTMLElement | `document.body` | Container element for the tooltip |
| `target` | HTMLElement | `null` | Element to attach tooltip to |
| `content` | string | `''` | Tooltip content (string or HTML) |
| `position` | string | `'top'` | Position of tooltip (top, right, bottom, left) |
| `offset` | number | `8` | Distance from target in pixels |
| `showDelay` | number | `200` | Delay before showing tooltip (ms) |
| `hideDelay` | number | `200` | Delay before hiding tooltip (ms) |
| `theme` | string | `'default'` | Theme (default, light, dark, primary, success, warning, error) |
| `maxWidth` | string | `'200px'` | Maximum width of tooltip |
| `arrow` | boolean | `true` | Whether to show arrow |
| `interactive` | boolean | `false` | Whether tooltip is interactive (can be hovered) |
| `debug` | boolean | `false` | Enable debug logging |

## Methods

The Tooltip component provides the following methods:

### `show()`

Shows the tooltip after the configured delay.

```javascript
tooltip.show();
```

### `hide()`

Hides the tooltip after the configured delay.

```javascript
tooltip.hide();
```

### `updateContent(content)`

Updates the tooltip content.

```javascript
tooltip.updateContent('New tooltip content');
```

## LiveView Events

When used with LiveView, the Tooltip component responds to the following events:

### `show_tooltip`

Shows the tooltip.

```elixir
push_event(socket, "show_tooltip", %{})
```

### `hide_tooltip`

Hides the tooltip.

```elixir
push_event(socket, "hide_tooltip", %{})
```

### `update_tooltip_content`

Updates the tooltip content.

```elixir
push_event(socket, "update_tooltip_content", %{content: "New tooltip content"})
```

## Styling

The Tooltip component includes default styles, but you can customize its appearance using CSS variables or by overriding the following classes:

- `.tooltip` - The tooltip container
- `.tooltip-arrow` - The tooltip arrow
- `.tooltip-{theme}` - Theme-specific styles (e.g., `.tooltip-primary`)
- `.tooltip-{position}` - Position-specific styles (e.g., `.tooltip-top`)

### CSS Variables

You can customize the tooltip appearance by setting these CSS variables:

```css
:root {
  --tooltip-bg-default: #333;
  --tooltip-text-default: #fff;
  --tooltip-border-default: transparent;
  --tooltip-shadow-default: 0 2px 8px rgba(0, 0, 0, 0.15);
  
  /* Theme-specific variables */
  --tooltip-bg-light: #fff;
  --tooltip-text-light: #333;
  --tooltip-border-light: #e2e8f0;
  
  --tooltip-bg-dark: #1a202c;
  --tooltip-text-dark: #f7fafc;
  
  --tooltip-bg-primary: #3b82f6;
  --tooltip-text-primary: #fff;
  
  --tooltip-bg-success: #10b981;
  --tooltip-text-success: #fff;
  
  --tooltip-bg-warning: #f59e0b;
  --tooltip-text-warning: #fff;
  
  --tooltip-bg-error: #ef4444;
  --tooltip-text-error: #fff;
  
  /* Z-index */
  --z-index-tooltip: 9000;
}
```

## Accessibility

The Tooltip component is designed with accessibility in mind:

- Uses appropriate ARIA attributes (`aria-describedby`)
- Provides sufficient color contrast
- Supports keyboard focus with visible focus indicators
- Can be triggered by both hover and focus events
- Includes screen reader support

### Keyboard Support

- **Tab**: Focus on elements with tooltips
- **Escape**: Dismiss tooltip when focused on the trigger element

## Implementation Details

The Tooltip component is built using the robust component system, which ensures:

1. **Component Isolation**: Each tooltip instance has a unique ID and manages its own state
2. **Proper Cleanup**: All DOM elements and event listeners are properly cleaned up
3. **Event Management**: Uses the centralized EventManager for event handling
4. **DOM Cleanup**: Implements the DOM cleanup protocol for resource management

## Example

Here's a complete example of using the Tooltip component in a LiveView template:

```html
<div class="tooltip-example">
  <h3>Tooltip Examples</h3>
  
  <div class="tooltip-demo-row">
    <button 
      class="btn has-tooltip" 
      phx-hook="Tooltip" 
      data-tooltip="Default tooltip position (top)"
    >
      Default
    </button>
    
    <button 
      class="btn has-tooltip" 
      phx-hook="Tooltip" 
      data-tooltip="Tooltip on the right"
      data-tooltip-position="right"
    >
      Right
    </button>
    
    <button 
      class="btn has-tooltip" 
      phx-hook="Tooltip" 
      data-tooltip="Tooltip on the bottom"
      data-tooltip-position="bottom"
    >
      Bottom
    </button>
    
    <button 
      class="btn has-tooltip" 
      phx-hook="Tooltip" 
      data-tooltip="Tooltip on the left"
      data-tooltip-position="left"
    >
      Left
    </button>
  </div>
  
  <div class="tooltip-demo-row">
    <button 
      class="btn has-tooltip" 
      phx-hook="Tooltip" 
      data-tooltip="Primary theme tooltip"
      data-tooltip-theme="primary"
    >
      Primary
    </button>
    
    <button 
      class="btn has-tooltip" 
      phx-hook="Tooltip" 
      data-tooltip="Success theme tooltip"
      data-tooltip-theme="success"
    >
      Success
    </button>
    
    <button 
      class="btn has-tooltip" 
      phx-hook="Tooltip" 
      data-tooltip="Warning theme tooltip"
      data-tooltip-theme="warning"
    >
      Warning
    </button>
    
    <button 
      class="btn has-tooltip" 
      phx-hook="Tooltip" 
      data-tooltip="Error theme tooltip"
      data-tooltip-theme="error"
    >
      Error
    </button>
  </div>
  
  <div class="tooltip-demo-row">
    <button 
      class="btn has-tooltip" 
      phx-hook="Tooltip" 
      data-tooltip="<strong>HTML content</strong> is supported"
      data-tooltip-theme="light"
    >
      HTML Content
    </button>
    
    <button 
      class="btn has-tooltip" 
      phx-hook="Tooltip" 
      data-tooltip="This tooltip can be hovered"
      data-tooltip-interactive
    >
      Interactive
    </button>
  </div>
</div>
``` 