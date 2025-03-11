defmodule HydepwnsLiveviewWeb.Components.Terminal do
  @moduledoc """
  An interactive terminal component with command history and customization options.
  
  This component provides:
  - Command-line interface with history management
  - Custom command registration and execution
  - Syntax highlighting for terminal output
  - Persistent command history using localStorage
  - Customizable prompt and appearance
  
  The terminal uses the MonoGrid component to ensure proper character alignment.
  
  ## Examples

      <.terminal id="example-terminal" />

      <.terminal 
        id="custom-terminal" 
        prompt="user@hydepwns:~$" 
        welcome_message="Welcome to Hydepwns Terminal v1.0.0" 
        available_commands={@custom_commands}
      />
  """
  use HydepwnsLiveviewWeb, :live_component
  alias HydepwnsLiveviewWeb.Components.MonoGrid
  import HydepwnsLiveviewWeb.Components.MonoGrid

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
    # Merge the provided commands with the default commands
    commands =
      case assigns[:available_commands] do
        nil -> @default_commands
        custom_commands -> Map.merge(@default_commands, custom_commands)
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:available_commands, commands)
     |> assign_new(:cols, fn -> assigns[:cols] || @default_cols end)
     |> assign_new(:rows, fn -> assigns[:rows] || @default_rows end)
     |> assign_new(:prompt, fn -> assigns[:prompt] || @default_prompt end)
     |> assign_new(:welcome_message, fn -> assigns[:welcome_message] || @default_welcome_message end)
     |> assign_new(:theme, fn -> assigns[:theme] || "dark" end)
     |> assign_new(:command_history, fn -> [] end)
     |> assign_new(:output, fn -> [
        %{type: :system, content: assigns[:welcome_message] || @default_welcome_message}
      ] end)}
  end

  @doc """
  Renders a terminal component.
  
  ## Attributes
  
  * `id` - Required unique identifier for this terminal instance
  * `cols` - Number of columns in the terminal (default: #{@default_cols})
  * `rows` - Number of rows in the terminal viewport (default: #{@default_rows})
  * `prompt` - Terminal prompt string (default: "#{@default_prompt}")
  * `welcome_message` - Initial message shown in the terminal
  * `available_commands` - Map of custom commands this terminal should support
  * `theme` - Terminal theme: "light", "dark", "dim", "high-contrast" (default: "dark")
  * `wrap` - Whether to enable line wrapping (default: true)
  * `fullscreen` - Whether the terminal can be toggled to fullscreen mode (default: false)
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
      
      <.mono_grid 
        id={"#{@id}-grid"} 
        class="terminal-screen"
        cols={@cols} 
        container={:pre}
      >
        <%= for line <- @output do %>
          <div class={["terminal-line", line[:type] && "terminal-line-#{line[:type]}"]}>
            <%= if line[:type] == :command do %>
              <span class="terminal-prompt"><%= @prompt %></span><%= line[:content] %>
            <% else %>
              <%= line[:content] %>
            <% end %>
          </div>
        <% end %>
        <div class="terminal-input-line">
          <span class="terminal-prompt"><%= @prompt %></span>
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
              <div class={["autocomplete-option", idx == @autocomplete_index && "autocomplete-selected"]}>
                <%= option %>
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
    command = socket.assigns.current_command
    history = socket.assigns.command_history
    output = socket.assigns.output

    # Don't do anything for empty commands
    if command == "" do
      {:noreply, socket}
    else
      # Add command to history and output
      new_history = [command | history] |> Enum.take(100)  # Limit history to 100 entries
      new_output = output ++ [%{type: :command, content: command}]
      
      # Execute the command and get the result
      {result_output, command_result} = execute_command(command, socket.assigns)
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
  defp execute_command("clear", _assigns) do
    {[], :ok}
  end

  defp execute_command("help" <> args, assigns) do
    args = String.trim(args)
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
      command = String.trim(args)
      
      if Map.has_key?(commands, command) do
        cmd_info = commands[command]
        content = """
        #{command} - #{cmd_info[:description]}
        
        Usage: #{cmd_info[:usage]}
        """
        
        {[%{type: :system, content: content}], :ok}
      else
        {[%{type: :error, content: "Unknown command: #{command}"}], :error}
      end
    end
  end

  defp execute_command("echo" <> args, _assigns) do
    args = String.trim(args)
    {[%{type: :output, content: args}], :ok}
  end

  defp execute_command("date", _assigns) do
    now = DateTime.utc_now() |> DateTime.to_string()
    {[%{type: :output, content: "Current date and time: #{now}"}], :ok}
  end

  defp execute_command("theme" <> args, _assigns) do
    theme = String.trim(args)
    
    if theme in ["light", "dark", "dim", "high-contrast"] do
      {[%{type: :system, content: "Switched to #{theme} theme."}], {:theme_change, theme}}
    else
      {[%{type: :error, content: "Unknown theme: #{theme}. Available themes: light, dark, dim, high-contrast"}], :error}
    end
  end

  defp execute_command("history" <> args, assigns) do
    args = String.trim(args)
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

  defp execute_command(command, _assigns) do
    # Extract the command name (before the first space)
    command_name =
      case String.split(command, " ", parts: 2) do
        [name | _] -> name
        [] -> command
      end
    
    {[%{type: :error, content: "Unknown command: #{command_name}. Type 'help' for available commands."}], :error}
  end
end 