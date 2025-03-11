defmodule HydepwnsLiveviewWeb.Live.Docs.ApiDocsLive do
  use HydepwnsLiveviewWeb, :live_view
  alias HydepwnsLiveviewWeb.Components.Documentation.ApiDocs
  import ApiDocs
  alias HydepwnsLiveviewWeb.Helpers.PathHelper

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> PathHelper.assign_specific_path("/api-docs")
     |> assign(:page_title, "API Documentation")
     |> assign(:theme_class, "dark-theme")
     |> assign(:show_toc, true)
     |> assign(:toc_items, [
       {"intro", "Introduction"},
       {"grid-components", "Grid Components"},
       {"terminal-component", "Terminal Component"},
       {"ascii-art-components", "ASCII Art Components"},
       {"ui-components", "UI Components"},
       {"theme-components", "Theme Components"}
     ])}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, PathHelper.assign_specific_path(socket, "/api-docs")}
  end

  @impl true
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

      <.api_docs_section id="terminal-component" title="Terminal Component">
        <.api_docs
          component_name="Terminal"
          description="An interactive terminal component with command history and customization options."
          import_statement="alias HydepwnsLiveviewWeb.Components.Terminal"
          attributes={[
            %{
              name: "id",
              type: "string",
              required: true,
              description: "Required unique identifier for this terminal instance"
            },
            %{name: "prompt", type: "string", default: "$ ", description: "Terminal prompt string"}
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
end
