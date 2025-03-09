defmodule HydepwnsLiveviewWeb.Components.UI.ThemeToggle do
  use Phoenix.Component

  @moduledoc """
  Advanced theme toggle UI component for switching between application themes.
  
  Provides a more sophisticated version of the theme toggle with additional styling
  and functionality compared to the basic ThemeToggle component.
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
        phx-click="change_theme"
        phx-value-theme="light"
        aria-label="Switch to light theme"
        data-theme="light"
        title="Light theme"
        aria-pressed="false"
        type="button"
      >
        □
      </button>
      <button
        phx-click="change_theme"
        phx-value-theme="dark"
        aria-label="Switch to dark theme"
        data-theme="dark"
        title="Dark theme"
        aria-pressed="false"
        type="button"
      >
        ■
      </button>
      <button
        phx-click="change_theme"
        phx-value-theme="dim"
        aria-label="Switch to dim theme"
        data-theme="dim"
        title="Dim theme"
        aria-pressed="false"
        type="button"
      >
        ▣
      </button>
    </div>
    """
  end
end 