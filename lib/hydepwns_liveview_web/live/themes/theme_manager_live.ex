defmodule HydepwnsLiveviewWeb.Themes.ThemeManagerLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.ThemeSystem

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"

    {:ok,
     assign(socket,
       themes: ThemeSystem.list_themes(),
       theme_class: theme_class,
       default_theme: default_theme.mode,
       page_title: "Theme Manager"
     )}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id} = _params, _url, socket) do
    socket =
      socket
      |> assign(:page_title, "Edit Theme")
      |> assign(:theme, ThemeSystem.get_theme!(id))

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    themes = ThemeSystem.list_themes()
    {:noreply, assign(socket, :themes, themes)}
  end

  @impl true
  def handle_event("update_theme", %{"theme" => theme}, socket) do
    theme_class = "#{theme}-theme"
    {:noreply, assign(socket, :theme_class, theme_class)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    theme = ThemeSystem.get_theme!(id)
    {:ok, _} = ThemeSystem.delete_theme(theme)

    {:noreply, assign(socket, :themes, ThemeSystem.list_themes())}
  end

  @impl true
  def handle_event("apply", %{"id" => id}, socket) do
    theme = ThemeSystem.get_theme!(id)
    {:ok, _} = ThemeSystem.apply_theme(theme)

    {:noreply, socket}
  end

  @impl true
  def handle_event("customize", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/themes/#{id}/customize")}
  end

  @impl true
  def handle_event("save", %{"theme" => theme_params}, socket) do
    case socket.assigns.theme do
      nil ->
        {:ok, _theme} = ThemeSystem.create_theme(theme_params)
        {:noreply, assign(socket, :themes, ThemeSystem.list_themes())}

      theme ->
        {:ok, _theme} = ThemeSystem.update_theme(theme, theme_params)
        {:noreply, assign(socket, :themes, ThemeSystem.list_themes())}
    end
  end

  @impl true
  def handle_info({:theme_updated, _theme}, socket) do
    {:noreply, assign(socket, :themes, ThemeSystem.list_themes())}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8" data-mode={@theme_class}>
      <%= HydepwnsLiveviewWeb.Components.Common.HeaderComponent.header(assigns) %>

      <div class="mt-8">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <%= for theme <- @themes do %>
            <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6" data-test-id={"theme-card-#{theme.id}"}>
              <div class="flex justify-between items-start mb-4">
                <h3 class="text-lg font-medium" data-test-id={"theme-name-#{theme.id}"}><%= theme.name %></h3>
                <div class="flex space-x-2">
                  <.link navigate={~p"/themes/#{theme}/edit"} data-test-id={"edit-theme-#{theme.id}"}>
                    <.button>Edit</.button>
                  </.link>
                  <button phx-click="delete" phx-value-id={theme.id} data-test-id={"delete-theme-#{theme.id}"}>
                    <.button>Delete</.button>
                  </button>
                </div>
              </div>
              <div class="space-y-2">
                <div><strong>Mode:</strong> <%= theme.mode %></div>
                <div><strong>Primary:</strong> <span style={"color: #{theme.primary_color}"}><%= theme.primary_color %></span></div>
                <div><strong>Secondary:</strong> <span style={"color: #{theme.secondary_color}"}><%= theme.secondary_color %></span></div>
                <div><strong>Background:</strong> <span style={"color: #{theme.background_color}"}><%= theme.background_color %></span></div>
                <div><strong>Text:</strong> <span style={"color: #{theme.text_color}"}><%= theme.text_color %></span></div>
              </div>
              <div class="mt-4">
                <button phx-click="apply" phx-value-id={theme.id} data-test-id={"apply-theme-#{theme.id}"}>
                  <.button>Apply Theme</.button>
                </button>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
