---
title: Resource Management System
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
  - resource-management-system
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - key-features
  - implementation
  - relationship-management-details
  - load-a-specific-relationship
  - load-a-relationship-lazily
  - eager-load-multiple-relationships
  - validating-relationships
  - validate-all-relationships-on-a-resource
  - validate-a-specific-relationship
  - validate-an-update-operation
  - validate-a-delete-operation
  - validate-cascading-operations
  - relationship-resolution-process
  - an-error-in-a-deeply-nested-relationship-might-include-
  - best-practices-for-relationships
  - track-a-change-to-a-resource
  - view-change-history
  - get-a-specific-version
  - create-a-diff-between-versions
  - nested-resource-validation-implemented-
  - define-validations-that-span-relationships-with-dependency-tracking
  - validate-a-resource-and-all-its-related-resources-with-dependency-resolution
  - inspect-structured-validation-errors
  - resource-validation-viewer-implemented-
  - ui-components
  - future-enhancements
  - references
  - code-examples
  - testing
  - architecture
last_updated: '2025-03-14'
---
# Resource Management System

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

# Resource Management System


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

The Resource Management System provides a comprehensive set of tools for managing, validating, tracking changes, and establishing relationships between resources in the Hydepwns LiveView framework. This document outlines the key features, implementation details, and usage guidelines.

For a detailed overview of the current implementation state, including enhancements and optimizations, please refer to the [Resource System Implementation](../RESOURCE_SYSTEM_IMPLEMENTATION.md) document.

## Key Features

### Phase 1: Relationship Management System (Completed)

- **Relationship Specification DSL**: Define relationships between resources using a declarative syntax.
  - Support for belongs_to, has_many, has_one relationships
  - Support for through relationships
  - Polymorphic relationship handling
- **Relationship Resolution System**: Efficiently resolve relationships at runtime.
  - Lazy-loading of related resources
  - Eager loading capabilities for performance
  - Relationship caching system
- **Relationship Integrity Validation**: Ensure data consistency across related resources.
  - Referential integrity checks
  - Cascading updates/deletes
  - Validation rules for relationship constraints

### Phase 2: Change Tracking Implementation (Completed)

- **Change Tracking Architecture**: Track changes to resources in an immutable history.
  - Immutable change records
  - Optimistic concurrency control
  - Change serialization for persistence
- **Automatic Tracking Mechanisms**: Capture changes automatically.
  - Before/after change snapshots
  - Change metadata tracking (who, when, why)
  - Selective field tracking
- **Change Visualization Tools**: View and analyze changes.
  - Diff views for resource changes
  - Timeline view for change history
  - Audit log visualization

### Phase 3: Nested Resource Validation (Completed)

- **Context-aware Validation System**: Validate resources in the context of their relationships.
  - Validation context propagation
  - Parent-child validation rules
  - Cross-resource validation patterns
- **Validation Dependency Graph**: Manage the order and dependencies of validations.
  - Automated validation order resolution through ValidationDependencyResolver
  - Circular dependency detection
  - Validation checkpointing
- **Error Collection and Reporting**: Provide clear error information.
  - Hierarchical error structure with ValidationErrorReporter
  - Path-based error navigation
  - Error visualization for nested resources via ValidationErrorsViewer

## Implementation

### Relationship Management

The Relationship Management System uses a DSL to define relationships between resources:

```elixir
relationships do
  has_many :posts, PostResource
  belongs_to :team, TeamResource
  has_many_through :team_members, through: [:team, :members]
  polymorphic :manageable, types: [PostResource, TeamResource]
end
```markdown

## Relationship Management Details

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

  This allows a user to access all members of their team through their own team relationship.

- **has_one_through**: Defines a relationship that goes through another relationship to access a single resource.

  ```elixir
  has_one_through :manager, through: [:team, :manager]
  ```markdown

  This allows a user to access their team's manager through their own team relationship.

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

## Relationship Resolution Process

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

### Relationship Validation Process

The validation process includes:

1. Checking if required relationships are present
2. Validating referential integrity when possible
3. Performing deep validation if requested
4. Validating cascading operations when applicable
5. Collecting detailed error information

### Error Handling for Relationships

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

## Best Practices for Relationships

- **Use Caching**: Enable caching for frequently accessed relationships
- **Consider Eager Loading**: Use eager loading when you know you'll need multiple relationships
- **Validate Before Updating/Deleting**: Always validate operations that might affect relationships
- **Use Cascading Operations Carefully**: Be cautious with cascading operations as they can affect multiple resources
- **Provide Meaningful Foreign Keys**: Explicitly specify foreign keys when they don't follow naming conventions

### Change Tracking

The Change Tracking System maintains an immutable history of changes to resources:

```elixir
# Track a change to a resource
{:ok, updated_user} = UserResource.track_change(user, %{name: "New Name"}, %{
  actor: "user@example.com",
  reason: "Name correction",
  source: "profile_edit_form"
})

# View change history
{:ok, changes} = UserResource.get_history(user)

# Get a specific version
{:ok, previous_version} = UserResource.get_version(user, 1)

# Create a diff between versions
{:ok, diff} = UserResource.diff_versions(user, version1: 1, version2: 2)
```markdown

## Nested Resource Validation (Implemented)

The Nested Resource Validation system enables validation of resources in the context of their relationships:

```elixir
# Define validations that span relationships with dependency tracking
validations do
  validate :team_member_has_valid_role, fn user ->
    if user.team && user.role not in user.team.allowed_roles do
      {:error, "User role not allowed in team"}
    else
      :ok
    end
  end, depends_on: [:team]
  
  validate_related :team, fn team ->
    if team.max_members && length(team.members) > team.max_members do
      {:error, "Team exceeds maximum member count"}
    else
      :ok
    end
  end
end

# Validate a resource and all its related resources with dependency resolution
{:ok, _} = UserResource.validate_deep(user)

# Inspect structured validation errors
{:error, errors} = UserResource.validate_deep(invalid_user)
hierarchical_errors = ValidationErrorReporter.format_errors(errors)
```markdown

## Resource Validation Viewer (Implemented)

The Resource Validation Viewer provides a visual interface for viewing validation errors in nested resources:

```heex
<.validation_errors_viewer
  resource={@user}
  errors={@validation_errors}
  show_nested={true}
  collapsible={true}
/>
```markdown

## UI Components

### Change History Viewer

The Change History Viewer component provides a user interface for viewing resource change history:

```heex
<.change_history_viewer
  resource={@user}
  selected_version={@selected_version}
  on_view_version="view_version"
  on_diff_versions="diff_versions"
/>
```markdown

## Future Enhancements

### Phase 4: Resource Transformation Pipeline (Planned)

- Resource transformation pipeline for data processing
  - Composable transformation functions
  - Pre/post validation transformations
  - Contextual transformation based on operation type

- Comprehensive resource event system
  - Event-driven architecture for resource lifecycle events
  - Subscriptions to specific resource events
  - Event aggregation and filtering

- Resource visualization tools for data exploration
- Support for resource versioning and branching
- Resource composition patterns for complex data models

## References

- [Change Tracking Documentation](CHANGE_TRACKING.md)
- [API Documentation](../ARCHITECTURE/API_DOCUMENTATION.md)
