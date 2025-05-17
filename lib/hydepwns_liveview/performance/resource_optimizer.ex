defmodule HydepwnsLiveview.Performance.ResourceOptimizer do
  @moduledoc """
  DEPRECATED: Use HydepwnsLiveview.Resources.PerformanceOptimizer instead.

  This module is maintained for backward compatibility and delegates to
  the consolidated Resources.PerformanceOptimizer module.
  """

  alias HydepwnsLiveview.Resources.PerformanceOptimizer
  require Logger

  def deprecated_warning(_env) do
    Logger.warning(
      "HydepwnsLiveview.Performance.ResourceOptimizer is deprecated. " <>
        "Use HydepwnsLiveview.Resources.PerformanceOptimizer instead."
    )
  end

  defdelegate init, to: PerformanceOptimizer
  defdelegate optimize_snapshot_interval(resource_module, opts \\ []), to: PerformanceOptimizer
  defdelegate batch_process(resource_module, commands, opts \\ []), to: PerformanceOptimizer
  defdelegate setup_resource_cache(resource_module, opts \\ []), to: PerformanceOptimizer
  defdelegate get_cached_resource(resource_module, resource_id), to: PerformanceOptimizer
  defdelegate invalidate_cache(resource_module, resource_id \\ :all), to: PerformanceOptimizer
  defdelegate analyze_performance(resource_type, period \\ 3600), to: PerformanceOptimizer
end
