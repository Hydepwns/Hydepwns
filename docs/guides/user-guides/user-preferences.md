---
title: User Preferences
description: Guide to customizing and managing user preferences in Hydepwns
topics:
  - user-guides
  - preferences
  - customization
  - settings
  - personalization
last_updated: '2025-03-14'
---

# User Preferences

## Overview

Hydepwns provides extensive customization options to tailor the application to your needs. This guide covers all available preferences and how to manage them.

## Preference Categories

### 1. Display Settings

```elixir
defmodule Hydepwns.Preferences.Display do
  def default_settings do
    %{
      theme: :system,
      font_size: :medium,
      contrast: :standard,
      reduce_motion: false,
      enable_animations: true
    }
  end

  def available_themes do
    [:system, :light, :dark, :high_contrast]
  end

  def font_sizes do
    [:small, :medium, :large, :x_large]
  end
end
```

### 2. Notification Preferences

```elixir
defmodule Hydepwns.Preferences.Notifications do
  def notification_settings do
    %{
      email: %{
        updates: true,
        security: true,
        marketing: false
      },
      in_app: %{
        mentions: true,
        comments: true,
        system: true
      },
      desktop: %{
        enabled: true,
        sound: true
      }
    }
  end
end
```

### 3. Keyboard Shortcuts

```elixir
defmodule Hydepwns.Preferences.Keyboard do
  def default_shortcuts do
    %{
      navigation: %{
        search: "/",
        home: "g h",
        dashboard: "g d"
      },
      actions: %{
        create: "c",
        edit: "e",
        delete: "d"
      }
    }
  end

  def custom_shortcuts do
    # Load user's custom shortcuts
  end
end
```

## Managing Preferences

### Storage and Persistence

```elixir
defmodule Hydepwns.Preferences.Storage do
  def save_preferences(user_id, preferences) do
    user = Repo.get!(User, user_id)
    
    user
    |> User.preferences_changeset(preferences)
    |> Repo.update()
  end

  def load_preferences(user_id) do
    user = Repo.get!(User, user_id)
    Map.merge(default_preferences(), user.preferences)
  end

  defp default_preferences do
    %{
      display: Display.default_settings(),
      notifications: Notifications.notification_settings(),
      keyboard: Keyboard.default_shortcuts()
    }
  end
end
```

### Synchronization

```elixir
defmodule Hydepwns.Preferences.Sync do
  def sync_preferences(socket, preferences) do
    Phoenix.PubSub.broadcast(
      Hydepwns.PubSub,
      "user:#{socket.assigns.user_id}",
      {:preferences_updated, preferences}
    )
  end

  def handle_info({:preferences_updated, preferences}, socket) do
    {:noreply, assign(socket, preferences: preferences)}
  end
end
```

## User Interface

### Preference Form

```elixir
def preference_form(assigns) do
  ~H"""
  <.form let={f} for={@changeset} phx-change="update_preferences">
    <.section_header>Display Settings</.section_header>
    
    <.form_field type="select" 
                 field={f[:theme]} 
                 options={Display.available_themes()} />
                 
    <.form_field type="select" 
                 field={f[:font_size]} 
                 options={Display.font_sizes()} />
                 
    <.form_field type="checkbox" 
                 field={f[:reduce_motion]} 
                 label="Reduce motion" />
                 
    <.section_header>Notification Settings</.section_header>
    
    <%= for {type, settings} <- f[:notifications].value do %>
      <.notification_settings type={type} settings={settings} />
    <% end %>
    
    <.section_header>Keyboard Shortcuts</.section_header>
    
    <.shortcut_editor shortcuts={f[:keyboard].value} />
    
    <.form_actions>
      <.button type="submit">Save Preferences</.button>
      <.button type="button" phx-click="reset_preferences">
        Reset to Defaults
      </.button>
    </.form_actions>
  </.form>
  """
end
```

### Live Updates

```elixir
defmodule Hydepwns.PreferencesLive do
  use HydepwnsWeb, :live_view

  def mount(_params, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(
        Hydepwns.PubSub,
        "user:#{session.user_id}"
      )
    end

    preferences = Storage.load_preferences(session.user_id)
    
    {:ok, assign(socket, preferences: preferences)}
  end

  def handle_event("update_preferences", %{"preferences" => params}, socket) do
    case Storage.save_preferences(socket.assigns.user_id, params) do
      {:ok, preferences} ->
        Sync.sync_preferences(socket, preferences)
        {:noreply, put_flash(socket, :info, "Preferences updated")}
        
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
```

## Best Practices

### 1. Preference Organization

- Group related settings
- Use clear labels
- Provide descriptions
- Show default values

### 2. Validation

- Validate input
- Prevent conflicts
- Handle errors
- Provide feedback

### 3. Performance

- Cache preferences
- Batch updates
- Optimize queries
- Handle timeouts

### 4. Security

- Validate permissions
- Sanitize input
- Audit changes
- Secure storage

## Migration and Backup

### Export Preferences

```elixir
def export_preferences(user_id) do
  preferences = Storage.load_preferences(user_id)
  
  Jason.encode!(preferences, pretty: true)
end
```

### Import Preferences

```elixir
def import_preferences(user_id, data) do
  with {:ok, preferences} <- Jason.decode(data),
       {:ok, _} <- validate_preferences(preferences) do
    Storage.save_preferences(user_id, preferences)
  end
end
```

## Troubleshooting

### Common Issues

1. **Preferences Not Saving**
   - Check permissions
   - Verify storage
   - Check validation
   - Clear cache

2. **Sync Problems**
   - Check connection
   - Verify PubSub
   - Check payload
   - Retry logic

## References

- [Accessibility Guidelines](accessibility.md)
- [Theme System](../../reference/features/theme-system.md)
- [User Settings API](../../reference/api/settings.md)
- [Storage Guide](../../reference/guides/storage.md) 