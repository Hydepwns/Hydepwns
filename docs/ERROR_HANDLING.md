# Error Handling Best Practices for Hydepwns Components

This guide outlines the error handling strategies employed in the Hydepwns UI component library,
providing developers with a consistent approach to handle errors across components.

## Core Principles

1. **Graceful Degradation**: Components should continue to function with reasonable defaults when errors occur.
2. **Explicit Error States**: Users should be informed about errors in a clear, non-technical manner.
3. **Defensive Coding**: Components should validate all inputs and handle edge cases.
4. **Recovery Mechanisms**: Components should provide mechanisms to recover from errors.
5. **Logging**: Errors should be logged for debugging purposes without exposing technical details to end users.

## Input Validation Patterns

### Parameter Validation

All component inputs should be validated before use:

```elixir
# Example from DiagramEditor component
defp safe_dimension(value, default, min, max) do
  cond do
    is_nil(value) -> default
    is_binary(value) ->
      case Integer.parse(value) do
        {num, _} when num >= min and num <= max -> num
        {num, _} when num < min -> min
        {num, _} when num > max -> max
        :error -> default
      end
    is_integer(value) ->
      cond do
        value < min -> min
        value > max -> max
        true -> value
      end
    true -> default
  end
end
```

### Type Safety

Always check that values are of expected types before operating on them:

```elixir
if is_binary(content) do
  # Process content
else
  # Handle invalid content
  ""
end
```

## Error Recovery Strategies

### Try/Rescue Pattern

Use try/rescue blocks for operations that might fail:

```elixir
try do
  execute_command(command, socket.assigns)
rescue
  e ->
    error_message = "An error occurred: #{Exception.message(e)}"
    {[%{type: :error, content: error_message}], :error}
catch
  kind, reason ->
    error_message = "Unexpected #{kind}: #{inspect(reason)}"
    {[%{type: :error, content: error_message}], :error}
end
```

### Default Values

Always provide sensible defaults to fall back on:

```elixir
def update(assigns, socket) do
  # Code that may fail...
rescue
  e ->
    # Fall back to safe defaults
    {:ok, 
      socket
      |> assign(:content, "Error initializing component. Please try again.")
      |> assign(:error, "Initialization error: #{Exception.message(e)}")
    }
end
```

## User Feedback

### Error Messages

Present clear, action-oriented error messages:

```elixir
# Bad
"Error: Failed to parse JSON data. TypeError: Cannot read property of undefined"

# Good
"We couldn't load your saved configuration. Try refreshing the page or uploading a different file."
```

### Visual Indicators

Use consistent visual patterns for errors:

```elixir
<%= if @error do %>
  <div class="component-error">
    <%= @error %>
  </div>
<% end %>
```

## Security Considerations

### Input Sanitization

Sanitize user input to prevent injection attacks:

```elixir
# Limit text length for security
safe_content = String.slice(content, 0, 10000)
```

### Error Information Disclosure

Avoid exposing sensitive information in error messages:

```elixir
# Bad
"Database connection failed: mysql://user:password@localhost/db"

# Good
"We couldn't connect to our database. Please try again later."
```

## Testing Error Scenarios

Always include tests for error conditions:

```elixir
test "handles invalid input gracefully" do
  {:ok, view, _html} = live_isolated_component(MyComponent, %{input: :invalid_input})
  assert has_element?(view, ".error-message")
  assert element_text(view, ".error-message") =~ "Invalid input"
end
```

## Implementing Error Handling

### Component Lifecycle

Add error handling at each stage of the component lifecycle:

1. **Mount/Update**: Validate and sanitize inputs
2. **Handle Event**: Protect against malformed events
3. **Render**: Handle missing or invalid assigns

### Error Boundary Pattern

For complex components, implement error boundaries:

```elixir
def render(assigns) do
  ~H"""
  <div class="error-boundary">
    <%= if @error do %>
      <div class="error-fallback">
        <h3>Something went wrong</h3>
        <p><%= @error_message %></p>
        <button phx-click="reset_component" phx-target={@myself}>Try Again</button>
      </div>
    <% else %>
      <%= render_content(assigns) %>
    <% end %>
  </div>
  """
end
```

## Conclusion

By following these error handling best practices, we create a more robust, user-friendly application that gracefully handles unexpected situations while providing clear guidance to users when things go wrong.
