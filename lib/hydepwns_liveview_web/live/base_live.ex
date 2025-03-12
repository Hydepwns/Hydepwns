defmodule HydepwnsLiveviewWeb.BaseLive do
  @moduledoc """
  Base module for LiveViews with standardized parameter validation.

  Provides mount hooks and validation to ensure all required assigns are
  present, preventing KeyErrors and improving error handling.

  ## Usage

  ```elixir
  defmodule MyAppWeb.ExampleLive do
    use HydepwnsLiveviewWeb.BaseLive, 
      required_assigns: [:user_id, :theme],
      type_specs: %{
        user_id: :string,
        theme: {:one_of, ["dark", "light", "dim"]},
        settings: %{notifications: :boolean}
      }
    
    @impl true
    def mount(params, session, socket) do
      # Call the parent mount function which will call do_mount
      super(params, session, socket)
    end
    
    # Your LiveView implementation using do_mount callback
    def do_mount(_params, session, socket) do
      socket
      |> Phoenix.Component.assign(:user_id, Map.get(session, "user_id"))
      |> Phoenix.Component.assign(:theme, Map.get(session, "theme", "dark"))
      |> Phoenix.Component.assign(:settings, %{notifications: true})
    end
    
    # Your LiveView implementation...
  end
  ```
  """

  alias HydepwnsLiveview.Utils.SocketValidator
  alias HydepwnsLiveview.Utils.SocketValidationDebugGrid

  defmacro __using__(opts) do
    required_assigns = Keyword.get(opts, :required_assigns, [])
    type_specs = Keyword.get(opts, :type_specs, %{})
    # New option to control validation behavior
    validation_behavior = Keyword.get(opts, :validation_behavior, :log)
    # New option to enable/disable debug grid integration
    enable_debug_grid = Keyword.get(opts, :enable_debug_grid, true)

    quote do
      use Phoenix.LiveView
      alias HydepwnsLiveview.Utils.SocketValidator
      alias HydepwnsLiveview.Utils.SocketValidationDebugGrid
      require Logger

      @required_assigns unquote(required_assigns)
      @type_specs unquote(Macro.escape(type_specs))
      @validation_behavior unquote(validation_behavior)
      @enable_debug_grid unquote(enable_debug_grid)

      # Define behavior for do_mount that will be implemented by child modules
      @callback do_mount(map(), map(), Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()

      # Override the mount callback
      @impl Phoenix.LiveView
      def mount(params, session, socket) do
        # Store the view module in the socket for telemetry
        socket = Phoenix.Component.assign(socket, :view, __MODULE__)

        socket = mount_with_validation(params, session, socket)
        {:ok, socket}
      end

      defp mount_with_validation(params, session, socket) do
        # Call the implementation mount function
        socket = do_mount(params, session, socket)

        # Validate required assigns
        socket = validate_required_assigns(socket)

        # Validate assign types if type specs are provided
        socket = validate_assign_types(socket)

        # Add a history tracker for assign values
        socket =
          if Mix.env() == :dev do
            Phoenix.Component.assign(socket, :__validation_history__, %{})
          else
            socket
          end

        socket
      end

      # Validate that all required assigns are present
      defp validate_required_assigns(socket) do
        case SocketValidator.validate_required(socket, @required_assigns) do
          {:ok, _} ->
            socket =
              if Mix.env() == :dev && @enable_debug_grid do
                # Inject validation data into debug grid
                SocketValidationDebugGrid.inject_validation_data(
                  socket,
                  @type_specs,
                  @required_assigns
                )
              else
                socket
              end

            socket

          {:error, missing} ->
            # Log the error but continue with defaults
            error_message = "Missing required assigns: #{inspect(missing)} in #{__MODULE__}"
            Logger.warning(error_message)

            # Add default values for missing assigns
            defaults = Enum.map(missing, fn key -> {key, nil} end) |> Enum.into(%{})

            # In development, consider showing a flash message
            socket =
              if @validation_behavior == :flash && Mix.env() == :dev do
                Phoenix.LiveView.put_flash(socket, :error, error_message)
              else
                socket
              end

            # Inject validation data into debug grid in development
            socket =
              if Mix.env() == :dev && @enable_debug_grid do
                socket = Phoenix.Component.assign(socket, defaults)

                SocketValidationDebugGrid.inject_validation_data(
                  socket,
                  @type_specs,
                  @required_assigns
                )
              else
                socket
              end

            Phoenix.Component.assign(socket, defaults)
        end
      end

      # Validate types of assigns based on type_specs
      defp validate_assign_types(socket) do
        # Only validate assigns that have specified type specs
        socket =
          Enum.reduce(@type_specs, socket, fn {key, type_spec}, acc_socket ->
            # Skip validation if the key doesn't exist (it might be optional)
            if Map.has_key?(acc_socket.assigns, key) do
              # Store the previous value for this assign in history
              acc_socket = update_validation_history(acc_socket, key)

              case SocketValidator.type_validation(acc_socket, key, type_spec) do
                {:ok, _} ->
                  acc_socket

                {:error, message, _} ->
                  # Create context-aware error message
                  context_message = SocketValidator.context_aware_error(message, key, acc_socket)

                  # Log the error but continue with the current value
                  Logger.warning(context_message)

                  # Development handling - can be configured by validation_behavior
                  if Mix.env() == :dev do
                    case @validation_behavior do
                      :raise ->
                        # Raise an error in development for immediate feedback
                        raise "Type validation error: #{context_message}"

                      :flash ->
                        # Add flash message but don't crash the app
                        Phoenix.LiveView.put_flash(acc_socket, :error, context_message)

                      :telemetry_only ->
                        # Do nothing, the telemetry event was already sent by SocketValidator
                        acc_socket

                      _ ->
                        # Default: log but don't disrupt the user experience
                        Logger.error("[TYPE VALIDATION ERROR] #{context_message}")
                        acc_socket
                    end
                  else
                    acc_socket
                  end
              end
            else
              acc_socket
            end
          end)

        # In development, inject validation data into debug grid
        if Mix.env() == :dev && @enable_debug_grid do
          SocketValidationDebugGrid.inject_validation_data(socket, @type_specs, @required_assigns)
        else
          socket
        end
      end

      # Store assign value history for context-aware error messages
      defp update_validation_history(socket, key) do
        if Mix.env() == :dev do
          current_value = Map.get(socket.assigns, key)

          socket =
            if Map.has_key?(socket.assigns, :__validation_history__) do
              history = Map.get(socket.assigns, :__validation_history__, %{})
              key_history = Map.get(history, key, [])
              updated_key_history = [current_value | key_history] |> Enum.take(5)
              updated_history = Map.put(history, key, updated_key_history)

              Phoenix.Component.assign(socket, :__validation_history__, updated_history)
            else
              # Initialize history if it doesn't exist
              Phoenix.Component.assign(socket, :__validation_history__, %{key => [current_value]})
            end

          # Set the current lifecycle phase if it's not already set
          if !Map.has_key?(socket.assigns, :__lifecycle_phase__) do
            lifecycle_phase = detect_lifecycle_phase()
            Phoenix.Component.assign(socket, :__lifecycle_phase__, lifecycle_phase)
          else
            socket
          end
        else
          # In production, don't track history
          socket
        end
      end

      # Helper to detect the current lifecycle phase
      defp detect_lifecycle_phase() do
        # Analyze the call stack to determine the lifecycle phase
        # This is a heuristic and might not be 100% accurate
        stack = Process.info(self(), :current_stacktrace)

        if stack do
          {_, stacktrace} = stack

          cond do
            Enum.any?(stacktrace, fn {m, f, _, _} ->
              m == Phoenix.LiveView.Lifecycle && f == :mount
            end) ->
              :mount

            Enum.any?(stacktrace, fn {m, f, _, _} ->
              m == Phoenix.LiveView.Lifecycle && f == :handle_params
            end) ->
              :handle_params

            Enum.any?(stacktrace, fn {m, f, _, _} ->
              m == Phoenix.LiveView.Channel && f == :handle_event
            end) ->
              :handle_event

            Enum.any?(stacktrace, fn {m, f, _, _} ->
              m == Phoenix.LiveView.Channel && f == :handle_info
            end) ->
              :handle_info

            true ->
              :unknown
          end
        else
          :unknown
        end
      end

      # Handler for validation error highlighting in UI
      def handle_info({:highlight_validation_errors, validation_results}, socket) do
        socket = SocketValidationDebugGrid.highlight_validation_errors(socket)
        {:noreply, socket}
      end

      # Handler for opening the validation panel
      def handle_info(:open_validation_panel, socket) do
        # Send a message to the PubSub to show the validation panel
        Phoenix.PubSub.broadcast(
          HydepwnsLiveview.PubSub,
          "socket_validation",
          {:show_validation_panel}
        )

        {:noreply, socket}
      end

      # Default implementation that can be overridden
      def do_mount(_params, _session, socket), do: socket

      # Provide super implementation so modules can call super mount
      defoverridable mount: 3, do_mount: 3
    end
  end
end
