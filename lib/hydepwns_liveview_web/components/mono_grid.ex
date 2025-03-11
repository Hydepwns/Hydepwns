defmodule HydepwnsLiveviewWeb.Components.MonoGrid do
  @moduledoc """
  # MonoGrid

  Provides a grid system designed specifically for monospace layouts.

  ## Overview

  The MonoGrid component creates a CSS grid-based layout system that aligns content
  to a character grid, ensuring pixel-perfect alignment of monospace text. This is
  essential for creating terminal-like interfaces and ASCII art displays.

  The grid system uses character units (ch) for width and consistent line-height for
  row height, ensuring that text aligns perfectly across cells and rows.

  ## Examples

  ```heex
  <MonoGrid.grid id="example-grid" cols={80} rows={24}>
    <MonoGrid.cell row={1} col={1} colspan={80}>
      Header content
    </MonoGrid.cell>
    <MonoGrid.cell row={2} col={1} colspan={40}>
      Left column
    </MonoGrid.cell>
    <MonoGrid.cell row={2} col={41} colspan={40}>
      Right column
    </MonoGrid.cell>
  </MonoGrid.grid>
  ```

  ## Props/Attributes

  | Name | Type | Default | Required | Description |
  |------|------|---------|----------|-------------|
  | `id` | `string` | `nil` | Yes | Unique identifier for the grid |
  | `cols` | `integer` | `80` | No | Number of columns in the grid |
  | `rows` | `integer` | `nil` | No | Number of rows in the grid (optional) |
  | `bordered` | `boolean` | `false` | No | Whether to display a border around the grid |
  | `debug` | `boolean` | `false` | No | Whether to show debug grid lines |
  | `container` | `atom` | `:div` | No | HTML element to use as container (`:div` or `:pre`) |
  | `class` | `string` | `nil` | No | Additional CSS classes to apply |

  ## Accessibility

  The MonoGrid component is designed to maintain proper accessibility:
  - Preserves semantic HTML structure
  - Maintains proper focus order based on document flow
  - Supports screen readers by preserving content hierarchy

  ## Theming

  The grid system adapts to the current theme automatically. The following CSS variables affect its appearance:
  - `--mono-grid-cell-width`: Width of a single cell (default: 1ch)
  - `--mono-grid-cell-height`: Height of a single cell (default: 1.5rem)
  - `--mono-grid-border-color`: Border color when bordered option is enabled

  ## Browser Compatibility

  The component uses CSS Grid which is supported in all modern browsers. For older browsers,
  a fallback layout is provided that maintains readability but may not preserve perfect alignment.

  ## Related Components

  - `HydepwnsLiveviewWeb.Components.Visualization.AsciiArtGenerator` - Uses MonoGrid for layout
  - `HydepwnsLiveviewWeb.Components.Interactive.Terminal` - Uses MonoGrid for terminal display

  ## Changelog

  | Version | Changes |
  |---------|---------|
  | 0.2.0   | Added container option and improved debug mode |
  | 0.1.0   | Initial implementation |
  """
  use Phoenix.Component
  use PhoenixHTMLHelpers

  # Default grid properties
  @default_cols 80
  # Character width unit
  @default_cell_width "1ch"
  # Default line height
  @default_cell_height "1.5rem"

  @doc """
  Renders a monospace grid container.

  ## Examples

  ```heex
  <MonoGrid.grid id="example-grid" cols={80}>
    Content that will respect the monospace grid
  </MonoGrid.grid>

  <MonoGrid.grid id="debug-grid" cols={40} debug={true}>
    Grid with debugging overlay
  </MonoGrid.grid>

  <MonoGrid.grid id="pre-grid" cols={60} container={:pre}>
    Pre-formatted text that preserves whitespace
  </MonoGrid.grid>
  ```

  ## Attributes

  | Name | Type | Default | Required | Description |
  |------|------|---------|----------|-------------|
  | `id` | `string` | `nil` | No | Unique identifier for the grid |
  | `class` | `string` | `nil` | No | Additional CSS classes to add to the grid container |
  | `cols` | `integer` | `#{@default_cols}` | No | Number of columns in the grid |
  | `cell_width` | `string` | `"#{@default_cell_width}"` | No | Width of each cell |
  | `cell_height` | `string` | `"#{@default_cell_height}"` | No | Height of each cell |
  | `debug` | `boolean` | `false` | No | When true, shows grid lines for debugging |
  | `container` | `atom` | `:div` | No | Container type: `:div`, `:pre`, or `:code` |

  ## Slots

  | Name | Description |
  |------|-------------|
  | `:default` | The default slot for grid content |

  ## Returns

  HEEx template rendering the grid container with the specified attributes.
  """
  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :cols, :integer, default: @default_cols
  attr :cell_width, :string, default: @default_cell_width
  attr :cell_height, :string, default: @default_cell_height
  attr :debug, :boolean, default: false
  attr :container, :atom, default: :div, values: [:div, :pre, :code]
  attr :rest, :global

  slot :inner_block, required: true

  def mono_grid(assigns) do
    ~H"""
    <.custom_dynamic_tag
      name={@container}
      id={@id}
      class={[
        "mono-grid",
        @debug && "mono-grid--debug",
        @class
      ]}
      style={grid_style(@cols, @cell_width, @cell_height)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.custom_dynamic_tag>
    """
  end

  @doc """
  Renders a row within the monospace grid system.

  ## Attributes

  * `id` - Optional unique identifier for this row
  * `class` - Additional CSS classes to add to the row
  * `debug` - When true, shows grid lines for debugging (default: false)
  * `rest` - Additional attributes to add to the row element
  """
  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :debug, :boolean, default: false
  attr :rest, :global

  slot :inner_block, required: true

  def mono_grid_row(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "mono-grid-row",
        @debug && "mono-grid-row--debug",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a cell within the monospace grid system.

  ## Attributes

  * `id` - Optional unique identifier for this cell
  * `class` - Additional CSS classes to add to the cell
  * `cols` - Number of columns this cell spans (default: 1)
  * `rows` - Number of rows this cell spans (default: 1)
  * `debug` - When true, shows grid lines for debugging (default: false)
  * `align` - Text alignment within the cell: :left, :center, :right (default: :left)
  * `rest` - Additional attributes to add to the cell element
  """
  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :cols, :integer, default: 1
  attr :rows, :integer, default: 1
  attr :debug, :boolean, default: false
  attr :align, :atom, default: :left, values: [:left, :center, :right]
  attr :rest, :global

  slot :inner_block, required: true

  def mono_grid_cell(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "mono-grid-cell",
        @debug && "mono-grid-cell--debug",
        @align == :center && "mono-grid-cell--center",
        @align == :right && "mono-grid-cell--right",
        @class
      ]}
      style={cell_style(@cols, @rows)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a helper component that ensures text aligns properly on the grid.

  ## Attributes

  * `id` - Optional unique identifier 
  * `class` - Additional CSS classes
  * `style` - Additional inline styles
  * `padding` - Padding in character units (format: "top right bottom left")
  * `rest` - Additional attributes
  """
  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :style, :string, default: nil
  attr :padding, :string, default: "0 0 0 0"
  attr :rest, :global

  slot :inner_block, required: true

  def mono_text(assigns) do
    ~H"""
    <span id={@id} class={["mono-text", @class]} style={text_style(@style, @padding)} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  # Helper function for rendering dynamic HTML tags
  def custom_dynamic_tag(assigns) do
    tag = assigns[:name] || :div
    attrs_map = assigns |> Map.drop([:name, :inner_block, :tag]) |> Map.to_list()

    assigns = assign(assigns, :tag, tag)
    assigns = assign(assigns, :attrs_map, attrs_map)

    ~H"""
    {PhoenixHTMLHelpers.Tag.content_tag(@tag, render_slot(@inner_block), @attrs_map)}
    """
  end

  # Helper function to generate grid container styles
  defp grid_style(cols, cell_width, cell_height) do
    """
    --mono-grid-cols: #{cols};
    --mono-grid-cell-width: #{cell_width};
    --mono-grid-cell-height: #{cell_height};
    grid-template-columns: repeat(var(--mono-grid-cols), var(--mono-grid-cell-width));
    """
  end

  # Helper function to generate cell styles
  defp cell_style(cols, rows) do
    """
    grid-column: span #{cols};
    grid-row: span #{rows};
    """
  end

  # Helper function to generate text styles with padding
  defp text_style(base_style, padding) do
    [top, right, bottom, left] = String.split(padding, " ", trim: true)

    padding_style = """
    padding-top: #{top}ch;
    padding-right: #{right}ch;
    padding-bottom: #{bottom}ch;
    padding-left: #{left}ch;
    """

    if base_style, do: base_style <> padding_style, else: padding_style
  end

  # Public helper function to calculate character-based width
  @doc """
  Converts a string or content to its character width.
  Useful for determining exact monospace grid dimensions.

  ## Examples

      iex> MonoGrid.char_width("Hello")
      5
      
      iex> MonoGrid.char_width(["Hello", "World"])
      10
  """
  def char_width(content) when is_binary(content) do
    String.length(content)
  end

  def char_width(content) when is_list(content) do
    content
    |> Enum.map(&char_width/1)
    |> Enum.sum()
  end

  # Public debug helper
  @doc """
  Returns a debug representation of content with its grid dimensions.
  Useful for visualizing how content will appear in the grid.

  ## Examples

      iex> MonoGrid.debug_dimensions("Hello World")
      "Hello World [11×1]"
  """
  def debug_dimensions(content) when is_binary(content) do
    width = char_width(content)
    lines = String.split(content, "\n")
    height = length(lines)

    "#{content} [#{width}×#{height}]"
  end
end
