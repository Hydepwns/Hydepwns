Mox.set_mox_global(false)
ExUnit.start()
{:ok, _} = Application.ensure_all_started(:hydepwns_liveview)

# Load test support files
Code.require_file("test/support/signal_nif_stub.ex")

# Ensure the ETS table for mock resources exists and is public
if :ets.whereis(:mock_resources) == :undefined do
  :ets.new(:mock_resources, [:set, :public, :named_table])
end

# Ensure the theme system ETS table exists for all tests
if :ets.whereis(:theme_system_default) == :undefined do
  :ets.new(:theme_system_default, [:set, :public, :named_table])
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

# Start MockEventStore globally for all tests
case HydepwnsLiveview.TestSupport.MockEventStore.start_link([]) do
  {:ok, _pid} -> :ok
  {:error, {:already_started, _pid}} -> :ok
end

# Start EventMonitor globally for all tests with TestEventStore
case HydepwnsLiveview.Events.Core.EventMonitor.start_link(
       event_store: HydepwnsLiveview.Events.TestEventStore
     ) do
  {:ok, _pid} -> :ok
  {:error, {:already_started, _pid}} -> :ok
end

# Define setup callback for all tests
defmodule HydepwnsLiveview.TestSetup do
  use ExUnit.CaseTemplate

  setup do
    HydepwnsLiveview.Resources.ResourceSystem.reset_store()
    # Ensure theme system has a default theme for tests
    HydepwnsLiveview.ThemeSystem.ensure_default_theme()

    # Allow the MockEventStore process to use the test's DB connection
    if Process.whereis(HydepwnsLiveview.TestSupport.MockEventStore) do
      Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, self(), Process.whereis(HydepwnsLiveview.TestSupport.MockEventStore))
    end

    :ok
  end
end
