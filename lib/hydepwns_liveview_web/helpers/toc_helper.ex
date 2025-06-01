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
      ~r/<h([#{min_level}-#{max_level}])(?:\s+[^>]*?id=["\']([^"\']*)["\']|[^>]*?)>(.*?)<\/h\1>/si

    # Find all matches in the HTML content
    Regex.scan(heading_pattern, html_content, capture: :all_but_first)
    |> Enum.map(fn match ->
      case match do
        [level, id, content] when id != nil and id != "" ->
          %{
            level: String.to_integer(level),
            id: id,
            label: sanitize_heading_text(content)
          }

        # Handles cases where id is nil or empty string
        [level, _id, content] ->
          # If no ID is provided, generate a slug from the content
          generated_id = generate_id_from_text(content)

          %{
            level: String.to_integer(level),
            id: generated_id,
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
    if Enum.empty?(headings) do
      []
    else
      headings_with_prefix =
        Enum.map(headings, fn heading ->
          Map.update!(heading, :id, fn id -> id_prefix <> id end)
        end)

      # Determine the shallowest level among the provided headings
      # The parent_level for the root call should be one less than this.
      min_level_present = Enum.min_by(headings_with_prefix, & &1.level).level
      initial_parent_level = min_level_present - 1

      {children, _remaining_headings} =
        do_build_hierarchy(headings_with_prefix, initial_parent_level)

      children
    end
  end

  # Recursive helper to build the hierarchy.
  # `parent_level` is the level of the parent under which we are looking for children.
  defp do_build_hierarchy([], _parent_level) do
    # Base case: no headings left, return empty children and empty remaining
    {[], []}
  end

  defp do_build_hierarchy([current_heading | rest_headings], parent_level) do
    # If the current heading is a direct child of the parent_level
    if current_heading.level == parent_level + 1 do
      # Recursively find children for the current_heading (its level is current_heading.level)
      {children_of_current, remaining_after_children} =
        do_build_hierarchy(rest_headings, current_heading.level)

      # Add the current heading (with its children) to the list of siblings
      node_with_children = Map.put(current_heading, :children, children_of_current)

      # Continue processing for more siblings at the same parent_level
      {other_siblings, remaining_after_siblings} =
        do_build_hierarchy(remaining_after_children, parent_level)

      {[node_with_children | other_siblings], remaining_after_siblings}
    else
      # If the current heading is not a direct child (either deeper or shallower),
      # it means we are done finding children for the *current* parent_level.
      # Return an empty list of children for this level, and pass back the
      # current_heading and rest_headings to be processed by the caller
      # (which might be looking for headings at a different level).
      {[], [current_heading | rest_headings]}
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
