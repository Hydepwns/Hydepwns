defmodule HydepwnsLiveviewWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use HydepwnsLiveviewWeb, :controller` and
  `use HydepwnsLiveviewWeb, :live_view`.
  """
  use HydepwnsLiveviewWeb, :html
  use Phoenix.Component

  # Keep the MobileNav alias which is used in the template
  alias HydepwnsLiveviewWeb.Components.Layout.MobileNav
  alias HydepwnsLiveviewWeb.Components.Debug.SocketValidationPanel

  # Only keep imports that are actually used in the embedded templates
  embed_templates "layouts/*"

  def app(assigns) do
    ~H"""
    <div class="min-h-full flex flex-col">
      <header class="main-header">
        <!-- Desktop navigation -->
        <nav class="desktop-only">
          <!-- Existing navigation code -->
        </nav>
        
    <!-- Progress bar for page load indication -->
        <div class="nprogress-container">
          <div id="nprogress-bar" class="nprogress" phx-hook="ProgressBar" />
        </div>
      </header>

      <main id="main-content" class="flex-grow">
        <%= if assigns[:inner_block], do: render_slot(assigns[:inner_block]) %>
      </main>

      <footer class="main-footer">
        <!-- Footer content -->
      </footer>
      
    <!-- Mobile navigation (only appears on mobile devices) -->
      <MobileNav.mobile_nav current_path={assigns[:current_path] || ""} />
      
    <!-- Socket Validation Panel (only visible in development mode) -->
      <%= if Mix.env() == :dev do %>
        <.live_component module={SocketValidationPanel} id="socket-validation-panel" />
      <% end %>
    </div>
    """
  end
end
