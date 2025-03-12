defmodule HydepwnsLiveviewWeb.AboutLive do
  use HydepwnsLiveviewWeb.BaseLive,
    required_assigns: [
      :page_title,
      :theme_class,
      :show_toc,
      :toc_items,
      :code_example
    ]

  alias HydepwnsLiveviewWeb.Helpers.PathHelper

  @impl true
  def do_mount(_params, _session, socket) do
    code_example = """
    git clone https://github.com/hydepwns/hydepwns.git
    cd hydepwns
    mix deps.get
    mix phx.server
    """

    socket
    |> PathHelper.assign_specific_path("/about")
    |> assign(:page_title, "About")
    |> assign(:theme_class, "dark-theme")
    |> assign(:show_toc, true)
    |> assign(:toc_items, [
      {"philosophy", "Philosophy"},
      {"tech-stack", "Technology Stack"},
      {"contribute", "Contribute"}
    ])
    |> assign(:code_example, code_example)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <h2>About Hydepwns</h2>
      <p>
        Hydepwns is a showcase of monospace-inspired web design and typography.
        Built with Elixir and Phoenix LiveView, this site demonstrates how monospace
        fonts and grid-based layouts can create a clean, functional, and beautiful web experience.
      </p>

      <h3 id="philosophy">Philosophy</h3>
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

      <h3 id="tech-stack">Technology Stack</h3>
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

      <h3 id="contribute">Contribute</h3>
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
