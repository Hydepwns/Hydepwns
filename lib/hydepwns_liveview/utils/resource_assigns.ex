defmodule HydepwnsLiveview.Utils.ResourceAssigns do
  @moduledoc """
  Implements an Ash-inspired resource architecture for LiveView socket assigns.

  This module provides a DSL for declaratively defining socket assigns as first-class resources
  with attributes, relationships, and validations.

  ## Features

  - Declarative assign specifications using DSL
  - Resource-oriented socket assigns
  - API-based access patterns for LiveView resources
  - Bidirectional integration with Ash resources (when available)

  ## Usage

  ```elixir
  defmodule MyAppWeb.UserLive do
    use HydepwnsLiveviewWeb.Resources.ResourceLive
    
    assigns_resource do
      attributes do
        attribute :user_id, :string, required: true
        attribute :username, :string, required: true
        attribute :role, {:one_of, ["admin", "user", "guest"]}, default: "user"
        
        # Nested attributes using map schema
        attribute :settings, :map do
          attribute :theme, {:one_of, ["dark", "light", "system"]}, default: "system"
          attribute :notifications, :boolean, default: true
        end
        
        # List attributes with validation
        attribute :permissions, {:list, :string}, default: []
      end
      
      relationships do
        # Define relationships to other socket resources
        # (Implementation pending)
      end
      
      validations do
        # Custom validations beyond type validation
        # (Implementation pending)
      end
    end
    
    # Your LiveView implementation...
  end
  ```
  """

  @doc """
  Defines a resource for LiveView assigns.

  This macro is the entry point for the DSL, allowing developers to define
  attributes, relationships, and validations for LiveView socket assigns.
  """
  defmacro assigns_resource(do: block) do
    quote do
      Module.register_attribute(__MODULE__, :resource_attributes, accumulate: true)
      Module.register_attribute(__MODULE__, :resource_relationships, accumulate: true)
      Module.register_attribute(__MODULE__, :resource_validations, accumulate: true)

      import HydepwnsLiveview.Utils.ResourceAssigns,
        only: [attributes: 1, relationships: 1, validations: 1]

      unquote(block)

      # Generate the required assigns and type specs based on the resource definition
      @before_compile HydepwnsLiveview.Utils.ResourceAssigns
    end
  end

  @doc """
  Defines attributes for the socket assigns resource.
  """
  defmacro attributes(do: block) do
    quote do
      import HydepwnsLiveview.Utils.ResourceAssigns,
        only: [attribute: 2, attribute: 3, attribute: 4]

      unquote(block)
    end
  end

  @doc """
  Defines relationships for the socket assigns resource.
  """
  defmacro relationships(do: block) do
    quote do
      import HydepwnsLiveview.Utils.ResourceAssigns, only: [relationship: 3, relationship: 4]
      unquote(block)
    end
  end

  @doc """
  Defines validations for the socket assigns resource.
  """
  defmacro validations(do: block) do
    quote do
      import HydepwnsLiveview.Utils.ResourceAssigns, only: [validation: 2, validation: 3]
      unquote(block)
    end
  end

  @doc """
  Defines an attribute for the socket assigns resource.
  """
  defmacro attribute(name, type, opts \\ []) do
    quote do
      @resource_attributes {unquote(name), unquote(type), unquote(opts)}
    end
  end

  @doc """
  Defines a nested attribute with a block for nested attributes.
  """
  defmacro attribute(name, type, opts, do: block) when type == :map do
    quote do
      # Start a new nested context for attributes
      Module.register_attribute(__MODULE__, :nested_attributes, accumulate: true)

      # Import the attribute macro in this context
      import HydepwnsLiveview.Utils.ResourceAssigns, only: [attribute: 2, attribute: 3]

      # Process the nested attributes block
      unquote(block)

      # Collect the nested attributes
      nested_attrs = @nested_attributes
      Module.delete_attribute(__MODULE__, :nested_attributes)

      # Create a map schema from the nested attributes
      nested_schema =
        Enum.reduce(nested_attrs, %{}, fn {attr_name, attr_type, attr_opts}, acc ->
          Map.put(acc, attr_name, build_type_spec(attr_type, attr_opts))
        end)

      # Register the complete nested attribute
      @resource_attributes {unquote(name), nested_schema, unquote(opts)}
    end
  end

  @doc """
  Defines a relationship for the socket assigns resource.
  """
  defmacro relationship(name, type, target, opts \\ []) do
    quote do
      @resource_relationships {unquote(name), unquote(type), unquote(target), unquote(opts)}
    end
  end

  @doc """
  Defines a validation for the socket assigns resource.
  """
  defmacro validation(name, validation_fn, opts \\ []) do
    quote do
      @resource_validations {unquote(name), unquote(validation_fn), unquote(opts)}
    end
  end

  @doc """
  Builds a type specification based on attribute type and options.
  """
  def build_type_spec(type, opts) do
    # If the attribute is optional, wrap the type in an optional spec
    if Keyword.get(opts, :optional, false) do
      {:optional, type}
    else
      type
    end
  end

  @doc """
  Before compile hook to process resource definitions and generate required code.
  """
  defmacro __before_compile__(env) do
    # Collect all the resource definitions
    attributes = Module.get_attribute(env.module, :resource_attributes) || []
    relationships = Module.get_attribute(env.module, :resource_relationships) || []
    validations = Module.get_attribute(env.module, :resource_validations) || []

    # Build the required_assigns list
    required_assigns =
      attributes
      |> Enum.filter(fn {_name, _type, opts} ->
        !Keyword.get(opts, :optional, false) && !Keyword.has_key?(opts, :default)
      end)
      |> Enum.map(fn {name, _type, _opts} -> name end)

    # Build the type_specs map
    type_specs =
      attributes
      |> Enum.map(fn {name, type, opts} ->
        {name, build_type_spec(type, opts)}
      end)
      |> Enum.into(%{})

    # Generate default values map
    default_values =
      attributes
      |> Enum.filter(fn {_name, _type, opts} -> Keyword.has_key?(opts, :default) end)
      |> Enum.map(fn {name, _type, opts} -> {name, Keyword.get(opts, :default)} end)
      |> Enum.into(%{})

    # Generate the __apply_resource_defaults__/1 function
    apply_defaults_function =
      quote do
        def __apply_resource_defaults__(socket) do
          defaults = unquote(Macro.escape(default_values))
          Phoenix.Component.assign(socket, defaults)
        end
      end

    # Generate accessor functions for each attribute
    accessors =
      Enum.map(attributes, fn {name, _type, opts} ->
        quote do
          def unquote(name)(socket) do
            HydepwnsLiveview.Utils.SocketValidator.get_assign(
              socket,
              unquote(name),
              unquote(Keyword.get(opts, :default))
            )
          end

          def unquote(:"put_#{name}")(socket, value) do
            Phoenix.Component.assign(socket, unquote(name), value)
          end
        end
      end)

    # Generate initialization function to set default values
    init_function =
      quote do
        def init_resource_assigns(socket) do
          defaults = unquote(Macro.escape(default_values))
          Phoenix.Component.assign(socket, defaults)
        end
      end

    # Combine everything and generate the code
    quote do
      use HydepwnsLiveviewWeb.Resources.ResourceLive,
        required_assigns: unquote(required_assigns),
        type_specs: unquote(Macro.escape(type_specs))

      # Generate accessor functions
      unquote(accessors)

      # Generate initialization function
      unquote(init_function)

      # Generate apply defaults function
      unquote(apply_defaults_function)

      # Override do_mount to include default values
      def do_mount(params, session, socket) do
        socket = init_resource_assigns(socket)

        # Call the original do_mount implementation if defined
        super(params, session, socket)
      end

      # Metadata about the resource
      def __resource_metadata__() do
        %{
          attributes: unquote(Macro.escape(attributes)),
          relationships: unquote(Macro.escape(relationships)),
          validations: unquote(Macro.escape(validations)),
          required_assigns: unquote(required_assigns),
          type_specs: unquote(Macro.escape(type_specs)),
          default_values: unquote(Macro.escape(default_values))
        }
      end
    end
  end
end
