defmodule HydepwnsLiveview.TestSupport.ResourceSystemHelper do
  @moduledoc """
  Helper functions for setting up the resource system in tests.
  """

  alias HydepwnsLiveview.Resources.ResourceSystem

  @doc """
  Sets up the resource system for tests.
  This ensures the Agent is started and the store is reset.
  """
  def setup_resource_system() do
    # Start the Agent if it's not already running
    case Process.whereis(ResourceSystem.Agent) do
      nil ->
        {:ok, _} = ResourceSystem.start_link()

      _ ->
        :ok
    end

    # Reset the store to ensure a clean state
    ResourceSystem.reset_store()
  end
end
