# Toast Component

The Toast component provides lightweight, temporary notification toasts that appear briefly and then disappear. It's designed for simple success/error/info messages that don't require user interaction.

## Features

- Multiple toast types: success, error, info, warning
- Configurable position: top-right, top-center, top-left, bottom-right, bottom-center, bottom-left
- Customizable duration
- Maximum toast limit with automatic management
- Automatic cleanup of DOM elements and event listeners
- Dark mode support
- Accessible design with proper ARIA attributes

## Usage

### Basic Usage with LiveView

Add the Toast hook to your LiveView template:

```html
<div id="toast-container" phx-hook="Toast"></div>
```

Then, from your LiveView, push an event to show a toast:

```elixir
def handle_event("some_action", _params, socket) do
  # Do something...
  
  # Show a success toast
  {:noreply, push_event(socket, "show_toast", %{
    message: "Operation completed successfully!",
    type: "success"
  })}
end
```

### JavaScript API

You can also use the Toast component directly in JavaScript:

```javascript
// Get the toast component from the hook
const toastContainer = document.getElementById('toast-container');
const toast = toastContainer._phxHook.component;

// Show different types of toasts
toast.success('Operation completed successfully!');
toast.error('An error occurred. Please try again.');
toast.info('Here is some useful information.');
toast.warning('Warning: This action cannot be undone.');

// With custom options
toast.show({
  message: 'Custom toast message',
  type: 'info',
  duration: 5000 // 5 seconds
});

// Hide a specific toast
const toastId = toast.show({ message: 'This will be hidden' });
toast.hide(toastId);

// Clear all toasts
toast.clearAll();
```

## Configuration Options

The Toast component accepts the following configuration options:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `container` | HTMLElement | `document.body` | Container element for the toast |
| `position` | string | `'bottom-center'` | Position of the toast container |
| `duration` | number | `3000` | Default display duration in milliseconds |
| `maxToasts` | number | `3` | Maximum number of toasts to show at once |
| `gap` | number | `8` | Gap between toasts in pixels |
| `zIndex` | number | `9000` | z-index for the toast container |
| `debug` | boolean | `false` | Enable debug logging |

## Toast Types

The component supports four types of toasts, each with its own styling:

- **Success**: Green background, used for successful operations
- **Error**: Red background, used for error messages
- **Info**: Blue background, used for informational messages
- **Warning**: Yellow/orange background, used for warning messages

## Accessibility

The Toast component is designed with accessibility in mind:

- Uses proper ARIA attributes (`role="alert"`)
- Provides a close button with accessible label
- Ensures sufficient color contrast for all toast types
- Supports keyboard navigation for dismissing toasts

## Implementation Details

The Toast component is built using the robust component system, which ensures:

1. **Component Isolation**: Each toast instance has a unique ID and manages its own state
2. **Proper Cleanup**: All DOM elements and event listeners are properly cleaned up
3. **Event Management**: Uses the centralized EventManager for event handling
4. **DOM Cleanup**: Implements the DOM cleanup protocol for resource management

## Example

See the [Toast Example](../../examples/components/toast_example.html) for a complete demonstration of the Toast component's capabilities. 