defmodule HydepwnsLiveview.PromEx do
  @moduledoc """
  PromEx configuration for HydepwnsLiveview event monitoring metrics.
  """

  use PromEx, otp_app: :hydepwns_liveview

  @impl true
  def plugins do
    [
      # PromEx built-in plugins
      PromEx.Plugins.Application,
      PromEx.Plugins.Beam,
      {PromEx.Plugins.Phoenix, router: HydepwnsLiveviewWeb.Router},
      PromEx.Plugins.Ecto,
      PromEx.Plugins.PhoenixLiveView
    ]
  end

  @impl true
  def dashboard_assigns do
    [
      otp_app: :hydepwns_liveview,
      datasource_id: "prometheus",
      default_selected_interval: "30s"
    ]
  end

  @impl true
  def dashboards do
    [
      # PromEx built-in dashboards
      {:prom_ex, "application.json"},
      {:prom_ex, "beam.json"},
      {:prom_ex, "phoenix.json"},
      {:prom_ex, "ecto.json"},
      {:prom_ex, "phoenix_live_view.json"},
      # Custom dashboard for event monitoring
      {:hydepwns_liveview, "event_monitoring.json"}
    ]
  end


end
