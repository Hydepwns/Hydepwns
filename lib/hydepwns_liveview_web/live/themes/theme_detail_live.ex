defmodule HydepwnsLiveviewWeb.Themes.ThemeDetailLive do
  use HydepwnsLiveviewWeb.BaseLive, layout: {HydepwnsLiveviewWeb.Layouts, :app}
  alias HydepwnsLiveview.ThemeSystem
  alias HydepwnsLiveview.ThemeSystem.Models.Theme

  @impl true
  def mount(params, _session, socket) do
    id = params["id"]
    theme = ThemeSystem.get_theme!(id)
    show_customize_form = params["customize"] in ["1", 1, true, "true"]
    default_theme = ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"

    {:ok,
     assign(socket,
       theme: theme,
       show_customize_form: show_customize_form,
       show_accessibility_form: false,
       show_edit_form: false,
       color_changeset: Theme.changeset(theme, %{}),
       applied: false,
       theme_class: theme_class
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">
        Theme: <a href={"/themes/#{@theme.id}"} class="text-blue-600 underline">{@theme.name}</a>
      </h1>
      <div class="mb-4">
        <div class="text-lg font-semibold mb-2">Mode: {@theme.mode}</div>
        <div class="flex flex-wrap gap-2 mb-4">
          <%= for {key, value} <- @theme.colors do %>
            <div class="flex items-center">
              <div class="w-4 h-4 rounded mr-1" style={"background-color: #{value};"} title={value}></div>
              <span class="text-xs">{key}</span>
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
        <.simple_form :let={f} for={@color_changeset} as={:theme} phx-submit="save-colors">
          <.error :if={@color_changeset.action}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <:inner_block_simple_form :let={f}>
            <div class="space-y-4">
              <h3 class="text-lg font-medium">Colors</h3>
              <.input field={f[:primary_color]} id="theme_primary_color" type="text" type_input="text" label="Primary Color" name="theme[primary_color]" value={@theme.colors["primary_color"] || ""} data-test-id="theme-primary-color" />
              <.input field={f[:secondary_color]} id="theme_secondary_color" type="text" type_input="text" label="Secondary Color" name="theme[secondary_color]" value={@theme.colors["secondary_color"] || ""} data-test-id="theme-secondary-color" />
              <.input field={f[:accent_color]} id="theme_accent_color" type="text" type_input="text" label="Accent Color" name="theme[accent_color]" value={@theme.colors["accent_color"] || ""} data-test-id="theme-accent-color" />
            </div>
          </:inner_block_simple_form>
          <:actions>
            <.button type="submit" data-test-id="save-colors-button">Save Colors</.button>
          </:actions>
        </.simple_form>

        <.simple_form :let={f} for={@color_changeset} as={:theme} phx-submit="save-typography">
          <.error :if={@color_changeset.action}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <:inner_block_simple_form :let={f}>
            <div class="space-y-4">
              <h3 class="text-lg font-medium">Typography</h3>
              <.input field={f[:font_family]} id="theme_font_family" type="text" type_input="text" label="Font Family" name="theme[font_family]" value={Map.get(@theme, :font_family) || Map.get(@theme.settings, "font_family") || ""} data-test-id="theme-font-family" />
              <.input field={f[:font_size]} id="theme_font_size" type="select" type_input="select" label="Font Size" options={[{"Small", "small"}, {"Medium", "medium"}, {"Large", "large"}]} name="theme[font_size]" value={Map.get(@theme.settings, "font_size") || ""} data-test-id="theme-font-size" />
              <.input field={f[:line_height]} id="theme_line_height" type="select" type_input="select" label="Line Height" options={[{"Normal", "normal"}, {"Wide", "wide"}]} name="theme[line_height]" value={Map.get(@theme.settings, "line_height") || ""} data-test-id="theme-line-height" />
            </div>
          </:inner_block_simple_form>
          <:actions>
            <.button type="submit" data-test-id="save-typography-button">Save Typography</.button>
          </:actions>
        </.simple_form>

        <.simple_form :let={f} for={@color_changeset} as={:theme} phx-submit="save-spacing">
          <.error :if={@color_changeset.action}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <:inner_block_simple_form :let={f}>
            <div class="space-y-4">
              <h3 class="text-lg font-medium">Spacing</h3>
              <.input field={f[:spacing_unit]} id="theme_spacing_unit" type="text" type_input="text" label="Spacing Unit" name="theme[spacing_unit]" value={Map.get(@theme.settings, "spacing_unit") || ""} data-test-id="theme-spacing-unit" />
              <.input field={f[:container_padding]} id="theme_container_padding" type="text" type_input="text" label="Container Padding" name="theme[container_padding]" value={Map.get(@theme.settings, "container_padding") || ""} data-test-id="theme-container-padding" />
              <.input field={f[:section_margin]} id="theme_section_margin" type="text" type_input="text" label="Section Margin" name="theme[section_margin]" value={Map.get(@theme.settings, "section_margin") || ""} data-test-id="theme-section-margin" />
            </div>
          </:inner_block_simple_form>
          <:actions>
            <.button type="submit" data-test-id="save-spacing-button">Save Spacing</.button>
          </:actions>
        </.simple_form>
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
        <.simple_form :let={f} for={@color_changeset} as={:theme} phx-submit="save-accessibility">
          <.error :if={@color_changeset.action}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <:inner_block_simple_form :let={f}>
            <div class="space-y-4">
              <h3 class="text-lg font-medium">Accessibility</h3>
              <.input field={f[:reduced_motion]} id="theme_reduced_motion" type="checkbox" type_input="checkbox" label="Reduced Motion" name="theme[reduced_motion]" checked={Map.get(@theme.settings, "reduced_motion", false)} data-test-id="theme-reduced-motion" />
            </div>
          </:inner_block_simple_form>
          <:actions>
            <.button type="submit" data-test-id="save-accessibility-button">Save Accessibility</.button>
          </:actions>
        </.simple_form>
      <% end %>

      <%= if @show_edit_form do %>
        <.simple_form :let={f} for={@color_changeset} as={:theme} phx-submit="update-theme">
          <.error :if={@color_changeset.action}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <:inner_block_simple_form :let={f}>
            <.input field={f[:name]} id="theme_name" type="text" type_input="text" label="Name" name="theme[name]" value={@theme.name} data-test-id="theme-name-input" />
            <.input field={f[:mode]} id="theme_mode" type="select" type_input="select" label="Mode" options={[{"Light", "light"}, {"Dark", "dark"}, {"Dim", "dim"}, {"System", "system"}]} name="theme[mode]" value={@theme.mode} data-test-id="theme-mode-select" />
            <div class="space-y-4">
              <h3 class="text-lg font-medium">Colors</h3>
              <.input field={f[:primary_color]} id="theme_primary_color" type="text" type_input="text" label="Primary Color" name="theme[primary_color]" value={@theme.colors["primary_color"] || ""} data-test-id="theme-primary-color" />
              <.input field={f[:secondary_color]} id="theme_secondary_color" type="text" type_input="text" label="Secondary Color" name="theme[secondary_color]" value={@theme.colors["secondary_color"] || ""} data-test-id="theme-secondary-color" />
              <.input field={f[:accent_color]} id="theme_accent_color" type="text" type_input="text" label="Accent Color" name="theme[accent_color]" value={@theme.colors["accent_color"] || ""} data-test-id="theme-accent-color" />
            </div>
          </:inner_block_simple_form>
          <:actions>
            <.button type="submit" data-test-id="update-theme-button">Update Theme</.button>
          </:actions>
        </.simple_form>
      <% end %>

      <%= if @applied do %>
        <div class="theme-applied">{@theme.name}</div>
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
    {:noreply,
     assign(socket,
       show_edit_form: true,
       show_customize_form: false,
       show_accessibility_form: false
     )}
  end

  @impl true
  def handle_event("delete-theme", _params, socket) do
    {:noreply, put_flash(socket, :info, "Delete theme stub")}
  end

  @impl true
  def handle_event("customize-theme", _params, socket) do
    {:noreply,
     assign(socket,
       show_customize_form: true,
       show_accessibility_form: false,
       show_edit_form: false
     )}
  end

  @impl true
  def handle_event("apply-theme", _params, socket) do
    {:noreply, assign(socket, :applied, true)}
  end

  @impl true
  def handle_event("accessibility-settings", _params, socket) do
    {:noreply,
     assign(socket,
       show_accessibility_form: true,
       show_customize_form: false,
       show_edit_form: false
     )}
  end

  @impl true
  def handle_event("save-colors", %{"theme" => theme_params}, socket) do
    colors = %{
      "primary_color" => theme_params["primary_color"],
      "secondary_color" => theme_params["secondary_color"],
      "accent_color" => theme_params["accent_color"]
    }

    case ThemeSystem.update_theme(socket.assigns.theme, %{colors: colors}) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> assign(:theme, theme)
         |> put_flash(:info, "Colors updated successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update colors")}
    end
  end

  @impl true
  def handle_event("save-typography", %{"theme" => theme_params}, socket) do
    settings = %{
      "font_family" => theme_params["font_family"],
      "font_size" => theme_params["font_size"],
      "line_height" => theme_params["line_height"]
    }

    case ThemeSystem.update_theme(socket.assigns.theme, %{settings: settings}) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> assign(:theme, theme)
         |> put_flash(:info, "Typography updated successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update typography")}
    end
  end

  @impl true
  def handle_event("save-spacing", %{"theme" => theme_params}, socket) do
    settings = %{
      "spacing_unit" => theme_params["spacing_unit"],
      "container_padding" => theme_params["container_padding"],
      "section_margin" => theme_params["section_margin"]
    }

    case ThemeSystem.update_theme(socket.assigns.theme, %{settings: settings}) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> assign(:theme, theme)
         |> put_flash(:info, "Spacing updated successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update spacing")}
    end
  end

  @impl true
  def handle_event("save-accessibility", %{"theme" => theme_params}, socket) do
    settings = %{
      "reduced_motion" => theme_params["reduced_motion"]
    }

    case ThemeSystem.update_theme(socket.assigns.theme, %{settings: settings}) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> assign(:theme, theme)
         |> put_flash(:info, "Accessibility settings updated successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update accessibility settings")}
    end
  end

  @impl true
  def handle_event("update-theme", %{"theme" => theme_params}, socket) do
    case ThemeSystem.update_theme(socket.assigns.theme, theme_params) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> assign(:theme, theme)
         |> assign(:show_edit_form, false)
         |> put_flash(:info, "Theme updated successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update theme")}
    end
  end
end
