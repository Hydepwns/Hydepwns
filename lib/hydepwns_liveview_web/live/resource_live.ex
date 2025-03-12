defmodule HydepwnsLiveviewWeb.ResourceLive do
  @moduledoc """
  Enhanced LiveView module with resource-oriented socket assigns.

  This module extends BaseLive by adding support for declarative socket assigns
  using an Ash-inspired DSL pattern. It allows LiveViews to define their socket 
  assigns as first-class resources with attributes, validations, and relationships.

  ## Features

  - Declarative socket schema specification using `assigns do ... end` DSL
  - Resource-oriented socket assigns
  - Automatic validation of socket assigns
  - API-based access patterns

  ## Usage

  ```elixir
  defmodule MyAppWeb.UserLive do
    use HydepwnsLiveviewWeb.ResourceLive
    
    assigns do
      attribute :user_id, :string, required: true
      attribute :username, :string, required: true
      attribute :role, {:one_of, ["admin", "user", "guest"]}, default: "user"
      
      # Nested attributes using map schema
      attribute :settings, :map do
        attribute :theme, {:one_of, ["dark", "light", "system"]}, default: "system"
        attribute :notifications, :boolean, default: true
      end
      
      # Relationships to other resources
      relationship :team, :belongs_to, MyApp.TeamResource
      relationship :posts, :has_many, MyApp.PostResource
    end
    
    def do_mount(params, session, socket) do
      # Your mount logic here
      {:ok, assign(socket, :user_id, "123")}
    end
    
    # Your LiveView implementation...
  end
  ```
  """

  alias HydepwnsLiveview.Utils.LiveViewAPI
  alias HydepwnsLiveview.Utils.SocketValidator

  defmacro __using__(_opts) do
    quote do
      use HydepwnsLiveviewWeb.BaseLive
      import HydepwnsLiveviewWeb.ResourceLive
      import Phoenix.LiveView
      import Phoenix.LiveView.Helpers
      alias HydepwnsLiveview.Utils.LiveViewAPI

      Module.register_attribute(__MODULE__, :resource_attributes, accumulate: true)
      Module.register_attribute(__MODULE__, :resource_relationships, accumulate: true)

      @before_compile HydepwnsLiveviewWeb.ResourceLive

      # Define do_mount before making it overridable
      def do_mount(params, session, socket) do
        {:ok, socket}
      end

      # Default implementation of do_mount to be overridden
      defoverridable do_mount: 3

      # Resource API Methods
      def get_resource(socket, field, default \\ nil) do
        LiveViewAPI.get(socket, field, default)
      end

      def update_resource(socket, resource_key, updates) do
        # Validate updates against the resource definition
        case validate_updates(socket, resource_key, updates) do
          {:ok, validated_updates} ->
            # Apply the validated updates
            socket = Phoenix.Component.assign(socket, validated_updates)
            {:ok, socket}

          {:error, message} ->
            # Log the validation error
            require Logger
            Logger.warning("Resource update validation failed: #{message}")

            # Return error with original socket
            {:error, message, socket}
        end
      end

      def validate_updates(socket, _resource_key, updates) do
        # Extract type specifications from metadata
        type_specs = __resource_type_specs__()

        # Check each update against its type specification
        validation_results =
          for {key, value} <- updates, Map.has_key?(type_specs, key) do
            type_spec = Map.get(type_specs, key)
            SocketValidator.validate_type(value, type_spec)
          end

        # Check if any validations failed
        errors =
          validation_results
          |> Enum.filter(fn
            {:error, _} -> true
            _ -> false
          end)
          |> Enum.map(fn {:error, message} -> message end)

        if Enum.empty?(errors) do
          {:ok, updates}
        else
          {:error, Enum.join(errors, "; ")}
        end
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __resource_metadata__ do
        %{
          attributes: @resource_attributes,
          relationships: @resource_relationships
        }
      end

      def __resource_type_specs__ do
        attrs =
          @resource_attributes
          |> Enum.map(fn attr ->
            {attr.name, attr.type}
          end)
          |> Map.new()

        attrs
      end
    end
  end

  @doc """
  DSL for defining assigns in a resource-oriented LiveView.

  ## Example

  ```elixir
  assigns do
    attribute :user_id, :string, required: true
    attribute :name, :string, required: true
    
    # Nested attributes
    attribute :settings, :map do
      attribute :theme, {:one_of, ["light", "dark"]}, default: "dark"
      attribute :notifications, :boolean, default: true
    end
    
    # Relationships
    relationship :team, :belongs_to, MyApp.TeamResource
    relationship :posts, :has_many, MyApp.PostResource
  end
  ```
  """
  defmacro assigns(do: block) do
    quote do
      unquote(block)

      # Auto-generate required_assigns and type_specs from attributes
      def do_mount(params, session, socket) do
        # Set default values for attributes with defaults
        defaults =
          @resource_attributes
          |> Enum.filter(fn attr -> attr.default != nil end)
          |> Enum.map(fn attr -> {attr.name, attr.default} end)
          |> Map.new()

        socket = assign(socket, defaults)

        # Call user-defined mount if it exists
        if function_exported?(__MODULE__, :do_mount, 3) do
          apply(__MODULE__, :do_mount, [params, session, socket])
        else
          {:ok, socket}
        end
      end
    end
  end

  @doc """
  DSL for defining a single attribute in a resource-oriented LiveView.
  """
  defmacro attribute(name, type, opts \\ [], do_block \\ nil) do
    opts = Macro.escape(opts)

    quote bind_quoted: [
            name: name,
            type: type,
            opts: opts,
            do_block: Macro.escape(do_block, unquote: true)
          ] do
      attr_def = %{
        name: name,
        type: type,
        required: Keyword.get(opts, :required, false),
        default: Keyword.get(opts, :default, nil),
        nested_attributes: nil
      }

      # Handle nested attributes if a do block is provided
      if do_block do
        nested_attrs =
          case do_block do
            {:__block__, _, attrs} -> attrs
            attr -> [attr]
          end

        # Process nested attributes (simplified for now)
        attr_def = Map.put(attr_def, :nested_attributes, nested_attrs)
      end

      @resource_attributes attr_def
    end
  end

  @doc """
  DSL for defining a relationship to another resource.
  """
  defmacro relationship(name, type, resource, opts \\ []) do
    opts = Macro.escape(opts)

    quote bind_quoted: [name: name, type: type, resource: resource, opts: opts] do
      relationship_def = %{
        name: name,
        type: type,
        resource: resource,
        foreign_key: Keyword.get(opts, :foreign_key, nil)
      }

      @resource_relationships relationship_def
    end
  end
end
