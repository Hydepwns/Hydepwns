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
      has_many :team_members, through: [:team, :members]
      polymorphic :commentable, types: [MyApp.PostResource, MyApp.ArticleResource]
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
      
      # Define a validation that depends on another validation
      validate :role_permissions_valid, fn resource ->
        if resource.role == "admin" && Enum.empty?(resource.permissions) do
          {:error, "Admin users must have at least one permission"}
        else
          :ok
        end
      end
      
      # Define that this validation depends on the email_must_be_valid validation
      validation_depends_on :role_permissions_valid, [:email_must_be_valid]
      
      # Define a validation that depends on a related resource validation
      validate_related :team, :max_members_not_exceeded, fn team ->
        if team.max_members && length(team.members) > team.max_members do
          {:error, "Team exceeds maximum member count"}
        else
          :ok
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

  alias HydepwnsLiveview.Utils.ChangeTracker
  alias HydepwnsLiveview.Utils.RelationshipResolver
  alias HydepwnsLiveview.Utils.TransformationPipeline

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

      Module.register_attribute(__MODULE__, :resource_attributes, accumulate: true)
      Module.register_attribute(__MODULE__, :resource_relationships, accumulate: true)
      Module.register_attribute(__MODULE__, :validations, accumulate: true)
      Module.register_attribute(__MODULE__, :validation_dependencies, accumulate: true)
      Module.register_attribute(__MODULE__, :relationship_dependencies, accumulate: true)
      Module.register_attribute(__MODULE__, :transformations, accumulate: true)

      @before_compile HydepwnsLiveview.Utils.LiveViewResource

      @impl true
      def attributes, do: []

      @impl true
      def relationships, do: []

      @impl true
      def validations, do: []

      defoverridable attributes: 0, relationships: 0, validations: 0

      # Add change tracking functions
      def track_change(resource, changes, metadata \\ %{}) do
        HydepwnsLiveview.Utils.ChangeTracker.track_change(
          ensure_resource_module(resource),
          changes,
          metadata
        )
      end

      def get_history(resource, opts \\ []) do
        HydepwnsLiveview.Utils.ChangeTracker.get_history(
          ensure_resource_module(resource),
          opts
        )
      end

      def get_version(resource, version) do
        HydepwnsLiveview.Utils.ChangeTracker.get_version(
          ensure_resource_module(resource),
          version
        )
      end

      def diff_versions(resource, opts \\ []) do
        HydepwnsLiveview.Utils.ChangeTracker.diff(
          ensure_resource_module(resource),
          opts
        )
      end

      def check_concurrent_update(resource, expected_version, changes) do
        HydepwnsLiveview.Utils.ChangeTracker.check_concurrent_update(
          ensure_resource_module(resource),
          expected_version,
          changes
        )
      end

      def serialize_history(resource, opts \\ []) do
        HydepwnsLiveview.Utils.ChangeTracker.serialize_history(
          ensure_resource_module(resource),
          opts
        )
      end

      def deserialize_history(resource, serialized, opts \\ []) do
        HydepwnsLiveview.Utils.ChangeTracker.deserialize_history(
          ensure_resource_module(resource),
          serialized,
          opts
        )
      end

      # Add transformation pipeline functions
      def default_transformation_pipeline do
        # Get registered transformations
        transformations = __MODULE__.__resource_schema__().transformations

        # Create the pipeline with the registered transformations
        HydepwnsLiveview.Utils.LiveViewResource.build_transformation_pipeline(transformations)
        |> Map.put(:name, "#{__MODULE__} Default Pipeline")
      end

      def transform(resource, context \\ %{}) do
        pipeline = default_transformation_pipeline()
        HydepwnsLiveview.Utils.TransformationPipeline.apply(pipeline, resource, context: context)
      end

      def register_transformation(module, opts \\ []) do
        transformation = %{
          module: module,
          opts: opts
        }

        Module.put_attribute(__MODULE__, :transformations, transformation)
      end

      def transform_with_tracking(resource, context \\ %{}, opts \\ []) do
        case transform(resource, context) do
          {:ok, transformed_resource} ->
            tracking_opts =
              Keyword.merge(opts,
                actor: Map.get(context, :actor),
                source: Map.get(context, :source),
                reason: Map.get(context, :reason, "Resource transformation")
              )

            ChangeTracker.track_change(
              transformed_resource,
              # No additional changes needed since transformation already applied
              %{},
              tracking_opts
            )

          error ->
            error
        end
      end

      # Add context-aware validation with deep validation
      def validate_deep(resource, opts \\ []) do
        HydepwnsLiveview.Utils.ContextValidation.validate_deep(
          ensure_resource_module(resource),
          opts
        )
      end

      # Add context-aware validation with specific rules
      def validate_with_rules(resource, rules, opts \\ []) do
        HydepwnsLiveview.Utils.ContextValidation.validate_with_rules(
          ensure_resource_module(resource),
          Keyword.put(opts, :rules, rules)
        )
      end

      # Add validation dependency resolution
      def resolve_validation_dependencies(resource_or_module \\ __MODULE__, opts \\ []) do
        HydepwnsLiveview.Utils.ValidationDependencyResolver.resolve_dependencies(
          resource_or_module,
          opts
        )
      end

      # Add validation plan execution
      def execute_validation_plan(validation_plan, resource, opts \\ []) do
        HydepwnsLiveview.Utils.ValidationDependencyResolver.execute_validation_plan(
          validation_plan,
          resource,
          opts
        )
      end

      # Add transformation with validation
      def transform_and_validate(resource, context \\ %{}, validation_opts \\ []) do
        case transform(resource, context) do
          {:ok, transformed_resource} ->
            validate_deep(transformed_resource, validation_opts)

          error ->
            error
        end
      end
    end
  end

  defmacro __before_compile__(env) do
    # Check if an adapter is defined
    _adapter_info = Module.get_attribute(env.module, :adapter_info)

    quote do
      @impl true
      def __resource_metadata__ do
        %{
          attributes: @resource_attributes,
          relationships: @resource_relationships
        }
      end

      def __resource_schema__ do
        %{
          attributes: @resource_attributes,
          relationships: @resource_relationships,
          validations: @validations,
          validation_dependencies: @validation_dependencies,
          relationship_dependencies: @relationship_dependencies,
          transformations: @transformations
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

      # Define validation rules accessor
      def __validation_rules__ do
        @validations
        |> Enum.map(fn validation -> {validation.name, validation.validation_fn} end)
      end

      # Define validation dependencies accessor
      def __validation_dependencies__(rule_name) do
        @validation_dependencies
        |> Enum.filter(fn {rule, _deps} -> rule == rule_name end)
        |> Enum.flat_map(fn {_rule, deps} -> deps end)
        |> Enum.map(fn dep ->
          if is_tuple(dep), do: dep, else: {__MODULE__, dep}
        end)
      end

      # Define relationship dependencies accessor
      def __relationship_dependencies__(relationship_name) do
        @relationship_dependencies
        |> Enum.filter(fn {rel, _rule, _deps} -> rel == relationship_name end)
        |> Enum.map(fn {_rel, rule, target_rules} -> {rule, target_rules} end)
      end

      # Helper to ensure the resource has a __resource_module__ attribute
      defp ensure_resource_module(resource) do
        if Map.has_key?(resource, :__resource_module__) do
          resource
        else
          Map.put(resource, :__resource_module__, __MODULE__)
        end
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
        if length(@resource_attributes) == 0 &&
             function_exported?(@adapter_module, :extract_attributes, 1) do
          def __extract_attributes__ do
            @adapter_module.extract_attributes(@adapter_schema)
          end
        else
          def __extract_attributes__, do: @resource_attributes
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
        def __extract_attributes__, do: @resource_attributes

        # Define validation function that uses the internal validation logic
        def validate(values) when is_map(values) do
          # Basic validation using the attribute definitions
          # For now, just check required fields
          required_fields =
            Enum.filter(@resource_attributes, fn attr -> attr.required end)
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

      # Add relationship resolution functions
      def resolve_relationship(resource, relationship_name, opts \\ []) do
        HydepwnsLiveview.Utils.RelationshipResolver.resolve_relationship(
          resource,
          relationship_name,
          opts
        )
      end

      def eager_load(resource_or_resources, relationships, opts \\ []) do
        HydepwnsLiveview.Utils.RelationshipResolver.eager_load(
          resource_or_resources,
          relationships,
          opts
        )
      end

      # Add relationship validation functions
      def validate_relationships(resource, opts \\ []) do
        HydepwnsLiveview.Utils.RelationshipValidator.validate_relationships(
          resource,
          opts
        )
      end

      def validate_relationship(
            resource,
            relationship_name,
            check_referential_integrity \\ true,
            deep \\ false
          ) do
        HydepwnsLiveview.Utils.RelationshipValidator.validate_relationship(
          resource,
          relationship_name,
          check_referential_integrity,
          deep
        )
      end

      def validate_delete(resource, opts \\ []) do
        HydepwnsLiveview.Utils.RelationshipValidator.validate_delete(
          resource,
          opts
        )
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

        # Use a temporary variable to accumulate attributes
        # instead of trying to set a module attribute inside a function
        unquote(block)

        # Return the accumulated attributes from the module attribute
        # which was set during compilation
        @resource_attributes
      end
    end
  end

  @doc """
  DSL for defining a single attribute in a resource.
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
        format: Keyword.get(opts, :format, nil),
        nested_attributes: nil
      }

      # Handle nested attributes if a do block is provided
      attr_def =
        if do_block do
          # Process nested attributes
          nested_attrs =
            case do_block do
              {:__block__, _, attrs} -> attrs
              attr -> [attr]
            end

          # We can't process these here, so we'll just store the block for later processing
          Map.put(attr_def, :nested_block, do_block)
        else
          attr_def
        end

      # Accumulate the attribute at compile time
      Module.put_attribute(__MODULE__, :resource_attributes, attr_def)
      attr_def
    end
  end

  @doc """
  DSL for defining relationships in a resource.
  """
  defmacro relationships(do: block) do
    quote do
      @impl true
      def relationships do
        # Define the relationship functions
        has_many = fn name, resource ->
          relationship_def = %{
            name: name,
            type: :has_many,
            resource: resource,
            foreign_key: nil,
            cardinality: :many
          }

          Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
        end

        has_many_with_opts = fn name, resource, opts ->
          relationship_def = %{
            name: name,
            type: :has_many,
            resource: resource,
            foreign_key: Keyword.get(opts, :foreign_key, nil),
            cardinality: :many
          }

          Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
        end

        belongs_to = fn name, resource ->
          relationship_def = %{
            name: name,
            type: :belongs_to,
            resource: resource,
            foreign_key: nil,
            cardinality: :one
          }

          Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
        end

        belongs_to_with_opts = fn name, resource, opts ->
          relationship_def = %{
            name: name,
            type: :belongs_to,
            resource: resource,
            foreign_key: Keyword.get(opts, :foreign_key, nil),
            cardinality: :one
          }

          Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
        end

        has_one = fn name, resource ->
          relationship_def = %{
            name: name,
            type: :has_one,
            resource: resource,
            foreign_key: nil,
            cardinality: :one
          }

          Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
        end

        has_one_with_opts = fn name, resource, opts ->
          relationship_def = %{
            name: name,
            type: :has_one,
            resource: resource,
            foreign_key: Keyword.get(opts, :foreign_key, nil),
            cardinality: :one
          }

          Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
        end

        has_many_through = fn name, opts ->
          case opts do
            [through: [through_rel, target_rel]] ->
              relationship_def = %{
                name: name,
                type: :through,
                through: through_rel,
                target: target_rel,
                cardinality: :many,
                foreign_key: nil
              }
              Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
            _ ->
              raise ArgumentError, "has_many_through expects opts: [through: [rel1, rel2]]"
          end
        end

        has_many_through_with_opts = fn name, opts, through_opts ->
          case opts do
            [through: [through_rel, target_rel]] ->
              relationship_def = %{
                name: name,
                type: :through,
                through: through_rel,
                target: target_rel,
                cardinality: :many,
                foreign_key: Keyword.get(through_opts, :foreign_key, nil)
              }
              Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
            _ ->
              raise ArgumentError, "has_many_through_with_opts expects opts: [through: [rel1, rel2]]"
          end
        end

        has_one_through = fn name, opts ->
          case opts do
            [through: [through_rel, target_rel]] ->
              relationship_def = %{
                name: name,
                type: :through,
                through: through_rel,
                target: target_rel,
                cardinality: :one,
                foreign_key: nil
              }
              Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
            _ ->
              raise ArgumentError, "has_one_through expects opts: [through: [rel1, rel2]]"
          end
        end

        has_one_through_with_opts = fn name, opts, through_opts ->
          case opts do
            [through: [through_rel, target_rel]] ->
              relationship_def = %{
                name: name,
                type: :through,
                through: through_rel,
                target: target_rel,
                cardinality: :one,
                foreign_key: Keyword.get(through_opts, :foreign_key, nil)
              }
              Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
            _ ->
              raise ArgumentError, "has_one_through_with_opts expects opts: [through: [rel1, rel2]]"
          end
        end

        polymorphic = fn name, opts ->
          case opts do
            [types: allowed_types] ->
              relationship_def = %{
                name: name,
                type: :polymorphic,
                polymorphic_name: name,
                allowed_types: allowed_types,
                cardinality: :one
              }
              Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
            _ ->
              raise ArgumentError, "polymorphic expects opts: [types: allowed_types]"
          end
        end

        polymorphic_with_opts = fn name, opts, poly_opts ->
          case opts do
            [types: allowed_types] ->
              polymorphic_name = Keyword.get(poly_opts, :polymorphic_name, name)
              relationship_def = %{
                name: name,
                type: :polymorphic,
                polymorphic_name: polymorphic_name,
                allowed_types: allowed_types,
                cardinality: Keyword.get(poly_opts, :cardinality, :one)
              }
              Module.put_attribute(__MODULE__, :resource_relationships, relationship_def)
            _ ->
              raise ArgumentError, "polymorphic_with_opts expects opts: [types: allowed_types]"
          end
        end

        # Execute the block with the relationship functions in scope
        require Logger

        # Define the functions in the current scope
        has_many = has_many
        has_many_with_opts = has_many_with_opts
        belongs_to = belongs_to
        belongs_to_with_opts = belongs_to_with_opts
        has_one = has_one
        has_one_with_opts = has_one_with_opts
        has_many_through = has_many_through
        has_many_through_with_opts = has_many_through_with_opts
        has_one_through = has_one_through
        has_one_through_with_opts = has_one_through_with_opts
        polymorphic = polymorphic
        polymorphic_with_opts = polymorphic_with_opts

        # Import the functions into the current scope
        import Kernel, except: []

        unquote(block)

        # Return the accumulated relationships from the module attribute
        @resource_relationships
      end
    end
  end

  @doc """
  DSL for defining validations in a resource.
  """
  defmacro validations(do: block) do
    quote do
      @impl true
      def validations do
        import HydepwnsLiveview.Utils.LiveViewResource,
          only: [
            validate: 2,
            validation_depends_on: 2,
            validate_related: 3
          ]

        # Execute the block to define validations
        unquote(block)

        # Return the accumulated validations from the module attribute
        @validations
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

      # Accumulate the validation at compile time
      Module.put_attribute(__MODULE__, :validations, validation_def)
    end
  end

  @doc """
  DSL for defining validation dependencies.

  This macro allows you to specify that a validation depends on other validations,
  either in the same resource or in related resources. The dependency information
  is used to determine the order in which validations should be executed.

  ## Example

  ```elixir
  # Simple dependencies within the same resource
  validation_depends_on :role_permissions_valid, [:email_must_be_valid]

  # Dependencies on validations in related resources
  validation_depends_on :team_role_valid, [{TeamResource, :role_valid}]
  ```
  """
  defmacro validation_depends_on(rule_name, dependencies) do
    quote bind_quoted: [rule_name: rule_name, dependencies: dependencies] do
      # Accumulate the validation dependency at compile time
      Module.put_attribute(__MODULE__, :validation_dependencies, {rule_name, dependencies})
    end
  end

  @doc """
  DSL for defining a validation on a related resource.

  This macro allows you to specify a validation that should be applied to a 
  related resource. The validation will only be executed if the relationship
  exists.

  ## Example

  ```elixir
  # Define a validation for a related resource
  validate_related :team, :team_name_valid, fn team ->
    if String.length(team.name) > 3 do
      :ok
    else
      {:error, "Team name must be at least 3 characters"}
    end
  end
  ```
  """
  defmacro validate_related(relationship_name, rule_name, rule_fn) do
    quote bind_quoted: [
            relationship_name: relationship_name,
            rule_name: rule_name,
            rule_fn: Macro.escape(rule_fn)
          ] do
      # Define the validation function that will be called on this resource
      validate(rule_name, fn resource, context ->
        # Check if the relationship exists
        case HydepwnsLiveview.Utils.RelationshipResolver.resolve_relationship(
               resource,
               relationship_name
             ) do
          {:ok, nil} ->
            # Relationship doesn't exist, validation passes
            :ok

          {:ok, related} ->
            # Relationship exists, apply the validation function
            rule_fn.(related)

          {:error, _reason} ->
            # Error resolving relationship, validation passes
            :ok
        end
      end)

      # Register the relationship validation for dependency resolution
      Module.put_attribute(
        __MODULE__,
        :relationship_dependencies,
        {relationship_name, rule_name, []}
      )
    end
  end

  @doc """
  DSL for registering a transformation module with this resource.

  This macro allows you to specify a transformation that should be
  included in the default transformation pipeline for this resource.

  ## Example

  ```elixir
  # Register a transformation
  transformation MyApp.Transformations.NormalizeEmail

  # Register with options
  transformation MyApp.Transformations.NormalizeEmail,
    hook: :pre_validation,
    condition: fn resource, _context -> resource.email != nil end
  ```
  """
  defmacro transformation(module, opts \\ []) do
    quote bind_quoted: [module: module, opts: opts] do
      register_transformation(module, opts)
    end
  end

  @doc """
  Builds a transformation pipeline based on the registered transformations.

  This function is used by the default_transformation_pipeline/0 function
  to create a pipeline that includes all registered transformations.
  """
  def build_transformation_pipeline(transformations) do
    pipeline = HydepwnsLiveview.Utils.TransformationPipeline.new()

    Enum.reduce(transformations, pipeline, fn transformation, acc ->
      HydepwnsLiveview.Utils.TransformationPipeline.add(
        acc,
        transformation.module,
        transformation.opts
      )
    end)
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

  # Helper for ensuring a resource has a module reference
  defp ensure_resource_module(resource) when is_map(resource) do
    if Map.has_key?(resource, :__resource_module__) do
      resource
    else
      Map.put(resource, :__resource_module__, __MODULE__)
    end
  end

  defp ensure_resource_module(module) when is_atom(module) do
    %{__resource_module__: module}
  end
end
