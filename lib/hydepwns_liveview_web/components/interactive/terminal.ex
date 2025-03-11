defmodule HydepwnsLiveviewWeb.Components.Interactive.Terminal do
  @moduledoc """
  # Terminal

  Provides an interactive terminal component with command history and customization options.

  ## Overview

  The Terminal component creates a fully functional terminal emulator that can be embedded
  in any LiveView. It supports command history, custom commands, syntax highlighting,
  and various customization options.

  This component is useful for:
  - Creating interactive tutorials
  - Demonstrating command-line interfaces
  - Providing a playground for users to experiment with commands
  - Embedding CLI functionality within a web interface

  The terminal uses the MonoGrid component to ensure proper character alignment and
  preserves the monospace aesthetics of the application.

  ## Examples

  ```heex
  <Terminal.terminal id="example-terminal" />

  <Terminal.terminal 
    id="custom-terminal" 
    prompt="user@hydepwns:~$ " 
    welcome_message="Welcome to Hydepwns Terminal v1.0.0" 
    available_commands={@custom_commands}
    height={20}
    width={80}
    theme="dark"
    fullscreen={true}
  />
  ```

  ## Props/Attributes

  | Name | Type | Default | Required | Description |
  |------|------|---------|----------|-------------|
  | `id` | `string` | `nil` | Yes | Unique identifier for the terminal |
  | `prompt` | `string` | `"> "` | No | Custom prompt string |
  | `welcome_message` | `string` | `"Welcome to the terminal..."` | No | Initial message displayed |
  | `available_commands` | `map` | `%{}` | No | Custom commands to add |
  | `height` | `integer` | `15` | No | Terminal height in rows |
  | `width` | `integer` | `80` | No | Terminal width in columns |
  | `theme` | `string` | `"dark"` | No | Theme variant (light, dark, dim) |
  | `fullscreen` | `boolean` | `false` | No | Whether to enable fullscreen mode |

  ## Accessibility

  The Terminal component includes the following accessibility features:
  - ARIA role="application" for the terminal container
  - ARIA live region for screen reader announcements of new output
  - Focus management to maintain cursor position
  - Keyboard navigation support including command history (up/down arrows)
  - High contrast mode support

  ## Theming

  The terminal supports the following theme options:
  - `light`: Light background with dark text
  - `dark`: Dark background with light text
  - `dim`: Dark background with softer text colors
  - `high-contrast`: High contrast colors for accessibility

  ## Browser Compatibility

  The terminal component works in all modern browsers. In older browsers without
  localStorage support, command history persistence is automatically disabled.

  ## Related Components

  - `HydepwnsLiveviewWeb.Components.MonoGrid` - Used for layout
  - `HydepwnsLiveviewWeb.Components.Interactive.ThemePreview` - Often used with Terminal

  ## Changelog

  | Version | Changes |
  |---------|---------|
  | 0.2.0   | Added fullscreen toggle and theme support |
  | 0.1.0   | Initial implementation |
  """
  use HydepwnsLiveviewWeb, :live_component
  import HydepwnsLiveviewWeb.Components.MonoGrid
  alias Phoenix.LiveView.JS

  # Default commands that are available in all terminals
  @default_commands %{
    "help" => %{
      description: "Show available commands",
      usage: "help [command]"
    },
    "clear" => %{
      description: "Clear the terminal screen",
      usage: "clear"
    },
    "echo" => %{
      description: "Display a line of text",
      usage: "echo [text]"
    },
    "date" => %{
      description: "Display the current date and time",
      usage: "date"
    },
    "theme" => %{
      description: "Change the terminal theme",
      usage: "theme [light|dark|dim|high-contrast]"
    },
    "history" => %{
      description: "Show command history",
      usage: "history [clear]"
    }
  }

  # Default terminal properties
  @default_cols 80
  @default_rows 20
  @default_prompt "$ "
  @default_welcome_message "Welcome to Hydepwns Terminal. Type 'help' to see available commands."

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:command_history, [])
     |> assign(:history_index, 0)
     |> assign(:output, [])
     |> assign(:current_command, "")
     |> assign(:show_autocomplete, false)
     |> assign(:autocomplete_options, [])
     |> assign(:autocomplete_index, 0)}
  end

  @impl true
  def update(assigns, socket) do
    commands =
      case assigns[:available_commands] do
        nil -> @default_commands
        custom_commands -> Map.merge(@default_commands, custom_commands)
      end

    # Filter out reserved assigns
    reserved_assigns = [:socket, :flash, :live_action, :uploads]

    filtered_assigns =
      assigns
      |> Map.drop(reserved_assigns)

    {:ok,
     socket
     |> assign(filtered_assigns)
     |> assign(:available_commands, commands)
     |> assign_new(:cols, fn -> filtered_assigns[:cols] || @default_cols end)
     |> assign_new(:rows, fn -> filtered_assigns[:rows] || @default_rows end)
     |> assign_new(:prompt, fn -> filtered_assigns[:prompt] || @default_prompt end)
     |> assign_new(:welcome_message, fn ->
       filtered_assigns[:welcome_message] || @default_welcome_message
     end)
     |> assign_new(:theme, fn -> filtered_assigns[:theme] || "dark" end)
     |> assign_new(:command_history, fn -> [] end)
     |> assign_new(:output, fn ->
       [
         %{type: :system, content: filtered_assigns[:welcome_message] || @default_welcome_message}
       ]
     end)}
  end

  @doc """
  Renders a terminal component.

  ## Examples

  ```heex
  <Terminal.terminal id="example-terminal" />

  <Terminal.terminal 
    id="custom-terminal" 
    prompt="user@hydepwns:~$ " 
    welcome_message="Welcome to Hydepwns Terminal v1.0.0" 
    height={20}
    width={80}
  />
  ```

  ## Attributes

  | Name | Type | Default | Required | Description |
  |------|------|---------|----------|-------------|
  | `id` | `string` | `nil` | Yes | Unique identifier for this terminal instance |
  | `cols` | `integer` | `#{@default_cols}` | No | Number of columns in the terminal |
  | `rows` | `integer` | `#{@default_rows}` | No | Number of rows in the terminal viewport |
  | `prompt` | `string` | `"#{@default_prompt}"` | No | Terminal prompt string |
  | `welcome_message` | `string` | `"Welcome..."` | No | Initial message shown in the terminal |
  | `available_commands` | `map` | `%{}` | No | Map of custom commands this terminal should support |
  | `theme` | `string` | `"dark"` | No | Terminal theme: "light", "dark", "dim", "high-contrast" |
  | `wrap` | `boolean` | `true` | No | Whether to enable line wrapping |
  | `fullscreen` | `boolean` | `false` | No | Whether the terminal can be toggled to fullscreen mode |

  ## Returns

  HEEx template rendering the terminal component.
  """
  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "terminal-container",
        "terminal-theme-#{@theme}"
      ]}
      phx-hook="Terminal"
      data-terminal-id={@id}
      data-fullscreen={assigns[:fullscreen] || false}
    >
      <div class="terminal-header">
        <div class="terminal-title">Terminal</div>
        <div class="terminal-controls">
          <button
            type="button"
            class="terminal-control terminal-control-minimize"
            aria-label="Minimize terminal"
            phx-click={JS.dispatch("terminal:minimize", to: "##{@id}")}
          >
            _
          </button>
          <%= if assigns[:fullscreen] do %>
            <button
              type="button"
              class="terminal-control terminal-control-fullscreen"
              aria-label="Toggle fullscreen"
              phx-click={JS.dispatch("terminal:fullscreen", to: "##{@id}")}
            >
              [ ]
            </button>
          <% end %>
          <button
            type="button"
            class="terminal-control terminal-control-close"
            aria-label="Close terminal"
            phx-click={JS.dispatch("terminal:close", to: "##{@id}")}
          >
            ×
          </button>
        </div>
      </div>

      <.mono_grid id={"#{@id}-grid"} class="terminal-screen" cols={@cols} container={:pre}>
        <%= for line <- @output do %>
          <div class={["terminal-line", line[:type] && "terminal-line-#{line[:type]}"]}>
            <%= if line[:type] == :command do %>
              <span class="terminal-prompt">{@prompt}</span>{line[:content]}
            <% else %>
              {line[:content]}
            <% end %>
          </div>
        <% end %>
        <div class="terminal-input-line">
          <span class="terminal-prompt">{@prompt}</span>
          <input
            id={"#{@id}-input"}
            type="text"
            class="terminal-input"
            autocomplete="off"
            aria-label="Terminal input"
            phx-keydown="terminal_keydown"
            phx-keyup="terminal_keyup"
            phx-blur="terminal_blur"
            phx-focus="terminal_focus"
            phx-target={@myself}
            value={@current_command}
          />
        </div>

        <%= if @show_autocomplete && length(@autocomplete_options) > 0 do %>
          <div class="terminal-autocomplete">
            <%= for {option, idx} <- Enum.with_index(@autocomplete_options) do %>
              <div class={[
                "autocomplete-option",
                idx == @autocomplete_index && "autocomplete-selected"
              ]}>
                {option}
              </div>
            <% end %>
          </div>
        <% end %>
      </.mono_grid>
    </div>
    """
  end

  @impl true
  def handle_event("terminal_keydown", %{"key" => "Enter"}, socket) do
    # Execute command when Enter is pressed
    command = socket.assigns.current_command |> String.trim()
    history = socket.assigns.command_history
    output = socket.assigns.output

    # Don't do anything for empty commands
    if command == "" do
      {:noreply, socket}
    else
      # Add command to history and output
      # Limit history to 100 entries
      new_history = [command | history] |> Enum.take(100)
      new_output = output ++ [%{type: :command, content: command}]

      # Execute the command and get the result
      # Use try/rescue to handle any unexpected errors during command execution
      {result_output, command_result} =
        try do
          execute_command(command, socket.assigns)
        rescue
          e ->
            error_message = "An error occurred: #{Exception.message(e)}"
            {[%{type: :error, content: error_message}], :error}
        catch
          kind, reason ->
            error_message = "Unexpected #{kind}: #{inspect(reason)}"
            {[%{type: :error, content: error_message}], :error}
        end

      new_output = new_output ++ result_output

      {:noreply,
       socket
       |> assign(:command_history, new_history)
       |> assign(:history_index, 0)
       |> assign(:current_command, "")
       |> assign(:output, new_output)
       |> assign(:show_autocomplete, false)
       |> assign(:command_result, command_result)}
    end
  end

  def handle_event("terminal_keydown", %{"key" => "Tab"}, socket) do
    # Handle autocomplete
    current = socket.assigns.current_command
    show_autocomplete = socket.assigns.show_autocomplete
    autocomplete_options = socket.assigns.autocomplete_options
    autocomplete_index = socket.assigns.autocomplete_index

    cond do
      show_autocomplete && length(autocomplete_options) > 0 ->
        # If autocomplete is already shown, select the current option
        selected_option = Enum.at(autocomplete_options, autocomplete_index)

        {:noreply,
         socket
         |> assign(:current_command, selected_option)
         |> assign(:show_autocomplete, false)}

      true ->
        # Generate autocomplete options based on available commands and current input
        options =
          socket.assigns.available_commands
          |> Map.keys()
          |> Enum.filter(&String.starts_with?(&1, current))
          |> Enum.sort()

        if length(options) > 0 do
          {:noreply,
           socket
           |> assign(:show_autocomplete, true)
           |> assign(:autocomplete_options, options)
           |> assign(:autocomplete_index, 0)}
        else
          {:noreply, socket}
        end
    end
  end

  def handle_event("terminal_keydown", %{"key" => "ArrowUp"}, socket) do
    # Navigate command history up
    history = socket.assigns.command_history
    history_index = socket.assigns.history_index

    if history_index < length(history) do
      command = Enum.at(history, history_index)

      {:noreply,
       socket
       |> assign(:current_command, command)
       |> assign(:history_index, history_index + 1)
       |> assign(:show_autocomplete, false)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("terminal_keydown", %{"key" => "ArrowDown"}, socket) do
    # Navigate command history down
    history = socket.assigns.command_history
    history_index = socket.assigns.history_index

    cond do
      history_index > 1 ->
        command = Enum.at(history, history_index - 2)

        {:noreply,
         socket
         |> assign(:current_command, command)
         |> assign(:history_index, history_index - 1)
         |> assign(:show_autocomplete, false)}

      history_index == 1 ->
        {:noreply,
         socket
         |> assign(:current_command, "")
         |> assign(:history_index, 0)
         |> assign(:show_autocomplete, false)}

      true ->
        {:noreply, socket}
    end
  end

  def handle_event("terminal_keydown", %{"key" => "Escape"}, socket) do
    # Close autocomplete on Escape
    {:noreply, assign(socket, :show_autocomplete, false)}
  end

  def handle_event("terminal_keyup", %{"key" => key, "target" => %{"value" => value}}, socket)
      when key not in ["Enter", "Tab", "ArrowUp", "ArrowDown", "Escape"] do
    # Update the current command as user types
    {:noreply, assign(socket, :current_command, value)}
  end

  def handle_event("terminal_keyup", _params, socket) do
    # Ignore other key events
    {:noreply, socket}
  end

  def handle_event("terminal_focus", _params, socket) do
    # Handle terminal focus
    {:noreply, socket}
  end

  def handle_event("terminal_blur", _params, socket) do
    # Handle terminal blur
    {:noreply, socket}
  end

  # Private functions to handle command execution
  defp execute_command(raw_command, assigns) when is_binary(raw_command) do
    {command, args} = parse_command(raw_command)

    case command do
      "clear" ->
        execute_clear(args, assigns)

      "help" ->
        execute_help(args, assigns)

      "echo" ->
        execute_echo(args, assigns)

      "date" ->
        execute_date(args, assigns)

      "theme" ->
        execute_theme(args, assigns)

      "history" ->
        execute_history(args, assigns)

      "" ->
        {[
           %{type: :error, content: "Please enter a command. Type 'help' for available commands."}
         ], :error}

      _ ->
        {[
           %{
             type: :error,
             content: "Unknown command: #{command}. Type 'help' for available commands."
           }
         ], :error}
    end
  end

  defp execute_clear(_args, _assigns) do
    {[], :ok}
  end

  defp execute_help(args, assigns) do
    commands = assigns.available_commands

    if args == "" do
      # Show general help
      content = """
      Available commands:

      #{commands |> Map.keys() |> Enum.sort() |> Enum.map_join("\n", &"  #{&1} - #{commands[&1][:description]}")}

      Type 'help [command]' for more information on a specific command.
      """

      {[%{type: :system, content: content}], :ok}
    else
      # Show help for specific command
      command = args

      if Map.has_key?(commands, command) do
        cmd_info = commands[command]

        content = """
        #{command} - #{cmd_info[:description]}

        Usage: #{cmd_info[:usage]}
        """

        {[%{type: :system, content: content}], :ok}
      else
        {[
           %{
             type: :error,
             content: "Unknown command: #{command}. Type 'help' for available commands."
           }
         ], :error}
      end
    end
  end

  defp execute_echo(args, _assigns) do
    {[%{type: :output, content: args}], :ok}
  end

  defp execute_date(_args, _assigns) do
    now = DateTime.utc_now() |> DateTime.to_string()
    {[%{type: :output, content: "Current date and time: #{now}"}], :ok}
  end

  defp execute_theme(theme, _assigns) do
    if theme in ["light", "dark", "dim", "high-contrast"] do
      {[%{type: :system, content: "Switched to #{theme} theme."}], {:theme_change, theme}}
    else
      {[
         %{
           type: :error,
           content: "Unknown theme: #{theme}. Available themes: light, dark, dim, high-contrast"
         }
       ], :error}
    end
  end

  defp execute_history(args, assigns) do
    history = assigns.command_history

    if args == "clear" do
      {[%{type: :system, content: "Command history cleared."}], {:clear_history, []}}
    else
      content =
        history
        |> Enum.reverse()
        |> Enum.with_index(1)
        |> Enum.map_join("\n", fn {cmd, idx} -> "  #{idx}: #{cmd}" end)

      {[%{type: :output, content: content}], :ok}
    end
  end

  # Add a new helper function for safer command parsing
  defp parse_command(raw_command) when is_binary(raw_command) do
    # Trim leading and trailing whitespace
    trimmed = String.trim(raw_command)

    # Split into command and arguments
    case String.split(trimmed, " ", parts: 2) do
      [command] -> {command, ""}
      [command, args] -> {command, String.trim(args)}
      # This should never happen with String.split, but just in case
      _ -> {"", ""}
    end
  end
end
