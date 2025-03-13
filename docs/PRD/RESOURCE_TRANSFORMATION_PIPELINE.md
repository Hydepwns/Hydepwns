## Example Transformations

To illustrate how the Resource Transformation Pipeline works in practice, we've implemented two example transformations:

### NormalizeEmail

The `NormalizeEmail` transformation is a simple example that normalizes email addresses to lowercase. This ensures consistency in email storage and comparison throughout the system.

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
```

### GenerateUsername

The `GenerateUsername` transformation demonstrates more advanced functionality. It generates a username from a user's name if one doesn't exist, handles special characters, ensures minimum length, and can even handle username conflicts using a provided conflict checker function.

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
```

### Using Transformations Together

These transformations can be used together in a pipeline. For example:

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
```

Note that the `GenerateUsername` transformation declares a dependency on `NormalizeEmail` in its `info/0` function. This ensures that email normalization happens before username generation, which could be important if the username generation logic were to use the email address. 

## Additional Transformation Examples

### Input Sanitization Transformation

The `SanitizeHtmlContent` transformation demonstrates how to securely process user-generated content by stripping unsafe HTML tags while preserving safe formatting.

```elixir
defmodule HydepwnsLiveview.Transformations.SanitizeHtmlContent do
  use HydepwnsLiveview.Utils.Transformation
  
  @allowed_tags ~w(p br b i u ul ol li h1 h2 h3 h4 h5 h6 blockquote)
  
  @impl true
  def transform(resource, _context) do
    sanitized_content = 
      resource.content
      |> HtmlSanitizer.sanitize(allowed_tags: @allowed_tags)
    
    {:ok, %{resource | content: sanitized_content}}
  end
  
  @impl true
  def applicable?(resource, _context) do
    Map.has_key?(resource, :content) && is_binary(resource.content)
  end
  
  @impl true
  def info do
    %{
      name: "Sanitize HTML Content",
      description: "Removes potentially unsafe HTML tags from user content",
      version: "1.0",
      categories: [:security, :content],
      metadata: %{
        priority: :critical,
        audit_required: true
      }
    }
  end
end
```

### Format Conversion Transformation

The `ConvertDateFormat` transformation converts date strings between different formats, ensuring consistency across the application:

```elixir
defmodule HydepwnsLiveview.Transformations.ConvertDateFormat do
  use HydepwnsLiveview.Utils.Transformation
  
  @date_fields [:created_at, :updated_at, :published_at, :due_date]
  
  @impl true
  def transform(resource, context) do
    target_format = context[:target_format] || "{YYYY}-{0M}-{0D}"
    
    updated_resource =
      @date_fields
      |> Enum.filter(&Map.has_key?(resource, &1))
      |> Enum.reduce(resource, fn field, acc ->
        case format_date(Map.get(acc, field), target_format) do
          {:ok, formatted} -> Map.put(acc, field, formatted)
          _ -> acc
        end
      end)
    
    {:ok, updated_resource}
  end
  
  @impl true
  def applicable?(resource, _context) do
    Enum.any?(@date_fields, &Map.has_key?(resource, &1))
  end
  
  @impl true
  def info do
    %{
      name: "Convert Date Format",
      description: "Converts date strings to a consistent format",
      version: "1.0",
      categories: [:date, :formatting],
      metadata: %{
        priority: :medium
      }
    }
  end
  
  defp format_date(nil, _), do: {:error, :no_date}
  defp format_date(date, format) when is_binary(date) do
    # Implementation uses Timex or similar for parsing and formatting
    {:ok, parsed} = Timex.parse(date, "{ISO:Extended}")
    {:ok, Timex.format!(parsed, format)}
  rescue
    _ -> {:error, :invalid_date}
  end
  defp format_date(%DateTime{} = date, format) do
    {:ok, Timex.format!(date, format)}
  rescue
    _ -> {:error, :format_error}  
  end
end
```

### Computed Field Transformation

The `ComputeFullName` transformation demonstrates how to derive new fields from existing data:

```elixir
defmodule HydepwnsLiveview.Transformations.ComputeFullName do
  use HydepwnsLiveview.Utils.Transformation
  
  @impl true
  def transform(resource, _context) do
    full_name = build_full_name(resource)
    {:ok, Map.put(resource, :full_name, full_name)}
  end
  
  @impl true
  def applicable?(resource, _context) do
    has_first_name = Map.has_key?(resource, :first_name) && is_binary(resource.first_name)
    has_last_name = Map.has_key?(resource, :last_name) && is_binary(resource.last_name)
    has_first_name && has_last_name
  end
  
  @impl true
  def info do
    %{
      name: "Compute Full Name",
      description: "Generates a full name field from first and last name",
      version: "1.0",
      categories: [:user, :computed_fields],
      metadata: %{
        priority: :low,
        cache_result: true
      }
    }
  end
  
  defp build_full_name(resource) do
    first = String.trim(resource.first_name)
    last = String.trim(resource.last_name)
    
    cond do
      first != "" && last != "" -> "#{first} #{last}"
      first != "" -> first
      last != "" -> last
      true -> ""
    end
  end
end
```

# Transformation Cookbook

This cookbook provides patterns, best practices, and strategies for effectively using the Resource Transformation Pipeline in your application.

## Chaining Transformations Effectively

### Pattern: Transformation Order Management

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
```

### Pattern: Multi-stage Pipelines

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
```

### Pattern: Conditional Transformations

Create adaptation transformations that modify the pipeline based on resource content:

```elixir
defmodule ConditionalTransformationAdapter do
  use HydepwnsLiveview.Utils.Transformation
  
  @impl true
  def transform(resource, context) do
    # Modify context to add/remove transformations based on resource content
    updated_context =
      if is_premium_user?(resource) do
        Map.put(context, :transformations, context.transformations ++ [:premium_features])
      else
        context
      end
    
    {:ok, resource, updated_context}
  end
  
  # Always applicable
  @impl true
  def applicable?(_resource, _context), do: true
  
  # Always run first
  @impl true
  def info do
    %{
      name: "Conditional Transformation Adapter",
      metadata: %{priority: :highest}
    }
  end
end
```

## Performance Optimization Strategies

### Strategy: Selective Application

Only apply transformations when necessary by implementing strict `applicable?/2` functions:

```elixir
def applicable?(resource, context) do
  # Only apply if the field exists and has changed
  Map.has_key?(resource, :email) && 
    Map.get(context.changes, :email) != nil
end
```

### Strategy: Result Caching

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
  
  # Implementation details omitted for brevity
end
```

### Strategy: Batch Processing

Group similar resources for batch transformation:

```elixir
defmodule BatchedExternalEnrichment do
  use HydepwnsLiveview.Utils.Transformation
  
  @impl true
  def transform(resources, context) when is_list(resources) do
    # Extract IDs for batch processing
    ids = Enum.map(resources, & &1.id)
    
    # Fetch data for all resources in a single API call
    enrichment_data = ExternalAPI.fetch_batch_data(ids)
    
    # Enrich each resource
    enriched = Enum.map(resources, fn resource ->
      data = Map.get(enrichment_data, resource.id, %{})
      Map.merge(resource, data)
    end)
    
    {:ok, enriched}
  end
  
  # Support single resource transformation by wrapping in a list
  def transform(resource, context) do
    case transform([resource], context) do
      {:ok, [result]} -> {:ok, result}
      error -> error
    end
  end
end
```

## Error Handling Patterns in Transformations

### Pattern: Graceful Degradation

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
```

### Pattern: Validation Integration

Combine transformations with validation:

```elixir
defmodule ValidatingTransformation do
  use HydepwnsLiveview.Utils.Transformation
  
  @impl true
  def transform(resource, context) do
    transformed = perform_transform(resource)
    
    case validate(transformed) do
      :ok -> 
        {:ok, transformed}
      {:error, errors} ->
        # Return original with validation errors
        {:error, resource, errors}
    end
  end
  
  defp validate(resource) do
    # Use your validation system
    Validator.validate(resource, [:required_fields, :format_checks])
  end
end
```

### Pattern: Comprehensive Error Reporting

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
```

## Testing Transformation Pipelines

### Strategy: Unit Testing Individual Transformations

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
```

### Strategy: Integration Testing Transformation Chains

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
```

### Strategy: Property-Based Testing

Test transformations with randomly generated data:

```elixir
defmodule PropertyBasedTransformationTest do
  use ExUnit.Case
  use ExUnitProperties
  
  alias HydepwnsLiveview.Transformations.NormalizeEmail
  
  property "email is always lowercase after transformation" do
    check all email <- email_generator() do
      resource = %{email: email}
      {:ok, result} = NormalizeEmail.transform(resource, %{})
      assert result.email == String.downcase(email)
    end
  end
  
  defp email_generator do
    gen all username <- string(:alphanumeric, min_length: 1),
            domain <- string(:alphanumeric, min_length: 1),
            tld <- one_of(["com", "org", "net", "io"]) do
      random_case("#{username}@#{domain}.#{tld}")
    end
  end
  
  defp random_case(string) do
    string
    |> String.graphemes()
    |> Enum.map(fn char ->
      if :rand.uniform() > 0.5, do: String.upcase(char), else: String.downcase(char)
    end)
    |> Enum.join()
  end
end
```

## Advanced Usage Patterns

### Pattern: Transformation Middleware

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
```

### Pattern: Contextual Transformations

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
```

## Conclusion

The Resource Transformation Pipeline provides a flexible, powerful framework for processing resources throughout your application. By using the patterns and examples in this cookbook, you can create maintainable, testable transformations that adapt to your business needs.

For more information, see the API documentation for the `Transformation` behavior and the `TransformationRegistry` module. 