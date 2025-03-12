defmodule HydepwnsLiveviewWeb.Live.Playground.TerminalDemoLive do
  @moduledoc """
  Terminal Demo LiveView

  This LiveView demonstrates the Terminal component with all its features:
  - Command history and persistence
  - Autocomplete functionality
  - Plugin system
  - Theme customization
  - Fullscreen mode
  """
  use HydepwnsLiveviewWeb.BaseLive,
    required_assigns: [
      :page_title,
      :custom_commands
    ]

  alias HydepwnsLiveviewWeb.Components.Interactive.Terminal
  alias HydepwnsLiveviewWeb.Components.Interactive.Plugins.Navigation

  @impl true
  def do_mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Terminal Demo")
    |> assign(:custom_commands, %{
      "hello" => %{
        description: "Say hello to the user",
        usage: "hello [name]"
      },
      "count" => %{
        description: "Count from 1 to N",
        usage: "count [number]"
      }
    })
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-6">Terminal Component Demo</h1>

      <div class="mb-6">
        <p class="mb-4">
          This page demonstrates the Terminal component with its advanced features:
        </p>
        <ul class="list-disc pl-8 mb-6">
          <li>
            Command history with persistence (use up/down arrows to navigate through previous commands)
          </li>
          <li>Autocomplete functionality (type a partial command and press Tab)</li>
          <li>Plugin system (try using the 'nav' plugin commands)</li>
          <li>Theme customization (try 'theme dark', 'theme light', or 'theme dim')</li>
          <li>
            Appearance customization (try 'preferences font "Monaco"' or 'preferences cursor bar')
          </li>
          <li>Visual styling options (try 'preferences highlight #36F9F6')</li>
          <li>Fullscreen mode (click the fullscreen button in the header)</li>
          <li>Custom commands ('hello' and 'count')</li>
          <li>ASCII art welcome message</li>
          <li>System information (try the 'info' command)</li>
        </ul>
      </div>

      <div class="mb-8">
        <h2 class="text-2xl font-bold mb-4">Basic Terminal</h2>
        <.live_component module={Terminal} id="demo-terminal" prompt="demo$ " welcome_message={nil} available_commands={@custom_commands} fullscreen={true} cols={80} rows={15} />
      </div>

      <div class="mb-8">
        <h2 class="text-2xl font-bold mb-4">Terminal with Navigation Plugin</h2>
        <p class="mb-4">
          This terminal includes the Navigation plugin. Try commands like:
        </p>
        <ul class="list-disc pl-8 mb-4">
          <li><code>nav</code> - See navigation plugin help</li>
          <li><code>ls</code> - List available pages</li>
          <li><code>goto /about</code> - Navigate to a page</li>
          <li><code>map</code> - Show a site map</li>
        </ul>
        <.live_component module={Terminal} id="plugin-terminal" prompt="hydepwns$ " welcome_message="Terminal with Navigation Plugin. Try 'nav' for help." plugins={[Navigation]} theme="dim" fullscreen={true} cols={80} rows={20} />
      </div>

      <div class="mb-8">
        <h2 class="text-2xl font-bold mb-4">Available Commands</h2>
        <p class="mb-4">Try these commands in the terminals above:</p>

        <h3 class="text-xl font-bold mt-4 mb-2">Built-in Commands</h3>
        <ul class="grid grid-cols-1 md:grid-cols-2 gap-2">
          <li><code>help</code> - Show available commands</li>
          <li><code>clear</code> - Clear the terminal screen</li>
          <li><code>echo [text]</code> - Display text</li>
          <li><code>date</code> - Show current date/time</li>
          <li><code>theme [name]</code> - Change theme</li>
          <li><code>history</code> - Show command history</li>
          <li><code>info</code> - Display system information</li>
          <li><code>preferences</code> - Customize terminal appearance</li>
        </ul>

        <h3 class="text-xl font-bold mt-4 mb-2">Custom Commands</h3>
        <ul class="grid grid-cols-1 md:grid-cols-2 gap-2">
          <li><code>hello [name]</code> - Say hello</li>
          <li><code>count [number]</code> - Count from 1 to N</li>
        </ul>

        <h3 class="text-xl font-bold mt-4 mb-2">Navigation Plugin Commands</h3>
        <ul class="grid grid-cols-1 md:grid-cols-2 gap-2">
          <li><code>nav</code> - Show navigation help</li>
          <li><code>goto [path]</code> - Navigate to page</li>
          <li><code>ls [path]</code> - List available pages</li>
          <li><code>map</code> - Show site map</li>
        </ul>

        <h3 class="text-xl font-bold mt-4 mb-2">Keyboard Shortcuts</h3>
        <ul class="grid grid-cols-1 md:grid-cols-2 gap-2">
          <li><code>Tab</code> - Autocomplete commands</li>
          <li><code>↑/↓</code> - Navigate command history</li>
          <li><code>Ctrl+L</code> - Clear terminal</li>
          <li><code>Ctrl+C</code> - Copy selected text</li>
          <li><code>Esc</code> - Close autocomplete</li>
        </ul>

        <h3 class="text-xl font-bold mt-4 mb-2">Command History Navigation</h3>
        <p class="mb-4">
          The terminal maintains a history of commands you've entered. You can navigate through this history using:
        </p>
        <ul class="list-disc pl-8 mb-4">
          <li><code>↑</code> (Up Arrow) - Move to previous command in history</li>
          <li><code>↓</code> (Down Arrow) - Move to next command in history</li>
          <li><code>history</code> - View your command history</li>
          <li><code>history clear</code> - Clear your command history</li>
        </ul>
        <p class="mb-4">
          Your command history is automatically saved in your browser's local storage,
          so it will persist even if you close the page and return later.
        </p>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("terminal_command", %{"command" => "hello" <> rest, "id" => id}, socket) do
    name = String.trim(rest)
    name = if name == "", do: "World", else: name

    response = %{
      type: :output,
      content: "Hello, #{name}! 👋"
    }

    send_update(Terminal, id: id, new_output: [response])
    {:noreply, socket}
  end

  @impl true
  def handle_event("terminal_command", %{"command" => "count" <> rest, "id" => id}, socket) do
    count_str = String.trim(rest)

    response =
      case Integer.parse(count_str) do
        {n, _} when n > 0 and n <= 100 ->
          numbers = Enum.map(1..n, &Integer.to_string/1) |> Enum.join(", ")

          %{
            type: :output,
            content: "Counting from 1 to #{n}:\n#{numbers}"
          }

        {n, _} when n > 100 ->
          %{
            type: :error,
            content: "Sorry, the maximum count is 100."
          }

        _ ->
          %{
            type: :error,
            content: "Please provide a positive number.\nUsage: count [number]"
          }
      end

    send_update(Terminal, id: id, new_output: [response])
    {:noreply, socket}
  end

  @impl true
  def handle_event("terminal_command", _params, socket) do
    # Let the Terminal component handle other commands
    {:noreply, socket}
  end
end
