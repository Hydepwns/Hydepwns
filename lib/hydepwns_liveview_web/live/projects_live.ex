defmodule HydepwnsLiveviewWeb.ProjectsLive do
  use HydepwnsLiveviewWeb, :live_view
  alias HydepwnsLiveviewWeb.Helpers.PathHelper

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
     |> PathHelper.assign_specific_path("/projects")
     |> assign(:page_title, "Projects")
     |> assign(:theme_class, "dark-theme")
     |> assign(:show_toc, true)
     |> assign(:toc_items, [
       {"personal", "Personal Projects"},
       {"open-source", "Open Source"},
       {"experiments", "Experiments"}
     ])
     |> assign(:diagram, diagram)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h2>PROJECTS</h2>
    <p>
      A collection of projects built with the monospace aesthetic in mind.
      Each project embraces clean design, readability, and functionality.
    </p>

    <h3 id="featured">Featured Projects</h3>
    <div class="project-grid">
      <div class="project-card">
        <h4>Monospace Editor</h4>
        <p>A text editor designed specifically for monospaced fonts and grid-based layouts.</p>
        <a href="#" class="mono-button">VIEW PROJECT →</a>
      </div>

      <div class="project-card">
        <h4>Terminal Dashboard</h4>
        <p>A real-time dashboard with a terminal-inspired interface.</p>
        <a href="#" class="mono-button">VIEW PROJECT →</a>
      </div>
    </div>

    <h3 id="open-source">Open Source</h3>
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

    <h3 id="experiments">Experiments</h3>
    <p>
      Experimental projects exploring the boundaries of monospace design and typography.
    </p>

    <pre><code><%= @diagram %></code></pre>

    <p>
      More experiments coming soon. Check back for updates.
    </p>
    """
  end
end
