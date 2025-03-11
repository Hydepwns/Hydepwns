defmodule HydepwnsLiveviewWeb.Components.AsciiArtGenerator do
  use Phoenix.LiveComponent
  use PhoenixHTMLHelpers

  @moduledoc """
  A component for generating ASCII art with various templates and customization options.
  
  Features:
  - Generate various types of ASCII art (boxes, arrows, tables, banners, etc.)
  - Customize dimensions, styles, and text content
  - Copy generated ASCII art to clipboard
  - Preview changes in real-time
  - Accessibility support with ARIA labels and keyboard navigation
  """

  @doc """
  Mount function for AsciiArtGenerator LiveComponent
  """
  def mount(socket) do
    {:ok, socket}
  end

  @doc """
  Update function for AsciiArtGenerator LiveComponent
  """
  def update(assigns, socket) do
    socket = socket
      |> assign(:id, assigns.id)
      |> assign(:art_type, assigns[:art_type] || "box")
      |> assign(:width, assigns[:width] || 25)
      |> assign(:height, assigns[:height] || 5)
      |> assign(:text, assigns[:text] || "")
      |> assign(:style, assigns[:style] || "single")
      |> assign(:show_code, assigns[:show_code] || true)

    socket = generate_ascii_art(socket)

    {:ok, socket}
  end

  @doc """
  Renders the ASCII art generator component
  """
  def render(assigns) do
    ~H"""
    <div id={@id} class="ascii-art-generator" phx-hook="AsciiArtGenerator">
      <form phx-change="update_ascii_art" phx-target={@myself}>
        <div class="form-row">
          <div class="form-group">
            <label for={"#{@id}-art-type"}>Art Type</label>
            <select id={"#{@id}-art-type"} name="art_type" value={@art_type}>
              <option value="box">Box</option>
              <option value="arrow">Arrow</option>
              <option value="table">Table</option>
              <option value="banner">Banner</option>
              <option value="frame">Frame</option>
              <option value="list">List</option>
              <option value="badge">Badge</option>
              <option value="custom">Custom</option>
            </select>
          </div>

          <div class="form-group">
            <label for={"#{@id}-style"}>Style</label>
            <select id={"#{@id}-style"} name="style" value={@style}>
              <option value="single">Single Line</option>
              <option value="double">Double Line</option>
              <option value="rounded">Rounded</option>
              <option value="heavy">Heavy</option>
              <option value="ascii">ASCII (no unicode)</option>
            </select>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for={"#{@id}-width"}>Width</label>
            <input
              type="number"
              id={"#{@id}-width"}
              name="width"
              value={@width}
              min="5"
              max="100"
            />
          </div>

          <div class="form-group">
            <label for={"#{@id}-height"}>Height</label>
            <input
              type="number"
              id={"#{@id}-height"}
              name="height"
              value={@height}
              min="1"
              max="50"
            />
          </div>

          <div class="form-group">
            <label for={"#{@id}-text"}>Text</label>
            <input
              type="text"
              id={"#{@id}-text"}
              name="text"
              value={@text}
              placeholder="Optional text for the art"
            />
          </div>
        </div>
      </form>

      <div class="preview-section">
        <div class="preview-header">
          <h3>Preview</h3>
          <div class="preview-controls">
            <button
              type="button"
              class="preview-control-button"
              phx-click="copy_ascii_art"
              phx-target={@myself}
              aria-label="Copy ASCII art to clipboard"
            >
              Copy
            </button>
            <button
              type="button"
              class="preview-control-button"
              phx-click="toggle_code_view"
              phx-target={@myself}
              aria-label={if @show_code, do: "Hide code view", else: "Show code view"}
            >
              <%= if @show_code, do: "Hide Code", else: "Show Code" %>
            </button>
          </div>
        </div>

        <pre><code id={"#{@id}-art-code"} phx-hook="CopyableCode" class="ascii-art"><%= @generated_art %></code></pre>

        <%= if @show_code do %>
          <div class="code-section">
            <h4>Code to Insert</h4>
            <div class="code-block">Code placeholder</div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Handle events from the user interface
  """
  def handle_event("update_ascii_art", params, socket) do
    # Parse and validate parameters
    width = parse_integer(params["width"], 25)
    height = parse_integer(params["height"], 5)
    
    # Update socket with new parameters
    socket = socket
      |> assign(:art_type, params["art_type"] || socket.assigns.art_type)
      |> assign(:style, params["style"] || socket.assigns.style)
      |> assign(:width, width)
      |> assign(:height, height)
      |> assign(:text, params["text"] || "")
    
    # Generate the new ASCII art
    socket = generate_ascii_art(socket)
    
    {:noreply, socket}
  end

  def handle_event("copy_ascii_art", _params, socket) do
    {:noreply, push_event(socket, "copy-to-clipboard", %{
      text: socket.assigns.generated_art,
      message: "ASCII art copied to clipboard!"
    })}
  end

  def handle_event("toggle_code_view", _params, socket) do
    {:noreply, assign(socket, :show_code, !socket.assigns.show_code)}
  end

  # Helper functions for generating ASCII art
  defp generate_ascii_art(socket) do
    %{art_type: art_type, style: style, width: width, height: height, text: text} = socket.assigns
    
    generated_art = case art_type do
      "box" -> generate_box(style, width, height, text)
      "arrow" -> generate_arrow(style, width, text)
      "table" -> generate_table(style, width, height, text)
      "banner" -> generate_banner(style, width, text)
      "frame" -> generate_frame(style, width, height, text)
      "list" -> generate_list(style, width, text)
      "badge" -> generate_badge(style, width, text)
      "custom" -> text # For custom, just use the text as-is
      _ -> "Unsupported art type: #{art_type}"
    end
    
    assign(socket, :generated_art, generated_art)
  end

  defp parse_integer(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> default
    end
  end
  defp parse_integer(_, default), do: default

  # Box generator with different styles
  defp generate_box("single", width, height, text) do
    top = "┌" <> String.duplicate("─", width - 2) <> "┐"
    middle = "│" <> String.pad_trailing(String.slice(text, 0, width - 2), width - 2) <> "│"
    bottom = "└" <> String.duplicate("─", width - 2) <> "┘"
    
    lines = [top] ++ 
            List.duplicate(middle, max(1, height - 2)) ++ 
            [bottom]
    
    Enum.join(lines, "\n")
  end
  
  defp generate_box("double", width, height, text) do
    top = "╔" <> String.duplicate("═", width - 2) <> "╗"
    middle = "║" <> String.pad_trailing(String.slice(text, 0, width - 2), width - 2) <> "║"
    bottom = "╚" <> String.duplicate("═", width - 2) <> "╝"
    
    lines = [top] ++ 
            List.duplicate(middle, max(1, height - 2)) ++ 
            [bottom]
            
    Enum.join(lines, "\n")
  end
  
  defp generate_box("rounded", width, height, text) do
    top = "╭" <> String.duplicate("─", width - 2) <> "╮"
    middle = "│" <> String.pad_trailing(String.slice(text, 0, width - 2), width - 2) <> "│"
    bottom = "╰" <> String.duplicate("─", width - 2) <> "╯"
    
    lines = [top] ++ 
            List.duplicate(middle, max(1, height - 2)) ++ 
            [bottom]
            
    Enum.join(lines, "\n")
  end
  
  defp generate_box("heavy", width, height, text) do
    top = "┏" <> String.duplicate("━", width - 2) <> "┓"
    middle = "┃" <> String.pad_trailing(String.slice(text, 0, width - 2), width - 2) <> "┃"
    bottom = "┗" <> String.duplicate("━", width - 2) <> "┛"
    
    lines = [top] ++ 
            List.duplicate(middle, max(1, height - 2)) ++ 
            [bottom]
            
    Enum.join(lines, "\n")
  end
  
  defp generate_box("ascii", width, height, text) do
    top = "+" <> String.duplicate("-", width - 2) <> "+"
    middle = "|" <> String.pad_trailing(String.slice(text, 0, width - 2), width - 2) <> "|"
    bottom = "+" <> String.duplicate("-", width - 2) <> "+"
    
    lines = [top] ++ 
            List.duplicate(middle, max(1, height - 2)) ++ 
            [bottom]
            
    Enum.join(lines, "\n")
  end
  
  # Arrow generator with different styles
  defp generate_arrow("single", width, text) do
    arrow_body = String.pad_trailing(String.slice(text, 0, width - 5), width - 5)
    line = "─" <> arrow_body <> "─▶"
    Enum.join([line], "\n")
  end
  
  defp generate_arrow("double", width, text) do
    arrow_body = String.pad_trailing(String.slice(text, 0, width - 5), width - 5)
    line = "═" <> arrow_body <> "═▶"
    Enum.join([line], "\n")
  end
  
  defp generate_arrow("rounded", width, text) do
    arrow_body = String.pad_trailing(String.slice(text, 0, width - 5), width - 5)
    line = "─" <> arrow_body <> "─►"
    Enum.join([line], "\n")
  end
  
  defp generate_arrow("heavy", width, text) do
    arrow_body = String.pad_trailing(String.slice(text, 0, width - 5), width - 5)
    line = "━" <> arrow_body <> "━▶"
    Enum.join([line], "\n")
  end
  
  defp generate_arrow("ascii", width, text) do
    arrow_body = String.pad_trailing(String.slice(text, 0, width - 5), width - 5)
    line = "-" <> arrow_body <> "->"
    Enum.join([line], "\n")
  end
  
  # Table generator with different styles
  defp generate_table("single", width, height, text) do
    cell_width = max(5, width / 3)
    col_count = max(1, width / cell_width)
    
    # Create headers and data based on text
    parts = String.split(text, ",")
    headers = Enum.take(parts, col_count)
              |> Enum.map(&String.slice(&1, 0, cell_width - 2))
              |> Enum.map(&String.pad_trailing(&1, cell_width - 2))
    
    # Table components
    top = "┌" <> Enum.join(List.duplicate(String.duplicate("─", cell_width - 2), col_count), "┬") <> "┐"
    header_row = "│ " <> Enum.join(headers, " │ ") <> " │"
    separator = "├" <> Enum.join(List.duplicate(String.duplicate("─", cell_width - 2), col_count), "┼") <> "┤"
    
    # Generate data rows
    data_rows = for row_index <- 1..(height - 3) do
      data_cells = for col_index <- 1..col_count do
        data_index = col_count * row_index + col_index - 1
        if data_index < length(parts) do
          String.slice(Enum.at(parts, data_index, ""), 0, cell_width - 2)
          |> String.pad_trailing(cell_width - 2)
        else
          String.duplicate(" ", cell_width - 2)
        end
      end
      "│ " <> Enum.join(data_cells, " │ ") <> " │"
    end
    
    bottom = "└" <> Enum.join(List.duplicate(String.duplicate("─", cell_width - 2), col_count), "┴") <> "┘"
    
    # Combine all parts
    lines = [top, header_row, separator] ++ data_rows ++ [bottom]
    Enum.join(lines, "\n")
  end
  
  defp generate_table("double", width, height, text) do
    cell_width = max(5, width / 3)
    col_count = max(1, width / cell_width)
    
    # Create headers and data based on text
    parts = String.split(text, ",")
    headers = Enum.take(parts, col_count)
              |> Enum.map(&String.slice(&1, 0, cell_width - 2))
              |> Enum.map(&String.pad_trailing(&1, cell_width - 2))
    
    # Table components
    top = "╔" <> Enum.join(List.duplicate(String.duplicate("═", cell_width - 2), col_count), "╦") <> "╗"
    header_row = "║ " <> Enum.join(headers, " ║ ") <> " ║"
    separator = "╠" <> Enum.join(List.duplicate(String.duplicate("═", cell_width - 2), col_count), "╬") <> "╣"
    
    # Generate data rows
    data_rows = for row_index <- 1..(height - 3) do
      data_cells = for col_index <- 1..col_count do
        data_index = col_count * row_index + col_index - 1
        if data_index < length(parts) do
          String.slice(Enum.at(parts, data_index, ""), 0, cell_width - 2)
          |> String.pad_trailing(cell_width - 2)
        else
          String.duplicate(" ", cell_width - 2)
        end
      end
      "║ " <> Enum.join(data_cells, " ║ ") <> " ║"
    end
    
    bottom = "╚" <> Enum.join(List.duplicate(String.duplicate("═", cell_width - 2), col_count), "╩") <> "╝"
    
    # Combine all parts
    lines = [top, header_row, separator] ++ data_rows ++ [bottom]
    Enum.join(lines, "\n")
  end
  
  # Simplified implementations for other table styles
  defp generate_table(_style, width, height, text) do
    generate_table("single", width, height, text)
  end

  # Banner generator 
  defp generate_banner(style, width, text) do
    trimmed_text = String.slice(text, 0, width - 4)
    padded_text = String.pad_trailing(trimmed_text, width - 4)
    
    case style do
      "single" ->
        [
          "┌" <> String.duplicate("─", width - 2) <> "┐",
          "│ " <> padded_text <> " │",
          "└" <> String.duplicate("─", width - 2) <> "┘"
        ] |> Enum.join("\n")
        
      "double" ->
        [
          "╔" <> String.duplicate("═", width - 2) <> "╗",
          "║ " <> padded_text <> " ║",
          "╚" <> String.duplicate("═", width - 2) <> "╝"
        ] |> Enum.join("\n")
        
      "heavy" ->
        [
          "┏" <> String.duplicate("━", width - 2) <> "┓",
          "┃ " <> padded_text <> " ┃",
          "┗" <> String.duplicate("━", width - 2) <> "┛"
        ] |> Enum.join("\n")
        
      "rounded" ->
        [
          "╭" <> String.duplicate("─", width - 2) <> "╮",
          "│ " <> padded_text <> " │",
          "╰" <> String.duplicate("─", width - 2) <> "╯"
        ] |> Enum.join("\n")
        
      _ -> # ASCII
        [
          "+" <> String.duplicate("-", width - 2) <> "+",
          "| " <> padded_text <> " |",
          "+" <> String.duplicate("-", width - 2) <> "+"
        ] |> Enum.join("\n")
    end
  end

  # Frame generator
  defp generate_frame(style, width, height, text) do
    text_lines = String.split(text, ",")
    
    # Calculate how many lines we can display
    max_lines = min(length(text_lines), height - 2)
    displayed_lines = Enum.take(text_lines, max_lines)
    
    # Prepare the content lines with proper padding
    content_lines = Enum.map(displayed_lines, fn line ->
      trimmed = String.slice(line, 0, width - 4)
      String.pad_trailing(trimmed, width - 4)
    end)
    
    # Add empty lines if needed
    content_lines = content_lines ++ List.duplicate(String.duplicate(" ", width - 4), height - 2 - length(content_lines))
    
    case style do
      "single" ->
        top = "┌" <> String.duplicate("─", width - 2) <> "┐"
        middle = Enum.map(content_lines, fn line -> "│ " <> line <> " │" end)
        bottom = "└" <> String.duplicate("─", width - 2) <> "┘"
        
        [top] ++ middle ++ [bottom] |> Enum.join("\n")
        
      "double" ->
        top = "╔" <> String.duplicate("═", width - 2) <> "╗"
        middle = Enum.map(content_lines, fn line -> "║ " <> line <> " ║" end)
        bottom = "╚" <> String.duplicate("═", width - 2) <> "╝"
        
        [top] ++ middle ++ [bottom] |> Enum.join("\n")
        
      "rounded" ->
        top = "╭" <> String.duplicate("─", width - 2) <> "╮"
        middle = Enum.map(content_lines, fn line -> "│ " <> line <> " │" end)
        bottom = "╰" <> String.duplicate("─", width - 2) <> "╯"
        
        [top] ++ middle ++ [bottom] |> Enum.join("\n")
        
      "heavy" ->
        top = "┏" <> String.duplicate("━", width - 2) <> "┓"
        middle = Enum.map(content_lines, fn line -> "┃ " <> line <> " ┃" end)
        bottom = "┗" <> String.duplicate("━", width - 2) <> "┛"
        
        [top] ++ middle ++ [bottom] |> Enum.join("\n")
        
      _ -> # ASCII
        top = "+" <> String.duplicate("-", width - 2) <> "+"
        middle = Enum.map(content_lines, fn line -> "| " <> line <> " |" end)
        bottom = "+" <> String.duplicate("-", width - 2) <> "+"
        
        [top] ++ middle ++ [bottom] |> Enum.join("\n")
    end
  end

  # List generator
  defp generate_list(style, width, text) do
    items = String.split(text, ",")
    
    bullet = case style do
      "single" -> "• "
      "double" -> "◆ "
      "rounded" -> "○ "
      "heavy" -> "■ "
      _ -> "* "
    end
    
    lines = Enum.map(items, fn item ->
      trimmed = String.slice(item, 0, width - 4)
      bullet <> String.pad_trailing(String.trim(trimmed), width - 4)
    end)
    
    Enum.join(lines, "\n")
  end

  # Badge generator
  defp generate_badge(style, width, text) do
    parts = String.split(text, ":", parts: 2)
    
    label = if length(parts) > 0, do: Enum.at(parts, 0, ""), else: ""
    value = if length(parts) > 1, do: Enum.at(parts, 1, ""), else: ""
    
    # Trim to fit within width
    label_max = min(String.length(label), div(width, 2) - 2)
    value_max = min(String.length(value), div(width, 2) - 2)
    
    trimmed_label = String.slice(label, 0, label_max)
    trimmed_value = String.slice(value, 0, value_max)
    
    case style do
      "single" ->
        "┌" <> String.duplicate("─", String.length(trimmed_label) + 2) <> 
        "┬" <> String.duplicate("─", String.length(trimmed_value) + 2) <> "┐\n" <>
        "│ " <> trimmed_label <> " │ " <> trimmed_value <> " │\n" <>
        "└" <> String.duplicate("─", String.length(trimmed_label) + 2) <> 
        "┴" <> String.duplicate("─", String.length(trimmed_value) + 2) <> "┘"
        
      "double" ->
        "╔" <> String.duplicate("═", String.length(trimmed_label) + 2) <> 
        "╦" <> String.duplicate("═", String.length(trimmed_value) + 2) <> "╗\n" <>
        "║ " <> trimmed_label <> " ║ " <> trimmed_value <> " ║\n" <>
        "╚" <> String.duplicate("═", String.length(trimmed_label) + 2) <> 
        "╩" <> String.duplicate("═", String.length(trimmed_value) + 2) <> "╝"
        
      "rounded" ->
        "╭" <> String.duplicate("─", String.length(trimmed_label) + 2) <> 
        "┬" <> String.duplicate("─", String.length(trimmed_value) + 2) <> "╮\n" <>
        "│ " <> trimmed_label <> " │ " <> trimmed_value <> " │\n" <>
        "╰" <> String.duplicate("─", String.length(trimmed_label) + 2) <> 
        "┴" <> String.duplicate("─", String.length(trimmed_value) + 2) <> "╯"
        
      "heavy" ->
        "┏" <> String.duplicate("━", String.length(trimmed_label) + 2) <> 
        "┳" <> String.duplicate("━", String.length(trimmed_value) + 2) <> "┓\n" <>
        "┃ " <> trimmed_label <> " ┃ " <> trimmed_value <> " ┃\n" <>
        "┗" <> String.duplicate("━", String.length(trimmed_label) + 2) <> 
        "┻" <> String.duplicate("━", String.length(trimmed_value) + 2) <> "┛"
        
      _ -> # ASCII
        "+" <> String.duplicate("-", String.length(trimmed_label) + 2) <> 
        "+" <> String.duplicate("-", String.length(trimmed_value) + 2) <> "+\n" <>
        "| " <> trimmed_label <> " | " <> trimmed_value <> " |\n" <>
        "+" <> String.duplicate("-", String.length(trimmed_label) + 2) <> 
        "+" <> String.duplicate("-", String.length(trimmed_value) + 2) <> "+"
    end
  end
end
