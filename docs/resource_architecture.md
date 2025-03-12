# Resource-Oriented Architecture for Socket Validation

## Overview

This document describes the Ash-inspired, resource-oriented architecture that has been implemented for LiveView socket validation. This architecture enhances the existing socket validation system by providing a more declarative and structured approach to defining and working with socket assigns.

## Key Components

1. **LiveViewResource**: A behavior for defining resources with attributes, relationships, and validations.
2. **ResourceLive**: An enhanced LiveView module that implements the `assigns` DSL and resource-oriented socket assigns.
3. **LiveViewAPI**: A standardized API for accessing and manipulating resource-oriented socket assigns.

## LiveViewResource

The `LiveViewResource` behavior allows you to define resources with attributes, relationships, and validations in a declarative way.

### Example

```elixir
defmodule MyApp.UserResource do
  use HydepwnsLiveview.Utils.LiveViewResource
  
  attributes do
    attribute :id, :string, required: true
    attribute :name, :string, required: true
    attribute :email, :string, format: ~r/@/
    attribute :role, {:one_of, ["admin", "editor", "viewer"]}, default: "viewer"
    
    attribute :settings, :map do
      attribute :theme, {:one_of, ["light", "dark", "system"]}, default: "system"
      attribute :notifications, :boolean, default: true
    end
  end
  
  relationships do
    has_many :posts, MyApp.PostResource
    belongs_to :team, MyApp.TeamResource
  end
  
  validations do
    validate :email_must_be_valid, fn resource ->
      if resource.email && String.contains?(resource.email, "@") do
        :ok
      else
        {:error, "Email must contain @"}
      end
    end
  end
end
```

### Attributes

Attributes can be defined with the following options:

- `required`: Whether the attribute is required
- `default`: A default value for the attribute
- `format`: A regex pattern for string validation

You can also define nested attributes for map types:

```elixir
attribute :settings, :map do
  attribute :theme, {:one_of, ["light", "dark", "system"]}, default: "system"
  attribute :notifications, :boolean, default: true
end
```

### Relationships

Relationships define connections between resources:

```elixir
relationships do
  has_many :posts, MyApp.PostResource
  belongs_to :team, MyApp.TeamResource
end
```

### Validations

Validations allow you to define custom validation functions:

```elixir
validations do
  validate :email_must_be_valid, fn resource ->
    if resource.email && String.contains?(resource.email, "@") do
      :ok
    else
      {:error, "Email must contain @"}
    end
  end
end
```

## ResourceLive

The `ResourceLive` module extends `BaseLive` to support declarative socket assigns using the `assigns` DSL.

### Example

```elixir
defmodule MyAppWeb.UserLive do
  use HydepwnsLiveviewWeb.ResourceLive
  
  assigns do
    attribute :user_id, :string, required: true
    attribute :username, :string, required: true
    attribute :role, {:one_of, ["admin", "user", "guest"]}, default: "user"
    
    attribute :settings, :map do
      attribute :theme, {:one_of, ["dark", "light", "system"]}, default: "system"
      attribute :notifications, :boolean, default: true
    end
    
    relationship :team, :belongs_to, MyApp.TeamResource
  end
  
  def mount_resources(params, session, socket) do
    # Your mount logic here
    {:ok, assign(socket, :user_id, "123")}
  end
end
```

### The `assigns` DSL

The `assigns` DSL allows you to define socket assigns in a declarative way:

```elixir
assigns do
  attribute :user_id, :string, required: true
  attribute :username, :string, required: true
  
  # Nested attributes
  attribute :settings, :map do
    attribute :theme, {:one_of, ["light", "dark"]}, default: "dark"
    attribute :notifications, :boolean, default: true
  end
  
  # Relationships
  relationship :team, :belongs_to, MyApp.TeamResource
end
```

### Resource API Methods

The `ResourceLive` module provides the following API methods:

- `get_resource(socket, field, default)`: Gets a value from a resource
- `update_resource(socket, resource_key, updates)`: Updates a resource with the given values
- `validate_updates(socket, resource_key, updates)`: Validates updates against the resource definition

## LiveViewAPI

The `LiveViewAPI` module provides a standardized API for working with resource-oriented socket assigns.

### Example

```elixir
def handle_event("update_user", %{"user" => user_params}, socket) do
  case LiveViewAPI.update(socket, :user, user_params) do
    {:ok, updated_socket} ->
      {:noreply, updated_socket}
    
    {:error, message, socket} ->
      {:noreply, put_flash(socket, :error, message)}
  end
end
```

### API Methods

- `get(socket, resource, field, default)`: Gets a value from a resource-oriented socket assign
- `update(socket, resource, values, opts)`: Updates a resource in the socket assigns
- `create(socket, resource, values, opts)`: Creates a new resource in the socket assigns
- `remove(socket, resource)`: Removes a resource from the socket assigns
- `get_resources(socket, pattern)`: Gets all resources that match a pattern
- `create_from_resource(socket, resource_key, resource_module, values, opts)`: Creates a resource from a LiveViewResource module

## Integration with Existing Frameworks

### Ecto Integration (Planned)

Future enhancements will include integration with Ecto schemas:

```elixir
defmodule MyApp.UserResource do
  use HydepwnsLiveview.Utils.LiveViewResource
  
  ecto_schema MyApp.User
end
```

### Ash Resource Integration (Planned)

Future enhancements will include integration with Ash resources:

```elixir
defmodule MyApp.UserResource do
  use HydepwnsLiveview.Utils.LiveViewResource
  
  ash_resource MyApp.UserResource
end
```

## Benefits of the Resource-Oriented Architecture

1. **Declarative Over Imperative**: Define what assigns should be, not how to validate them
2. **Consistent Resource Pattern**: Use same conceptual model across backend and frontend
3. **Domain-Driven APIs**: Organize LiveViews into domain-specific APIs for better structure
4. **Reduced Boilerplate**: Eliminate repetitive validation code through resource declarations
5. **Enhanced Documentation**: Self-documenting resources with clear attribute definitions
6. **Data Source Flexibility**: Abstract validation logic from underlying data sources

## Getting Started

To get started with the resource-oriented architecture:

1. Define your resources using `LiveViewResource`:

```elixir
defmodule MyApp.UserResource do
  use HydepwnsLiveview.Utils.LiveViewResource
  
  attributes do
    attribute :id, :string, required: true
    attribute :name, :string, required: true
  end
end
```

2. Use `ResourceLive` in your LiveView modules:

```elixir
defmodule MyAppWeb.UserLive do
  use HydepwnsLiveviewWeb.ResourceLive
  
  assigns do
    attribute :user_id, :string, required: true
    attribute :username, :string, required: true
  end
end
```

3. Use `LiveViewAPI` to work with your resources:

```elixir
def handle_event("update_user", %{"user" => user_params}, socket) do
  case LiveViewAPI.update(socket, :user, user_params) do
    {:ok, updated_socket} ->
      {:noreply, updated_socket}
    
    {:error, message, socket} ->
      {:noreply, put_flash(socket, :error, message)}
  end
end
```

## Example Implementation

Check out the `UserResourceExampleLive` module for a complete example of the resource-oriented architecture in action:

```
/examples/user-resource
```

This example demonstrates:
- Resource-oriented socket assigns
- The `assigns` DSL
- Working with nested attributes
- Updating resources using the LiveViewAPI
- Integrating with LiveViewResource modules 