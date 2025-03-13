defmodule HydepwnsLiveview.Events.Handlers.HandlerSupervisor do
  @moduledoc """
  Supervisor for event handler processes.

  This supervisor manages all event handlers in the system, allowing for:
  - Starting new handlers
  - Stopping handlers
  - Listing active handlers
  - Dynamic management of handler processes at runtime

  Handlers implement the `HydepwnsLiveview.Events.Handler` behavior.
  """

  use DynamicSupervisor
  require Logger

  alias HydepwnsLiveview.Events.HandlerProcess

  @doc """
  Starts the handler supervisor.
  """
  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a new handler process.

  ## Parameters

  * `handler_module` - The handler module to start (must implement `HydepwnsLiveview.Events.Handler`)
  * `opts` - Options for the handler
    * `:name` - Optional name for the handler process
    * `:event_types` - Event types to handle (default: from handler's interested_in/0)

  ## Returns

  * `{:ok, pid}` - The handler was started successfully
  * `{:error, reason}` - The handler failed to start
  """
  def start_handler(handler_module, opts \\ []) do
    # Set up options for the handler process
    name_opts =
      case Keyword.get(opts, :name) do
        nil -> []
        name -> [name: name]
      end

    # Start the handler process under this supervisor
    DynamicSupervisor.start_child(
      __MODULE__,
      {HandlerProcess, [handler_module, opts, name_opts]}
    )
  end

  @doc """
  Stops a handler process.

  ## Parameters

  * `handler_ref` - PID or name of the handler process to stop

  ## Returns

  * `:ok` - The handler was stopped
  * `{:error, :not_found}` - No handler found with the given reference
  """
  def stop_handler(handler_ref) do
    case get_handler_pid(handler_ref) do
      nil -> {:error, :not_found}
      pid -> DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end

  @doc """
  Lists all active handlers.

  ## Returns

  * `{:ok, handlers}` - List of {handler_module, pid} tuples
  """
  def list_handlers do
    handlers =
      DynamicSupervisor.which_children(__MODULE__)
      |> Enum.map(fn {_, pid, _, _} ->
        case pid do
          :undefined ->
            nil

          pid when is_pid(pid) ->
            try do
              {:ok, handler_module} = GenServer.call(pid, :get_handler_module)
              {handler_module, pid}
            catch
              :exit, _ -> nil
            end
        end
      end)
      |> Enum.reject(&is_nil/1)

    {:ok, handlers}
  end

  @doc """
  Sends a message to a specific handler.

  ## Parameters

  * `handler_ref` - PID or name of the handler to send the message to
  * `message` - The message to send

  ## Returns

  * `{:ok, reply}` - The handler processed the message and returned a reply
  * `{:error, :not_found}` - No handler found with the given reference
  * `{:error, reason}` - The handler could not process the message
  """
  def send_to_handler(handler_ref, message) do
    case get_handler_pid(handler_ref) do
      nil ->
        {:error, :not_found}

      pid ->
        try do
          {:ok, GenServer.call(pid, {:handle_message, message})}
        catch
          :exit, reason -> {:error, reason}
        end
    end
  end

  # Private functions

  # Gets the PID of a handler based on a reference (name or PID)
  defp get_handler_pid(handler_ref) when is_pid(handler_ref) do
    # Check if the PID is a child of this supervisor
    if DynamicSupervisor.which_children(__MODULE__)
       |> Enum.any?(fn {_, pid, _, _} -> pid == handler_ref end) do
      handler_ref
    else
      nil
    end
  end

  defp get_handler_pid(handler_ref) when is_atom(handler_ref) do
    # Try to find a process with the given name
    case Process.whereis(handler_ref) do
      nil -> nil
      pid -> get_handler_pid(pid)
    end
  end

  defp get_handler_pid(_), do: nil
end
