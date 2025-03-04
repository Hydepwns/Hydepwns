defmodule HydepwnsLiveviewWeb.StyleGuideLive do
  use HydepwnsLiveviewWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="container">
      <div class="header-with-nav">
        <h1 class="page-title">Style Guide</h1>
        <.link navigate={~p"/"} class="link">
          ← Back to Home
        </.link>
      </div>

      <div class="card">
        <p class="section-text">
          This style guide showcases all available UI components and design patterns used in the Hydepwns application.
        </p>
        <.theme_toggle />
      </div>

      <section class="section">
        <h2 class="section-title with-border">Buttons</h2>
        <div class="button-showcase">
          <.button>Default Button</.button>
          <.button variant="outline">Outline Button</.button>
          <.button variant="ghost">Ghost Button</.button>
          <.button disabled>Disabled Button</.button>
          <.button size="sm">Small Button</.button>
          <.button size="lg">Large Button</.button>
        </div>
      </section>

      <section class="section">
        <h2 class="section-title with-border">Navigation</h2>
        <.nav>
          <:item link={~p"/"}>Home</:item>
          <:item link={~p"/style-guide"} active>Style Guide</:item>
          <:item link="#about">About</:item>
          <:item link="#contact">Contact</:item>
        </.nav>
      </section>

      <section class="section">
        <h2 class="section-title with-border">Tables</h2>
        <.header_table>
          <:header>Name</:header>
          <:header>Email</:header>
          <:header>Role</:header>
          <:header>Status</:header>
          <:row>
            <td>John Doe</td>
            <td>john@example.com</td>
            <td>Admin</td>
            <td>Active</td>
          </:row>
          <:row>
            <td>Jane Smith</td>
            <td>jane@example.com</td>
            <td>User</td>
            <td>Active</td>
          </:row>
          <:row>
            <td>Bob Johnson</td>
            <td>bob@example.com</td>
            <td>Moderator</td>
            <td>Inactive</td>
          </:row>
        </.header_table>
      </section>

      <section class="section">
        <h2 class="section-title with-border">Cards</h2>
        <div class="two-column-grid">
          <div class="card">
            <h3 class="section-subtitle">Card Title</h3>
            <p class="section-text">This is a simple card component with some content.</p>
            <.button variant="outline" size="sm">Action</.button>
          </div>
          <div class="card">
            <h3 class="section-subtitle">Another Card</h3>
            <p class="section-text">Cards can be used for various content and layouts.</p>
            <.button variant="outline" size="sm">Learn More</.button>
          </div>
        </div>
      </section>
    </div>
    """
  end
end
