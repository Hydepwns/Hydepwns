defmodule HydepwnsLiveviewWeb.HomeLive do
  use HydepwnsLiveviewWeb, :live_view
  alias HydepwnsLiveviewWeb.Components.ThemeToggle
  alias HydepwnsLiveviewWeb.Components.UI.LayoutComponents

  def mount(_params, _session, socket) do
    # Set default theme if not already set by the client
    system_theme = if connected?(socket), do: get_system_theme(), else: "light"
    
    {:ok, assign(socket, theme_class: "#{system_theme}-theme")}
  end

  def handle_event("change_theme", %{"theme" => theme}, socket) do
    {:noreply, 
      socket
      |> assign(:theme_class, "#{theme}-theme")
      |> push_event("change_theme", %{theme: theme})
    }
  end

  def render(assigns) do
    ~H"""
    <main>
      <LayoutComponents.header_table>
        <:left>
          <h1>Hydepwns</h1>
        </:left>
        <:right>
          <ThemeToggle.theme_toggle />
        </:right>
      </LayoutComponents.header_table>

      <h2>Welcome to Monospace Web</h2>
      
      <p>
        This is a monospace-focused web experience built with Phoenix LiveView, 
        following the principles of <a href="https://github.com/owickstrom/the-monospace-web" target="_blank">The Monospace Web</a>.
        We use Monaspace Argon as our primary typeface with JetBrains Mono as fallback.
      </p>

      <h3>Features</h3>
      
      <ul>
        <li>Pixel-perfect monospace typography</li>
        <li>Character-based grid layout</li>
        <li>Three theme options: light, dark, and dim</li>
        <li>Real-time updates with LiveView</li>
        <li>Minimal JavaScript footprint</li>
      </ul>

      <h3>Getting Started</h3>
      
      <p>Explore the design system components below:</p>
      
      <.link navigate={~p"/style-guide"} class="mono-button">
        View Style Guide →
      </.link>
      
      <details>
        <summary>About Monaspace</summary>
        <p>
          Monaspace is a superfamily of coding fonts from GitHub that includes five 
          variable fonts with different personalities but matching metrics. We're 
          using Monaspace Argon, which features clean, geometric letterforms.
        </p>
      </details>

      <table>
        <thead>
          <tr>
            <th>Theme</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Light</td>
            <td>White background with black text, ideal for daytime usage</td>
          </tr>
          <tr>
            <td>Dark</td>
            <td>Black background with white text, perfect for low-light environments</td>
          </tr>
          <tr>
            <td>Dim</td>
            <td>A deep purple background with accents, inspired by synthwave aesthetics</td>
          </tr>
        </tbody>
      </table>
    </main>
    """
  end

  # Get system theme preference (if connected)
  defp get_system_theme do
    # Default to light theme if we can't detect
    "light"
  end
end
