defmodule HydepwnsLiveviewWeb.ThemeFormLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.ThemeSystem
  alias HydepwnsLiveview.ThemeSystem.Models.Theme

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [simple_form: 1, input: 1, button: 1]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :theme, %Theme{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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
  def handle_event("save", %{"theme" => theme_params}, socket) do
    save_theme(socket, socket.assigns.live_action, theme_params)
  end

  defp save_theme(socket, :edit, theme_params) do
    case ThemeSystem.update_theme(socket.assigns.theme, theme_params) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> put_flash(:info, "Theme updated successfully")
         |> push_navigate(to: ~p"/themes/#{theme}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_theme(socket, :new, theme_params) do
    case ThemeSystem.create_theme(theme_params) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> put_flash(:info, "Theme created successfully")
         |> push_navigate(to: ~p"/themes/#{theme}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @page_title %>
      </.header>

      <.simple_form for={@changeset} id="theme-form" phx-submit="save">
        <.input field={@changeset[:name]} type="text" label="Name" />
        <.input field={@changeset[:description]} type="text" label="Description" />
        <.input field={@changeset[:is_active]} type="checkbox" label="Active" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Theme</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end 