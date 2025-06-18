defmodule HydepwnsLiveviewWeb.ResourceDSL do
  @moduledoc """
  Provides a DSL for defining resource-oriented socket assigns in LiveViews.
  """

  alias HydepwnsLiveview.Utils.SocketValidator

  defmacro __using__(_opts) do
    quote do
      use HydepwnsLiveviewWeb, :live_view
      import HydepwnsLiveviewWeb.ResourceDSL
      import Phoenix.LiveView
      import Phoenix.LiveView.Helpers
      alias HydepwnsLiveview.Utils.LiveViewAPI

      Module.register_attribute(__MODULE__, :resource_attributes, accumulate: true)
      Module.register_attribute(__MODULE__, :resource_relationships, accumulate: true)

      @before_compile HydepwnsLiveviewWeb.ResourceDSL

      defoverridable mount: 3, handle_params: 3

      # DSL for defining socket assigns
      def assigns(block) do
        # This is a placeholder for more complex macro logic
        # that would parse the block and define assigns.
        # For now, we'll just execute the block in the context of the module.
        block
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @impl true
      def mount(params, session, socket) do
        # We call super to allow the user to define their own mount,
        # then we add our validation logic.
        case super(params, session, socket) do
          {:ok, socket} ->
            validate_socket(socket)

          {:error, _reason} = error ->
            error
        end
      end

      defp validate_socket(socket) do
        attributes = Module.get_attribute(__MODULE__, :resource_attributes)
        relationships = Module.get_attribute(__MODULE__, :resource_relationships)
        schema = build_schema(attributes, relationships)

        case SocketValidator.validate(socket, schema) do
          :ok ->
            {:ok, socket}

          {:error, errors} ->
            raise "Invalid socket assigns: #{inspect(errors)}"
        end
      end

      defp build_schema(attributes, relationships) do
        # TODO:This is a simplified schema builder.
        # In a real implementation, this would be more robust.
        Enum.into(attributes, %{}, fn {name, opts} -> {name, Keyword.get(opts, :type, :any)} end)
      end
    end
  end

  # DSL functions
  defmacro attribute(name, type, options \\ []) do
    quote do
      @resource_attributes {unquote(name), [type: unquote(type)] ++ unquote(options)}
    end
  end

  defmacro relationship(name, type, resource, options \\ []) do
    quote do
      @resource_relationships {unquote(name),
                               [type: unquote(type), resource: unquote(resource)] ++
                                 unquote(options)}
    end
  end
end
