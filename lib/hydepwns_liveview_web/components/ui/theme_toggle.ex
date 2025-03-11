defmodule HydepwnsLiveviewWeb.Components.UI.ThemeToggle do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @moduledoc """
  Advanced theme toggle UI component for switching between application themes.

  Provides a more sophisticated version of the theme toggle with additional styling
  and functionality compared to the basic ThemeToggle component.

  Supports keyboard shortcuts:
  - Shift+Up/Right: Next theme
  - Shift+Down/Left: Previous theme
  """

  @doc """
  Renders a theme toggle component for switching between light, dark, and dim themes.

  ## Example

      <.theme_toggle />
  """
  attr :class, :string, default: nil
  attr :rest, :global

  def theme_toggle(assigns) do
    ~H"""
    <div class={["theme-toggle", @class]} phx-hook="ThemeToggle" {@rest} aria-label="Theme toggles">
      <button
        id="light-theme"
        data-theme="light"
        phx-click={JS.dispatch("theme-set", detail: %{theme: "light-theme"})}
        aria-label="light"
        title="light (Shift+Arrow Keys)"
        aria-pressed="false"
        type="button"
      >
        □
      </button>
      <button
        id="dark-theme"
        data-theme="dark"
        phx-click={JS.dispatch("theme-set", detail: %{theme: "dark-theme"})}
        aria-label="dark"
        title="dark (Shift+Arrow Keys)"
        aria-pressed="false"
        type="button"
      >
        ■
      </button>
      <button
        id="dim-theme"
        data-theme="dim"
        phx-click={JS.dispatch("theme-set", detail: %{theme: "dim-theme"})}
        aria-label="dim"
        title="dim (Shift+Arrow Keys)"
        aria-pressed="false"
        type="button"
      >
        ▣
      </button>
    </div>
    """
  end
end
