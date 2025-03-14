---
title: Change Tracking Architecture
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - features
  - change-tracking-architecture
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - architecture
  - usage
  - track-a-change-to-a-resource
  - selective-field-tracking
  - only-track-changes-to-specific-fields-even-if-other-fields-change
  - viewing-change-history
  - get-all-change-history
  - get-recent-changes
  - get-changes-by-a-specific-user
  - get-changes-since-a-specific-time
  - versioned-resources
  - get-a-specific-version-of-a-resource
  - create-a-diff-between-versions
  - optimistic-concurrency-control
  - update-with-optimistic-concurrency-control
  - integration-with-liveviews
  - in-your-liveview-template
  - handle-events-in-your-liveview
  - handle-view-mode-changes
  - deep-diffing-for-nested-structures
  - the-diff-now-includes-nested-diff-for-maps-and-lists
  - example-diff-result-format-
  - serialization-and-persistence
  - serialize-change-history
  - save-to-database-or-file-
  - later-deserialize-history
  - creating-change-aware-resources
  - best-practices
  - performance-considerations
  - ui-considerations
  - integration-with-context-aware-validation
  - update-with-context-validation
  - integration-with-liveviewapi
  - conclusion
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Change Tracking Architecture

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

# Change Tracking Architecture


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

The Change Tracking Architecture provides a robust system for tracking changes to resources, maintaining an immutable history, and providing tools for auditing and visualizing changes. This system is part of the Advanced Resource Integration for the Hydepwns LiveView framework.

## Features

- **Immutable Change History**: Every change to a resource is recorded in an append-only history.
- **Before/After Snapshots**: Each change includes the complete state before and after the change.
- **Change Metadata Tracking**: Track who made changes, when they were made, and why.
- **Selective Field Tracking**: Focus on specific fields that have changed, ignoring others.
- **Deep Diffing**: Compare nested structures with detailed visualization of changes.
- **Optimistic Concurrency Control**: Prevent conflicts when multiple users try to update the same resource.
- **Change Serialization**: Persist change history to a database or file system.
- **Visual Change Tracking**: View changes over time with timeline, list, and audit log views.

## Architecture

The Change Tracking Architecture consists of several components:

1. **ChangeTracker**: Core module for tracking changes and maintaining history.
2. **LiveViewResource Integration**: Extensions to LiveViewResource to work with ChangeTracker.
3. **LiveViewAPI Integration**: Extensions to LiveViewAPI for change tracking in LiveViews.
4. **ChangeHistoryViewer**: UI component for visualizing change history with multiple view modes.

## Usage

### Basic Change Tracking

```elixir
# Track a change to a resource
{:ok, updated_user} = UserResource.track_change(user, %{name: "New Name"}, %{
  actor: "user@example.com",
  reason: "Name correction",
  source: "profile_edit_form"
})
```markdown

## Selective Field Tracking

```elixir
# Only track changes to specific fields, even if other fields change
{:ok, updated_user} = UserResource.track_change(
  user, 
  %{name: "New Name", email: "new@example.com", role: "admin"}, 
  %{
    actor: "admin@example.com",
    reason: "Name correction only",
    source: "profile_edit_form",
    tracked_fields: [:name] # Only track changes to the name field
  }
)
```markdown

## Viewing Change History

```elixir
# Get all change history
{:ok, changes} = UserResource.get_history(user)

# Get recent changes
{:ok, recent_changes} = UserResource.get_history(user, limit: 5)

# Get changes by a specific user
{:ok, admin_changes} = UserResource.get_history(user, by_actor: "admin@example.com")

# Get changes since a specific time
{:ok, recent_changes} = UserResource.get_history(user, since: ~N[2023-01-01 00:00:00])
```markdown

## Versioned Resources

```elixir
# Get a specific version of a resource
{:ok, previous_version} = UserResource.get_version(user, 1)

# Create a diff between versions
{:ok, diff} = UserResource.diff_versions(user, version1: 1, version2: 2)
```markdown

## Optimistic Concurrency Control

```elixir
# Update with optimistic concurrency control
case UserResource.check_concurrent_update(user, 2, %{name: "New Name"}) do
  {:ok, _} -> 
    # The resource has not changed since version 2, safe to update
    {:ok, updated_user} = UserResource.track_change(user, %{name: "New Name"}, %{
      expected_version: 2
    })
    
  {:error, :stale_resource} -> 
    # The resource has been updated since version 2, need to handle conflict
    # Perhaps show the user the changes and let them reapply their changes
    
  {:error, reason} -> 
    # Some other error occurred
end
```markdown

## Integration with LiveViews

```elixir
def handle_event("update_user", %{"user" => params}, socket) do
  # Update with change tracking
  metadata = %{
    actor: get_current_user_email(socket),
    reason: "User profile update",
    source: "profile_page"
  }
  
  case LiveViewAPI.update_with_tracking(socket, :user, params, metadata) do
    {:ok, updated_socket} ->
      {:noreply, updated_socket}
      
    {:error, :stale_resource, socket} ->
      {:noreply, put_flash(socket, :error, "Resource was modified by someone else")}
      
    {:error, message, socket} ->
      {:noreply, put_flash(socket, :error, message)}
  end
end

def handle_event("view_history", _params, socket) do
  {:ok, history} = LiveViewAPI.get_history(socket, :user)
  {:noreply, assign(socket, :change_history, history)}
end
```markdown

### Using the Enhanced ChangeHistoryViewer Component

The `ChangeHistoryViewer` component now offers three different view modes:

1. **Timeline View**: A visual timeline showing changes over time
2. **List View**: A table-based view with detailed information
3. **Audit Log View**: A comprehensive audit log with detailed changes

```elixir
# In your LiveView template
<.change_history_viewer
  resource={@user}
  selected_version={@selected_version}
  on_view_version="view_version"
  on_diff_versions="diff_versions"
  versioned_resource={@versioned_user}
  diff={@diff}
  view_mode={@view_mode}
/>

# Handle events in your LiveView
def handle_event("view_version", %{"version" => version_str}, socket) do
  version = String.to_integer(version_str)
  {:ok, versioned_user} = LiveViewAPI.get_version(socket, :user, version)
  
  socket = 
    socket
    |> assign(:versioned_user, versioned_user)
    |> assign(:selected_version, version)
  
  {:noreply, socket}
end

def handle_event("diff_versions", %{"version1" => v1, "version2" => v2}, socket) do
  v1 = String.to_integer(v1)
  v2 = String.to_integer(v2)
  
  {:ok, diff} = LiveViewAPI.diff_versions(socket, :user, version1: v1, version2: v2)
  
  {:noreply, assign(socket, :diff, diff)}
end

# Handle view mode changes
def handle_event("set_view_mode", %{"mode" => mode}, socket) when mode in ["timeline", "list", "audit"] do
  {:noreply, assign(socket, :view_mode, mode)}
end
```markdown

## Deep Diffing for Nested Structures

The change tracking system now supports deep diffing for nested structures, allowing you to visualize changes at any level of nesting:

```elixir
# Create a diff between versions
{:ok, diff} = UserResource.diff_versions(user, version1: 1, version2: 2)

# The diff now includes nested_diff for maps and lists
# Example diff result format:
%{
  "settings" => %{
    before: %{theme: "light", notifications: true},
    after: %{theme: "dark", notifications: false},
    nested_diff: %{
      "theme" => %{
        before: "light",
        after: "dark"
      },
      "notifications" => %{
        before: true,
        after: false
      }
    }
  }
}
```markdown

## Serialization and Persistence

The change history can be serialized for persistence and later deserialized:

```elixir
# Serialize change history
{:ok, serialized} = UserResource.serialize_history(user, format: :json)

# Save to database or file...

# Later, deserialize history
{:ok, user_with_history} = UserResource.deserialize_history(user, serialized, format: :json)
```markdown

## Creating Change-Aware Resources

All resources defined with `LiveViewResource` automatically have change tracking capabilities. To implement custom change tracking behavior, you can override the functions in your resource module:

```elixir
defmodule MyApp.UserResource do
  use HydepwnsLiveview.Utils.LiveViewResource
  
  # ... attributes, relationships, validations ...
  
  # Customized track_change implementation
  def track_change(resource, changes, metadata) do
    # Custom pre-processing
    processed_changes = preprocess_changes(changes)
    
    # Call the built-in implementation
    super(resource, processed_changes, metadata)
  end
  
  # Helper for pre-processing changes
  defp preprocess_changes(changes) do
    # Add custom logic...
    changes
  end
end
```markdown

## Best Practices

1. **Include Meaningful Metadata**: Always include relevant metadata when tracking changes, especially actor, reason, and source.

2. **Use Selective Field Tracking**: When appropriate, use the `tracked_fields` option to focus on specific fields rather than tracking all changes. This is especially useful for large resources.

3. **Use Optimistic Concurrency Control**: For resources that might be updated by multiple users, always use optimistic concurrency control.

4. **Be Selective with History**: For very frequent changes or long-lived resources, consider purging old history or storing it separately.

5. **Handle Conflicts Gracefully**: When conflicts occur, give users clear options for resolving them, such as refreshing the data or merging changes.

6. **Use Versioned APIs**: For critical systems, consider exposing versioned resources through your API to ensure consistency.

## Performance Considerations

1. **Memory Usage**: Each change includes a snapshot of the resource before the change, which can use significant memory for large resources. Consider using `serialize_history` with `include_data: false` to save space.

2. **Deep Diffs**: Computing diffs between complex nested structures can be computationally expensive. Cache results when possible.

3. **Selective Tracking**: Only track changes for resources where history is important. Not every resource needs full change tracking.

4. **Batch Operations**: When performing batch updates, consider collecting all changes first, then applying them as a single tracked change.

## UI Considerations

1. **View Mode Flexibility**: The ChangeHistoryViewer component offers multiple view modes. Consider which mode is most appropriate for your users:
   - Timeline view works well for visualizing changes over time
   - List view is best for dense information in a compact format
   - Audit log view is best for detailed auditing and compliance needs

2. **Diff Visualization**: Use the nested diff visualization to help users understand complex changes to nested structures.

3. **Mobile Optimization**: The enhanced timeline view is now more mobile-friendly with improved layout and touch targets.

## Integration with Context-Aware Validation

The Change Tracking system now integrates fully with the Context-Aware Validation system, allowing for sophisticated validation rules to be applied before changes are tracked.

### Using Context Validation with Change Tracking

```elixir
# Update with context validation
{:ok, updated_user} = UserResource.update_with_tracking(user, %{role: "admin"}, %{
  actor: "admin@example.com",
  reason: "Role promotion",
  source: "admin_panel",
  context_validation: true,
  validation_rules: [:role_permissions_valid, :access_level_valid],
  validation_context: %{
    allowed_roles: ["admin", "editor"],
    current_user: %{role: "admin"}
  }
})
```markdown

## Integration with LiveViewAPI

The LiveViewAPI has been enhanced to support context validation:

```elixir
case LiveViewAPI.update_with_tracking(socket, :user, %{role: "admin"}, %{
  actor: get_current_user_email(socket),
  reason: "Role promotion",
  source: "admin_panel",
  context_validation: true,
  validation_rules: [:role_permissions_valid],
  validation_context: %{
    allowed_roles: ["admin", "editor"],
    current_user: get_current_user(socket)
  }
}) do
  {:ok, updated_socket} ->
    {:noreply, updated_socket}
    
  {:error, :stale_resource, socket} ->
    {:noreply, put_flash(socket, :error, "Resource was modified by someone else")}
    
  {:error, message, socket} ->
    {:noreply, put_flash(socket, :error, message)}
end
```markdown

### Resource-Level Context Validation Configuration

You can configure a resource to always use context validation by implementing the `__context_validation__/0` function:

```elixir
defmodule MyApp.UserResource do
  use HydepwnsLiveview.Utils.LiveViewResource
  
  # Always use context validation for this resource
  def __context_validation__, do: true
  
  # Define validation rules
  def __validation_rules__ do
    [
      role_valid: fn resource, context ->
        allowed_roles = Map.get(context, :allowed_roles, ["user", "admin"])
        
        if resource.role in allowed_roles do
          :ok
        else
          {:error, "Invalid role"}
        end
      end
    ]
  end
  
  # ... attributes, relationships, etc.
end
```markdown

## Conclusion

The Change Tracking Architecture provides a powerful system for tracking changes to resources, allowing for auditing, history viewing, and conflict prevention. With the addition of selective field tracking, deep diffing, and enhanced visualization tools, it now offers even more flexibility and power for building robust, change-aware applications. 

## References

- [Project Documentation](../README.md)
