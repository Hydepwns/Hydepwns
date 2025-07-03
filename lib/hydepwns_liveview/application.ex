defmodule HydepwnsLiveview.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Initialize telemetry storage for socket validation
    HydepwnsLiveview.Telemetry.init_storage()

    children =
      [
        HydepwnsLiveviewWeb.Telemetry,
        HydepwnsLiveview.Telemetry,
        HydepwnsLiveview.Telemetry.Alerts,
        HydepwnsLiveview.Resources.ResourceSystem,
        HydepwnsLiveview.Transformations.TransformationRegistry,
        HydepwnsLiveview.Transformations.TransformationMetrics,
        HydepwnsLiveview.Events.Core.EventSupervisor
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

    # Check if StandardTransformers has a register_defaults function and call it
    if function_exported?(StandardTransformers, :register_defaults, 0) do
      StandardTransformers.register_defaults()
    end
  end

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
