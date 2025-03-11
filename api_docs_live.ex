defmodule HydepwnsLiveviewWeb.ApiDocsLive do
  use HydepwnsLiveviewWeb, :live_view
  alias HydepwnsLiveviewWeb.Components.ApiDocs
  
  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_current_path()
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
  def handle_event("change_theme", %{"theme" => theme}, socket) do
    theme_class = "#{theme}-theme"
    {:noreply, assign(socket, :theme_class, theme_class)}
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
          description="A grid system component that maintains proper character alignment for monospace text. Ensures consistent spacing and layout with character-based units."
          import_statement="alias HydepwnsLiveviewWeb.Components.MonoGrid"
          attributes={[
            %{
              name: "id",
              type: "string",
              default: nil,
              description: "Optional unique identifier for this grid instance"
            },
            %{
              name: "class",
              type: "string",
              default: nil,
              description: "Additional CSS classes to add to the grid container"
            },
            %{
              name: "cols",
              type: "integer",
              default: "80",
              description: "Number of columns in the grid"
            },
            %{
              name: "cell_width",
              type: "string",
              default: "1ch",
              description: "Width of each cell"
            },
            %{
              name: "cell_height",
              type: "string",
              default: "1.5rem",
              description: "Height of each cell"
            },
            %{
              name: "debug",
              type: "boolean",
              default: "false",
              description: "When true, shows grid lines for debugging"
            },
            %{
              name: "container",
              type: "atom",
              default: ":div",
              description: "Container type: :div, :pre, :code"
            }
          ]}
          slots={[
            %{
              name: :inner_block,
              description: "Content to display within the grid"
            }
          ]}
          examples={[
            %{
              title: "Basic Grid",
              code: """
              <.mono_grid cols={40}>
                Content that will respect the monospace grid
              </.mono_grid>
              """,
              description: "A basic grid with 40 columns"
            },
            %{
              title: "Debug Mode",
              code: """
              <.mono_grid cols={40} debug={true}>
                Grid with debugging overlay
              </.mono_grid>
              """,
              description: "A grid with debugging overlay to help with alignment"
            }
          ]}
          notes={[
            "Uses CSS Grid with ch units to ensure precise character alignment",
            "Responsive layouts maintain monospace aesthetics across device sizes",
            "Debug mode helps visualize the grid for development purposes"
          ]}
        />

        <.api_docs
          component_name="MonoGridRow"
          description="A row component for the MonoGrid system. Creates a logical row grouping within the grid."
          import_statement="alias HydepwnsLiveviewWeb.Components.MonoGrid"
          attributes={[
            %{
              name: "id",
              type: "string",
              default: nil,
              description: "Optional unique identifier for this row"
            },
            %{
              name: "class",
              type: "string",
              default: nil,
              description: "Additional CSS classes to add to the row"
            },
            %{
              name: "debug",
              type: "boolean",
              default: "false",
              description: "When true, shows grid lines for debugging"
            }
          ]}
          slots={[
            %{
              name: :inner_block,
              description: "Content to display within the row (typically MonoGridCell components)"
            }
          ]}
          examples={[
            %{
              title: "Grid with Rows",
              code: """
              <.mono_grid cols={40}>
                <.mono_grid_row>
                  Row 1 content
                </.mono_grid_row>
                <.mono_grid_row>
                  Row 2 content
                </.mono_grid_row>
              </.mono_grid>
              """,
              description: "A grid with multiple rows"
            }
          ]}
        />

        <.api_docs
          component_name="MonoGridCell"
          description="A cell component for the MonoGrid system. Represents a content cell that can span multiple columns and rows."
          import_statement="alias HydepwnsLiveviewWeb.Components.MonoGrid"
          attributes={[
            %{
              name: "id",
              type: "string",
              default: nil,
              description: "Optional unique identifier for this cell"
            },
            %{
              name: "class",
              type: "string",
              default: nil,
              description: "Additional CSS classes to add to the cell"
            },
            %{
              name: "cols",
              type: "integer",
              default: "1",
              description: "Number of columns this cell spans"
            },
            %{
              name: "rows",
              type: "integer",
              default: "1",
              description: "Number of rows this cell spans"
            },
            %{
              name: "debug",
              type: "boolean",
              default: "false",
              description: "When true, shows grid lines for debugging"
            },
            %{
              name: "align",
              type: "atom",
              default: ":left",
              description: "Text alignment within the cell: :left, :center, :right"
            }
          ]}
          slots={[
            %{
              name: :inner_block,
              description: "Content to display within the cell"
            }
          ]}
          examples={[
            %{
              title: "Grid with Cells",
              code: """
              <.mono_grid cols={40}>
                <.mono_grid_row>
                  <.mono_grid_cell cols={10}>Cell 1</.mono_grid_cell>
                  <.mono_grid_cell cols={15} align={:center}>Cell 2</.mono_grid_cell>
                  <.mono_grid_cell cols={15} align={:right}>Cell 3</.mono_grid_cell>
                </.mono_grid_row>
              </.mono_grid>
              """,
              description: "A grid with cells of different sizes and alignments"
            }
          ]}
        />

        <.api_docs
          component_name="MonoText"
          description="A helper component for the MonoGrid system that ensures text aligns properly on the grid with optional padding."
          import_statement="alias HydepwnsLiveviewWeb.Components.MonoGrid"
          attributes={[
            %{
              name: "id",
              type: "string",
              default: nil,
              description: "Optional unique identifier"
            },
            %{
              name: "class",
              type: "string",
              default: nil,
              description: "Additional CSS classes"
            },
            %{
              name: "style",
              type: "string",
              default: nil,
              description: "Additional inline styles"
            },
            %{
              name: "padding",
              type: "string",
              default: "0 0 0 0",
              description: "Padding in character units (format: \"top right bottom left\")"
            }
          ]}
          slots={[
            %{
              name: :inner_block,
              description: "Text content to display"
            }
          ]}
          examples={[
            %{
              title: "Text with Padding",
              code: """
              <.mono_text padding="1 2 1 2">
                Padded text that aligns with the grid
              </.mono_text>
              """,
              description: "Text with character-based padding"
            }
          ]}
        />
      </.api_docs_section>

      <.api_docs_section id="terminal-component" title="Terminal Component">
        <.api_docs
          component_name="Terminal"
          description="An interactive terminal component with command history and customization options. Provides a command-line interface that supports custom commands."
          import_statement="alias HydepwnsLiveviewWeb.Components.Terminal"
          attributes={[
            %{
              name: "id",
              type: "string",
              required: true,
              description: "Required unique identifier for this terminal instance"
            },
            %{
              name: "cols",
              type: "integer",
              default: "80",
              description: "Number of columns in the terminal"
            },
            %{
              name: "rows",
              type: "integer",
              default: "20",
              description: "Number of rows in the terminal viewport"
            },
            %{
              name: "prompt",
              type: "string",
              default: "$ ",
              description: "Terminal prompt string"
            },
            %{
              name: "welcome_message",
              type: "string",
              default: "Welcome to Hydepwns Terminal...",
              description: "Initial message shown in the terminal"
            },
            %{
              name: "available_commands",
              type: "map",
              default: "Default commands",
              description: "Map of custom commands this terminal should support"
            },
            %{
              name: "theme",
              type: "string",
              default: "dark",
              description: "Terminal theme: \"light\", \"dark\", \"dim\", \"high-contrast\""
            },
            %{
              name: "wrap",
              type: "boolean",
              default: "true",
              description: "Whether to enable line wrapping"
            },
            %{
              name: "fullscreen",
              type: "boolean",
              default: "false",
              description: "Whether the terminal can be toggled to fullscreen mode"
            }
          ]}
          examples={[
            %{
              title: "Basic Terminal",
              code: """
              <.live_component
                module={Terminal}
                id="basic-terminal"
                cols={60}
                rows={10}
              />
              """,
              description: "A basic terminal with default commands"
            },
            %{
              title: "Custom Terminal",
              code: """
              <.live_component
                module={Terminal}
                id="custom-terminal"
                cols={60}
                rows={12}
                prompt="user@hydepwns:~$ "
                theme="dim"
                available_commands={custom_commands}
                fullscreen={true}
              />
              """,
              description: "A custom terminal with a different prompt, theme, and custom commands"
            }
          ]}
          notes={[
            "Supports command history navigation with up/down arrow keys",
            "Command history is persisted in localStorage",
            "Tab completion is available for commands",
            "Custom commands can be defined with descriptions and functionality",
            "Four theme options are available: light, dark, dim, and high-contrast",
            "Default commands include: help, clear, echo, date, theme, and history"
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
              description: "Type of ASCII art to generate: \"box\", \"arrow\", \"table\", \"custom\""
            },
            %{
              name: "width",
              type: "integer",
              default: "25",
              description: "Width of the ASCII art (where applicable)"
            },
            %{
              name: "height",
              type: "integer",
              default: "5",
              description: "Height of the ASCII art (where applicable)"
            },
            %{
              name: "text",
              type: "string",
              default: "",
              description: "Text to include in the ASCII art"
            },
            %{
              name: "style",
              type: "string",
              default: "single",
              description: "Style of the box drawing: \"single\", \"double\", \"rounded\""
            }
          ]}
          examples={[
            %{
              title: "Basic ASCII Box",
              code: """
              <.ascii_art_generator
                id="box-example"
                art_type="box"
                width={30}
                height={5}
                text="Hello World"
                style="single"
              />
              """,
              description: "A simple ASCII box with text"
            }
          ]}
          notes={[
            "Supports generating multiple types of ASCII art",
            "Live preview updates as parameters change",
            "Generated art can be copied to clipboard",
            "Works well with the MonoGrid component for proper alignment"
          ]}
        />

        <.api_docs
          component_name="DiagramEditor"
          description="A simple ASCII diagram editor component with live preview functionality."
          import_statement="alias HydepwnsLiveviewWeb.Components.DiagramEditor"
          attributes={[
            %{
              name: "id",
              type: "string",
              required: true,
              description: "Unique identifier for this component instance"
            },
            %{
              name: "initial_template",
              type: "string",
              default: "flowchart",
              description: "Initial diagram template to use: \"flowchart\", \"sequence\", \"state\", \"custom\""
            },
            %{
              name: "width",
              type: "integer",
              default: "60",
              description: "Width of the diagram editor in characters"
            },
            %{
              name: "height",
              type: "integer",
              default: "20",
              description: "Height of the diagram editor in rows"
            }
          ]}
          examples={[
            %{
              title: "Basic Diagram Editor",
              code: """
              <.live_component
                module={DiagramEditor}
                id="diagram-editor"
                initial_template="flowchart"
                width={60}
                height={20}
              />
              """,
              description: "A diagram editor with flowchart template"
            }
          ]}
          notes={[
            "Includes several built-in templates for common diagram types",
            "Live preview updates as you edit the diagram",
            "Box drawing characters can be inserted using the toolbar",
            "Resulting diagrams can be copied to clipboard"
          ]}
        />
      </.api_docs_section>

      <.api_docs_section id="theme-components" title="Theme Components">
        <.api_docs
          component_name="ThemeToggle"
          description="A theme toggle component for switching between light, dark, dim, and high-contrast themes."
          import_statement="alias HydepwnsLiveviewWeb.Components.ThemeToggle"
          examples={[
            %{
              title: "Basic Theme Toggle",
              code: """
              <.theme_toggle />
              """,
              description: "A simple theme toggle with all theme options"
            }
          ]}
          notes={[
            "Supports four themes: light, dark, dim, and high-contrast",
            "Theme preference is saved in localStorage",
            "Includes keyboard shortcuts (Shift+Arrow keys) for navigation",
            "Announces theme changes to screen readers"
          ]}
        />

        <.api_docs
          component_name="ThemePreview"
          description="A component for previewing different themes side by side."
          import_statement="alias HydepwnsLiveviewWeb.Components.ThemePreview"
          attributes={[
            %{
              name: "id",
              type: "string",
              default: nil,
              description: "Optional unique identifier"
            },
            %{
              name: "themes",
              type: "list",
              default: "[\"light\", \"dark\", \"dim\", \"high-contrast\"]",
              description: "List of themes to preview"
            }
          ]}
          examples={[
            %{
              title: "Theme Preview",
              code: """
              <.theme_preview themes={["light", "dark"]} />
              """,
              description: "A preview of light and dark themes"
            }
          ]}
          notes={[
            "Useful for comparing multiple themes side by side",
            "Shows key UI elements in each theme",
            "Can be customized to show specific themes"
          ]}
        />
      </.api_docs_section>

      <.api_docs_section id="ui-components" title="UI Components">
        <.api_docs
          component_name="CopyableCode"
          description="A component for displaying code snippets that can be copied to the clipboard."
          import_statement=""
          attributes={[
            %{
              name: "id",
              type: "string",
              default: nil,
              description: "Optional unique identifier"
            },
            %{
              name: "language",
              type: "string",
              default: "text",
              description: "Programming language for syntax highlighting"
            },
            %{
              name: "show_copy",
              type: "boolean",
              default: "true",
              description: "Whether to show the copy button"
            }
          ]}
          slots={[
            %{
              name: :inner_block,
              description: "Code content to display"
            }
          ]}
          examples={[
            %{
              title: "Copyable Code",
              code: """
              <.copyable_code language="elixir">
                defmodule Example do
                  def hello, do: "world"
                end
              </.copyable_code>
              """,
              description: "A copyable code snippet with Elixir syntax highlighting"
            }
          ]}
          notes={[
            "Includes a copy-to-clipboard button",
            "Shows success/error notifications after copy attempt",
            "Can be configured for different programming languages"
          ]}
        />
      </.api_docs_section>
    </section>
    """
  end

  defp assign_current_path(socket) do
    assign(socket, :current_path, "/api-docs")
  end
end 