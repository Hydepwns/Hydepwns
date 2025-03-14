---
title: Change-Tracking
description: >-
  ---

  title: Change Tracking Architecture

  description: A robust system for tracking changes to resources, maintaining an
  immutable history, and providing tools for auditing and visualizing changes

  category: reference

  subcategory: architecture

  order: 6

  last_updated: 2024-04-20

  contributors: 
    - backend_team
    - documentation_team
  status: active

  tags:
    - architecture
    - resources
    - change-tracking
    - auditing
  ---
topics:
  - reference
  - architecture
  - change-tracking
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - change-tracking-architecture
  - overview
  - features
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
  - integration-with-other-systems
  - performance-considerations
  - future-enhancements
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Change-Tracking

---
title: Change Tracking Architecture
description: A robust system for tracking changes to resources, maintaining an immutable history, and providing tools for auditing and visualizing changes
category: reference
subcategory: architecture
order: 6
last_updated: 2024-04-20
contributors: 
  - backend_team
  - documentation_team
status: active
tags:
  - architecture
  - resources
  - change-tracking
  - auditing
---


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

# Change-Tracking

---
title: Change Tracking Architecture
description: A robust system for tracking changes to resources, maintaining an immutable history, and providing tools for auditing and visualizing changes
category: reference
subcategory: architecture
order: 6
last_updated: 2024-04-20
contributors: 
  - backend_team
  - documentation_team
status: active
tags:
  - architecture
  - resources
  - change-tracking
  - auditing
---

# Change Tracking Architecture

## Overview

The Change Tracking Architecture provides a robust system for tracking changes to resources, maintaining an immutable history, and providing tools for auditing and visualizing changes. This system is part of the Advanced Resource Integration framework.

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
  use LiveviewUtils.LiveViewResource
  
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
2. **Use Selective Field Tracking**: When only certain fields are of interest for history, use the tracked_fields option.
3. **Handle Concurrency**: Always use optimistic concurrency control when multiple users might modify the same resource.
4. **Implement User-Friendly Conflict Resolution**: When conflicts occur, show users what changed and let them merge changes intentionally.
5. **Consider Storage Implications**: Change history can grow large over time; implement archiving or pruning strategies for old changes.
6. **Use Appropriate View Modes**: Choose the right view mode for each use case - timeline for temporal understanding, list for efficient review, audit for complete details.

## Integration with Other Systems

The Change Tracking Architecture integrates with other components of the system:

1. **Resource System**: All resources gain change tracking abilities with minimal configuration.
2. **LiveView Framework**: Change tracking is deeply integrated with the LiveView lifecycle.
3. **Validation Pipeline**: Changes are tracked only after validation succeeds.
4. **Authorization System**: Change tracking respects authorization rules and records authorization context.

## Performance Considerations

1. **Denormalized History Storage**: Change history is stored in a denormalized format for efficient retrieval.
2. **Lazy Loading**: History is loaded only when requested to minimize performance impact.
3. **Batch Processing**: When making bulk changes, use batch processing to minimize overhead.
4. **Memory Management**: Large histories are paginated to prevent excessive memory usage.

## Future Enhancements

1. **Change Subscriptions**: Subscribe to changes on specific resources or fields.
2. **Change Propagation**: Propagate changes to related resources automatically.
3. **Change Approval Workflows**: Implement approval workflows for critical changes.
4. **Advanced Visualization**: More sophisticated visualization options for complex changes.
5. **AI-Powered Change Summarization**: Automatically generate human-readable summaries of complex changes. 

## References

- [Project Documentation](../README.md)
