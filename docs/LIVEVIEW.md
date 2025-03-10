# Phoenix LiveView Integration

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
  
  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
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
```

## Integration with Monospace Web

### 1. Setup

Ensure your project has the required styling and font files:

```bash
# Create directories
mkdir -p assets/css/themes
mkdir -p priv/static/fonts

# Copy font files to priv/static/fonts/
# Copy theme CSS files to assets/css/themes/
```

### 2. LiveView Components with Monospace Styling

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
```

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
```

### 3. Grid-Based Animations

LiveView supports grid-based animations through CSS and hooks. Example typewriter animation:

```elixir
def typewriter(assigns) do
  ~H"""
  <div id="typewriter" phx-hook="Typewriter" data-text={@text}></div>
  """
end
```

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
```

## Theme System Integration

The theme system integrates with LiveView using hooks. Register theme hooks in your app.js:

```javascript
import ThemeToggle from "./hooks/theme_toggle"

let Hooks = {}
Hooks.ThemeToggle = ThemeToggle

let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})
```

Add the theme toggle component to your layouts:

```elixir
<HydepwnsLiveviewWeb.Components.UI.ThemeToggle.theme_toggle />
```

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
```

### Send Updates

Update LiveView components from other processes:

```elixir
Phoenix.LiveView.send_update(HydepwnsLiveviewWeb.Components.Counter, id: "counter", count: 10)
```

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
```

### 3. Use LiveView Hooks Judiciously

- Prefer server-side state management
- Use hooks only when client-side interactions are necessary
- Keep JavaScript minimal

### 4. Maintain Grid Alignment

- Use `ch` units for horizontal spacing
- Use `line-height` multiples for vertical spacing
- Test with the debug grid to ensure alignment

## Debugging LiveView Applications

### 1. Enable Debug Logs

```elixir
# config/dev.exs
config :phoenix_live_view, debug_heex_annotations: true
```

### 2. Visualize Character Grid

Add the debug grid class to the body during development:

```elixir
<body class={if @debug, do: "debug-grid", else: ""}>
  <%= @inner_content %>
</body>
```

Toggle debug mode with a URL parameter:

```elixir
def mount(params, _session, socket) do
  {:ok, assign(socket, debug: params["debug"] == "true")}
end
```

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
```

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
```

## Resources

- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view)
- [Phoenix LiveView GitHub](https://github.com/phoenixframework/phoenix_live_view)
- [The Monospace Web](https://github.com/owickstrom/the-monospace-web)
