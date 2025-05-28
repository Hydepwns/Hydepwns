defmodule HydepwnsLiveview.Utils.TransformationPipeline do
  @moduledoc """
  Resource Transformation Pipeline for applying transformations to resources.

  This module provides a comprehensive system for defining and applying transformations
  to resources. Transformations are composable, configurable operations that can be
  applied to resources at various hook points during their lifecycle.

  ## Features

  - **Composable Transformation Pipeline**: Chain transformations together in a pipeline
  - **Transformation Registry**: Discover and register transformations dynamically
  - **Transformation Context**: Share data and state between transformations
  - **Hook Points**: Apply transformations at specific points (pre/post validation)
  - **Conditional Transformations**: Apply transformations based on conditions
  - **Performance Monitoring**: Track transformation execution time and metrics

  ## Example Usage

  ```elixir
  # Define a simple transformation
  defmodule MyApp.Transformations.NormalizeEmail do
    use HydepwnsLiveview.Utils.Transformation

    def transform(resource, _context) do
      # Normalize email to lowercase
      email = String.downcase(resource.email)
      
      # Return the transformed resource
      {:ok, %{resource | email: email}}
    end
  end

  # Create a transformation pipeline
  pipeline = TransformationPipeline.new()
    |> TransformationPipeline.add(:normalize_email, MyApp.Transformations.NormalizeEmail)
    |> TransformationPipeline.add(:validate_email, fn resource, _context ->
      if String.contains?(resource.email, "@") do
        {:ok, resource}
      else
        {:error, "Invalid email format"}
      end
    end)

  # Apply the pipeline to a resource
  case TransformationPipeline.apply(pipeline, user) do
    {:ok, transformed_user} ->
      # Handle success
      
    {:error, reason} ->
      # Handle error
  end
  ```
  """

  alias HydepwnsLiveview.Utils.TransformationMetrics

  @doc """
  Creates a new transformation pipeline.

  ## Options

  - `:name` - Optional name for the pipeline
  - `:description` - Optional description of the pipeline's purpose
  - `:context` - Initial context for the pipeline

  ## Examples

  ```elixir
  # Create a basic pipeline
  pipeline = TransformationPipeline.new()

  # Create a pipeline with a name and description
  pipeline = TransformationPipeline.new(
    name: "User Normalization Pipeline",
    description: "Normalizes user data for storage"
  )

  # Create a pipeline with initial context
  pipeline = TransformationPipeline.new(
    context: %{
      current_user: user,
      timestamp: DateTime.utc_now()
    }
  )
  ```

  ## Returns

  A new transformation pipeline struct
  """
  def new(opts \\ []) do
    name = Keyword.get(opts, :name)
    description = Keyword.get(opts, :description)
    context = Keyword.get(opts, :context, %{})

    %{
      name: name,
      description: description,
      steps: [],
      context: context,
      hooks: %{
        pre_validation: [],
        post_validation: []
      },
      metrics: %{
        execution_times: %{}
      }
    }
  end

  @doc """
  Adds a transformation step to the pipeline.

  ## Options

  - `:name` - Optional name for the transformation step (required if transformation is a function)
  - `:hook` - Hook point to apply the transformation at (`:pre_validation` or `:post_validation`)
  - `:condition` - Function that determines whether to apply the transformation
  - `:id` - Unique identifier for the step (defaults to a generated UUID)

  ## Examples

  ```elixir
  # Add a transformation module
  pipeline = 
    pipeline
    |> TransformationPipeline.add(MyApp.Transformations.NormalizeEmail)

  # Add a transformation module with options
  pipeline = 
    pipeline
    |> TransformationPipeline.add(
      MyApp.Transformations.NormalizeEmail,
      hook: :pre_validation,
      condition: fn resource, _context -> resource.email != nil end
    )

  # Add a transformation function
  pipeline = 
    pipeline
    |> TransformationPipeline.add(
      :normalize_email,
      fn resource, _context ->
        {:ok, %{resource | email: String.downcase(resource.email)}}
      end
    )
  ```

  ## Returns

  Updated pipeline with the new transformation step
  """
  def add(pipeline, transformation, opts \\ []) when is_map(pipeline) do
    hook = Keyword.get(opts, :hook, :pre_validation)
    condition = Keyword.get(opts, :condition)
    id = Keyword.get(opts, :id, UUID.uuid4())

    {name, transformation_fn} =
      cond do
        is_atom(transformation) and not is_nil(Atom.to_string(transformation)) and
            Code.ensure_loaded?(transformation) ->
          # It's a module
          {transformation, &transformation.transform/2}

        is_function(transformation, 2) ->
          # It's a function with name specified as the first argument
          if is_atom(opts[:name]) do
            {opts[:name], transformation}
          else
            raise ArgumentError,
                  "When adding a function transformation, a name must be provided via the :name option"
          end

        is_atom(transformation) and is_function(opts[:function], 2) ->
          # First arg is the name, function is in the options
          {transformation, opts[:function]}

        true ->
          raise ArgumentError,
                "Invalid transformation: #{inspect(transformation)}. Expected a module or a function."
      end

    step = %{
      id: id,
      name: name,
      transformation: transformation_fn,
      condition: condition,
      hook: hook
    }

    # Add the step to the appropriate hook
    hooks = Map.update!(pipeline.hooks, hook, fn steps -> steps ++ [step] end)

    # Update the pipeline
    %{pipeline | hooks: hooks}
  end

  @doc """
  Applies the transformation pipeline to a resource.

  ## Options

  - `:context` - Additional context to merge with the pipeline's context
  - `:only_hooks` - Only apply transformations at specific hooks (list of hook names)
  - `:skip_hooks` - Skip transformations at specific hooks (list of hook names)
  - `:collect_metrics` - Whether to collect performance metrics (default: true)

  ## Examples

  ```elixir
  # Apply the pipeline to a resource
  case TransformationPipeline.apply(pipeline, resource) do
    {:ok, transformed_resource} ->
      # Handle success
      
    {:error, reason} ->
      # Handle error
  end

  # Apply with additional context
  TransformationPipeline.apply(pipeline, resource, 
    context: %{current_user: user}
  )

  # Only apply pre-validation transformations
  TransformationPipeline.apply(pipeline, resource, 
    only_hooks: [:pre_validation]
  )

  # Skip post-validation transformations
  TransformationPipeline.apply(pipeline, resource, 
    skip_hooks: [:post_validation]
  )
  ```

  ## Returns

  - `{:ok, transformed_resource}` - Successfully transformed resource
  - `{:error, reason}` - Failed to transform resource
  """
  def apply(pipeline, resource, opts \\ []) do
    context = Map.merge(pipeline.context, Keyword.get(opts, :context, %{}))
    only_hooks = Keyword.get(opts, :only_hooks)
    skip_hooks = Keyword.get(opts, :skip_hooks, [])
    collect_metrics = Keyword.get(opts, :collect_metrics, true)

    # Determine which hooks to apply
    hooks_to_apply =
      if only_hooks do
        # Only apply specified hooks
        only_hooks
      else
        # Apply all hooks except those in skip_hooks
        Map.keys(pipeline.hooks) -- skip_hooks
      end

    # Initialize state
    state = %{
      resource: resource,
      context: context,
      metrics: %{},
      errors: []
    }

    # Apply transformations at each hook
    Enum.reduce_while(hooks_to_apply, {:ok, state}, fn hook, {:ok, current_state} ->
      # Get transformations for this hook
      transformations = Map.get(pipeline.hooks, hook, [])

      # Apply transformations
      case apply_hook(transformations, current_state, collect_metrics) do
        {:ok, updated_state} ->
          {:cont, {:ok, updated_state}}

        {:error, error_state} ->
          {:halt, {:error, error_state}}
      end
    end)
    |> case do
      {:ok, final_state} ->
        # Extract the transformed resource
        {:ok, final_state.resource}

      {:error, error_state} ->
        # Extract the error
        {:error,
         %{
           message: "Transformation pipeline failed",
           errors: error_state.errors,
           last_resource: error_state.resource
         }}
    end
  end

  @doc """
  Visualizes the transformation pipeline.

  This function creates a string representation of the pipeline
  that can be used for debugging or documentation.

  ## Options

  - `:format` - Output format, either `:text` or `:dot` (default: `:text`)

  ## Examples

  ```elixir
  # Get a text visualization of the pipeline
  IO.puts TransformationPipeline.visualize(pipeline)

  # Get a GraphViz DOT representation for visualization tools
  dot = TransformationPipeline.visualize(pipeline, format: :dot)
  File.write!("pipeline.dot", dot)
  ```

  ## Returns

  String representation of the pipeline
  """
  def visualize(pipeline, opts \\ []) do
    format = Keyword.get(opts, :format, :text)

    case format do
      :text ->
        visualize_as_text(pipeline)

      :dot ->
        visualize_as_dot(pipeline)

      _ ->
        raise ArgumentError, "Unsupported format: #{inspect(format)}"
    end
  end

  # Apply transformations at a specific hook
  defp apply_hook(transformations, state, collect_metrics) do
    # Apply each transformation in sequence
    Enum.reduce_while(transformations, {:ok, state}, fn step, {:ok, current_state} ->
      # Check if the transformation should be applied
      if should_apply_transformation?(step, current_state) do
        # Apply the transformation with metrics collection if enabled
        if collect_metrics do
          # Use TransformationMetrics to track the transformation execution
          transformation_module = get_transformation_module(step)

          {result, metrics} =
            TransformationMetrics.track(
              transformation_module,
              fn -> apply_transformation(step, current_state) end,
              current_state.resource,
              metadata: %{
                pipeline_name: state.pipeline_name,
                hook: step.hook,
                step_name: step.name
              }
            )

          # Process the result
          case result do
            {:ok, new_resource} ->
              # Store execution time in the pipeline metrics for backward compatibility
              pipeline_metrics =
                Map.put(current_state.metrics, step.name, metrics.execution_time_ms / 1000)

              updated_state = %{
                current_state
                | resource: new_resource,
                  metrics: pipeline_metrics
              }

              {:cont, {:ok, updated_state}}

            {:error, reason} ->
              # Store execution time in the pipeline metrics for backward compatibility
              pipeline_metrics =
                Map.put(current_state.metrics, step.name, metrics.execution_time_ms / 1000)

              error_state = %{
                current_state
                | errors: [%{step: step.name, reason: reason} | current_state.errors],
                  metrics: pipeline_metrics
              }

              {:halt, {:error, error_state}}
          end
        else
          # Apply without metrics
          case apply_transformation(step, current_state) do
            {:ok, new_resource} ->
              updated_state = %{current_state | resource: new_resource}
              {:cont, {:ok, updated_state}}

            {:error, reason} ->
              error_state = %{
                current_state
                | errors: [%{step: step.name, reason: reason} | current_state.errors]
              }

              {:halt, {:error, error_state}}
          end
        end
      else
        # Skip this transformation
        {:cont, {:ok, current_state}}
      end
    end)
  end

  # Get the transformation module from a step
  defp get_transformation_module(step) do
    cond do
      is_atom(step.transformation) and not is_nil(step.transformation) and
          not is_function(step.transformation) ->
        # If the transformation is a module, return it
        step.transformation

      is_function(step.transformation) and is_atom(step.name) ->
        # If the transformation is a function but has a name, create a dynamic module name
        # This is just for metrics tracking purposes
        Module.concat(["HydepwnsLiveview.DynamicTransformations", to_string(step.name)])

      true ->
        # Fallback to a generic module name
        HydepwnsLiveview.Utils.TransformationPipeline.AnonymousTransformation
    end
  end

  # Check if a transformation should be applied
  defp should_apply_transformation?(step, state) do
    # If there's no condition, always apply
    if is_nil(step.condition) do
      true
    else
      # Check the condition
      step.condition.(state.resource, state.context)
    end
  end

  # Apply a transformation
  defp apply_transformation(step, state) do
    # Apply the transformation
    case step.transformation.(state.resource, state.context) do
      {:ok, transformed_resource} ->
        {:ok, transformed_resource}

      {:error, reason} ->
        {:error, reason}

      other ->
        # Handle unexpected return values
        {:error, "Transformation returned unexpected value: #{inspect(other)}"}
    end
  end

  # Visualize the pipeline as text
  defp visualize_as_text(pipeline) do
    # Start with the pipeline name and description
    header =
      if pipeline.name do
        name_str = "Pipeline: #{pipeline.name}"

        desc_str =
          if pipeline.description do
            "\nDescription: #{pipeline.description}"
          else
            ""
          end

        name_str <> desc_str <> "\n"
      else
        "Unnamed Pipeline\n"
      end

    # Format each hook
    hooks_text =
      Enum.map(pipeline.hooks, fn {hook_name, steps} ->
        hook_header = "Hook: #{hook_name}\n"

        # Format each step in the hook
        steps_text =
          Enum.map_join(steps, "\n", fn step ->
            condition_text =
              if step.condition do
                " (conditional)"
              else
                ""
              end

            "  - #{step.name}#{condition_text}"
          end)

        hook_header <> steps_text
      end)
      |> Enum.join("\n\n")

    # Combine header and hooks text
    header <> "\n" <> hooks_text
  end

  # Visualize the pipeline as GraphViz DOT
  defp visualize_as_dot(pipeline) do
    nodes =
      Enum.map_join("\n", pipeline.hooks, fn {hook_name, steps} ->
        step_nodes =
          Enum.map_join("\n", steps, fn step ->
            "  \"#{hook_name}_#{step.name}\" [label=\"#{step.name}\"];"
          end)

        "subgraph cluster_#{hook_name} {\n    label = \"#{hook_name}\";\n#{step_nodes}\n  }"
      end)

    edges =
      Enum.flat_map(pipeline.hooks, fn {hook_name, steps} ->
        # Create edges between steps within the same hook
        intra_hook_edges =
          if length(steps) > 1 do
            Enum.zip(steps, tl(steps))
            |> Enum.map_join("\n", fn {step1, step2} ->
              "  \"#{hook_name}_#{step1.name}\" -> \"#{hook_name}_#{step2.name}\";"
            end)
          else
            ""
          end

        # Create edges between the last step of one hook and the first of the next (if applicable)
        # This requires knowing the order of hooks, which is implicit here (pre_validation then post_validation)
        # A more robust solution would define explicit hook order.
        inter_hook_edges = ""

        [intra_hook_edges, inter_hook_edges]
      end)
      |> Enum.reject(&(&1 == ""))
      |> Enum.join("\n")

    "digraph TransformationPipeline {\n  rankdir=LR;\n  node [shape=box];\n#{nodes}\n#{edges}\n}"
  end
end
