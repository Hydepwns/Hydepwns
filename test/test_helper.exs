ExUnit.start()
{:ok, _} = Application.ensure_all_started(:hydepwns_liveview)
Ecto.Adapters.SQL.Sandbox.mode(HydepwnsLiveview.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:wallaby)

# Ensure all modules are loaded before tests
Code.require_file("support/theme_helper.ex", __DIR__)
Code.require_file("support/mock_helper.ex", __DIR__)
Code.require_file("support/resource_system_helper.ex", __DIR__)

# Start the resource system
{:ok, _} =
  case HydepwnsLiveview.Resources.ResourceSystem.start_link() do
    {:ok, pid} -> {:ok, pid}
    {:error, {:already_started, _pid}} -> {:ok, :already_started}
  end

# Define setup callback for all tests
defmodule HydepwnsLiveview.TestSetup do
  use ExUnit.CaseTemplate

  setup do
    HydepwnsLiveview.Resources.ResourceSystem.reset_store()
    :ok
  end
end
