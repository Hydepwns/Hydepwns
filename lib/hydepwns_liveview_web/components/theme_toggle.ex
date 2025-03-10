defmodule HydepwnsLiveviewWeb.Components.ThemeToggle do
  @moduledoc """
  Provides a theme toggle component for switching between light, dark, and dim themes.
  
  This component renders a set of buttons that send theme change events to the parent LiveView
  via phx-click events using JS.push. The parent LiveView should implement a "change_theme" 
  event handler to process these events.
  
  The component is also connected to a JavaScript hook ("ThemeToggle") that handles
  theme persistence in localStorage and applies theme changes to the DOM.
  
  Keyboard shortcuts available:
  - Shift+Up/Right: Next theme
  - Shift+Down/Left: Previous theme
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  
  @doc """
  Renders a theme toggle component with buttons for different themes.
  
  Each button is assigned a data-theme attribute and triggers a "change_theme" event
  with the appropriate theme value when clicked.
  
  ## Examples
      <ThemeToggle.theme_toggle />
  """
  def theme_toggle(assigns) do
    ~H"""
    <div id="theme-toggle" class="theme-toggle" phx-hook="ThemeToggle" role="group" aria-label="Theme selection">
      <span class="theme-toggle-label" id="theme-source-indicator">Theme</span>
      <button 
        id="light-theme" 
        data-theme="light" 
        phx-click={JS.push("change_theme", value: %{theme: "light"})}
        aria-label="light"
        title="light (Shift+Up/Right)"
        >⬜️<span class="sr-only">Light</span></button>
      <button 
        id="dim-theme" 
        data-theme="dim" 
        phx-click={JS.push("change_theme", value: %{theme: "dim"})}
        aria-label="dim" 
        title="dim (Shift+Up/Right)"
        >🟪<span class="sr-only">Dim theme</span></button>
      <button 
        id="dark-theme" 
        data-theme="dark" 
        phx-click={JS.push("change_theme", value: %{theme: "dark"})}
        aria-label="dark"
        title="dark (Shift+Up/Right)"
        >⬛️<span class="sr-only">Dark theme</span></button>
    </div>
    """
  end
end 