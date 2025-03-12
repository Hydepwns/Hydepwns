# Resource-Oriented Socket Assigns

This document outlines the implementation of resource-oriented socket assigns in the Hydepwns Monospace Web application, inspired by Ash Framework's architecture patterns.

## Overview

Resource-oriented socket assigns treat LiveView socket assigns as first-class resources with attributes, relationships, and validations. This approach provides several benefits:

- **Declarative Specifications**: Define socket assigns with a clear, consistent DSL
- **Automatic Validation**: Prevent runtime errors through type validation
- **API-Based Access**: Use standard API methods for accessing and updating assigns
- **Self-Documenting Code**: Resource definitions serve as documentation
- **Consistent Error Handling**: Standardized approach to validation errors

## Implementation

The implementation consists of several key components:

1. `ResourceAssigns` module: Provides the DSL for defining socket assigns as resources
2. `ResourceLive` module: LiveView wrapper that adds resource-oriented functionality
3. `LiveViewAPI` module: API-style interface for accessing and manipulating socket assigns

## Usage

### Defining Resource Assigns

```elixir
defmodule MyAppWeb.UserLive do
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
      
      # List attributes with validation
      attribute :permissions, {:list, :string}, default: []
    end
    
    relationships do
      # Define relationships to other socket resources
      # relationship :team, :belongs_to, TeamLive, optional: true
    end
    
    validations do
      # Custom validations beyond type validation
      # validation :email_format, &valid_email?/1, field: :email
    end
  end
  
  # Your LiveView implementation...
end
```

### Using the LiveViewAPI

```elixir
alias HydepwnsLiveview.Utils.LiveViewAPI

# Get a value from a resource
role = LiveViewAPI.get(socket, :user, :role)

# Update a resource
{:ok, socket} = LiveViewAPI.update(socket, :user, %{role: "admin"})

# Create a new resource
{:ok, socket} = LiveViewAPI.create(socket, :team, %{name: "Engineering", members: 5})

# Delete a resource
{:ok, socket} = LiveViewAPI.delete(socket, :temporary_data)

# Check if a resource exists
if LiveViewAPI.resource_exists?(socket, :user) do
  # Do something with the user resource
end

# Get all fields from a resource
user_data = LiveViewAPI.get_all(socket, :user)

# Get multiple fields from a resource
%{name: name, role: role} = LiveViewAPI.get_fields(socket, :user, [:name, :role])
```

### Generated Accessor Functions

The `assigns_resource` DSL automatically generates accessor functions for your resource attributes:

```elixir
# Instead of socket.assigns.user.role
role = user_role(socket)

# Instead of assign(socket, :user, Map.put(socket.assigns.user, :role, "admin"))
socket = put_user_role(socket, "admin")
```

## Supported Types

The resource-oriented socket assigns system supports the following types:

- Basic types: `:string`, `:integer`, `:boolean`, `:map`, `:list`, `:atom`, `:function`
- Enum validation: `{:one_of, ["option1", "option2"]}`
- List validation: `{:list, elem_type_spec}`
- Map schema validation: `%{field1: type1, field2: type2}`
- List of maps validation: `{:list_of_maps, schema}`
- Nested list validation: `{:nested_list, type_spec}`
- Union types: `{:union, [type_spec1, type_spec2]}`
- Optional fields: `{:optional, type_spec}`
- Custom validation: `{:custom, validation_function}`

## Example

An example implementation is available at `/examples/resource-assigns` which demonstrates:

- Resource definition with nested attributes
- Handling updates with validation
- API-based access to socket assigns
- Error handling for validation failures

## Benefits of Resource-Oriented Socket Assigns

1. **Explicit Required Assigns**: All LiveView dependencies are declared upfront
2. **Automatic Validation**: Prevents KeyError crashes at runtime 
3. **Standardized Error Handling**: Consistent approach across all LiveViews
4. **Simplified Development**: Focuses developers on business logic over boilerplate
5. **Testing Improvements**: Easier validation and clearer error messages
6. **Better Documentation**: Self-documenting code with clear requirements
7. **Resource-Oriented Approach**: Consistent conceptual model with Ash resources

## Future Enhancements

1. **Integration with Ecto Schemas**: Auto-generate resource definitions from Ecto schemas
2. **Integration with Ash Resources**: Bidirectional integration with Ash resources
3. **Relationship Support**: Define and navigate relationships between LiveView resources
4. **Custom Validation DSL**: Enhanced validation capabilities beyond type validation
5. **Code Generation**: Generate LiveView code based on resource definitions
6. **Visual Editor**: Generate resource definitions through a visual editor

## Comparison with Ash Framework

| Feature | Resource-Oriented Socket Assigns | Ash Framework |
|---------|----------------------------------|---------------|
| Declarative Resource Definition | ✅ | ✅ |
| Type Validation | ✅ | ✅ |
| Relationships | ⚠️ Planned | ✅ |
| Computed Fields | ❌ Not Implemented | ✅ |
| Actions | ❌ Not Implemented | ✅ |
| Data Layer | ❌ View Layer Only | ✅ |
| Ecosystem | 🔄 Growing | ✅ Established |

## Contributing

To contribute to the resource-oriented socket assigns system:

1. Review the current implementation in `lib/hydepwns_liveview/utils/resource_assigns.ex`
2. Check the example implementation at `lib/hydepwns_liveview_web/live/examples/user_resource_live.ex`
3. Run the example and test different edge cases
4. Submit PRs with enhancements or bug fixes

## Changelog

### v1.0.0 (Current)

- Initial implementation of resource-oriented socket assigns
- DSL for declarative assign specifications
- Basic LiveViewAPI implementation
- Example LiveView showcase
- Documentation 