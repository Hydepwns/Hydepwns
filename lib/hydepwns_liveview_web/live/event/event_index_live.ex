defmodule HydepwnsLiveviewWeb.Event.EventIndexLive do
  use HydepwnsLiveviewWeb, :live_view

  on_mount {HydepwnsLiveviewWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Events")
     |> assign(:events, [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold">Events</h1>
        <.link navigate={~p"/events/new"} class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
          Create Event
        </.link>
      </div>

      <div class="bg-white shadow-lg rounded-lg p-6">
        <div class="text-center text-gray-500 py-8">
          <p class="text-lg">No events found</p>
          <p class="text-sm mt-2">Create your first event to get started</p>
        </div>
      </div>
    </div>
    """
  end
end 