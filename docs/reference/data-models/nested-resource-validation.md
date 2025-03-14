---
title: Nested-Resource-Validation
description: >-
  ---

  title: Nested Resource Validation

  description: A comprehensive system for validating resources in the context of
  their relationships and managing complex validation dependencies

  category: reference

  subcategory: data-models

  order: 3

  last_updated: 2024-04-20

  contributors: 
    - backend_team
    - documentation_team
  status: active

  tags:
    - validation
    - resources
    - data-models
    - dependencies
  ---
topics:
  - reference
  - data-models
  - nested-resource-validation
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - key-features
  - implementation
  - resolve-validation-dependencies
  - visualize-the-dependency-graph-as-text
  - visualize-as-graphviz-dot-for-external-visualization-tools
  - analyzing-dependencies
  - analyze-dependencies-for-a-specific-validation
  - >-
    the-analysis-includes-direct-dependencies-reverse-dependencies-and-dependency-chains
  - detecting-and-fixing-circular-dependencies
  - detect-circular-dependencies
  - validating-related-resources
  - validate-a-resource-and-all-its-related-resources-with-context
  - validate-with-specific-validation-rules
  - validation-dependency-resolution
  - resolve-validation-dependencies-for-a-resource
  - execute-validations-in-the-correct-order
  - error-reporting-and-visualization
  - validate-a-resource-and-collect-errors
  - create-an-error-report
  - get-errors-for-a-specific-path
  - format-errors-for-display
  - ui-components
  - architecture
  - best-practices
  - integration-with-other-systems
  - performance-considerations
  - future-enhancements
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Nested-Resource-Validation

---
title: Nested Resource Validation
description: A comprehensive system for validating resources in the context of their relationships and managing complex validation dependencies
category: reference
subcategory: data-models
order: 3
last_updated: 2024-04-20
contributors: 
  - backend_team
  - documentation_team
status: active
tags:
  - validation
  - resources
  - data-models
  - dependencies
---


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

# Nested-Resource-Validation

---
title: Nested Resource Validation
description: A comprehensive system for validating resources in the context of their relationships and managing complex validation dependencies
category: reference
subcategory: data-models
order: 3
last_updated: 2024-04-20
contributors: 
  - backend_team
  - documentation_team
status: active
tags:
  - validation
  - resources
  - data-models
  - dependencies
---

# Nested Resource Validation

## Overview

The Nested Resource Validation system provides a comprehensive set of tools for validating resources in the context of their relationships. This system extends the resource management capabilities by adding support for complex validation scenarios that span multiple related resources.

## Key Features

- **Context-aware Validation**: Validate resources in the context of their relationships
  - Propagate validation context between related resources
  - Define parent-child validation rules
  - Implement cross-resource validation patterns
- **Validation Dependency Graph**: Manage complex validation dependencies
  - Automatically determine optimal validation order
  - Detect circular dependencies
  - Support for validation checkpointing
  - Visualize dependency relationships
  - Analyze and fix circular dependencies
- **Hierarchical Error Reporting**: Clear and navigable error reporting
  - Organize errors by resource and relationship
  - Navigate errors using path expressions
  - Visualize errors in multiple formats

## Implementation

### Declaring Validation Dependencies

The system allows you to declare dependencies between validations using the `validation_depends_on` macro:

```elixir
defmodule MyApp.UserResource do
  use LiveviewUtils.LiveViewResource
  
  validations do
    validate :email_must_be_valid, fn resource ->
      if String.contains?(resource.email, "@") do
        :ok
      else
        {:error, "Email must contain @"}
      end
    end
    
    validate :role_permissions_valid, fn resource ->
      if resource.role == "admin" && Enum.empty?(resource.permissions) do
        {:error, "Admin users must have at least one permission"}
      else
        :ok
      end
    end
    
    # Define that this validation depends on the email_must_be_valid validation
    validation_depends_on :role_permissions_valid, [:email_must_be_valid]
  end
end
```markdown

### Advanced Dependency Resolution

The system now supports advanced dependency resolution with the following features:

#### Dependency Graph Visualization

You can visualize the validation dependency graph to better understand the relationships between validations:

```elixir
# Resolve validation dependencies
{:ok, validation_plan} = UserResource.resolve_validation_dependencies(user)

# Visualize the dependency graph as text
graph_text = ValidationDependencyResolver.visualize_dependency_graph(validation_plan)
IO.puts(graph_text)

# Visualize as GraphViz DOT for external visualization tools
dot_graph = ValidationDependencyResolver.visualize_dependency_graph(validation_plan, format: :dot)
File.write!("validation_graph.dot", dot_graph)
```markdown

## Analyzing Dependencies

You can analyze dependencies for a specific validation rule:

```elixir
# Analyze dependencies for a specific validation
analysis = ValidationDependencyResolver.analyze_dependencies(
  validation_plan, 
  {UserResource, :email_must_be_valid}
)

# The analysis includes direct dependencies, reverse dependencies, and dependency chains
IO.inspect(analysis.direct_dependencies, label: "Direct Dependencies")
IO.inspect(analysis.reverse_dependencies, label: "Reverse Dependencies")
IO.inspect(analysis.dependency_chain, label: "Dependency Chain")
```markdown

## Detecting and Fixing Circular Dependencies

The system can detect circular dependencies and provide mechanisms to fix them:

```elixir
# Detect circular dependencies
cycles = ValidationDependencyResolver.detect_circular_dependencies(validation_plan)

if Enum.empty?(cycles) do
  IO.puts("No circular dependencies detected")
else
  IO.puts("Circular dependencies detected:")
  Enum.each(cycles, fn cycle ->
    cycle_str = Enum.map_join(cycle, " -> ", fn {module, rule} -> 
      "#{inspect(module)}.#{rule}"
    end)
    IO.puts("  #{cycle_str} -> #{elem(hd(cycle), 0)}.#{elem(hd(cycle), 1)}")
  end)
  
  # Fix circular dependencies automatically
  {:ok, fixed_plan} = ValidationDependencyResolver.fix_circular_dependencies(validation_plan)
  
  # You can also specify a strategy and priorities for fixing
  priorities = [
    {UserResource, :email_must_be_valid},
    {TeamResource, :name_valid}
  ]
  
  {:ok, fixed_plan} = ValidationDependencyResolver.fix_circular_dependencies(
    validation_plan,
    strategy: :prioritize_order,
    priorities: priorities
  )
end
```markdown

## Validating Related Resources

You can define validations that operate on related resources using the `validate_related` macro:

```elixir
defmodule MyApp.UserResource do
  use LiveviewUtils.LiveViewResource
  
  validations do
    validate_related :team, :max_members_not_exceeded, fn team ->
      if team.max_members && length(team.members) > team.max_members do
        {:error, "Team exceeds maximum member count"}
      else
        :ok
      end
    end
  end
end
```markdown

### Context-Aware Validation

The system provides deep validation capabilities that propagate context between related resources:

```elixir
# Validate a resource and all its related resources with context
{:ok, _} = UserResource.validate_deep(user, context: %{allowed_roles: ["admin", "editor"]})

# Validate with specific validation rules
{:ok, _} = UserResource.validate_with_rules(user, rules: [:team_member_role, :access_permissions])
```markdown

## Validation Dependency Resolution

The system automatically resolves validation dependencies to determine the optimal validation order:

```elixir
# Resolve validation dependencies for a resource
{:ok, validation_plan} = UserResource.resolve_validation_dependencies()

# Execute validations in the correct order
{:ok, validation_results} = UserResource.execute_validation_plan(validation_plan, user)
```markdown

## Error Reporting and Visualization

The system provides comprehensive error reporting and visualization capabilities:

```elixir
# Validate a resource and collect errors
{:error, errors} = UserResource.validate_deep(user)

# Create an error report
error_report = ValidationErrorReporter.create_error_report(errors)

# Get errors for a specific path
team_errors = ValidationErrorReporter.get_errors_at_path(error_report, "team")

# Format errors for display
html = ValidationErrorReporter.format_errors_as_html(error_report)
json = ValidationErrorReporter.format_errors_as_json(error_report)
```markdown

## UI Components

### Validation Errors Viewer

The system includes a LiveView component for visualizing validation errors:

```heex
<.validation_errors_viewer
  resource={@user}
  errors={@validation_errors}
  show_nested={true}
  max_depth={3}
  view_mode="tree"
/>
```markdown

### Error Path Navigation

You can also display errors for a specific path in the resource hierarchy:

```heex
<.validation_errors_at_path
  resource={@user}
  errors={@validation_errors}
  path="team.members.0"
/>
```markdown

## Architecture

The Nested Resource Validation system consists of several components:

1. **ContextValidation**: Provides validation with context propagation and support for nested resources.
2. **ValidationDependencyResolver**: Manages validation dependencies and determines execution order.
3. **ValidationErrorReporter**: Organizes and presents validation errors in a hierarchical structure.
4. **ValidationErrorsViewer**: LiveView component for visualizing validation errors.
5. **LiveViewResource Extensions**: Macros and functions for defining validation dependencies.

## Best Practices

### Defining Validation Dependencies

- Group related validations with clear dependencies
- Avoid circular dependencies between validations
- Use validation dependencies to ensure validations run in the correct order

### Handling Validation Context

- Use context to pass information between validations
- Include relevant parent information in the context for child validations
- Keep context data structures simple and serializable

### Error Reporting

- Provide clear error messages that guide users toward resolution
- Use path-based error navigation for complex nested structures
- Consider the end-user experience when formatting validation errors

## Integration with Other Systems

The Nested Resource Validation system integrates with several other components:

1. **Resource System**: Leverages the resource system for relationship management
2. **LiveView Framework**: Provides LiveView components for error visualization
3. **Transformation Pipeline**: Can validate resources during transformation
4. **Documentation System**: Self-documenting validation rules with metadata

## Performance Considerations

When working with deeply nested resources and complex validation rules, consider these performance guidelines:

1. **Lazy Validation**: Only validate required parts of the resource tree
2. **Caching Validation Results**: Cache validation results for unchanged resources
3. **Validation Batching**: Group validations to minimize database queries
4. **Optimizing Dependency Resolution**: Pre-compute validation dependencies when possible

## Future Enhancements

The Nested Resource Validation system will be enhanced with these planned features:

1. **Validation Rule Library**: Reusable validation rules across resources
2. **Custom Validation Strategies**: Domain-specific validation strategies
3. **Validation Profiles**: Apply different validation rules based on context
4. **Real-time Validation Feedback**: Immediate validation feedback during editing 

## References

- [Project Documentation](../README.md)
