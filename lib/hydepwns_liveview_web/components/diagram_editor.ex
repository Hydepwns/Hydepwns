defmodule HydepwnsLiveviewWeb.Components.DiagramEditor do
  @moduledoc """
  A simple ASCII diagram editor component with live preview functionality.

  This component allows users to:
  - Create and edit ASCII/Unicode diagrams directly in the browser
  - Choose from various diagram templates (flowchart, sequence, state diagram)
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
    ┌────────────────┐
    │      Start     │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │   Process 1    │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │   Process 2    │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │       End      │
    └────────────────┘
    """,
    "sequence" => """
    ┌─────────┐  ┌─────────┐  ┌─────────┐
    │  User   │  │  App    │  │  API    │
    └────┬────┘  └────┬────┘  └────┬────┘
         │            │            │
         │ Request    │            │
         │───────────>│            │
         │            │            │
         │            │ API Call   │
         │            │───────────>│
         │            │            │
         │            │ Response   │
         │            │<───────────│
         │            │            │
         │ Result     │            │
         │<───────────│            │
         │            │            │
    ┌────┴────┐  ┌────┴────┐  ┌────┴────┐
    │  User   │  │  App    │  │  API    │
    └─────────┘  └─────────┘  └─────────┘
    """,
    "state" => """
    ┌───────────┐
    │   Idle    │
    └─────┬─────┘
          │
          ▼
    ┌───────────┐    Error    ┌───────────┐
    │ Processing ├───────────>│   Error   │
    └─────┬─────┘             └─────┬─────┘
          │                         │
          │ Success                 │
          ▼                         │
    ┌───────────┐                   │
    │  Success  │                   │
    └─────┬─────┘                   │
          │                         │
          │         Retry           │
          └─────────────────────────┘
    """,
    "boxes" => """
    ┌───────────────┐  ┌───────────────┐
    │               │  │               │
    │     Box 1     │  │     Box 2     │
    │               │  │               │
    └───────┬───────┘  └───────┬───────┘
            │                  │
            │                  │
            │                  │
    ┌───────┴───────┐  ┌───────┴───────┐
    │               │  │               │
    │     Box 3     │  │     Box 4     │
    │               │  │               │
    └───────────────┘  └───────────────┘
    """,
    "blank" => ""
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
    {:ok, socket}
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
  def handle_event("select-template", %{"template" => template}, socket) do
    template_content = Map.get(@templates, template, "")

    {:noreply,
     socket
     |> assign(:template, template)
     |> assign(:content, template_content)}
  end

  @impl true
  def handle_event("update-content", %{"content" => content}, socket) do
    {:noreply, socket |> assign(:content, content)}
  end

  @impl true
  def handle_event("insert-box-char", %{"char" => char_key}, socket) do
    char = Map.get(@box_chars, char_key, "")
    textarea_id = "#{socket.assigns.id}-textarea"

    # Send a command to JS to insert the character at the cursor position
    {:noreply,
     socket
     |> push_event("insert-at-cursor", %{
       target: textarea_id,
       text: char
     })}
  end

  @impl true
  def handle_event("copy-diagram", _, socket) do
    # Will trigger JS to copy the content to clipboard
    {:noreply,
     socket
     |> push_event("copy-to-clipboard", %{
       text: socket.assigns.content,
       message: "Diagram copied to clipboard!"
     })}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="diagram-editor" phx-hook="DiagramEditor">
      <div class="editor-header">
        <h3>ASCII Diagram Editor</h3>

        <div class="template-selector">
          <label for={"#{@id}-template-select"}>Choose template:</label>
          <select id={"#{@id}-template-select"} phx-change="select-template" phx-target={@myself}>
            <%= for template <- @available_templates do %>
              <option value={template} selected={@template == template}>
                {String.capitalize(template)}
              </option>
            <% end %>
          </select>
        </div>
      </div>

      <div class="editor-tools">
        <div class="box-drawing-chars">
          <%= for {key, char} <- @box_chars do %>
            <button
              type="button"
              class="box-char-button"
              phx-click="insert-box-char"
              phx-value-char={key}
              phx-target={@myself}
              title={"Insert #{String.replace(key, "_", " ")}"}
            >
              {char}
            </button>
          <% end %>
        </div>
      </div>

      <div class="editor-grid">
        <div class="editor-pane">
          <textarea
            id={"#{@id}-textarea"}
            class="diagram-textarea monospace"
            rows={@height}
            cols={@width}
            spellcheck="false"
            phx-change="update-content"
            phx-target={@myself}
            phx-debounce="300"
            phx-hook="AutoResize"
            aria-label="ASCII Diagram Editor"
          ><%= @content %></textarea>
        </div>

        <div class="preview-pane">
          <div class="preview-header">
            <h4>Preview</h4>
            <button
              type="button"
              class="copy-button"
              phx-click="copy-diagram"
              phx-target={@myself}
              aria-label="Copy diagram to clipboard"
            >
              Copy
            </button>
          </div>
          <pre id={"#{@id}-preview"} class="diagram-preview monospace"><code><%= @content %></code></pre>
        </div>
      </div>

      <div class="diagram-help">
        <details>
          <summary>Keyboard Shortcuts & Tips</summary>
          <div class="help-content">
            <h4>Keyboard Shortcuts</h4>
            <ul>
              <li><kbd>Tab</kbd> - Insert spaces (maintains column alignment)</li>
              <li><kbd>Shift+Enter</kbd> - Insert new line</li>
              <li><kbd>Ctrl+C</kbd> - Copy selected text</li>
              <li><kbd>Ctrl+Z</kbd> - Undo</li>
              <li><kbd>Ctrl+Y</kbd> - Redo</li>
            </ul>

            <h4>Tips</h4>
            <ul>
              <li>Use box drawing characters for clean lines</li>
              <li>Maintain consistent spacing for alignment</li>
              <li>Start with a template and modify as needed</li>
              <li>Preview updates as you type</li>
            </ul>
          </div>
        </details>
      </div>
    </div>
    """
  end
end
