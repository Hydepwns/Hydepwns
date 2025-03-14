---
title: Component Guidelines
description: Standards and best practices for developing components in Hydepwns
topics:
  - development
  - components
  - guidelines
  - standards
  - best-practices
last_updated: '2025-03-14'
---

# Component Guidelines

## Overview

This guide outlines the standards and best practices for developing components in Hydepwns. Following these guidelines ensures consistency, maintainability, and high quality across the component ecosystem.

## Component Structure

### Basic Component

```elixir
defmodule Hydepwns.Components.Button do
  use HydepwnsWeb, :component
  
  prop label, :string, required: true
  prop type, :string, default: "button"
  prop size, :string, values: ~w(sm md lg)
  prop variant, :string, values: ~w(primary secondary ghost)
  prop disabled, :boolean, default: false
  prop class, :string, default: nil
  prop rest, :global
  
  def render(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "btn",
        "btn--#{@size}",
        "btn--#{@variant}",
        @class
      ]}
      disabled={@disabled}
      {@rest}
    >
      <%= @label %>
    </button>
    """
  end
end
```

### Component with Slots

```elixir
defmodule Hydepwns.Components.Card do
  use HydepwnsWeb, :component
  
  prop title, :string, required: true
  slot header
  slot default
  slot footer
  
  def render(assigns) do
    ~H"""
    <div class="card">
      <div class="card__header">
        <h3 class="card__title"><%= @title %></h3>
        <%= render_slot(@header) %>
      </div>
      
      <div class="card__body">
        <%= render_slot(@default) %>
      </div>
      
      <div class="card__footer">
        <%= render_slot(@footer) %>
      </div>
    </div>
    """
  end
end
```

## Naming Conventions

### Component Names

```elixir
# Good
defmodule Hydepwns.Components.DataTable
defmodule Hydepwns.Components.SearchInput
defmodule Hydepwns.Components.UserAvatar

# Bad
defmodule Hydepwns.Components.Dt # Too short
defmodule Hydepwns.Components.TheDataTable # Unnecessary prefix
defmodule Hydepwns.Components.Data.Table # Wrong nesting
```

### CSS Classes

```css
/* Component-specific classes */
.btn { /* Base styles */ }
.btn--primary { /* Variant */ }
.btn--sm { /* Size modifier */ }
.btn--disabled { /* State */ }

/* Utility classes */
.u-margin-top { /* Utility */ }
.u-text-center { /* Utility */ }
.u-hidden { /* Utility */ }
```

## Props and Slots

### Prop Definitions

```elixir
defmodule Hydepwns.Components.Input do
  use HydepwnsWeb, :component
  
  # Required props
  prop name, :string, required: true
  prop type, :string, required: true
  
  # Optional props with defaults
  prop value, :string, default: ""
  prop placeholder, :string, default: nil
  
  # Validated props
  prop size, :string, values: ~w(sm md lg)
  prop status, :string, values: ~w(default error success warning)
  
  # Boolean flags
  prop disabled, :boolean, default: false
  prop readonly, :boolean, default: false
  
  # Custom validation
  prop min_length, :integer, default: 0, doc: "Minimum input length"
  prop max_length, :integer, default: nil, doc: "Maximum input length"
  
  # Event handlers
  prop on_change, :event, default: nil
  prop on_blur, :event, default: nil
  
  # Global attributes
  prop rest, :global
end
```

### Slot Usage

```elixir
defmodule Hydepwns.Components.Dialog do
  use HydepwnsWeb, :component
  
  # Named slots
  slot header, required: true
  slot default
  slot footer
  
  # Slots with props
  slot action, props: [:label, :variant]
  
  def render(assigns) do
    ~H"""
    <div class="dialog">
      <div class="dialog__header">
        <%= render_slot(@header) %>
      </div>
      
      <div class="dialog__body">
        <%= render_slot(@default) %>
      </div>
      
      <div class="dialog__footer">
        <%= for action <- @action do %>
          <button class={"btn btn--#{action.variant}"}>
            <%= action.label %>
          </button>
        <% end %>
        <%= render_slot(@footer) %>
      </div>
    </div>
    """
  end
end
```

## State Management

### Component State

```elixir
defmodule Hydepwns.Components.Tabs do
  use HydepwnsWeb, :live_component
  
  prop tabs, :list, required: true
  prop active_tab, :string, default: nil
  
  def mount(socket) do
    {:ok, assign(socket, 
      active_tab: List.first(socket.assigns.tabs).id
    )}
  end
  
  def handle_event("change_tab", %{"tab" => tab_id}, socket) do
    {:noreply, assign(socket, active_tab: tab_id)}
  end
end
```

### State Updates

```elixir
defmodule Hydepwns.Components.Counter do
  use HydepwnsWeb, :live_component
  
  prop initial_value, :integer, default: 0
  prop min, :integer, default: nil
  prop max, :integer, default: nil
  
  def mount(socket) do
    {:ok, assign(socket, 
      value: socket.assigns.initial_value
    )}
  end
  
  def handle_event("increment", _, socket) do
    {:noreply, update(socket, :value, &increment_value(&1, socket.assigns))}
  end
  
  def handle_event("decrement", _, socket) do
    {:noreply, update(socket, :value, &decrement_value(&1, socket.assigns))}
  end
  
  defp increment_value(value, %{max: max}) when not is_nil(max) do
    min(value + 1, max)
  end
  
  defp decrement_value(value, %{min: min}) when not is_nil(min) do
    max(value - 1, min)
  end
end
```

## Event Handling

### Event Definitions

```elixir
defmodule Hydepwns.Components.Form do
  use HydepwnsWeb, :live_component
  
  # Define events
  prop on_submit, :event, required: true
  prop on_change, :event, default: nil
  prop on_reset, :event, default: nil
  
  def handle_event("submit", params, socket) do
    case validate_form(params) do
      {:ok, data} ->
        send_event(socket, :on_submit, data)
        {:noreply, socket}
        
      {:error, errors} ->
        {:noreply, assign(socket, errors: errors)}
    end
  end
end
```

### Event Propagation

```elixir
defmodule Hydepwns.Components.Select do
  use HydepwnsWeb, :live_component
  
  def handle_event("option_selected", %{"value" => value}, socket) do
    # Local state update
    socket = assign(socket, selected: value)
    
    # Notify parent
    send(self(), {:select_changed, value})
    
    {:noreply, socket}
  end
end
```

## Testing

### Component Tests

```elixir
defmodule Hydepwns.Components.ButtonTest do
  use HydepwnsWeb.ComponentCase
  
  test "renders button with label" do
    html = render_component(&Button.render/1,
      label: "Click me",
      type: "button"
    )
    
    assert html =~ "Click me"
    assert html =~ ~s(type="button")
  end
  
  test "applies variant classes" do
    html = render_component(&Button.render/1,
      label: "Primary",
      variant: "primary"
    )
    
    assert html =~ "btn--primary"
  end
  
  test "handles disabled state" do
    html = render_component(&Button.render/1,
      label: "Disabled",
      disabled: true
    )
    
    assert html =~ "disabled"
  end
end
```

### Integration Tests

```elixir
defmodule Hydepwns.Components.FormTest do
  use HydepwnsWeb.ConnCase
  
  test "submits form data", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/form")
    
    assert view
           |> element("form")
           |> render_submit(%{
             "user" => %{"name" => "Test User"}
           }) =~ "Form submitted successfully"
  end
end
```

## Performance

### Optimization Techniques

1. **Memoization**
   ```elixir
   def expensive_computation(value) do
     ConCache.get_or_store(:cache, "key:#{value}", fn ->
       # Expensive operation
     end)
   end
   ```

2. **Lazy Loading**
   ```elixir
   def mount(socket) do
     {:ok, assign(socket, data: nil),
      temporary_assigns: [data: nil]}
   end
   
   def handle_event("load", _, socket) do
     {:noreply, assign(socket, data: load_data())}
   end
   ```

3. **Batch Updates**
   ```elixir
   def handle_info({:batch_update, items}, socket) do
     socket =
       Enum.reduce(items, socket, fn item, acc ->
         update(acc, :items, &[item | &1])
       end)
     
     {:noreply, socket}
   end
   ```

## Documentation

### Component Documentation

```elixir
defmodule Hydepwns.Components.Pagination do
  @moduledoc """
  Pagination component for navigating through multiple pages of content.
  
  ## Examples
  
      <.pagination
        current_page={1}
        total_pages={10}
        on_page_change="change_page"
      />
  
  ## Props
  
  * `current_page` - Current active page number
  * `total_pages` - Total number of pages
  * `on_page_change` - Event triggered when page changes
  
  ## Slots
  
  * `prev_button` - Custom previous page button
  * `next_button` - Custom next page button
  """
  
  use HydepwnsWeb, :component
  
  # Props and implementation...
end
```

## References

- [Component Architecture](../../reference/architecture/component-architecture.md)
- [Enhanced Component System](../../reference/architecture/enhanced-component-system.md)
- [Robust Implementation](robust-implementation.md)
- [Component Patterns](patterns.md)
