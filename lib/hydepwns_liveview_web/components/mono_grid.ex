defmodule HydepwnsLiveviewWeb.Components.MonoGrid do
  @moduledoc """
  A grid system component that maintains proper character alignment for monospace text.
  
  This component provides:
  - Precise character grid alignment using ch units
  - Responsive behavior that preserves monospace aesthetics
  - Debug visualization mode for grid alignment debugging
  - Helper functions for maintaining consistent spacing
  
  ## Examples

      <.mono_grid>
        Content that will respect the monospace grid
      </.mono_grid>

      <.mono_grid cols={80} debug={true}>
        Grid with debugging overlay
      </.mono_grid>

      <.mono_grid_row>
        A single row in the grid system
      </.mono_grid_row>

      <.mono_grid_cell cols={3}>
        A cell spanning 3 columns
      </.mono_grid_cell>
  """
  use Phoenix.Component
  import Phoenix.HTML
  use PhoenixHTMLHelpers

  # Default grid properties
  @default_cols 80
  @default_cell_width "1ch" # Character width unit
  @default_cell_height "1.5rem" # Default line height

  @doc """
  Renders a monospace grid container.
  
  ## Attributes
  
  * `id` - Optional unique identifier for this grid instance
  * `class` - Additional CSS classes to add to the grid container
  * `cols` - Number of columns in the grid (default: #{@default_cols})
  * `cell_width` - Width of each cell (default: #{@default_cell_width})
  * `cell_height` - Height of each cell (default: #{@default_cell_height})
  * `debug` - When true, shows grid lines for debugging (default: false)
  * `container` - Container type: :div, :pre, :code (default: :div)
  * `rest` - Additional attributes to add to the container element
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
      <%= render_slot(@inner_block) %>
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
      <%= render_slot(@inner_block) %>
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
      <%= render_slot(@inner_block) %>
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
    <span
      id={@id}
      class={["mono-text", @class]}
      style={text_style(@style, @padding)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  # Helper function for rendering dynamic HTML tags
  defp custom_dynamic_tag(assigns) do
    tag = assigns[:name] || :div
    attrs = assigns |> Map.drop([:name, :inner_block, :tag]) |> Map.to_list()
    
    assigns = assign(assigns, :tag, tag)
    
    ~H"""
    <%= PhoenixHTMLHelpers.Tag.content_tag(@tag, render_slot(@inner_block), attrs) %>
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