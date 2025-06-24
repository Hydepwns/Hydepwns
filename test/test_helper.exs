ExUnit.start()
{:ok, _} = Application.ensure_all_started(:hydepwns_liveview)
Ecto.Adapters.SQL.Sandbox.mode(HydepwnsLiveview.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:wallaby)

# Load test stubs first to override dependency modules
Code.require_file("support/signal_nif_module.ex", __DIR__)
Code.require_file("support/signal_nif_stub.ex", __DIR__)
Code.require_file("support/signal_protocol_stub.ex", __DIR__)
Code.require_file("support/repo_behaviour.ex", __DIR__)
Code.require_file("support/repo_mock.ex", __DIR__)
Code.require_file("support/repo_helper.ex", __DIR__)

# Ensure all modules are loaded before tests
Code.require_file("support/theme_helper.ex", __DIR__)
Code.require_file("support/mock_helper.ex", __DIR__)
Code.require_file("support/resource_system_helper.ex", __DIR__)
Code.require_file("support/event_store_test_helper.ex", __DIR__)
Code.require_file("support/test_event_store.ex", __DIR__)
Code.require_file("support/fixtures/theme_system_fixtures.ex", __DIR__)

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
