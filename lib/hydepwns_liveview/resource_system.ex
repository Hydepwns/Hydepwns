defmodule HydepwnsLiveview.ResourceSystem do
  @moduledoc """
  Manages resources in an in-memory store (Agent) for testing and demonstration.
  """

  # Use a named Agent to store resources
  @agent_name __MODULE__.Agent

  @doc """
  Defines the child specification for starting this module as a supervisor's child.
  """
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(opts \\ []) do
    Agent.start_link(fn -> %{} end, name: @agent_name)
  end

  def create_resource(attrs) do
    id = System.unique_integer([:positive])
    resource = Map.merge(%{
      id: id,
      name: Map.get(attrs, :name, "Test Resource " <> Integer.to_string(id)), # Ensure unique default name
      description: Map.get(attrs, :description, "A resource for testing"),
      type: Map.get(attrs, :type, "default"),
      data: Map.get(attrs, :data, %{})
    }, attrs)
    |> Map.put(:id, id) # Ensure ID is part of the final map

    Agent.update(@agent_name, fn state -> Map.put(state, id, resource) end)
    {:ok, resource}
  end

  def list_resources do
    Agent.get(@agent_name, fn state -> Map.values(state) end)
  end

  def get_resource(id) do
    Agent.get(@agent_name, fn state -> Map.get(state, id) end)
  end

  # Helper to reset the store, useful for tests
  def reset_store do
    Agent.update(@agent_name, fn _ -> %{} end)
  end
end 