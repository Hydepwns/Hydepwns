defmodule HydepwnsLiveview.Resources.Examples.UserResource do
  @moduledoc """
  Example of an event-sourced resource using the Resource Event System.

  This module demonstrates how to implement an event-sourced resource
  by following the EventSourcedResource behavior.
  """

  use HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource, snapshot_interval: 50

  alias HydepwnsLiveview.Events.Core.Event

  @doc """
  Returns the initial state for a user resource.

  Implements the EventSourcedResource behavior.
  """
  @impl true
  def initial_state do
    %{
      id: nil,
      email: nil,
      name: nil,
      status: "pending",
      created_at: nil,
      updated_at: nil,
      last_login_at: nil,
      metadata: %{}
    }
  end

  @doc """
  Returns the resource type for this module.

  Implements the EventSourcedResource behavior.
  """
  @impl true
  def resource_type, do: "user"

  @doc """
  Applies an event to the current state of the resource.

  Implements the EventSourcedResource behavior.
  """
  @impl true
  def apply_event(%Event{type: "user.created"} = event, state) do
    %{
      state
      | id: event.resource_id,
        email: event.data.email,
        name: event.data.name,
        status: "active",
        created_at: event.timestamp,
        updated_at: event.timestamp
    }
  end

  def apply_event(%Event{type: "user.updated"} = event, state) do
    # Update fields from event data
    updated_state =
      Enum.reduce(event.data, state, fn {key, value}, acc ->
        # Only update fields that exist in the state
        if Map.has_key?(acc, String.to_atom(key)) do
          Map.put(acc, String.to_atom(key), value)
        else
          acc
        end
      end)

    # Always update the updated_at timestamp
    %{updated_state | updated_at: event.timestamp}
  end

  def apply_event(%Event{type: "user.email_changed"} = event, state) do
    %{state | email: event.data.email, updated_at: event.timestamp}
  end

  def apply_event(%Event{type: "user.name_changed"} = event, state) do
    %{state | name: event.data.name, updated_at: event.timestamp}
  end

  def apply_event(%Event{type: "user.activated"} = event, state) do
    %{state | status: "active", updated_at: event.timestamp}
  end

  def apply_event(%Event{type: "user.deactivated"} = event, state) do
    %{state | status: "inactive", updated_at: event.timestamp}
  end

  def apply_event(%Event{type: "user.logged_in"} = event, state) do
    %{state | last_login_at: event.timestamp, updated_at: event.timestamp}
  end

  def apply_event(%Event{type: "user.deleted"} = event, state) do
    %{state | status: "deleted", updated_at: event.timestamp}
  end

  # Fallback for events that don't require special handling
  def apply_event(%Event{} = event, state) do
    %{state | updated_at: event.timestamp}
  end

  @doc """
  Creates events for resource creation.

  Overrides the default implementation from EventSourcedResource.
  """
  def create_events(id, params) do
    [
      %Event{
        id: Ecto.UUID.generate(),
        type: "user.created",
        resource_id: id,
        resource_type: "user",
        timestamp: DateTime.utc_now(),
        data: Map.take(params, ["email", "name", "metadata"])
      }
    ]
  end

  @doc """
  Generates events for an update.

  Overrides the default implementation from EventSourcedResource.
  """
  def update_events(resource, params) do
    events = []

    # Generate specific events for certain field changes
    events =
      if Map.has_key?(params, "email") && params["email"] != resource.email do
        [
          %Event{
            id: Ecto.UUID.generate(),
            type: "user.email_changed",
            resource_id: resource.id,
            resource_type: "user",
            timestamp: DateTime.utc_now(),
            data: %{email: params["email"]},
            metadata: %{previous_email: resource.email}
          }
          | events
        ]
      else
        events
      end

    events =
      if Map.has_key?(params, "name") && params["name"] != resource.name do
        [
          %Event{
            id: Ecto.UUID.generate(),
            type: "user.name_changed",
            resource_id: resource.id,
            resource_type: "user",
            timestamp: DateTime.utc_now(),
            data: %{name: params["name"]},
            metadata: %{previous_name: resource.name}
          }
          | events
        ]
      else
        events
      end

    # If we have other fields to update, generate a general update event
    other_fields = Map.drop(params, ["email", "name"])

    if map_size(other_fields) > 0 do
      [
        %Event{
          id: Ecto.UUID.generate(),
          type: "user.updated",
          resource_id: resource.id,
          resource_type: "user",
          timestamp: DateTime.utc_now(),
          data: other_fields
        }
        | events
      ]
    else
      events
    end
  end

  @doc """
  Executes a command on a user resource.

  ## Parameters
  * `resource` - The user resource
  * `command` - The command to execute
  * `params` - Command parameters

  ## Returns
  * `{:ok, events, updated_resource}` - Command executed successfully
  * `{:error, reason}` - Command failed
  """
  def execute_command(resource, command, params) do
    events =
      case command do
        "activate" ->
          [
            %Event{
              id: Ecto.UUID.generate(),
              type: "user.activated",
              resource_id: resource.id,
              resource_type: "user",
              timestamp: DateTime.utc_now(),
              data: %{},
              metadata: %{reason: params["reason"]}
            }
          ]

        "deactivate" ->
          [
            %Event{
              id: Ecto.UUID.generate(),
              type: "user.deactivated",
              resource_id: resource.id,
              resource_type: "user",
              timestamp: DateTime.utc_now(),
              data: %{},
              metadata: %{reason: params["reason"]}
            }
          ]

        "login" ->
          [
            %Event{
              id: Ecto.UUID.generate(),
              type: "user.logged_in",
              resource_id: resource.id,
              resource_type: "user",
              timestamp: DateTime.utc_now(),
              data: %{},
              metadata: %{
                ip_address: params["ip_address"],
                user_agent: params["user_agent"]
              }
            }
          ]

        _ ->
          raise "Unknown command: #{command}"
      end

    # Apply the events to the resource to get the updated user
    updated_user = Enum.reduce(events, resource, fn event, acc -> apply_event(event, acc) end)

    {:ok, events, updated_user}
  end

  @doc """
  Updates a user resource.

  ## Parameters
  * `resource` - The user resource to update
  * `updates` - The update parameters
  * `metadata` - Optional metadata for the update

  ## Returns
  * `{:ok, updated_resource}` - Update successful
  * `{:error, reason}` - Update failed
  """
  def update(resource, updates, metadata) do
    # Create an update event
    event = %Event{
      id: Ecto.UUID.generate(),
      type: "user.updated",
      resource_id: resource.id,
      resource_type: "user",
      timestamp: DateTime.utc_now(),
      data: updates,
      metadata: metadata
    }

    # Apply the event to get the updated user
    updated_user = apply_event(event, resource)

    {:ok, updated_user}
  end

  @doc """
  Updates a user resource with tracking (for audit/telemetry).

  ## Parameters
  * `resource` - The user resource to update
  * `updates` - The update parameters
  * `metadata` - Additional metadata for the update
  * `opts` - Optional context/options (unused)

  ## Returns
  * `{:ok, updated_resource}` or `{:error, reason}`
  """
  def update_with_tracking(resource, updates, metadata, _opts \\ %{}) do
    update(resource, updates)
  end
end
