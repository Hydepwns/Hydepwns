---
title: Relationship Management System
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - archive
  - prd
  - features
  - relationship-management-system
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - usage
  - load-a-specific-relationship
  - load-a-relationship-lazily
  - eager-load-multiple-relationships
  - validating-relationships
  - validate-all-relationships-on-a-resource
  - validate-a-specific-relationship
  - validate-an-update-operation
  - validate-a-delete-operation
  - validate-cascading-operations
  - component-descriptions
  - implementation-details
  - best-practices
  - error-handling
  - an-error-in-a-deeply-nested-relationship-might-include-
  - conclusion
  - references
  - code-examples
  - testing
  - architecture
last_updated: '2025-03-14'
---
# Relationship Management System

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

# Relationship Management System


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

The Relationship Management System provides a flexible and robust way to define, resolve, and validate relationships between resources in the Hydepwns LiveView application. Inspired by the Ash framework's resource architecture, this system allows for declarative relationship definitions with automatic loading, caching, and validation capabilities.

## Features

- **Declarative Relationship DSL**: Define relationships using a simple, expressive DSL
- **Relationship Types**: Support for `belongs_to`, `has_many`, `has_one`, `through`, and `polymorphic` relationships
- **Lazy and Eager Loading**: Load related resources on-demand or in advance to optimize performance
- **Relationship Caching**: Automatically cache related resources to prevent duplicate loads
- **Referential Integrity**: Validate relationships to ensure they maintain proper integrity
- **Cascading Operations**: Support for cascading updates and deletes with validation

## Usage

### Defining Relationships

Relationships are defined within a resource using the `relationships` DSL block:

```elixir
defmodule MyApp.UserResource do
  use HydepwnsLiveview.Utils.LiveViewResource
  
  attributes do
    attribute :id, :string, required: true
    attribute :name, :string, required: true
    # ...
  end

  relationships do
    # Basic relationships
    has_many :posts, MyApp.PostResource
    belongs_to :team, MyApp.TeamResource
    has_one :profile, MyApp.ProfileResource
    
    # Advanced relationships
    has_many_through :team_members, through: [:team, :members]
    has_one_through :manager, through: [:team, :manager]
    polymorphic :manageable, types: [MyApp.PostResource, MyApp.TeamResource]
  end
  
  # ...
end
```markdown

### Relationship Types

#### Basic Relationships

- **belongs_to**: Defines a relationship where this resource has a foreign key pointing to another resource.

  ```elixir
  belongs_to :team, TeamResource
  belongs_to :creator, UserResource, foreign_key: :created_by_id
  ```markdown

- **has_many**: Defines a relationship where this resource is referenced by multiple instances of another resource.

  ```elixir
  has_many :posts, PostResource
  has_many :comments, CommentResource, foreign_key: :target_user_id
  ```markdown

- **has_one**: Defines a relationship where this resource is referenced by exactly one instance of another resource.

  ```elixir
  has_one :profile, ProfileResource
  has_one :latest_post, PostResource, foreign_key: :user_id
  ```markdown

#### Advanced Relationships

- **has_many_through**: Defines a relationship that goes through another relationship to access a collection of resources.

  ```elixir
  has_many_through :team_members, through: [:team, :members]
  ```markdown

  This would allow a user to access all members of their team through their own team relationship.

- **has_one_through**: Defines a relationship that goes through another relationship to access a single resource.

  ```elixir
  has_one_through :manager, through: [:team, :manager]
  ```markdown

  This would allow a user to access their team's manager through their own team relationship.

- **polymorphic**: Defines a relationship that can reference different types of resources.

  ```elixir
  polymorphic :commentable, types: [PostResource, ArticleResource]
  ```markdown

  This allows a comment to be associated with either a post or an article.

### Loading Relationships

Once relationships are defined, they can be loaded using the resolver functions:

```elixir
# Load a specific relationship
case UserResource.resolve_relationship(user, :posts) do
  {:ok, posts} -> # Do something with posts
  {:error, reason} -> # Handle error
end

# Load a relationship lazily
{:ok, posts_loader} = UserResource.resolve_relationship(user, :posts, lazy: true)
{:ok, posts} = posts_loader.()

# Eager load multiple relationships
{:ok, user_with_loaded_relationships} = UserResource.eager_load(user, [:posts, :team])
```markdown

## Validating Relationships

The system provides extensive validation capabilities:

```elixir
# Validate all relationships on a resource
case UserResource.validate_relationships(user) do
  :ok -> # All relationships are valid
  {:error, errors} -> # Handle validation errors
end

# Validate a specific relationship
errors = UserResource.validate_relationship(user, :team)

# Validate an update operation
case UserResource.validate_update(user, %{team_id: 5}) do
  :ok -> # Update is valid
  {:error, errors} -> # Handle validation errors
end

# Validate a delete operation
case UserResource.validate_delete(post) do
  :ok -> # Delete is valid
  {:error, errors} -> # Handle validation errors
end

# Validate cascading operations
UserResource.validate_update(user, %{team_id: 5}, cascade: true)
UserResource.validate_delete(team, cascade: true)
```markdown

## Component Descriptions

The relationship management system consists of several key components:

### LiveViewResource

The base module that provides the DSL for defining resources and relationships. It also exposes helper functions for relationship resolution and validation.

### RelationshipResolver

Handles the actual resolution of relationships, including:

- Loading relationships based on their type
- Implementing lazy and eager loading strategies
- Managing relationship caching
- Supporting through and polymorphic relationships

### RelationshipValidator

Provides validation capabilities for relationships, including:

- Checking referential integrity
- Validating relationship constraints
- Supporting cascading updates and deletes
- Providing detailed error information

## Implementation Details

### Relationship Resolution

When resolving a relationship, the system follows these steps:

1. Check if the relationship is cached
2. If not cached, determine the relationship type
3. Load the relationship based on its type:
   - For `belongs_to`, load using the foreign key
   - For `has_many`, query related resources
   - For `has_one`, query the related resource
   - For `through`, load the intermediate, then the target
   - For `polymorphic`, determine the type and load accordingly
4. Cache the result if caching is enabled
5. Return the loaded relationship

### Relationship Validation

The validation process includes:

1. Checking if required relationships are present
2. Validating referential integrity when possible
3. Performing deep validation if requested
4. Validating cascading operations when applicable
5. Collecting detailed error information

## Best Practices

- **Use Caching**: Enable caching for frequently accessed relationships
- **Consider Eager Loading**: Use eager loading when you know you'll need multiple relationships
- **Validate Before Updating/Deleting**: Always validate operations that might affect relationships
- **Use Cascading Operations Carefully**: Be cautious with cascading operations as they can affect multiple resources
- **Provide Meaningful Foreign Keys**: Explicitly specify foreign keys when they don't follow naming conventions

## Error Handling

The relationship management system provides detailed error information to help diagnose and fix issues:

```elixir
case UserResource.validate_relationships(user) do
  :ok -> # All good
  {:error, errors} ->
    # errors might look like:
    # [
    #   %{
    #     relationship: :team,
    #     error: "Referenced entity not found: Record not found",
    #     foreign_key: :team_id,
    #     foreign_key_value: 999
    #   }
    # ]
end
```markdown

For deep validation, errors include a relationship path showing the chain of relationships leading to the error:

```elixir
# An error in a deeply nested relationship might include:
%{
  relationship: :post_author,
  relationship_path: [:team, :posts, :author],
  error: "Referenced entity not found"
}
```markdown

## Conclusion

The relationship management system provides a powerful and flexible way to define, resolve, and validate relationships between resources. By using the declarative DSL and built-in validation capabilities, you can ensure that your application maintains proper data integrity while providing efficient access to related data.


## References

- [Project Documentation](../README.md)
