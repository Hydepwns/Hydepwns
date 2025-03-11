defmodule HydepwnsLiveviewWeb.Components.StyleGuide do
  @moduledoc """
  Provides a comprehensive style guide showcasing all UI components.
  
  This component acts as a living documentation of the design system,
  displaying examples of all available components along with their usage.
  """
  use HydepwnsLiveviewWeb, :live_component

  alias HydepwnsLiveviewWeb.Components.MonoGrid
  alias HydepwnsLiveviewWeb.Components.Terminal
  alias HydepwnsLiveviewWeb.Components.AsciiArtGenerator
  alias HydepwnsLiveviewWeb.Components.DiagramEditor
  alias HydepwnsLiveviewWeb.Components.ThemeToggle
  alias HydepwnsLiveviewWeb.Components.ApiDocs

  @doc """
  Renders the style guide component.
  """
  def render(assigns) do
    ~H"""
    <div class="style-guide" id={@id}>
      <h1 class="style-guide-title">Hydepwns Monospace Style Guide</h1>
      
      <p class="style-guide-intro">
        This style guide documents the components, typography, and design patterns used
        throughout the Hydepwns monospace web application.
      </p>
      
      <div class="style-guide-toc">
        <h2>Table of Contents</h2>
        <ul>
          <li><a href="#typography">Typography</a></li>
          <li><a href="#color-palette">Color Palette</a></li>
          <li><a href="#grid-system">Grid System</a></li>
          <li><a href="#components">Components</a></li>
        </ul>
      </div>

      <section id="typography" class="style-guide-section">
        <h2>Typography</h2>
        <p>Typography section content</p>
      </section>
      
      <section id="color-palette" class="style-guide-section">
        <h2>Color Palette</h2>
        <p>Color palette section content</p>
      </section>
      
      <section id="grid-system" class="style-guide-section">
        <h2>Grid System</h2>
        <p>Grid system section content</p>
      </section>
      
      <section id="components" class="style-guide-section">
        <h2>Components</h2>
        <p>Components section content</p>
        
        <h3>MonoGrid</h3>
        <.mono_grid cols={40} debug={true}>
          <.mono_grid_row>
            <.mono_grid_cell cols={40}>
              This is a demo of the MonoGrid component
            </.mono_grid_cell>
          </.mono_grid_row>
        </.mono_grid>
        
        <h3>Terminal Component</h3>
        <.live_component
          module={Terminal}
          id="demo-terminal"
          prompt="user@hydepwns:~$"
          welcome_message="Welcome to the Terminal component demo"
        />
        
        <h3>Theme Toggle</h3>
        <ThemeToggle.theme_toggle />
        
        <h3>ASCII Art Generator</h3>
        <.live_component
          module={AsciiArtGenerator}
          id="demo-ascii-art-generator"
        />
      </section>
    </div>
    """
  end

  @doc """
  Mount function for the StyleGuide component.
  """
  def mount(socket) do
    {:ok, socket}
  end

  @doc """
  Update function for the StyleGuide component.
  """
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end 