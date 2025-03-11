defmodule HydepwnsLiveviewWeb.ScreenReaderTestLive do
  use HydepwnsLiveviewWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_screen_reader_path()
     |> assign(:page_title, "Screen Reader Test")
     |> assign(:theme_class, "dark-theme")}
  end

  @impl true
  def handle_event("change_theme", %{"theme" => theme}, socket) do
    theme_class = "#{theme}-theme"
    {:noreply, assign(socket, :theme_class, theme_class)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <h2>Screen Reader Accessibility Test</h2>
      <p>
        This page provides a summary of screen reader accessibility tests and recommendations
        for improving the user experience for users with visual impairments.
      </p>

      <h3>Overview</h3>
      <p>
        Screen readers are assistive technologies that allow visually impaired users to interact with websites
        by reading the content aloud. Ensuring our site works well with screen readers is essential for accessibility.
      </p>

      <h3>Test Results</h3>
      <p>Coming soon...</p>
    </section>
    """
  end

  defp assign_screen_reader_path(socket) do
    assign(socket, :current_path, "/screen-reader-test")
  end
end 