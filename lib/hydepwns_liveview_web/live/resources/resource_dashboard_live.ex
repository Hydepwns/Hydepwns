defmodule HydepwnsLiveviewWeb.ResourceDashboardLive do
  @moduledoc """
  LiveView for the resource dashboard.
  """

  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Resources

  @behaviour Phoenix.LiveView

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
    |> assign(:page_title, "Resource Dashboard")
    |> assign(:resources, Resources.list_resources())
    |> assign(:resource_stats, Resources.get_resource_stats())
  end

  @impl Phoenix.LiveView
  def handle_event("filter", %{"type" => type}, socket) do
    resources = Resources.list_resources_by_type(type)
    {:noreply, assign(socket, :resources, resources)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-2xl font-bold mb-6">Resource Dashboard</h1>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white shadow rounded-lg p-6">
          <h3 class="text-lg font-medium text-gray-900 mb-2">Total Resources</h3>
          <p class="text-3xl font-bold text-blue-600"><%= @resource_stats.total %></p>
        </div>

        <div class="bg-white shadow rounded-lg p-6">
          <h3 class="text-lg font-medium text-gray-900 mb-2">Published</h3>
          <p class="text-3xl font-bold text-green-600"><%= @resource_stats.published %></p>
        </div>

        <div class="bg-white shadow rounded-lg p-6">
          <h3 class="text-lg font-medium text-gray-900 mb-2">Draft</h3>
          <p class="text-3xl font-bold text-yellow-600"><%= @resource_stats.draft %></p>
        </div>
      </div>

      <div class="bg-white shadow rounded-lg p-6">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-xl font-bold">Resources</h2>
          <div class="flex space-x-4">
            <select
              phx-change="filter"
              class="block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm rounded-md"
            >
              <option value="">All Types</option>
              <option value="article">Articles</option>
              <option value="video">Videos</option>
              <option value="document">Documents</option>
            </select>
            <.link navigate={~p"/resources/new"} class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
              New Resource
            </.link>
          </div>
        </div>

        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for resource <- @resources do %>
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm font-medium text-gray-900"><%= resource.title %></div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm text-gray-500"><%= resource.type %></div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class={"px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{resource_status_class(resource.status)}"}>
                      <%= resource.status %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm text-gray-500"><%= Calendar.strftime(resource.inserted_at, "%B %d, %Y") %></div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <.link navigate={~p"/resources/#{resource}"} class="text-indigo-600 hover:text-indigo-900 mr-4">
                      Show
                    </.link>
                    <.link navigate={~p"/resources/#{resource}/edit"} class="text-indigo-600 hover:text-indigo-900 mr-4">
                      Edit
                    </.link>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  defp resource_status_class("draft"), do: "bg-gray-100 text-gray-800"
  defp resource_status_class("published"), do: "bg-green-100 text-green-800"
  defp resource_status_class("archived"), do: "bg-red-100 text-red-800"
  defp resource_status_class(_), do: "bg-gray-100 text-gray-800"
end
