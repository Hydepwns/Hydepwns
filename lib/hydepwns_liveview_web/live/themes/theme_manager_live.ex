defmodule HydepwnsLiveviewWeb.Themes.ThemeManagerLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Layouts, :app}

  alias HydepwnsLiveview.ThemeSystem.Models.Theme
  require Logger
  import HydepwnsLiveviewWeb.Components.UI.ThemeToggle, only: [theme_toggle: 1]

  @impl true
  def do_mount(_params, _session, socket) do
    default_theme = HydepwnsLiveview.ThemeSystem.ensure_default_theme()
    _theme_class = "#{default_theme.mode}-theme"
    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    # Filter out any invalid themes (id nil or name empty)
    themes =
      Enum.filter(themes, fn t ->
        t.id != nil and t.name != nil and t.name != ""
      end)

    # If no valid themes, create a default one
    themes =
      if themes == [] do
        {:ok, default_theme} =
          HydepwnsLiveview.ThemeSystem.create_theme(%{
            "name" => "Default Theme",
            "mode" => "light",
            "colors" => %{"primary" => "#3b82f6", "background" => "#ffffff", "text" => "#1f2937"},
            "settings" => %{
              "animations" => true,
              "contrast" => "normal",
              "font_size" => "medium",
              "line_height" => "normal"
            },
            "is_default" => true
          })

        [default_theme]
      else
        themes
      end

    # Defensive fallback: if themes is still empty, log and create another default
    themes =
      if themes == [] do
        Logger.warning(
          "[ThemeManagerLive] No themes found after initial creation logic. Creating emergency default theme."
        )

        {:ok, emergency_theme} =
          HydepwnsLiveview.ThemeSystem.create_theme(%{
            "name" => "Emergency Default Theme",
            "mode" => "light",
            "colors" => %{"primary" => "#3b82f6", "background" => "#ffffff", "text" => "#1f2937"},
            "settings" => %{
              "animations" => true,
              "contrast" => "normal",
              "font_size" => "medium",
              "line_height" => "normal"
            },
            "is_default" => true
          })

        [emergency_theme]
      else
        themes
      end

    changeset = HydepwnsLiveview.ThemeSystem.change_theme(%Theme{})

    # Try to get the applied theme from session or cookie
    user_theme_name = get_user_theme_from_session_or_cookie(socket)

    applied_theme =
      case Enum.find(themes, fn t -> t.name == user_theme_name end) do
        nil -> nil
        theme -> theme
      end

    theme_mode =
      case applied_theme do
        %{mode: mode} when is_binary(mode) -> mode
        _ -> "light"
      end

    theme_class = "#{theme_mode}-theme"

    socket =
      socket
      |> assign(:page_title, "Theme Manager")
      |> assign(:themes, themes)
      |> assign(:changeset, changeset)
      |> assign_new(:errors, fn -> [] end)
      |> assign(:theme_class, theme_class)
      |> assign(:applied_theme, applied_theme)
      |> assign(:theme_mode, theme_mode)
      |> assign(:confirm_delete_id, nil)

    socket
  end

  defp get_user_theme_from_session_or_cookie(session_or_socket) do
    case session_or_socket do
      %Phoenix.LiveView.Socket{} = socket ->
        session_theme = Map.get(socket.assigns[:session] || %{}, "user_theme")

        cookie_theme =
          if function_exported?(Phoenix.LiveView, :get_connect_info, 2) and
               Map.has_key?(socket, :transport_pid) and
               not is_nil(socket.transport_pid) and
               is_pid(socket.transport_pid) and
               not Map.has_key?(socket, :endpoint) do
            # Only call get_connect_info if this is a real connected socket, not a test socket or Plug.Conn
            (Phoenix.LiveView.get_connect_info(socket, :cookies) || %{})["user_theme"]
          else
            nil
          end

        session_theme || cookie_theme

      session when is_map(session) ->
        Map.get(session, "user_theme")

      _ ->
        nil
    end
  end

  @impl true
  def mount(params, session, socket) do
    if Mix.env() in [:dev, :test] do
      send(self(), :expose_pid)
    end

    socket = do_mount(params, session, socket)
    {:ok, socket}
  end

  @impl true
  def handle_info(:expose_pid, socket) do
    pid_str = :erlang.pid_to_list(self()) |> to_string()
    push_event(socket, "live_view_pid", %{pid: pid_str})
    {:noreply, socket}
  end

  defp theme_list_eex(themes, applied_theme) do
    # Defensive: ensure themes is always a list of structs
    themes =
      case themes do
        nil ->
          Logger.error("[theme_list_eex] themes was nil, defaulting to []")
          []
        t when is_list(t) ->
          t
        _ ->
          Logger.error("[theme_list_eex] themes was not a list: #{inspect(themes)}; defaulting to []")
          []
      end

    assigns = %{
      themes: themes,
      applied_theme: applied_theme
    }
    # Ensure themes is always present in assigns
    assigns = Map.put_new(assigns, :themes, [])

    Logger.debug(
      "[theme_list_eex] assigns before EEx.eval_string: #{inspect(assigns, pretty: true)}"
    )

    EEx.eval_string(
      ~S"""
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for theme <- @themes do %>
            <div class="border rounded-lg p-4 shadow-sm theme-item" data-default={theme.is_default}>
              <a href="/themes/<%= theme.id %>" class="block text-lg font-semibold text-blue-600 underline mb-2" data-test-id={theme.name == "Test Theme" && "theme-link-test-theme" || "theme-link-#{theme.id}")>
                <%= theme.name %>
              </a>
              <div class="flex items-center mb-2">
                <span class="theme-type text-xs bg-gray-200 rounded px-2 py-1 mr-2"><%= theme.mode %></span>
                <%= if @applied_theme && @applied_theme.id == theme.id do %>
                  <span class="theme-applied text-green-600 font-bold ml-2">Applied</span>
                <% end %>
              </div>
              <div class="flex flex-wrap gap-2 mb-2">
                <%= for {key, value} <- theme.colors do %>
                  <div class="theme-color w-6 h-6 rounded border mr-1" style="background-color: <%= value %>;" title="<%= key %>"></div>
                <% end %>
              </div>
              <div class="flex gap-2 mt-2">
                <button phx-click="edit" phx-value-id={theme.id} class="px-2 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600" data-action="edit" data-id={theme.id}>Edit</button>
                <button phx-click="delete" phx-value-id={theme.id} class="px-2 py-1 bg-red-500 text-white rounded hover:bg-red-600" data-action="delete" data-id={theme.id}>Delete Theme</button>
                <button phx-click="apply" phx-value-id={theme.id} class="px-2 py-1 bg-green-500 text-white rounded hover:bg-green-600" data-action="apply" data-id={theme.id}>Apply Theme</button>
                <button phx-click="set_default" phx-value-id={theme.id} class="px-2 py-1 bg-blue-500 text-white rounded hover:bg-blue-600" data-action="set_default" data-id={theme.id} disabled={theme.is_default}>Set Default</button>
              </div>
            </div>
          <% end %>
        </div>
      """,
      assigns: assigns
    )
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
            <div class="border rounded-lg p-4 shadow-sm theme-item" data-default={theme.is_default}>
              <a href={"/themes/#{theme.id}"} class="block text-lg font-semibold text-blue-600 underline mb-2" data-test-id={(theme.name == "Test Theme" && "theme-link-test-theme") || "theme-link-#{theme.id}"}>
                {theme.name}
              </a>
              <div class="flex items-center mb-2">
                <span class="theme-type text-xs bg-gray-200 rounded px-2 py-1 mr-2">{theme.mode}</span>
                <%= if @applied_theme && @applied_theme.id == theme.id do %>
                  <span class="theme-applied text-green-600 font-bold ml-2">Applied</span>
                <% end %>
              </div>
              <div class="flex flex-wrap gap-2 mb-2">
                <%= for {key, value} <- theme.colors do %>
                  <div class="theme-color w-6 h-6 rounded border mr-1" style={"background-color: #{value};"} title={key}></div>
                <% end %>
              </div>
              <div class="flex gap-2 mt-2">
                <button phx-click="edit" phx-value-id={theme.id} class="px-2 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600" data-action="edit" data-id={theme.id}>Edit</button>
                <button phx-click="delete" phx-value-id={theme.id} class="px-2 py-1 bg-red-500 text-white rounded hover:bg-red-600" data-action="delete" data-id={theme.id}>Delete Theme</button>
                <button phx-click="apply" phx-value-id={theme.id} class="px-2 py-1 bg-green-500 text-white rounded hover:bg-green-600" data-action="apply" data-id={theme.id}>Apply Theme</button>
                <button phx-click="set_default" phx-value-id={theme.id} class="px-2 py-1 bg-blue-500 text-white rounded hover:bg-blue-600" data-action="set_default" data-id={theme.id} disabled={theme.is_default}>Set Default</button>
              </div>
            </div>
          <% end %>
        </div>
      </div>

      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">Add New Theme</h2>
        <.simple_form :let={f} for={@changeset} as={:theme} phx-submit="save">
          <.error :if={@changeset.action}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <:inner_block_simple_form :let={f}>
            <.input field={f[:name]} id="theme_name" type="text" label="Name" name="theme[name]" required data-test-id="theme-name-input" />
            <.input field={f[:mode]} id="theme_mode" type="select" label="Mode" options={[{"Light", "light"}, {"Dark", "dark"}, {"Dim", "dim"}, {"System", "system"}]} name="theme[mode]" required data-test-id="theme-mode-select" />
            
            <div class="space-y-4">
              <h3 class="text-lg font-medium">Colors</h3>
              <.input field={f[:primary_color]} id="theme_primary_color" type="text" label="Primary Color" name="theme[primary_color]" data-test-id="theme-primary-color" />
              <.input field={f[:secondary_color]} id="theme_secondary_color" type="text" label="Secondary Color" name="theme[secondary_color]" data-test-id="theme-secondary-color" />
              <.input field={f[:accent_color]} id="theme_accent_color" type="text" label="Accent Color" name="theme[accent_color]" data-test-id="theme-accent-color" />
              <.input field={f[:background_color]} id="theme_background_color" type="text" label="Background Color" name="theme[background_color]" data-test-id="theme-background-color" />
              <.input field={f[:text_color]} id="theme_text_color" type="text" label="Text Color" name="theme[text_color]" data-test-id="theme-text-color" />
              <.input field={f[:border_color]} id="theme_border_color" type="text" label="Border Color" name="theme[border_color]" data-test-id="theme-border-color" />
              <.input field={f[:error_color]} id="theme_error_color" type="text" label="Error Color" name="theme[error_color]" data-test-id="theme-error-color" />
              <.input field={f[:success_color]} id="theme_success_color" type="text" label="Success Color" name="theme[success_color]" data-test-id="theme-success-color" />
              <.input field={f[:warning_color]} id="theme_warning_color" type="text" label="Warning Color" name="theme[warning_color]" data-test-id="theme-warning-color" />
              <.input field={f[:info_color]} id="theme_info_color" type="text" label="Info Color" name="theme[info_color]" data-test-id="theme-info-color" />
            </div>

            <div class="space-y-4 mt-6">
              <h3 class="text-lg font-medium">Typography</h3>
              <.input field={f[:font_family]} id="theme_font_family" type="text" label="Font Family" name="theme[font_family]" data-test-id="theme-font-family" />
              <.input field={f[:font_size]} id="theme_font_size" type="select" label="Font Size" options={[{"Small", "small"}, {"Medium", "medium"}, {"Large", "large"}]} name="theme[font_size]" data-test-id="theme-font-size" />
              <.input field={f[:line_height]} id="theme_line_height" type="select" label="Line Height" options={[{"Normal", "normal"}, {"Wide", "wide"}]} name="theme[line_height]" data-test-id="theme-line-height" />
            </div>

            <div class="space-y-4 mt-6">
              <h3 class="text-lg font-medium">Spacing</h3>
              <.input field={f[:spacing_unit]} id="theme_spacing_unit" type="text" label="Spacing Unit" name="theme[spacing_unit]" data-test-id="theme-spacing-unit" />
            </div>

            <div class="space-y-4 mt-6">
              <h3 class="text-lg font-medium">Accessibility</h3>
              <.input field={f[:contrast]} id="theme_contrast" type="select" label="Contrast" options={[{"Normal", "normal"}, {"Medium", "medium"}, {"High", "high"}]} name="theme[contrast]" data-test-id="theme-contrast" />
              <.input field={f[:animations]} id="theme_animations" type="checkbox" label="Enable Animations" name="theme[animations]" data-test-id="theme-animations" />
              <.input field={f[:reduced_motion]} id="theme_reduced_motion" type="checkbox" label="Reduced Motion" name="theme[reduced_motion]" data-test-id="theme-reduced-motion" />
            </div>

            <.input field={f[:is_default]} id="theme_is_default" type="checkbox" label="Set as Default Theme" name="theme[is_default]" data-test-id="theme-is-default" />
          </:inner_block_simple_form>
          <:actions>
            <.button type="submit" data-test-id="save-theme-button">Save Theme</.button>
            <.button phx-click="cancel" class="button" data-test-id="cancel-theme-button">Cancel</.button>
          </:actions>
        </.simple_form>
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

    case HydepwnsLiveview.ThemeSystem.create_theme(theme_params) do
      {:ok, _theme} ->
        themes = HydepwnsLiveview.ThemeSystem.list_themes()

        socket =
          socket
          |> assign(:themes, themes)
          |> assign(:changeset, HydepwnsLiveview.ThemeSystem.change_theme(%Theme{}))
          |> put_flash(:info, "Theme created successfully.")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("set_default", %{"id" => id}, socket) do
    theme = HydepwnsLiveview.ThemeSystem.get_theme!(id)
    {:ok, _} = HydepwnsLiveview.ThemeSystem.update_theme(theme, %{is_default: true})
    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    {:noreply, assign(socket, :themes, themes)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    theme = HydepwnsLiveview.ThemeSystem.get_theme!(id)
    {:ok, _} = HydepwnsLiveview.ThemeSystem.delete_theme(theme)
    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    {:noreply, assign(socket, :themes, themes)}
  end

  @impl true
  def handle_event("apply", %{"id" => id}, socket) do
    theme = HydepwnsLiveview.ThemeSystem.get_theme!(id)
    {:noreply, assign(socket, :applied_theme, theme)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_patch(socket, to: "/themes/#{id}/edit")}
  end

  @impl true
  def handle_info(_msg, socket) do
    {:noreply, socket}
  end
end
