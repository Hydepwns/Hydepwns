defmodule HydepwnsLiveviewWeb.GalleryLive do
  use HydepwnsLiveviewWeb, :live_view
  import HydepwnsLiveviewWeb.ImageHelper
  import HydepwnsLiveviewWeb.ResponsiveImageHelper

  @impl true
  def mount(_params, _session, socket) do
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

    {:ok,
     socket
     |> assign_current_path()
     |> assign(:page_title, "Image Gallery")
     |> assign(:theme_class, "dark-theme")
     |> assign(:show_toc, true)
     |> assign(:toc_items, [
       {"gallery", "Image Gallery"},
       {"responsive", "Responsive Images"},
       {"optimization", "Image Optimization"}
     ])
     |> assign(:images, images)}
  end

  @impl true
  def handle_event("change_theme", %{"theme" => theme}, socket) do
    theme_class = "#{theme}-theme"
    {:noreply, assign(socket, :theme_class, theme_class)}
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
              <%= responsive_image_tag(image.path, 
                    alt: image.title, 
                    class: "gallery-image",
                    sizes: "(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw") %>
            </div>
            <h3><%= image.title %></h3>
            <p><%= image.description %></p>
          </div>
        <% end %>
      </div>

      <h3 id="responsive">Responsive Images</h3>
      <p>
        All images in this gallery are served in multiple sizes and formats to optimize for:
      </p>

      <ul>
        <li><strong>Screen size:</strong> Multiple image sizes from 320px to 1920px wide</li>
        <li><strong>Network conditions:</strong> Different quality levels for various connection speeds</li>
        <li><strong>Browser support:</strong> WebP for modern browsers, PNG/JPEG fallbacks for older browsers</li>
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