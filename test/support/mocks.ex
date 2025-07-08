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

  # Define behavior for Security Logger
  defmodule SecurityLoggerBehaviour do
    @moduledoc """
    Behavior for Security Logger implementations.
    """

    @callback log_security_event(String.t(), map()) :: {:ok, String.t()} | {:error, term()}
  end

  # Define behavior for Security Detector
  defmodule SecurityDetectorBehaviour do
    @moduledoc """
    Behavior for Security Detector implementations.
    """

    @callback detect_suspicious_activity(map()) :: {:warning, String.t()} | {:ok, String.t()} | {:error, term()}
  end

  # Define behavior for Security Alerting
  defmodule SecurityAlertingBehaviour do
    @moduledoc """
    Behavior for Security Alerting implementations.
    """

    @callback send_alert(String.t(), map()) :: {:ok, String.t()} | {:error, term()}
  end

  # Define behavior for Performance Monitor
  defmodule PerformanceMonitorBehaviour do
    @moduledoc """
    Behavior for Performance Monitor implementations.
    """

    @callback track_response_time(String.t(), integer()) :: {:ok, String.t()} | {:error, term()}
    @callback check_performance() :: {:warning, map()} | {:ok, map()} | {:error, term()}
    @callback generate_report(String.t()) :: {:ok, map()} | {:error, term()}
  end

  # Define behavior for Performance Cache
  defmodule PerformanceCacheBehaviour do
    @moduledoc """
    Behavior for Performance Cache implementations.
    """

    @callback get(String.t()) :: {:ok, term()} | {:error, String.t()}
    @callback put(String.t(), term(), integer()) :: {:ok, String.t()} | {:error, term()}
    @callback delete(String.t()) :: {:ok, String.t()} | {:error, term()}
  end



  # Define implementation modules
  defmodule DefaultHTTPClient do
    @moduledoc """
    Default implementation of HTTP client behavior.

    This module provides a real implementation that would be used in production.
    """

    @behaviour HTTPClientBehaviour

    @impl true
    def get(_url, _headers \\ [], _opts \\ []) do
      # This would be a real HTTP request in production
      # We're providing a simple implementation for use with mocks
      {:ok, %{status: 200, body: "{}", headers: []}}
    end

    @impl true
    def post(_url, _body, _headers \\ [], _opts \\ []) do
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
      # Mocked resource with all expected fields for integration tests
      {:ok,
       %{
         "id" => id,
         "name" => "Test Resource",
         "description" => "A resource for testing.",
         "type" => "test-type",
         "status" => "active",
         "content" => "This is the test content.",
         "html_content" => "<b>Test HTML Content</b>"
       }}
    end

    @impl true
    def update_resource(id, data) do
      # Real implementation would call external API
      {:ok, Map.put(data, "id", id)}
    end

    @impl true
    def delete_resource(_id) do
      # Real implementation would call external API
      :ok
    end
  end

  # Default implementation for Security Logger
  defmodule DefaultSecurityLogger do
    @moduledoc """
    Default implementation of Security Logger behavior.
    """

    @behaviour SecurityLoggerBehaviour

    @impl true
    def log_security_event(event_type, details) do
      HydepwnsLiveview.Security.Logger.log_security_event(event_type, details)
    end
  end

  # Default implementation for Security Detector
  defmodule DefaultSecurityDetector do
    @moduledoc """
    Default implementation of Security Detector behavior.
    """

    @behaviour SecurityDetectorBehaviour

    @impl true
    def detect_suspicious_activity(activity) do
      HydepwnsLiveview.Security.Detector.detect_suspicious_activity(activity)
    end
  end

  # Default implementation for Security Alerting
  defmodule DefaultSecurityAlerting do
    @moduledoc """
    Default implementation of Security Alerting behavior.
    """

    @behaviour SecurityAlertingBehaviour

    @impl true
    def send_alert(alert_type, details) do
      HydepwnsLiveview.Security.Alerting.send_alert(alert_type, details)
    end
  end

  # Default implementation for Performance Monitor
  defmodule DefaultPerformanceMonitor do
    @moduledoc """
    Default implementation of Performance Monitor behavior.
    """

    @behaviour PerformanceMonitorBehaviour

    @impl true
    def track_response_time(endpoint, response_time) do
      HydepwnsLiveview.Performance.Monitor.track_response_time(endpoint, response_time)
    end

    @impl true
    def check_performance do
      HydepwnsLiveview.Performance.Monitor.check_performance()
    end

    @impl true
    def generate_report(time_range) do
      HydepwnsLiveview.Performance.Monitor.generate_report(time_range)
    end
  end

  # Default implementation for Performance Cache
  defmodule DefaultPerformanceCache do
    @moduledoc """
    Default implementation of Performance Cache behavior.
    """

    @behaviour PerformanceCacheBehaviour

    @impl true
    def get(key) do
      HydepwnsLiveview.Performance.Cache.get(key)
    end

    @impl true
    def put(key, data, ttl) do
      HydepwnsLiveview.Performance.Cache.put(key, data, ttl)
    end

    @impl true
    def delete(key) do
      HydepwnsLiveview.Performance.Cache.delete(key)
    end
  end
end

# Define mocks
Mox.defmock(HydepwnsLiveview.MockHTTPClient, for: HydepwnsLiveview.Mocks.HTTPClientBehaviour)
Mox.defmock(HydepwnsLiveview.MockExternalAPI, for: HydepwnsLiveview.Mocks.ExternalAPIBehaviour)
Mox.defmock(HydepwnsLiveview.Notifications.EmailAdapter, for: HydepwnsLiveview.Notifications.EmailAdapterBehaviour)
Mox.defmock(HydepwnsLiveview.Notifications.Twilio, for: HydepwnsLiveview.Notifications.TwilioBehaviour)
Mox.defmock(HydepwnsLiveview.Integration.WebhookAdapter, for: HydepwnsLiveview.Integration.WebhookAdapterBehaviour)
Mox.defmock(HydepwnsLiveview.Integration.ExternalSyncAdapter, for: HydepwnsLiveview.Integration.ExternalSyncAdapterBehaviour)
Mox.defmock(HydepwnsLiveview.Integration.ExternalServiceMonitor, for: HydepwnsLiveview.Integration.ExternalServiceMonitorBehaviour)
Mox.defmock(HydepwnsLiveview.Integration.ExternalServiceAuth, for: HydepwnsLiveview.Integration.ExternalServiceAuthBehaviour)
Mox.defmock(HydepwnsLiveview.Integration.CircuitBreaker, for: HydepwnsLiveview.Integration.CircuitBreakerBehaviour)
Mox.defmock(HydepwnsLiveview.Integration.AnalyticsAdapter, for: HydepwnsLiveview.Integration.AnalyticsAdapterBehaviour)
Mox.defmock(HydepwnsLiveview.Events.Adapters.PushAdapter, for: HydepwnsLiveview.Events.Adapters.PushAdapterBehaviour)
Mox.defmock(HydepwnsLiveview.MockSecurityLogger, for: HydepwnsLiveview.Mocks.SecurityLoggerBehaviour)
Mox.defmock(HydepwnsLiveview.MockSecurityDetector, for: HydepwnsLiveview.Mocks.SecurityDetectorBehaviour)
Mox.defmock(HydepwnsLiveview.MockSecurityAlerting, for: HydepwnsLiveview.Mocks.SecurityAlertingBehaviour)
Mox.defmock(HydepwnsLiveview.MockPerformanceMonitor, for: HydepwnsLiveview.Mocks.PerformanceMonitorBehaviour)
Mox.defmock(HydepwnsLiveview.MockPerformanceCache, for: HydepwnsLiveview.Mocks.PerformanceCacheBehaviour)

defmodule HydepwnsLiveview.DefaultHTTPClient do
  @moduledoc false
  @behaviour HydepwnsLiveview.Mocks.HTTPClientBehaviour

  defdelegate get(url, headers \\ [], opts \\ []), to: HydepwnsLiveview.Mocks.DefaultHTTPClient

  defdelegate post(url, body, headers \\ [], opts \\ []),
    to: HydepwnsLiveview.Mocks.DefaultHTTPClient
end

defmodule HydepwnsLiveview.DefaultExternalAPI do
  @moduledoc false
  @behaviour HydepwnsLiveview.Mocks.ExternalAPIBehaviour

  defdelegate fetch_data(id), to: HydepwnsLiveview.Mocks.DefaultExternalAPI
  defdelegate update_resource(id, data), to: HydepwnsLiveview.Mocks.DefaultExternalAPI
  defdelegate delete_resource(id), to: HydepwnsLiveview.Mocks.DefaultExternalAPI
end

defmodule HydepwnsLiveview.DefaultSecurityLogger do
  @moduledoc false
  @behaviour HydepwnsLiveview.Mocks.SecurityLoggerBehaviour

  defdelegate log_security_event(event_type, details), to: HydepwnsLiveview.Mocks.DefaultSecurityLogger
end

defmodule HydepwnsLiveview.DefaultSecurityDetector do
  @moduledoc false
  @behaviour HydepwnsLiveview.Mocks.SecurityDetectorBehaviour

  defdelegate detect_suspicious_activity(activity), to: HydepwnsLiveview.Mocks.DefaultSecurityDetector
end

defmodule HydepwnsLiveview.DefaultSecurityAlerting do
  @moduledoc false
  @behaviour HydepwnsLiveview.Mocks.SecurityAlertingBehaviour

  defdelegate send_alert(alert_type, details), to: HydepwnsLiveview.Mocks.DefaultSecurityAlerting
end

defmodule HydepwnsLiveview.DefaultPerformanceMonitor do
  @moduledoc false
  @behaviour HydepwnsLiveview.Mocks.PerformanceMonitorBehaviour

  defdelegate track_response_time(endpoint, response_time), to: HydepwnsLiveview.Mocks.DefaultPerformanceMonitor
  defdelegate check_performance(), to: HydepwnsLiveview.Mocks.DefaultPerformanceMonitor
  defdelegate generate_report(time_range), to: HydepwnsLiveview.Mocks.DefaultPerformanceMonitor
end

defmodule HydepwnsLiveview.DefaultPerformanceCache do
  @moduledoc false
  @behaviour HydepwnsLiveview.Mocks.PerformanceCacheBehaviour

  defdelegate get(key), to: HydepwnsLiveview.Mocks.DefaultPerformanceCache
  defdelegate put(key, data, ttl), to: HydepwnsLiveview.Mocks.DefaultPerformanceCache
  defdelegate delete(key), to: HydepwnsLiveview.Mocks.DefaultPerformanceCache
end
