# Progress Bar Component

The Progress Bar component provides a visual indicator of progress for various operations. It supports different styles, animations, and can be controlled via JavaScript or LiveView events.

## Features

- Customizable appearance (colors, height, width)
- Support for striped and animated progress bars
- Optional percentage display
- Callback on completion
- Automatic cleanup of DOM elements and event listeners
- Dark mode support
- Accessible design with proper ARIA attributes

## Usage

### Basic Usage with LiveView

Add the ProgressBar hook to your LiveView template:

```html
<div id="progress-container" phx-hook="ProgressBar"></div>
```

Then, from your LiveView, push an event to update the progress:

```elixir
def handle_event("some_action", _params, socket) do
  # Do something...
  
  # Update progress
  {:noreply, push_event(socket, "update_progress", %{progress: 75})}
end
```

### JavaScript API

You can also use the ProgressBar component directly in JavaScript:

```javascript
// Import the component
import { ProgressBarComponent } from './components/progress_bar';

// Create a new progress bar
const progressBar = new ProgressBarComponent({
  container: document.getElementById('progress-container'),
  initialProgress: 25,
  height: '12px',
  color: '#3b82f6',
  backgroundColor: '#dbeafe'
}).mount();

// Update progress
progressBar.setProgress(50);

// Increment progress
progressBar.increment(10);

// Reset progress
progressBar.reset();
```

## Configuration Options

The ProgressBar component accepts the following configuration options:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `container` | HTMLElement | `document.body` | Container element for the progress bar |
| `initialProgress` | number | `0` | Initial progress value (0-100) |
| `height` | string | `'8px'` | Height of the progress bar |
| `width` | string | `'100%'` | Width of the progress bar container |
| `color` | string | `'var(--accent-color, #3b82f6)'` | Progress bar color |
| `backgroundColor` | string | `'var(--accent-color-light, #dbeafe)'` | Background color |
| `animated` | boolean | `true` | Whether to animate progress changes |
| `showPercentage` | boolean | `false` | Whether to show percentage text |
| `striped` | boolean | `false` | Whether to show striped pattern |
| `rounded` | boolean | `true` | Whether to use rounded corners |
| `onComplete` | function | `null` | Callback when progress reaches 100% |
| `debug` | boolean | `false` | Enable debug logging |

## Methods

The ProgressBar component provides the following methods:

### `setProgress(value)`

Sets the progress to a specific value (0-100).

```javascript
progressBar.setProgress(75);
```

### `increment(amount = 10)`

Increments the progress by a specified amount.

```javascript
progressBar.increment(10);
```

### `reset()`

Resets the progress to 0.

```javascript
progressBar.reset();
```

## LiveView Events

When used with LiveView, the ProgressBar component responds to the following events:

### `update_progress`

Updates the progress to a specific value.

```elixir
push_event(socket, "update_progress", %{progress: 75})
```

### `reset_progress`

Resets the progress to 0.

```elixir
push_event(socket, "reset_progress", %{})
```

## Styling

The ProgressBar component includes default styles, but you can customize its appearance using CSS variables or by overriding the following classes:

- `.progress-bar-container` - The outer container
- `.progress-bar` - The actual progress indicator
- `.progress-bar-striped` - Applied when using striped pattern
- `.progress-bar-animated` - Applied when using animation
- `.progress-bar-percentage` - The percentage text element
- `.progress-complete` - Applied when progress reaches 100%

## Accessibility

The ProgressBar component is designed with accessibility in mind:

- Uses appropriate ARIA attributes (`role="progressbar"`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax`)
- Provides sufficient color contrast
- Supports keyboard focus with visible focus indicators
- Announces progress changes to screen readers

## Implementation Details

The ProgressBar component is built using the robust component system, which ensures:

1. **Component Isolation**: Each progress bar instance has a unique ID and manages its own state
2. **Proper Cleanup**: All DOM elements and event listeners are properly cleaned up
3. **Event Management**: Uses the centralized EventManager for event handling
4. **DOM Cleanup**: Implements the DOM cleanup protocol for resource management

## Example

See the [Progress Bar Example](../../examples/components/progress_bar_example.html) for a complete demonstration of the ProgressBar component's capabilities. 