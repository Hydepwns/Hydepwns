defmodule HydepwnsLiveview.Resources.CacheServer do
  @moduledoc """
  GenServer for managing resource caching with advanced strategies.

  This module provides:
  - LRU (Least Recently Used) cache with size limits
  - Cache warming for frequently accessed resources
  - Adaptive TTL based on access patterns
  - Cache statistics and monitoring
  - Automatic cache cleanup
  """

  use GenServer
  require Logger

  # Client API

  @doc """
  Starts the cache server.

  ## Options
  * `:name` - The name to register the server under
  * `:max_size` - Maximum number of items in cache (default: 1000)
  * `:default_ttl` - Default time-to-live in seconds (default: 300)
  * `:cleanup_interval` - Interval between cache cleanups in seconds (default: 300)
  * `:warmup_interval` - Interval between cache warmups in seconds (default: 3600)

  ## Returns
  * `{:ok, pid}` - Server started successfully
  * `{:error, reason}` - Failed to start server
  """
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Gets a resource from cache or loads it if not cached.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The resource ID
  * `fetch_fn` - Function to fetch the resource if not in cache

  ## Returns
  * `{:ok, resource}` - The resource
  * `{:error, reason}` - Failed to get resource
  """
  def get(resource_type, resource_id, fetch_fn) do
    GenServer.call(__MODULE__, {:get, resource_type, resource_id, fetch_fn})
  end

  @doc """
  Puts a resource in the cache.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The resource ID
  * `resource` - The resource to cache
  * `opts` - Cache options

  ## Returns
  * `:ok` - Resource cached successfully
  * `{:error, reason}` - Failed to cache resource
  """
  def put(resource_type, resource_id, resource, opts \\ []) do
    GenServer.call(__MODULE__, {:put, resource_type, resource_id, resource, opts})
  end

  @doc """
  Invalidates cache entries for a resource.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The resource ID (or :all for all resources)

  ## Returns
  * `:ok` - Cache invalidated successfully
  * `{:error, reason}` - Failed to invalidate cache
  """
  def invalidate(resource_type, resource_id \\ :all) do
    GenServer.call(__MODULE__, {:invalidate, resource_type, resource_id})
  end

  @doc """
  Gets cache statistics.

  ## Returns
  * `{:ok, stats}` - Cache statistics
  * `{:error, reason}` - Failed to get statistics
  """
  def stats do
    GenServer.call(__MODULE__, :stats)
  end

  # Server Callbacks

  @impl true
  def init(opts) do
    # Get options
    max_size = Keyword.get(opts, :max_size, 1000)
    default_ttl = Keyword.get(opts, :default_ttl, 300)
    cleanup_interval = Keyword.get(opts, :cleanup_interval, 300)
    warmup_interval = Keyword.get(opts, :warmup_interval, 3600)

    # Create ETS tables
    cache_table = :ets.new(:resource_cache, [:named_table, :set, :public])
    stats_table = :ets.new(:cache_stats, [:named_table, :set, :public])
    access_table = :ets.new(:resource_access, [:named_table, :set, :public])

    # Initialize state
    state = %{
      cache_table: cache_table,
      stats_table: stats_table,
      access_table: access_table,
      max_size: max_size,
      default_ttl: default_ttl,
      cleanup_interval: cleanup_interval,
      warmup_interval: warmup_interval,
      stats: %{
        hits: 0,
        misses: 0,
        evictions: 0,
        size: 0
      }
    }

    # Schedule cleanup and warmup
    schedule_cleanup(cleanup_interval)
    schedule_warmup(warmup_interval)

    {:ok, state}
  end

  @impl true
  def handle_call({:get, resource_type, resource_id, fetch_fn}, _from, state) do
    cache_key = {resource_type, resource_id}

    case :ets.lookup(state.cache_table, cache_key) do
      [{^cache_key, resource, expiry}] ->
        if DateTime.compare(expiry, DateTime.utc_now()) == :gt do
          # Cache hit
          update_access_stats(state, resource_type, resource_id)
          update_stats(state, :hits)

          {:reply, {:ok, resource}, state}
        else
          # Cache expired
          handle_cache_miss(state, resource_type, resource_id, fetch_fn)
        end

      [] ->
        # Cache miss
        handle_cache_miss(state, resource_type, resource_id, fetch_fn)
    end
  end

  @impl true
  def handle_call({:put, resource_type, resource_id, resource, opts}, _from, state) do
    cache_key = {resource_type, resource_id}
    ttl = Keyword.get(opts, :ttl, state.default_ttl)
    expiry = DateTime.add(DateTime.utc_now(), ttl, :second)

    # Check if we need to evict entries
    if :ets.info(state.cache_table, :size) >= state.max_size do
      evict_entries(state)
    end

    # Store in cache
    :ets.insert(state.cache_table, {cache_key, resource, expiry})
    update_access_stats(state, resource_type, resource_id)
    update_stats(state, :size)

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:invalidate, resource_type, resource_id}, _from, state) do
    case resource_id do
      :all ->
        # Clear all entries for this resource type
        :ets.match_delete(state.cache_table, {{resource_type, :_}, :_, :_})
        {:reply, :ok, state}

      specific_id ->
        # Clear specific resource
        :ets.delete(state.cache_table, {resource_type, specific_id})
        {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call(:stats, _from, state) do
    stats = %{
      hits: :ets.lookup_element(state.stats_table, :hits, 2),
      misses: :ets.lookup_element(state.stats_table, :misses, 2),
      evictions: :ets.lookup_element(state.stats_table, :evictions, 2),
      size: :ets.info(state.cache_table, :size),
      hit_rate: calculate_hit_rate(state)
    }

    {:reply, {:ok, stats}, state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    cleanup_expired_entries(state)
    schedule_cleanup(state.cleanup_interval)
    {:noreply, state}
  end

  @impl true
  def handle_info(:warmup, state) do
    warmup_frequent_resources(state)
    schedule_warmup(state.warmup_interval)
    {:noreply, state}
  end

  # Private functions

  defp handle_cache_miss(state, resource_type, resource_id, fetch_fn) do
    # Try to fetch the resource
    case fetch_fn.() do
      {:ok, resource} ->
        # Cache the resource
        ttl = calculate_adaptive_ttl(state, resource_type, resource_id)
        expiry = DateTime.add(DateTime.utc_now(), ttl, :second)
        :ets.insert(state.cache_table, {{resource_type, resource_id}, resource, expiry})

        update_access_stats(state, resource_type, resource_id)
        update_stats(state, [:misses, :size])

        {:reply, {:ok, resource}, state}

      {:error, reason} ->
        update_stats(state, :misses)
        {:reply, {:error, reason}, state}
    end
  end

  defp update_access_stats(state, resource_type, resource_id) do
    # Update access count
    :ets.update_counter(
      state.access_table,
      {resource_type, resource_id},
      {2, 1},
      {resource_type, resource_id, 1}
    )

    # Update last access time
    :ets.insert(
      state.access_table,
      {{resource_type, resource_id, :last_access}, DateTime.utc_now()}
    )
  end

  defp update_stats(state, stat) when is_atom(stat) do
    :ets.update_counter(state.stats_table, stat, {2, 1}, {stat, 1})
  end

  defp update_stats(state, stats) when is_list(stats) do
    Enum.each(stats, &update_stats(state, &1))
  end

  defp calculate_hit_rate(state) do
    hits = :ets.lookup_element(state.stats_table, :hits, 2)
    misses = :ets.lookup_element(state.stats_table, :misses, 2)
    total = hits + misses

    if total > 0, do: hits / total, else: 0.0
  end

  defp calculate_adaptive_ttl(state, resource_type, resource_id) do
    # Get access pattern
    access_count =
      case :ets.lookup(state.access_table, {resource_type, resource_id}) do
        [{_, count}] -> count
        [] -> 0
      end

    # Adjust TTL based on access pattern
    cond do
      # Very frequently accessed
      access_count > 1000 -> state.default_ttl * 2
      # Frequently accessed
      access_count > 100 -> state.default_ttl * 1.5
      # Normal access
      access_count > 10 -> state.default_ttl
      # Rarely accessed
      true -> state.default_ttl * 0.5
    end
  end

  defp evict_entries(state) do
    # Get all entries with access times
    entries =
      :ets.match_object(state.access_table, {:"$1", :"$2", :"$3"})
      |> Enum.sort_by(fn {_, _, last_access} -> last_access end)

    # Remove 20% of least recently used entries
    to_remove = Enum.take(entries, trunc(length(entries) * 0.2))

    Enum.each(to_remove, fn {resource_type, resource_id, _} ->
      :ets.delete(state.cache_table, {resource_type, resource_id})
      :ets.delete(state.access_table, {resource_type, resource_id})
      :ets.delete(state.access_table, {resource_type, resource_id, :last_access})
      update_stats(state, :evictions)
    end)
  end

  defp cleanup_expired_entries(state) do
    now = DateTime.utc_now()

    # Match specification for expired entries
    match_spec = [
      {
        {:"$1", :_, {:const, :"$2"}},
        [{:==, {:call, DateTime, :compare, [:"$2", {:const, now}]}, :lt}],
        [true]
      }
    ]

    # Delete all expired entries
    :ets.select_delete(state.cache_table, match_spec)
  end

  defp warmup_frequent_resources(state) do
    # Get frequently accessed resources
    frequent_resources =
      :ets.match_object(state.access_table, {:"$1", :"$2", :"$3"})
      |> Enum.filter(fn {_, count, _} -> count > 100 end)
      |> Enum.map(fn {resource_type, resource_id, _} -> {resource_type, resource_id} end)

    # Warm up each resource
    Enum.each(frequent_resources, fn {resource_type, resource_id} ->
      case get_warmup_function(resource_type) do
        {:ok, warmup_fn} ->
          case warmup_fn.(resource_id) do
            {:ok, resource} ->
              put(resource_type, resource_id, resource)

            _ ->
              :ok
          end

        :error ->
          :ok
      end
    end)
  end

  defp get_warmup_function(resource_type) do
    # In a real implementation, this would look up the appropriate
    # warmup function for each resource type
    case resource_type do
      :user -> {:ok, &HydepwnsLiveview.Resources.User.load/1}
      :post -> {:ok, &HydepwnsLiveview.Resources.Post.load/1}
      :team -> {:ok, &HydepwnsLiveview.Resources.Team.load/1}
      _ -> :error
    end
  end

  defp schedule_cleanup(interval) do
    Process.send_after(self(), :cleanup, interval * 1000)
  end

  defp schedule_warmup(interval) do
    Process.send_after(self(), :warmup, interval * 1000)
  end
end
