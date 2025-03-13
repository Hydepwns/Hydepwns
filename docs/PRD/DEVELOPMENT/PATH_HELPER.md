# PathHelper Module Documentation

## Overview

The `PathHelper` module provides utility functions for handling paths in Phoenix LiveView applications. It simplifies path management and provides a consistent way to assign path information to LiveView sockets.

## Purpose

In Phoenix LiveView applications, managing the current path can be challenging due to the nature of LiveView's lifecycle and navigation. The `PathHelper` module addresses these challenges by:

1. Providing consistent path information in LiveView sockets
2. Working reliably during both initial renders and subsequent live navigations
3. Avoiding reliance on parameters that might not be available during certain phases

## Module Functions

### `assign_current_path/1`

Assigns the current path to the socket without relying on request parameters.

```elixir
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
```

**Parameters:**

- `socket` - The LiveView socket to which the path will be assigned

**Returns:**

- The socket with the `:current_path` assign set

**Example Usage:**

```elixir
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> PathHelper.assign_current_path()
   |> assign(:page_title, "Home")}
end
```

### `assign_specific_path/2`

Assigns a specific path to the socket. This is useful when the path needs to be explicitly set.

```elixir
def assign_specific_path(socket, path) do
  Phoenix.Component.assign(socket, :current_path, path)
end
```

**Parameters:**

- `socket` - The LiveView socket to which the path will be assigned
- `path` - The path string to assign

**Returns:**

- The socket with the `:current_path` assign set to the specified path

**Example Usage:**

```elixir
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> PathHelper.assign_specific_path("/projects")
   |> assign(:page_title, "Projects")}
end
```

## Implementation Details

The `PathHelper` module is implemented in `lib/hydepwns_liveview_web/helpers/path_helper.ex` and works by:

1. For `assign_current_path/1`:
   - Checking if a LiveView action is present in the socket assigns
   - If present, converting it to a path by adding a leading slash
   - If not present, defaulting to the root path "/"

2. For `assign_specific_path/2`:
   - Directly assigning the provided path to the socket's `:current_path` assign

## Integration with Navigation Components

The path information stored in the socket's `:current_path` assign can be used to:

1. Highlight the active navigation item
2. Conditionally render UI elements based on the current path
3. Provide path information to other components

Example navigation component using the path information:

```elixir
def nav(assigns) do
  ~H"""
  <nav class="main-nav">
    <a href="/" class={if @current_path == "/", do: "active"}>Home</a>
    <a href="/projects" class={if @current_path == "/projects", do: "active"}>Projects</a>
    <a href="/about" class={if @current_path == "/about", do: "active"}>About</a>
  </nav>
  """
end
```

## Best Practices

1. Call `PathHelper.assign_current_path/1` or `PathHelper.assign_specific_path/2` in the `mount/3` callback of your LiveView
2. Use the assigned `:current_path` for navigation-related UI decisions
3. Avoid relying on the `:path_params` for path-related decisions as these might not be available in some LiveView lifecycle phases

## Troubleshooting

If path-related functionality is not working as expected:

1. Ensure the `PathHelper` module is being used in the `mount/3` callback
2. Check that the `:current_path` assign is being passed to components that need it
3. Verify that the path format matches what your components expect (e.g., leading slash)
4. Check for any custom routing logic that might override the path 