defmodule HydepwnsLiveviewWeb.Themes.ThemeEditLive do
  use HydepwnsLiveviewWeb, :live_view

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [input: 1, label: 1]

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    {:ok, assign(socket, theme_class: theme_class)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _url, socket) do
    theme = ThemeSystem.get_theme!(id)
    {:noreply, assign(socket, :theme, theme)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"theme" => theme_params}, socket) do
    case ThemeSystem.update_theme(socket.assigns.theme, theme_params) do
      {:ok, _theme} ->
        {:noreply,
         socket
         |> put_flash(:info, "Theme updated successfully")
         |> push_navigate(to: ~p"/themes")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <%= HydepwnsLiveviewWeb.Components.Common.HeaderComponent.header(assigns) %>

      <div class="bg-white shadow rounded-lg p-6">
        <div class="space-y-6">
          <div>
            <h3 class="text-lg font-medium">Edit Theme</h3>
            <.form
              :let={f}
              for={%{}}
              id="theme-form"
              phx-submit="save"
            >
              <div class="space-y-4">
          <div>
                  <.label for={f[:name].id}>Name</.label>
                  <.input field={f[:name]} type="text" value={@theme.name} />
          </div>

          <div>
                  <.label for={f[:mode].id}>Mode</.label>
                  <.input field={f[:mode]} type="select" options={[Light: "light", Dark: "dark", System: "system"]} value={@theme.mode} />
          </div>

                <div class="flex justify-end space-x-4">
                  <.link navigate={~p"/themes/#{@theme}"} class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded">
                    Cancel
                  </.link>
                  <.button type="submit" phx-disable-with="Saving...">
                    Save Theme
                  </.button>
          </div>
          </div>
            </.form>
          </div>
        </div>
        </div>
    </div>
    """
  end
end 