defmodule HydepwnsLiveviewWeb.ApiDocsLive do
  use HydepwnsLiveviewWeb.BaseLive, layout: {HydepwnsLiveviewWeb.Layouts, :app}
  import Phoenix.Component

  alias HydepwnsLiveviewWeb.Components.Documentation.ApiDocs
  import ApiDocs
  alias HydepwnsLiveviewWeb.Helpers.PathHelper

  @behaviour Phoenix.LiveView

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = HydepwnsLiveview.ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    socket
    |> PathHelper.assign_specific_path("/api-docs")
    |> assign(:page_title, "API Documentation")
    |> assign(:theme_class, theme_class)
    |> assign(:show_toc, true)
    |> assign(:toc_items, [
      {"intro", "Introduction"},
      {"grid-components", "Grid Components"},
      {"ascii-art-components", "ASCII Art Components"},
      {"ui-components", "UI Components"},
      {"theme-components", "Theme Components"}
    ])
    |> assign(:docs, load_docs())

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, PathHelper.assign_specific_path(socket, "/api-docs")}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <section>
      <h2>Component API Documentation</h2>

      <div id="intro" class="docs-section">
        <h3>Introduction</h3>
        <p>
          This page provides comprehensive API documentation for all components in the Hydepwns component library.
          Each component's documentation includes usage examples, available attributes, slots, and additional notes.
        </p>
        <p>
          The components are organized into categories based on their functionality. Use the table of contents
          to navigate to the specific component you're interested in.
        </p>
      </div>

      <.api_docs_section id="grid-components" title="Grid Components">
        <.api_docs
          component_name="MonoGrid"
          description="A grid system component that maintains proper character alignment for monospace text."
          import_statement="alias HydepwnsLiveviewWeb.Components.MonoGrid"
          attributes={[
            %{name: "id", type: "string", default: nil, description: "Optional unique identifier"},
            %{
              name: "cols",
              type: "integer",
              default: "80",
              description: "Number of columns in the grid"
            }
          ]}
        />
      </.api_docs_section>

      <.api_docs_section id="ascii-art-components" title="ASCII Art Components">
        <.api_docs
          component_name="AsciiArtGenerator"
          description="A component for generating ASCII art with various templates and customization options."
          import_statement="alias HydepwnsLiveviewWeb.Components.AsciiArtGenerator"
          attributes={[
            %{
              name: "id",
              type: "string",
              required: true,
              description: "Unique identifier for this component instance"
            },
            %{
              name: "art_type",
              type: "string",
              default: "box",
              description: "Type of ASCII art to generate"
            }
          ]}
        />
      </.api_docs_section>

      <.api_docs_section id="theme-components" title="Theme Components">
        <.api_docs component_name="ThemeToggle" description="A theme toggle component for switching between light, dark, dim, and high-contrast themes." import_statement="alias HydepwnsLiveviewWeb.Components.ThemeToggle" attributes={[]} />
      </.api_docs_section>

      <.api_docs_section id="ui-components" title="UI Components">
        <.api_docs
          component_name="MonoTabs"
          description="Monospace tabbed interface component that maintains grid alignment."
          import_statement="alias HydepwnsLiveviewWeb.Components.UI.MonoTabs"
          attributes={[
            %{
              name: "id",
              type: "string",
              required: true,
              description: "Unique identifier for the tabs component"
            },
            %{
              name: "style",
              type: "atom",
              default: ":bordered",
              description: "Tab styling variant: :bordered, :underlined, :boxed"
            }
          ]}
        />
      </.api_docs_section>
    </section>
    """
  end

  defp load_docs do
    [
      %{
        title: "Getting Started",
        content: """
        # Getting Started

        Welcome to the API documentation. This guide will help you get started with our API.

        ## Authentication

        All API requests require authentication using an API key. You can get your API key from the dashboard.

        ## Base URL

        All API requests should be made to:

        ```
        https://api.example.com/v1
        ```

        ## Rate Limiting

        API requests are limited to 1000 requests per hour per API key.
        """
      },
      %{
        title: "Resources",
        content: """
        # Resources

        ## Users

        ### List Users

        ```http
        GET /users
        ```

        Returns a list of users.

        ### Get User

        ```http
        GET /users/:id
        ```

        Returns a single user by ID.
        """
      }
    ]
  end
end
