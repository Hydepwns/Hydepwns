defmodule HydepwnsLiveviewWeb.Helpers.TocHelper do
  @moduledoc """
  Helper module for generating Table of Contents (TOC) from HTML content.

  This module provides functionality to:
  1. Parse HTML content and extract heading elements (h2, h3, h4, etc.)
  2. Build a hierarchical TOC structure
  3. Generate TOC items with proper nesting and relationships

  Used to automatically generate TOC instead of manual definition in LiveViews.
  """

  @doc """
  Extracts headings from HTML content and generates a hierarchical table of contents.

  ## Parameters

  * `html_content` - String containing HTML content with heading elements
  * `opts` - Options for customizing the TOC generation:
    * `:min_level` - Minimum heading level to include (default: 2 for h2)
    * `:max_level` - Maximum heading level to include (default: 4 for h4)
    * `:id_prefix` - Prefix to add to heading IDs if needed (default: "")

  ## Returns

  A nested map structure representing the TOC with the following format:
  ```
  [
    %{
      id: "section-id",
      label: "Section Title",
      level: 2,
      children: [
        %{
          id: "subsection-id",
          label: "Subsection Title",
          level: 3,
          children: []
        }
      ]
    },
    ...
  ]
  ```

  ## Examples

  ```elixir
  html_content = "
    <h2 id='intro'>Introduction</h2>
    <p>Some content</p>
    <h3 id='background'>Background</h3>
    <p>More content</p>
    <h2 id='features'>Features</h2>
  "

  TocHelper.generate_toc(html_content)
  # Returns:
  # [
  #   %{id: "intro", label: "Introduction", level: 2, children: [
  #     %{id: "background", label: "Background", level: 3, children: []}
  #   ]},
  #   %{id: "features", label: "Features", level: 2, children: []}
  # ]
  ```
  """
  def generate_toc(html_content, opts \\ []) do
    min_level = Keyword.get(opts, :min_level, 2)
    max_level = Keyword.get(opts, :max_level, 4)
    id_prefix = Keyword.get(opts, :id_prefix, "")

    # Extract headings from the HTML content
    headings = extract_headings(html_content, min_level, max_level)

    # Build hierarchical TOC structure
    build_toc_hierarchy(headings, id_prefix)
  end

  @doc """
  Extracts heading elements from HTML content.

  Returns a list of maps with heading information: id, text, level.
  """
  def extract_headings(html_content, min_level, max_level) do
    # Create a regex pattern to match heading elements
    # This pattern:
    # 1. Matches <h2> to <h6> tags with optional attributes
    # 2. Captures the heading level, id attribute, and content text
    heading_pattern =
      ~r/<h([#{min_level}-#{max_level}])(?:\s+[^>]*?id=["']([^"']*)["'][^>]*?|[^>]*?)>(.*?)<\/h\1>/si

    # Find all matches in the HTML content
    Regex.scan(heading_pattern, html_content, capture: :all_but_first)
    |> Enum.map(fn match ->
      case match do
        [level, id, content] ->
          %{
            level: String.to_integer(level),
            id: id,
            label: sanitize_heading_text(content)
          }

        [level, "", content] ->
          # If no ID is provided, generate a slug from the content
          id = generate_id_from_text(content)

          %{
            level: String.to_integer(level),
            id: id,
            label: sanitize_heading_text(content)
          }
      end
    end)
  end

  @doc """
  Builds a hierarchical TOC structure from a flat list of headings.

  Creates proper parent-child relationships based on heading levels.
  """
  def build_toc_hierarchy(headings, id_prefix) do
    # Apply ID prefix if provided
    headings_with_prefix =
      Enum.map(headings, fn heading ->
        Map.update!(heading, :id, fn id -> id_prefix <> id end)
      end)

    # Build the hierarchy
    build_hierarchy(headings_with_prefix)
  end

  # Private helper function to build the hierarchy recursively
  defp build_hierarchy(headings, current_level \\ nil) do
    # If no more headings or current level is nil, return empty list
    if headings == [] or current_level == nil do
      {[], []}
    else
      # Get the current heading level to process
      process_level = if current_level == nil, do: List.first(headings).level, else: current_level

      # Process headings at the current level
      process_hierarchy(headings, [], [], process_level)
    end
    |> elem(0)
  end

  # Process each heading and build hierarchy
  defp process_hierarchy([], processed, result, _level), do: {result, processed}

  defp process_hierarchy([h | t], processed, result, level) do
    cond do
      # Current heading is at our target level - add to results
      h.level == level ->
        # Process remaining headings at current level
        {children, remaining} = build_hierarchy(t, h.level + 1)
        # Create TOC item with children
        current_item = Map.put(h, :children, children)
        # Continue processing the rest
        process_hierarchy(remaining, [], result ++ [current_item], level)

      # Heading is at a deeper level - process in a child context
      h.level > level ->
        # Put this heading back to be processed in a child context
        {_remaining, processed_new} = process_hierarchy(t, [h | processed], [], level)
        {result, processed_new}

      # Heading is at a higher level - return to parent context
      h.level < level ->
        # Return to parent with this heading as part of processed
        {result, [h | t] ++ processed}
    end
  end

  @doc """
  Sanitizes heading text content by removing HTML tags and normalizing whitespace.
  """
  def sanitize_heading_text(content) do
    content
    # Remove HTML tags
    |> String.replace(~r/<[^>]*>/, "")
    # Trim whitespace
    |> String.trim()
  end

  @doc """
  Generates an ID slug from heading text content.

  This is used when a heading doesn't already have an ID attribute.
  """
  def generate_id_from_text(content) do
    content
    |> sanitize_heading_text()
    |> String.downcase()
    # Remove special characters
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    # Replace spaces with hyphens
    |> String.replace(~r/\s+/, "-")
  end

  @doc """
  Converts the hierarchical TOC to a flat list format for simpler rendering.

  Useful when you don't need the full hierarchy but need level information.

  ## Example

  ```elixir
  toc = TocHelper.generate_toc(html_content)
  flat_toc = TocHelper.flatten_toc(toc)
  # Returns a list of %{id: "...", label: "...", level: n} items
  ```
  """
  def flatten_toc(toc, acc \\ []) do
    Enum.reduce(toc, acc, fn item, items ->
      # Add current item (without children) to the accumulator
      current = Map.delete(item, :children)
      # Process children (if any) and append to result
      children_items = flatten_toc(Map.get(item, :children, []), [])
      items ++ [current] ++ children_items
    end)
  end
end
