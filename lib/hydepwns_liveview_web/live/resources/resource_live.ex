defmodule HydepwnsLiveviewWeb.Resources.ResourceLive do
  @moduledoc """
  LiveView for managing resources.
  """

  use HydepwnsLiveviewWeb, :live_view
  import Phoenix.Component

  alias HydepwnsLiveview.Resources
  alias HydepwnsLiveview.Resources.Resource
  alias HydepwnsLiveviewWeb.Components.UI.FormComponents
  alias HydepwnsLiveviewWeb.Components.UI.MonoForm

  defmacro __using__(_opts) do
    quote do
      import Phoenix.Component
      import Phoenix.LiveView
      import HydepwnsLiveviewWeb.Resources.ResourceHelpers
    end
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = HydepwnsLiveview.ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    {:ok, assign(socket, theme_class: theme_class)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Resources")
    |> assign(:resources, Resources.list_resources())
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    resource = Resources.get_resource!(id)
    {:ok, _} = Resources.delete_resource(resource)

    {:noreply, assign(socket, :resources, Resources.list_resources())}
  end

  @impl Phoenix.LiveView
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp resource_status_class("draft"), do: "bg-gray-100 text-gray-800"
  defp resource_status_class("published"), do: "bg-green-100 text-green-800"
  defp resource_status_class("archived"), do: "bg-red-100 text-red-800"
  defp resource_status_class(_), do: "bg-gray-100 text-gray-800"
end
