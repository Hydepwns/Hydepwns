defmodule HydepwnsLiveviewWeb.GalleryLive do
  @moduledoc """
  LiveView for displaying the image gallery.
  """

  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Gallery

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
    |> assign(:page_title, "Gallery")
    |> assign(:images, Gallery.list_images())
  end

  @impl Phoenix.LiveView
  def handle_event("filter", %{"type" => type}, socket) do
    images = Gallery.list_images_by_type(type)
    {:noreply, assign(socket, :images, images)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Gallery</h1>
        <div class="flex space-x-4">
          <select
            phx-change="filter"
            class="block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm rounded-md"
          >
            <option value="">All Types</option>
            <option value="photo">Photos</option>
            <option value="artwork">Artwork</option>
            <option value="design">Design</option>
          </select>
        </div>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        <%= for image <- @images do %>
          <div class="bg-white shadow rounded-lg overflow-hidden">
            <div class="relative pb-[75%]">
              <img
                src={image.url}
                alt={image.title}
                class="absolute inset-0 w-full h-full object-cover"
                loading="lazy"
              />
            </div>
            <div class="p-4">
              <h3 class="text-lg font-medium text-gray-900"><%= image.title %></h3>
              <p class="mt-1 text-sm text-gray-500"><%= image.description %></p>
              <div class="mt-2">
                <span class={"px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{image_type_class(image.type)}"}>
                  <%= image.type %>
                </span>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp image_type_class("photo"), do: "bg-blue-100 text-blue-800"
  defp image_type_class("artwork"), do: "bg-purple-100 text-purple-800"
  defp image_type_class("design"), do: "bg-green-100 text-green-800"
  defp image_type_class(_), do: "bg-gray-100 text-gray-800"
end
