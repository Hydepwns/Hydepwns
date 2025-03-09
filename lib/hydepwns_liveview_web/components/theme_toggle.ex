defmodule HydepwnsLiveviewWeb.Components.ThemeToggle do
  @moduledoc """
  Provides a theme toggle component for switching between light, dark, and dim themes.
  
  This component renders a set of buttons that dispatch theme change events using JavaScript.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  
  @doc """
  Renders a theme toggle component with buttons for different themes.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="theme-toggle">
      <button id="light-theme" phx-click={JS.dispatch("theme-set", detail: %{theme: "light-theme"})}>⬜️</button>
      <button id="dim-theme" phx-click={JS.dispatch("theme-set", detail: %{theme: "dim-theme"})}>🟪</button>
      <button id="dark-theme" phx-click={JS.dispatch("theme-set", detail: %{theme: "dark-theme"})}>⬛️</button>
    </div>
    """
  end
end 