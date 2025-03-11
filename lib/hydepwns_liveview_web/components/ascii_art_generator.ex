defmodule HydepwnsLiveviewWeb.Components.AsciiArtGenerator do
  use Phoenix.LiveComponent
  import Phoenix.HTML
  import Phoenix.HTML.Form
  use PhoenixHTMLHelpers

  @moduledoc """
  A component for generating ASCII art with various templates and customization options.
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
              <option value="custom">Custom</option>
            </select>
          </div>

          <div class="form-group">
            <label for={"#{@id}-style"}>Style</label>
            <select id={"#{@id}-style"} name="style" value={@style}>
              <option value="single">Single Line</option>
              <option value="double">Double Line</option>
              <option value="rounded">Rounded</option>
            </select>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for={"#{@id}-width"}>Width</label>
            <input type="number" id={"#{@id}-width"} name="width" value={@width} min="3" max="100" />
          </div>

          <div class="form-group">
            <label for={"#{@id}-height"}>Height</label>
            <input type="number" id={"#{@id}-height"} name="height" value={@height} min="1" max="50" />
          </div>
        </div>

        <div class="form-group">
          <label for={"#{@id}-text"}>Text</label>
          <input
            type="text"
            id={"#{@id}-text"}
            name="text"
            value={@text}
            placeholder="Text to include in ASCII art"
          />
        </div>
      </form>

      <div class="preview-section">
        <h3>Preview</h3>
        <pre aria-label={"Generated ASCII art: #{generate_alt_text(@art_type, @text, @width, @height, @style)}"} role="img"><code id={"#{@id}-code"} class="ascii-art" phx-hook="CopyableCode"><%= generate_ascii_art(@art_type, @width, @height, @text, @style) %></code></pre>
        
        <div class="a11y-description">
          <button 
            type="button" 
            class="a11y-description-toggle" 
            aria-expanded="false"
            aria-controls={"#{@id}-description"}
            onclick="toggleA11yDescription(this)"
          >
            Show text description
          </button>
          <div 
            id={"#{@id}-description"} 
            class="a11y-description-text" 
            aria-live="polite"
            hidden
          >
            <%= generate_alt_text(@art_type, @text, @width, @height, @style) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("update_ascii_art", params, socket) do
    {:noreply,
     socket
     |> assign(:art_type, params["art_type"] || socket.assigns.art_type)
     |> assign(:width, String.to_integer(params["width"] || "#{socket.assigns.width}"))
     |> assign(:height, String.to_integer(params["height"] || "#{socket.assigns.height}"))
     |> assign(:text, params["text"] || socket.assigns.text)
     |> assign(:style, params["style"] || socket.assigns.style)}
  end

  defp generate_alt_text(art_type, text, width \\ nil, height \\ nil, style \\ nil) do
    style_desc = case style do
      "single" -> "using single lines"
      "double" -> "using double lines"
      "rounded" -> "with rounded corners"
      _ -> ""
    end

    dimensions = if width && height do
      "with dimensions #{width}x#{height}"
    else
      ""
    end

    case art_type do
      "box" -> 
        if text == "" do 
          "Empty box #{style_desc} #{dimensions}"
        else 
          "Box #{style_desc} #{dimensions} containing text: \"#{text}\""
        end
      "arrow" -> 
        "Arrow #{style_desc} #{dimensions} " <> 
        if text == "", do: "without any text", else: "with text: \"#{text}\""
      "table" -> 
        "Table structure #{style_desc} #{dimensions} " <> 
        if text == "", do: "with empty cells", else: "containing data: \"#{text}\""
      "custom" -> 
        "Custom ASCII art #{dimensions} " <> 
        if text == "", do: "without any text", else: "containing text: \"#{text}\""
      _ -> "ASCII art"
    end
  end

  defp generate_ascii_art(art_type, width, height, text, style) do
    case art_type do
      "box" -> generate_box(width, height, text, style)
      "arrow" -> generate_arrow(width, text, style)
      "table" -> generate_table(width, height, text, style)
      "custom" -> generate_custom(width, height, text)
      _ -> "Invalid art type"
    end
  end

  # Box generation
  defp generate_box(width, height, text, style) do
    # Get the appropriate characters for the selected style
    {top_left, top_right, bottom_left, bottom_right, horizontal, vertical} =
      case style do
        "single" -> {"┌", "┐", "└", "┘", "─", "│"}
        "double" -> {"╔", "╗", "╚", "╝", "═", "║"}
        "rounded" -> {"╭", "╮", "╰", "╯", "─", "│"}
        # Default to single
        _ -> {"┌", "┐", "└", "┘", "─", "│"}
      end

    # Create the top border
    top = top_left <> String.duplicate(horizontal, width - 2) <> top_right <> "\n"

    # Create the content (with text centered if provided)
    content =
      if text == "" do
        String.duplicate(vertical <> String.duplicate(" ", width - 2) <> vertical <> "\n", height)
      else
        # Center the text
        padding_total = width - 2 - String.length(text)
        padding_left = div(padding_total, 2)
        padding_right = padding_total - padding_left

        # Generate middle rows with the text centered in one row
        middle_with_text =
          vertical <>
            String.duplicate(" ", padding_left) <>
            text <> String.duplicate(" ", padding_right) <> vertical <> "\n"

        # Calculate rows before and after the text
        rows_before = div(height - 1, 2)
        rows_after = height - 1 - rows_before

        empty_row = vertical <> String.duplicate(" ", width - 2) <> vertical <> "\n"

        String.duplicate(empty_row, rows_before) <>
          middle_with_text <> String.duplicate(empty_row, rows_after)
      end

    # Create the bottom border
    bottom = bottom_left <> String.duplicate(horizontal, width - 2) <> bottom_right

    # Combine all parts
    top <> content <> bottom
  end

  # Arrow generation
  defp generate_arrow(width, text, style) do
    # Simplified arrow for now
    horizontal =
      case style do
        "single" -> "─"
        "double" -> "═"
        _ -> "─"
      end

    # Create the arrow
    if text == "" do
      "#{String.duplicate(horizontal, width - 2)}>"
    else
      "#{String.duplicate(horizontal, 3)}[ #{text} ]#{String.duplicate(horizontal, max(3, width - 7 - String.length(text)))}>"
    end
  end

  # Table generation
  defp generate_table(width, height, text, style) do
    # Get the appropriate characters for the selected style
    {h_line, v_line, tl, tr, bl, br, cross, t_down, t_up, t_right, t_left} =
      case style do
        "single" -> {"─", "│", "┌", "┐", "└", "┘", "┼", "┬", "┴", "┤", "├"}
        "double" -> {"═", "║", "╔", "╗", "╚", "╝", "╬", "╦", "╩", "╣", "╠"}
        # Default to single
        _ -> {"─", "│", "┌", "┐", "└", "┘", "┼", "┬", "┴", "┤", "├"}
      end

    # For simplicity, create a 2x2 table
    col_width = div(width - 3, 2)
    row_height = div(height - 3, 2)

    # Table parts
    top =
      tl <>
        String.duplicate(h_line, col_width) <>
        t_down <> String.duplicate(h_line, col_width) <> tr <> "\n"

    # First row content (text in first cell if provided)
    first_row_content =
      if text == "" do
        String.duplicate(
          v_line <>
            String.duplicate(" ", col_width) <>
            v_line <> String.duplicate(" ", col_width) <> v_line <> "\n",
          row_height
        )
      else
        # Put text in first cell
        padding_total = col_width - String.length(text)
        padding_left = max(0, div(padding_total, 2))
        padding_right = max(0, padding_total - padding_left)

        first_cell =
          v_line <>
            String.duplicate(" ", padding_left) <> text <> String.duplicate(" ", padding_right)

        second_cell = v_line <> String.duplicate(" ", col_width) <> v_line <> "\n"

        first_row = first_cell <> second_cell

        # Add empty rows to complete the row height
        first_row <>
          String.duplicate(
            v_line <>
              String.duplicate(" ", col_width) <>
              v_line <> String.duplicate(" ", col_width) <> v_line <> "\n",
            row_height - 1
          )
      end

    # Middle divider
    middle =
      t_left <>
        String.duplicate(h_line, col_width) <>
        cross <> String.duplicate(h_line, col_width) <> t_right <> "\n"

    # Second row (empty)
    second_row =
      String.duplicate(
        v_line <>
          String.duplicate(" ", col_width) <>
          v_line <> String.duplicate(" ", col_width) <> v_line <> "\n",
        row_height
      )

    # Bottom
    bottom =
      bl <>
        String.duplicate(h_line, col_width) <> t_up <> String.duplicate(h_line, col_width) <> br

    # Combine all parts
    top <> first_row_content <> middle <> second_row <> bottom
  end

  # Custom ASCII art (placeholder)
  defp generate_custom(width, height, text) do
    # For now, just provide a placeholder with the dimensions and text
    "Custom ASCII Art\n" <>
      "Width: #{width}\n" <>
      "Height: #{height}\n" <>
      "Text: #{text}\n" <>
      "\n" <>
      "This feature is coming soon!"
  end
end
