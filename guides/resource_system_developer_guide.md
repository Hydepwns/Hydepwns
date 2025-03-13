# Hydepwns Resource System Developer Guide

## Introduction

The Hydepwns Resource System is a comprehensive solution for managing domain entities in your application through an event-sourced approach. This guide will help you understand the system's architecture, how to create and use resources, and how to leverage the various features available.

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Creating Resources](#creating-resources)
3. [Working with Events](#working-with-events)
4. [Resource Testing](#resource-testing)
5. [Integration with External Systems](#integration-with-external-systems)
6. [Admin Interface](#admin-interface)
7. [Performance Optimization](#performance-optimization)
8. [Best Practices](#best-practices)

## Core Concepts

### What is a Resource?

A resource is a domain entity that represents a business concept in your application. Resources in Hydepwns are event-sourced, meaning their state is derived from a sequence of events rather than being directly stored in a database.

### Event Sourcing

Event sourcing is a pattern where changes to the application state are captured as a sequence of events. Instead of storing the current state directly, we store the events that led to that state. This provides benefits like:

- Complete audit history
- Ability to reconstruct the state at any point in time
- Separation of write and read models
- Easy event replay for testing and debugging

### Resources vs. Traditional Models

Unlike traditional database models that store current state, resources in Hydepwns:

- Derive their state from events
- Have a clear history of all changes
- Allow for more sophisticated event-based workflows
- Can be replicated and synchronized more easily

## Creating Resources

### Basic Resource Structure

A resource module consists of:

1. Initial state definition
2. Event handlers that update state based on events
3. Command functions that generate events
4. Helper functions for working with the resource

### Example: Creating a Simple Resource

```elixir
defmodule MyApp.Resources.ProductResource do
  use HydepwnsLiveview.Events.EventSourcedResource
  
  # Define initial state
  @impl true
  def initial_state do
    %{
      name: nil,
      price: nil,
      inventory: 0,
      active: false,
      created_at: nil,
      updated_at: nil
    }
  end
  
  # Define resource type
  @impl true
  def resource_type, do: "product"
  
  # Event handlers
  @impl true
  def apply_event(%Event{type: "product_created"} = event, _state) do
    Map.merge(initial_state(), %{
      name: event.data.name,
      price: event.data.price,
      created_at: event.data.created_at || DateTime.utc_now(),
      updated_at: event.data.created_at || DateTime.utc_now()
    })
  end
  
  def apply_event(%Event{type: "price_updated"} = event, state) do
    %{state | 
      price: event.data.price,
      updated_at: event.data.updated_at || DateTime.utc_now()
    }
  end
  
  # Command functions
  def create_product(resource_id, name, price, metadata \\ %{}) do
    event = %Event{
      type: "product_created",
      resource_id: resource_id,
      data: %{
        name: name,
        price: price,
        created_at: DateTime.utc_now()
      },
      metadata: metadata
    }
    
    ResourceEventGenerator.generate_event(__MODULE__, event)
  end
  
  def update_price(resource_id, price, metadata \\ %{}) do
    event = %Event{
      type: "price_updated",
      resource_id: resource_id,
      data: %{
        price: price,
        updated_at: DateTime.utc_now()
      },
      metadata: metadata
    }
    
    ResourceEventGenerator.generate_event(__MODULE__, event)
  end
end
```

### Resource Attributes and Relationships

For more complex resources, you can use the ResourceDSL to define attributes and relationships:

```elixir
defmodule MyApp.Resources.CategoryResource do
  use HydepwnsLiveview.Utils.ResourceDSL
  
  attribute(:id, :string, required: true)
  attribute(:name, :string, required: true)
  attribute(:description, :string)
  attribute(:active, :boolean, default: true)
  
  has_many(:products, MyApp.Resources.ProductResource)
  
  validate(:name_must_not_be_empty, fn resource ->
    if resource.name && String.length(resource.name) > 0 do
      :ok
    else
      {:error, "Name cannot be empty"}
    end
  end)
end
```

## Working with Events

### Event Structure

Events in the Hydepwns system have a standard structure:

```elixir
%Event{
  type: "event_type",      # String identifying the event type
  resource_id: "res-123",  # ID of the resource this event applies to
  data: %{},               # Event payload data
  metadata: %{},           # Additional metadata
  timestamp: ~U[2023-01-01 12:00:00Z] # Event timestamp
}
```

### Event Types

Each resource defines its own set of event types that represent state transitions. Common patterns include:

- `resource_created` - Initial creation
- `resource_updated` - General updates
- `resource_deleted` - Logical deletion
- Specific actions like `order_paid`, `item_added`, etc.

### Event Handlers

Event handlers in resources are implementations of the `apply_event/2` function:

```elixir
def apply_event(%Event{type: "event_type"} = event, state) do
  # Transform state based on event
  %{state | 
    some_field: event.data.some_value,
    updated_at: event.timestamp
  }
end
```

### Event Bus

The `EventBus` module allows you to subscribe to events:

```elixir
# Subscribe to all events for a specific resource type
EventBus.subscribe("order:*")

# Subscribe to specific event types
EventBus.subscribe("order:order_paid")

# Handle events
def handle_info({:event, %Event{type: "order_paid"} = event}, state) do
  # Handle event
  {:noreply, state}
end
```

## Resource Testing

The TestFramework module provides tools for testing resources:

### Scenario Tests

Scenario tests run a sequence of commands against a resource:

```elixir
alias HydepwnsLiveview.Resources.TestFramework

test "can create and update a product" do
  result = TestFramework.scenario_test(ProductResource, fn ctx ->
    ctx
    |> TestFramework.given_command(:create_product, ["product-1", "Test Product", Decimal.new("10.99")])
    |> TestFramework.when_command(:update_price, ["product-1", Decimal.new("12.99")])
    |> TestFramework.then_state_matches(%{name: "Test Product", price: Decimal.new("12.99")})
  end)
  
  assert match?({:ok, _}, result)
end
```

### Property Tests

Property tests verify that resources maintain invariants across random sequences of events:

```elixir
test "product price is always positive" do
  result = TestFramework.property_test(ProductResource, fn ctx ->
    positive_price? = Decimal.cmp(ctx.current_state.price, Decimal.new("0")) == :gt
    if ctx.current_state.price && !positive_price? do
      {:error, "Price must be positive"}
    else
      :ok
    end
  end, iterations: 100)
  
  assert match?({:ok, _}, result)
end
```

### Test Reporting

Generate HTML reports for test results:

```elixir
alias HydepwnsLiveview.Resources.TestFrameworkReporter

TestFrameworkReporter.run_scenario_and_report(
  ProductResource, 
  &product_creation_scenario/1,
  title: "Product Creation Test",
  output_path: "test_reports/product_creation.html"
)
```

## Integration with External Systems

### Integration Bridge

The IntegrationBridge provides a standardized way to connect resources with external systems:

```elixir
alias HydepwnsLiveview.Integration.IntegrationBridge

# Register an adapter
{:ok, adapter_id} = IntegrationBridge.register_adapter(
  "shopify", 
  MyApp.ShopifyAdapter,
  %{api_key: "key", api_secret: "secret"}
)

# Import data from external system
{:ok, imported_ids} = IntegrationBridge.import_from_external(
  adapter_id,
  "product",
  ProductResource,
  %{limit: 100}
)

# Export data to external system
{:ok, exported} = IntegrationBridge.export_to_external(
  adapter_id,
  product_ids,
  ProductResource
)

# Synchronize data
{:ok, sync_report} = IntegrationBridge.synchronize(
  adapter_id,
  "product",
  ProductResource,
  %{direction: :both}
)
```

### Creating Integration Adapters

To create a new adapter, implement the IntegrationAdapter behavior:

```elixir
defmodule MyApp.ShopifyAdapter do
  @behaviour HydepwnsLiveview.Integration.IntegrationAdapter
  
  @impl true
  def validate_config(config) do
    # Validate configuration
    if config.api_key && config.api_secret do
      :ok
    else
      {:error, "Missing API key or secret"}
    end
  end
  
  @impl true
  def fetch_data(options) do
    # Fetch data from Shopify
    # ...
    {:ok, products}
  end
  
  @impl true
  def export_data(data, options) do
    # Export data to Shopify
    # ...
    {:ok, external_ids}
  end
  
  @impl true
  def test_connection(config) do
    # Test connection to Shopify
    # ...
    {:ok, "Connected"}
  end
end
```

## Admin Interface

The admin interface provides a UI for managing resources:

### Resource Dashboard

The `HydepwnsLiveviewWeb.Admin.ResourceDashboardLive` module provides a LiveView for managing resources:

- View resources of different types
- Filter and sort resources
- View resource details and event history
- Create, update, and delete resources

### Navigation

Add the resource dashboard to your router:

```elixir
scope "/admin", HydepwnsLiveviewWeb.Admin do
  pipe_through [:browser, :require_admin]
  
  live "/resources", ResourceDashboardLive, :index
end
```

## Performance Optimization

### Resource Optimizer

The `HydepwnsLiveview.Performance.ResourceOptimizer` module provides tools for optimizing resource performance:

```elixir
alias HydepwnsLiveview.Performance.ResourceOptimizer

# Optimize snapshot interval
{:ok, interval} = ResourceOptimizer.optimize_snapshot_interval(ProductResource)

# Set up resource caching
ResourceOptimizer.setup_resource_cache(ProductResource, ttl: 300)

# Get a cached resource
{:ok, resource} = ResourceOptimizer.get_cached_resource(ProductResource, "product-1")

# Batch process commands
commands = [
  {:create_product, "product-1", ["Product 1", Decimal.new("10.99")]},
  {:create_product, "product-2", ["Product 2", Decimal.new("19.99")]}
]
{:ok, results} = ResourceOptimizer.batch_process(ProductResource, commands)

# Analyze performance
{:ok, metrics} = ResourceOptimizer.analyze_performance("product")
```

### Performance Best Practices

1. Use appropriate snapshot intervals based on resource access patterns
2. Cache frequently accessed resources
3. Use batch processing for bulk operations
4. Implement efficient projections for read-heavy use cases
5. Consider sharding for high-volume resource types

## Best Practices

### Resource Design

1. **Keep resources focused**: Each resource should represent a single domain concept
2. **Design meaningful events**: Events should represent business-meaningful state transitions
3. **Use descriptive event types**: Event types should clearly communicate what happened
4. **Include all necessary data**: Events should contain all data needed to reconstruct state
5. **Separate commands and queries**: Follow CQRS principles for complex systems

### Event Handling

1. **Make event handlers pure functions**: They should only depend on the event and current state
2. **Handle unknown events gracefully**: Return the current state unchanged for unknown events
3. **Validate state transitions**: Ensure state transitions are valid in command functions
4. **Use metadata for context**: Store contextual information in event metadata

### Testing

1. **Test common scenarios**: Write scenario tests for common use cases
2. **Test edge cases**: Use property tests to find edge cases
3. **Test invariants**: Verify that resources maintain important invariants
4. **Generate test reports**: Use test reporters to generate detailed reports

### Integration

1. **Design clean adapter interfaces**: Make adapters replaceable and testable
2. **Handle failures gracefully**: Implement proper error handling for external systems
3. **Use idempotent operations**: Ensure operations can be safely retried
4. **Implement conflict resolution**: Define clear strategies for handling conflicts

## Conclusion

The Hydepwns Resource System provides a powerful foundation for building event-sourced applications. By following the patterns and practices outlined in this guide, you can create robust, maintainable, and performant applications that leverage the benefits of event sourcing.

## Additional Resources

- [Event Sourcing Patterns](https://martinfowler.com/eaaDev/EventSourcing.html)
- [Command Query Responsibility Segregation (CQRS)](https://martinfowler.com/bliki/CQRS.html)
- [Domain-Driven Design](https://www.domainlanguage.com/ddd/)
- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)
- [Elixir Documentation](https://elixir-lang.org/docs.html) 