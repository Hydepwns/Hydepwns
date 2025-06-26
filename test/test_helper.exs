ExUnit.start()
{:ok, _} = Application.ensure_all_started(:hydepwns_liveview)

# Ensure the ETS table for mock resources exists and is public
unless :ets.whereis(:mock_resources) != :undefined do
  :ets.new(:mock_resources, [:set, :public, :named_table])
end

# Configure Ecto sandbox for proper async test support
Ecto.Adapters.SQL.Sandbox.mode(HydepwnsLiveview.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:wallaby)

# Start the resource system
{:ok, _} =
  case HydepwnsLiveview.Resources.ResourceSystem.start_link() do
    {:ok, pid} -> {:ok, pid}
    {:error, {:already_started, _pid}} -> {:ok, :already_started}
  end

# Set up global mocks for all tests
HydepwnsLiveviewWeb.TestMockHelper.setup_mocks()

# Define setup callback for all tests
defmodule HydepwnsLiveview.TestSetup do
  use ExUnit.CaseTemplate

  setup do
    HydepwnsLiveview.Resources.ResourceSystem.reset_store()
    :ok
  end
end
