---
title: Transformation Cookbook
description: '## Overview'
topics:
  - development
  - components
  - transformation-cookbook
  - overview
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - table-of-contents
  - introduction
  - transformation-patterns
  - error-handling-patterns
  - performance-optimization
  - testing-strategies
  - best-practices
  - common-pitfalls
  - related-documentation
  - references
  - code-examples
  - testing
  - architecture
last_updated: '2025-03-14'
---
# Transformation Cookbook

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

This document provides information about Transformation-Cookbook.


This document provides example transformations, patterns, and best practices for using the Resource Transformation Pipeline in Hydepwns.

## Table of Contents

1. [Introduction](#introduction)
2. [Transformation Patterns](#transformation-patterns)
   - [Basic Field Normalization](#basic-field-normalization)
   - [Data Enrichment](#data-enrichment)
   - [Conditional Transformations](#conditional-transformations)
   - [Conflict Resolution](#conflict-resolution)
   - [Validation Transformations](#validation-transformations)
   - [Multi-field Transformations](#multi-field-transformations)
   - [Cascading Transformations](#cascading-transformations)
3. [Error Handling Patterns](#error-handling-patterns)
4. [Performance Optimization](#performance-optimization)
5. [Testing Strategies](#testing-strategies)
6. [Best Practices](#best-practices)
7. [Common Pitfalls](#common-pitfalls)

## Introduction

The Resource Transformation Pipeline provides a flexible way to apply transformations to resources during various lifecycle stages. This cookbook demonstrates common patterns and best practices for creating and applying transformations.

## Transformation Patterns

### Basic Field Normalization

**Use case**: Ensuring consistent formatting of fields without complex logic.

**Example**: Normalizing an email address to lowercase

```elixir
defmodule MyApp.Transformations.NormalizeEmail do
  use HydepwnsLiveview.Utils.Transformation

  @impl true
  def transform(resource, _context) do
    if Map.has_key?(resource, :email) && resource.email do
      # Normalize email to lowercase
      email = String.downcase(resource.email)
      {:ok, %{resource | email: email}}
    else
      # No email field or nil email, return unchanged
      {:ok, resource}
    end
  end

  @impl true
  def applicable?(resource, _context) do
    Map.has_key?(resource, :email) && resource.email != nil
  end
end
```markdown

### Data Enrichment

**Use case**: Adding computed or derived fields to a resource.

**Example**: Adding a slug from a title

```elixir
defmodule MyApp.Transformations.GenerateSlug do
  use HydepwnsLiveview.Utils.Transformation

  @impl true
  def transform(resource, _context) do
    slug = resource.title
           |> String.downcase()
           |> String.replace(~r/[^a-z0-9\s-]/, "")
           |> String.replace(~r/\s+/, "-")
           |> String.trim("-")

    {:ok, Map.put(resource, :slug, slug)}
  end

  @impl true
  def applicable?(resource, _context) do
    Map.has_key?(resource, :title) && 
    resource.title != nil && 
    resource.title != "" &&
    (!Map.has_key?(resource, :slug) || resource.slug == nil || resource.slug == "")
  end
end
```markdown

### Conditional Transformations

**Use case**: Applying transformations only under specific conditions.

**Example**: Adding a default role only for new users

```elixir
defmodule MyApp.Transformations.AssignDefaultRole do
  use HydepwnsLiveview.Utils.Transformation

  @impl true
  def transform(resource, context) do
    # Only apply for new resources (those without an ID)
    {:ok, Map.put(resource, :role, "user")}
  end

  @impl true
  def applicable?(resource, context) do
    # Check if this is a new resource (no ID yet)
    !Map.has_key?(resource, :id) && !Map.has_key?(resource, :role)
  end
end
```markdown

### Conflict Resolution

**Use case**: Handling potential conflicts when generating data.

**Example**: Ensuring unique usernames

```elixir
defmodule MyApp.Transformations.EnsureUniqueUsername do
  use HydepwnsLiveview.Utils.Transformation

  @impl true
  def transform(resource, context) do
    # Generate a username from the name
    username = generate_username_from_name(resource.name)

    # Check for conflicts if a conflict checker is provided
    username =
      if context[:username_exists?] do
        ensure_unique_username(username, context[:username_exists?])
      else
        username
      end

    # Return the transformed resource
    {:ok, Map.put(resource, :username, username)}
  end

  # Ensure the username is unique by appending a number if needed
  defp ensure_unique_username(username, exists_fn) do
    if exists_fn.(username) do
      # Try adding incrementing numbers until we find a unique username
      Stream.iterate(1, &(&1 + 1))
      |> Enum.reduce_while(username, fn i, username ->
        candidate = "#{username}#{i}"

        if exists_fn.(candidate) do
          {:cont, username}
        else
          {:halt, candidate}
        end
      end)
    else
      username
    end
  end

  # Generate a username from a name
  defp generate_username_from_name(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]/, "")
  end
end
```markdown

### Validation Transformations

**Use case**: Validating data as part of the transformation pipeline.

**Example**: Validating email format

```elixir
defmodule MyApp.Transformations.ValidateEmail do
  use HydepwnsLiveview.Utils.Transformation

  @email_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/

  @impl true
  def transform(resource, _context) do
    if Regex.match?(@email_regex, resource.email) do
      {:ok, resource}
    else
      {:error, "Invalid email format"}
    end
  end

  @impl true
  def applicable?(resource, _context) do
    Map.has_key?(resource, :email) && resource.email != nil
  end
end
```markdown

### Multi-field Transformations

**Use case**: Transformations that affect multiple fields at once.

**Example**: Setting full_name based on first_name and last_name

```elixir
defmodule MyApp.Transformations.GenerateFullName do
  use HydepwnsLiveview.Utils.Transformation

  @impl true
  def transform(resource, _context) do
    full_name = "#{resource.first_name} #{resource.last_name}" |> String.trim()
    {:ok, Map.put(resource, :full_name, full_name)}
  end

  @impl true
  def applicable?(resource, _context) do
    Map.has_key?(resource, :first_name) && 
    Map.has_key?(resource, :last_name) &&
    resource.first_name != nil &&
    resource.last_name != nil
  end
end
```markdown

### Cascading Transformations

**Use case**: Transformations that may trigger other transformations.

**Example**: Updating timestamps when specific fields change

```elixir
defmodule MyApp.Transformations.UpdateTimestamps do
  use HydepwnsLiveview.Utils.Transformation

  @tracked_fields [:title, :content, :status]

  @impl true
  def transform(resource, context) do
    now = DateTime.utc_now()
    
    resource = 
      if Map.has_key?(resource, :created_at) && resource.created_at do
        resource
      else
        # Set created_at for new resources
        Map.put(resource, :created_at, now)
      end
      
    # Always update updated_at
    resource = Map.put(resource, :updated_at, now)
    
    {:ok, resource}
  end

  @impl true
  def applicable?(resource, context) do
    # Check if this is a new resource or if tracked fields have changed
    !Map.has_key?(resource, :id) || 
    (context[:previous_resource] && fields_changed?(resource, context[:previous_resource]))
  end
  
  defp fields_changed?(current, previous) do
    Enum.any?(@tracked_fields, fn field ->
      Map.get(current, field) != Map.get(previous, field)
    end)
  end
end
```markdown

## Error Handling Patterns

### Transformation with Recovery

**Use case**: Handling potential errors with fallback behavior.

**Example**: Transforming a date with fallback

```elixir
defmodule MyApp.Transformations.ParsePublishedDate do
  use HydepwnsLiveview.Utils.Transformation

  @impl true
  def transform(resource, _context) do
    case parse_date(resource.published_date_string) do
      {:ok, date} ->
        # Successfully parsed date
        {:ok, Map.put(resource, :published_date, date)}
        
      {:error, _reason} ->
        # Failed to parse, use current date as fallback
        {:ok, Map.put(resource, :published_date, Date.utc_today())}
    end
  end
  
  defp parse_date(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> {:ok, date}
      error -> error
    end
  end
end
```markdown

### Strict Validation

**Use case**: Transformations that must fail on invalid data.

**Example**: Ensuring required fields are present

```elixir
defmodule MyApp.Transformations.ValidateRequiredFields do
  use HydepwnsLiveview.Utils.Transformation

  @required_fields [:title, :content, :author_id]

  @impl true
  def transform(resource, _context) do
    missing_fields = Enum.filter(@required_fields, fn field ->
      !Map.has_key?(resource, field) || is_nil(Map.get(resource, field))
    end)
    
    if Enum.empty?(missing_fields) do
      {:ok, resource}
    else
      fields = Enum.join(missing_fields, ", ")
      {:error, "Missing required fields: #{fields}"}
    end
  end
end
```markdown

## Performance Optimization

### Selective Field Processing

**Use case**: Optimizing performance by only processing what's needed.

**Example**: Only processing changed fields

```elixir
defmodule MyApp.Transformations.SelectiveProcessor do
  use HydepwnsLiveview.Utils.Transformation

  @impl true
  def transform(resource, context) do
    if context[:previous_resource] do
      # Process only changed fields
      changed_fields = get_changed_fields(resource, context[:previous_resource])
      
      if :title in changed_fields do
        # Do expensive title processing
        resource = process_title(resource)
      end
      
      if :content in changed_fields do
        # Do expensive content processing
        resource = process_content(resource)
      end
      
      {:ok, resource}
    else
      # New resource, process everything
      resource = process_title(resource)
      resource = process_content(resource)
      
      {:ok, resource}
    end
  end
  
  defp get_changed_fields(current, previous) do
    current
    |> Map.keys()
    |> Enum.filter(fn key -> Map.get(current, key) != Map.get(previous, key) end)
  end
  
  defp process_title(resource) do
    # Expensive title processing
    %{resource | title: String.trim(resource.title)}
  end
  
  defp process_content(resource) do
    # Expensive content processing
    %{resource | content: String.trim(resource.content)}
  end
end
```markdown

## Testing Strategies

### Unit Testing Transformations

```elixir
defmodule MyApp.Transformations.NormalizeEmailTest do
  use ExUnit.Case
  
  alias MyApp.Transformations.NormalizeEmail
  
  test "normalizes email to lowercase" do
    resource = %{email: "User@Example.COM"}
    
    assert {:ok, transformed} = NormalizeEmail.transform(resource, %{})
    assert transformed.email == "user@example.com"
  end
  
  test "ignores resources without email" do
    resource = %{name: "Test User"}
    
    assert {:ok, transformed} = NormalizeEmail.transform(resource, %{})
    assert transformed == resource
  end
  
  test "applicable? returns true for resources with email" do
    resource = %{email: "test@example.com"}
    assert NormalizeEmail.applicable?(resource, %{}) == true
  end
  
  test "applicable? returns false for resources without email" do
    resource = %{name: "Test User"}
    assert NormalizeEmail.applicable?(resource, %{}) == false
  end
end
```markdown

### Pipeline Integration Testing

```elixir
defmodule MyApp.TransformationPipelineTest do
  use ExUnit.Case
  
  alias HydepwnsLiveview.Utils.TransformationPipeline
  
  test "applies multiple transformations in sequence" do
    # Create a pipeline with multiple transformations
    pipeline = TransformationPipeline.new()
      |> TransformationPipeline.add(MyApp.Transformations.NormalizeEmail)
      |> TransformationPipeline.add(MyApp.Transformations.GenerateUsername)
      
    # Create a resource to transform
    resource = %{
      name: "John Doe",
      email: "John.Doe@Example.COM"
    }
    
    # Apply the pipeline
    {:ok, transformed} = TransformationPipeline.apply(pipeline, resource)
    
    # Check that all transformations were applied
    assert transformed.email == "john.doe@example.com"
    assert transformed.username == "johndoe"
  end
end
```markdown

## Best Practices

1. **Keep transformations focused**: Each transformation should do one thing well.

2. **Use the applicable? callback**: Instead of adding conditional logic inside transform/2, use the applicable?/2 callback to determine if a transformation should be applied.

3. **Handle missing fields gracefully**: Always check if fields exist before accessing them.

4. **Provide meaningful error messages**: When returning errors, include details about what went wrong.

5. **Document transformations thoroughly**: Use @moduledoc and @doc to explain what each transformation does.

6. **Use context for shared data**: Pass context between transformations when they need to share data.

7. **Set dependencies properly**: If transformations depend on each other, specify the dependencies to ensure correct ordering.

8. **Add metadata to transformations**: Use the info/0 callback to provide metadata about each transformation.

9. **Test all code paths**: Ensure that you have tests for all possible branches in your transformations.

10. **Consider performance implications**: Be mindful of expensive operations, especially in pipelines with many transformations.

## Common Pitfalls

1. **Mutating the context**: Transformations should treat the context as read-only unless explicitly designed to update it.

2. **Circular dependencies**: Be careful with dependencies to avoid circular references.

3. **Overly complex transformations**: Break down complex transformations into smaller, focused ones.

4. **Ignoring errors**: Always handle potential errors from functions that may fail.

5. **Poor performance**: Watch out for N+1 queries or other performance issues when accessing external data.

6. **Missing validation**: Don't assume input data is valid; either validate it or handle potential issues.

7. **Overusing transformations**: Not everything needs to be a transformation; use them judiciously.

8. **Hardcoding business logic**: Extract configurable elements to make transformations more reusable.

## Related Documentation

- [Component Guidelines](guidelines.md)
- [Component Patterns](patterns.md)
- [Resource System Architecture](../../reference/architecture/resource-system.md)
- [Transformation Pipeline Architecture](../../reference/architecture/transformation-pipeline.md) 

## References

- [Project Documentation](../README.md)
