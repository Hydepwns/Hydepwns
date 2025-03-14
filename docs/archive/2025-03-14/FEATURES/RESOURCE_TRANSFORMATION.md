---
title: Resource Transformation Pipeline
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - features
  - resource-transformation-pipeline
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - key-features
  - architecture
  - usage-examples
  - create-a-new-pipeline
  - add-transformations-to-the-pipeline
  - applying-a-pipeline
  - apply-the-pipeline-to-a-resource
  - apply-with-additional-context
  - using-the-registry
  - register-a-transformation
  - register-with-categories
  - discover-transformations-in-a-module
  - get-transformations-by-category
  - create-a-pipeline-with-all-email-transformations
  - visualizing-pipelines
  - get-a-text-visualization-of-the-pipeline
  - output-
  - pipeline-user-processing-pipeline
  - description-processes-user-data-for-storage
  - '-hook-pre-validation'
  - '-myapp-transformations-normalizeemail'
  - '-validate-email'
  - '-hook-post-validation'
  - '-myapp-transformations-generateusername'
  - generate-a-graphviz-dot-representation-for-visualization-tools
  - integration-with-liveviewresource
  - usage-in-liveview
  - performance-considerations
  - apply-pipeline-with-metrics-collection
  - get-execution-metrics
  - log-slow-transformations
  - best-practices
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Resource Transformation Pipeline

> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

# Resource Transformation Pipeline


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

The Resource Transformation Pipeline provides a flexible, composable system for applying transformations to resources. Transformations are self-contained, stateless operations that can modify resources according to specific business rules. The pipeline system allows these transformations to be organized, discovered, and executed in a controlled manner.

## Key Features

- **Composable Transformation Pipeline**: Chain transformations together in a pipeline
- **Transformation Registry**: Discover and register transformations dynamically
- **Transformation Context**: Share data and state between transformations
- **Hook Points**: Apply transformations at specific points (pre/post validation)
- **Conditional Transformations**: Apply transformations based on conditions
- **Performance Monitoring**: Track transformation execution time and metrics
- **Visualization Tools**: Visualize transformation pipelines for debugging and documentation

## Architecture

The Resource Transformation Pipeline system consists of three main components:

1. **TransformationPipeline**: Core pipeline for composing and executing transformations
2. **Transformation**: Base module for creating transformations
3. **TransformationRegistry**: Registry for discovering and managing transformations

### TransformationPipeline

The `TransformationPipeline` is the central component that manages the execution of transformations. It provides:

- Creation of pipelines with named steps
- Addition of transformations to the pipeline
- Execution of the pipeline against resources
- Hook points for applying transformations at specific stages
- Performance monitoring for transformation execution
- Visualization of the pipeline structure

### Transformation

The `Transformation` module provides a consistent interface for creating transformations. It defines:

- A behavior specification for transformations
- Default implementations for common functionality
- Metadata about transformations
- Conditional application logic

### TransformationRegistry

The `TransformationRegistry` provides discovery and management of transformations. It supports:

- Registration of transformations at runtime
- Auto-discovery of transformations in specified modules
- Categorization of transformations by purpose
- Metadata storage and retrieval
- Listing and filtering of available transformations

## Usage Examples

### Creating a Transformation

```elixir
defmodule MyApp.Transformations.NormalizeEmail do
  use HydepwnsLiveview.Utils.Transformation
  
  @impl true
  def transform(resource, _context) do
    # Normalize email to lowercase
    email = String.downcase(resource.email)
    
    # Return the transformed resource
    {:ok, %{resource | email: email}}
  end
  
  @impl true
  def info do
    %{
      name: "Normalize Email",
      description: "Converts email addresses to lowercase for consistency",
      version: "1.0",
      categories: [:email, :normalization],
      metadata: %{
        author: "John Doe",
        priority: :high
      }
    }
  end
  
  @impl true
  def applicable?(resource, _context) do
    # Only apply to resources with an email field that is not nil
    Map.has_key?(resource, :email) and not is_nil(resource.email)
  end
end
```markdown

### Building a Pipeline

```elixir
alias HydepwnsLiveview.Utils.TransformationPipeline

# Create a new pipeline
pipeline = 
  TransformationPipeline.new(
    name: "User Processing Pipeline",
    description: "Processes user data for storage"
  )
  
# Add transformations to the pipeline
pipeline =
  pipeline
  |> TransformationPipeline.add(MyApp.Transformations.NormalizeEmail)
  |> TransformationPipeline.add(:validate_email, fn resource, _context ->
    if String.contains?(resource.email, "@") do
      {:ok, resource}
    else
      {:error, "Invalid email format"}
    end
  end)
  |> TransformationPipeline.add(
    MyApp.Transformations.GenerateUsername,
    hook: :post_validation
  )
```markdown

## Applying a Pipeline

```elixir
# Apply the pipeline to a resource
user = %{
  name: "John Doe",
  email: "JOHN@EXAMPLE.COM"
}

case TransformationPipeline.apply(pipeline, user) do
  {:ok, transformed_user} ->
    # Handle success
    IO.inspect(transformed_user) 
    # %{name: "John Doe", email: "john@example.com", username: "johndoe"}
    
  {:error, reason} ->
    # Handle error
    IO.puts("Error: #{reason.message}")
end

# Apply with additional context
context = %{
  current_user: admin_user,
  timestamp: DateTime.utc_now()
}

TransformationPipeline.apply(pipeline, user, context: context)
```markdown

## Using the Registry

```elixir
alias HydepwnsLiveview.Utils.TransformationRegistry

# Register a transformation
TransformationRegistry.register(MyApp.Transformations.NormalizeEmail)

# Register with categories
TransformationRegistry.register(
  MyApp.Transformations.NormalizeEmail, 
  categories: [:email, :normalization]
)

# Discover transformations in a module
{:ok, modules} = TransformationRegistry.discover_in_module(MyApp.Transformations)

# Get transformations by category
email_transforms = TransformationRegistry.list_by_category(:email)

# Create a pipeline with all email transformations
pipeline = 
  TransformationPipeline.new(name: "Email Processing Pipeline")
  
pipeline =
  Enum.reduce(email_transforms, pipeline, fn transform, acc ->
    TransformationPipeline.add(acc, transform.module)
  end)
```markdown

## Visualizing Pipelines

```elixir
# Get a text visualization of the pipeline
pipeline_text = TransformationPipeline.visualize(pipeline)
IO.puts(pipeline_text)

# Output:
# Pipeline: User Processing Pipeline
# Description: Processes user data for storage
#
# Hook: pre_validation
#   - MyApp.Transformations.NormalizeEmail
#   - validate_email
#
# Hook: post_validation
#   - MyApp.Transformations.GenerateUsername

# Generate a GraphViz DOT representation for visualization tools
dot_graph = TransformationPipeline.visualize(pipeline, format: :dot)
File.write!("pipeline.dot", dot_graph)
```markdown

## Integration with LiveViewResource

The Resource Transformation Pipeline integrates with `LiveViewResource` to provide transformation capabilities for resources:

```elixir
defmodule MyApp.UserResource do
  use HydepwnsLiveview.Utils.LiveViewResource
  
  # ... attributes, validations, etc. ...
  
  # Define a default transformation pipeline
  def default_pipeline do
    HydepwnsLiveview.Utils.TransformationPipeline.new()
    |> HydepwnsLiveview.Utils.TransformationPipeline.add(MyApp.Transformations.NormalizeEmail)
    |> HydepwnsLiveview.Utils.TransformationPipeline.add(MyApp.Transformations.GenerateUsername)
  end
  
  # Apply transformations before saving
  def transform_before_save(resource, context \\ %{}) do
    HydepwnsLiveview.Utils.TransformationPipeline.apply(
      default_pipeline(),
      resource,
      context: context
    )
  end
end

# Usage in LiveView
def handle_event("save_user", %{"user" => params}, socket) do
  # Create resource from params
  {:ok, user} = UserResource.create(params)
  
  # Apply transformations
  case UserResource.transform_before_save(user, %{current_user: socket.assigns.current_user}) do
    {:ok, transformed_user} ->
      # Save the transformed user
      {:ok, saved_user} = UserResource.save(transformed_user)
      {:noreply, assign(socket, user: saved_user)}
      
    {:error, reason} ->
      {:noreply, put_flash(socket, :error, reason.message)}
  end
end
```markdown

## Performance Considerations

The transformation pipeline includes built-in performance monitoring capabilities:

```elixir
# Apply pipeline with metrics collection
{:ok, result} = TransformationPipeline.apply(pipeline, resource, collect_metrics: true)

# Get execution metrics
metrics = result.metrics

# Log slow transformations
for {name, execution_time} <- metrics, execution_time > 0.1 do
  Logger.warn("Slow transformation: #{name} took #{execution_time} seconds")
end
```markdown

## Best Practices

1. **Keep Transformations Focused**: Each transformation should have a single responsibility
2. **Make Transformations Stateless**: Avoid storing state in transformations
3. **Use Conditional Application**: Implement the `applicable?/2` callback to control when transformations are applied
4. **Provide Good Metadata**: Include helpful information in the `info/0` callback
5. **Handle Errors Gracefully**: Return detailed error information when transformations fail
6. **Monitor Performance**: Use the built-in metrics to identify slow transformations
7. **Organize Transformations**: Use categories to organize transformations by purpose
8. **Visualize Complex Pipelines**: Use the visualization tools to understand complex pipelines 

## References

- [Project Documentation](../README.md)
