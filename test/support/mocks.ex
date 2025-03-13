defmodule HydepwnsLiveview.Mocks do
  @moduledoc """
  Defines mocks for external dependencies used in tests.

  This module defines mock behaviors that can be used to substitute
  real implementations during tests.
  """

  # Define behavior for HTTP client
  defmodule HTTPClientBehaviour do
    @moduledoc """
    Behavior for HTTP client implementations.
    """

    @callback get(String.t(), list(), keyword()) ::
                {:ok, %{status: integer(), body: String.t(), headers: list()}}
                | {:error, term()}

    @callback post(String.t(), map(), list(), keyword()) ::
                {:ok, %{status: integer(), body: String.t(), headers: list()}}
                | {:error, term()}
  end

  # Define behavior for external API client
  defmodule ExternalAPIBehaviour do
    @moduledoc """
    Behavior for external API client implementations.
    """

    @callback fetch_data(String.t()) :: {:ok, map()} | {:error, term()}
    @callback update_resource(String.t(), map()) :: {:ok, map()} | {:error, term()}
    @callback delete_resource(String.t()) :: :ok | {:error, term()}
  end

  # Define implementation modules
  defmodule DefaultHTTPClient do
    @moduledoc """
    Default implementation of HTTP client behavior.

    This module provides a real implementation that would be used in production.
    """

    @behaviour HTTPClientBehaviour

    @impl true
    def get(url, headers \\ [], opts \\ []) do
      # This would be a real HTTP request in production
      # We're providing a simple implementation for use with mocks
      {:ok, %{status: 200, body: "{}", headers: []}}
    end

    @impl true
    def post(url, body, headers \\ [], opts \\ []) do
      # This would be a real HTTP request in production
      {:ok, %{status: 201, body: "{}", headers: []}}
    end
  end

  defmodule DefaultExternalAPI do
    @moduledoc """
    Default implementation of external API behavior.

    This module provides a real implementation that would be used in production.
    """

    @behaviour ExternalAPIBehaviour

    @impl true
    def fetch_data(id) do
      # Real implementation would call external API
      {:ok, %{"id" => id, "data" => "sample data"}}
    end

    @impl true
    def update_resource(id, data) do
      # Real implementation would call external API
      {:ok, Map.put(data, "id", id)}
    end

    @impl true
    def delete_resource(id) do
      # Real implementation would call external API
      :ok
    end
  end
end

# Define mocks
Mox.defmock(HydepwnsLiveview.MockHTTPClient, for: HydepwnsLiveview.Mocks.HTTPClientBehaviour)
Mox.defmock(HydepwnsLiveview.MockExternalAPI, for: HydepwnsLiveview.Mocks.ExternalAPIBehaviour)
