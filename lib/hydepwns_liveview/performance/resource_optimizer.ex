defmodule HydepwnsLiveview.Performance.ResourceOptimizer do
  @moduledoc """
  DEPRECATED: Use HydepwnsLiveview.Resources.PerformanceOptimizer instead.

  This module is maintained for backward compatibility and delegates to
  the consolidated Resources.PerformanceOptimizer module.

  Performance optimization tools for resource operations.

  This module provides tools for analyzing and optimizing the performance of 
  resource operations, including:
  - Resource loading optimization
  - Event stream processing optimization
  - Query optimization and caching
  - Batch processing for resource operations
  - Performance metrics collection and analysis
  """

  alias HydepwnsLiveview.Resources.PerformanceOptimizer
  alias HydepwnsLiveview.Events.Core.Event
  require Logger

  # Log deprecation warning on module compilation
  @on_compile {__MODULE__, :deprecated_warning}

  def deprecated_warning(_env) do
    Logger.warning(
      "HydepwnsLiveview.Performance.ResourceOptimizer is deprecated. " <>
        "Use HydepwnsLiveview.Resources.PerformanceOptimizer instead."
    )
  end

  # Forward all function calls to the new module
  defdelegate init, to: PerformanceOptimizer

  # Define function heads with default values
  def optimize_snapshot_interval(resource_module, opts \\ [])
  def batch_process(resource_module, commands, opts \\ [])
  def setup_resource_cache(resource_module, opts \\ [])

  # Delegate implementations to PerformanceOptimizer
  defdelegate optimize_snapshot_interval(resource_module, opts), to: PerformanceOptimizer
  defdelegate batch_process(resource_module, commands, opts), to: PerformanceOptimizer
  defdelegate setup_resource_cache(resource_module, opts), to: PerformanceOptimizer
  defdelegate get_cached_resource(resource_module, resource_id), to: PerformanceOptimizer

  alias HydepwnsLiveview.Events.EventStore
  alias HydepwnsLiveview.Events.Event

  # Default options
  @default_snapshot_interval 100
  @default_batch_size 50
  @default_cache_ttl_seconds 60

  # Cache registry table name
  @cache_registry_table :resource_cache_registry

  # Initialize the cache system
  def init do
    # Create the cache registry table if it doesn't exist
    if :ets.info(@cache_registry_table) == :undefined do
      :ets.new(@cache_registry_table, [
        :named_table,
        :set,
        :public,
        read_concurrency: true,
        write_concurrency: true
      ])

      Logger.info("Resource cache registry initialized")
    end

    # Start the cache maintenance process
    start_cache_maintenance_process()

    :ok
  end

  @doc """
  Optimizes snapshot generation for a resource.

  Analyzes event frequency and access patterns to determine the optimal
  snapshot interval for a given resource type.

  ## Parameters
  * `resource_module` - The resource module to optimize
  * `opts` - Options for the optimization

  ## Options
  * `:analysis_period` - Time period to analyze in seconds (default: 86400 - 1 day)
  * `:min_events` - Minimum number of events to consider (default: 10)
  * `:max_interval` - Maximum snapshot interval to recommend (default: 1000)

  ## Returns
  * `{:ok, recommended_interval}` - The recommended snapshot interval
  * `{:error, reason}` - Failed to determine optimal interval
  """
  def optimize_snapshot_interval(resource_module, opts) do
    # Get options
    analysis_period = Keyword.get(opts, :analysis_period, 86_400)
    min_events = Keyword.get(opts, :min_events, 10)
    max_interval = Keyword.get(opts, :max_interval, 1000)

    # Get the resource type
    resource_type = resource_module.resource_type()

    # Get event metrics
    with {:ok, metrics} <- gather_event_metrics(resource_type, analysis_period) do
      # If we don't have enough events, use the default
      if metrics.total_events < min_events do
        {:ok, @default_snapshot_interval}
      else
        # Calculate optimal interval based on:
        # 1. Read-to-write ratio (higher ratio = more frequent snapshots)
        # 2. Average event count per resource (higher count = more frequent snapshots)
        # 3. Average event size (larger events = more frequent snapshots)

        read_write_factor = metrics.read_count / max(metrics.write_count, 1)
        event_count_factor = metrics.avg_events_per_resource / 100
        event_size_factor = metrics.avg_event_size / 1024

        # Calculate a weighted score (higher = more frequent snapshots)
        score = read_write_factor * 0.5 + event_count_factor * 0.3 + event_size_factor * 0.2

        # Convert score to an interval (higher score = lower interval)
        interval = max(10, min(max_interval, trunc(@default_snapshot_interval / max(score, 0.1))))

        # Round to the nearest 10
        interval = round(interval / 10) * 10

        {:ok, interval}
      end
    end
  end

  @doc """
  Performs batch processing of resource commands.

  Groups and processes multiple resource commands in batches for improved performance.

  ## Parameters
  * `resource_module` - The resource module to use
  * `commands` - List of commands to process
  * `opts` - Options for batch processing

  ## Options
  * `:batch_size` - Size of each batch (default: 50)
  * `:parallel` - Whether to process batches in parallel (default: false)

  ## Returns
  * `{:ok, results}` - The results of the commands
  * `{:error, reason}` - Failed to process commands
  """
  def batch_process(resource_module, commands, opts) do
    # Get options
    batch_size = Keyword.get(opts, :batch_size, @default_batch_size)
    parallel = Keyword.get(opts, :parallel, false)

    # Group commands by resource ID to maintain order within each resource
    commands_by_resource =
      Enum.group_by(commands, fn {_command, resource_id, _args} -> resource_id end)

    # Create batches
    batches = create_batches(commands_by_resource, batch_size)

    # Process batches
    results =
      if parallel do
        # Process in parallel
        batches
        |> Task.async_stream(fn batch -> process_batch(resource_module, batch) end,
          ordered: false
        )
        |> Enum.flat_map(fn {:ok, result} -> result end)
      else
        # Process sequentially
        batches
        |> Enum.flat_map(fn batch -> process_batch(resource_module, batch) end)
      end

    {:ok, results}
  end

  @doc """
  Creates a caching layer for resource access.

  Sets up caching for resource state to reduce database and event store access.

  ## Parameters
  * `resource_module` - The resource module to cache
  * `opts` - Options for caching

  ## Options
  * `:ttl` - Time-to-live in seconds (default: 60)
  * `:max_size` - Maximum cache size (default: 1000)
  * `:invalidation_events` - List of event types that should invalidate cache

  ## Returns
  * `:ok` - Cache configured successfully
  * `{:error, reason}` - Failed to set up cache
  """
  def setup_resource_cache(resource_module, opts) do
    # Get options
    ttl = Keyword.get(opts, :ttl, @default_cache_ttl_seconds)
    max_size = Keyword.get(opts, :max_size, 1000)
    invalidation_events = Keyword.get(opts, :invalidation_events, [])

    # Cache name based on resource type
    cache_name = String.to_atom("#{resource_module.resource_type()}_cache")

    # Create cache table if it doesn't exist
    if :ets.info(cache_name) == :undefined do
      :ets.new(cache_name, [
        :named_table,
        :set,
        :public,
        read_concurrency: true,
        write_concurrency: true
      ])
    end

    # Store cache configuration
    cache_config = %{
      resource_module: resource_module,
      ttl: ttl,
      max_size: max_size,
      invalidation_events: invalidation_events,
      created_at: DateTime.utc_now()
    }

    # Store in the cache registry ETS table
    :ets.insert(@cache_registry_table, {cache_name, cache_config})

    # Subscribe to invalidation events if specified
    if invalidation_events != [] do
      Enum.each(invalidation_events, fn event_type ->
        # Subscribe to the event
        HydepwnsLiveview.Events.EventBus.subscribe(event_type)

        # Store the subscription info in the registry
        :ets.insert(@cache_registry_table, {{:event_subscription, event_type}, cache_name})
      end)
    end

    # Return success
    :ok
  end

  @doc """
  Retrieves a resource from cache or loads it if not cached.

  ## Parameters
  * `resource_module` - The resource module
  * `resource_id` - The resource ID

  ## Returns
  * `{:ok, resource}` - The resource (from cache or freshly loaded)
  * `{:error, reason}` - Failed to get resource
  """
  def get_cached_resource(resource_module, resource_id) do
    # Get cache name
    cache_name = String.to_atom("#{resource_module.resource_type()}_cache")

    # Check if cache exists
    if :ets.info(cache_name) == :undefined do
      # No cache, just load the resource directly
      resource_module.load(resource_id)
    else
      # Try to get from cache
      case :ets.lookup(cache_name, resource_id) do
        [{^resource_id, resource, inserted_at}] ->
          # Check if cache entry is still valid
          case get_cache_config(cache_name) do
            {:ok, cache_config} ->
              if cache_entry_valid?(inserted_at, cache_config.ttl) do
                # Cache hit
                {:ok, resource}
              else
                # Cache entry expired, reload and update cache
                reload_and_cache(resource_module, resource_id, cache_name)
              end

            {:error, _reason} ->
              # Cache config not found, reload and don't cache
              resource_module.load(resource_id)
          end

        [] ->
          # Cache miss, load and cache
          reload_and_cache(resource_module, resource_id, cache_name)
      end
    end
  end

  @doc """
  Invalidates cache entries for a resource.

  ## Parameters
  * `resource_module` - The resource module
  * `resource_id` - The resource ID to invalidate (or :all for all resources)

  ## Returns
  * `:ok` - Cache invalidated
  """
  def invalidate_cache(resource_module, resource_id \\ :all) do
    # Get cache name
    cache_name = String.to_atom("#{resource_module.resource_type()}_cache")

    # Check if cache exists
    if :ets.info(cache_name) != :undefined do
      case resource_id do
        :all ->
          # Clear entire cache
          :ets.delete_all_objects(cache_name)

        specific_id ->
          # Clear specific resource
          :ets.delete(cache_name, specific_id)
      end
    end

    :ok
  end

  @doc """
  Collects and analyzes performance metrics for resource operations.

  ## Parameters
  * `resource_type` - The resource type to analyze
  * `period` - Time period for analysis in seconds

  ## Returns
  * `{:ok, metrics}` - Performance metrics
  * `{:error, reason}` - Failed to collect metrics
  """
  def analyze_performance(resource_type, period \\ 3600) do
    gather_event_metrics(resource_type, period)
  end

  # Private functions

  defp gather_event_metrics(resource_type, period) do
    # This would query actual metrics from telemetry, databases, etc.
    # For this example, we'll return sample data
    cutoff_time = DateTime.add(DateTime.utc_now(), -period, :second)

    # In a real implementation, this would gather actual metrics from:
    # - EventStore access patterns
    # - Telemetry events
    # - Database query logs
    # - Resource access logs

    # Sample metrics
    {:ok,
     %{
       resource_type: resource_type,
       total_events: 1000,
       avg_events_per_resource: 50,
       # bytes
       avg_event_size: 512,
       read_count: 5000,
       write_count: 1000,
       period_seconds: period,
       cutoff_time: cutoff_time
     }}
  end

  defp create_batches(commands_by_resource, batch_size) do
    commands_by_resource
    |> Map.values()
    |> List.flatten()
    |> Enum.chunk_every(batch_size)
  end

  defp process_batch(resource_module, batch) do
    # In a real implementation, this would use the resource module to process
    # the commands efficiently, possibly in a transaction if appropriate

    Enum.map(batch, fn {command, resource_id, args} ->
      # Apply the command
      result = apply(resource_module, command, [resource_id | args])
      {command, resource_id, result}
    end)
  end

  defp cache_entry_valid?(inserted_at, ttl) do
    # Check if the cache entry is still valid based on TTL
    diff = DateTime.diff(DateTime.utc_now(), inserted_at, :second)
    diff < ttl
  end

  defp reload_and_cache(resource_module, resource_id, cache_name) do
    # Load the resource
    case resource_module.load(resource_id) do
      {:ok, resource} = result ->
        # Cache the result
        :ets.insert(cache_name, {resource_id, resource, DateTime.utc_now()})

        # Prune cache if needed (simple LRU-like approach)
        prune_cache_if_needed(cache_name)

        result

      error ->
        error
    end
  end

  defp prune_cache_if_needed(cache_name) do
    # Get cache config
    caches = Application.get_env(:hydepwns_liveview, :resource_caches, %{})
    cache_config = Map.get(caches, cache_name)

    if cache_config do
      # Check cache size
      case :ets.info(cache_name, :size) do
        size when size > cache_config.max_size ->
          # Prune oldest entries (based on inserted_at timestamp)
          # Remove 20% of entries
          prune_count = trunc(cache_config.max_size * 0.2)

          # Get all entries with timestamps
          all_entries = :ets.tab2list(cache_name)

          # Sort by timestamp (oldest first)
          sorted_entries = Enum.sort_by(all_entries, fn {_, _, timestamp} -> timestamp end)

          # Get the oldest entries to remove
          to_remove = Enum.take(sorted_entries, prune_count)

          # Remove them
          Enum.each(to_remove, fn {key, _, _} -> :ets.delete(cache_name, key) end)

        _ ->
          # Cache size is fine
          :ok
      end
    end
  end

  # Get cache configuration from the registry
  defp get_cache_config(cache_name) do
    case :ets.lookup(@cache_registry_table, cache_name) do
      [{^cache_name, config}] -> {:ok, config}
      [] -> {:error, :cache_config_not_found}
    end
  end

  # Start a process to maintain the cache (cleanup expired entries, etc.)
  defp start_cache_maintenance_process do
    # This would typically be a GenServer in a real application
    # For simplicity, we'll use a Task
    Task.start(fn ->
      # Run maintenance every minute
      :timer.sleep(60_000)
      cleanup_expired_cache_entries()
      start_cache_maintenance_process()
    end)
  end

  # Clean up expired cache entries
  defp cleanup_expired_cache_entries do
    # Get all cache configurations
    all_caches = :ets.tab2list(@cache_registry_table)

    # Filter out event subscriptions
    cache_configs =
      Enum.filter(all_caches, fn
        {name, _config} when is_atom(name) -> true
        _ -> false
      end)

    # Process each cache
    Enum.each(cache_configs, fn {cache_name, config} ->
      cleanup_cache(cache_name, config)
    end)
  end

  # Clean up a specific cache
  defp cleanup_cache(cache_name, config) do
    now = DateTime.utc_now()

    # Get all entries
    all_entries = :ets.tab2list(cache_name)

    # Find expired entries
    expired_entries =
      Enum.filter(all_entries, fn {_id, _resource, inserted_at} ->
        DateTime.diff(now, inserted_at, :second) > config.ttl
      end)

    # Delete expired entries
    Enum.each(expired_entries, fn {id, _resource, _inserted_at} ->
      :ets.delete(cache_name, id)
    end)

    # Log cleanup
    if length(expired_entries) > 0 do
      Logger.info("Cleaned up #{length(expired_entries)} expired entries from #{cache_name}")
    end

    # Check if we need to reduce cache size
    if length(all_entries) > config.max_size do
      # Sort by insertion time (oldest first)
      sorted_entries =
        Enum.sort_by(all_entries, fn {_id, _resource, inserted_at} -> inserted_at end)

      # Calculate how many to remove
      to_remove = length(all_entries) - config.max_size

      # Get the oldest entries to remove
      entries_to_remove = Enum.take(sorted_entries, to_remove)

      # Remove them
      Enum.each(entries_to_remove, fn {id, _resource, _inserted_at} ->
        :ets.delete(cache_name, id)
      end)

      Logger.info("Removed #{to_remove} oldest entries from #{cache_name} to maintain max size")
    end
  end

  # Handle cache invalidation events
  def handle_event(%HydepwnsLiveview.Events.Core.Event{type: event_type} = event) do
    # Check if this event type is registered for cache invalidation
    case :ets.lookup(@cache_registry_table, {:event_subscription, event_type}) do
      [{{:event_subscription, ^event_type}, cache_name}] ->
        # Invalidate the specific resource in the cache
        :ets.delete(cache_name, event.resource_id)

        Logger.info(
          "Invalidated cache entry for #{event.resource_id} in #{cache_name} due to event #{event_type}"
        )

      [] ->
        # No cache subscribed to this event
        :ok
    end
  end
end
