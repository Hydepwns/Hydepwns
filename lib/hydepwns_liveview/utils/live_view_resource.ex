defmodule HydepwnsLiveview.Utils.LiveViewResource do
  @moduledoc """
  Defines a behavior for resource-oriented LiveViews, inspired by Ash framework's resource patterns.

  LiveViewResource provides a structure for declaring socket assigns as first-class resources with
  attributes, validations, and relationships. This allows for more declarative LiveView development
  and consistent validation throughout the application.

  ## Usage

  ```elixir
  defmodule MyApp.UserResource do
    use HydepwnsLiveview.Utils.LiveViewResource
    
    attributes do
      attribute :id, :string, required: true
      attribute :name, :string, required: true
      attribute :email, :string, format: ~r/@/
      attribute :role, {:one_of, ["admin", "editor", "viewer"]}, default: "viewer"
      attribute :settings, :map do
        attribute :notifications, :boolean, default: true
        attribute :theme, {:one_of, ["light", "dark", "system"]}, default: "system"
      end
    end
    
    relationships do
      has_many :posts, MyApp.PostResource
      belongs_to :team, MyApp.TeamResource
    end
    
    validations do
      validate :email_must_be_valid, fn resource ->
        # Custom validation logic
        if String.contains?(resource.email, "@") do
          :ok
        else
          {:error, "Email must contain @"}
        end
      end
    end
  end
  ```

  ### Using with Data Source Adapters

  You can also define resources that are backed by a data source like an Ecto schema:

  ```elixir
  defmodule MyApp.UserResource do
    use HydepwnsLiveview.Utils.LiveViewResource
    
    # Use the EctoAdapter with the User schema
    adapter HydepwnsLiveview.Utils.EctoAdapter, schema: MyApp.User
  end
  ```
  """

  @doc """
  Defines the behavior required for a LiveViewResource.
  """
  @callback attributes() :: Macro.t()
  @callback relationships() :: Macro.t()
  @callback validations() :: Macro.t()

  @doc """
  Returns the schema for the resource, including all attributes, types, and validations.
  """
  @callback __resource_schema__() :: map()

  defmacro __using__(_opts) do
    quote do
      @behaviour HydepwnsLiveview.Utils.LiveViewResource

      import HydepwnsLiveview.Utils.LiveViewResource

      Module.register_attribute(__MODULE__, :attributes, accumulate: true)
      Module.register_attribute(__MODULE__, :relationships, accumulate: true)
      Module.register_attribute(__MODULE__, :validations, accumulate: true)
      Module.register_attribute(__MODULE__, :adapter_info, accumulate: false)

      @adapter_info nil

      @before_compile HydepwnsLiveview.Utils.LiveViewResource

      @impl true
      def attributes, do: []

      @impl true
      def relationships, do: []

      @impl true
      def validations, do: []

      defoverridable attributes: 0, relationships: 0, validations: 0
    end
  end

  defmacro __before_compile__(env) do
    # Check if an adapter is defined
    _adapter_info = Module.get_attribute(env.module, :adapter_info)

    quote do
      @impl true
      def __resource_schema__ do
        %{
          attributes: @attributes,
          relationships: @relationships,
          validations: @validations,
          adapter_info: @adapter_info
        }
      end

      # Define helper functions for adapter access
      if @adapter_info do
        @adapter_module Keyword.get(@adapter_info, :module)
        @adapter_schema Keyword.get(@adapter_info, :schema)

        def __adapter__ do
          %{
            module: @adapter_module,
            schema: @adapter_schema
          }
        end

        # If no attributes are defined but we have an adapter, use the adapter to extract them
        if length(@attributes) == 0 && function_exported?(@adapter_module, :extract_attributes, 1) do
          def __extract_attributes__ do
            @adapter_module.extract_attributes(@adapter_schema)
          end
        else
          def __extract_attributes__, do: @attributes
        end

        # Define validation function that uses the adapter
        def validate(values) when is_map(values) do
          @adapter_module.validate(@adapter_schema, values)
        end

        # Define load function that uses the adapter
        def load(id) do
          @adapter_module.load(@adapter_schema, id)
        end

        # Define save function that uses the adapter
        def save(values) when is_map(values) do
          @adapter_module.save(@adapter_schema, values)
        end
      else
        def __adapter__, do: nil
        def __extract_attributes__, do: @attributes

        # Define validation function that uses the internal validation logic
        def validate(values) when is_map(values) do
          # Basic validation using the attribute definitions
          # For now, just check required fields
          required_fields =
            Enum.filter(@attributes, fn attr -> attr.required end)
            |> Enum.map(fn attr -> attr.name end)

          # Check if all required fields are present
          missing =
            Enum.filter(required_fields, fn field ->
              is_nil(Map.get(values, field)) && is_nil(Map.get(values, to_string(field)))
            end)

          if length(missing) > 0 do
            missing_fields = Enum.join(missing, ", ")
            {:error, "Missing required fields: #{missing_fields}"}
          else
            {:ok, values}
          end
        end

        # No adapter, so load and save are not implemented
        def load(_id), do: {:error, "No adapter configured for load"}
        def save(_values), do: {:error, "No adapter configured for save"}
      end
    end
  end

  @doc """
  DSL for defining the adapter for a resource.

  This macro allows you to specify a data source adapter for the resource,
  such as an Ecto or Ash adapter, and the schema to use with that adapter.

  ## Example

  ```elixir
  adapter HydepwnsLiveview.Utils.EctoAdapter, schema: MyApp.User
  ```
  """
  defmacro adapter(module, opts \\ []) do
    quote do
      # Store the adapter information
      @adapter_info [module: unquote(module), schema: unquote(Keyword.get(opts, :schema))]
    end
  end

  @doc """
  DSL for defining attributes in a resource.
  """
  defmacro attributes(do: block) do
    quote do
      @impl true
      def attributes do
        import HydepwnsLiveview.Utils.LiveViewResource,
          only: [attribute: 2, attribute: 3, attribute: 4]

        attrs = []
        result = unquote(block)
        Module.put_attribute(__MODULE__, :attributes, Enum.reverse(attrs))
        result
      end
    end
  end

  @doc """
  DSL for defining a single attribute in a resource.
  """
  defmacro attribute(name, type, opts \\ [], do_block \\ nil) do
    opts = Macro.escape(opts)

    quote do
      attr_def = %{
        name: unquote(name),
        type: unquote(type),
        required: Keyword.get(unquote(opts), :required, false),
        default: Keyword.get(unquote(opts), :default, nil),
        format: Keyword.get(unquote(opts), :format, nil),
        nested_attributes: nil
      }

      # Handle nested attributes if a do block is provided
      attr_def =
        if unquote(do_block) do
          nested_block = unquote(Macro.escape(do_block, unquote: true))

          # Process nested attributes
          nested_attrs =
            case nested_block do
              {:__block__, _, attrs} -> attrs
              attr -> [attr]
            end

          # We can't process these here, so we'll just store the block for later processing
          Map.put(attr_def, :nested_block, nested_block)
        else
          attr_def
        end

      @attributes attr_def
      attr_def
    end
  end

  @doc """
  DSL for defining relationships in a resource.
  """
  defmacro relationships(do: block) do
    quote do
      def relationships do
        unquote(block)
      end
    end
  end

  @doc """
  DSL for defining a has_many relationship.
  """
  defmacro has_many(name, resource, opts \\ []) do
    opts = Macro.escape(opts)

    quote bind_quoted: [name: name, resource: resource, opts: opts] do
      relationship_def = %{
        name: name,
        type: :has_many,
        resource: resource,
        foreign_key: Keyword.get(opts, :foreign_key, nil),
        cardinality: :many
      }

      @relationships relationship_def
    end
  end

  @doc """
  DSL for defining a belongs_to relationship.
  """
  defmacro belongs_to(name, resource, opts \\ []) do
    opts = Macro.escape(opts)

    quote bind_quoted: [name: name, resource: resource, opts: opts] do
      relationship_def = %{
        name: name,
        type: :belongs_to,
        resource: resource,
        foreign_key: Keyword.get(opts, :foreign_key, nil),
        cardinality: :one
      }

      @relationships relationship_def
    end
  end

  @doc """
  DSL for defining validations in a resource.
  """
  defmacro validations(do: block) do
    quote do
      def validations do
        unquote(block)
      end
    end
  end

  @doc """
  DSL for defining a custom validation.
  """
  defmacro validate(name, validation_fn) do
    quote bind_quoted: [name: name, validation_fn: Macro.escape(validation_fn)] do
      validation_def = %{
        name: name,
        validation_fn: validation_fn
      }

      @validations validation_def
    end
  end

  @doc """
  Generates a type specification map from a resource definition.
  """
  def generate_type_specs(resource_module) when is_atom(resource_module) do
    schema = resource_module.__resource_schema__()
    adapter_info = Map.get(schema, :adapter_info)

    if adapter_info do
      # Use the adapter to generate type specs
      adapter_module = Keyword.get(adapter_info, :module)
      adapter_schema = Keyword.get(adapter_info, :schema)

      if function_exported?(adapter_module, :generate_type_specs, 1) do
        adapter_module.generate_type_specs(adapter_schema)
      else
        # Fall back to attribute-based type specs
        generate_type_specs_from_attributes(resource_module.__extract_attributes__())
      end
    else
      # Use attribute-based type specs
      generate_type_specs_from_attributes(schema.attributes)
    end
  end

  # Generate type specs from attribute definitions
  defp generate_type_specs_from_attributes(attributes) do
    attributes
    |> Enum.map(fn attr -> {attr.name, attr_to_type_spec(attr)} end)
    |> Map.new()
  end

  # Convert an attribute definition to a type specification for socket validation
  defp attr_to_type_spec(attr) do
    cond do
      # Handle nested attributes for map types
      attr.type == :map && attr.nested_attributes ->
        nested_attrs =
          attr.nested_attributes
          |> Enum.map(fn nested -> {nested.name, attr_to_type_spec(nested)} end)
          |> Map.new()

        nested_attrs

      # Handle basic types
      true ->
        attr.type
    end
  end
end
