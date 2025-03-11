# Terminal Plugin System

## Overview

The Terminal Plugin System allows adding custom command handlers to the Terminal component. Plugins are Elixir modules that implement the `HydepwnsLiveviewWeb.Components.Interactive.Terminal.Plugin` behavior, providing a standardized way to extend the terminal's functionality.

## Plugin Behavior

All terminal plugins must implement the `HydepwnsLiveviewWeb.Components.Interactive.Terminal.Plugin` behavior, which defines the following callbacks:

```elixir
defmodule HydepwnsLiveviewWeb.Components.Interactive.Terminal.Plugin do
  @moduledoc """
  Behaviour for Terminal Plugins
  
  This behaviour defines the interface for plugins that can be used with the Terminal component.
  Implementing this behaviour allows creating custom command processors that can be
  added to the terminal.
  """
  
  @callback name() :: String.t()
  @callback init() :: {:ok, map()}
  @callback commands() :: map()
  @callback execute(command :: String.t(), args :: String.t(), state :: map()) :: 
    {:ok, String.t(), map()} | {:error, String.t(), map()}
  @callback autocomplete(prefix :: String.t()) :: [String.t()]
end
```

### Callback Descriptions

| Callback | Description |
|----------|-------------|
| `name/0` | Returns the name of the plugin, used as a namespace for commands |
| `init/0` | Initializes the plugin state |
| `commands/0` | Returns a map of commands supported by this plugin |
| `execute/3` | Executes a command with the given arguments and state |
| `autocomplete/1` | Provides autocomplete suggestions for a given prefix |

## Creating a Plugin

To create a new terminal plugin, follow these steps:

1. Create a new module that implements the Plugin behavior
2. Define the required callbacks
3. Register the plugin with the Terminal component

### Example Plugin

Here's a simple example of a plugin that provides weather information:

```elixir
defmodule HydepwnsLiveviewWeb.Components.Interactive.Plugins.Weather do
  @behaviour HydepwnsLiveviewWeb.Components.Interactive.Terminal.Plugin

  @impl true
  def name, do: "weather"

  @impl true
  def init do
    {:ok, %{last_lookup: nil}}
  end

  @impl true
  def commands do
    %{
      "weather" => %{
        description: "Get weather information for a location",
        usage: "weather [location]"
      },
      "forecast" => %{
        description: "Get a 5-day forecast for a location",
        usage: "forecast [location]"
      }
    }
  end

  @impl true
  def execute("weather", location, state) do
    # In a real implementation, this would call a weather API
    response = """
    Weather for #{location}:
    
    Temperature: 72°F
    Condition: Partly Cloudy
    Humidity: 45%
    Wind: 5 mph NW
    """
    
    updated_state = %{state | last_lookup: location}
    {:ok, response, updated_state}
  end

  @impl true
  def execute("forecast", location, state) do
    # In a real implementation, this would call a weather API
    response = """
    5-day Forecast for #{location}:
    
    Monday: 72°F, Partly Cloudy
    Tuesday: 75°F, Sunny
    Wednesday: 68°F, Rain
    Thursday: 70°F, Cloudy
    Friday: 73°F, Partly Cloudy
    """
    
    updated_state = %{state | last_lookup: location}
    {:ok, response, updated_state}
  end

  @impl true
  def execute(cmd, _args, state) do
    {:error, "Unknown weather command: #{cmd}", state}
  end

  @impl true
  def autocomplete(prefix) do
    commands = ["weather", "forecast"]
    
    # Filter commands by prefix
    filtered_commands = Enum.filter(commands, fn cmd -> 
      String.starts_with?(cmd, prefix) 
    end)
    
    # Add common location completions
    if String.starts_with?("weather ", prefix) or String.starts_with?("forecast ", prefix) do
      locations = ["new york", "los angeles", "chicago", "houston", "phoenix"]
      
      location_prefix = String.replace_prefix(prefix, "weather ", "")
      location_prefix = String.replace_prefix(location_prefix, "forecast ", "")
      
      cmd_prefix = if String.contains?(prefix, "forecast"), do: "forecast ", else: "weather "
      
      location_completions = Enum.filter(locations, fn loc -> 
        String.starts_with?(loc, location_prefix) 
      end)
      |> Enum.map(fn loc -> "#{cmd_prefix}#{loc}" end)
      
      filtered_commands ++ location_completions
    else
      filtered_commands
    end
  end
end
```

## Registering Plugins with the Terminal

To use a plugin with the Terminal component, you need to register it when rendering the terminal:

```elixir
<.live_component
  module={HydepwnsLiveviewWeb.Components.Interactive.Terminal}
  id="example-terminal"
  prompt="$ "
  plugins={[
    HydepwnsLiveviewWeb.Components.Interactive.Plugins.Navigation,
    HydepwnsLiveviewWeb.Components.Interactive.Plugins.Weather
  ]}
/>
```

## State Management

Each plugin maintains its own state, which is passed back and forth between the terminal and the plugin. The plugin's `init/0` callback initializes the state, and the `execute/3` callback returns an updated state.

The terminal component will store each plugin's state separately and provide it to the plugin when executing commands.

## Command Routing

When a user enters a command, the terminal will route it to the appropriate plugin based on the command name. If multiple plugins support the same command, the first one registered will handle it.

## Best Practices

1. **Use clear command names** - Choose command names that are descriptive and unlikely to conflict with other plugins
2. **Provide helpful error messages** - When a command fails, return an error message that helps the user understand what went wrong
3. **Implement autocomplete** - Add comprehensive autocomplete support to make your commands easier to discover and use
4. **Keep state minimal** - Only store what's necessary in your plugin's state
5. **Add documentation** - Document your plugin's commands and usage in the `commands/0` callback

## Example Usage

With the Weather plugin registered, users can enter commands like:

```bash
weather new york
forecast chicago
```

And use Tab for autocompletion.

## Implementing @impl true Annotations

All callback implementations should be annotated with `@impl true` to make the code more maintainable and to properly document which functions are implementing the behavior:

```elixir
@impl true
def name, do: "my_plugin"

@impl true
def init, do: {:ok, %{}}

@impl true
def commands, do: %{...}

@impl true
def execute(command, args, state), do: ...

@impl true
def autocomplete(prefix), do: ...
```

These annotations help the compiler validate that your plugin correctly implements all required callbacks. 