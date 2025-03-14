---
title: Resource-Oriented Architecture for Socket Validation
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - archive
  - prd
  - architecture
  - resource-oriented-architecture-for-socket-validation
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - key-components
  - liveviewresource
  - resourcelive
  - liveviewapi
  - relationship-management-system
  - resolve-a-specific-relationship
  - lazy-load-a-relationship-returns-a-function-
  - eager-load-multiple-relationships
  - get-all-relationships-for-a-resource
  - relationshipvalidator
  - validate-all-relationships
  - validate-a-specific-relationship
  - validate-an-update-operation
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Resource-Oriented Architecture for Socket Validation

> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

# Resource-Oriented Architecture for Socket Validation


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document describes the Ash-inspired, resource-oriented architecture that has been implemented for LiveView socket validation. This architecture enhances the existing socket validation system by providing a more declarative and structured approach to defining and working with socket assigns.

## Key Components

1. **LiveViewResource**: A behavior for defining resources with attributes, relationships, and validations.
2. **ResourceLive**: An enhanced LiveView module that implements the `assigns` DSL and resource-oriented socket assigns.
3. **LiveViewAPI**: A standardized API for accessing and manipulating resource-oriented socket assigns.
4. **Relationship Management System**: A system for defining, resolving, and validating relationships between resources.

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
```markdown

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
```markdown

### Relationships

Relationships define connections between resources:

```elixir
relationships do
  has_many :posts, MyApp.PostResource
  belongs_to :team, MyApp.TeamResource
  has_many_through :team_members, through: [:team, :members]
  polymorphic :manageable, types: [MyApp.PostResource, MyApp.TeamResource]
end
```markdown

The following relationship types are supported:

- **belongs_to**: Defines a relationship where this resource has a foreign key pointing to another resource
- **has_many**: Defines a relationship where this resource is referenced by multiple instances of another resource
- **has_one**: Defines a relationship where this resource is referenced by exactly one instance of another resource
- **has_many_through**: Defines a relationship that accesses resources through an intermediate relationship
- **has_one_through**: Defines a relationship that accesses a single resource through an intermediate relationship
- **polymorphic**: Defines a relationship that can reference different types of resources

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
```markdown

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
```markdown

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
```markdown

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
```markdown

### API Methods

- `get(socket, resource, field, default)`: Gets a value from a resource-oriented socket assign
- `update(socket, resource, values, opts)`: Updates a resource in the socket assigns
- `create(socket, resource, values, opts)`: Creates a new resource in the socket assigns
- `remove(socket, resource)`: Removes a resource from the socket assigns
- `get_resources(socket, pattern)`: Gets all resources that match a pattern
- `create_from_resource(socket, resource_key, resource_module, values, opts)`: Creates a resource from a LiveViewResource module

## Relationship Management System

The Relationship Management System provides a robust way to define, resolve, and validate relationships between resources.

### RelationshipResolver

The `RelationshipResolver` module handles loading related resources with features such as:

- Lazy-loading relationships on demand
- Eager-loading multiple relationships for performance
- Caching resolved relationships to avoid redundant loads
- Supporting various relationship types including through and polymorphic relationships

Example usage:

```elixir
# Resolve a specific relationship
{:ok, posts} = RelationshipResolver.resolve_relationship(user, :posts)

# Lazy load a relationship (returns a function)
{:ok, posts_loader} = RelationshipResolver.resolve_relationship(user, :posts, lazy: true)
{:ok, posts} = posts_loader.()

# Eager load multiple relationships
{:ok, user_with_loaded_rels} = RelationshipResolver.eager_load(user, [:posts, :team])

# Get all relationships for a resource
relationships = RelationshipResolver.get_relationships(UserResource)
```markdown

## RelationshipValidator

The `RelationshipValidator` module ensures relationship integrity with features such as:

- Checking referential integrity of relationships
- Supporting deep validation of related resources
- Validating updates to ensure they maintain integrity
- Validating deletes to prevent orphaned references
- Supporting cascading operations with validation

Example usage:

```elixir
# Validate all relationships
case RelationshipValidator.validate_relationships(user) do
  :ok -> # All relationships valid
  {:error, errors} -> # Handle validation errors
end

# Validate a specific relationship
errors = RelationshipValidator.validate_relationship(user, :team)

# Validate an update operation
case RelationshipValidator.validate_update(user, %{team_id: 5}) do
  :ok -> # Update is valid
  {:error, errors} -> # Handle validation errors
end
```markdown 

## References

- [Project Documentation](../README.md)
