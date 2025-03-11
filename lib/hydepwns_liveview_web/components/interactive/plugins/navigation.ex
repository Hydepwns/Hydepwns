defmodule HydepwnsLiveviewWeb.Components.Interactive.Plugins.Navigation do
  @moduledoc """
  Navigation Plugin for Terminal

  This plugin allows users to navigate the site through terminal commands.
  It provides commands like `goto`, `ls`, and `map` to explore and navigate the application.
  """
  @behaviour HydepwnsLiveviewWeb.Components.Interactive.Terminal.Plugin

  @impl true
  def name, do: "nav"

  @impl true
  def init do
    {:ok,
     %{
       module: __MODULE__,
       visited_pages: [],
       current_page: "/",
       available_routes: [
         "/",
         "/about",
         "/docs",
         "/gallery",
         "/playground",
         "/projects"
       ]
     }}
  end

  @impl true
  def commands do
    %{
      "nav" => %{
        description: "Navigation plugin for exploring the site",
        usage: "nav [command] [args]",
        subcommands: [
          "goto - Navigate to a specific page",
          "ls - List available pages",
          "map - Show site structure as ASCII art"
        ]
      },
      "goto" => %{
        description: "Navigate to a specific page",
        usage: "goto [path]"
      },
      "ls" => %{
        description: "List available pages",
        usage: "ls [optional path]"
      },
      "map" => %{
        description: "Show site structure as ASCII art",
        usage: "map"
      }
    }
  end

  @impl true
  def execute("nav", args, state) do
    case String.split(args, " ", parts: 2) do
      [subcommand | rest] ->
        args_str = Enum.join(rest, " ")
        execute(subcommand, args_str, state)

      [] ->
        help_text = """
        Navigation Plugin Commands:

        goto [path]    - Navigate to a specific page
        ls [path]      - List available pages
        map            - Show site structure as ASCII art

        Example: nav goto /about
                nav ls
                nav map
        """

        {:ok, help_text, state}
    end
  end

  @impl true
  def execute("goto", path, state) do
    path = String.trim(path)

    if path == "" do
      {:error, "Usage: goto [path]\nExample: goto /about", state}
    else
      # Check if path exists
      if Enum.member?(state.available_routes, path) do
        # In a real implementation, this would use Phoenix's push_navigate
        # For demo purposes, we'll just add it to visited pages
        updated_state = %{
          state
          | visited_pages: [state.current_page | state.visited_pages],
            current_page: path
        }

        # Prepare push_navigate script (would be executed by JS in real implementation)
        nav_script = """
        <script>
          // This would be executed to navigate in a real implementation
          window.location.href = '#{path}';
        </script>
        """

        response = """
        Navigating to #{path}...

        #{nav_script}

        Note: In a full implementation, this would actually navigate to the page.
        For demo purposes, we're just simulating navigation.
        """

        {:ok, response, updated_state}
      else
        {:error,
         "Error: Page '#{path}' not found.\nAvailable pages: #{Enum.join(state.available_routes, ", ")}",
         state}
      end
    end
  end

  @impl true
  def execute("ls", path, state) do
    path = String.trim(path)

    # In a real implementation, this would list actual routes or content
    # For demo, we'll return a static list based on the path
    routes =
      case path do
        "" ->
          state.available_routes

        "/docs" ->
          [
            "/docs/getting-started",
            "/docs/components",
            "/docs/api",
            "/docs/theming",
            "/docs/plugins"
          ]

        "/gallery" ->
          [
            "/gallery/ascii-art",
            "/gallery/monospace-grids",
            "/gallery/terminal-themes"
          ]

        _ ->
          []
      end

    if routes == [] do
      {:error, "No routes found for path: #{path}", state}
    else
      response = """
      Available routes for #{if path == "", do: "/", else: path}:

      #{Enum.map(routes, fn route -> "  #{route}" end) |> Enum.join("\n")}

      Use 'goto [path]' to navigate to a specific page.
      """

      {:ok, response, state}
    end
  end

  @impl true
  def execute("map", _args, state) do
    # Create an ASCII art site map
    site_map = """
    Hydepwns Site Map
    =================

    +-------+       +---------+       +--------+
    |       |------>|         |------>|        |
    | Home  |       |  About  |       |  Docs  |
    |       |<------|         |<------|        |
    +-------+       +---------+       +--------+
        |                                 |
        v                                 v
    +---------+      +-----------+    +--------+
    |         |----->|           |    |        |
    | Gallery |      | Playground|--->| Projects|
    |         |<-----|           |    |        |
    +---------+      +-----------+    +--------+

    Current location: #{state.current_page}
    Recently visited: #{Enum.take(state.visited_pages, 3) |> Enum.join(", ")}
    """

    {:ok, site_map, state}
  end

  # Handle unknown commands
  @impl true
  def execute(cmd, _args, state) do
    {:error, "Unknown navigation command: #{cmd}\nTry 'nav' for help.", state}
  end

  @impl true
  def autocomplete(prefix) do
    commands = ["goto", "ls", "map"]

    # Filter commands by prefix
    filtered_commands = Enum.filter(commands, fn cmd -> String.starts_with?(cmd, prefix) end)

    # Add common path completions for goto and ls
    path_completions =
      case prefix do
        "goto " <> path_prefix ->
          get_path_completions(path_prefix)
          |> Enum.map(fn path -> "goto #{path}" end)

        "ls " <> path_prefix ->
          get_path_completions(path_prefix)
          |> Enum.map(fn path -> "ls #{path}" end)

        _ ->
          []
      end

    # Combine both lists
    filtered_commands ++ path_completions
  end

  # Get path completions for autocomplete
  defp get_path_completions(prefix) do
    paths = [
      "/",
      "/about",
      "/docs",
      "/gallery",
      "/playground",
      "/projects"
    ]

    paths
    |> Enum.filter(fn path -> String.starts_with?(path, prefix) end)
  end
end
