defmodule PasswordManagement do
  use GenServer
  require Logger

  # Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, %{opts: opts}}
  end

  def get_events_for_resource(resource_type, resource_id) do
    HydepwnsLiveview.Events.EventStore.get_events_for_resource(resource_type, resource_id)
  end

  def handle_call({:get_events_for_resource, resource_type, resource_id}, _from, state) do
    events = EventStore.get_events_for_resource(resource_type, resource_id)
    {:reply, events, state}
  end
end 