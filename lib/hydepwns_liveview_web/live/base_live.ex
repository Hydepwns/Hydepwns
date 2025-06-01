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
        settings: {:map, %{notifications: :boolean}} # Note: For map schemas, use {:map, %{...}}
      },
      validation_behavior: :log # Options: :log, :raise, :flash, :telemetry_only (defaults to :log)

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
    type_specs_option = Keyword.get(opts, :type_specs, %{})

    type_specs_ast_for_unquote =
      cond do
        is_map(type_specs_option) ->
          Macro.escape(type_specs_option)

        is_tuple(type_specs_option) and tuple_size(type_specs_option) == 3 and
            elem(type_specs_option, 0) == :%{} ->
          # Use the AST as is
          type_specs_option

        true ->
          raise ArgumentError,
                "Invalid type_specs. Expected map or map AST (e.g., {:%{}, meta, pairs}). Got: #{inspect(type_specs_option)}"
      end

    # :log, :raise, :flash, :telemetry_only
    validation_behavior = Keyword.get(opts, :validation_behavior, :log)
    enable_debug_grid = Keyword.get(opts, :enable_debug_grid, true)

    quote do
      # Use the project's standard live_view setup first
      use HydepwnsLiveviewWeb, :live_view

      @behaviour HydepwnsLiveviewWeb.BaseLive.Behaviour
      alias HydepwnsLiveview.Utils.SocketValidator
      alias HydepwnsLiveview.Utils.SocketValidationDebugGrid
      require Logger

      @required_assigns unquote(required_assigns)
      @hydepwns_base_live_type_specs unquote(type_specs_ast_for_unquote)
      # Store compile-time validation_behavior to be accessible and serve as a default at runtime
      @compile_time_validation_behavior unquote(validation_behavior)
      @enable_debug_grid unquote(enable_debug_grid)

      # Helper function to get the actual type_specs map at runtime
      defp __get_type_specs_map__ do
        @hydepwns_base_live_type_specs
      end

      # Define behavior for do_mount that will be implemented by child modules
      @callback do_mount(map(), map(), Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()

      # Override the mount callback
      @impl Phoenix.LiveView
      def mount(params, session, socket) do
        socket = Phoenix.Component.assign(socket, :view, __MODULE__)
        # Assign compile-time behavior so it can be read by validation functions
        socket =
          Phoenix.Component.assign(
            socket,
            :__base_live_compile_time_validation_behavior__,
            @compile_time_validation_behavior
          )

        socket = mount_with_validation(params, session, socket)
        {:ok, socket}
      end

      defp mount_with_validation(params, session, socket) do
        # Call the implementation mount function from the child module
        socket = do_mount(params, session, socket)

        # Validate required assigns
        socket = validate_required_assigns(socket)

        # Validate assign types if type specs are provided
        socket = validate_assign_types(socket)

        # Initialize history tracker for assign values in dev
        socket =
          if Mix.env() == :dev do
            Phoenix.Component.assign_new(socket, :__validation_history__, fn -> %{} end)
          else
            socket
          end

        socket
      end

      # Validate that all required assigns are present
      defp validate_required_assigns(socket) do
        case SocketValidator.validate_required(socket, @required_assigns) do
          {:ok, _} ->
            socket_maybe_with_grid =
              if Mix.env() == :dev && @enable_debug_grid do
                SocketValidationDebugGrid.inject_validation_data(
                  socket,
                  __get_type_specs_map__(),
                  @required_assigns
                )
              else
                socket
              end

            socket_maybe_with_grid

          {:error, missing} ->
            view_module = socket.assigns.view || __MODULE__

            lifecycle_info =
              if Mix.env() == :dev, do: " during #{detect_lifecycle_phase()}", else: ""

            error_message =
              "[BaseLive Validation] Missing required assigns: #{inspect(missing)} in #{view_module}#{lifecycle_info}."

            Logger.warning(error_message)

            defaults = Enum.map(missing, fn key -> {key, nil} end) |> Enum.into(%{})
            socket_with_defaults = Phoenix.Component.assign(socket, defaults)

            # Determine runtime validation behavior, preferring assign, then compile-time, then :log
            current_validation_behavior =
              socket.assigns[:validation_behavior] ||
                socket.assigns[:__base_live_compile_time_validation_behavior__] ||
                :log

            socket_with_flash_option =
              if current_validation_behavior == :flash && Mix.env() == :dev do
                Phoenix.LiveView.put_flash(socket_with_defaults, :error, error_message)
              else
                socket_with_defaults
              end

            if Mix.env() == :dev && @enable_debug_grid do
              SocketValidationDebugGrid.inject_validation_data(
                socket_with_flash_option,
                __get_type_specs_map__(),
                @required_assigns
              )
            else
              socket_with_flash_option
            end
        end
      end

      # Validate types of assigns based on type_specs
      defp validate_assign_types(socket) do
        # Process assigns with type specs
        final_socket =
          Enum.reduce(__get_type_specs_map__(), socket, fn {key, type_spec}, acc_socket ->
            # Skip validation if the key doesn't exist (it might be optional)
            if Map.has_key?(acc_socket.assigns, key) do
              # Store the previous value for this assign in history (dev only)
              acc_socket_with_history =
                if Mix.env() == :dev,
                  do: update_validation_history(acc_socket, key),
                  else: acc_socket

              case SocketValidator.type_validation(acc_socket_with_history, key, type_spec) do
                {:ok, _} ->
                  acc_socket_with_history

                {:error, simple_error_message, _socket_from_validator} ->
                  view_module = acc_socket_with_history.assigns.view || __MODULE__

                  # Determine runtime validation behavior
                  current_validation_behavior =
                    acc_socket_with_history.assigns[:validation_behavior] ||
                      acc_socket_with_history.assigns[
                        :__base_live_compile_time_validation_behavior__
                      ] ||
                      :log

                  if Mix.env() == :dev do
                    # Generate detailed context message for dev environment
                    detailed_context_message =
                      SocketValidator.context_aware_error(
                        simple_error_message,
                        key,
                        acc_socket_with_history
                      )

                    # Log detailed message in dev
                    Logger.warning(
                      "[BaseLive Validation] Detailed Type Error (Dev):\nView: #{view_module}\nAssign: :#{key}\nValue: #{inspect(Map.get(acc_socket_with_history.assigns, key))}\n#{detailed_context_message}"
                    )

                    case current_validation_behavior do
                      :raise ->
                        raise "[BaseLive Validation] Type error in #{view_module} for assign :#{key}. Details in console. Value: #{inspect(Map.get(acc_socket_with_history.assigns, key))}"

                      :flash ->
                        # Flash a concise message, details are in console
                        Phoenix.LiveView.put_flash(
                          acc_socket_with_history,
                          :error,
                          "[BaseLive Validation] Type Error for :#{key} in #{view_module}. Check console for details."
                        )

                      :telemetry_only ->
                        # Telemetry already sent by SocketValidator, detailed log already done
                        acc_socket_with_history

                      # :log or other default
                      _ ->
                        # Detailed log already done
                        acc_socket_with_history
                    end
                  else
                    # Production logging: simpler message
                    Logger.warning(
                      "[BaseLive Validation] Type error for assign :#{key} in #{view_module}: #{simple_error_message}."
                    )

                    acc_socket_with_history
                  end
              end
            else
              # Key not in assigns, skip (might be optional, or will be caught by required_assigns if not)
              acc_socket
            end
          end)

        # In development, inject validation data into debug grid (after all validations)
        if Mix.env() == :dev && @enable_debug_grid do
          SocketValidationDebugGrid.inject_validation_data(
            final_socket,
            __get_type_specs_map__(),
            @required_assigns
          )
        else
          final_socket
        end
      end

      # Store assign value history for context-aware error messages
      defp update_validation_history(socket, key) do
        # This function is only called in :dev environment.
        current_value = Map.get(socket.assigns, key)

        socket_with_history =
          if Map.has_key?(socket.assigns, :__validation_history__) do
            history = Map.get(socket.assigns, :__validation_history__, %{})
            key_history = Map.get(history, key, [])
            # Ensure history is always a list before prepending
            updated_key_history =
              [current_value | if(is_list(key_history), do: key_history, else: [])]
              |> Enum.take(5)

            updated_history = Map.put(history, key, updated_key_history)
            Phoenix.Component.assign(socket, :__validation_history__, updated_history)
          else
            # Initialize history if it doesn't exist
            Phoenix.Component.assign(socket, :__validation_history__, %{key => [current_value]})
          end

        # Set the current lifecycle phase if it's not already set for this validation cycle
        # Use assign_new to only set it once per overall validation context if not present
        Phoenix.Component.assign_new(socket_with_history, :__lifecycle_phase__, fn ->
          detect_lifecycle_phase()
        end)
      end

      # Helper to detect the current lifecycle phase
      defp detect_lifecycle_phase() do
        # This function is primarily called in :dev environment.
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
      @impl Phoenix.LiveView
      def handle_info({:highlight_validation_errors, _validation_results}, socket) do
        # _validation_results are not directly used here;
        # SocketValidationDebugGrid.highlight_validation_errors likely uses data already in the socket
        new_socket = SocketValidationDebugGrid.highlight_validation_errors(socket)
        {:noreply, new_socket}
      end

      # Handler for opening the validation panel
      @impl Phoenix.LiveView
      def handle_info(:open_validation_panel, socket) do
        Phoenix.PubSub.broadcast(
          HydepwnsLiveview.PubSub,
          "socket_validation",
          {:show_validation_panel}
        )

        {:noreply, socket}
      end

      # Default implementation that can be overridden
      @impl HydepwnsLiveviewWeb.BaseLive.Behaviour
      def do_mount(_params, _session, socket), do: socket

      # Provide super implementation so modules can call super mount
      defoverridable mount: 3, do_mount: 3
    end
  end
end

defmodule HydepwnsLiveviewWeb.BaseLive.Behaviour do
  # Changed to return socket directly for simplicity
  @callback do_mount(params :: map(), session :: map(), socket :: Phoenix.LiveView.Socket.t()) ::
              Phoenix.LiveView.Socket.t()
end
