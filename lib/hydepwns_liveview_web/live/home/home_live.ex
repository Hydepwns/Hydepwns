defmodule HydepwnsLiveviewWeb.HomeLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveviewWeb.Helpers.TocHelper
  alias HydepwnsLiveviewWeb.Helpers.PathHelper
  import HydepwnsLiveviewWeb.Components.UI.Nav, only: [hierarchical_toc_nav: 1]

  @impl true
  def mount(_params, _session, socket) do
    # Initial page content for TOC generation
    page_content = """
    <h2 id="introduction">Introduction</h2>
    <p>Welcome to the Hydepwns monospace interface demonstration...</p>
    <h3 id="background">Background</h3>
    <p>The design is inspired by terminal UIs and uses monospace fonts...</p>
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

    {:ok,
     socket
     |> PathHelper.assign_specific_path("/")
     |> assign(:page_title, "Home")
     |> assign(:theme_class, "dark-theme")
     |> assign(:show_toc, true)
     |> assign(:toc_items, [
       {"introduction", "Introduction"},
       {"animations", "Animations"},
       {"typewriter", "Typewriter Effect"},
       {"char-fade", "Character Fade"},
       {"grid-fade", "Grid Fade"}
     ])
     |> assign(:toc_data, toc_data)
     |> assign(:current_section, nil)
     |> assign(:animation_speed_class, "normal-speed")}
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

    {:noreply, assign(socket, :animation_speed_class, speed_class)}
  end

  @impl true
  def handle_event("replay_animations", _, socket) do
    # Send a custom event to the client to trigger animation replay
    {:noreply, push_event(socket, "replay_animations", %{})}
  end

  @impl true
  def handle_event("set_current_section", %{"section" => section}, socket) do
    {:noreply, assign(socket, :current_section, section)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="home-container">
      <header class="page-header">
        <div class="toc-toggle">
          <button phx-click="toggle_toc" class="toc-toggle-button" aria-label={if @show_toc, do: "Hide table of contents", else: "Show table of contents"}>
            <%= if @show_toc do %>
              <span class="toc-toggle-icon">▼</span>
            <% else %>
              <span class="toc-toggle-icon">▶</span>
            <% end %>
            TOC
          </button>
        </div>

        <h1 id="main-title" phx-hook="CharacterAnimation" class="typewriter" data-typing-speed="40">
          Hydepwns Monospace Interface
        </h1>
      </header>

      <%= if @show_toc do %>
        <div class="content-with-toc">
          <aside class="toc-sidebar">
            <.hierarchical_toc_nav toc_data={@toc_data} current_section={@current_section} class="main-toc" />
          </aside>

          <main class="content" id="main-content">
            <section id="introduction">
              <h2>Introduction</h2>
              <p>
                Welcome to the Hydepwns monospace interface demonstration. This interface
                showcases various techniques for creating a terminal-like web experience
                using LiveView.
              </p>
              <p>
                The design is inspired by terminal UIs and uses monospace fonts exclusively
                to create a grid-based layout. All spacing and alignment is carefully calculated
                to maintain character-level precision.
              </p>

              <h3 id="background">Background</h3>
              <p>
                The design is inspired by terminal UIs and uses monospace fonts exclusively
                to create a grid-based layout. All spacing and alignment is carefully calculated
                to maintain character-level precision.
              </p>
            </section>

            <section id="animations">
              <h2>Animations</h2>
              <p>
                Monospace interfaces can be enhanced with subtle animations that mimic terminal
                behavior. Below are examples of animations compatible with monospace layouts.
              </p>

              <div class="animation-controls">
                <span>Animation Speed:</span>
                <button phx-click="set_animation_speed" phx-value-speed="slow" class={@animation_speed_class == "slow-speed" && "active"}>
                  Slow
                </button>
                <button phx-click="set_animation_speed" phx-value-speed="normal" class={@animation_speed_class == "normal-speed" && "active"}>
                  Normal
                </button>
                <button phx-click="set_animation_speed" phx-value-speed="fast" class={@animation_speed_class == "fast-speed" && "active"}>
                  Fast
                </button>
                <button phx-click="replay_animations" class="replay-button">
                  Replay All
                </button>
              </div>

              <h3 id="typewriter">Typewriter Effect</h3>
              <div class={["animation-example", @animation_speed_class]}>
                <pre id="typewriter-code" phx-hook="CharacterAnimation" class="typewriter" data-typing-speed="70"><code>
                  console.log("This is an example of a typewriter effect.");
                  console.log("Each character appears one at a time.");
                  console.log("It works great for terminal-like interfaces.");
                </code></pre>
              </div>

              <h3 id="char-fade">Character Fade</h3>
              <div class={["animation-example", @animation_speed_class]}>
                <p id="char-fade-example" phx-hook="CharacterAnimation" class="character-fade" data-fade-speed="20">
                  This text fades in character by character, creating a matrix-like effect
                  that works well with monospace text. Each character appears independently.
                </p>
              </div>

              <h3 id="grid-fade">Grid Fade</h3>
              <div class={["animation-example", @animation_speed_class]}>
                <div id="grid-fade-container" phx-hook="GridFadeIn" class="grid-fade-container" data-fade-speed="30">
                  <div class="mono-grid">
                    <div class="grid-cell">1</div>
                    <div class="grid-cell">2</div>
                    <div class="grid-cell">3</div>
                    <div class="grid-cell">4</div>
                    <div class="grid-cell">5</div>
                    <div class="grid-cell">6</div>
                    <div class="grid-cell">7</div>
                    <div class="grid-cell">8</div>
                    <div class="grid-cell">9</div>
                  </div>
                </div>
              </div>
            </section>
          </main>
        </div>
      <% else %>
        <main class="content full-width" id="main-content">
          <section id="introduction">
            <h2>Introduction</h2>
            <p>
              Welcome to the Hydepwns monospace interface demonstration. This interface
              showcases various techniques for creating a terminal-like web experience
              using LiveView.
            </p>
            <p>
              The design is inspired by terminal UIs and uses monospace fonts exclusively
              to create a grid-based layout. All spacing and alignment is carefully calculated
              to maintain character-level precision.
            </p>

            <h3 id="background">Background</h3>
            <p>
              The design is inspired by terminal UIs and uses monospace fonts exclusively
              to create a grid-based layout. All spacing and alignment is carefully calculated
              to maintain character-level precision.
            </p>
          </section>

          <section id="animations">
            <h2>Animations</h2>
            <p>
              Monospace interfaces can be enhanced with subtle animations that mimic terminal
              behavior. Below are examples of animations compatible with monospace layouts.
            </p>

            <div class="animation-controls">
              <span>Animation Speed:</span>
              <button phx-click="set_animation_speed" phx-value-speed="slow" class={@animation_speed_class == "slow-speed" && "active"}>
                Slow
              </button>
              <button phx-click="set_animation_speed" phx-value-speed="normal" class={@animation_speed_class == "normal-speed" && "active"}>
                Normal
              </button>
              <button phx-click="set_animation_speed" phx-value-speed="fast" class={@animation_speed_class == "fast-speed" && "active"}>
                Fast
              </button>
              <button phx-click="replay_animations" class="replay-button">
                Replay All
              </button>
            </div>

            <h3 id="typewriter">Typewriter Effect</h3>
            <div class={["animation-example", @animation_speed_class]}>
              <pre id="typewriter-code" phx-hook="CharacterAnimation" class="typewriter" data-typing-speed="70"><code>
                console.log("This is an example of a typewriter effect.");
                console.log("Each character appears one at a time.");
                console.log("It works great for terminal-like interfaces.");
              </code></pre>
            </div>

            <h3 id="char-fade">Character Fade</h3>
            <div class={["animation-example", @animation_speed_class]}>
              <p id="char-fade-example" phx-hook="CharacterAnimation" class="character-fade" data-fade-speed="20">
                This text fades in character by character, creating a matrix-like effect
                that works well with monospace text. Each character appears independently.
              </p>
            </div>

            <h3 id="grid-fade">Grid Fade</h3>
            <div class={["animation-example", @animation_speed_class]}>
              <div id="grid-fade-container" phx-hook="GridFadeIn" class="grid-fade-container" data-fade-speed="30">
                <div class="mono-grid">
                  <div class="grid-cell">1</div>
                  <div class="grid-cell">2</div>
                  <div class="grid-cell">3</div>
                  <div class="grid-cell">4</div>
                  <div class="grid-cell">5</div>
                  <div class="grid-cell">6</div>
                  <div class="grid-cell">7</div>
                  <div class="grid-cell">8</div>
                  <div class="grid-cell">9</div>
                </div>
              </div>
            </div>
          </section>
        </main>
      <% end %>
    </div>
    """
  end
end
