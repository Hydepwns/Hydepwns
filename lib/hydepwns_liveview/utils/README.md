# Socket Validation Utilities

This directory contains utilities for enhancing LiveView socket validation with an Ash-inspired architecture.

## Overview

The implementation consists of several key modules:

- `SocketValidator`: Basic validation for socket assigns
- `ResourceAssigns`: DSL for defining socket assigns as resources
- `LiveViewAPI`: API-style interface for accessing and manipulating socket assigns

## Usage

### Basic Socket Validation

```elixir
use HydepwnsLiveviewWeb.BaseLive,
  required_assigns: [:user_id, :theme],
  type_specs: %{
    user_id: :string,
    theme: {:one_of, ["dark", "light", "dim"]},
    settings: %{notifications: :boolean}
  }
```

### Resource-Oriented Socket Assigns

```elixir
use HydepwnsLiveviewWeb.ResourceLive

assigns_resource do
  attributes do
    attribute :user_id, :string, required: true
    attribute :username, :string, required: true
    attribute :role, {:one_of, ["admin", "user", "guest"]}, default: "user"
    
    # Nested attributes using map schema
    attribute :settings, :map do
      attribute :theme, {:one_of, ["dark", "light", "system"]}, default: "system"
      attribute :notifications, :boolean, default: true
    end
  end
end
```

### API-Style Access

```elixir
alias HydepwnsLiveview.Utils.LiveViewAPI

# Get a value from a resource
role = LiveViewAPI.get(socket, :user, :role)

# Update a resource
{:ok, socket} = LiveViewAPI.update(socket, :user, %{role: "admin"})
```

## Modules

### SocketValidator

Provides basic validation utilities for LiveView socket assigns:

- `validate_required/2`: Ensures all required assigns are present
- `type_validation/3`: Validates that an assign is of the expected type
- `get_assign/3`: Gets a value from socket assigns with a default fallback
- `safe_assign/3`: Safely updates socket assigns, ensuring required fields are maintained

### ResourceAssigns

Implements an Ash-inspired DSL for defining socket assigns as resources:

- `assigns_resource/1`: Entry point for the DSL
- `attributes/1`: Defines attributes for the resource
- `attribute/3`: Defines a specific attribute with type and options
- `relationships/1`: Defines relationships to other resources
- `validations/1`: Defines custom validations

### LiveViewAPI

Provides a standardized API for working with socket assigns:

- `get/4`: Gets a value from a resource-oriented socket assign
- `update/3`: Updates fields in a resource-oriented socket assign
- `create/3`: Creates a new resource in the socket assigns
- `delete/2`: Deletes a resource from the socket assigns
- `list_resources/1`: Lists all resources defined in the socket assigns
- `get_all/2`: Gets all fields from a resource
- `get_fields/3`: Gets multiple fields from a resource

## Examples

An example implementation is available at `/examples/resource-assigns` which demonstrates the usage of these utilities in a real LiveView.

## Testing

The socket validation utilities are tested in:

- `test/hydepwns_liveview_web/live/resource_live_test.exs`: Tests for resource-oriented socket assigns

## Documentation

Comprehensive documentation is available in:

- `docs/PRD/FEATURES/SOCKET_VALIDATION.md`: Overview of resource-oriented socket assigns

## Next Steps

- Enhanced relationship support
- Integration with Ecto schemas and Ash resources
- Custom validation DSL
- Visual resource editor 