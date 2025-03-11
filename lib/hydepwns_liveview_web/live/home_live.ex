defmodule HydepwnsLiveviewWeb.HomeLive do
  use HydepwnsLiveviewWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_current_path()
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
  def handle_event("change_theme", %{"theme" => theme}, socket) do
    theme_class = "#{theme}-theme"
    {:noreply, assign(socket, :theme_class, theme_class)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="home-container">
      <header class="page-header">
        <div class="toc-toggle">
          <button
            phx-click="toggle_toc"
            class="toc-toggle-button"
            aria-label={if @show_toc, do: "Hide table of contents", else: "Show table of contents"}
          >
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
        <nav class="toc">
          <ul>
            <%= for {id, label} <- @toc_items do %>
              <li>
                <a href={"##{id}"}><%= label %></a>
              </li>
            <% end %>
          </ul>
        </nav>
      <% end %>
      
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
          </div>
        </section>

        <section id="typewriter">
          <h2>Typewriter Effect</h2>
          <p>The typewriter effect types characters one by one:</p>
          
          <div class="animation-example">
            <p id="typewriter-example" phx-hook="CharacterAnimation" class="typewriter" data-typing-speed="50">
              This text is typed out character by character, simulating a terminal typing effect.
            </p>
          </div>
          
          <h3>Implementation</h3>
          <div class="code-example">
            &lt;p phx-hook="CharacterAnimation" class="typewriter" data-typing-speed="50"&gt;
              This text is typed out character by character.
            &lt;/p&gt;
          </div>
        </section>

        <section id="char-fade">
          <h2>Character Fade Effect</h2>
          <p>The character fade effect fades in characters one by one:</p>
          
          <div class="animation-example">
            <p id="char-fade-example" phx-hook="CharacterAnimation" class="char-fade" data-fade-delay="50">
              Each character in this text will fade in individually with a slight delay between them.
            </p>
          </div>
          
          <h3>Implementation</h3>
          <div class="code-example">Example code for character fade animation</div>
        </section>

        <section id="grid-fade">
          <h2>Grid Fade Effect</h2>
          <p>The grid fade effect reveals content line by line:</p>
          
          <div class="animation-example">
            <div id="grid-fade-example" phx-hook="GridFadeIn" class="grid-fade-in" data-line-delay="100">
              <p>This first line fades in.</p>
              <p>Then this second line fades in.</p>
              <p>Finally, this third line completes the sequence.</p>
              <pre>
                +----------------+
                |                |
                |  Grid Example  |
                |                |
                +----------------+
              </pre>
            </div>
          </div>
          
          <h3>Implementation</h3>
          <div class="code-example">Example code for grid fade animation</div>
        </section>
      </main>
      
      <footer class="page-footer">
        <div class="footer-content">
          <p>Hydepwns Monospace Interface Demo</p>
          <p>
            <a href="/style-guide">Style Guide</a> |
            <a href="/grid-playground">Grid Playground</a>
          </p>
        </div>
      </footer>
    </div>
    """
  end
end
