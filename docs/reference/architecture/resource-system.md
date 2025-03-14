---
title: Resource-System
description: '## Overview'
topics:
  - reference
  - architecture
  - resource-system
  - overview
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - introduction
  - table-of-contents
  - core-concepts
  - creating-resources
  - create-a-resource
  - update-a-resource
  - delete-a-resource
  - validate-a-resource
  - transform-a-resource
  - relationships-between-resources
  - load-related-resources
  - access-related-resources
  - create-with-relationships
  - update-relationships
  - validation-system
  - basic-validation
  - validation-with-context
  - validate-specific-rules
  - deep-validation-includes-related-resources-
  - change-tracking
  - track-changes-with-metadata
  - get-change-history
  - get-specific-version-of-a-resource
  - compare-versions
  - optimistic-concurrency-control
  - event-system-integration
  - subscribe-to-resource-events
  - handle-events
  - publish-custom-events
  - event-sourcing
  - live-view-integration
  - advanced-features
  - batch-create
  - batch-update
  - batch-delete
  - performance-considerations
  - configure-caching
  - use-cached-resources
  - invalidate-cache
  - eager-loading
  - eager-load-relationships-for-better-performance
  - pagination-and-filtering
  - paginate-results
  - filter-resources
  - sort-resources
  - best-practices
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Resource-System

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

This document provides information about Resource-System.


---
title: Resource System
description: A comprehensive solution for managing domain entities in your application through an event-sourced approach
category: reference
subcategory: architecture
order: 2
last_updated: 2024-04-20
contributors: 
  - backend_team
  - documentation_team
status: active
tags:
  - architecture
  - resources
  - event-sourcing
  - domain-entities
---

# Resource System

## Introduction

The Resource System is a comprehensive solution for managing domain entities in your application through an event-sourced approach. This document explains the system's architecture, how to create and use resources, and how to leverage the various features available.

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Creating Resources](#creating-resources)
3. [Relationships Between Resources](#relationships-between-resources)
4. [Validation System](#validation-system)
5. [Change Tracking](#change-tracking)
6. [Event System Integration](#event-system-integration)
7. [Live View Integration](#live-view-integration)
8. [Advanced Features](#advanced-features)
9. [Performance Considerations](#performance-considerations)
10. [Best Practices](#best-practices)

## Core Concepts

The Resource System is built around several key concepts:

### Resources

Resources are domain entities with defined:
- Attributes (data)
- Relationships (connections to other resources)
- Validations (rules for data integrity)
- Transformations (ways to convert between formats)
- Behaviors (functional capabilities)

### Events

All changes to resources generate events that:
- Record what changed, when, and why
- Allow for audit trails
- Enable event sourcing patterns
- Facilitate real-time updates

### Transformations

Resources can be transformed:
- Between different formats (e.g., database to API, API to UI)
- With added computed properties
- By filtering sensitive data
- Through context-aware processing

### Validation Pipeline

Resources are validated through:
- Attribute-level validation
- Resource-level validation
- Cross-resource validation
- Context-aware validation

## Creating Resources

### Basic Resource Definition

```elixir
defmodule MyApp.UserResource do
  use HydepwnsResource
  
  attributes do
    attribute :id, :uuid, primary_key: true
    attribute :name, :string, required: true
    attribute :email, :string, format: :email
    attribute :age, :integer, min: 18
    attribute :preferences, :map
    attribute :created_at, :utc_datetime, default: &DateTime.utc_now/0
  end
  
  relationships do
    belongs_to :team, MyApp.TeamResource
    has_many :posts, MyApp.PostResource
  end
  
  validations do
    validate :email_must_be_unique, fn resource, context ->
      # Validation logic
    end
  end
  
  transformations do
    transforms_to :api_v1 do
      excludes [:created_at]
      computes :full_name, fn resource -> "#{resource.name}" end
    end
  end
end
```markdown

### Working with Resources

```elixir
# Create a resource
{:ok, user} = UserResource.create(%{
  name: "Jane Doe",
  email: "jane@example.com",
  age: 30
})

# Update a resource
{:ok, updated_user} = UserResource.update(user, %{
  preferences: %{theme: "dark"}
})

# Delete a resource
{:ok, _} = UserResource.delete(user)

# Validate a resource
case UserResource.validate(user) do
  :ok -> 
    # Resource is valid
  {:error, errors} -> 
    # Handle validation errors
end

# Transform a resource
api_user = UserResource.transform(user, to: :api_v1)
```markdown

## Relationships Between Resources

### Defining Relationships

```elixir
defmodule MyApp.UserResource do
  use HydepwnsResource
  
  # ... attributes ...
  
  relationships do
    belongs_to :team, MyApp.TeamResource
    has_many :posts, MyApp.PostResource
    has_many :comments, through: :posts
    has_one :profile, MyApp.ProfileResource
    many_to_many :roles, MyApp.RoleResource
  end
end
```markdown

### Working with Relationships

```elixir
# Load related resources
{:ok, user_with_posts} = UserResource.load(user, [:posts])

# Access related resources
posts = user_with_posts.posts

# Create with relationships
{:ok, user} = UserResource.create(%{
  name: "Jane Doe",
  team_id: team.id,
  posts: [%{title: "First Post"}]
})

# Update relationships
{:ok, updated_user} = UserResource.update(user, %{
  posts: [%{id: post.id, title: "Updated Title"}]
})
```markdown

## Validation System

### Defining Validations

```elixir
defmodule MyApp.UserResource do
  use HydepwnsResource
  
  # ... attributes and relationships ...
  
  validations do
    # Field-level validations
    validates :name, presence: true, length: [min: 2, max: 100]
    validates :email, format: [with: ~r/@/], uniqueness: true
    
    # Resource-level validations
    validate :valid_age_for_role, fn resource, context ->
      if resource.role == "admin" && resource.age < 21 do
        {:error, "Admin users must be at least 21 years old"}
      else
        :ok
      end
    end
    
    # Related resource validations
    validate_related :team, :member_limit_not_exceeded, fn team, _user, context ->
      if team.max_members && length(team.members) >= team.max_members do
        {:error, "Team has reached member limit"}
      else
        :ok
      end
    end
  end
end
```markdown

### Validating Resources

```elixir
# Basic validation
case UserResource.validate(user) do
  :ok -> 
    # Resource is valid
  {:error, errors} -> 
    # Handle validation errors
end

# Validation with context
validation_context = %{
  current_user: admin_user,
  action: :create
}

case UserResource.validate(user, context: validation_context) do
  :ok -> 
    # Resource is valid in this context
  {:error, errors} -> 
    # Handle validation errors
end

# Validate specific rules
case UserResource.validate_with_rules(user, rules: [:valid_age_for_role]) do
  :ok -> 
    # Specified rules passed
  {:error, errors} -> 
    # Handle validation errors
end

# Deep validation (includes related resources)
case UserResource.validate_deep(user) do
  :ok -> 
    # Resource and its relationships are valid
  {:error, errors} -> 
    # Handle validation errors
end
```markdown

## Change Tracking

The Resource System includes a comprehensive change tracking system:

```elixir
# Track changes with metadata
{:ok, updated_user} = UserResource.track_change(user, %{name: "New Name"}, %{
  actor: "user@example.com",
  reason: "Name correction",
  source: "profile_edit_form"
})

# Get change history
{:ok, changes} = UserResource.get_history(user)

# Get specific version of a resource
{:ok, previous_version} = UserResource.get_version(user, 1)

# Compare versions
{:ok, diff} = UserResource.diff_versions(user, version1: 1, version2: 2)

# Optimistic concurrency control
case UserResource.check_concurrent_update(user, 2, %{name: "New Name"}) do
  {:ok, _} -> 
    # Safe to update
  {:error, :stale_resource} -> 
    # Handle conflict
end
```markdown

## Event System Integration

Resources automatically generate events for various operations:

```elixir
# Subscribe to resource events
ResourceEventBus.subscribe({UserResource, :created})
ResourceEventBus.subscribe({UserResource, :updated})
ResourceEventBus.subscribe({UserResource, :deleted})

# Handle events
def handle_event({UserResource, :created}, %{resource: user} = event_data) do
  # React to user creation
end

# Publish custom events
UserResource.publish_event(user, :email_changed, %{
  old_email: "old@example.com",
  new_email: "new@example.com"
})

# Event sourcing
{:ok, user} = UserResource.from_events(user_events)
```markdown

## Live View Integration

The Resource System integrates with Phoenix LiveView:

```elixir
defmodule MyApp.UserLive do
  use MyApp.LiveView
  
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_resource(:user, %{})}
  end
  
  def handle_event("save", %{"user" => user_params}, socket) do
    case update_resource(socket, :user, user_params) do
      {:ok, socket} ->
        {:noreply, socket |> put_flash(:info, "User saved")}
        
      {:error, socket} ->
        {:noreply, socket |> put_flash(:error, "Invalid data")}
    end
  end
end
```markdown

## Advanced Features

### Resource Observers

```elixir
defmodule MyApp.UserObserver do
  use HydepwnsResource.Observer
  
  observe UserResource do
    after_create fn user ->
      # Send welcome email
    end
    
    after_update fn user, changes when :email in changes ->
      # Send email verification
    end
    
    before_delete fn user ->
      # Archive user data
    end
  end
end
```markdown

### Resource Policies

```elixir
defmodule MyApp.UserPolicy do
  use HydepwnsResource.Policy
  
  policy_for UserResource do
    def can?(:create, _resource, %{user: user}) do
      user.admin?
    end
    
    def can?(:update, resource, %{user: user}) do
      user.id == resource.id || user.admin?
    end
    
    def can?(:delete, resource, %{user: user}) do
      user.admin?
    end
  end
end
```markdown

### Batch Operations

```elixir
# Batch create
{:ok, users} = UserResource.batch_create([
  %{name: "User 1", email: "user1@example.com"},
  %{name: "User 2", email: "user2@example.com"}
])

# Batch update
{:ok, updated_users} = UserResource.batch_update(users, [
  %{id: user1.id, role: "admin"},
  %{id: user2.id, role: "editor"}
])

# Batch delete
{:ok, _} = UserResource.batch_delete(users)
```markdown

## Performance Considerations

### Resource Caching

```elixir
# Configure caching
config :hydepwns, :resource_cache,
  enabled: true,
  ttl: 300, # seconds
  max_size: 1000

# Use cached resources
{:ok, user} = UserResource.get(id, cache: true)

# Invalidate cache
UserResource.invalidate_cache(user)
UserResource.invalidate_cache_all()
```markdown

## Eager Loading

```elixir
# Eager load relationships for better performance
{:ok, user} = UserResource.get(id, preload: [:team, :posts])
{:ok, users} = UserResource.list(preload: [:team, posts: [:comments]])
```markdown

## Pagination and Filtering

```elixir
# Paginate results
{:ok, %{data: users, metadata: metadata}} = UserResource.list(
  page: 2,
  per_page: 20
)

# Filter resources
{:ok, users} = UserResource.list(
  filter: [
    role: "admin",
    age: [gte: 21]
  ]
)

# Sort resources
{:ok, users} = UserResource.list(
  sort: [
    desc: :created_at,
    asc: :name
  ]
)
```markdown

## Best Practices

1. **Resource Design**
   - Keep resources focused on domain concepts
   - Use descriptive names for attributes and relationships
   - Leverage computed attributes for derived data

2. **Validation Strategy**
   - Place validations at the appropriate level
   - Use context-aware validations for complex rules
   - Create reusable validation modules for common patterns

3. **Performance Optimization**
   - Eager load relationships that are always needed
   - Use pagination for large collections
   - Leverage caching for read-heavy resources

4. **Event Handling**
   - Subscribe to specific events rather than all events
   - Keep event handlers small and focused
   - Use event sourcing for audit-critical resources

5. **Security Considerations**
   - Implement resource policies for authorization
   - Use transformations to filter sensitive data
   - Validate all input, even from trusted sources


## References

- [Project Documentation](../README.md)
