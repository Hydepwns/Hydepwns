defmodule HydepwnsLiveview.Resources.PerformanceOptimizer do
  @moduledoc """
  Optimizes performance of the resource system.

  This module provides tools to improve the performance of resource operations, including:
  - Performance measurement and profiling for resource operations
  - Multi-level caching system for resources
  - Optimized query patterns for resource retrieval
  - Resource loading strategies for different performance profiles
  - Benchmarking tools for measuring performance improvements
  """

  require Logger
  alias HydepwnsLiveview.Repo
  alias HydepwnsLiveview.Events.EventStore
  alias HydepwnsLiveview.Telemetry

  # ETS table name for resource cache
  @resource_cache_table :resource_cache

  # Default cache options
  @default_cache_opts %{
    # 5 minutes
    ttl_seconds: 300,
    # Maximum items in cache
    max_size: 1000,
    # Events that should invalidate cache
    invalidation_events: []
  }

  @doc """
  Initializes the resource performance optimization system.

  This should be called during application startup.

  ## Returns
  * `:ok` - System was initialized successfully
  """
  def init do
    # Start the cache server
    {:ok, _pid} = HydepwnsLiveview.Resources.CacheServer.start_link()

    # Register telemetry handlers
    register_telemetry_handlers()

    :ok
  end

  @doc """
  Measures performance of resource operations.

  ## Parameters
  * `operation` - The operation to measure
  * `args` - Arguments for the operation
  * `opts` - Measurement options

  ## Returns
  * `{result, metrics}` - Operation result and performance metrics
  """
  def measure(operation, args, opts \\ []) when is_function(operation, length(args)) do
    # Prepare telemetry context
    context = %{
      operation: opts[:name] || "resource_operation",
      args: args
    }

    # Start measurements
    start_time = System.monotonic_time(:millisecond)
    memory_before = :erlang.memory(:total)

    # Emit start event
    :telemetry.execute([:hydepwns_liveview, :resources, :operation, :start], %{}, context)

    # Execute the operation
    result =
      try do
        apply(operation, args)
      rescue
        e ->
          # Emit exception event
          :telemetry.execute(
            [:hydepwns_liveview, :resources, :operation, :exception],
            %{},
            Map.merge(context, %{error: e, stacktrace: __STACKTRACE__})
          )

          reraise e, __STACKTRACE__
      end

    # Complete measurements
    end_time = System.monotonic_time(:millisecond)
    memory_after = :erlang.memory(:total)

    # Calculate metrics
    metrics = %{
      execution_time_ms: end_time - start_time,
      memory_delta_bytes: memory_after - memory_before
    }

    # Emit stop event
    :telemetry.execute(
      [:hydepwns_liveview, :resources, :operation, :stop],
      metrics,
      Map.merge(context, %{result: result})
    )

    # Return the result and metrics
    {result, metrics}
  end

  @doc """
  Implements a multi-level caching system for resources.

  This function tries to retrieve a resource from a cache hierarchy:
  1. Process dictionary (fastest, but process-specific)
  2. ETS cache (fast, shared across processes)
  3. Original data source (slowest, but always up-to-date)

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource
  * `fetch_fn` - Function to fetch the resource if not in cache
  * `opts` - Caching options

  ## Returns
  * `{:ok, resource}` - Resource retrieved
  * `{:error, reason}` - Failed to retrieve resource
  """
  def cached_resource(resource_type, resource_id, fetch_fn, opts \\ []) do
    # Try process dictionary first (fastest)
    case Process.get({:resource_cache, resource_type, resource_id}) do
      {resource, expiry} ->
        if DateTime.compare(expiry, DateTime.utc_now()) == :gt do
          # Process cache is valid
          {:ok, resource}
        else
          # Process cache expired, try cache server
          try_cache_server(resource_type, resource_id, fetch_fn, opts)
        end

      nil ->
        # Not in process dictionary, try cache server
        try_cache_server(resource_type, resource_id, fetch_fn, opts)
    end
  end

  @doc """
  Invalidates cache entries for a resource.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource

  ## Returns
  * `:ok` - Cache was invalidated
  """
  def invalidate_cache(resource_type, resource_id) do
    # Remove from process dictionary
    Process.delete({:resource_cache, resource_type, resource_id})

    # Invalidate in cache server
    HydepwnsLiveview.Resources.CacheServer.invalidate(resource_type, resource_id)

    :ok
  end

  @doc """
  Bulk loads resources with optimized query patterns.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_ids` - List of resource IDs to load
  * `loader_fn` - Function to load resources
  * `opts` - Options for bulk loading

  ## Returns
  * `{:ok, resources}` - Map of resource_id -> resource
  * `{:error, reason}` - Failed to load resources
  """
  def bulk_load_resources(resource_type, resource_ids, loader_fn, opts \\ []) do
    # Filter out IDs that are already in cache
    {cached, uncached} = split_cached_uncached(resource_type, resource_ids)

    # Load uncached resources
    uncached_resources =
      if uncached != [] do
        {result, _metrics} = measure(loader_fn, [uncached], name: "bulk_load_#{resource_type}")

        case result do
          {:ok, resources} ->
            # Cache the loaded resources
            cache_resources(resource_type, resources, opts)
            resources

          {:error, reason} ->
            Logger.error("Failed to bulk load #{resource_type} resources: #{inspect(reason)}")
            %{}
        end
      else
        %{}
      end

    # Combine cached and newly loaded resources
    resources = Map.merge(cached, uncached_resources)

    {:ok, resources}
  end

  @doc """
  Creates an optimized loading strategy based on client capabilities.

  ## Parameters
  * `client_info` - Information about the client
  * `resource_type` - The type of resource
  * `opts` - Additional options

  ## Returns
  * Loading strategy for the client
  """
  def optimized_loading_strategy(client_info, resource_type, _opts \\ []) do
    # Determine device capabilities
    is_mobile = client_info.user_agent =~ ~r/(Android|iPhone|iPad|iPod)/
    connection_type = client_info.connection_type || :unknown

    # Create loading strategy based on device
    cond do
      is_mobile and connection_type in [:slow_3g, :cellular] ->
        %{
          initial_fields: essential_fields(resource_type),
          batch_size: 5,
          lazy_relationships: true,
          prefetch: false,
          # Longer cache for slow connections
          cache_ttl_seconds: 600,
          compression: true,
          image_quality: :low
        }

      is_mobile ->
        %{
          initial_fields: essential_fields(resource_type) ++ secondary_fields(resource_type),
          batch_size: 10,
          lazy_relationships: true,
          prefetch: limited_prefetch(resource_type),
          cache_ttl_seconds: 300,
          compression: true,
          image_quality: :medium
        }

      connection_type == :slow ->
        %{
          initial_fields: essential_fields(resource_type) ++ secondary_fields(resource_type),
          batch_size: 15,
          lazy_relationships: true,
          prefetch: limited_prefetch(resource_type),
          cache_ttl_seconds: 300,
          compression: false,
          image_quality: :medium
        }

      true ->
        %{
          initial_fields: :all,
          batch_size: 25,
          lazy_relationships: false,
          prefetch: full_prefetch(resource_type),
          # Shorter cache for fast connections
          cache_ttl_seconds: 120,
          compression: false,
          image_quality: :high
        }
    end
  end

  @doc """
  Benchmarks a resource operation with different strategies.

  ## Parameters
  * `operation_fn` - The operation to benchmark
  * `strategies` - List of strategies to benchmark
  * `iterations` - Number of iterations for each strategy

  ## Returns
  * `{:ok, results}` - Benchmark results
  * `{:error, reason}` - Failed to benchmark
  """
  def benchmark(operation_fn, strategies, iterations \\ 10) do
    # Run each strategy and collect metrics
    results =
      Enum.map(strategies, fn {strategy_name, strategy_opts} ->
        # Run multiple iterations
        iteration_results =
          Enum.map(1..iterations, fn i ->
            # Apply strategy to operation
            {result, metrics} =
              measure(
                fn -> operation_fn.(strategy_opts) end,
                [],
                name: "benchmark_#{strategy_name}_iteration_#{i}"
              )

            {result, metrics}
          end)

        # Calculate aggregate metrics
        successful = Enum.count(iteration_results, fn {result, _} -> match?({:ok, _}, result) end)

        # Extract time metrics
        times = Enum.map(iteration_results, fn {_, metrics} -> metrics.execution_time_ms end)
        avg_time = Enum.sum(times) / length(times)

        # Extract memory metrics
        memory_deltas =
          Enum.map(iteration_results, fn {_, metrics} -> metrics.memory_delta_bytes end)

        avg_memory = Enum.sum(memory_deltas) / length(memory_deltas)

        # Return strategy results
        {strategy_name,
         %{
           success_rate: successful / iterations,
           avg_execution_time_ms: avg_time,
           min_execution_time_ms: Enum.min(times),
           max_execution_time_ms: Enum.max(times),
           avg_memory_delta_bytes: avg_memory,
           iterations: iterations
         }}
      end)
      |> Enum.into(%{})

    {:ok, results}
  end

  @doc """
  Stores performance metrics in a time-series database.

  ## Parameters
  * `metrics` - The metrics to store
  * `opts` - Storage options

  ## Returns
  * `:ok` - Metrics stored successfully
  * `{:error, reason}` - Failed to store metrics
  """
  def store_metrics(metrics, opts \\ []) do
    # Get storage backend from config
    backend = Application.get_env(:hydepwns_liveview, :metrics_backend, :influxdb)

    case backend do
      :influxdb ->
        store_metrics_influxdb(metrics, opts)

      :prometheus ->
        store_metrics_prometheus(metrics, opts)

      _ ->
        {:error, "Unsupported metrics backend: #{inspect(backend)}"}
    end
  end

  @doc """
  Analyzes performance patterns and suggests optimizations.

  ## Parameters
  * `resource_type` - The resource type to analyze
  * `period` - Time period for analysis in seconds

  ## Returns
  * `{:ok, suggestions}` - List of optimization suggestions
  * `{:error, reason}` - Failed to analyze performance
  """
  def analyze_performance_patterns(resource_type, period \\ 3600) do
    with {:ok, metrics} <- gather_event_metrics(resource_type, period) do
      suggestions = []

      # Analyze read/write patterns
      read_write_ratio = metrics.read_count / max(metrics.write_count, 1)

      suggestions =
        if read_write_ratio > 10 do
          [
            %{
              type: :cache_optimization,
              description: "High read/write ratio suggests increasing cache TTL",
              impact: :high,
              priority: :high
            }
            | suggestions
          ]
        else
          suggestions
        end

      # Analyze event frequency
      events_per_second = metrics.total_events / period

      suggestions =
        if events_per_second > 100 do
          [
            %{
              type: :batch_processing,
              description: "High event frequency suggests implementing batch processing",
              impact: :high,
              priority: :high
            }
            | suggestions
          ]
        else
          suggestions
        end

      # Analyze resource size
      suggestions =
        if metrics.avg_event_size > 1024 do
          [
            %{
              type: :compression,
              description: "Large event size suggests implementing compression",
              impact: :medium,
              priority: :medium
            }
            | suggestions
          ]
        else
          suggestions
        end

      {:ok, suggestions}
    end
  end

  @doc """
  Sets up performance monitoring alerts.

  ## Parameters
  * `resource_type` - The resource type to monitor
  * `thresholds` - Alert thresholds

  ## Returns
  * `:ok` - Alerts configured successfully
  * `{:error, reason}` - Failed to configure alerts
  """
  def setup_performance_alerts(resource_type, thresholds \\ %{}) do
    # Default thresholds
    default_thresholds = %{
      response_time_ms: 1000,
      error_rate: 0.01,
      cache_hit_rate: 0.8,
      memory_usage_mb: 100
    }

    # Merge with provided thresholds
    thresholds = Map.merge(default_thresholds, thresholds)

    # Store thresholds in ETS
    :ets.insert(@resource_cache_table, {:alert_thresholds, resource_type, thresholds})

    # Start monitoring process
    start_performance_monitoring(resource_type)

    :ok
  end

  # Private helper functions

  defp try_cache_server(resource_type, resource_id, fetch_fn, opts) do
    # Try to get from cache server
    case HydepwnsLiveview.Resources.CacheServer.get(resource_type, resource_id, fetch_fn) do
      {:ok, resource} ->
        # Update process cache
        expiry = DateTime.add(DateTime.utc_now(), Keyword.get(opts, :ttl_seconds, 300), :second)
        Process.put({:resource_cache, resource_type, resource_id}, {resource, expiry})

        {:ok, resource}

      {:error, _} = error ->
        error
    end
  end

  defp split_cached_uncached(resource_type, resource_ids) do
    # Prepare result accumulators
    cached = %{}
    uncached = []

    # Check each ID
    Enum.reduce(resource_ids, {cached, uncached}, fn id, {cached_acc, uncached_acc} ->
      cache_key = "#{resource_type}:#{id}"

      # Check if it's in the cache
      case :ets.lookup(@resource_cache_table, cache_key) do
        [{^cache_key, resource, expiry}] ->
          if DateTime.compare(expiry, DateTime.utc_now()) == :gt do
            # It's cached, add to cached accumulator
            {Map.put(cached_acc, id, resource), uncached_acc}
          else
            # It's expired, add to uncached accumulator
            {cached_acc, [id | uncached_acc]}
          end

        [] ->
          # Not cached, add to uncached accumulator
          {cached_acc, [id | uncached_acc]}
      end
    end)
  end

  defp cache_resources(resource_type, resources, opts) do
    # Get cache options
    cache_opts =
      Map.merge(
        @default_cache_opts,
        Map.new(Keyword.take(opts, [:ttl_seconds, :max_size, :invalidation_events]))
      )

    # Cache each resource
    Enum.each(resources, fn {id, resource} ->
      # Cache in process dictionary
      expiry = DateTime.add(DateTime.utc_now(), cache_opts.ttl_seconds, :second)
      Process.put({:resource_cache, resource_type, id}, {resource, expiry})

      # Cache in cache server
      HydepwnsLiveview.Resources.CacheServer.put(resource_type, id, resource, opts)
    end)
  end

  defp register_telemetry_handlers do
    :telemetry.attach(
      "resource-performance-handler",
      [:hydepwns_liveview, :resources, :operation, :stop],
      &handle_resource_operation_telemetry/4,
      nil
    )
  end

  defp handle_resource_operation_telemetry(
         [:hydepwns_liveview, :resources, :operation, :stop],
         measurements,
         metadata,
         _config
       ) do
    # Record operation metrics
    Logger.debug("Resource operation telemetry: #{inspect(measurements)}, #{inspect(metadata)}")

    # In a real implementation, you would store these metrics
    # in a time-series database or other metrics store
  end

  # Resource-specific field definitions

  defp essential_fields(:user), do: [:id, :name, :avatar_url]
  defp essential_fields(:post), do: [:id, :title, :summary, :author_id]
  defp essential_fields(:team), do: [:id, :name, :slug]
  defp essential_fields(_), do: [:id, :name]

  defp secondary_fields(:user), do: [:email, :bio, :role]
  defp secondary_fields(:post), do: [:content, :published_at, :tags]
  defp secondary_fields(:team), do: [:description, :member_count]
  defp secondary_fields(_), do: []

  defp limited_prefetch(:user), do: [:teams]
  defp limited_prefetch(:post), do: [:author]
  defp limited_prefetch(:team), do: [:owner]
  defp limited_prefetch(_), do: []

  defp full_prefetch(:user), do: [:teams, :posts, :followers]
  defp full_prefetch(:post), do: [:author, :comments, :likes]
  defp full_prefetch(:team), do: [:owner, :members, :projects]
  defp full_prefetch(_), do: []

  # Private functions for metrics storage

  defp store_metrics_influxdb(metrics, _opts) do
    # In a real implementation, this would store metrics in InfluxDB
    # For now, we'll just log them
    Logger.info("Storing metrics in InfluxDB: #{inspect(metrics)}")
    :ok
  end

  defp store_metrics_prometheus(metrics, _opts) do
    # In a real implementation, this would store metrics in Prometheus
    # For now, we'll just log them
    Logger.info("Storing metrics in Prometheus: #{inspect(metrics)}")
    :ok
  end

  # Private functions for performance monitoring

  defp start_performance_monitoring(resource_type) do
    # Start a process to monitor performance
    Task.start(fn ->
      # Wait 1 minute before first check
      :timer.sleep(60_000)
      monitor_performance_loop(resource_type)
    end)
  end

  defp monitor_performance_loop(resource_type) do
    with {:ok, metrics} <- gather_event_metrics(resource_type, 60) do
      # Process metrics and store them
      store_metrics(metrics)
    end

    # Schedule next check
    Process.send_after(self(), {:monitor_performance, resource_type}, @monitoring_interval)
  end

  defp gather_event_metrics(resource_type, time_window) do
    try do
      # Get metrics from ETS table
      metrics =
        :ets.select(@metrics_table, [
          {{resource_type, :"$1", :"$2"}, [], [{{:"$1", :"$2"}}]}
        ])

      # Filter metrics within time window
      cutoff = DateTime.add(DateTime.utc_now(), -time_window, :second)

      filtered_metrics =
        Enum.filter(metrics, fn {timestamp, _} ->
          DateTime.compare(timestamp, cutoff) == :gt
        end)

      {:ok, filtered_metrics}
    catch
      _type, error ->
        {:error, "Failed to gather metrics: #{inspect(error)}"}
    end
  end

  defp alert_performance_issue(resource_type, issue_type, message) do
    # In a real implementation, this would send alerts through various channels
    # (email, Slack, etc.)
    Logger.warning("Performance alert for #{resource_type} - #{issue_type}: #{message}")
  end
end
