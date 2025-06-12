defmodule HydepwnsLiveviewWeb.Themes.ThemeDetailLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.ThemeSystem

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [simple_form: 1, input: 1, button: 1]

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case ThemeSystem.get_theme(id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Theme not found")
         |> redirect(to: ~p"/themes")}

      theme ->
        {:ok, assign(socket, :theme, theme)}
    end
  end

  @impl true
  def handle_event("save", %{"theme" => theme_params}, socket) do
    case ThemeSystem.update_theme(socket.assigns.theme, theme_params) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> put_flash(:info, "Theme updated successfully")
         |> assign(:theme, theme)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_event("apply", _params, socket) do
    {:ok, _} = ThemeSystem.apply_theme(socket.assigns.theme)

    {:noreply,
     socket
     |> put_flash(:info, "Theme applied successfully")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Theme Details
        <:subtitle>Customize your theme settings.</:subtitle>
        <:actions>
          <.button phx-click="apply">Apply Theme</.button>
        </:actions>
      </.header>

      <.simple_form for={%{}} id="theme-form" phx-submit="save">
        <div class="space-y-6">
          <div>
            <h3 class="text-lg font-medium leading-6 text-gray-900">Colors</h3>
            <div class="mt-4 grid grid-cols-1 gap-4 sm:grid-cols-2">
              <.input field={@theme.colors.primary} type="color" label="Primary Color" />
              <.input field={@theme.colors.secondary} type="color" label="Secondary Color" />
              <.input field={@theme.colors.accent} type="color" label="Accent Color" />
              <.input field={@theme.colors.background} type="color" label="Background Color" />
            </div>
          </div>

          <div>
            <h3 class="text-lg font-medium leading-6 text-gray-900">Typography</h3>
            <div class="mt-4 grid grid-cols-1 gap-4 sm:grid-cols-2">
              <.input field={@theme.typography.font_family} type="text" label="Font Family" />
              <.input field={@theme.typography.font_size} type="number" label="Base Font Size" />
              <.input field={@theme.typography.line_height} type="number" label="Line Height" step="0.1" />
            </div>
          </div>

          <div>
            <h3 class="text-lg font-medium leading-6 text-gray-900">Spacing</h3>
            <div class="mt-4 grid grid-cols-1 gap-4 sm:grid-cols-2">
              <.input field={@theme.spacing.base} type="number" label="Base Spacing" />
              <.input field={@theme.spacing.small} type="number" label="Small Spacing" />
              <.input field={@theme.spacing.large} type="number" label="Large Spacing" />
            </div>
          </div>

          <div>
            <h3 class="text-lg font-medium leading-6 text-gray-900">Accessibility</h3>
            <div class="mt-4 grid grid-cols-1 gap-4 sm:grid-cols-2">
              <.input field={@theme.accessibility.contrast_ratio} type="number" label="Minimum Contrast Ratio" step="0.1" />
              <.input field={@theme.accessibility.font_size_min} type="number" label="Minimum Font Size" />
            </div>
          </div>
        </div>

        <:actions>
          <.button>Save Theme</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
