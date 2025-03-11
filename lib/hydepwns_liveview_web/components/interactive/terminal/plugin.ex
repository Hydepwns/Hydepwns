defmodule HydepwnsLiveviewWeb.Components.Interactive.Terminal.Plugin do
  @moduledoc """
  Behaviour for Terminal Plugins

  This behaviour defines the interface for plugins that can be used with the Terminal component.
  Implementing this behaviour allows creating custom command processors that can be
  added to the terminal.
  """

  @doc """
  Returns the name of the plugin, used as a namespace for commands.
  """
  @callback name() :: String.t()

  @doc """
  Initializes the plugin state.
  """
  @callback init() :: {:ok, map()}

  @doc """
  Returns a map of commands supported by this plugin.
  Each command should have a description and usage instructions.
  """
  @callback commands() :: map()

  @doc """
  Executes a command with the given arguments and state.

  Returns a tuple with:
  - :ok or :error
  - Output message 
  - Updated state
  """
  @callback execute(command :: String.t(), args :: String.t(), state :: map()) ::
              {:ok, String.t(), map()} | {:error, String.t(), map()}

  @doc """
  Provides autocomplete suggestions for a given prefix.
  """
  @callback autocomplete(prefix :: String.t()) :: [String.t()]
end
