# Component Documentation Template

This document provides a standardized template for documenting components in the Hydepwns application. Use this format when adding or updating component documentation.

## Module Documentation Header

Every component module should include a comprehensive documentation header following this format:

```elixir
@moduledoc """
# ComponentName

Provides a brief one-line description of what the component does.

## Overview

A paragraph or two describing the component's purpose, functionality, and use cases.
Explain when this component should be used and its key features.

## Examples

```heex
<ComponentName.function
  attr1="value"
  attr2={value}
/>
```

## Props/Attributes

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `attr1` | `string` | `nil` | Yes | Description of the attribute |
| `attr2` | `any` | `nil` | No | Description of the attribute |

## Accessibility

Information about the component's accessibility features, including:
- ARIA attributes used
- Keyboard navigation support
- Screen reader considerations
- Color contrast requirements

## Theming

How the component can be styled or themed, including:
- CSS variables that affect the component
- Theme-specific variations
- Custom class options

## Browser Compatibility

Any browser-specific considerations or limitations.

## Related Components

List of related components that are often used together with this component.

## Changelog

| Version | Changes |
|---------|---------|
| 0.1.0   | Initial implementation |
"""
```

## Function Documentation Format

Every public function should include detailed documentation following this format:

```elixir
@doc """
Brief description of what the function does.

## Examples

```heex
<ComponentName.function
  attr1="value"
  attr2={value}
/>
```

## Attributes

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `attr1` | `string` | `nil` | Yes | Description of the attribute |
| `attr2` | `any` | `nil` | No | Description of the attribute |

## Slots

| Name | Description |
|------|-------------|
| `:default` | The default slot for content |
| `:header` | Header content slot |

## Returns

HEEx template rendering the component.
"""
```

## TypeSpec Format

Every public function should have a typespec that defines its expected inputs and outputs:

```elixir
@spec function_name(map()) :: Phoenix.LiveView.Rendered.t()
```

## Recommended Module Structure

For consistency, follow this structure for component modules:

1. Module documentation
2. Use statements and aliases
3. Attribute definitions
4. Type definitions
5. Public functions with documentation
6. Private helper functions

## Example Implementation

Here's an example implementation following the template:

```elixir
defmodule HydepwnsLiveviewWeb.Components.Common.Example do
  @moduledoc """
  # Example

  Provides a simple example component for demonstration purposes.

  ## Overview

  The Example component serves as a demonstration of proper documentation
  and implementation patterns. It displays content within a styled container.

  ## Examples

  ```heex
  <Example.container id="my-example" theme="dark">
    Your content here
  </Example.container>
  ```

  ## Props/Attributes

  | Name | Type | Default | Required | Description |
  |------|------|---------|----------|-------------|
  | `id` | `string` | `nil` | Yes | Unique identifier for the component |
  | `theme` | `string` | `"light"` | No | Theme variant (light, dark, dim) |

  ## Accessibility

  This component includes appropriate ARIA attributes for accessibility.
  """
  use Phoenix.Component
  
  @doc """
  Renders an example container.

  ## Examples

  ```heex
  <Example.container id="my-example" theme="dark">
    Your content here
  </Example.container>
  ```

  ## Attributes

  | Name | Type | Default | Required | Description |
  |------|------|---------|----------|-------------|
  | `id` | `string` | `nil` | Yes | Unique identifier for the component |
  | `theme` | `string` | `"light"` | No | Theme variant (light, dark, dim) |

  ## Slots

  | Name | Description |
  |------|-------------|
  | `:default` | The default slot for content |

  ## Returns

  HEEx template rendering the example container.
  """
  @spec container(map()) :: Phoenix.LiveView.Rendered.t()
  def container(assigns) do
    assigns = assign_new(assigns, :theme, fn -> "light" end)
    
    ~H"""
    <div id={@id} class={"example example--#{@theme}"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
  
  # Private helper functions
  defp some_helper(value) do
    # Implementation
  end
end 