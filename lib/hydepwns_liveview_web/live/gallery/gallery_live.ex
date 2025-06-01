defmodule HydepwnsLiveviewWeb.GalleryLive do
  use HydepwnsLiveviewWeb.BaseLive,
    required_assigns: [
      :page_title,
      :theme_class,
      :show_toc,
      :toc_items,
      :images
    ]

  import HydepwnsLiveviewWeb.ResponsiveImageHelper
  alias HydepwnsLiveviewWeb.Helpers.PathHelper

  @impl true
  def do_mount(_params, _session, socket) do
    images = [
      %{
        path: "/images/foxmask.png",
        title: "Fox Mask",
        description: "An artistic rendering of a stylized fox mask."
      },
      %{
        path: "/images/foxheist1.png",
        title: "Fox Heist",
        description: "Illustration of foxes planning a heist."
      },
      %{
        path: "/images/foxoffice.jpeg",
        title: "Fox Office",
        description: "A fox in an office setting."
      }
    ]
    default_theme = HydepwnsLiveview.ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    socket
    |> PathHelper.assign_specific_path("/gallery")
    |> assign(:page_title, "Image Gallery")
    |> assign(:theme_class, theme_class)
    |> assign(:show_toc, true)
    |> assign(:toc_items, [
      {"gallery", "Image Gallery"},
      {"responsive", "Responsive Images"},
      {"optimization", "Image Optimization"}
    ])
    |> assign(:images, images)
  end

  @impl true
  def handle_event("filter_gallery", %{"filter" => filter}, socket) do
    filtered_items =
      if filter == "all" do
        socket.assigns.all_gallery_items
      else
        Enum.filter(socket.assigns.all_gallery_items, fn item ->
          item.category == filter
        end)
      end

    {:noreply, assign(socket, :gallery_items, filtered_items)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <h2 id="gallery">Image Gallery</h2>
      <p>
        This gallery showcases optimized images using WebP format with fallbacks for browsers
        that don't support it. The images are automatically served in the most optimal format.
      </p>

      <div class="gallery-grid">
        <%= for image <- @images do %>
          <div class="gallery-item">
            <div class="image-container">
              {responsive_image_tag(image.path,
                alt: image.title,
                class: "gallery-image",
                sizes: "(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
              )}
            </div>
            <h3>{image.title}</h3>
            <p>{image.description}</p>
          </div>
        <% end %>
      </div>

      <h3 id="responsive">Responsive Images</h3>
      <p>
        All images in this gallery are served in multiple sizes and formats to optimize for:
      </p>

      <ul>
        <li><strong>Screen size:</strong> Multiple image sizes from 320px to 1920px wide</li>
        <li>
          <strong>Network conditions:</strong> Different quality levels for various connection speeds
        </li>
        <li>
          <strong>Browser support:</strong> WebP for modern browsers, PNG/JPEG fallbacks for older browsers
        </li>
        <li><strong>Performance:</strong> Lazy loading for images that are off-screen initially</li>
      </ul>

      <div class="code-explanation">
        <h4>How responsive images work</h4>
        <p>
          Using the HTML <code>picture</code> element with <code>source</code> elements that have <code>srcset</code> and <code>sizes</code> attributes,
          we can provide multiple image options to the browser:
        </p>
        <pre><code>&lt;picture&gt;
          &lt;source 
            type="image/webp"
            srcset="/images/example-320w.webp 320w, /images/example-640w.webp 640w, /images/example-1280w.webp 1280w"
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"&gt;
          &lt;source 
            type="image/png"
            srcset="/images/example-320w.png 320w, /images/example-640w.png 640w, /images/example-1280w.png 1280w"
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"&gt;
          &lt;img src="/images/example.png" alt="Example image" loading="lazy"&gt;
        &lt;/picture&gt;</code></pre>
        <p>
          The browser selects the most appropriate image based on:
        </p>
        <ul>
          <li>The device's screen size and pixel density</li>
          <li>The network connection speed (when Save-Data header is present)</li>
          <li>The browser's supported image formats</li>
        </ul>
      </div>

      <h3 id="optimization">Image Optimization</h3>
      <p>
        All images are automatically served in WebP format when supported by the browser,
        with fallbacks to the original format (PNG, JPEG) for older browsers.
      </p>

      <h4>Benefits of WebP</h4>
      <ul>
        <li>30-80% smaller file sizes compared to PNG and JPEG</li>
        <li>Support for transparency like PNG</li>
        <li>Better compression than JPEG for photographic images</li>
        <li>Improved page load times and performance</li>
      </ul>
    </section>
    """
  end
end
