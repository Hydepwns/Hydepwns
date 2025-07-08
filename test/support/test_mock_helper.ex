defmodule HydepwnsLiveviewWeb.TestMockHelper do
  @moduledoc """
  Helper module for setting up Mox mocks in tests.
  """

  def setup_mocks do
    # Define mock modules for external services
    Mox.defmock(HydepwnsLiveview.ExternalAPI, for: HydepwnsLiveview.ExternalAPI.Behaviour)
    Mox.defmock(HydepwnsLiveview.SecurityService, for: HydepwnsLiveview.SecurityService.Behaviour)
    Mox.defmock(HydepwnsLiveview.PerformanceService, for: HydepwnsLiveview.PerformanceService.Behaviour)
    Mox.defmock(HydepwnsLiveview.EventStore, for: HydepwnsLiveview.EventStore.Behaviour)

    # Set up default mock responses
    HydepwnsLiveview.ExternalAPI
    |> Mox.stub(:get_data, fn _id -> {:ok, %{id: "test", data: "mock_data"}} end)
    |> Mox.stub(:post_data, fn _data -> {:ok, %{id: "test", status: "created"}} end)

    HydepwnsLiveview.SecurityService
    |> Mox.stub(:validate_token, fn _token -> {:ok, %{user_id: "test_user", valid: true}} end)
    |> Mox.stub(:encrypt_data, fn data -> {:ok, "encrypted_#{data}"} end)
    |> Mox.stub(:decrypt_data, fn data -> {:ok, String.replace(data, "encrypted_", "")} end)

    HydepwnsLiveview.PerformanceService
    |> Mox.stub(:measure_execution_time, fn func ->
      start_time = System.monotonic_time(:millisecond)
      result = func.()
      end_time = System.monotonic_time(:millisecond)
      {:ok, result, end_time - start_time}
    end)

    HydepwnsLiveview.EventStore
    |> Mox.stub(:store_event, fn _type, _data -> {:ok, %{id: Ecto.UUID.generate()}} end)
    |> Mox.stub(:get_events, fn _criteria -> {:ok, []} end)
    |> Mox.stub(:list_events, fn -> {:ok, []} end)
  end
end
