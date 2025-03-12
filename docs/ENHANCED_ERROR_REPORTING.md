# Enhanced Error Reporting System

This document describes the enhanced error reporting system for Socket Validation in the Hydepwns LiveView application. The system provides detailed, context-aware error messages with actionable suggestions and integrates with the Debug Grid for visual error indicators.

## Overview

The enhanced error reporting system builds on the existing Socket Validation system by adding:

1. **Context-Aware Error Messages** - Error messages that analyze the validation context and provide tailored suggestions
2. **Code Examples** - Practical code snippets that demonstrate how to fix validation issues
3. **Lifecycle Detection** - Recognition of which LiveView lifecycle phase an error occurs in
4. **Debug Grid Integration** - Visual indicators in the Debug Grid showing validation status
5. **Improved Telemetry** - Enhanced telemetry for monitoring validation failures

## Features

### Context-Aware Error Messages

Error messages now provide detailed context and suggestions based on:

- The current validation error type
- The expected type vs. actual value
- Historical values (pattern detection)
- LiveView lifecycle context
- Common conversion patterns

Example:

```
Invalid type for count: expected integer in MyAppWeb.CounterLive
Current value: "42" (string)

Suggestion:
Convert the string to an integer:

```elixir
# Using String.to_integer/1
count = String.to_integer("42")  # 42

# In assign:
assign(socket, :count, String.to_integer("42"))
```

LiveView Context:
- Current lifecycle phase: handle_event
- View module: MyAppWeb.CounterLive
```

### Error Visualization in Debug Grid

The Debug Grid now displays validation issues with:

- Overall validation status indicator
- Per-assign validation results
- Visual highlighting of UI elements with validation errors
- Integration with the existing Socket Validation Panel

### Type Validation History

The system now tracks:

- Historical assign values for pattern detection
- Lifecycle context for more relevant suggestions
- Type error patterns for better diagnostic information

## Usage

### In Your LiveView

The enhanced error reporting is automatically enabled for any LiveView that uses the `BaseLive` module:

```elixir
defmodule MyAppWeb.ExampleLive do
  use HydepwnsLiveviewWeb.BaseLive, 
    required_assigns: [:user_id, :theme],
    type_specs: %{
      user_id: :string,
      theme: {:one_of, ["dark", "light", "dim"]},
      settings: %{notifications: :boolean}
    }
  
  def do_mount(_params, session, socket) do
    socket
    |> assign(:user_id, Map.get(session, "user_id"))
    |> assign(:theme, Map.get(session, "theme", "dark"))
    |> assign(:settings, %{notifications: true})
  end
  
  # Your LiveView implementation...
end
```

To enable data-attribute marking for UI elements (for highlighting):

```html
<p>Count: <span data-assign="count"><%= @count %></span></p>
```

This allows the Debug Grid to highlight the UI element when there's a validation error.

### Debug Grid Integration

The Debug Grid integration is automatically enabled for all LiveViews that use the `BaseLive` module. You can disable it with:

```elixir
use HydepwnsLiveviewWeb.BaseLive, 
  enable_debug_grid: false,
  # other options...
```

### Manual Use

For direct access to context-aware error messages:

```elixir
alias HydepwnsLiveview.Utils.SocketValidator

# Generate context-aware error message
{:error, message, _} = SocketValidator.type_validation(socket, :count, :integer)
context_message = SocketValidator.context_aware_error(message, :count, socket)

# Log the message or display it to the user
Logger.warning(context_message)
```

For manual Debug Grid integration:

```elixir
alias HydepwnsLiveview.Utils.SocketValidationDebugGrid

# Inject validation data into Debug Grid
socket = SocketValidationDebugGrid.inject_validation_data(
  socket,
  %{count: :integer, name: :string},
  [:count, :name]
)

# Highlight UI elements with validation errors
socket = SocketValidationDebugGrid.highlight_validation_errors(socket)
```

## Implementation Details

The enhanced error reporting system is implemented in the following files:

- `lib/hydepwns_liveview/utils/socket_validator.ex` - Core validation logic with enhanced error reporting
- `lib/hydepwns_liveview/utils/socket_validation_debug_grid.ex` - Debug Grid integration
- `lib/hydepwns_liveview_web/components/debug/socket_validation_grid.ex` - Visual component for the Debug Grid
- `lib/hydepwns_liveview_web/live/base_live.ex` - Integration with LiveView lifecycle

## Best Practices

1. **Use Clear Assign Names** - Choose descriptive assign names that reflect their purpose
2. **Add data-assign Attributes** - Add data-assign attributes to UI elements to enable highlighting
3. **Set Appropriate Type Specs** - Be specific with type specs to get better error messages
4. **Review Debug Grid During Development** - Keep the Debug Grid open to catch validation issues
5. **Track Telemetry in Production** - Set up monitoring for validation events in production

## Future Improvements

- Add static analysis for LiveView assigns
- Implement machine learning for pattern detection in validation errors
- Create a schema generator based on validation errors
- Enhance visual error highlighting with more contextual information 