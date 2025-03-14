---
title: Resource Transformation Pipeline
description: '## Overview'
topics:
  - reference
  - architecture
  - resource-transformation-pipeline
  - overview
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - core-components
  - example-transformations
  - create-a-registry-with-our-transformations
  - create-a-resource
  - create-a-context-with-a-username-conflict-checker
  - apply-all-applicable-transformations
  - result-
  - transformed-
  - name-john-doe-
  - email-john-doe-example-com-
  - username-johndoe1-
  - '-'
  - best-practices-and-patterns
  - stage-1-input-normalization
  - stage-2-business-logic
  - apply-stages-in-sequence
  - performance-optimization-strategies
  - testing-transformation-pipelines
  - advanced-usage-patterns
  - register-the-middleware-with-the-registry
  - contextual-transformations
  - related-documentation
  - conclusion
  - references
  - code-examples
  - testing
last_updated: '2025-03-14'
---
# Resource Transformation Pipeline

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

The Resource Transformation Pipeline is a robust system for applying a series of transformations to resources in a structured, maintainable way. It enables consistent data processing, validation, normalization, and enrichment throughout the application.

## Core Components

The transformation pipeline consists of several key components:

1. **Transformations**: Individual modules that implement the `Transformation` behavior
2. **TransformationRegistry**: A registry that manages and applies transformations
3. **Middleware**: Optional components that wrap transformation execution

## Example Transformations

To illustrate how the Resource Transformation Pipeline works in practice, here are some example transformations:

### NormalizeEmail

The `NormalizeEmail` transformation normalizes email addresses to lowercase for consistency in storage and comparison:

```elixir
defmodule HydepwnsLiveview.Transformations.NormalizeEmail do
  use HydepwnsLiveview.Utils.Transformation
  
  @impl true
  def transform(resource, _context) do
    if Map.has_key?(resource, :email) && resource.email do
      {:ok, Map.update!(resource, :email, &String.downcase/1)}
    else
      {:ok, resource}
    end
  end
  
  @impl true
  def applicable?(resource, _context) do
    Map.has_key?(resource, :email) && resource.email != nil
  end
  
  @impl true
  def info do
    %{
      name: "Normalize Email",
      description: "Normalizes email addresses to lowercase",
      version: "1.0",
      categories: [:email, :normalization],
      metadata: %{
        priority: :high
      }
    }
  end
end
```markdown

### GenerateUsername

The `GenerateUsername` transformation demonstrates more advanced functionality by generating a username from a user's name:

```elixir
defmodule HydepwnsLiveview.Transformations.GenerateUsername do
  use HydepwnsLiveview.Utils.Transformation
  
  @impl true
  def transform(resource, context) do
    if should_generate_username?(resource) do
      username = generate_username_from_name(resource.name)
      
      username = 
        if context[:username_exists?] do
          ensure_unique_username(username, context[:username_exists?])
        else
          username
        end
      
      {:ok, Map.put(resource, :username, username)}
    else
      {:ok, resource}
    end
  end
  
  @impl true
  def applicable?(resource, _context) do
    Map.has_key?(resource, :name) && resource.name != nil
  end
  
  @impl true
  def info do
    %{
      name: "Generate Username",
      description: "Generates a username from a user's name if one doesn't exist",
      version: "1.0",
      categories: [:user, :username_generation],
      metadata: %{
        priority: :medium,
        dependencies: [:normalize_email]
      }
    }
  end
  
  # Private helper functions omitted for brevity
end
```markdown

### Using Transformations Together

These transformations can be used together in a pipeline:

```elixir
# Create a registry with our transformations
registry = TransformationRegistry.new()
|> TransformationRegistry.register(NormalizeEmail)
|> TransformationRegistry.register(GenerateUsername)

# Create a resource
resource = %{
  name: "John Doe",
  email: "John.Doe@Example.COM"
}

# Create a context with a username conflict checker
context = %{
  username_exists?: fn username ->
    username == "johndoe"
  end
}

# Apply all applicable transformations
{:ok, transformed} = TransformationRegistry.apply_all(registry, resource, context)

# Result:
# transformed = %{
#   name: "John Doe",
#   email: "john.doe@example.com",
#   username: "johndoe1"
# }
```markdown

## Best Practices and Patterns

### Chaining Transformations Effectively

#### Transformation Order Management

Define clear dependencies between transformations to ensure they execute in the correct order:

```elixir
def info do
  %{
    name: "My Transformation",
    # ...
    metadata: %{
      # List transformations that must run before this one
      dependencies: [:normalize_email, :sanitize_input]
    }
  }
end
```markdown

#### Multi-stage Pipelines

For complex workflows, consider organizing transformations into stages:

```elixir
# Stage 1: Input normalization
normalization_pipeline = 
  TransformationRegistry.new()
  |> TransformationRegistry.register(NormalizeEmail)
  |> TransformationRegistry.register(SanitizeInput)

# Stage 2: Business logic
business_pipeline = 
  TransformationRegistry.new()
  |> TransformationRegistry.register(ValidateBusinessRules)
  |> TransformationRegistry.register(EnrichWithExternalData)

# Apply stages in sequence
{:ok, normalized} = TransformationRegistry.apply_all(normalization_pipeline, resource, context)
{:ok, processed} = TransformationRegistry.apply_all(business_pipeline, normalized, context)
```markdown

## Performance Optimization Strategies

#### Selective Application

Only apply transformations when necessary by implementing strict `applicable?/2` functions:

```elixir
def applicable?(resource, context) do
  # Only apply if the field exists and has changed
  Map.has_key?(resource, :email) && 
    Map.get(context.changes, :email) != nil
end
```markdown

#### Result Caching

Cache transformation results for expensive operations:

```elixir
defmodule CachedTransformation do
  use HydepwnsLiveview.Utils.Transformation
  
  @impl true
  def transform(resource, context) do
    cache_key = generate_cache_key(resource)
    
    case TransformationCache.get(cache_key) do
      {:ok, cached_result} ->
        {:ok, cached_result}
      _ ->
        # Perform expensive transformation
        result = expensive_transform(resource)
        TransformationCache.put(cache_key, result)
        {:ok, result}
    end
  end
end
```markdown

### Error Handling Patterns

#### Graceful Degradation

Continue processing even when a transformation fails:

```elixir
defmodule GracefulTransformation do
  use HydepwnsLiveview.Utils.Transformation
  
  @impl true
  def transform(resource, context) do
    try do
      result = perform_risky_transform(resource)
      {:ok, result}
    rescue
      e ->
        Logger.warn("Transformation failed: #{inspect(e)}")
        # Return original resource but flag the error
        {:ok, resource, Map.update(context, :warnings, [e], &[e | &1])}
    end
  end
end
```markdown

#### Comprehensive Error Reporting

Provide detailed error information:

```elixir
defmodule DetailedErrorTransformation do
  use HydepwnsLiveview.Utils.Transformation
  
  @impl true
  def transform(resource, _context) do
    case complex_transformation(resource) do
      {:ok, result} ->
        {:ok, result}
      {:error, reason} ->
        error_details = %{
          transformation: __MODULE__,
          resource_id: resource.id,
          timestamp: DateTime.utc_now(),
          reason: reason,
          field: determine_problem_field(reason, resource)
        }
        {:error, error_details}
    end
  end
end
```markdown

## Testing Transformation Pipelines

### Unit Testing Individual Transformations

Test each transformation in isolation:

```elixir
defmodule NormalizeEmailTest do
  use ExUnit.Case
  
  alias HydepwnsLiveview.Transformations.NormalizeEmail
  
  test "normalizes email to lowercase" do
    resource = %{email: "User@Example.COM"}
    {:ok, result} = NormalizeEmail.transform(resource, %{})
    assert result.email == "user@example.com"
  end
  
  test "leaves non-email fields unchanged" do
    resource = %{email: "User@Example.COM", name: "User"}
    {:ok, result} = NormalizeEmail.transform(resource, %{})
    assert result.name == "User"
  end
  
  test "handles nil email" do
    resource = %{email: nil}
    {:ok, result} = NormalizeEmail.transform(resource, %{})
    assert result.email == nil
  end
end
```markdown

### Integration Testing Transformation Chains

Test transformations working together:

```elixir
defmodule UserTransformationPipelineTest do
  use ExUnit.Case
  
  setup do
    registry = TransformationRegistry.new()
               |> TransformationRegistry.register(NormalizeEmail)
               |> TransformationRegistry.register(GenerateUsername)
               |> TransformationRegistry.register(SanitizeHtmlContent)
    
    {:ok, registry: registry}
  end
  
  test "full user registration pipeline", %{registry: registry} do
    user = %{
      name: "John Doe",
      email: "John.Doe@Example.com",
      content: "<script>alert('xss')</script><p>Bio info</p>"
    }
    
    {:ok, transformed} = TransformationRegistry.apply_all(registry, user, %{})
    
    assert transformed.email == "john.doe@example.com"
    assert transformed.username == "johndoe"
    assert transformed.content == "<p>Bio info</p>"
  end
end
```markdown

## Advanced Usage Patterns

### Transformation Middleware

Create middleware that wraps all transformations:

```elixir
defmodule TransformationTracer do
  @behaviour TransformationMiddleware
  
  @impl true
  def before_transform(transformation, resource, context) do
    start_time = System.monotonic_time()
    metadata = %{
      start_time: start_time,
      transformation: transformation,
      resource_id: resource.id
    }
    
    {resource, Map.put(context, :tracer_metadata, metadata)}
  end
  
  @impl true
  def after_transform(result, transformation, resource, context) do
    %{start_time: start_time} = context.tracer_metadata
    duration_ms = (System.monotonic_time() - start_time) / 1_000_000
    
    Logger.debug("Transformation #{inspect(transformation)} took #{duration_ms}ms for resource #{resource.id}")
    
    # Can modify the result or context here
    result
  end
end

# Register the middleware with the registry
registry = 
  TransformationRegistry.new()
  |> TransformationRegistry.add_middleware(TransformationTracer)
  |> TransformationRegistry.register(NormalizeEmail)
  # ...
```markdown

## Contextual Transformations

Adapt transformations based on user roles or other context:

```elixir
defmodule RoleBasedTransformation do
  use HydepwnsLiveview.Utils.Transformation
  
  @impl true
  def transform(resource, context) do
    case context.current_user.role do
      :admin ->
        # Allow all fields for admins
        {:ok, resource}
      :editor ->
        # Editors can only modify specific fields
        allowed_fields = [:title, :content, :tags]
        filtered = Map.take(resource, allowed_fields)
        {:ok, filtered}
      :viewer ->
        # Viewers get read-only version
        read_only = Map.put(resource, :readonly, true)
        {:ok, read_only}
    end
  end
  
  @impl true
  def applicable?(_resource, context) do
    # Only apply when we have user role information
    Map.has_key?(context, :current_user) && 
      Map.has_key?(context.current_user, :role)
  end
end
```markdown

## Related Documentation

- [Resource System](resource-system.md)
- [Event Bus](event-bus.md)
- [Reactive State](reactive-state.md)

## Conclusion

The Resource Transformation Pipeline provides a flexible, powerful framework for processing resources throughout your application. By using the patterns and examples in this documentation, you can create maintainable, testable transformations that adapt to your business needs. 

## References

- [Project Documentation](../README.md)
