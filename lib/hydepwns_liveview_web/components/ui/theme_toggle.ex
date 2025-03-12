defmodule HydepwnsLiveviewWeb.Components.UI.ThemeToggle do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  alias HydepwnsLiveview.Themes

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
  See `assets/js/hooks/theme_toggle.js` for the implementation details.

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
      case Themes.list_themes() do
        [] ->
          [
            %{name: "light", mode: "light", is_default: true},
            %{name: "dark", mode: "dark", is_default: false},
            %{name: "system", mode: "system", is_default: false}
          ]

        db_themes ->
          db_themes
      end

    assigns = assign(assigns, :themes, themes)

    ~H"""
    <div id={@id} class={["theme-toggle", @class]} phx-hook="ThemeToggle" {@rest} role="group" aria-label={@aria_label}>
      <%= for theme <- @themes do %>
        <button
          id={"#{theme.name}-theme-button"}
          data-theme={theme.name}
          phx-click={JS.dispatch("theme-set", detail: %{theme: "#{theme.name}-theme"})}
          aria-label={"#{String.capitalize(theme.name)} theme"}
          title={"#{String.capitalize(theme.name)} theme"}
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
          <span class="theme-label">{String.capitalize(theme.name)}</span>
        </button>
      <% end %>
    </div>
    """
  end
end
