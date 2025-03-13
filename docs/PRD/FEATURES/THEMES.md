# Theme System

## Overview

The Theme System is a core part of the Hydepwns application, providing users with the ability to customize their viewing experience. The system supports multiple themes (light, dark, dim) with persistent preferences.

This document describes the themes system architecture, implementation details, and usage guidelines after recent consolidation efforts.

## Consolidated Architecture

The Theme System has been recently consolidated to improve maintainability and organization. The new structure follows a more coherent pattern:

### Directory Structure

```
lib/hydepwns_liveview/
├── theme_system/
│   ├── models/
│   │   └── theme.ex      # Core Theme model
│   └── components/       # Theme-related components
└── theme_system.ex       # Main context module
```

### Key Components

1. **ThemeSystem Module**: The main context module that provides functions for managing themes.
2. **Models.Theme**: The consolidated schema representing a theme with validations.
3. **Legacy Components**: For backward compatibility, the system maintains facade modules that delegate to the new consolidated components.

## Implementation Details

### Theme Model

The Theme model represents a theme with the following attributes:

- `name`: A unique identifier for the theme (e.g., "dark", "light", "dim")
- `mode`: The theme mode (one of "light", "dark", "dim", "system")
- `colors`: A map of color definitions specific to the theme
- `is_default`: Whether this theme is the system default
- `settings`: Additional theme-specific settings

### Theme System Context

The ThemeSystem context provides functions for managing themes:

- `list_themes/0`: Retrieves all available themes
- `get_theme!/1`: Gets a theme by ID
- `get_theme_by_name/1`: Gets a theme by name
- `get_default_theme/0`: Gets the default theme
- `create_theme/1`: Creates a new theme
- `update_theme/2`: Updates an existing theme
- `delete_theme/1`: Deletes a theme
- `set_default_theme/1`: Sets a theme as the default

## Integration with LiveView

The Theme System integrates with Phoenix LiveView to provide a seamless user experience:

1. **Theme Selection**: Users can select their preferred theme through UI controls
2. **Theme Persistence**: Selected themes are stored in browser localStorage
3. **System Preference Detection**: The system can detect and apply the user's system preference
4. **Real-time Updates**: Theme changes are applied without page reloads

## Legacy Support

For backward compatibility, the system maintains facades for legacy code:

- `HydepwnsLiveview.Themes`: Delegates to `ThemeSystem` with deprecation warnings
- `HydepwnsLiveview.Themes.Theme`: Delegates to `ThemeSystem.Models.Theme`

These facades ensure that existing code continues to work while encouraging migration to the new, consolidated API.

## Usage Examples

### Creating a Theme

```elixir
alias HydepwnsLiveview.ThemeSystem

{:ok, theme} = ThemeSystem.create_theme(%{
  name: "custom_dark",
  mode: "dark",
  colors: %{
    primary: "#3498db",
    secondary: "#2ecc71",
    background: "#121212",
    text: "#ffffff"
  }
})
```

### Setting a Default Theme

```elixir
theme = ThemeSystem.get_theme_by_name("dark")
{:ok, updated_theme} = ThemeSystem.set_default_theme(theme)
```

### Using Themes in Templates

```elixir
<div class={"app-container #{@theme.mode}-theme"}>
  <!-- Content -->
</div>
```

## Relationship to Other Systems

The Theme System interacts with:

- **LiveView Components**: Theme information is passed to components
- **User Preferences**: User theme selections are stored as preferences
- **Accessibility System**: Themes support high contrast mode for accessibility

## Migration Path

Projects using the old theme system structure should:

1. Replace `HydepwnsLiveview.Themes` with `HydepwnsLiveview.ThemeSystem`
2. Replace `HydepwnsLiveview.Themes.Theme` with `HydepwnsLiveview.ThemeSystem.Models.Theme`
3. Update any direct database queries to use the ThemeSystem context functions

## Future Enhancements

Planned enhancements to the Theme System include:

1. **Custom Theme Builder**: UI for creating and sharing custom themes
2. **Theme Export/Import**: Ability to export and import themes
3. **Component-Level Theming**: More granular theme controls for specific components
4. **Animation Settings**: Theme-specific animation preferences
