# Codebase Consistency Guide

## Overview

This document outlines identified inconsistencies in the Hydepwns codebase and provides guidance for maintaining consistency as the project evolves. By following these guidelines, we can ensure a more maintainable and cohesive codebase.

## Current Inconsistencies

### Theme System

#### Issue

The Theme System has undergone consolidation, but remnants of the old system still exist throughout the codebase:

- Multiple Theme models:
  - `HydepwnsLiveview.ThemeSystem.Models.Theme` (new consolidated model)
  - `HydepwnsLiveview.ThemeSystem.Theme` (older model)
  - `HydepwnsLiveview.Themes.Theme` (deprecated but still in use)

- Various pieces of code still reference the old modules:
  - `seeds.exs` - Uses the old `HydepwnsLiveview.Themes` module
  - `ThemeJSON` - References the deprecated `HydepwnsLiveview.Themes.Theme`

#### Migration Path

1. Replace all usages of `HydepwnsLiveview.Themes` with `HydepwnsLiveview.ThemeSystem`
2. Replace all usages of `HydepwnsLiveview.Themes.Theme` with `HydepwnsLiveview.ThemeSystem.Models.Theme`
3. Remove the old `HydepwnsLiveview.ThemeSystem.Theme` module after all references have been updated

### Resource Management System

#### Issue

Several components of the resource management system have duplicate implementations:

- `HydepwnsLiveview.Performance.ResourceOptimizer` and `HydepwnsLiveview.Resources.PerformanceOptimizer` have overlapping functionality
- Documentation describes advanced features that may be partially implemented or spread across multiple modules

#### Migration Path

1. Standardize on `HydepwnsLiveview.Resources.PerformanceOptimizer` for all resource optimization code
2. Mark other implementations as deprecated and provide delegation to the standard module
3. Update documentation to reflect the actual state of implementation

### Event System

#### Issue

The Event System implementation is spread across multiple modules with potential inconsistencies in naming and interfaces.

#### Recent Progress

As of the latest updates, significant progress has been made on standardizing the Event System:

- Fixed cyclic module dependencies by updating aliases and imports
- Corrected Event struct references by using fully qualified paths
- Standardized module references across the event system
- Implemented proper module imports to ensure consistent access to Event-related functionality
- Fixed various Event-related function implementations that were causing compilation errors

#### Remaining Work

1. Continue standardizing the Event System API in `HydepwnsLiveview.Events.*`
2. Document clear boundaries between modules and their responsibilities
3. Address remaining warnings related to unused variables and function calls

## Naming Conventions

To maintain consistency going forward, follow these naming conventions:

### Module Organization

- `HydepwnsLiveview.{Feature}` - Main context modules (e.g., `HydepwnsLiveview.ThemeSystem`)
- `HydepwnsLiveview.{Feature}.Models.{Model}` - Schema definitions (e.g., `HydepwnsLiveview.ThemeSystem.Models.Theme`)
- `HydepwnsLiveview.{Feature}.Utils.{Utility}` - Helper functions (e.g., `HydepwnsLiveview.ThemeSystem.Utils.ColorConverter`)
- `HydepwnsLiveviewWeb.{Feature}Live` - LiveView modules (e.g., `HydepwnsLiveviewWeb.ThemeSwitcherLive`)
- `HydepwnsLiveviewWeb.{Feature}Component` - LiveComponent modules (e.g., `HydepwnsLiveviewWeb.ThemePickerComponent`)

### File Organization

- Context modules: `lib/hydepwns_liveview/{feature}.ex`
- Schema definitions: `lib/hydepwns_liveview/{feature}/models/{model}.ex`
- Web modules: `lib/hydepwns_liveview_web/{controllers,live,components}/{module}.ex`

## Implementation Checklist

For each feature, ensure consistency by checking these items:

- [ ] Documentation matches implementation
- [ ] Tests cover the feature
- [ ] No duplicate implementations exist
- [ ] Clear deprecation notices for old code
- [ ] Migration path for users of deprecated code
- [ ] Follows naming conventions

## Ongoing Maintenance

To maintain consistency as the codebase evolves:

1. Regularly review the codebase for inconsistencies
2. Immediately mark deprecated code with `@deprecated` attributes
3. Update this document when new patterns are established
4. Run `mix xref graph --format dot` periodically to visualize module dependencies

## References

- [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- [Phoenix Best Practices](https://hexdocs.pm/phoenix/phoenix_mix_tasks.html)
- [Resource System Implementation](../RESOURCE_SYSTEM_IMPLEMENTATION.md)
- [Theme System Documentation](../FEATURES/THEMES.md)
