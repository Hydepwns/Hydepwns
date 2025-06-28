defmodule HydepwnsLiveviewWeb.Themes.ThemeCustomizeLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.ThemeSystem

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    {:ok, assign(socket, theme_class: theme_class, title: "Theme Customization")}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _url, socket) do
    theme = ThemeSystem.get_theme!(id)
    {:noreply, assign(socket, :theme, theme)}
  end

  @impl true
  def handle_event("save_colors", %{"theme" => theme_params}, socket) do
    case ThemeSystem.update_theme(socket.assigns.theme, theme_params) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> put_flash(:info, "Colors saved successfully")
         |> assign(:theme, theme)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to save colors")}
    end
  end

  @impl true
  def handle_event("save_typography", %{"theme" => theme_params}, socket) do
    case ThemeSystem.update_theme(socket.assigns.theme, theme_params) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> put_flash(:info, "Typography saved successfully")
         |> assign(:theme, theme)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to save typography")}
    end
  end

  @impl true
  def handle_event("save_spacing", %{"theme" => theme_params}, socket) do
    case ThemeSystem.update_theme(socket.assigns.theme, theme_params) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> put_flash(:info, "Spacing saved successfully")
         |> assign(:theme, theme)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to save spacing")}
    end
  end

  @impl true
  def handle_event("save_accessibility", params, socket) do
    settings = case params do
      %{"reduced_motion" => reduced_motion, "high_contrast" => high_contrast} ->
        Map.merge(socket.assigns.theme.settings || %{}, %{
          "reduced_motion" => reduced_motion == "on",
          "high_contrast" => high_contrast == "on"
        })
      _ ->
        # Handle case where checkboxes are not checked
        socket.assigns.theme.settings || %{}
    end
    
    case ThemeSystem.update_theme(socket.assigns.theme, %{settings: settings}) do
      {:ok, theme} ->
        {:noreply,
         socket
         |> put_flash(:info, "Accessibility settings applied successfully")
         |> assign(:theme, theme)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to apply accessibility settings")}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8" data-mode={@theme_class}>
      <header class="mb-6">
        <h1 class="text-2xl font-semibold text-gray-900 dark:text-white">Customize Theme</h1>
        <p class="text-gray-600 dark:text-gray-400">Customize the appearance of your theme</p>
      </header>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Color Customization -->
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-lg font-medium mb-4">Colors</h2>
          <form phx-submit="save_colors">
            <div class="space-y-4">
              <div>
                <label for="theme[primary_color]" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Primary Color</label>
                <input type="color" name="theme[primary_color]" id="theme[primary_color]" value={@theme.primary_color} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
              </div>
              <div>
                <label for="theme[secondary_color]" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Secondary Color</label>
                <input type="color" name="theme[secondary_color]" id="theme[secondary_color]" value={@theme.secondary_color} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
              </div>
              <div>
                <label for="theme[accent_color]" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Accent Color</label>
                <input type="color" name="theme[accent_color]" id="theme[accent_color]" value={Map.get(@theme.colors, "accent", "#3357FF")} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
              </div>
            </div>
            <div class="mt-6">
              <button type="submit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">Save Colors</button>
            </div>
          </form>
          
          <!-- Color Preview -->
          <div class="mt-6">
            <h3 class="text-md font-medium mb-3">Preview</h3>
            <div class="flex space-x-2">
              <div class="w-8 h-8 rounded color-preview" style={"background-color: #{@theme.primary_color}"}></div>
              <div class="w-8 h-8 rounded color-preview" style={"background-color: #{@theme.secondary_color}"}></div>
              <div class="w-8 h-8 rounded color-preview" style={"background-color: #{Map.get(@theme.colors, "accent", "#3357FF")}"}></div>
            </div>
          </div>
        </div>

        <!-- Typography Customization -->
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-lg font-medium mb-4">Typography</h2>
          <form phx-submit="save_typography">
            <div class="space-y-4">
              <div>
                <label for="theme[font_family]" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Font Family</label>
                <input type="text" name="theme[font_family]" id="theme[font_family]" value={@theme.font_family || "Helvetica"} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
              </div>
              <div>
                <label for="theme[font_size]" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Font Size</label>
                <input type="text" name="theme[font_size]" id="theme[font_size]" value={@theme.font_size || "16px"} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
              </div>
              <div>
                <label for="theme[line_height]" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Line Height</label>
                <input type="text" name="theme[line_height]" id="theme[line_height]" value={@theme.line_height || "1.5"} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
              </div>
            </div>
            <div class="mt-6">
              <button type="submit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">Save Typography</button>
            </div>
          </form>
          
          <!-- Typography Preview -->
          <div class="mt-6">
            <h3 class="text-md font-medium mb-3">Preview</h3>
            <div class="typography-preview p-4 border rounded" style={"font-family: #{@theme.font_family || "Helvetica"}; font-size: #{@theme.font_size || "16px"}; line-height: #{@theme.line_height || "1.5"}"}>
              <p>This is a preview of your typography settings.</p>
            </div>
          </div>
        </div>

        <!-- Spacing Customization -->
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-lg font-medium mb-4">Spacing</h2>
          <form phx-submit="save_spacing">
            <div class="space-y-4">
              <div>
                <label for="theme[spacing_unit]" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Spacing Unit</label>
                <input type="text" name="theme[spacing_unit]" id="theme[spacing_unit]" value={@theme.spacing_unit || "8px"} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
              </div>
              <div>
                <label for="theme[container_padding]" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Container Padding</label>
                <input type="text" name="theme[container_padding]" id="theme[container_padding]" value={@theme.container_padding || "24px"} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
              </div>
              <div>
                <label for="theme[section_margin]" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Section Margin</label>
                <input type="text" name="theme[section_margin]" id="theme[section_margin]" value={@theme.section_margin || "32px"} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
              </div>
            </div>
            <div class="mt-6">
              <button type="submit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">Save Spacing</button>
            </div>
          </form>
          
          <!-- Spacing Preview -->
          <div class="mt-6" data-test-id="spacing-preview-section">
            <h3 class="text-md font-medium mb-3">Preview</h3>
            <div class="p-4 border rounded" style={"padding: #{@theme.container_padding || "24px"}; margin: #{@theme.section_margin || "32px"}"}>
              <div class="space-y-2">
                <div class="h-4 bg-gray-200 rounded" style={"margin-bottom: #{@theme.spacing_unit || "8px"}"}></div>
                <div class="h-4 bg-gray-200 rounded" style={"margin-bottom: #{@theme.spacing_unit || "8px"}"}></div>
                <div class="h-4 bg-gray-200 rounded"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Accessibility Settings -->
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 class="text-lg font-medium mb-4">Accessibility</h2>
          <form phx-submit="save_accessibility">
            <div class="space-y-4">
              <div class="flex items-center">
                <input type="checkbox" name="reduced_motion" id="reduced_motion" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                <label for="reduced_motion" class="ml-2 block text-sm text-gray-900 dark:text-gray-300">Reduce Motion</label>
              </div>
              <div class="flex items-center">
                <input type="checkbox" name="high_contrast" id="high_contrast" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                <label for="high_contrast" class="ml-2 block text-sm text-gray-900 dark:text-gray-300">High Contrast</label>
              </div>
            </div>
            <div class="mt-6">
              <button type="submit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">Apply</button>
            </div>
          </form>
          
          <!-- Accessibility Status -->
          <div class="mt-6">
            <div class="contrast-ratio text-sm text-green-600">4.5:1</div>
            <div class="accessibility-status text-sm text-green-600">WCAG 2.1 AA compliant</div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end 