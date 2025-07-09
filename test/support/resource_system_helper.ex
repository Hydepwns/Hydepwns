defmodule HydepwnsLiveview.TestSupport.ResourceSystemHelper do
  @moduledoc """
  Helper functions for setting up the resource system in tests.
  """

  alias HydepwnsLiveview.Resources.ResourceSystem

  @doc """
  Sets up the resource system for tests.
  This ensures the ResourceSystem is available and the store is reset.
  """
  def setup_resource_system() do
    # The ResourceSystem is already started in the supervision tree
    # Reset the store and cache to ensure a clean state
    ResourceSystem.reset_store()
    ResourceSystem.reset_cache()
  end
end
