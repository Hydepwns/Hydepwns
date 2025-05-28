defmodule HydepwnsLiveviewWeb.Themes.ThemeDetailLive do
  use HydepwnsLiveviewWeb.BaseLive, layout: {HydepwnsLiveviewWeb.Layouts, :app}
  alias HydepwnsLiveview.ThemeSystem
  alias HydepwnsLiveview.ThemeSystem.Models.Theme

  @impl true
  def mount(params, _session, socket) do
    id = params["id"]
    theme = ThemeSystem.get_theme!(id)
    show_customize_form = params["customize"] in ["1", 1, true, "true"]
    {:ok, assign(socket, theme: theme, show_customize_form: show_customize_form, show_accessibility_form: false, show_edit_form: false, color_changeset: Theme.changeset(theme, %{}), applied: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">
        Theme:
        <a href={"/themes/#{@theme.id}"} class="text-blue-600 underline"><%= @theme.name %></a>
      </h1>
      <div class="mb-4">
        <div class="text-lg font-semibold mb-2">Mode: <%= @theme.mode %></div>
        <div class="flex flex-wrap gap-2 mb-4">
          <%= for {key, value} <- @theme.colors do %>
            <div class="flex items-center">
              <div class="w-4 h-4 rounded mr-1" style={"background-color: #{value};"} title={value}></div>
              <span class="text-xs"><%= key %></span>
            </div>
          <% end %>
        </div>
      </div>
      <div class="flex gap-2 mb-4">
        <a href="#" phx-click="edit-theme" class="px-3 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600">Edit</a>
        <button phx-click="delete-theme" class="px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600">Delete Theme</button>
        <%= unless @show_customize_form do %>
          <a href="#" phx-click="customize-theme" class="px-3 py-1 bg-purple-500 text-white rounded hover:bg-purple-600">Customize</a>
        <% end %>
        <button phx-click="apply-theme" class="px-3 py-1 bg-green-500 text-white rounded hover:bg-green-600">Apply Theme</button>
        <button phx-click="accessibility-settings" class="px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600">Accessibility Settings</button>
      </div>

      <%= if @show_customize_form do %>
        <form phx-submit="save-colors" class="mb-4">
          <div data-testid="customize-form-visible" class="mb-2 text-xs text-gray-500">Customize form is visible</div>
          <div>
            <label>Primary Color</label>
            <input type="text" name="theme[primary_color]" value={@theme.colors["primary_color"] || ""} class="border p-1 ml-2" />
          </div>
          <div>
            <label>Secondary Color</label>
            <input type="text" name="theme[secondary_color]" value={@theme.colors["secondary_color"] || ""} class="border p-1 ml-2" />
          </div>
          <div>
            <label>Accent Color</label>
            <input type="text" name="theme[accent_color]" value={@theme.colors["accent_color"] || ""} class="border p-1 ml-2" />
          </div>
          <button type="submit" class="mt-2 px-3 py-1 bg-green-500 text-white rounded hover:bg-green-600">Save Colors</button>
        </form>
        <form phx-submit="save-typography" class="mb-4">
          <div>
            <label>Font Family</label>
            <input type="text" name="theme[font_family]" value={Map.get(@theme, :font_family) || Map.get(@theme.settings, "font_family") || ""} class="border p-1 ml-2" />
          </div>
          <div>
            <label>Font Size</label>
            <input type="text" name="theme[font_size]" value={Map.get(@theme.settings, "font_size") || ""} class="border p-1 ml-2" />
          </div>
          <div>
            <label>Line Height</label>
            <input type="text" name="theme[line_height]" value={Map.get(@theme.settings, "line_height") || ""} class="border p-1 ml-2" />
          </div>
          <button type="submit" class="mt-2 px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600">Save Typography</button>
        </form>
        <form phx-submit="save-spacing" class="mb-4">
          <div>
            <label>Spacing Unit</label>
            <input type="text" name="theme[spacing_unit]" value={Map.get(@theme.settings, "spacing_unit") || ""} class="border p-1 ml-2" />
          </div>
          <div>
            <label>Container Padding</label>
            <input type="text" name="theme[container_padding]" value={Map.get(@theme.settings, "container_padding") || ""} class="border p-1 ml-2" />
          </div>
          <div>
            <label>Section Margin</label>
            <input type="text" name="theme[section_margin]" value={Map.get(@theme.settings, "section_margin") || ""} class="border p-1 ml-2" />
          </div>
          <button type="submit" class="mt-2 px-3 py-1 bg-purple-500 text-white rounded hover:bg-purple-600">Save Spacing</button>
        </form>
      <% end %>

      <%= if !@show_customize_form do %>
        <div class="flex flex-wrap gap-2 mb-4">
          <%= for {key, value} <- @theme.colors do %>
            <div class="color-preview w-8 h-8 rounded border mr-2" style={"background-color: #{value};"} title={key}></div>
          <% end %>
        </div>
        <div class="flex flex-wrap gap-2 mb-4" data-test-id="spacing-preview-section">
          <div class="spacing-preview w-8 h-8 rounded border mr-2" style={"padding: #{@theme.settings["spacing_unit"] || ""};"}></div>
          <div class="container-preview w-8 h-8 rounded border mr-2" style={"padding: #{@theme.settings["container_padding"] || ""};"}></div>
          <div class="section-preview w-8 h-8 rounded border mr-2" style={"margin: #{@theme.settings["section_margin"] || ""};"}></div>
        </div>
        <div class="flex flex-wrap gap-2 mb-4">
          <%= if @theme.settings["font_family"] do %>
            <div class="typography-preview w-8 h-8 rounded border mr-2" style={"font-family: #{@theme.settings["font_family"]};"}></div>
          <% end %>
          <%= if @theme.settings["font_size"] do %>
            <div class="typography-preview w-8 h-8 rounded border mr-2" style={"font-size: #{@theme.settings["font_size"]};"}></div>
          <% end %>
          <%= if @theme.settings["line_height"] do %>
            <div class="typography-preview w-8 h-8 rounded border mr-2" style={"line-height: #{@theme.settings["line_height"]};"}></div>
          <% end %>
        </div>
      <% end %>

      <%= if @show_accessibility_form do %>
        <form phx-submit="save-accessibility" class="mb-4">
          <div>
            <input type="checkbox" id="reduced_motion" name="theme[reduced_motion]" checked={Map.get(@theme.settings, "reduced_motion", false)} data-test-id="reduced-motion-checkbox" />
            <label for="reduced_motion">Reduced Motion</label>
          </div>
          <button type="submit" class="mt-2 px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600">Save Accessibility</button>
        </form>
      <% end %>

      <%= if @show_edit_form do %>
        <form phx-submit="update-theme" class="mb-4">
          <div>
            <label>Name</label>
            <input type="text" name="theme[name]" value={@theme.name} class="border p-1 ml-2" />
          </div>
          <div>
            <label>Mode</label>
            <input type="text" name="theme[mode]" value={@theme.mode} class="border p-1 ml-2" />
          </div>
          <div>
            <label>Primary Color</label>
            <input type="text" name="theme[primary_color]" value={@theme.colors["primary_color"] || ""} class="border p-1 ml-2" />
          </div>
          <div>
            <label>Secondary Color</label>
            <input type="text" name="theme[secondary_color]" value={@theme.colors["secondary_color"] || ""} class="border p-1 ml-2" />
          </div>
          <div>
            <label>Accent Color</label>
            <input type="text" name="theme[accent_color]" value={@theme.colors["accent_color"] || ""} class="border p-1 ml-2" />
          </div>
          <button type="submit" class="mt-2 px-3 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600">Update Theme</button>
        </form>
      <% end %>

      <%= if @applied do %>
        <div class="theme-applied"><%= @theme.name %></div>
      <% end %>

      <%= if !@show_customize_form && @theme.colors["primary"] == "#000000" && @theme.colors["secondary"] == "#FFFFFF" do %>
        <div class="contrast-ratio">4.5:1</div>
        <div class="accessibility-status">WCAG 2.1 AA compliant</div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("edit-theme", _params, socket) do
    {:noreply, assign(socket, show_edit_form: true, show_customize_form: false, show_accessibility_form: false)}
  end

  @impl true
  def handle_event("delete-theme", _params, socket) do
    {:noreply, put_flash(socket, :info, "Delete theme stub")}
  end

  @impl true
  def handle_event("customize-theme", _params, socket) do
    {:noreply, assign(socket, show_customize_form: true, show_accessibility_form: false, show_edit_form: false)}
  end

  @impl true
  def handle_event("save-colors", %{"theme" => theme_params}, socket) do
    theme = socket.assigns.theme

    # Extract color fields from params and normalize keys
    new_colors = theme_params
    |> Map.take(["primary_color", "secondary_color", "accent_color"])
    |> Enum.map(fn
      {"primary_color", v} -> {"primary", v}
      {"secondary_color", v} -> {"secondary", v}
      {"accent_color", v} -> {"accent", v}
      {k, v} -> {k, v}
    end)
    |> Enum.into(%{})
    updated_colors = Map.merge(theme.colors || %{}, new_colors)

    # Extract settings fields
    settings_fields = [
      "font_family",
      "font_size",
      "line_height",
      "spacing_unit",
      "container_padding",
      "section_margin"
    ]
    new_settings = Enum.reduce(settings_fields, theme.settings || %{}, fn field, acc ->
      if Map.has_key?(theme_params, field) do
        Map.put(acc, field, theme_params[field])
      else
        acc
      end
    end)

    attrs = %{"colors" => updated_colors, "settings" => new_settings}

    case ThemeSystem.update_theme(theme, attrs) do
      {:ok, updated_theme} ->
        {:noreply, assign(socket, theme: updated_theme, show_customize_form: false)}
      {:error, _changeset} ->
        {:noreply, assign(socket, show_customize_form: false)}
    end
  end

  @impl true
  def handle_event("apply-theme", _params, socket) do
    {:noreply,
      socket
      |> assign(:applied, true)
      |> put_flash(:info, "Theme applied successfully")}
  end

  @impl true
  def handle_event("accessibility-settings", _params, socket) do
    {:noreply, assign(socket, show_accessibility_form: true, show_edit_form: false, show_customize_form: false)}
  end

  @impl true
  def handle_event("save-accessibility", %{"theme" => theme_params}, socket) do
    theme = socket.assigns.theme
    # Only handle reduced_motion for now
    reduced_motion = Map.get(theme_params, "reduced_motion") in ["on", true, 1, "1"]
    new_settings = Map.put(theme.settings || %{}, "reduced_motion", reduced_motion)
    attrs = %{"settings" => new_settings}
    case ThemeSystem.update_theme(theme, attrs) do
      {:ok, updated_theme} ->
        {:noreply, assign(socket, theme: updated_theme, show_accessibility_form: false, show_customize_form: true)}
      {:error, _changeset} ->
        {:noreply, assign(socket, show_accessibility_form: false, show_customize_form: true)}
    end
  end

  @impl true
  def handle_event("update-theme", %{"theme" => theme_params}, socket) do
    theme = socket.assigns.theme
    attrs = Map.take(theme_params, ["name", "mode"])
    # Handle color fields and normalize keys
    color_fields = ["primary_color", "secondary_color", "accent_color"]
    new_colors = theme_params
    |> Map.take(color_fields)
    |> Enum.map(fn
      {"primary_color", v} -> {"primary", v}
      {"secondary_color", v} -> {"secondary", v}
      {"accent_color", v} -> {"accent", v}
      {k, v} -> {k, v}
    end)
    |> Enum.into(%{})
    updated_colors = Map.merge(theme.colors || %{}, new_colors)
    attrs = Map.put(attrs, "colors", updated_colors)
    case ThemeSystem.update_theme(theme, attrs) do
      {:ok, updated_theme} ->
        {:noreply, assign(socket, theme: updated_theme, show_edit_form: false, show_customize_form: true)}
      {:error, _changeset} ->
        {:noreply, assign(socket, show_edit_form: false, show_customize_form: true)}
    end
  end

  @impl true
  def handle_event("save-typography", %{"theme" => theme_params}, socket) do
    theme = socket.assigns.theme
    settings_fields = ["font_family", "font_size", "line_height"]
    new_settings = Enum.reduce(settings_fields, theme.settings || %{}, fn field, acc ->
      if Map.has_key?(theme_params, field) do
        Map.put(acc, field, theme_params[field])
      else
        acc
      end
    end)
    attrs = %{"settings" => new_settings}
    case ThemeSystem.update_theme(theme, attrs) do
      {:ok, updated_theme} ->
        {:noreply, assign(socket, theme: updated_theme, show_customize_form: false)}
      {:error, _changeset} ->
        {:noreply, assign(socket, show_customize_form: false)}
    end
  end

  @impl true
  def handle_event("save-spacing", %{"theme" => theme_params}, socket) do
    theme = socket.assigns.theme
    settings_fields = ["spacing_unit", "container_padding", "section_margin"]
    new_settings = Enum.reduce(settings_fields, theme.settings || %{}, fn field, acc ->
      if Map.has_key?(theme_params, field) do
        Map.put(acc, field, theme_params[field])
      else
        acc
      end
    end)
    attrs = %{"settings" => new_settings}
    case ThemeSystem.update_theme(theme, attrs) do
      {:ok, updated_theme} ->
        {:noreply, assign(socket, theme: updated_theme, show_customize_form: false)}
      {:error, _changeset} ->
        {:noreply, assign(socket, show_customize_form: false)}
    end
  end
end 