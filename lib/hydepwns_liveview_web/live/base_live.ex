defmodule HydepwnsLiveviewWeb.BaseLive do
  @moduledoc """
  Base LiveView module that provides common functionality for all LiveViews.
  """

  use HydepwnsLiveviewWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = HydepwnsLiveview.ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    {:ok, assign(socket, theme_class: theme_class)}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class={@theme_class}>
      <%= @inner_content %>
    </div>
    """
  end

  defmacro __using__(_opts) do
    quote do
      use HydepwnsLiveviewWeb, :live_view

      import Phoenix.LiveView
      import Phoenix.Component
      import Phoenix.LiveView.Helpers
      import Phoenix.LiveView.Router
      import Phoenix.VerifiedRoutes

      @impl Phoenix.LiveView
      def mount(params, session, socket) do
        socket = do_mount(params, session, socket)
        {:ok, socket}
      end

      @impl Phoenix.LiveView
      def handle_params(params, uri, socket) do
        socket = do_handle_params(params, uri, socket)
        {:noreply, socket}
      end

      @impl Phoenix.LiveView
      def handle_event(event, params, socket) do
        socket = do_handle_event(event, params, socket)
        {:noreply, socket}
      end

      # Default implementations that can be overridden
      def do_mount(_params, _session, socket), do: socket
      def do_handle_params(_params, _uri, socket), do: socket
      def do_handle_event(_event, _params, socket), do: socket

      def get_resource(socket, key), do: Map.get(socket.assigns, key)
      def update_resource(socket, key, value), do: {:ok, assign(socket, key, value)}

      defoverridable do_mount: 3,
                     do_handle_params: 3,
                     do_handle_event: 3,
                     get_resource: 2,
                     update_resource: 3
    end
  end

  def on_mount(:default, _params, _session, socket) do
    {:cont, socket}
  end

  def on_mount(:require_authenticated_user, _params, session, socket) do
    case session do
      %{"user_token" => user_token} ->
        {:cont, assign(socket, :current_user, user_token)}

      _ ->
        {:halt, redirect(socket, to: ~p"/users/log_in")}
    end
  end

  def on_mount(:require_admin_user, _params, session, socket) do
    case session do
      %{"user_token" => user_token} ->
        if user_token.admin do
          {:cont, assign(socket, :current_user, user_token)}
        else
          {:halt, redirect(socket, to: ~p"/")}
        end

      _ ->
        {:halt, redirect(socket, to: ~p"/users/log_in")}
    end
  end

  def on_mount(:require_theme, _params, _session, socket) do
    case HydepwnsLiveview.ThemeSystem.get_current_theme() do
      {:ok, theme} ->
        {:cont, assign(socket, :current_theme, theme)}

      {:error, _} ->
        {:halt, redirect(socket, to: ~p"/themes/new")}
    end
  end

  def on_mount(:require_resource, _params, _session, socket) do
    case HydepwnsLiveview.ResourceSystem.get_current_resource() do
      {:ok, resource} ->
        {:cont, assign(socket, :current_resource, resource)}

      {:error, _} ->
        {:halt, redirect(socket, to: ~p"/resources/new")}
    end
  end

  def on_mount(:require_bridge, _params, _session, socket) do
    case HydepwnsLiveview.Bridge.get_current_bridge() do
      {:ok, bridge} ->
        {:cont, assign(socket, :current_bridge, bridge)}

      {:error, _} ->
        {:halt, redirect(socket, to: ~p"/bridges/new")}
    end
  end

  def on_mount(:require_theme_and_resource, _params, _session, socket) do
    with {:ok, theme} <- HydepwnsLiveview.ThemeSystem.get_current_theme(),
         {:ok, resource} <- HydepwnsLiveview.ResourceSystem.get_current_resource() do
      {:cont, assign(socket, current_theme: theme, current_resource: resource)}
    else
      _ ->
        {:halt, redirect(socket, to: ~p"/themes/new")}
    end
  end

  def on_mount(:require_theme_and_bridge, _params, _session, socket) do
    with {:ok, theme} <- HydepwnsLiveview.ThemeSystem.get_current_theme(),
         {:ok, bridge} <- HydepwnsLiveview.Bridge.get_current_bridge() do
      {:cont, assign(socket, current_theme: theme, current_bridge: bridge)}
    else
      _ ->
        {:halt, redirect(socket, to: ~p"/themes/new")}
    end
  end

  def on_mount(:require_resource_and_bridge, _params, _session, socket) do
    with {:ok, resource} <- HydepwnsLiveview.ResourceSystem.get_current_resource(),
         {:ok, bridge} <- HydepwnsLiveview.Bridge.get_current_bridge() do
      {:cont, assign(socket, current_resource: resource, current_bridge: bridge)}
    else
      _ ->
        {:halt, redirect(socket, to: ~p"/resources/new")}
    end
  end

  def on_mount(:require_all, _params, _session, socket) do
    with {:ok, theme} <- HydepwnsLiveview.ThemeSystem.get_current_theme(),
         {:ok, resource} <- HydepwnsLiveview.ResourceSystem.get_current_resource(),
         {:ok, bridge} <- HydepwnsLiveview.Bridge.get_current_bridge() do
      {:cont,
       assign(socket, current_theme: theme, current_resource: resource, current_bridge: bridge)}
    else
      _ ->
        {:halt, redirect(socket, to: ~p"/themes/new")}
    end
  end
end
