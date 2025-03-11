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
       {"animations", "Animations"}
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
            aria-label="Toggle Table of Contents"
          >
            TOC {if @show_toc, do: "▲", else: "▼"}
          </button>
        </div>
      </header>

      <div class="layout-grid">
        <aside
          class={"toc #{if !@show_toc, do: "hidden"}"}
          id="toc-navigation"
          aria-label="Table of Contents"
        >
          <nav>
            <ul>
              <%= for {id, title} <- @toc_items do %>
                <li><a href={"##{id}"} aria-label={"Navigate to #{title} section"}>{title}</a></li>
              <% end %>
            </ul>
          </nav>
        </aside>

        <section id="introduction">
          <h2>Introduction</h2>
          <p>This is a demonstration of a monospace-styled website.</p>
        </section>

        <section id="animations">
          <h2>Animations</h2>
          <p>This section demonstrates various animations.</p>

          <h3>Animation Speed Controls</h3>
          <div class="animation-controls">
            <button
              phx-click="set_animation_speed"
              phx-value-speed="slow"
              class="animation-control-button"
              aria-label="Set animation speed to slow"
            >
              Slow
            </button>
            <button
              phx-click="set_animation_speed"
              phx-value-speed="normal"
              class="animation-control-button"
              aria-label="Set animation speed to normal"
            >
              Normal
            </button>
            <button
              phx-click="set_animation_speed"
              phx-value-speed="fast"
              class="animation-control-button"
              aria-label="Set animation speed to fast"
            >
              Fast
            </button>
          </div>
        </section>
      </div>
    </div>
    """
  end
end
