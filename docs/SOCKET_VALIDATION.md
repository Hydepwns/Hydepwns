# Socket Validation System

This document describes the socket validation system implemented in the Hydepwns LiveView application. The system provides type validation, required assigns checking, and a debug panel for visualizing validation issues during development.

## Overview

The socket validation system consists of several components:

1. **SocketValidator** - Core validation logic for checking types and required assigns
2. **BaseLive** - Integration with LiveView lifecycle hooks
3. **SocketValidationPanel** - Debug UI for visualizing validation issues
4. **SocketValidationHelper** - Utility functions for interacting with the validation system

## Features

- **Type Validation** - Validates that socket assigns match their specified types
- **Required Assigns** - Ensures that required assigns are present
- **Nested Schema Validation** - Validates nested data structures
- **Union Types** - Supports validating union types (e.g., `integer | string`)
- **Telemetry Integration** - Emits telemetry events for validation failures
- **Debug Panel** - Visual interface for monitoring validation issues during development
- **Context-Aware Error Messages** - Provides helpful suggestions based on validation context

## Enhanced Error Reporting

The socket validation system now includes enhanced error reporting features:

### Context-Aware Error Messages

Error messages are now context-aware, providing specific suggestions based on the type of error and the current value:

- **Type Conversion Suggestions**: When a type error occurs, the system suggests specific conversion code examples
- **Schema Validation Help**: For schema validation errors, the system provides detailed field-by-field suggestions
- **Code Examples**: Includes ready-to-use code snippets that can be copied directly
- **Value History Analysis**: Shows recent values for the assign to help identify patterns
- **Intelligent Fix Generation**: Creates targeted fixes based on the specific error context

Example of a context-aware error message:

```
Invalid type for count: expected integer

Error in view: MyAppWeb.ExampleLive
Key: count
Current value: "42" (string)

## Suggested Fix

The string appears to be a valid integer.

```elixir
# Using String.to_integer/1
count = String.to_integer("42")  # 42

# In assign:
assign(socket, :count, String.to_integer("42"))
```

Specify the correct type in your type_specs/0 function:

```elixir
def type_specs do
  %{
    # ... other specs ...
    count: :integer,
    # ... other specs ...
  }
end
```

### Visualization Tools

The debug panel has been enhanced with new visualization features:

- **Error List View**: Shows all validation errors with filtering and sorting options
- **Assign Inspector**: Allows inspecting assigns in any LiveView
- **Metrics Dashboard**: Provides real-time metrics on validation errors
- **Fix Suggestions**: Offers quick-fix suggestions for common error patterns
- **Code Integration**: Provides buttons to copy fixes and find the relevant code

### Telemetry Integration

Enhanced telemetry integration provides better insights into validation issues:

- **Error Rate Tracking**: Monitors the rate of validation errors over time
- **Success Rate Tracking**: Tracks successful validations for comparison
- **View-Specific Metrics**: Identifies which views have the most validation issues
- **Error Type Distribution**: Shows the distribution of error types across the application
- **Time-Based Analysis**: Allows correlating validation issues with specific events or deployments

### How to Use the Enhanced Error Reporting

#### In Development

1. **Socket Validation Panel**: The enhanced panel is automatically included in development mode
   - Toggle the panel with the tab in the bottom-right corner
   - Switch between error list, assign inspector, metrics, and fix suggestions

2. **Copy and Apply Fixes**: 
   - Click "Copy Fix" to copy a suggested fix to the clipboard
   - Click "Apply Fix" in the Suggestions tab to automatically apply a fix

3. **Explore Patterns**:
   - The "Common Error Patterns" section shows recurring issues
   - Use the metrics view to identify problem areas in your application

#### In Production

1. **Telemetry Monitoring**:
   - Set up monitoring for the `hydepwns.socket.validation.*` telemetry events
   - Create alerts for sudden increases in error rates

2. **Logging**:
   - Validation errors are logged with appropriate severity levels
   - Concise error messages are used in production to avoid verbosity

3. **Performance Impact**:
   - Enhanced error reporting adds minimal overhead in production
   - Context-aware error generation is only active in development

### Customizing Error Reporting

You can customize the error reporting system:

```elixir
# In your config/dev.exs
config :hydepwns_liveview, :socket_validation,
  # Enable or disable enhanced error reporting
  enhanced_errors: true,
  
  # Configure behavior on validation failure
  # Options: :telemetry_only, :flash, :raise, or :log
  validation_behavior: :flash,
  
  # Maximum number of errors to keep in history
  max_errors: 50,
  
  # Enable or disable specific features
  features: %{
    context_aware_errors: true,
    debug_panel: true,
    telemetry: true
  }
```

## Usage

### Defining Types for LiveView Assigns

In your LiveView module, define a `type_specs/0` function that returns a map of assign keys to their expected types:

```elixir
defmodule MyAppWeb.ExampleLive do
  use MyAppWeb, :live_view
  
  # Define type specifications for assigns
  def type_specs do
    %{
      count: :integer,
      name: :string,
      items: {:list, :string},
      user: {:map, %{id: :integer, name: :string}},
      status: {:one_of, [:active, :inactive, :pending]},
      callback: :function
    }
  end
  
  # Define required assigns
  def required_assigns do
    [:count, :name]
  end
  
  # Rest of LiveView implementation...
end
```

### Supported Type Specifications

The following type specifications are supported:

- **Basic Types**: `:integer`, `:string`, `:boolean`, `:atom`, `:map`, `:list`, `:float`, `:function`
- **Lists with Type Spec**: `{:list, inner_type}` - A list where all elements match `inner_type`
- **Maps with Schema**: `{:map, schema}` - A map that matches the given schema
- **Union Types**: `{:one_of, [type1, type2, ...]}` - Value must match one of the specified types
- **Custom Validation**: `{:custom, validation_function}` - Custom validation function

### Debug Panel

The socket validation panel is automatically included in the application layout in development mode. It provides a visual interface for monitoring validation issues:

- Shows validation errors in real-time
- Displays error details including the error type, message, and context
- Allows toggling timestamps and details
- Provides controls for clearing errors and setting the maximum number of displayed errors

### Manual Testing

You can manually trigger validation errors for testing using the `SocketValidationHelper`:

```elixir
alias HydepwnsLiveview.Utils.SocketValidationHelper

# Broadcast a validation error
SocketValidationHelper.broadcast_error(
  MyAppWeb.HomeLive,
  :type_error,
  "Invalid type for :count",
  %{expected: "integer", got: "string"}
)

# Clear all errors
SocketValidationHelper.clear_errors()
```

## Telemetry

The validation system emits telemetry events when validation failures occur:

- `[:hydepwns, :socket, :validation, :error]` - Emitted when a validation error occurs
- `[:hydepwns, :socket, :validation, :type_error]` - Emitted specifically for type validation errors
- `[:hydepwns, :socket, :validation, :missing_key]` - Emitted when a required assign is missing

These events can be used for monitoring and alerting in production environments.

## Best Practices

1. **Define Types for All Assigns** - Even if not required, defining types for all assigns helps catch bugs early
2. **Use Nested Schemas** - For complex data structures, use nested schemas to validate the entire structure
3. **Add Custom Validations** - For complex validation logic, use custom validation functions
4. **Monitor Telemetry** - Set up monitoring for validation telemetry events in production
5. **Use the Debug Panel** - During development, keep the debug panel open to catch validation issues early

## Implementation Details

The socket validation system is implemented in the following files:

- `lib/hydepwns_liveview/utils/socket_validator.ex` - Core validation logic
- `lib/hydepwns_liveview/base_live.ex` - Integration with LiveView lifecycle
- `lib/hydepwns_liveview_web/components/debug/socket_validation_panel.ex` - Debug UI
- `lib/hydepwns_liveview/utils/socket_validation_helper.ex` - Helper functions
- `test/socket_validator/type_validation_test.exs` - Tests for the validation system

## Future Improvements

Planned improvements for the socket validation system:

- **AI-powered fix suggestions**: More intelligent fix generation based on codebase patterns
- **Test generation**: Automatic generation of tests for socket assigns validation
- **Static analysis**: Pre-runtime validation of LiveView modules for common issues
- **Schema visualization**: Visual representation of socket assign schemas
- **Performance optimization**: Further reducing the overhead of validation in production

## Changelog

### v1.3.9
- Added enhanced context-aware error messages with code examples
- Improved visualization tools in the debug panel
- Added comprehensive telemetry integration for validation metrics
- Implemented fix suggestions system for common error patterns

### v1.2.0
- Added initial socket validation system
- Implemented basic type validation for assigns
- Added required assigns checking
- Created simple debug panel for development

## Contributing

Contributions to the socket validation system are welcome! Here are some ways to contribute:

1. Improve error messages for specific types
2. Add support for more complex validation patterns
3. Enhance the debug panel and visualization tools
4. Add more telemetry metrics or reporting options

Please see the CONTRIBUTING.md file for guidelines on submitting pull requests.
