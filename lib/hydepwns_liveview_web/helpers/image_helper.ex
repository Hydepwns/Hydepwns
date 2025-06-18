defmodule HydepwnsLiveviewWeb.ImageHelper do
  @moduledoc """
  Helper functions for optimizing image loading and rendering.
  Provides functionality for serving WebP images with fallbacks.
  """
  # Add alias for Phoenix.HTML.Tag
  alias Phoenix.HTML.Tag

  @doc """
  Generates an HTML picture element with WebP and fallback sources.
  Automatically checks if a WebP version exists, otherwise uses only the original.

  ## Examples
      
      {optimized_image_tag("/images/logo.png", alt: "Logo", class: "header-logo")}

  Will generate:

      <picture>
        <source srcset="/images/logo.webp" type="image/webp">
        <img src="/images/logo.png" alt="Logo" class="header-logo">
      </picture>

  If logo.webp doesn't exist, it will generate just the img tag.
  """
  def optimized_image_tag(image_path, attrs \\ []) do
    # Extract file info
    {path, filename, _ext} = extract_path_info(image_path)
    # Construct the path to the WebP version
    webp_path = "#{path}#{filename}.webp"

    # Get static path (handles fingerprinting)
    original_static_path = static_image_path(image_path)

    # Check if WebP version exists in the filesystem
    webp_exists = webp_file_exists?(webp_path)

    if webp_exists do
      webp_static_path = static_image_path(webp_path)

      # Generate picture tag with WebP and fallback
      Tag.content_tag(:picture, [
        Tag.tag(:source, srcset: webp_static_path, type: "image/webp"),
        Tag.tag(:source, srcset: original_static_path),
        Tag.tag(:img, Keyword.merge([src: original_static_path], attrs))
      ])
    else
      # If WebP doesn't exist, just use the original image
      Tag.tag(:img, Keyword.merge([src: original_static_path], attrs))
    end
  end

  @doc """
  Returns a string with the static path for the given image.
  Handles the static path helpers with proper asset fingerprinting.
  """
  def static_image_path(image_path) do
    HydepwnsLiveviewWeb.Endpoint.static_path(image_path)
  end

  # Private helper to extract path components
  defp extract_path_info(image_path) do
    # Handle paths with or without leading slash
    path = Path.dirname(image_path)
    path = if path == ".", do: "", else: "#{path}/"

    # Get filename and extension
    filename = Path.basename(image_path, Path.extname(image_path))
    ext = Path.extname(image_path)

    {path, filename, ext}
  end

  # Check if the WebP version exists in priv/static
  defp webp_file_exists?(webp_path) do
    static_dir = Application.app_dir(:hydepwns_liveview, "priv/static")
    # Remove leading slash if present
    clean_path = String.replace_leading(webp_path, "/", "")
    webp_file_path = Path.join(static_dir, clean_path)

    File.exists?(webp_file_path)
  end
end
