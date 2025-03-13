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
    # Create ETS table for resource cache
    :ets.new(@resource_cache_table, [:named_table, :set, :public, read_concurrency: true])

    # Register telemetry handlers
    register_telemetry_handlers()

    # Start background tasks
    start_cache_maintenance_task()

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
    # Build cache key
    cache_key = "#{resource_type}:#{resource_id}"

    # Get cache options
    cache_opts =
      Map.merge(
        @default_cache_opts,
        Map.new(Keyword.take(opts, [:ttl_seconds, :max_size, :invalidation_events]))
      )

    # Try process dictionary (fastest)
    case Process.get({:resource_cache, cache_key}) do
      {resource, expiry} ->
        if DateTime.compare(expiry, DateTime.utc_now()) == :gt do
          # Process cache is valid
          {:ok, resource}
        else
          # Process cache expired, try ETS
          try_ets_then_fetch(cache_key, fetch_fn, cache_opts)
        end

      nil ->
        # Not in process dictionary, try ETS
        try_ets_then_fetch(cache_key, fetch_fn, cache_opts)
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
    cache_key = "#{resource_type}:#{resource_id}"

    # Remove from process dictionary
    Process.delete({:resource_cache, cache_key})

    # Remove from ETS cache
    :ets.delete(@resource_cache_table, cache_key)

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
  def optimized_loading_strategy(client_info, resource_type, opts \\ []) do
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

  # Private helper functions

  defp try_ets_then_fetch(cache_key, fetch_fn, cache_opts) do
    # Try ETS cache
    case :ets.lookup(@resource_cache_table, cache_key) do
      [{^cache_key, resource, expiry}] ->
        if DateTime.compare(expiry, DateTime.utc_now()) == :gt do
          # Update process cache
          Process.put({:resource_cache, cache_key}, {resource, expiry})

          # Return cached resource
          {:ok, resource}
        else
          # ETS cache expired, fetch and update caches
          fetch_and_cache(cache_key, fetch_fn, cache_opts)
        end

      [] ->
        # Not in ETS, fetch and update caches
        fetch_and_cache(cache_key, fetch_fn, cache_opts)
    end
  end

  defp fetch_and_cache(cache_key, fetch_fn, cache_opts) do
    # Execute fetch function
    case fetch_fn.() do
      {:ok, resource} ->
        # Calculate expiry
        expiry = DateTime.add(DateTime.utc_now(), cache_opts.ttl_seconds, :second)

        # Update process cache
        Process.put({:resource_cache, cache_key}, {resource, expiry})

        # Update ETS cache
        :ets.insert(@resource_cache_table, {cache_key, resource, expiry})

        # Return the resource
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

    # Calculate expiry
    expiry = DateTime.add(DateTime.utc_now(), cache_opts.ttl_seconds, :second)

    # Cache each resource
    Enum.each(resources, fn {id, resource} ->
      cache_key = "#{resource_type}:#{id}"

      # Update process cache
      Process.put({:resource_cache, cache_key}, {resource, expiry})

      # Update ETS cache
      :ets.insert(@resource_cache_table, {cache_key, resource, expiry})
    end)
  end

  defp start_cache_maintenance_task do
    # Start a task to periodically clean up expired cache entries
    Task.start(fn ->
      # Wait 1 minute before first run
      :timer.sleep(60_000)
      cache_maintenance_loop()
    end)
  end

  defp cache_maintenance_loop do
    # Clean up expired cache entries
    clean_expired_cache_entries()

    # Wait before next run (5 minutes)
    :timer.sleep(300_000)

    # Loop
    cache_maintenance_loop()
  end

  defp clean_expired_cache_entries do
    now = DateTime.utc_now()

    # Find and delete expired entries
    :ets.foldl(
      fn {key, _resource, expiry}, acc ->
        if DateTime.compare(expiry, now) == :lt do
          :ets.delete(@resource_cache_table, key)
          acc + 1
        else
          acc
        end
      end,
      0,
      @resource_cache_table
    )
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
end
