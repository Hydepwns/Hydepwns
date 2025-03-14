---
title: Phoenix LiveView Integration
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.

  > The current version of this document is now at
  [reference/features/liveview.md](../../reference/features/liveview.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link -->.
topics:
  - archive
  - prd
  - features
  - phoenix-liveview-integration
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - liveview-basics
  - path-handling-in-liveview
  - or-with-specific-path
  - integration-with-monospace-web
  - create-directories
  - copy-font-files-to-priv-static-fonts-
  - copy-theme-css-files-to-assets-css-themes-
  - 2-liveview-components-with-monospace-styling
  - theme-system-integration
  - in-web-ex
  - liveview-state-management
  - initial-state
  - update-single-assign
  - update-multiple-assigns
  - send-updates
  - best-practices
  - debugging-liveview-applications
  - config-dev-exs
  - 2-visualize-character-grid
  - common-patterns
  - resources
  - references
  - code-examples
  - development
last_updated: '2025-03-14'
---
# Phoenix LiveView Integration

> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.
> The current version of this document is now at [reference/features/liveview.md](../../reference/features/liveview.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->.


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

# Phoenix LiveView Integration


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.
> The current version of this document is now at [reference/features/liveview.md](../../reference/features/liveview.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->.


This document provides comprehensive guidance on using Phoenix LiveView with the Hydepwns Monospace Web styling system.

## Overview

Hydepwns integrates Phoenix LiveView with a monospace-focused design system inspired by [The Monospace Web](https://github.com/owickstrom/the-monospace-web) project.

Key features:

- Character-based grid layout aligned to monospace typography
- Real-time user interfaces with server-rendered HTML
- Seamless theme switching without page reloads
- Grid-respecting animations and transitions
- Minimal JavaScript footprint

## LiveView Basics

### What is LiveView?

Phoenix LiveView is a library that enables rich, real-time user experiences with server-rendered HTML. It works by:

1. Establishing a stateful connection to the server via WebSockets
2. Updating only the parts of the DOM that change when state changes
3. Handling client-side events, sending them to the server, and updating the UI based on results

### Creating a LiveView Module

A basic LiveView module looks like this:

```elixir
defmodule HydepwnsLiveviewWeb.HomeLive do
  use HydepwnsLiveviewWeb, :live_view
  alias HydepwnsLiveviewWeb.Helpers.PathHelper
  
  @impl true
  def mount(_params, _session, socket) do
    {:ok, 
     socket
     |> PathHelper.assign_current_path()
     |> assign(count: 0)}
  end
  
  @impl true
  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="container">
      <h1>Counter Example</h1>
      <p>Count: <%= @count %></p>
      <button phx-click="increment">Increment</button>
    </div>
    """
  end
end
```markdown

## Path Handling in LiveView

### PathHelper Module

Managing paths in LiveView can be challenging due to the different lifecycle phases of a LiveView mount. The `PathHelper` module provides functions to consistently handle paths:

```elixir
defmodule HydepwnsLiveviewWeb.Helpers.PathHelper do
  def assign_current_path(socket) do
    Phoenix.Component.assign(
      socket,
      :current_path,
      case socket.assigns[:live_action] do
        nil -> "/"
        action -> "/#{action}"
      end
    )
  end

  def assign_specific_path(socket, path) do
    Phoenix.Component.assign(socket, :current_path, path)
  end
end
```markdown

Use these functions in your LiveView `mount/3` callback:

```elixir
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> PathHelper.assign_current_path()  # For auto path detection
   |> assign(:page_title, "Home")}
end

# Or with specific path
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> PathHelper.assign_specific_path("/custom-path")
   |> assign(:page_title, "Custom Page")}
end
```markdown

See the full [PathHelper documentation](../DEVELOPMENT/PATH_HELPER.md) for more details.

## Integration with Monospace Web

### 1. Setup

Ensure your project has the required styling and font files:

```bash
# Create directories
mkdir -p assets/css/themes
mkdir -p priv/static/fonts

# Copy font files to priv/static/fonts/
# Copy theme CSS files to assets/css/themes/
```markdown

## 2. LiveView Components with Monospace Styling

Create components that respect the character grid:

```elixir
defmodule HydepwnsLiveviewWeb.Components.Card do
  use Phoenix.Component
  
  def card(assigns) do
    ~H"""
    <div class="card">
      <div class="card-header">
        <%= render_slot(@header) || @title %>
      </div>
      <div class="card-body">
        <%= render_slot(@inner_block) %>
      </div>
      <%= if render_slot(@footer) do %>
        <div class="card-footer">
          <%= render_slot(@footer) %>
        </div>
      <% end %>
    </div>
    """
  end
end
```markdown

CSS for the card component:

```css
.card {
  width: 80ch;
  border: var(--border-thickness) solid var(--text-color);
  margin-bottom: var(--line-height);
}

.card-header {
  padding: var(--spacing-small) var(--spacing-medium);
  border-bottom: var(--border-thickness) solid var(--text-color);
  font-weight: var(--font-weight-bold);
}

.card-body {
  padding: var(--spacing-medium);
}

.card-footer {
  padding: var(--spacing-small) var(--spacing-medium);
  border-top: var(--border-thickness) solid var(--text-color);
}
```markdown

### 3. Grid-Based Animations

LiveView supports grid-based animations through CSS and hooks. Example typewriter animation:

```elixir
def typewriter(assigns) do
  ~H"""
  <div id="typewriter" phx-hook="Typewriter" data-text={@text}></div>
  """
end
```markdown

JavaScript hook:

```javascript
const Typewriter = {
  mounted() {
    const text = this.el.dataset.text;
    const el = this.el;
    
    el.innerHTML = '';
    let i = 0;
    
    const interval = setInterval(() => {
      if (i < text.length) {
        el.innerHTML += text.charAt(i);
        i++;
      } else {
        clearInterval(interval);
      }
    }, 50);
  }
};

export default Typewriter;
```markdown

## Theme System Integration

The theme system integrates with LiveView through a centralized event handler in the base LiveView module:

```elixir
# In web.ex
def live_view do
  quote do
    use Phoenix.LiveView,
      layout: {HydepwnsLiveviewWeb.Components.Layout.Layouts, :app}

    import HydepwnsLiveviewWeb.Gettext

    # Base event handlers for all LiveViews
    def handle_event("change_theme", %{"theme" => theme}, socket) do
      theme_class = "#{theme}-theme"
      {:noreply, assign(socket, :theme_class, theme_class)}
    end

    unquote(verified_routes())
  end
end
```markdown

This approach ensures consistent theme handling across all LiveViews without duplicate code. For detailed information about the theme system, see the [Theme documentation](guides/design/themes.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->.

## LiveView State Management

### Assigns

Use assigns to manage state in LiveView:

```elixir
# Initial state
def mount(_params, _session, socket) do
  {:ok, assign(socket, count: 0, items: [])}
end

# Update single assign
def handle_event("increment", _params, socket) do
  {:noreply, assign(socket, count: socket.assigns.count + 1)}
end

# Update multiple assigns
def handle_event("add_item", %{"item" => item}, socket) do
  {:noreply, 
   socket
   |> assign(items: [item | socket.assigns.items])
   |> assign(form_visible: false)}
end
```markdown

## Send Updates

Update LiveView components from other processes:

```elixir
Phoenix.LiveView.send_update(HydepwnsLiveviewWeb.Components.Counter, id: "counter", count: 10)
```markdown

## Best Practices

### 1. Keep Components Small and Focused

- Break complex UIs into smaller components
- Use stateless components when possible
- Use function components for simple views

### 2. Optimize for Performance

- Keep assigns minimal
- Use `update/3` for efficient list updates
- Implement `render_many/3` for collections

```elixir
def render(assigns) do
  ~H"""
  <div class="items">
    <%= for item <- @items do %>
      <div class="item"><%= item %></div>
    <% end %>
  </div>
  """
end
```markdown

### 3. Use LiveView Hooks Judiciously

- Prefer server-side state management
- Use hooks only when client-side interactions are necessary
- Keep JavaScript minimal

### 4. Path Management

- Use the PathHelper module in your mount callbacks
- Maintain consistent path information in your LiveView socket
- Use the current_path assign for navigation-related UI decisions

```elixir
def nav(assigns) do
  ~H"""
  <nav>
    <a href="/" class={if @current_path == "/", do: "active"}>Home</a>
    <a href="/about" class={if @current_path == "/about", do: "active"}>About</a>
  </nav>
  """
end
```markdown

### 5. Standardize Event Handlers

- Use the base implementations for common events like "change_theme"
- Avoid duplicate event handlers across LiveView modules
- Create specific events for specialized behaviors

## Debugging LiveView Applications

### 1. Enable Debug Logs

```elixir
# config/dev.exs
config :phoenix_live_view, debug_heex_annotations: true
```markdown

## 2. Visualize Character Grid

Add the debug grid class to the body during development:

```elixir
<body class={if @debug, do: "debug-grid", else: ""}>
  <%= @inner_content %>
</body>
```markdown

Toggle debug mode with a URL parameter:

```elixir
def mount(params, _session, socket) do
  {:ok, assign(socket, debug: params["debug"] == "true")}
end
```markdown

### 3. Use Browser DevTools

- Check the LiveSocket object in the browser console
- Monitor network traffic in WebSocket frames
- Use the LiveView debugger for tracking changes

## Common Patterns

### Form Handling

```elixir
def mount(_params, _session, socket) do
  {:ok, 
   socket
   |> assign(:user, %User{})
   |> assign(:changeset, User.changeset(%User{}, %{}))}
end

def handle_event("save", %{"user" => user_params}, socket) do
  case Accounts.create_user(user_params) do
    {:ok, user} ->
      {:noreply,
       socket
       |> put_flash(:info, "User created")
       |> redirect(to: ~p"/users/#{user}")}
    
    {:error, %Ecto.Changeset{} = changeset} ->
      {:noreply, assign(socket, changeset: changeset)}
  end
end
```markdown

### Real-time Updates with PubSub

```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(HydepwnsLiveview.PubSub, "updates")
  end
  
  {:ok, assign(socket, messages: [])}
end

def handle_info({:new_message, message}, socket) do
  {:noreply, update(socket, :messages, fn messages -> [message | messages] end)}
end
```markdown

## Resources

- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view)
- [Phoenix LiveView GitHub](https://github.com/phoenixframework/phoenix_live_view)
- [The Monospace Web](https://github.com/owickstrom/the-monospace-web)


## References

- [Project Documentation](../README.md)
