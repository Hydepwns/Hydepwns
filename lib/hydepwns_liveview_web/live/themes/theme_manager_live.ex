defmodule HydepwnsLiveviewWeb.Themes.ThemeManagerLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.ThemeSystem
  alias HydepwnsLiveview.ThemeSystem.Models.Theme

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [button: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :themes, ThemeSystem.list_themes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Themes")
    |> assign(:theme, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Theme")
    |> assign(:theme, %Theme{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Theme")
    |> assign(:theme, ThemeSystem.get_theme!(id))
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
  def handle_info({:theme_updated, _theme}, socket) do
    {:noreply, assign(socket, :themes, ThemeSystem.list_themes())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Themes
        <:actions>
          <.link patch={~p"/themes/new"}>
            <.button>New Theme</.button>
          </.link>
        </:actions>
      </.header>

      <.table id="themes" rows={@themes}>
        <:col :let={theme} label="Name"><%= theme.name %></:col>
        <:col :let={theme} label="Description"><%= theme.description %></:col>
        <:action :let={theme}>
          <div class="flex gap-2">
            <.link patch={~p"/themes/#{theme}/edit"}>
              <.button>Edit</.button>
            </.link>
            <.button phx-click="apply" phx-value-id={theme.id}>Apply</.button>
            <.button phx-click="customize" phx-value-id={theme.id}>Customize</.button>
            <.button phx-click="delete" phx-value-id={theme.id} data-confirm="Are you sure?">Delete</.button>
          </div>
        </:action>
      </.table>
    </div>
    """
  end
end
