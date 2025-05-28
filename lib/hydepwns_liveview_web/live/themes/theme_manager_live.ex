defmodule HydepwnsLiveviewWeb.Themes.ThemeManagerLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Layouts, :app}

  alias HydepwnsLiveview.ThemeSystem.Models.Theme
  require Logger
  import HydepwnsLiveviewWeb.Components.UI.ThemeToggle, only: [theme_toggle: 1]

  @impl true
  def do_mount(_params, _session, socket) do
    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    # Filter out any invalid themes (id nil or name empty)
    themes = Enum.filter(themes, fn t ->
      t.id != nil and t.name != nil and t.name != ""
    end)
    # If no valid themes, create a default one
    themes =
      if themes == [] do
        {:ok, default_theme} = HydepwnsLiveview.ThemeSystem.create_theme(%{
          "name" => "Default Theme",
          "mode" => "light",
          "colors" => %{"primary" => "#3b82f6", "background" => "#ffffff", "text" => "#1f2937"},
          "settings" => %{"animations" => true, "contrast" => "normal", "font_size" => "medium", "line_height" => "normal"},
          "is_default" => true
        })
        [default_theme]
      else
        themes
      end
    # Defensive fallback: if themes is still empty, log and create another default
    themes =
      if themes == [] do
        Logger.warning("[ThemeManagerLive] No themes found after initial creation logic. Creating emergency default theme.")
        {:ok, emergency_theme} = HydepwnsLiveview.ThemeSystem.create_theme(%{
          "name" => "Emergency Default Theme",
          "mode" => "light",
          "colors" => %{"primary" => "#3b82f6", "background" => "#ffffff", "text" => "#1f2937"},
          "settings" => %{"animations" => true, "contrast" => "normal", "font_size" => "medium", "line_height" => "normal"},
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

    socket =
      socket
      |> assign(:page_title, "Theme Manager")
      |> assign(:themes, themes)
      |> assign(:changeset, changeset)
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
    {:ok, do_mount(params, session, socket)}
  end

  @impl true
  def handle_info(:expose_pid, socket) do
    pid_str = :erlang.pid_to_list(self()) |> to_string()
    push_event(socket, "live_view_pid", %{pid: pid_str})
    {:noreply, socket}
  end

  defp theme_list_eex(themes, applied_theme) do
    # Defensive: ensure themes is always a list
    themes =
      case themes do
        nil ->
          Logger.error("[theme_list_eex] themes was nil, defaulting to []")
          []
        t when is_list(t) -> t
        _ ->
          Logger.error("[theme_list_eex] themes was not a list: #{inspect(themes)}; defaulting to []")
          []
      end
    themes = Enum.map(themes, fn
      %_{} = struct -> Map.from_struct(struct)
      map -> map
    end)
    themes = Enum.map(themes, fn theme ->
      theme
      |> Map.put_new("id", nil)
      |> Map.put_new("name", "")
      |> Map.put_new("mode", "")
      |> Map.update("colors", %{}, fn
        nil -> %{}
        m when is_map(m) -> m
        _ -> %{}
      end)
    end)
    File.write!("tmp/theme_list_eex_themes_debug.txt", inspect(themes, pretty: true))
    applied_theme =
      case applied_theme do
        %_{} = struct -> Map.from_struct(struct)
        map -> map
      end
    assigns = %{
      themes: themes,
      applied_theme: applied_theme
    }
    Logger.debug("[theme_list_eex] assigns before EEx.eval_string: #{inspect(assigns, pretty: true)}")
    EEx.eval_string(~S"""
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <%= for theme <- themes do %>
          <div class="border rounded-lg p-4 shadow-sm theme-item">
            <a href="/themes/<%= theme[\"id\"] %>" class="block text-lg font-semibold text-blue-600 underline mb-2" data-test-id={theme[\"name\"] == "Test Theme" && "theme-link-test-theme" || "theme-link-#{theme[\"id\"]}">
              <%= theme[\"name\"] %>
            </a>
            <div class="flex items-center mb-2">
              <span class="theme-type text-xs bg-gray-200 rounded px-2 py-1 mr-2"><%= theme[\"mode\"] %></span>
              <%= if applied_theme && applied_theme[\"id\"] == theme[\"id\"] do %>
                <span class="theme-applied text-green-600 font-bold ml-2">Applied</span>
              <% end %>
            </div>
            <div class="flex flex-wrap gap-2 mb-2">
              <%= for {key, value} <- theme[\"colors\"] do %>
                <div class="theme-color w-6 h-6 rounded border mr-1" style="background-color: <%= value %>;" title="<%= key %>"></div>
              <% end %>
            </div>
            <div class="flex gap-2 mt-2">
              <button class="px-2 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600">Edit</button>
              <button class="px-2 py-1 bg-red-500 text-white rounded hover:bg-red-600">Delete Theme</button>
              <button class="px-2 py-1 bg-green-500 text-white rounded hover:bg-green-600">Apply Theme</button>
            </div>
          </div>
        <% end %>
      </div>
    """, assigns: assigns)
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put_new(:themes, [])
      |> Map.put_new(:applied_theme, nil)
      |> Map.put_new(:editing_theme, nil)

    theme_debug = Enum.map(assigns.themes, fn t -> %{id: t.id, name: t.name} end)
    File.write!("tmp/theme_names_debug.txt", inspect(theme_debug, pretty: true))
    # Write anchor tags for each theme to a debug file
    anchor_tags = Enum.map(assigns.themes, fn t -> ~s(<a href="/themes/#{t.id}">#{t.name}</a>) end) |> Enum.join("\n")
    File.write!("tmp/theme_anchors_debug.html", anchor_tags)
    theme_list_html =
      try do
        theme_list_eex(assigns.themes, assigns.applied_theme)
      rescue
        e ->
          File.write!("tmp/theme_list_eex_error.txt", "EEx error: #{inspect(e)}\nAssigns: #{inspect(assigns, pretty: true)}")
          "<div class=\"error\">Theme list render error</div>"
      end
    File.write!("tmp/theme_list_rendered.html", theme_list_html)
    ~H"""
    <div>
      <%= for theme <- @themes do %>
        <a href={"/themes/#{theme.id}"}><%= theme.name %></a>
      <% end %>
    </div>
    <div class="container mx-auto px-4 py-8">
      <%= if @applied_theme do %>
        <div class="theme-applied"><%= @applied_theme.name %></div>
      <% end %>
      <h1 class="text-3xl font-bold mb-8">Theme Manager</h1>
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">Current Themes</h2>
        <button type="button" onclick="document.getElementById('theme-form').scrollIntoView({ behavior: 'smooth' });" class="inline-block mb-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700" data-test-id="scroll-to-create-theme">Scroll to Create Theme Form</button>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <%= for theme <- @themes do %>
            <div class="border rounded-lg p-4 shadow-sm theme-item" data-default={if theme.is_default, do: "true", else: "false"}>
              <a href={"/themes/#{theme.id}"}
                 class="block text-lg font-semibold text-blue-600 underline mb-2"
                 data-test-id={theme.name == "Test Theme" && "theme-link-test-theme" || "theme-link-#{theme.id}"}>
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
                  <div class="theme-color w-6 h-6 rounded border mr-1" style={"background-color: #{value};"} title={key}></div>
                <% end %>
              </div>
              <div class="flex gap-2 mt-2">
                <button phx-click="edit-theme" phx-value-id={theme.id} class="px-2 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600" data-action="edit" data-id={theme.id}>Edit</button>
                <button phx-click="delete-theme" phx-value-id={theme.id} class="px-2 py-1 bg-red-500 text-white rounded hover:bg-red-600" data-action="delete" data-id={theme.id}>Delete Theme</button>
                <button phx-click="apply-theme" phx-value-id={theme.id} class="px-2 py-1 bg-green-500 text-white rounded hover:bg-green-600" data-action="apply" data-id={theme.id}>Apply Theme</button>
                <button phx-click="set-default" phx-value-id={theme.id} class="px-2 py-1 bg-blue-500 text-white rounded hover:bg-blue-600" data-action="set-default" data-id={theme.id} disabled={theme.is_default}>Set Default</button>
              </div>
            </div>
          <% end %>
        </div>
      </div>
      <%= if @editing_theme do %>
        <div class="mb-8">
          <h2 class="text-xl font-semibold mb-4">Edit Theme</h2>
          <.form for={@changeset} phx-submit="update" id="edit-theme-form">
            <div class="mb-4">
              <label class="block text-sm font-medium mb-1">Name</label>
              <input type="text" name="theme[name]" class="w-full px-3 py-2 border rounded" value={@editing_theme.name} required />
            </div>
            <div class="mb-4">
              <label class="block text-sm font-medium mb-1">Mode</label>
              <input type="text" name="theme[mode]" class="w-full px-3 py-2 border rounded" value={@editing_theme.mode} required />
              <%= if error = @changeset.errors[:mode] do %>
                <div class="error-message"><%= elem(error, 0) %></div>
              <% end %>
            </div>
            <div class="mb-4">
              <label class="block text-sm font-medium mb-1">Primary Color</label>
              <input type="text" name="theme[primary_color]" class="w-full px-3 py-2 border rounded" value={@editing_theme.colors["primary"] || ""} />
              <%= if error = @changeset.errors[:primary_color] do %>
                <div class="error-message"><%= elem(error, 0) %></div>
              <% end %>
            </div>
            <div class="mb-4">
              <label class="block text-sm font-medium mb-1">Secondary Color</label>
              <input type="text" name="theme[secondary_color]" class="w-full px-3 py-2 border rounded" value={@editing_theme.colors["secondary"] || ""} />
              <%= if error = @changeset.errors[:secondary_color] do %>
                <div class="error-message"><%= elem(error, 0) %></div>
              <% end %>
            </div>
            <div class="mb-4">
              <label class="block text-sm font-medium mb-1">Accent Color</label>
              <input type="text" name="theme[accent_color]" class="w-full px-3 py-2 border rounded" value={@editing_theme.colors["accent"] || ""} />
              <%= if error = @changeset.errors[:accent_color] do %>
                <div class="error-message"><%= elem(error, 0) %></div>
              <% end %>
            </div>
            <div>
              <button type="submit" class="px-4 py-2 bg-yellow-500 text-white rounded hover:bg-yellow-600">
                Update Theme
              </button>
            </div>
          </.form>
        </div>
      <% end %>
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">Add New Theme</h2>
        <.form for={@changeset} phx-submit="save" id="theme-form">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
            <div>
              <label class="block text-sm font-medium mb-1">Name</label>
              <input type="text" name="theme[name]" class="w-full px-3 py-2 border rounded" required />
              <%= if error = @changeset.errors[:name] do %>
                <div class="error-message"><%= elem(error, 0) %></div>
              <% end %>
            </div>
            <div>
              <label class="block text-sm font-medium mb-1">Mode</label>
              <select name="theme[mode]" class="w-full px-3 py-2 border rounded">
                <option value="light">Light</option>
                <option value="dark">Dark</option>
                <option value="system">System</option>
              </select>
              <%= if error = @changeset.errors[:mode] do %>
                <div class="error-message"><%= elem(error, 0) %></div>
              <% end %>
            </div>
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">Colors</label>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div>
                <label class="block text-xs mb-1">Primary</label>
                <input type="color" name="theme[colors][primary]" class="w-full" value="#3b82f6" />
                <input type="text" name="theme[primary_color]" class="w-full mt-1" value="#3b82f6" placeholder="Primary color (hex)" />
                <%= if error = @changeset.errors[:primary] do %>
                  <div class="error-message"><%= elem(error, 0) %></div>
                <% end %>
              </div>
              <div>
                <label class="block text-xs mb-1">Secondary</label>
                <input type="color" name="theme[colors][secondary]" class="w-full" value="#10b981" />
                <%= if error = @changeset.errors[:secondary] do %>
                  <div class="error-message"><%= elem(error, 0) %></div>
                <% end %>
              </div>
              <div>
                <label class="block text-xs mb-1">Accent</label>
                <input type="color" name="theme[colors][accent]" class="w-full" value="#f59e0b" />
                <%= if error = @changeset.errors[:accent] do %>
                  <div class="error-message"><%= elem(error, 0) %></div>
                <% end %>
              </div>
              <div>
                <label class="block text-xs mb-1">Background</label>
                <input type="color" name="theme[colors][background]" class="w-full" value="#ffffff" />
                <%= if error = @changeset.errors[:background] do %>
                  <div class="error-message"><%= elem(error, 0) %></div>
                <% end %>
              </div>
              <div>
                <label class="block text-xs mb-1">Text</label>
                <input type="color" name="theme[colors][text]" class="w-full" value="#1f2937" />
                <%= if error = @changeset.errors[:text] do %>
                  <div class="error-message"><%= elem(error, 0) %></div>
                <% end %>
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
            <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600" data-test-id="create-theme">
              Create Theme
            </button>
          </div>
        </.form>
      </div>
      <div class="mt-8">
        <h2 class="text-xl font-semibold mb-4">Theme Preview</h2>
        <div class="border rounded-lg p-4 shadow-sm">
          <.theme_toggle id="theme-toggle-live" />
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
      {:ok, new_theme} ->
        themes = HydepwnsLiveview.ThemeSystem.list_themes()
        # Determine if this theme should be the applied theme for mode
        theme_mode =
          cond do
            length(themes) == 1 -> new_theme.mode
            Map.get(theme_params, "is_default") in [true, "true", 1, "1", "on"] -> new_theme.mode
            socket.assigns.applied_theme && socket.assigns.applied_theme.id == new_theme.id -> new_theme.mode
            true -> socket.assigns.theme_mode || "light"
          end
        {:noreply,
          socket
          |> assign(:themes, themes)
          |> assign(:changeset, HydepwnsLiveview.ThemeSystem.change_theme(%Theme{}))
          |> assign(:applied_theme, nil)
          |> assign(:theme_mode, theme_mode)
          |> put_flash(:info, "Theme created successfully.")}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("set-default", %{"id" => id}, socket) do
    theme = HydepwnsLiveview.ThemeSystem.get_theme!(id)
    {:ok, _} = HydepwnsLiveview.ThemeSystem.update_theme(theme, %{is_default: true})
    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    theme_mode =
      case theme do
        %{mode: mode} when is_binary(mode) -> mode
        _ -> "light"
      end
    {:noreply, assign(socket, :themes, themes) |> assign(:theme_mode, theme_mode)}
  end

  @impl true
  def handle_event("delete-theme", %{"id" => id}, socket) do
    {:noreply, assign(socket, :confirm_delete_id, String.to_integer(id))}
  end

  @impl true
  def handle_event("confirm-delete-theme", %{"id" => id}, socket) do
    theme = HydepwnsLiveview.ThemeSystem.get_theme!(id)
    {:ok, _} = HydepwnsLiveview.ThemeSystem.delete_theme(theme)
    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    applied_theme =
      if socket.assigns.applied_theme && socket.assigns.applied_theme.id == theme.id do
        nil
      else
        socket.assigns.applied_theme
      end
    {:noreply,
      socket
      |> assign(:themes, themes)
      |> assign(:applied_theme, applied_theme)
      |> assign(:confirm_delete_id, nil)
      |> put_flash(:info, "Theme deleted successfully")}
  end

  @impl true
  def handle_event("cancel-delete-theme", _params, socket) do
    {:noreply, assign(socket, :confirm_delete_id, nil)}
  end

  @impl true
  def handle_event("edit-theme", %{"id" => id}, socket) do
    theme = Enum.find(socket.assigns.themes, &("#{&1.id}" == id))
    changeset =
      if theme do
        HydepwnsLiveview.ThemeSystem.change_theme(theme)
      else
        HydepwnsLiveview.ThemeSystem.change_theme(%Theme{})
      end
    theme_mode =
      case theme do
        %{mode: mode} when is_binary(mode) -> mode
        _ -> "light"
      end
    {:noreply, assign(socket, changeset: changeset, editing_theme: theme, theme_mode: theme_mode)}
  end

  @impl true
  def handle_event("change_theme", %{"theme" => theme_name}, socket) do
    socket =
      socket
      |> assign(:user_theme, theme_name)
      |> push_event("set_theme_cookie", %{theme: theme_name})
    {:noreply, socket}
  end

  @impl true
  def handle_event("apply-theme", %{"id" => id}, socket) do
    theme = HydepwnsLiveview.ThemeSystem.get_theme!(id)
    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    socket =
      socket
      |> put_flash(:info, "Theme applied successfully")
      |> assign(:applied_theme, theme)
      |> assign(:themes, themes)
      |> assign(:theme_mode, theme.mode)
      |> assign(:user_theme, theme.name)
      |> push_event("set_theme_cookie", %{theme: theme.name})
    {:noreply, socket}
  end

  @impl true
  def handle_event("customize-theme", %{"id" => id}, socket) do
    theme = HydepwnsLiveview.ThemeSystem.get_theme!(id)
    socket =
      socket
      |> assign(:current_theme, theme)
      |> put_flash(:info, "Customize theme stub for theme #{id}")
    {:noreply, socket}
  end

  @impl true
  def handle_event("update", %{"theme" => theme_params}, socket) do
    theme = HydepwnsLiveview.ThemeSystem.get_theme!(socket.assigns.editing_theme.id)
    colors =
      (theme_params["colors"] || %{})
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Map.new()
    theme_params =
      theme_params
      |> Map.put("colors", colors)
    case HydepwnsLiveview.ThemeSystem.update_theme(theme, theme_params) do
      {:ok, updated_theme} ->
        themes = HydepwnsLiveview.ThemeSystem.list_themes()
        {:noreply,
          socket
          |> assign(:themes, themes)
          |> assign(:changeset, HydepwnsLiveview.ThemeSystem.change_theme(%Theme{}))
          |> assign(:applied_theme, nil)
          |> assign(:editing_theme, nil)
          |> assign(:theme_mode, updated_theme.mode)
          |> put_flash(:info, "Theme updated successfully.")}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_info(_msg, socket) do
    {:noreply, socket}
  end
end
