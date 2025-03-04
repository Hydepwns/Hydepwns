defmodule HydepwnsLiveview.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HydepwnsLiveviewWeb.Telemetry,
      HydepwnsLiveview.Repo,
      {DNSCluster, query: Application.get_env(:hydepwns_liveview, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: HydepwnsLiveview.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: HydepwnsLiveview.Finch},
      # Start a worker by calling: HydepwnsLiveview.Worker.start_link(arg)
      # {HydepwnsLiveview.Worker, arg},
      # Start to serve requests, typically the last entry
      HydepwnsLiveviewWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HydepwnsLiveview.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HydepwnsLiveviewWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
