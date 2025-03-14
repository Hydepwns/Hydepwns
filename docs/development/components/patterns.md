---
title: Component Patterns
description: Common patterns and implementations for components in Hydepwns
topics:
  - development
  - components
  - patterns
  - architecture
  - best-practices
last_updated: '2025-03-14'
---

# Component Patterns

## Overview

This guide documents common patterns used in Hydepwns components, providing examples and best practices for implementation.

## Core Patterns

### 1. Compound Components

Components that work together to create a more complex UI pattern.

```elixir
defmodule Hydepwns.Components.Select do
  use Hydepwns.Components.Base
  
  # Main component
  def select(assigns) do
    ~H"""
    <div class="select" {@rest}>
      <%= render_slot(@trigger) %>
      <%= render_slot(@options) %>
    </div>
    """
  end
  
  # Trigger component
  def trigger(assigns) do
    ~H"""
    <button class="select-trigger" phx-click="toggle">
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
  
  # Options component
  def options(assigns) do
    ~H"""
    <div class="select-options" :if={@show}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end

# Usage example
<Select.select>
  <:trigger>Select Option</:trigger>
  <:options>
    <div>Option 1</div>
    <div>Option 2</div>
  </:options>
</Select.select>
```

### 2. Controlled Components

Components that delegate their state management to the parent.

```elixir
defmodule Hydepwns.Components.Input do
  use Hydepwns.Components.Base
  
  prop value, :string, required: true
  prop on_change, :function, required: true
  
  def input(assigns) do
    ~H"""
    <input
      type="text"
      value={@value}
      phx-change="handle_change"
      phx-target={@myself}
    />
    """
  end
  
  def handle_event("handle_change", %{"value" => value}, socket) do
    socket.assigns.on_change.(value)
    {:noreply, socket}
  end
end

# Usage example
<Input
  value={@input_value}
  on_change={fn value -> send(self(), {:update_value, value}) end}
/>
```

### 3. Render Props

Components that accept render functions as props.

```elixir
defmodule Hydepwns.Components.List do
  use Hydepwns.Components.Base
  
  prop items, :list, required: true
  prop render_item, :function, required: true
  
  def list(assigns) do
    ~H"""
    <div class="list">
      <%= for item <- @items do %>
        <%= @render_item.(item) %>
      <% end %>
    </div>
    """
  end
end

# Usage example
<List
  items={@users}
  render_item={fn user ->
    ~H"""
    <div class="user-item">
      <img src={user.avatar} />
      <span><%= user.name %></span>
    </div>
    """
  }
/>
```

### 4. Higher-Order Components

Components that wrap other components with additional functionality.

```elixir
defmodule Hydepwns.Components.WithLoading do
  use Hydepwns.Components.Base
  
  prop loading, :boolean, default: false
  prop component, :any, required: true
  prop component_props, :map, default: %{}
  
  def with_loading(assigns) do
    ~H"""
    <div class="with-loading">
      <%= if @loading do %>
        <div class="loading-spinner" />
      <% else %>
        <%= render_component(@component, @component_props) %>
      <% end %>
    </div>
    """
  end
end

# Usage example
<WithLoading
  loading={@loading}
  component={UserProfile}
  component_props={%{user: @user}}
/>
```

### 5. Context Providers

Components that provide shared context to their children.

```elixir
defmodule Hydepwns.Components.ThemeProvider do
  use Hydepwns.Components.Base
  
  prop theme, :string, default: "light"
  
  def theme_provider(assigns) do
    ~H"""
    <div class={"theme-#{@theme}"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end

# Usage example
<ThemeProvider theme="dark">
  <Button>Dark Mode Button</Button>
</ThemeProvider>
```

## Implementation Examples

### 1. Form Components

```elixir
defmodule Hydepwns.Components.Form do
  use Hydepwns.Components.Base
  
  prop on_submit, :function, required: true
  prop initial_values, :map, default: %{}
  
  def form(assigns) do
    ~H"""
    <form phx-submit="handle_submit" phx-target={@myself}>
      <%= render_slot(@inner_block, @initial_values) %>
    </form>
    """
  end
  
  def handle_event("handle_submit", params, socket) do
    socket.assigns.on_submit.(params)
    {:noreply, socket}
  end
end

# Usage example
<Form
  initial_values={%{name: "", email: ""}}
  on_submit={&handle_form_submit/1}
>
  <Input name="name" />
  <Input name="email" type="email" />
  <button type="submit">Submit</button>
</Form>
```

### 2. Modal Components

```elixir
defmodule Hydepwns.Components.Modal do
  use Hydepwns.Components.Base
  
  prop show, :boolean, default: false
  prop on_close, :function, required: true
  
  def modal(assigns) do
    ~H"""
    <%= if @show do %>
      <div class="modal-overlay" phx-click={@on_close}>
        <div class="modal" phx-click-away={@on_close}>
          <button class="close" phx-click={@on_close}>×</button>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    <% end %>
    """
  end
end

# Usage example
<Modal show={@show_modal} on_close={&hide_modal/0}>
  <h2>Modal Title</h2>
  <p>Modal content goes here</p>
</Modal>
```

### 3. Tab Components

```elixir
defmodule Hydepwns.Components.Tabs do
  use Hydepwns.Components.Base
  
  prop tabs, :list, required: true
  prop active_tab, :string, required: true
  prop on_change, :function, required: true
  
  def tabs(assigns) do
    ~H"""
    <div class="tabs">
      <div class="tab-list">
        <%= for tab <- @tabs do %>
          <button
            class={"tab #{if tab.id == @active_tab, do: 'active'}"}
            phx-click="change_tab"
            phx-value-tab={tab.id}
            phx-target={@myself}
          >
            <%= tab.label %>
          </button>
        <% end %>
      </div>
      <div class="tab-content">
        <%= render_slot(@inner_block, @active_tab) %>
      </div>
    </div>
    """
  end
  
  def handle_event("change_tab", %{"tab" => tab_id}, socket) do
    socket.assigns.on_change.(tab_id)
    {:noreply, socket}
  end
end

# Usage example
<Tabs
  tabs={[
    %{id: "tab1", label: "Tab 1"},
    %{id: "tab2", label: "Tab 2"}
  ]}
  active_tab={@active_tab}
  on_change={&handle_tab_change/1}
>
  <:tab id="tab1">Content for Tab 1</:tab>
  <:tab id="tab2">Content for Tab 2</:tab>
</Tabs>
```

## Best Practices

### 1. Component Composition

- Break down complex components into smaller, reusable parts
- Use slots for flexible content injection
- Implement clear interfaces between components
- Keep components focused and single-purpose
- Use composition over inheritance

### 2. State Management

- Keep state as close as possible to where it's used
- Use controlled components when state needs to be shared
- Implement clear state update patterns
- Handle loading and error states consistently
- Use context for deeply nested state sharing

### 3. Event Handling

- Use consistent event naming conventions
- Implement proper event delegation
- Handle event cleanup in component lifecycle
- Use typed event handlers when possible
- Implement proper error boundaries

### 4. Performance

- Implement proper memoization
- Use lazy loading when appropriate
- Optimize renders with proper key usage
- Implement efficient list rendering
- Use proper cleanup in lifecycle hooks

### 5. Accessibility

- Use semantic HTML elements
- Implement proper ARIA attributes
- Handle keyboard navigation
- Ensure proper focus management
- Test with screen readers

## References

- [Component Guidelines](guidelines.md)
- [Robust Implementation](robust-implementation.md)
- [Component Architecture](../../reference/architecture/component-architecture.md)
- [Accessibility Guide](../../reference/guides/accessibility.md)
