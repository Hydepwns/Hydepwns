defmodule HydepwnsLiveviewWeb.Components.UI.ThemeToggle do
  use Phoenix.Component

  @moduledoc """
  Advanced theme toggle UI component for switching between application themes.

  This component provides a monospace-friendly theme toggle with keyboard accessibility
  and integration with system preferences. It uses localStorage to persist user preferences
  and applies themes via CSS variables.

  ## Features

  - Supports light, dark, and system themes
  - Persists theme selection in localStorage
  - Respects system preferences when no selection is made
  - Keyboard accessible with Shift+Arrow shortcuts
  - Live theme updates without page refresh
  - Monospace-compatible design using unicode characters
  - ARIA attributes for screen reader support
  - Database-backed themes for customization

  ## Implementation Notes

  The component relies on the ThemeToggle JavaScript hook for functionality.
  See `js/hooks/theme_toggle.js` for the implementation details.

  ## CSS Dependencies

  Requires theme CSS variables defined in `assets/css/themes/themes.scss`
  """

  @doc """
  Renders a theme toggle component for switching between available themes.

  ## Examples

      <.theme_toggle />
      <.theme_toggle class="large-toggle" />

  ## Attributes

  - `class` - Additional CSS classes to apply to the component
  - `rest` - Additional HTML attributes to apply to the component
  """
  attr :class, :string, default: nil
  attr :id, :string, default: "theme-toggle"
  attr :aria_label, :string, default: "Theme selector"
  attr :rest, :global

  def theme_toggle(assigns) do
    # Get themes from database or use defaults if none exist
    themes =
      case HydepwnsLiveview.ThemeSystem.list_themes() do
        [] ->
          [
            %{id: "light", name: "light", mode: "light", is_default: true},
            %{id: "dark", name: "dark", mode: "dark", is_default: false},
            %{id: "system", name: "system", mode: "system", is_default: false}
          ]

        db_themes ->
          db_themes
      end

    assigns = assign(assigns, :themes, themes)

    ~H"""
    <div id={@id} class={["theme-toggle", @class]} phx-hook="ThemeToggle" {@rest} role="group" aria-label={@aria_label}>
      <%= for theme <- @themes do %>
        <button
          id={"#{@id}-#{theme.name}-#{theme.id}-theme-button"}
          data-theme={theme.name}
          phx-click="change_theme"
          phx-value-theme={theme.name}
          phx-hook="ThemeToggle"
          aria-label={cond do
            theme.name == "light" -> "Light theme"
            theme.name == "dark" -> "Dark theme"
            theme.name == "system" -> "System theme"
            String.starts_with?(to_string(theme.name), "high-contrast") -> "High contrast theme"
            String.starts_with?(to_string(theme.name), "dim") -> "Dim theme"
            true -> "#{String.capitalize(to_string(theme.name))} theme"
          end}
          title={cond do
            theme.name == "light" -> "Light theme"
            theme.name == "dark" -> "Dark theme"
            theme.name == "system" -> "System theme"
            String.starts_with?(to_string(theme.name), "high-contrast") -> "High contrast theme"
            String.starts_with?(to_string(theme.name), "dim") -> "Dim theme"
            true -> "#{String.capitalize(to_string(theme.name))} theme"
          end}
          aria-pressed={if theme.is_default, do: "true", else: "false"}
          type="button"
          class={"theme-button #{theme.name}-button"}
        >
          <span class="theme-icon">
            <%= case theme.mode do %>
              <% "light" -> %>
                □
              <% "dark" -> %>
                ■
              <% "system" -> %>
                ▣
              <% _ -> %>
                □
            <% end %>
          </span>
          <span class="theme-label">
            {cond do
              theme.name == "light" -> "Light theme"
              theme.name == "dark" -> "Dark theme"
              theme.name == "system" -> "System theme"
              String.starts_with?(to_string(theme.name), "high-contrast") -> "High contrast theme"
              String.starts_with?(to_string(theme.name), "dim") -> "Dim theme"
              true -> "#{String.capitalize(to_string(theme.name))} theme"
            end}
          </span>
        </button>
      <% end %>
    </div>
    """
  end
end
