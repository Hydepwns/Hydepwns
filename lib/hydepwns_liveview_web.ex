defmodule HydepwnsLiveviewWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use HydepwnsLiveviewWeb, :controller
      use HydepwnsLiveviewWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: HydepwnsLiveviewWeb.Layouts]

      use Gettext, backend: HydepwnsLiveviewWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {HydepwnsLiveviewWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Translation
      use Gettext, backend: HydepwnsLiveviewWeb.Gettext

      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components
      import HydepwnsLiveviewWeb.CoreComponents, except: [header_table: 1, nav: 1, theme_toggle: 1]
      # Import UI components
      import HydepwnsLiveviewWeb.Components.UI.LayoutComponents
      import HydepwnsLiveviewWeb.Components.UI.DebugGrid
      import HydepwnsLiveviewWeb.Components.UI.InfoBox
      import HydepwnsLiveviewWeb.Components.UI.MonoForm
      import HydepwnsLiveviewWeb.Components.UI.MonoTabs
      # Import Theme Toggle component
      import HydepwnsLiveviewWeb.Components.ThemeToggle
      # Import Theme Preview component
      import HydepwnsLiveviewWeb.Components.ThemePreview
      # Import Nav component
      import HydepwnsLiveviewWeb.Components.UI.Nav
      
      # Import custom components
      import HydepwnsLiveviewWeb.Components.MonoGrid
      alias HydepwnsLiveviewWeb.Components.Terminal
      alias HydepwnsLiveviewWeb.Components.AsciiArtGenerator
      alias HydepwnsLiveviewWeb.Components.DiagramEditor

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())

      # Helper for setting current path
      def assign_current_path(socket) do
        assign(socket, current_path: socket.assigns.live_action |> path_for_action())
      end

      defp path_for_action(:index), do: ~p"/"
      defp path_for_action(:style_guide), do: ~p"/style-guide"
      defp path_for_action(:projects), do: ~p"/projects"
      defp path_for_action(:about), do: ~p"/about"
      defp path_for_action(_), do: nil
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: HydepwnsLiveviewWeb.Endpoint,
        router: HydepwnsLiveviewWeb.Router,
        statics: HydepwnsLiveviewWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
