defmodule HydepwnsLiveviewWeb.MockHelper do
  @moduledoc """
  Helper for mocking external dependencies in tests.

  This module provides utilities for creating and using mocks in tests,
  particularly for external services and APIs that should not be called
  during testing.

  ## Usage

  ```elixir
  # In your test setup
  setup do
    MockHelper.setup_mocks()
    :ok
  end

  # In your test
  test "external API call is mocked", %{conn: conn} do
    MockHelper.expect_api_call(:external_service, :get_data, fn _ -> 
      {:ok, %{"result" => "mocked data"}} 
    end)
    
    # Test with mocked API
  end
  ```

  """

  import Mox

  @doc """
  Sets up mocks for external dependencies.

  Call this in your test setup to ensure mocks are properly configured.
  """
  def setup_mocks do
    # Reset all mocks before each test
    Mox.stub_with(HydepwnsLiveview.MockHTTPClient, HydepwnsLiveview.DefaultHTTPClient)
    Mox.stub_with(HydepwnsLiveview.MockExternalAPI, HydepwnsLiveview.DefaultExternalAPI)
    :ok
  end

  @doc """
  Expects an API call to be made with the given parameters and returns the specified result.

  ## Parameters

  - `service` - The service being mocked (e.g., `:external_service`)
  - `action` - The action being performed (e.g., `:get_data`)
  - `callback` - A function that takes the parameters and returns a mocked result

  ## Example

  ```elixir
  MockHelper.expect_api_call(:external_service, :get_data, fn _ -> 
    {:ok, %{"result" => "mocked data"}} 
  end)
  ```
  """
  def expect_api_call(mock, fun, implementation) do
    mock =
      case mock do
        :external_api -> HydepwnsLiveview.MockExternalAPI
        :http_client -> HydepwnsLiveview.MockHTTPClient
        m when is_atom(m) -> m
        m -> m
      end
    Mox.expect(mock, fun, implementation)
  end

  @doc """
  Verifies that all expected calls were made.

  Call this at the end of your test to ensure all expected mocked calls were made.
  """
  def verify_all_mocks do
    verify!(HydepwnsLiveview.MockHTTPClient)
    verify!(HydepwnsLiveview.MockExternalAPI)
  end

  def expect_api_call(:external_api, :fetch_data, callback) when is_function(callback, 1) do
    expect(HydepwnsLiveview.MockExternalAPI, :fetch_data, fn id ->
      callback.(id)
    end)
  end

  def expect_api_call(:external_api, :update_resource, callback) when is_function(callback, 2) do
    expect(HydepwnsLiveview.MockExternalAPI, :update_resource, fn id, data ->
      callback.(id, data)
    end)
  end
end
