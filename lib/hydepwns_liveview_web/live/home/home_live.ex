defmodule HydepwnsLiveviewWeb.HomeLive do
  use HydepwnsLiveviewWeb.BaseLive,
    required_assigns: [
      :page_title,
      :theme_class,
      :show_toc,
      :toc_items,
      :toc_data,
      :current_section,
      :animation_speed_class,
      :current_path,
      :terminal_id,
      :show_terminal,
      :viewport_size,
      :terminal_theme,
      :screen_reader_announcements
    ]

  alias HydepwnsLiveviewWeb.Helpers.TocHelper
  alias HydepwnsLiveviewWeb.Helpers.PathHelper
  alias HydepwnsLiveviewWeb.Helpers.ViewportHelper
  alias HydepwnsLiveviewWeb.Components.Interactive.Plugins.Navigation
  import HydepwnsLiveviewWeb.Components.UI.Nav, only: [hierarchical_toc_nav: 1, monospace_nav: 1]
  import HydepwnsLiveviewWeb.Components.UI.ThemeToggle, only: [theme_toggle: 1]
  import HydepwnsLiveviewWeb.Components.UI.DebugGrid, only: [debug_grid: 1]
  import HydepwnsLiveviewWeb.Components.UI.AccessibilityMenu, only: [accessibility_menu: 1]
  # import HydepwnsLiveviewWeb.Components.Interactive.Terminal

  @impl true
  def do_mount(_params, _session, socket) do
    # Initial page content for TOC generation
    page_content = """
    <h2 id="introduction">Introduction</h2>
    <p>Welcome to the Hydepwns monospace interface demonstration...</p>
    <h3 id="background">Background</h3>
    <p>The design is inspired by terminal UIs and uses monospace fonts...</p>
    <h2 id="features">Features</h2>
    <p>Explore the unique features of the Hydepwns monospace interface...</p>
    <h3 id="terminal">Terminal Integration</h3>
    <p>Full terminal emulation with customizable themes and commands...</p>
    <h2 id="animations">Animations</h2>
    <p>Monospace interfaces can be enhanced with subtle animations...</p>
    <h3 id="typewriter">Typewriter Effect</h3>
    <p>The typewriter effect types out text character by character...</p>
    <h3 id="char-fade">Character Fade</h3>
    <p>Characters can fade in individually for a matrix-like effect...</p>
    <h3 id="grid-fade">Grid Fade</h3>
    <p>Elements can fade in cell by cell in a grid pattern...</p>
    """

    # Generate TOC from page content
    toc_data = TocHelper.generate_toc(page_content)

    # Get viewport size
    viewport_size = ViewportHelper.get_viewport_size(socket)

    # Determine the current theme
    theme = get_session_theme(socket)

    socket
    |> PathHelper.assign_specific_path("/")
    |> assign(:page_title, "Home")
    |> assign(:theme_class, "#{theme}-theme")
    |> assign(:terminal_theme, theme)
    |> assign(:show_toc, true)
    |> assign(:toc_items, [
      {"introduction", "Introduction"},
      {"features", "Features"},
      {"terminal", "Terminal Integration"},
      {"animations", "Animations"},
      {"typewriter", "Typewriter Effect"},
      {"char-fade", "Character Fade"},
      {"grid-fade", "Grid Fade"}
    ])
    |> assign(:toc_data, toc_data)
    |> assign(:current_section, nil)
    |> assign(:animation_speed_class, "normal-speed")
    |> assign(:current_path, "/")
    |> assign(:terminal_id, "home-terminal")
    |> assign(:show_terminal, false)
    |> assign(:viewport_size, viewport_size)
    |> assign(:screen_reader_announcements, [])
  end

  @impl true
  def handle_event("toggle_toc", _, socket) do
    {:noreply, assign(socket, :show_toc, !socket.assigns.show_toc)}
  end

  @impl true
  def handle_event("set_animation_speed", %{"speed" => speed}, socket) do
    speed_class =
      case speed do
        "slow" -> "slow-speed"
        "normal" -> "normal-speed"
        "fast" -> "fast-speed"
        _ -> "normal-speed"
      end

    # Add screen reader announcement
    announcement = "Animation speed set to #{speed}"
    announcements = [announcement | socket.assigns.screen_reader_announcements]

    {:noreply,
     socket
     |> assign(:animation_speed_class, speed_class)
     |> assign(:screen_reader_announcements, announcements)}
  end

  @impl true
  def handle_event("replay_animations", _, socket) do
    # Add screen reader announcement
    announcement = "Replaying animations"
    announcements = [announcement | socket.assigns.screen_reader_announcements]

    # Send a custom event to the client to trigger animation replay
    {:noreply,
     socket
     |> assign(:screen_reader_announcements, announcements)
     |> push_event("replay_animations", %{})}
  end

  @impl true
  def handle_event("set_current_section", %{"section" => section}, socket) do
    {:noreply, assign(socket, :current_section, section)}
  end

  @impl true
  def handle_event("toggle_terminal", _, socket) do
    # Add screen reader announcement
    status = if socket.assigns.show_terminal, do: "hidden", else: "shown"
    announcement = "Terminal #{status}"
    announcements = [announcement | socket.assigns.screen_reader_announcements]

    {:noreply,
     socket
     |> assign(:show_terminal, !socket.assigns.show_terminal)
     |> assign(:screen_reader_announcements, announcements)}
  end

  @impl true
  def handle_event("update_terminal_theme", %{"theme" => theme}, socket) do
    {:noreply, assign(socket, :terminal_theme, theme)}
  end

  @impl true
  def handle_event("update_viewport_size", %{"size" => size}, socket) do
    if socket.assigns.viewport_size != size do
      # Add announcement for screen readers when viewport size changes
      announcement = "Viewport size changed to #{size}"

      socket =
        socket
        |> assign(:viewport_size, size)
        |> update(:screen_reader_announcements, fn announcements ->
          [announcement | announcements] |> Enum.take(5)
        end)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("handle_keydown", %{"key" => key, "alt" => true}, socket) do
    case key do
      "t" ->
        # Toggle terminal
        show_terminal = !socket.assigns.show_terminal
        announcement = if show_terminal, do: "Terminal shown", else: "Terminal hidden"
        announcements = [announcement | socket.assigns.screen_reader_announcements]

        {:noreply,
         socket
         |> assign(:show_terminal, show_terminal)
         |> assign(:screen_reader_announcements, announcements)}

      "m" ->
        # Jump to main content and announce
        announcement = "Jumped to main content"
        announcements = [announcement | socket.assigns.screen_reader_announcements]

        {:noreply,
         socket
         |> assign(:screen_reader_announcements, announcements)
         |> push_event("focus_main_content", %{})}

      "s" ->
        # Toggle table of contents
        show_toc = !socket.assigns.show_toc

        announcement =
          if show_toc, do: "Table of contents shown", else: "Table of contents hidden"

        announcements = [announcement | socket.assigns.screen_reader_announcements]

        {:noreply,
         socket
         |> assign(:show_toc, show_toc)
         |> assign(:screen_reader_announcements, announcements)}

      "r" ->
        # Replay animations
        announcement = "Replaying animations"
        announcements = [announcement | socket.assigns.screen_reader_announcements]

        {:noreply,
         socket
         |> assign(:screen_reader_announcements, announcements)
         |> push_event("replay_animations", %{})}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("handle_keydown", _, socket) do
    # Default case for non-special keydowns
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_theme", %{"theme" => theme}, socket) do
    # Updated theme handling to include terminal sync
    socket =
      socket
      |> assign(:theme_class, "#{theme}-theme")
      |> assign(:terminal_theme, theme)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set_text_size", %{"size" => size}, socket) do
    # Add announcement for screen readers
    announcement = "Text size set to #{size}"

    socket =
      socket
      |> update(:screen_reader_announcements, fn announcements ->
        [announcement | announcements] |> Enum.take(5)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set_animation_preference", %{"preference" => preference}, socket) do
    # Set animation speed class based on preference
    animation_speed_class =
      case preference do
        "disabled" -> "animations-disabled"
        "reduced" -> "animations-reduced"
        "enabled" -> ""
        _ -> ""
      end

    # Add announcement for screen readers
    announcement =
      case preference do
        "disabled" -> "Animations disabled"
        "reduced" -> "Animations reduced"
        "enabled" -> "Animations enabled"
        _ -> "Animation preference updated"
      end

    socket =
      socket
      |> assign(:animation_speed_class, animation_speed_class)
      |> update(:screen_reader_announcements, fn announcements ->
        [announcement | announcements] |> Enum.take(5)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set_contrast", %{"contrast" => contrast}, socket) do
    # Add announcement for screen readers
    announcement =
      case contrast do
        "high" -> "High contrast mode enabled"
        "normal" -> "Normal contrast mode enabled"
        _ -> "Contrast setting updated"
      end

    socket =
      socket
      |> update(:screen_reader_announcements, fn announcements ->
        [announcement | announcements] |> Enum.take(5)
      end)

    {:noreply, socket}
  end

  # Helper to get theme from session
  defp get_session_theme(socket) do
    case get_connect_params(socket) do
      %{"theme" => theme} when theme in ["dark", "light", "dim", "synthwave"] ->
        theme

      _ ->
        # Default theme
        "dark"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="accessibility-controls">
        <div class="animation-speed-controls">
          <label>Animation Speed:</label>
          <div class="speed-buttons">
            <button phx-click="set_animation_speed" phx-value-speed="slow" class={@animation_speed_class == "slow-speed" && "active"} aria-label="Set slow animation speed">
              Slow
            </button>
            <button phx-click="set_animation_speed" phx-value-speed="normal" class={@animation_speed_class == "normal-speed" && "active"} aria-label="Set normal animation speed">
              Normal
            </button>
            <button phx-click="set_animation_speed" phx-value-speed="fast" class={@animation_speed_class == "fast-speed" && "active"} aria-label="Set fast animation speed">
              Fast
            </button>
          </div>
        </div>
        <.accessibility_menu />
      </div>

      <div class="theme-toggle-container">
        <.theme_toggle />
      </div>

      <%= if @show_toc do %>
        <div class="content-with-toc">
          <div class="table-of-contents">
            <h2>Contents</h2>
            <ul>
              <%= for {id, label} <- @toc_items do %>
                <li>
                  <a href={"##{id}"}>{label}</a>
                </li>
              <% end %>
            </ul>
            <button phx-click="toggle_toc" class="toc-button" aria-label="Hide table of contents">
              <span class="toc-toggle-icon">◀</span> Hide TOC
            </button>
          </div>

          <main class="content" id="main-content">
            <!-- ASCII Banner Section -->
            <section id="ascii-banner" class={["ascii-banner", @animation_speed_class]}>
              <pre id="hydepwns-banner" class="ascii-header" aria-label="Hydepwns ASCII art logo banner">
    <span class="ascii-logo">
    ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ ██╗    ██╗███╗   ██╗███████╗
    ██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██║    ██║████╗  ██║██╔════╝
    ███████║ ╚████╔╝ ██║  ██║█████╗  ██████╔╝██║ █╗ ██║██╔██╗ ██║███████╗
    ██╔══██║  ╚██╔╝  ██║  ██║██╔══╝  ██╔═══╝ ██║███╗██║██║╚██╗██║╚════██║
    ██║  ██║   ██║   ██████╔╝███████╗██║     ╚███╔███╔╝██║ ╚████║███████║
    ╚═╝  ╚═╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝      ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝
    </span>
    <span class="ascii-version">MONOSPACE WEB DESIGN SYSTEM v1.3.1</span>
              </pre>
            </section>
            
    <!-- Introduction Section -->
            <section id="introduction">
              <h2>Introduction</h2>
              <p>Welcome to the Hydepwns monospace interface demonstration.</p>

              <h3 id="background">Background</h3>
              <p>The design is inspired by terminal UIs and uses monospace fonts technical aesthetic. This approach allows for precise control over ASCII art integration.</p>
            </section>
            
    <!-- Features Section -->
            <section id="features">
              <h2>Features</h2>

              <div class="feature-grid">
                <div class="feature-item">
                  <h3>Monospace</h3>
                  <p>Fixed-width character layout for perfect alignment</p>
                </div>
                <div class="feature-item">
                  <h3>Minimal</h3>
                  <p>Clean, distraction-free interface focused on content</p>
                </div>
                <div class="feature-item">
                  <h3>Accessible</h3>
                  <p>Fully keyboard navigable with screen reader support</p>
                </div>
                <div class="feature-item">
                  <h3>Customizable</h3>
                  <p>Multiple themes and display options to choose from</p>
                </div>
                <div class="feature-item">
                  <h3>Fast</h3>
                  <p>Lightweight design with minimal dependencies</p>
                </div>
                <div class="feature-item">
                  <h3>Responsive</h3>
                  <p>Mobile-friendly interface that adapts to different screen sizes</p>
                </div>
              </div>

              <div class="feature-legend">
                <h3>Project Components</h3>
                <div class="legend-items">
                  <div class="legend-item">
                    <span class="legend-marker" style="color: #FF2E97;">●</span>
                    <span>Design System: Typography, grids, colors, and components</span>
                  </div>
                  <div class="legend-item">
                    <span class="legend-marker" style="color: #19DCFF;">●</span>
                    <span>Documentation: Guides, API references, and usage examples</span>
                  </div>
                  <div class="legend-item">
                    <span class="legend-marker" style="color: #FFD319;">●</span>
                    <span>Examples: Interactive demos and playground environments</span>
                  </div>
                </div>
              </div>
            </section>
            
    <!-- Interactive Terminal Section -->
            <section id="interactive-terminal">
              <h2>Interactive Terminal</h2>
              <p>Experience our terminal interface directly from the home page. Try commands like <code>help</code>, <code>about</code>, <code>hello</code>, or <code>info</code>. Use the navigation plugin to explore the site.</p>

              <div class="interactive-terminal-container">
                <.live_component
                  module={HydepwnsLiveviewWeb.Components.Interactive.Terminal}
                  id="home-terminal"
                  prompt="hydepwns$ "
                  welcome_message="Welcome to Hydepwns Terminal! Type 'help' for available commands or 'about' for project information."
                  available_commands={
                    %{
                      "hello" => %{
                        description: "Say hello to the user",
                        usage: "hello [name]"
                      },
                      "about" => %{
                        description: "Display information about Hydepwns",
                        usage: "about"
                      }
                    }
                  }
                  plugins={[Navigation]}
                  theme={@terminal_theme}
                  fullscreen={false}
                  cols={80}
                  rows={15}
                />
              </div>

              <div class="terminal-help-text">
                <h3>Try These Commands:</h3>
                <ul class="command-suggestions">
                  <li><code>help</code> - List all available commands</li>
                  <li><code>about</code> - Learn about Hydepwns</li>
                  <li><code>hello [name]</code> - Personalized greeting</li>
                  <li><code>info</code> - System information</li>
                  <li><code>theme [name]</code> - Change the terminal theme (try "synthwave")</li>
                  <li><code>nav</code> - Site navigation help</li>
                  <li><code>map</code> - Show site structure</li>
                  <li><code>goto [path]</code> - Navigate to another page</li>
                </ul>
              </div>
            </section>
            
    <!-- Themes Section -->
            <section id="themes">
              <h2>Themes</h2>

              <div class="theme-gallery">
                <div class={["theme-option", @theme_class == "light-theme" && "active"]} phx-click="change_theme" phx-value-theme="light">
                  <div class="theme-preview light-theme">
                    <pre class="theme-sample">
                    ┌─────────────┐
                    │ LIGHT THEME │
                    └─────────────┘
                    </pre>
                  </div>
                  <label class="theme-label">Light</label>
                </div>

                <div class={["theme-option", @theme_class == "dark-theme" && "active"]} phx-click="change_theme" phx-value-theme="dark">
                  <div class="theme-preview dark-theme">
                    <pre class="theme-sample">
                    ┌────────────┐
                    │ DARK THEME │
                    └────────────┘
                    </pre>
                  </div>
                  <label class="theme-label">Dark</label>
                </div>

                <div class={["theme-option", @theme_class == "synthwave-theme" && "active"]} phx-click="change_theme" phx-value-theme="synthwave">
                  <div class="theme-preview synthwave-theme">
                    <pre class="theme-sample" style="color: #FF2E97; text-shadow: 0 0 5px #FF2E97;">
                    ┌────────────────┐
                    │ SYNTHWAVE THEME│
                    └────────────────┘
                    </pre>
                  </div>
                  <label class="theme-label">Synthwave</label>
                </div>
              </div>
            </section>
            
    <!-- Copyright Footer -->
            <footer class="copyright-footer">
              <pre class="ascii-box footer-box">
              ╔══════════════════════════════════╗
              ║  © 2025 Hydepwns Monospace Web   ║
              ╚══════════════════════════════════╝
              </pre>
            </footer>
          </main>
        </div>
      <% else %>
        <div class="content-no-toc">
          <main class="content" id="main-content">
            <!-- Simplified view when TOC is hidden -->
            <button phx-click="toggle_toc" class="show-toc-button" aria-label="Show table of contents">
              <span class="toc-toggle-icon">▶</span> Show TOC
            </button>

            <section id="ascii-banner" class={["ascii-banner", @animation_speed_class]}>
              <pre id="hydepwns-banner-mini" class="ascii-header-mini" aria-label="Hydepwns ASCII art logo banner">
    ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ ██╗    ██╗███╗   ██╗███████╗
    ██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██║    ██║████╗  ██║██╔════╝
    ███████║ ╚████╔╝ ██║  ██║█████╗  ██████╔╝██║ █╗ ██║██╔██╗ ██║███████╗
              </pre>
              <p>Toggle TOC to view full content</p>
            </section>
          </main>
        </div>
      <% end %>

      <.debug_grid />
    </div>
    """
  end
end
