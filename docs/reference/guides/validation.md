---
title: Validation Guide
description: Comprehensive guide to the Hydepwns validation system
topics:
  - validation
  - guides
  - best-practices
  - error-handling
  - data-integrity
last_updated: '2025-03-14'
---

# Validation Guide

## Overview

The Hydepwns validation system provides a robust framework for ensuring data integrity and consistency across the application. This guide covers validation concepts, implementation patterns, and best practices.

## Core Concepts

### Validation Types

1. **Schema Validation**
   - Field types
   - Required fields
   - Default values
   - Custom types

2. **Business Rules**
   - Complex conditions
   - Cross-field validation
   - Dependency validation
   - Custom rules

3. **Relationship Validation**
   - Foreign key constraints
   - Circular dependencies
   - Cascading validation
   - Integrity checks

## Implementation

### Basic Validation

```elixir
defmodule Hydepwns.Resources.Project do
  use Hydepwns.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :description, :string
    field :status, :string
    field :priority, :integer
    
    timestamps()
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :status, :priority])
    |> validate_required([:name, :status])
    |> validate_length(:name, min: 3, max: 255)
    |> validate_inclusion(:status, ["active", "archived", "draft"])
    |> validate_number(:priority, greater_than: 0, less_than: 6)
  end
end
```

### Custom Validation

```elixir
def validate_dependencies(changeset) do
  changeset
  |> validate_change(:dependencies, fn _, dependencies ->
    case check_circular_dependencies(dependencies) do
      {:ok, _} -> []
      {:error, message} -> [dependencies: message]
    end
  end)
end
```

### Nested Validation

```elixir
def validate_nested_resources(changeset) do
  changeset
  |> cast_assoc(:components, with: &Component.changeset/2)
  |> cast_assoc(:configurations, with: &Configuration.changeset/2)
end
```

## Best Practices

### 1. Validation Organization

- Group related validations
- Use meaningful function names
- Document complex rules
- Keep functions focused

```elixir
defmodule Hydepwns.Validation.ProjectRules do
  def validate_project_rules(changeset) do
    changeset
    |> validate_basic_fields()
    |> validate_relationships()
    |> validate_business_rules()
  end

  defp validate_basic_fields(changeset) do
    # Basic field validation
  end

  defp validate_relationships(changeset) do
    # Relationship validation
  end

  defp validate_business_rules(changeset) do
    # Business rule validation
  end
end
```

### 2. Error Messages

- Clear and actionable
- Localization support
- Context-specific
- User-friendly

```elixir
def error_messages do
  %{
    name: %{
      required: "Name is required",
      too_short: "Name must be at least %{count} characters",
      too_long: "Name cannot exceed %{count} characters"
    },
    status: %{
      invalid: "Status must be one of: active, archived, draft"
    }
  }
end
```

### 3. Performance

- Validate early
- Cache validation rules
- Batch validations
- Optimize queries

```elixir
def validate_batch(resources) do
  resources
  |> Enum.chunk_every(100)
  |> Enum.map(&validate_chunk/1)
  |> Enum.flat_map(&(&1))
end
```

## Error Handling

### 1. Error Collection

```elixir
def collect_errors(changeset) do
  Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end)
end
```

### 2. Error Reporting

```elixir
def format_errors(errors) do
  errors
  |> Enum.map(fn {field, detail} ->
    %{
      field: field,
      message: detail,
      type: error_type(detail)
    }
  end)
end
```

## Real-time Validation

### Client-side Validation

```javascript
function validateField(field, value) {
  const rules = getValidationRules(field);
  return rules.reduce((errors, rule) => {
    const result = rule.validate(value);
    return result.valid ? errors : [...errors, result.error];
  }, []);
}
```

### Server Integration

```elixir
def validate_live(socket, params) do
  changeset =
    socket.assigns.resource
    |> Resource.changeset(params)
    |> Map.put(:action, :validate)

  {:noreply, assign(socket, changeset: changeset)}
end
```

## Testing

### Unit Tests

```elixir
defmodule Hydepwns.ValidationTest do
  use Hydepwns.DataCase

  test "validates required fields" do
    changeset = Project.changeset(%Project{}, %{})
    assert "can't be blank" in errors_on(changeset).name
  end

  test "validates field length" do
    changeset = Project.changeset(%Project{}, %{name: "a"})
    assert "should be at least 3 character(s)" in errors_on(changeset).name
  end
end
```

### Integration Tests

```elixir
defmodule Hydepwns.ValidationIntegrationTest do
  use Hydepwns.ConnCase

  test "validates complex business rules" do
    attrs = valid_project_attributes()
    conn = post(conn, Routes.project_path(conn, :create), project: attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end
end
```

## References

- [Resource Management](../features/resource-management.md)
- [API Documentation](../api/resources.md)
- [Error Handling Guide](error-handling.md)
- [Testing Guide](testing.md) 