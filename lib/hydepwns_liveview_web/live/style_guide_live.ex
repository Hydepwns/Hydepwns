defmodule HydepwnsLiveviewWeb.StyleGuideLive do
  use HydepwnsLiveviewWeb, :live_view
  alias HydepwnsLiveviewWeb.Components.StyleGuide

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_style_guide_path()
     |> assign(:page_title, "Style Guide")
     |> assign(:theme_class, "dark-theme")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="style-guide-container">
      <h1>Hydepwns Monospace Style Guide</h1>
      <p class="style-guide-intro">
        Welcome to the comprehensive style guide for the Hydepwns monospace site.
        This guide documents all components, styles, and patterns used throughout the application.
      </p>
      
      <.live_component 
        module={StyleGuide} 
        id="style-guide-component"
      />
    </div>
    """
  end

  @impl true
  def handle_event("change_theme", %{"theme" => theme}, socket) do
    theme_class = "#{theme}-theme"
    {:noreply, assign(socket, :theme_class, theme_class)}
  end

  # Private function to get the current path
  defp assign_style_guide_path(socket) do
    assign(socket, :current_path, "/style-guide")
  end
end
