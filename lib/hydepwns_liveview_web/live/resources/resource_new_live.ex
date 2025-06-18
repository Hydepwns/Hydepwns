defmodule HydepwnsLiveviewWeb.ResourceNewLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Resources.ResourceSystem
  alias HydepwnsLiveview.Resources.Resource

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "New Resource")
     |> assign(:resource, %Resource{})
     |> assign(:resources, ResourceSystem.list_resources())}
  end
end
