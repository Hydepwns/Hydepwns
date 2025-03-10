defmodule HydepwnsLiveviewWeb.HomeLive do
  @moduledoc """
  Live view for the homepage of the Hydepwns application.
  
  This LiveView handles theme management, including:
  - Initial theme setup based on system preferences or stored user selections
  - Theme toggling via user interactions
  - Theme persistence between sessions
  
  The LiveView communicates with client-side JavaScript hooks to handle theme changes
  and retrieve saved theme preferences.
  """
  use HydepwnsLiveviewWeb, :live_view

  @doc """
  Sets up the initial LiveView socket with theme information.
  
  Initializes the theme selection based on user preferences and stores this
  in the socket assigns.
  """
  @impl true
  def mount(_params, _session, socket) do
    code_example = """
    // Example of monospaced code
    function greeting(name) {
      return "Hello, " + name + "!";
    }

    greeting('world');
    """
    
    {:ok, 
     socket
     |> assign_current_path()
     |> assign(:page_title, "Home")
     |> assign(:theme_class, "light-theme")
     |> assign(:show_toc, true)
     |> assign(:toc_items, [
       {"introduction", "Introduction"},
       {"monospace", "Monospace Design"},
       {"example", "Example Content"},
       {"about", "About"}
     ])
     |> assign(:code_example, code_example)
    }
  end

  @doc """
  Handles theme change events from the theme toggle component.
  
  Processes the theme value from the client, ensuring consistent formatting with
  the "-theme" suffix, updates the socket assigns, and pushes the change back to
  client-side JavaScript for persisting in localStorage.
  """
  @impl true
  def handle_event("change_theme", %{"theme" => theme}, socket) do
    # Ensure theme is stored with the proper suffix
    theme_with_suffix = ensure_theme_suffix(theme)
    
    # Push event with the base theme name (without suffix) for consistency with JS
    base_theme = String.replace(theme_with_suffix, "-theme", "")
    
    {:noreply, 
      socket
      |> assign(:theme_class, theme_with_suffix)
      |> push_event("change_theme", %{theme: base_theme})
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <h1 id="introduction">Welcome to Hydepwns</h1>
      <p>
        This is a demonstration of a monospace-styled website, inspired by 
        <a href="https://github.com/owickstrom/the-monospace-web" target="_blank">The Monospace Web</a>.
        The site uses a clean, minimalist design with monospace fonts and a grid-based layout.
      </p>
      
      <h2 id="monospace">Monospace Design</h2>
      <p>
        Monospace fonts are dear to many developers. They provide consistent spacing and alignment,
        making text easy to read and structure. This site embraces the monospace aesthetic, using
        it throughout the interface.
      </p>
      
      <pre><code><%= @code_example %></code></pre>
      
      <h2 id="example">Example Content</h2>
      <p>
        Below is an example of various content elements styled with our monospace theme:
      </p>
      
      <h3>Lists</h3>
      <ul>
        <li>Item one with some detailed text to show how wrapping works</li>
        <li>Item two</li>
        <li>Item three - the monospace font keeps everything aligned</li>
      </ul>
      
      <h3>Table</h3>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Monospace</td>
            <td>A font where each character takes up the same amount of space</td>
          </tr>
          <tr>
            <td>Grid</td>
            <td>A layout system based on consistent spacing</td>
          </tr>
        </tbody>
      </table>
      
      <h2 id="about">About</h2>
      <p>
        This is an Elixir LiveView implementation of a monospace-styled website.
        The navigation and styling are inspired by "The Monospace Web" project.
      </p>
    </section>
    """
  end

  # Functions below are kept for future implementation of theme detection
  # They are documented in LIVEVIEW.md but not currently used
  
  # Gets the system theme preference (light/dark) if available.
  # For future implementation.
  # defp get_system_theme do
  #   # For documentation/future use - not currently implemented
  #   "light"
  # end
  
  # Gets the client-side stored theme preference.
  # For future implementation.
  # defp get_client_theme(socket) do
  #   # For documentation/future use - not currently implemented
  #   if connected?(socket) do
  #     # Will interact with theme hook to get client setting
  #     "light"
  #   else
  #     "light"
  #   end
  # end
  
  # Helper function to ensure theme name has the -theme suffix
  defp ensure_theme_suffix(theme) do
    if String.ends_with?(theme, "-theme"), do: theme, else: "#{theme}-theme"
  end
end
