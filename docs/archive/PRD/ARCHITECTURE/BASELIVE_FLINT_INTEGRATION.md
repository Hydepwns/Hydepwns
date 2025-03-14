---
title: Integrating BaseLive and Flint
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - archive
  - prd
  - architecture
  - integrating-baselive-and-flint
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - integration-architecture
  - implementation-components
  - example-usage
  - define-a-flint-schema
  - use-the-schema-in-a-liveview
  - advanced-auto-generated-forms
  - advanced-integration-opportunities
  - benefits-of-integration
  - implementation-roadmap
  - conclusion
  - references
  - code-examples
  - testing
  - development
last_updated: '2025-03-14'
---
# Integrating BaseLive and Flint

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

# Integrating BaseLive and Flint


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document explores how to integrate the BaseLive module with Flint to create a comprehensive validation pipeline from data schemas to LiveView UI components.

BaseLive provides socket validation for Phoenix LiveView, enforcing type safety and required assigns at the UI layer. [Flint](https://github.com/acalejos/flint) enhances Ecto embedded schemas with declarative validation, type checking, and rich schema definitions.

By combining these technologies, we can create a continuous validation flow from data models to user interfaces.

## Integration Architecture

```ruby
┌────────────────┐      ┌─────────────────┐      ┌────────────────┐
│  Flint Schema  │ ───▶ │  DataContext    │ ───▶ │    BaseLive    │
│  (Data Layer)  │      │ (Domain Layer)  │      │   (UI Layer)   │
└────────────────┘      └─────────────────┘      └────────────────┘
```markdown

### Key Integration Points

1. **Schema Definition**: Define your schemas with Flint
2. **Type Propagation**: Extract types from Flint to BaseLive
3. **Validation Chaining**: Pass validation results between layers
4. **Error Aggregation**: Combine and contextualize errors across the stack

## Implementation Components

### Schema Type Extractor

This module extracts type specifications from a Flint schema for use in BaseLive:

```elixir
defmodule HydepwnsLiveview.Integration.SchemaTypeExtractor do
  @moduledoc """
  Extracts type specifications from a Flint schema for use in BaseLive
  """
  
  def extract_types(schema_module) do
    fields = schema_module.__schema__(:fields)
    
    fields
    |> Enum.map(fn field ->
      {field, get_field_type_spec(schema_module, field)}
    end)
    |> Map.new()
  end
  
  defp get_field_type_spec(schema_module, field) do
    type = schema_module.__schema__(:type, field)
    required = field in (schema_module.__schema__(:required) || [])
    
    case {type, required} do
      {{:embed, embed_schema}, _} -> extract_types(embed_schema)
      {:string, _} -> :string
      {:integer, _} -> :integer
      {:boolean, _} -> :boolean
      {Ecto.Enum, _} -> 
        values = schema_module.__schema__(:field_source, {field, :values})
        {:one_of, Map.values(values)}
      {_, _} -> :any
    end
  end
end
```markdown

### LiveView Integration Module

This module provides utilities for integrating Flint schemas with BaseLive:

```elixir
defmodule HydepwnsLiveview.Integration.FlintLiveIntegration do
  @moduledoc """
  Utilities for integrating Flint schemas with BaseLive
  """
  
  alias HydepwnsLiveview.Integration.SchemaTypeExtractor
  
  @doc """
  Generates type_specs for BaseLive from a Flint schema
  """
  def generate_type_specs(schema_module) do
    SchemaTypeExtractor.extract_types(schema_module)
  end
  
  @doc """
  Validates LiveView socket assigns against a Flint schema
  """
  def validate_socket_against_schema(socket, assign_key, schema_module) do
    case socket.assigns[assign_key] do
      nil -> {:error, "Assign #{assign_key} not found", socket}
      data ->
        changeset = schema_module.changeset(%schema_module{}, data)
        if changeset.valid? do
          {:ok, socket}
        else
          errors = format_changeset_errors(changeset)
          {:error, errors, socket}
        end
    end
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
```markdown

### Socket Enforced Schema

This module wraps socket assigns with schema validation guarantees:

```elixir
defmodule HydepwnsLiveview.Integration.SchemaEnforcedSocket do
  @moduledoc """
  Wraps socket assigns with schema validation guarantees
  """
  
  require Logger
  
  @doc """
  Updates a socket assign with schema validation
  """
  def update_with_schema(socket, key, value, schema) do
    # Attempt to validate the value against the schema
    case schema.changeset(%schema{}, value) do
      %{valid?: true} = changeset ->
        # Apply any transformations from the changeset
        validated_value = Ecto.Changeset.apply_changes(changeset)
        Phoenix.LiveView.assign(socket, key, validated_value)
        
      changeset ->
        # Log validation failure but allow the update
        # This provides developer feedback without breaking the app
        Logger.warning("Schema validation failed for #{key}: #{inspect(changeset.errors)}")
        Phoenix.LiveView.assign(socket, key, value)
    end
  end
end
```markdown

## Example Usage

### Basic Integration

```elixir
# Define a Flint schema
defmodule MyApp.UserForm do
  use Flint.Schema

  embedded_schema do
    field!(:name, :string)
    field!(:email, :string) do
      # Flint validation via function
      !String.match?(email, ~r/@/) -> "must contain @ symbol"
    end
    field(:age, :integer)
    field(:theme, Ecto.Enum, values: [dark: 0, light: 1, dim: 2])
  end
end

# Use the schema in a LiveView
defmodule MyAppWeb.UserFormLive do
  use HydepwnsLiveviewWeb.BaseLive,
    # Automatically derive type specs from the Flint schema
    type_specs: HydepwnsLiveview.Integration.FlintLiveIntegration.generate_type_specs(MyApp.UserForm),
    required_assigns: [:user_form, :validation_state]
  
  alias HydepwnsLiveview.Integration.FlintLiveIntegration
  
  @impl true
  def do_mount(_params, _session, socket) do
    # Initialize with default values
    socket
    |> assign(:user_form, %{name: "", email: "", age: nil, theme: :dark})
    |> assign(:validation_state, %{valid: true, errors: %{}})
  end
  
  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    # Validate using both Flint and BaseLive
    socket = assign(socket, :user_form, user_params)
    
    # Use Flint's changeset validation
    case FlintLiveIntegration.validate_socket_against_schema(socket, :user_form, MyApp.UserForm) do
      {:ok, _} ->
        socket = assign(socket, :validation_state, %{valid: true, errors: %{}})
        {:noreply, socket}
        
      {:error, errors, _} ->
        socket = assign(socket, :validation_state, %{valid: false, errors: errors})
        {:noreply, socket}
    end
  end
end
```markdown

## Advanced Auto-Generated Forms

```elixir
defmodule HydepwnsLiveview.Components.FlintForm do
  use Phoenix.Component
  import Phoenix.HTML.Form
  
  def dynamic_form(assigns) do
    ~H"""
    <.form id={@id} phx-submit={@submit} phx-change={@change || "validate"}>
      <%= for field <- schema_fields(@schema) do %>
        <div class="field-container">
          <%= render_field(field, @schema, @form_data, @errors) %>
        </div>
      <% end %>
      <button type="submit" class="btn btn-primary">Submit</button>
    </.form>
    """
  end
  
  defp schema_fields(schema_module) do
    schema_module.__schema__(:fields)
  end
  
  defp render_field(field, schema_module, form_data, errors) do
    type = schema_module.__schema__(:type, field)
    required = field in (schema_module.__schema__(:required) || [])
    error = get_in(errors, [field])
    
    case type do
      :string -> 
        render_text_input(field, form_data[field], required, error)
      :integer -> 
        render_number_input(field, form_data[field], required, error)
      :boolean -> 
        render_checkbox(field, form_data[field], required, error)
      Ecto.Enum -> 
        values = schema_module.__schema__(:field_source, {field, :values})
        render_select(field, form_data[field], values, required, error)
      _ -> 
        render_text_input(field, form_data[field], required, error)
    end
  end
  
  # Implementations of render_text_input, render_number_input, etc.
end
```markdown

## Advanced Integration Opportunities

### 1. Multi-Step Form Wizard with Schema Evolution

As users progress through a multi-step form, you can evolve the schema and UI validation:

```elixir
defmodule MyApp.Wizards.RegistrationLive do
  use HydepwnsLiveviewWeb.BaseLive
  alias HydepwnsLiveview.Integration.FlintLiveIntegration
  
  @steps [
    {MyApp.Schemas.UserDetails, "User Details"},
    {MyApp.Schemas.ContactInfo, "Contact Information"},
    {MyApp.Schemas.Preferences, "Preferences"}
  ]
  
  def do_mount(_params, _session, socket) do
    {current_schema, current_title} = Enum.at(@steps, 0)
    
    socket
    |> assign(:current_step, 0)
    |> assign(:steps_count, length(@steps))
    |> assign(:current_schema, current_schema)
    |> assign(:current_title, current_title)
    |> assign(:form_data, %{})
    |> assign(:aggregate_data, %{})
    |> assign(:type_specs, FlintLiveIntegration.generate_type_specs(current_schema))
  end
  
  def handle_event("next_step", params, socket) do
    current_step = socket.assigns.current_step
    current_schema = socket.assigns.current_schema
    
    # Validate current step with current schema
    case FlintLiveIntegration.validate_socket_against_schema(
      socket |> assign(:form_data, params["form"]), 
      :form_data, 
      current_schema
    ) do
      {:ok, _} ->
        # If valid, move to next step
        next_step = current_step + 1
        
        if next_step < length(@steps) do
          {next_schema, next_title} = Enum.at(@steps, next_step)
          
          # Merge validated data into aggregate
          aggregate_data = Map.merge(
            socket.assigns.aggregate_data,
            socket.assigns.form_data
          )
          
          socket
          |> assign(:current_step, next_step)
          |> assign(:current_schema, next_schema)
          |> assign(:current_title, next_title)
          |> assign(:form_data, %{})
          |> assign(:aggregate_data, aggregate_data)
          |> assign(:type_specs, FlintLiveIntegration.generate_type_specs(next_schema))
          |> then(fn socket -> {:noreply, socket} end)
        else
          # Form completed, process final data
          complete_registration(socket)
        end
        
      {:error, errors, _} ->
        socket = assign(socket, :validation_errors, errors)
        {:noreply, socket}
    end
  end
  
  defp complete_registration(socket) do
    # Process the completed form data
    # ...
  end
end
```markdown

### 2. Debug Grid Integration

The Debug Grid can be enhanced to display schema validation information:

```elixir
defmodule HydepwnsLiveview.Integration.DebugGridSchemaIntegration do
  @moduledoc """
  Integrates Flint schema validation with the Debug Grid
  """
  
  @doc """
  Adds schema validation info to the debug grid
  """
  def inject_schema_debug_info(socket, schemas) do
    validation_data = 
      schemas
      |> Enum.map(fn {key, schema} -> 
        {key, validate_assign(socket, key, schema)}
      end)
      |> Enum.into(%{})
      
    socket
    |> assign(:__schema_debug__, validation_data)
    |> assign_debug_grid_data(:schemas, format_validation_data(validation_data))
  end
  
  defp validate_assign(socket, key, schema) do
    case socket.assigns[key] do
      nil -> %{valid: false, reason: :not_found}
      value ->
        changeset = schema.changeset(%schema{}, value)
        if changeset.valid? do
          %{valid: true}
        else
          errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)
          %{valid: false, errors: errors}
        end
    end
  end
  
  defp format_validation_data(validation_data) do
    validation_data
    |> Enum.map(fn {key, data} ->
      validity = if data.valid, do: "✅", else: "❌"
      errors = Map.get(data, :errors, %{})
      errors_formatted = if errors == %{}, do: "", else: inspect(errors)
      
      %{
        assign: to_string(key),
        valid: validity,
        errors: errors_formatted
      }
    end)
  end
  
  defp assign_debug_grid_data(socket, section, data) do
    debug_data = Map.get(socket.assigns, :__debug_grid_data__, %{})
    updated_debug_data = Map.put(debug_data, section, data)
    assign(socket, :__debug_grid_data__, updated_debug_data)
  end
end
```markdown

## Benefits of Integration

### 1. Type Safety

End-to-end type checking from your data models to your UI ensures that data maintains consistent types throughout your application. This helps catch errors early and makes refactoring easier.

### 2. DRY Validation

Define your validation rules once in your Flint schema and reuse them throughout your application. This prevents duplication and ensures consistent validation.

### 3. Self-Documenting Code

Schema definitions serve as documentation for your application's data structures. This makes it easier for new developers to understand how data flows through your system.

### 4. Better Error Messages

By combining error information from both validation layers, you can provide more contextual and detailed error messages to users.

### 5. Schema Evolution

As your application evolves, you can update your schemas and have those changes automatically reflected in your UI validation.

### 6. Code Generation

Auto-generate forms, validation rules, and other UI components based on your schemas, reducing boilerplate code.

### 7. Nested Validation

Handle complex nested data structures consistently across your application.

## Implementation Roadmap

1. **Phase 1: Core Integration**
   - Create the SchemaTypeExtractor
   - Build the FlintLiveIntegration module
   - Develop basic integration tests

2. **Phase 2: Enhanced Integration**
   - Implement SchemaEnforcedSocket
   - Create auto-generated forms
   - Develop multi-step form support

3. **Phase 3: Debug and Developer Experience**
   - Integrate with Debug Grid
   - Add schema visualization
   - Develop real-time validation feedback

4. **Phase 4: Client-Side Integration**
   - Generate JavaScript validation code
   - Add real-time client-side validation
   - Create bidirectional schema synchronization

## Conclusion

Integrating BaseLive with Flint creates a powerful validation pipeline from your data schemas to your LiveView UI. This approach ensures type safety, reduces code duplication, and makes your application more maintainable. By leveraging the strengths of both libraries, you can create a more robust and developer-friendly application. 

## References

- [Project Documentation](../README.md)
