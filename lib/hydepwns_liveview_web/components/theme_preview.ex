defmodule HydepwnsLiveviewWeb.Components.ThemePreview do
  @moduledoc """
  Provides a theme preview component that allows users to see all available themes
  without changing their current theme.
  
  This component shows visual examples of each theme's color scheme and
  can be used in documentation or settings pages.
  """
  use Phoenix.Component
  
  @doc """
  Renders a theme preview component showing all available themes.
  
  ## Examples
      <ThemePreview.theme_previews />
  """
  def theme_previews(assigns) do
    ~H"""
    <div class="theme-previews">
      <h3 class="theme-previews-title">Available Themes</h3>
      <div class="theme-preview-grid">
        <.theme_preview_card theme="light" title="Light Theme" />
        <.theme_preview_card theme="dark" title="Dark Theme" />
        <.theme_preview_card theme="dim" title="Dim Theme" />
      </div>
    </div>
    """
  end
  
  @doc """
  Renders a preview card for a specific theme.
  
  ## Examples
      <ThemePreview.theme_preview_card theme="dark" title="Dark Theme" />
  """
  def theme_preview_card(assigns) do
    ~H"""
    <div class={"theme-preview-card #{@theme}-theme-preview"}>
      <h4 class="theme-preview-title"><%= @title %></h4>
      <div class="theme-preview-content">
        <div class="theme-preview-text">
          <p>Sample text</p>
          <a href="#" class="theme-preview-link">Link example</a>
        </div>
        <div class="theme-preview-elements">
          <button class="theme-preview-button">Button</button>
          <div class="theme-preview-box"></div>
        </div>
      </div>
    </div>
    """
  end
end 