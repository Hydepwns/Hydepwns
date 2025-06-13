defmodule HydepwnsLiveview.Events.Core.EventMonitor do
  @moduledoc """
  Monitors performance of the event system.

  This module provides comprehensive monitoring for event processing,
  including:
  - Metrics collection for event processing times
  - Backpressure detection in the event processing pipeline
  - Bottleneck identification in event handlers
  - Alerting for event processing issues
  - Visualization of event processing performance
  """

  require Logger
  use GenServer

  alias HydepwnsLiveview.Events.Core.EventStore
  alias HydepwnsLiveview.Events.Core.Event
  alias HydepwnsLiveview.Events.Core.NotificationSystem
  alias HydepwnsLiveview.Telemetry

  # Define thresholds for backpressure detection
  # Number of events in queue considered high
  @queue_high_threshold 1000
  # Processing time in ms considered slow
  @processing_time_threshold 500
  # 5% error rate is considered high
  @error_rate_threshold 0.05
  # Default alert check interval (1 minute)
  @default_alert_interval 60_000
  # Default metric collection interval (15 seconds)
  @default_metric_interval 15_000

  ##############################################################################
  # Client API
  ##############################################################################

  @doc """
  Starts the EventMonitor process.
  """
  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Gets current event processing metrics.

  ## Parameters
  * `opts` - Options for metrics retrieval

  ## Returns
  * `{:ok, metrics}` - The current metrics
  * `{:error, reason}` - Failed to get metrics
  """
  @spec get_metrics(Keyword.t()) :: {:ok, map()} | {:error, any()}
  def get_metrics(opts \\ []) do
    GenServer.call(__MODULE__, {:get_metrics, opts})
  end

  @doc """
  Detects backpressure in the event processing system.

  Backpressure is identified by analyzing queue sizes, processing
  times, error rates, and throughput metrics.

  ## Parameters
  * `queue_sizes` - Map of handler -> queue size
  * `processing_metrics` - Processing metrics by event type
  * `error_rates` - Error rates by event type

  ## Returns
  * Map with backpressure information
  """
  @spec detect_backpressure(%{any() => integer()}, %{any() => map()}, %{any() => float()}) ::
          map()
  def detect_backpressure(queue_sizes, processing_metrics, error_rates) do
    # Check if any queue sizes are above threshold
    queue_pressure =
      queue_sizes
      |> Enum.any?(fn {_handler, size} -> size > @queue_high_threshold end)

    # Check if any event types have slow processing
    slow_types =
      processing_metrics
      |> Enum.filter(fn {_type, metrics} ->
        metrics.avg_time > @processing_time_threshold
      end)
      |> Enum.map(fn {type, _metrics} -> type end)

    # Check for high error rates
    high_error_types =
      error_rates
      |> Enum.filter(fn {_type, rate} -> rate > @error_rate_threshold end)
      |> Enum.map(fn {type, _rate} -> type end)

    # Determine overall backpressure status
    status =
      cond do
        queue_pressure && (length(slow_types) > 0 || length(high_error_types) > 0) -> :critical
        queue_pressure || length(slow_types) > 0 || length(high_error_types) > 0 -> :warning
        true -> :normal
      end

    backpressure_data = %{
      status: status,
      queue_pressure: queue_pressure,
      slow_processing_types: slow_types,
      high_error_types: high_error_types,
      bottlenecks: identify_bottlenecks(queue_sizes, processing_metrics, error_rates)
    }

    # Emit telemetry for backpressure detection
    Telemetry.execute(
      [:hydepwns_liveview, :events, :backpressure],
      %{
        value: if(status == :normal, do: 0, else: if(status == :warning, do: 1, else: 2))
      },
      %{
        status: status,
        queue_pressure: queue_pressure,
        slow_types_count: length(slow_types),
        high_error_types_count: length(high_error_types)
      }
    )

    backpressure_data
  end

  @doc """
  Sets up alerting for event processing issues.

  ## Parameters
  * `notification_function` - Function to call when alert is triggered (for backward compatibility)
  * `opts` - Options for alerting:
    * `:interval_ms` - Alert check interval in milliseconds
    * `:lookback_seconds` - How far back to look for metrics
    * `:threshold_overrides` - Map of thresholds to override
    * `:notification_channels` - List of channels to notify (defaults to [:in_app, :log])
    * `:recipients` - Who should receive notifications (defaults to :admins_only)

  ## Returns
  * `:ok` - Alerting set up successfully
  """
  @spec setup_alerting((map() -> any()) | nil, Keyword.t()) :: :ok
  def setup_alerting(notification_function \\ nil, opts \\ [])
      when is_nil(notification_function) or is_function(notification_function, 1) do
    GenServer.cast(__MODULE__, {:setup_alerting, notification_function, opts})
  end

  @doc """
  Clears all alert notifications.

  ## Returns
  * `:ok` - Alerting cleared successfully
  """
  @spec clear_alerting() :: :ok
  def clear_alerting do
    GenServer.cast(__MODULE__, :clear_alerting)
  end

  @doc """
  Records an event processing metric.

  ## Parameters
  * `event` - The event that was processed
  * `metrics` - Metrics about the processing:
    * `:duration_ms` - How long it took to process
    * `:handler` - Which handler processed it
    * `:status` - :success or :error
    * `:details` - Additional details (optional)

  ## Returns
  * `:ok` - Metric recorded successfully
  """
  @spec record_processing_metric(Event.t(), map()) :: :ok
  def record_processing_metric(%Event{} = event, metrics) do
    # Extract required fields with defaults
    duration_ms = Map.get(metrics, :duration_ms, 0)
    handler = Map.get(metrics, :handler, :unknown)
    status = Map.get(metrics, :status, :success)
    details = Map.get(metrics, :details, %{})

    # Emit telemetry event for this processing
    Telemetry.execute(
      [:hydepwns_liveview, :events, :process],
      %{duration: duration_ms},
      %{
        event_id: event.id,
        event_type: event.type,
        handler: handler,
        status: status,
        timestamp: DateTime.utc_now(),
        details: details
      }
    )

    GenServer.cast(__MODULE__, {:record_metric, event, metrics})
  end

  @doc """
  Checks for issues and triggers alerts if needed.
  """
  @spec check_and_alert() :: :ok
  def check_and_alert do
    GenServer.cast(__MODULE__, :check_and_alert)
  end

  @doc """
  Records the current queue size for a handler.

  ## Parameters
  * `handler_name` - Name of the handler
  * `queue_size` - Current queue size

  ## Returns
  * `:ok` - Queue size recorded
  """
  @spec record_queue_size(any(), integer()) :: :ok
  def record_queue_size(handler_name, queue_size) do
    # Emit telemetry event for queue size
    Telemetry.execute(
      [:hydepwns_liveview, :events, :queue_size],
      %{size: queue_size},
      %{
        handler: handler_name,
        timestamp: DateTime.utc_now()
      }
    )

    GenServer.cast(__MODULE__, {:record_queue_size, handler_name, queue_size})
  end

  ##############################################################################
  # GenServer callbacks
  ##############################################################################

  @impl true
  def init(opts) do
    # Initialize state with empty metrics
    state = %{
      # Processing metrics by event type
      metrics_by_type: %{},
      # Error rates by event type
      error_rates: %{},
      # Queue sizes by handler
      queue_sizes: %{},
      # Alert configuration
      alert_config: %{
        enabled: false,
        notification_fn: nil,
        notification_channels: [:in_app, :log],
        recipients: :admins_only,
        interval_ms: @default_alert_interval,
        lookback_seconds: 300,
        last_alert_time: nil,
        thresholds: %{
          queue_high: @queue_high_threshold,
          processing_time: @processing_time_threshold,
          error_rate: @error_rate_threshold
        }
      },
      # Historical metrics
      history: %{
        metrics: [],
        max_size: 1000
      },
      # Metric collection interval
      metric_interval: Keyword.get(opts, :metric_interval, @default_metric_interval)
    }

    # Schedule periodic metrics collection
    schedule_metrics_collection(state.metric_interval)

    # Register with telemetry
    register_telemetry_handlers()

    {:ok, state}
  end

  @impl true
  def handle_call({:get_metrics, opts}, _from, state) do
    # Default to 1 hour lookback
    lookback_seconds = Keyword.get(opts, :lookback_seconds, 3600)
    start_time = DateTime.add(DateTime.utc_now(), -lookback_seconds, :second)

    # Get events in the time period
    with {:ok, events} <-
           EventStore.get_events(%{
             timestamp: %{after: start_time},
             sort: [timestamp: :asc]
           }) do
      # Calculate processing times by event type
      processing_metrics = calculate_processing_metrics(events, state)

      # Get current queue sizes from state
      queue_sizes = state.queue_sizes

      # Get error rates
      error_rates = calculate_error_rates(events, state)

      # Check for backpressure
      backpressure = detect_backpressure(queue_sizes, processing_metrics, error_rates)

      metrics = %{
        event_count: length(events),
        events_per_second: length(events) / lookback_seconds,
        processing_metrics: processing_metrics,
        queue_sizes: queue_sizes,
        error_rates: error_rates,
        backpressure: backpressure,
        timestamp: DateTime.utc_now(),
        lookback_period_seconds: lookback_seconds
      }

      {:reply, {:ok, metrics}, state}
    else
      error -> {:reply, error, state}
    end
  end

  @impl true
  def handle_cast({:record_metric, event, metrics}, state) do
    # Extract metrics
    duration_ms = Map.get(metrics, :duration_ms, 0)
    status = Map.get(metrics, :status, :success)

    # Update metrics for this event type
    metrics_by_type =
      Map.update(
        state.metrics_by_type,
        event.type,
        %{
          count: 1,
          total_time: duration_ms,
          errors: if(status == :error, do: 1, else: 0),
          avg_time: duration_ms,
          min_time: duration_ms,
          max_time: duration_ms
        },
        fn existing ->
          %{
            count: existing.count + 1,
            total_time: existing.total_time + duration_ms,
            errors: existing.errors + if(status == :error, do: 1, else: 0),
            avg_time: (existing.total_time + duration_ms) / (existing.count + 1),
            min_time: min(existing.min_time, duration_ms),
            max_time: max(existing.max_time, duration_ms)
          }
        end
      )

    # Update error rates
    error_rates =
      Map.update(
        state.error_rates,
        event.type,
        if(status == :error, do: 1.0, else: 0.0),
        fn _rate ->
          # Exponential moving average for smoother error rate
          metrics_for_type = metrics_by_type[event.type]
          metrics_for_type.errors / metrics_for_type.count
        end
      )

    # Add to history
    history =
      add_to_history(state.history, %{
        timestamp: DateTime.utc_now(),
        event_type: event.type,
        duration_ms: duration_ms,
        status: status
      })

    {:noreply,
     %{state | metrics_by_type: metrics_by_type, error_rates: error_rates, history: history}}
  end

  @impl true
  def handle_cast({:record_queue_size, handler_name, queue_size}, state) do
    # Update queue sizes
    queue_sizes = Map.put(state.queue_sizes, handler_name, queue_size)

    {:noreply, %{state | queue_sizes: queue_sizes}}
  end

  @impl true
  def handle_cast({:setup_alerting, notification_fn, opts}, state) do
    # Update alert configuration
    alert_config = %{
      enabled: true,
      notification_fn: notification_fn,
      notification_channels: Keyword.get(opts, :notification_channels, [:in_app, :log]),
      recipients: Keyword.get(opts, :recipients, :admins_only),
      interval_ms: Keyword.get(opts, :interval_ms, @default_alert_interval),
      lookback_seconds: Keyword.get(opts, :lookback_seconds, 300),
      last_alert_time: nil,
      thresholds:
        Map.merge(
          state.alert_config.thresholds,
          Keyword.get(opts, :threshold_overrides, %{})
        )
    }

    # Schedule first alert check
    schedule_alert_check(alert_config.interval_ms)

    {:noreply, %{state | alert_config: alert_config}}
  end

  @impl true
  def handle_cast(:clear_alerting, state) do
    # Disable alerting
    alert_config = %{state.alert_config | enabled: false, notification_fn: nil}

    {:noreply, %{state | alert_config: alert_config}}
  end

  @impl true
  def handle_cast(:check_and_alert, state) do
    # Skip if alerting is not enabled
    state =
      if state.alert_config.enabled do
        check_metrics_and_alert(state)
      else
        state
      end

    # Schedule next alert check if still enabled
    if state.alert_config.enabled do
      schedule_alert_check(state.alert_config.interval_ms)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:collect_metrics, state) do
    # This is triggered by the timer to collect metrics periodically
    # Collect current metrics
    {:ok, metrics} = do_get_metrics(state.alert_config.lookback_seconds, state)

    # Emit telemetry for current metrics
    Telemetry.execute(
      [:hydepwns_liveview, :events, :metrics],
      %{
        event_count: metrics.event_count,
        events_per_second: metrics.events_per_second
      },
      %{
        backpressure_status: metrics.backpressure.status,
        queue_sizes: metrics.queue_sizes,
        error_rates: metrics.error_rates,
        timestamp: metrics.timestamp
      }
    )

    # Schedule next collection
    schedule_metrics_collection(state.metric_interval)

    {:noreply, state}
  end

  ##############################################################################
  # Helper functions
  ##############################################################################

  # Calculate processing metrics from events
  defp calculate_processing_metrics(_events, state) do
    # Use metrics from state, supplemented with any missing event types from events
    state.metrics_by_type
  end

  # Calculate error rates from events and state
  defp calculate_error_rates(_events, state) do
    # Use error rates from state
    state.error_rates
  end

  # Add a metric to the history
  defp add_to_history(history, metric) do
    # Add new metric to history
    updated_metrics = [metric | history.metrics]

    # Trim if necessary
    trimmed_metrics =
      if length(updated_metrics) > history.max_size do
        Enum.take(updated_metrics, history.max_size)
      else
        updated_metrics
      end

    %{history | metrics: trimmed_metrics}
  end

  # Schedule periodic metrics collection
  defp schedule_metrics_collection(interval) do
    Process.send_after(self(), :collect_metrics, interval)
  end

  # Schedule alert check
  defp schedule_alert_check(interval) do
    Process.send_after(self(), :check_and_alert, interval)
  end

  # Check metrics and send alert if needed
  defp check_metrics_and_alert(state) do
    # Get current metrics
    {:ok, metrics} = do_get_metrics(state.alert_config.lookback_seconds, state)

    # Check if we need to alert
    if metrics.backpressure.status != :normal do
      # Send alert if we haven't alerted recently
      now = DateTime.utc_now()

      if state.alert_config.last_alert_time == nil ||
           DateTime.diff(now, state.alert_config.last_alert_time, :second) >= 300 do
        # Create alert data
        alert = %{
          type: :event_system_backpressure,
          level: metrics.backpressure.status,
          message: "Event system experiencing backpressure",
          details: metrics,
          timestamp: now
        }

        # Use the NotificationSystem for new alerts
        NotificationSystem.send_alert(alert,
          channels: state.alert_config.notification_channels,
          recipients: state.alert_config.recipients
        )

        # For backward compatibility, still call the notification function if provided
        if state.alert_config.notification_fn != nil do
          state.alert_config.notification_fn.(alert)
        end

        # Update last alert time
        %{state | alert_config: %{state.alert_config | last_alert_time: now}}
      else
        state
      end
    else
      state
    end
  end

  # Get metrics without going through GenServer.call
  defp do_get_metrics(lookback_seconds, state) do
    start_time = DateTime.add(DateTime.utc_now(), -lookback_seconds, :second)

    # Get events in the time period
    with {:ok, events} <-
           EventStore.get_events(%{
             timestamp: %{after: start_time},
             sort: [timestamp: :asc]
           }) do
      # Calculate processing times by event type
      processing_metrics = calculate_processing_metrics(events, state)

      # Get current queue sizes from state
      queue_sizes = state.queue_sizes

      # Get error rates
      error_rates = calculate_error_rates(events, state)

      # Check for backpressure
      backpressure = detect_backpressure(queue_sizes, processing_metrics, error_rates)

      metrics = %{
        event_count: length(events),
        events_per_second: length(events) / lookback_seconds,
        processing_metrics: processing_metrics,
        queue_sizes: queue_sizes,
        error_rates: error_rates,
        backpressure: backpressure,
        timestamp: DateTime.utc_now(),
        lookback_period_seconds: lookback_seconds
      }

      {:ok, metrics}
    end
  end

  # Identify bottlenecks in the event processing system
  defp identify_bottlenecks(queue_sizes, processing_metrics, error_rates) do
    # Implementation for identifying bottlenecks in the event system
    %{
      high_queue_handlers:
        queue_sizes
        |> Enum.filter(fn {_handler, size} -> size > @queue_high_threshold end)
        |> Enum.map(fn {handler, _} -> handler end),
      slow_event_types:
        processing_metrics
        |> Enum.filter(fn {_type, metrics} -> metrics.avg_time > @processing_time_threshold end)
        |> Enum.map(fn {type, _} -> type end),
      high_error_types:
        error_rates
        |> Enum.filter(fn {_type, rate} -> rate > @error_rate_threshold end)
        |> Enum.map(fn {type, _} -> type end)
    }
  end

  # Register telemetry handlers
  defp register_telemetry_handlers do
    # Implementation for registering telemetry handlers
    # This is a placeholder for actual telemetry registration
    :ok
  end
end
