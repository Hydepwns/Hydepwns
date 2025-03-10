defmodule HydepwnsLiveviewWeb.ProjectsLive do
  use HydepwnsLiveviewWeb, :live_view
  
  @impl true
  def mount(_params, _session, socket) do
    diagram = """
    +--------+    +---------+    +--------+
    |        |    |         |    |        |
    | Design |--->| Develop |--->| Deploy |
    |        |    |         |    |        |
    +--------+    +---------+    +--------+
    """
    
    {:ok, 
      socket
      |> assign_current_path()
      |> assign(:page_title, "Projects")
      |> assign(:theme_class, "dark-theme")
      |> assign(:show_toc, true)
      |> assign(:toc_items, [
        {"personal", "Personal Projects"},
        {"open-source", "Open Source"},
        {"experiments", "Experiments"}
      ])
      |> assign(:diagram, diagram)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <h1>Projects</h1>
      <p>
        A collection of projects built with the monospace aesthetic in mind.
        Each project embraces clean design, readability, and functionality.
      </p>
      
      <h2 id="featured">Featured Projects</h2>
      <div class="project-grid">
        <div class="project-card">
          <h3>Monospace Editor</h3>
          <p>A text editor designed specifically for monospaced fonts and grid-based layouts.</p>
          <a href="#" class="mono-button">View Project →</a>
        </div>
        
        <div class="project-card">
          <h3>Terminal Dashboard</h3>
          <p>A real-time dashboard with a terminal-inspired interface.</p>
          <a href="#" class="mono-button">View Project →</a>
        </div>
      </div>
      
      <h2 id="open-source">Open Source</h2>
      <p>
        Contributions to the open-source community with a focus on developer tools
        and typography-focused projects.
      </p>
      
      <ul>
        <li>
          <strong>MonoGrid</strong> - A CSS framework for monospace-based layouts
        </li>
        <li>
          <strong>FontMetrics</strong> - A tool for analyzing and comparing monospaced fonts
        </li>
        <li>
          <strong>TerminalUI</strong> - A library for building terminal-inspired web interfaces
        </li>
      </ul>
      
      <h2 id="experiments">Experiments</h2>
      <p>
        Experimental projects exploring the boundaries of monospace design and typography.
      </p>
      
      <pre><code><%= @diagram %></code></pre>
      
      <p>
        More experiments coming soon. Check back for updates.
      </p>
    </section>
    """
  end
end 