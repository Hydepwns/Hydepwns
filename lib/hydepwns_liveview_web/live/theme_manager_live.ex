defmodule HydepwnsLiveviewWeb.ThemeManagerLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Layouts, :app}

  alias HydepwnsLiveview.Themes
  alias HydepwnsLiveview.ThemeSystem.Models.Theme
  import HydepwnsLiveviewWeb.Components.UI.ThemeToggle

  @impl true
  def do_mount(_params, _session, socket) do
    themes = Themes.list_themes()
    changeset = Themes.change_theme(%Theme{})

    socket =
      socket
      |> assign(:page_title, "Theme Manager")
      |> assign(:themes, themes)
      |> assign(:changeset, changeset)

    socket
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">Theme Manager</h1>

      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">Current Themes</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for theme <- @themes do %>
            <div class="border rounded-lg p-4 shadow-sm">
              <div class="flex justify-between items-center mb-2">
                <h3 class="text-lg font-medium">{theme.name}</h3>
                <%= if theme.is_default do %>
                  <span class="bg-green-100 text-green-800 text-xs px-2 py-1 rounded">Default</span>
                <% end %>
              </div>
              <div class="text-sm mb-2">Mode: {theme.mode}</div>
              <div class="flex flex-wrap gap-2 mb-4">
                <%= for {key, value} <- theme.colors do %>
                  <div class="flex items-center">
                    <div class="w-4 h-4 rounded mr-1" style={"background-color: #{value};"} title={value}></div>
                    <span class="text-xs">{key}</span>
                  </div>
                <% end %>
              </div>
              <div class="flex justify-end gap-2">
                <button phx-click="set-default" phx-value-id={theme.id} class="text-sm px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:opacity-50" disabled={theme.is_default}>
                  Set Default
                </button>
                <button phx-click="delete-theme" phx-value-id={theme.id} class="text-sm px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600" disabled={theme.is_default}>
                  Delete
                </button>
              </div>
            </div>
          <% end %>
        </div>
      </div>

      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">Add New Theme</h2>
        <.form for={@changeset} phx-submit="save">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
            <div>
              <label class="block text-sm font-medium mb-1">Name</label>
              <input type="text" name="theme[name]" class="w-full px-3 py-2 border rounded" required />
            </div>
            <div>
              <label class="block text-sm font-medium mb-1">Mode</label>
              <select name="theme[mode]" class="w-full px-3 py-2 border rounded">
                <option value="light">Light</option>
                <option value="dark">Dark</option>
                <option value="system">System</option>
              </select>
            </div>
          </div>

          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">Colors</label>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div>
                <label class="block text-xs mb-1">Primary</label>
                <input type="color" name="theme[colors][primary]" class="w-full" value="#3b82f6" />
              </div>
              <div>
                <label class="block text-xs mb-1">Secondary</label>
                <input type="color" name="theme[colors][secondary]" class="w-full" value="#10b981" />
              </div>
              <div>
                <label class="block text-xs mb-1">Accent</label>
                <input type="color" name="theme[colors][accent]" class="w-full" value="#f59e0b" />
              </div>
              <div>
                <label class="block text-xs mb-1">Background</label>
                <input type="color" name="theme[colors][background]" class="w-full" value="#ffffff" />
              </div>
              <div>
                <label class="block text-xs mb-1">Text</label>
                <input type="color" name="theme[colors][text]" class="w-full" value="#1f2937" />
              </div>
            </div>
          </div>

          <div class="mb-4">
            <label class="flex items-center">
              <input type="checkbox" name="theme[is_default]" class="mr-2" />
              <span class="text-sm">Set as default theme</span>
            </label>
          </div>

          <div>
            <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
              Create Theme
            </button>
          </div>
        </.form>
      </div>

      <div class="mt-8">
        <h2 class="text-xl font-semibold mb-4">Theme Preview</h2>
        <div class="border rounded-lg p-4 shadow-sm">
          <.theme_toggle />
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("save", %{"theme" => theme_params}, socket) do
    # Convert string keys to atoms for the colors map
    colors =
      (theme_params["colors"] || %{})
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Map.new()

    # Update the theme_params with the converted colors map
    theme_params =
      theme_params
      |> Map.put("colors", colors)

    case Themes.create_theme(theme_params) do
      {:ok, _theme} ->
        themes = Themes.list_themes()

        socket =
          socket
          |> assign(:themes, themes)
          |> assign(:changeset, Themes.change_theme(%Theme{}))
          |> put_flash(:info, "Theme created successfully.")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("set-default", %{"id" => id}, socket) do
    theme = Themes.get_theme!(id)
    {:ok, _} = Themes.update_theme(theme, %{is_default: true})
    themes = Themes.list_themes()
    {:noreply, assign(socket, :themes, themes)}
  end

  @impl true
  def handle_event("delete-theme", %{"id" => id}, socket) do
    theme = Themes.get_theme!(id)
    {:ok, _} = Themes.delete_theme(theme)
    themes = Themes.list_themes()
    {:noreply, assign(socket, :themes, themes)}
  end
end
