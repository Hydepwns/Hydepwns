defmodule HydepwnsLiveviewWeb.Components.DiagramEditor do
  @moduledoc """
  A simple ASCII diagram editor component with live preview functionality.

  This component allows users to:
  - Create and edit ASCII/Unicode diagrams directly in the browser
  - Choose from various diagram templates (flowchart, sequence, state diagram, ER diagram)
  - Preview changes in real-time
  - Export the resulting diagram as text

  The editor uses a grid-based approach that maintains proper character alignment
  and provides a consistent monospace experience.
  """
  use HydepwnsLiveviewWeb, :live_component

  @default_width 40
  @default_height 15

  @templates %{
    "flowchart" => """
    ┌──────────────────┐
    │       Start      │
    └─────────┬────────┘
              │
              ▼
    ┌──────────────────┐
    │    Process 1     │◄───┐
    └─────────┬────────┘    │
              │              │ Retry
              ▼              │
    ┌──────────────────┐    │
    │    Decision      │    │
    └─────────┬────────┘    │
              │              │
        ┌─────┴─────┐       │
        │           │       │
        ▼           ▼       │
    ┌───────┐   ┌───────┐   │
    │  Yes  │   │  No   ├───┘
    └───┬───┘   └───┬───┘
        │           │
        ▼           ▼
    ┌───────┐   ┌───────┐
    │Success│   │ Error │
    └───┬───┘   └───────┘
        │
        ▼
    ┌──────────────────┐
    │       End        │
    └──────────────────┘
    """,
    "sequence" => """
    ┌───────────┐     ┌───────────┐     ┌───────────┐
    │   User    │     │   App     │     │   API     │
    └─────┬─────┘     └─────┬─────┘     └─────┬─────┘
          │                 │                 │
          │  1. Request     │                 │
          │───────────────► │                 │
          │                 │                 │
          │                 │  2. API Call    │
          │                 │───────────────► │
          │                 │                 │
          │                 │                 │  
          │                 │  3. Processing  │
          │                 │                 │  ─┐
          │                 │                 │   │ 
          │                 │                 │  ◄┘
          │                 │                 │  
          │                 │  4. Response    │
          │                 │ ◄───────────────│
          │                 │                 │
          │  5. Result      │                 │
          │ ◄───────────────│                 │
          │                 │                 │
    ┌─────┴─────┐     ┌─────┴─────┐     ┌─────┴─────┐
    │   User    │     │   App     │     │   API     │
    └───────────┘     └───────────┘     └───────────┘
    """,
    "state" => """
    ┌───────────────────────────────────────────┐
    │                                           │
    │  ┌─────────┐        ┌─────────────────┐   │
    │  │ Closed  │◄───────┤ Final Reviewed  │   │
    │  └─────────┘        └─────────────────┘   │
    │      │                      ▲             │
    │      │ create               │             │
    │      ▼                      │             │
    │  ┌─────────┐                │             │
    │  │  Open   │                │             │
    │  └─────────┘                │             │
    │      │                      │             │
    │      │ submit               │             │
    │      ▼                      │             │
    │  ┌─────────┐                │             │
    │  │ Review  ├───────┐        │             │
    │  └─────────┘       │        │             │
    │      │             │        │             │
    │      │ approve     │ reject │             │
    │      ▼             ▼        │             │
    │  ┌─────────┐    ┌─────────┐ │             │
    │  │Approved │    │Rejected ├─┘             │
    │  └─────────┘    └─────────┘               │
    │                                           │
    └───────────────────────────────────────────┘
    """,
    "er_diagram" => """
    ┌───────────────┐        ┌───────────────┐
    │    User       │        │    Post       │
    ├───────────────┤        ├───────────────┤
    │ id: int (PK)  │        │ id: int (PK)  │
    │ name: string  │◄──┐    │ title: string │
    │ email: string │   │    │ content: text │
    │ created: date │   │    │ created: date │
    │ user_id: int  │   │    │ (FK)         │
    └───────────────┘   │    │ (FK)         │
                        └────┤ (FK)         │
                             └───────────────┘
                                     │
                                     │
                                     ▼
    ┌───────────────┐        ┌───────────────┐
    │   Comment     │        │     Tag       │
    ├───────────────┤        ├───────────────┤
    │ id: int (PK)  │        │ id: int (PK)  │
    │ content: text │        │ name: string  │
    │ created: date │        └───────┬───────┘
    │ post_id: int  │◄───┐           │
    │ (FK)          │    │           │
    └───────────────┘    │    ┌──────┴───────┐
                         │    │ PostTag      │
                         │    ├──────────────┤
                         │    │ post_id (FK) │
                         │    │ tag_id (FK)  │
                         │    └──────────────┘
                         │           │
                         └───────────┘
    """
  }

  @box_chars %{
    "horizontal" => "─",
    "vertical" => "│",
    "top_left" => "┌",
    "top_right" => "┐",
    "bottom_left" => "└",
    "bottom_right" => "┘",
    "t_down" => "┬",
    "t_up" => "┴",
    "t_right" => "├",
    "t_left" => "┤",
    "cross" => "┼",
    "arrow_down" => "▼",
    "arrow_up" => "▲",
    "arrow_right" => "►",
    "arrow_left" => "◄"
  }

  @impl true
  def mount(socket) do
    templates_list = Map.keys(@templates)
                    |> Enum.map(&(%{key: &1, label: diagram_name_formatted(&1)}))

    {:ok, assign(socket,
      templates_list: templates_list,
      selected_template: hd(templates_list).key,
      content: @templates[hd(templates_list).key] || "",
      copy_tooltip: "Copy to clipboard"
    )}
  end

  @impl true
  def update(assigns, socket) do
    template_content = Map.get(@templates, assigns[:template] || "blank", "")

    socket =
      socket
      |> assign(:id, assigns[:id] || "diagram-editor-#{System.unique_integer([:positive])}")
      |> assign(:width, assigns[:width] || @default_width)
      |> assign(:height, assigns[:height] || @default_height)
      |> assign(:template, assigns[:template] || "blank")
      |> assign(:content, assigns[:content] || template_content)
      |> assign(:available_templates, Map.keys(@templates))
      |> assign(:box_chars, @box_chars)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_template", %{"template" => template}, socket) do
    content = @templates[template] || ""
    socket = socket
      |> assign(:selected_template, template)
      |> assign(:content, content)

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_content", %{"content" => content}, socket) do
    {:noreply, assign(socket, content: content)}
  end

  @impl true
  def handle_event("insert_character", %{"char" => char}, socket) do
    {:noreply, push_event(socket, "insert-at-cursor", %{text: char})}
  end

  @impl true
  def handle_event("copy_diagram", _params, socket) do
    {:noreply, push_event(socket, "copy-to-clipboard", %{
      text: socket.assigns.content,
      message: "Diagram copied to clipboard!"
    })}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="diagram-editor" phx-target={@myself}>
      <div class="editor-header">
        <h3>ASCII Diagram Editor</h3>
        <div class="template-selector">
          <label for={"#{@id}-template"}>Template:</label>
          <select
            id={"#{@id}-template"}
            phx-change="select_template"
            phx-target={@myself}
            name="template"
          >
            <%= for template <- @templates_list do %>
              <option value={template.key} selected={template.key == @selected_template}>
                <%= template.label %>
              </option>
            <% end %>
          </select>
        </div>
      </div>

      <div class="editor-tools">
        <div class="box-drawing-chars">
          <%= for char <- box_drawing_chars() do %>
            <button
              type="button"
              class="box-char-button"
              phx-click="insert_character"
              phx-value-char={char}
              phx-target={@myself}
              aria-label={"Insert #{char_description(char)} character"}
            >
              <%= char %>
            </button>
          <% end %>
        </div>
      </div>

      <div class="editor-grid">
        <div class="editor-pane">
          <textarea
            id={"#{@id}-editor"}
            phx-change="update_content"
            phx-target={@myself}
            name="content"
            placeholder="Start editing your diagram here..."
            aria-label="Diagram editor"
          ><%= @content %></textarea>
        </div>

        <div class="preview-pane">
          <div class="preview-header">
            <h4>Preview</h4>
            <button
              type="button"
              class="copy-button"
              phx-click="copy_diagram"
              phx-target={@myself}
              aria-label="Copy diagram to clipboard"
            >
              Copy
            </button>
          </div>
          <pre class="diagram-preview"><code id={"#{@id}-diagram-code"} phx-hook="CopyableCode"><%= @content %></code></pre>
        </div>
      </div>

      <details class="diagram-help">
        <summary>Keyboard shortcuts and tips</summary>
        <div class="help-content">
          <h4>Keyboard Shortcuts</h4>
          <ul>
            <li><kbd>Tab</kbd> - Insert 2 spaces</li>
            <li><kbd>Alt</kbd> + <kbd>C</kbd> - Copy diagram to clipboard</li>
          </ul>
          
          <h4>Box Drawing Tips</h4>
          <ul>
            <li>Use single characters (─ │ ┌ ┐ └ ┘) for simple borders</li>
            <li>Use double characters (═ ║ ╔ ╗ ╚ ╝) for emphasized borders</li>
            <li>Use arrows (→ ← ↑ ↓ ↔ ↕) for directions</li>
            <li>Click on any character in the toolbar to insert it at cursor position</li>
          </ul>
        </div>
      </details>
    </div>
    """
  end

  defp diagram_name_formatted("flowchart"), do: "Flowchart"
  defp diagram_name_formatted("sequence"), do: "Sequence Diagram"
  defp diagram_name_formatted("state"), do: "State Diagram"
  defp diagram_name_formatted("er_diagram"), do: "ER Diagram"
  defp diagram_name_formatted(key), do: String.capitalize(key)

  defp box_drawing_chars do
    [
      # Horizontal and vertical lines
      "─", "│", "═", "║",
      
      # Corners
      "┌", "┐", "└", "┘",
      "╔", "╗", "╚", "╝",
      "╭", "╮", "╰", "╯",
      
      # T-junctions
      "├", "┤", "┬", "┴",
      
      # Crosses
      "┼", "╬",
      
      # Arrows
      "→", "←", "↑", "↓",
      "⇒", "⇐", "⇑", "⇓",
      "↔", "↕", "◄", "►",
      
      # Other useful symbols
      "•", "◆", "★", "○",
      "□", "▪", "▫", "▶"
    ]
  end

  defp char_description("─"), do: "horizontal line"
  defp char_description("│"), do: "vertical line"
  defp char_description("═"), do: "double horizontal line"
  defp char_description("║"), do: "double vertical line"
  defp char_description("┌"), do: "top left corner"
  defp char_description("┐"), do: "top right corner"
  defp char_description("└"), do: "bottom left corner"
  defp char_description("┘"), do: "bottom right corner"
  defp char_description("╔"), do: "double top left corner"
  defp char_description("╗"), do: "double top right corner"
  defp char_description("╚"), do: "double bottom left corner"
  defp char_description("╝"), do: "double bottom right corner"
  defp char_description("╭"), do: "rounded top left corner"
  defp char_description("╮"), do: "rounded top right corner"
  defp char_description("╰"), do: "rounded bottom left corner"
  defp char_description("╯"), do: "rounded bottom right corner"
  defp char_description("├"), do: "left T-junction"
  defp char_description("┤"), do: "right T-junction"
  defp char_description("┬"), do: "top T-junction"
  defp char_description("┴"), do: "bottom T-junction"
  defp char_description("┼"), do: "cross"
  defp char_description("╬"), do: "double cross"
  defp char_description("→"), do: "right arrow"
  defp char_description("←"), do: "left arrow"
  defp char_description("↑"), do: "up arrow"
  defp char_description("↓"), do: "down arrow"
  defp char_description("⇒"), do: "double right arrow"
  defp char_description("⇐"), do: "double left arrow"
  defp char_description("⇑"), do: "double up arrow"
  defp char_description("⇓"), do: "double down arrow"
  defp char_description("↔"), do: "horizontal double arrow"
  defp char_description("↕"), do: "vertical double arrow"
  defp char_description("◄"), do: "left triangle arrow"
  defp char_description("►"), do: "right triangle arrow"
  defp char_description("•"), do: "bullet"
  defp char_description("◆"), do: "diamond"
  defp char_description("★"), do: "star"
  defp char_description("○"), do: "circle"
  defp char_description("□"), do: "square"
  defp char_description("▪"), do: "filled small square"
  defp char_description("▫"), do: "outline small square"
  defp char_description("▶"), do: "filled triangle"
  defp char_description(char), do: "special character #{char}"
end
