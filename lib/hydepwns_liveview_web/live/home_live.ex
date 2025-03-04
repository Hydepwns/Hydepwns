defmodule HydepwnsLiveviewWeb.HomeLive do
  use HydepwnsLiveviewWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="container">
      <h1 class="page-title">Welcome to Hydepwns</h1>

      <div class="card">
        <h2 class="section-title">About This Project</h2>
        <p class="section-text">
          Hydepwns is a modern web application built with Phoenix LiveView,
          showcasing real-time user interactions without the complexity of JavaScript frameworks.
        </p>
        <div class="button-group">
          <.button>Get Started</.button>
          <.button variant="outline">Learn More</.button>
        </div>
      </div>

      <div class="two-column-grid">
        <div class="card">
          <h3 class="section-subtitle">Feature Highlights</h3>
          <ul class="feature-list">
            <li>Real-time updates with minimal JavaScript</li>
            <li>Responsive design with custom CSS</li>
            <li>Dark mode support</li>
            <li>Custom UI components</li>
          </ul>
        </div>

        <div class="card">
          <h3 class="section-subtitle">Getting Started</h3>
          <p class="section-text">
            Check out our style guide to see all available components and design patterns.
          </p>
          <.link navigate={~p"/style-guide"} class="link">
            View Style Guide →
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
