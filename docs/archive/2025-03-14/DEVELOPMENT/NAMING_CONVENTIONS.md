---
title: Hydepwns Naming Conventions
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - development
  - hydepwns-naming-conventions
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - file-naming-conventions
  - module-naming-conventions
  - css-class-naming
  - javascript-naming-conventions
  - directory-structure-naming
  - implementation-plan
  - exceptions
  - enforcement
  - references
  - code-examples
  - testing
last_updated: '2025-03-14'
---
# Hydepwns Naming Conventions

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

# Hydepwns Naming Conventions


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document defines the naming conventions for all files and components in the Hydepwns project. Following these conventions ensures consistency across the codebase and improves maintainability.

## File Naming Conventions

### Elixir Files

| File Type | Naming Convention | Example |
|-----------|-------------------|---------|
| LiveView modules | `PascalCase` with `_live.ex` suffix | `UserDashboardLive.ex` |
| Component modules | `snake_case` with `_component.ex` suffix | `notification_component.ex` |
| Core modules | `snake_case.ex` | `socket_validator.ex` |
| Context modules | `PascalCase.ex` | `Accounts.ex` |
| Schema modules | `PascalCase.ex` | `User.ex` |
| Test files | Same as source file with `_test.exs` suffix | `user_dashboard_live_test.exs` |

#### Incorrect Examples

- `userDashboard.ex` - Uses camelCase instead of PascalCase or snake_case
- `NotificationComponent.ex` - Should use snake_case for component files
- `live_view.ex` - Too generic, doesn't follow naming convention for LiveView

### CSS/SCSS Files

| File Type | Naming Convention | Example |
|-----------|-------------------|---------|
| Component styles | `snake_case.scss` matching component name | `notification_component.scss` |
| Layout styles | `snake_case.scss` | `main_layout.scss` |
| Page-specific styles | `snake_case.scss` | `user_dashboard.scss` |
| Utility styles | `snake_case.scss` | `animations.scss` |
| Theme files | `snake_case.scss` | `dark_theme.scss` |

### JavaScript Files

| File Type | Naming Convention | Example |
|-----------|-------------------|---------|
| Hook files | `snake_case_hooks.js` | `notification_hooks.js` |
| Utility JS | `snake_case.js` | `form_helpers.js` |
| Component JS | Match component name with `snake_case.js` | `terminal_component.js` |
| Entry point files | `snake_case.js` | `app.js` |

## Module Naming Conventions

### Elixir Module Names

| Module Type | Naming Convention | Example |
|-------------|-------------------|---------|
| LiveView modules | `HydepwnsLiveviewWeb.ModuleNameLive` | `HydepwnsLiveviewWeb.UserDashboardLive` |
| Component modules | `HydepwnsLiveviewWeb.Components.ModuleName` | `HydepwnsLiveviewWeb.Components.Notification` |
| Context modules | `HydepwnsLiveview.ContextName` | `HydepwnsLiveview.Accounts` |
| Schema modules | `HydepwnsLiveview.ContextName.SchemaName` | `HydepwnsLiveview.Accounts.User` |

## CSS Class Naming

We follow a modified BEM (Block, Element, Modifier) methodology:

```css
/* Block component */
.card { }

/* Element that depends upon the block */
.card__title { }
.card__image { }

/* Modifier that changes the style of the block */
.card--featured { }
.card--dark { }
```markdown

### Examples

```scss
// Good
.user-profile { }
.user-profile__avatar { }
.user-profile--premium { }

// Bad
.userProfile { } // camelCase not allowed
.user_profile { } // Underscores not allowed for class names
.up-avatar { } // Not descriptive enough
```markdown

## JavaScript Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variables | camelCase | `let userData = {};` |
| Constants | UPPER_SNAKE_CASE | `const MAX_ATTEMPTS = 3;` |
| Functions | camelCase | `function validateForm() {}` |
| Classes | PascalCase | `class UserProfile {}` |
| Hooks | PascalCase | `const NotificationHook = {}` |

## Directory Structure Naming

| Directory | Naming Convention | Example |
|-----------|-------------------|---------|
| Component directories | snake_case | `lib/hydepwns_liveview_web/components/notification` |
| Context directories | snake_case | `lib/hydepwns_liveview/accounts` |
| Asset directories | snake_case | `assets/css/components` |
| Test directories | snake_case | `test/hydepwns_liveview_web/live` |

## Implementation Plan

1. Audit the codebase for files not following these conventions
2. Rename files to follow conventions
3. Update all references to renamed files
4. Add CI checks to ensure new files follow conventions

## Exceptions

- `mix.exs` and `mix.lock` follow their own conventions
- Files in `deps/` directory follow their project conventions
- Third-party libraries and assets maintain their original naming

## Enforcement

These naming conventions will be enforced through:

1. Code review process
2. CI checks where applicable
3. Documentation and onboarding materials 

## References

- [Project Documentation](../README.md)
