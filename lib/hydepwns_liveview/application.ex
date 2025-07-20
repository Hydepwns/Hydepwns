defmodule HydepwnsLiveview.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Initialize telemetry storage for socket validation
    HydepwnsLiveview.Telemetry.init_storage()

    # Ensure ETS table for rate limiting exists at startup
    table_name = :rate_limits

    case :ets.info(table_name) do
      :undefined ->
        :ets.new(table_name, [:set, :public, :named_table])

      _ ->
        :ok
    end

    # Initialize theme system ETS table at startup
    HydepwnsLiveview.ThemeSystem.ensure_default_theme()

    children =
      [
        HydepwnsLiveviewWeb.Telemetry,
        HydepwnsLiveview.Telemetry,
        HydepwnsLiveview.Telemetry.Alerts,
        HydepwnsLiveview.Resources.ResourceSystem,
        HydepwnsLiveview.Transformations.TransformationRegistry,
        HydepwnsLiveview.Transformations.TransformationMetrics,
        HydepwnsLiveview.Events.Core.EventSupervisor,
        HydepwnsLiveview.RateLimitSupervisor,
        HydepwnsLiveview.PromEx
      ] ++
        if Mix.env() != :test do
          [HydepwnsLiveview.Events.Core.EventMonitor]
        else
          []
        end ++
        [
          HydepwnsLiveview.Repo,
          {DNSCluster,
           query: Application.get_env(:hydepwns_liveview, :dns_cluster_query) || :ignore},
          {Phoenix.PubSub, name: HydepwnsLiveview.PubSub},
          {Finch, name: HydepwnsLiveview.Finch},
          HydepwnsLiveviewWeb.Endpoint,
          HydepwnsLiveviewWeb.Presence,
          HydepwnsLiveview.Events.ReminderWorker
        ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HydepwnsLiveview.Supervisor]
    result = Supervisor.start_link(children, opts)

      # After startup, register default transformations
  register_default_transformations()

  # After startup, register default event handlers
  register_default_event_handlers()

  result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HydepwnsLiveviewWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Register default transformations after application startup
  defp register_default_transformations do
    # Import to access the module
    alias HydepwnsLiveview.Transformations.StandardTransformers

    # Wait for the TransformationRegistry to be ready
    # Try to ping the registry a few times to ensure it's started
    case wait_for_registry(10) do
      :ok ->
        # Check if StandardTransformers has a register_defaults function and call it
        if function_exported?(StandardTransformers, :register_defaults, 0) do
          StandardTransformers.register_defaults()
        end

      :error ->
        # Log error but don't crash the application
        IO.puts("Warning: TransformationRegistry not ready, skipping default transformations")
    end
  end

  # Wait for the TransformationRegistry to be ready
  defp wait_for_registry(attempts) when attempts > 0 do
    case Process.whereis(HydepwnsLiveview.Transformations.TransformationRegistry) do
      nil ->
        # Registry not started yet, wait a bit and retry
        Process.sleep(100)
        wait_for_registry(attempts - 1)

      _pid ->
        # Registry is started, try to ping it
        case GenServer.call(HydepwnsLiveview.Transformations.TransformationRegistry, :get_transformations, 1000) do
          _transformations -> :ok
        end
    end
  end

  defp wait_for_registry(0), do: :error

  # Register default event handlers after application startup
  defp register_default_event_handlers do
    # Import to access the module
    alias HydepwnsLiveview.Events.StandardHandlers
    alias HydepwnsLiveview.Events.EventSupervisor

    # Register standard handlers
    if function_exported?(StandardHandlers, :register_handlers, 0) do
      StandardHandlers.register_handlers()
    end

    # Register standard projections
    if function_exported?(EventSupervisor, :register_standard_projections, 0) do
      EventSupervisor.register_standard_projections()
    end
  end
end
