defmodule HydepwnsLiveviewWeb.AboutLive do
  use HydepwnsLiveviewWeb, :live_view
  
  @impl true
  def mount(_params, _session, socket) do
    code_example = """
    git clone https://github.com/yourusername/hydepwns.git
    cd hydepwns
    mix deps.get
    mix phx.server
    """

    {:ok, 
      socket
      |> assign_current_path()
      |> assign(:page_title, "About")
      |> assign(:theme_class, "dark-theme")
      |> assign(:show_toc, true)
      |> assign(:toc_items, [
        {"philosophy", "Philosophy"},
        {"tech-stack", "Technology Stack"},
        {"contribute", "Contribute"}
      ])
      |> assign(:code_example, code_example)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <h1>About Hydepwns</h1>
      <p>
        Hydepwns is a showcase of monospace-inspired web design and typography.
        Built with Elixir and Phoenix LiveView, this site demonstrates how monospace
        fonts and grid-based layouts can create a clean, functional, and beautiful web experience.
      </p>
      
      <h2 id="philosophy">Philosophy</h2>
      <p>
        The design philosophy of Hydepwns is centered around these principles:
      </p>
      
      <ul>
        <li>
          <strong>Minimalism</strong> - Focus on content, reduce visual noise
        </li>
        <li>
          <strong>Consistency</strong> - Predictable spacing and alignment using monospace fonts
        </li>
        <li>
          <strong>Typography</strong> - Beautiful, readable text using modern monospace fonts
        </li>
        <li>
          <strong>Functionality</strong> - Design that serves a purpose, not just aesthetics
        </li>
      </ul>
      
      <h2 id="tech-stack">Technology Stack</h2>
      <p>
        This website is built with the following technologies:
      </p>
      
      <table>
        <thead>
          <tr>
            <th>Technology</th>
            <th>Purpose</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Elixir</td>
            <td>Backend programming language</td>
          </tr>
          <tr>
            <td>Phoenix</td>
            <td>Web framework</td>
          </tr>
          <tr>
            <td>LiveView</td>
            <td>Real-time server-rendered UI</td>
          </tr>
          <tr>
            <td>SCSS</td>
            <td>Styling</td>
          </tr>
          <tr>
            <td>Monaspace Fonts</td>
            <td>Typography</td>
          </tr>
        </tbody>
      </table>
      
      <h2 id="contribute">Contribute</h2>
      <p>
        Interested in contributing to Hydepwns? We welcome contributions of all kinds:
      </p>
      
      <pre><code><%= @code_example %></code></pre>
      
      <p>
        Visit the GitHub repository for more information on how to contribute to the project.
      </p>
    </section>
    """
  end
end 