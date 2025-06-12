defmodule HydepwnsLiveviewWeb.TestErrorLive do
  use HydepwnsLiveviewWeb, :live_view

  def mount(_params, session, socket) do
    socket =
      socket
      |> Phoenix.Component.assign(:user_id, Map.get(session, "user_id", ""))
      |> Phoenix.Component.assign(:count, Map.get(session, "count", 0))
      |> Phoenix.Component.assign(:status, Map.get(session, "status", "active"))
      |> Phoenix.Component.assign(
        :settings,
        Map.get(session, "settings", %{theme: "dark", notifications: true})
      )
      |> Phoenix.Component.assign(:items, Map.get(session, "items", []))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="test-error-live">
      <p>User ID: <span data-assign="user_id">{@user_id}</span></p>
      <p>Count: <span data-assign="count">{@count}</span></p>
      <p>Status: <span data-assign="status">{@status}</span></p>
      <p>Settings: <span data-assign="settings">{inspect(@settings)}</span></p>
      <ul :if={@items && Enum.any?(@items)}>
        <li :for={item <- @items}>{item}</li>
      </ul>
      <div phx-click="update_status" data-test-id="status-clickable-div" style="display:inline-block;cursor:pointer;">Click to update status</div>
    </div>
    """
  end

  def handle_event("update_count", %{"count" => count}, socket) do
    {:noreply, Phoenix.Component.assign(socket, :count, count)}
  end

  def handle_event("update_status", %{"status" => status}, socket) do
    {:noreply, Phoenix.Component.assign(socket, :status, status)}
  end

  def handle_event("update_settings", %{"theme" => theme}, socket) do
    settings = %{theme: theme, notifications: "yes"}
    {:noreply, Phoenix.Component.assign(socket, :settings, settings)}
  end
end
