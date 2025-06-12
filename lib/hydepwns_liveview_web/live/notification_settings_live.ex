defmodule HydepwnsLiveviewWeb.NotificationSettingsLive do
  use HydepwnsLiveviewWeb, :live_view
  import Phoenix.Component

  @impl true
  def mount(params, session, socket) do
    do_mount(params, session, socket)
  end

  @impl true
  def do_mount(_params, _session, socket) do
    socket
    |> assign(:myself, self())
    |> assign(:page_title, "Notification Settings")
    |> assign(:settings, %{
      email_notifications: true,
      push_notifications: false,
      reduced_motion: false
    })
  end

  @impl true
  def handle_event("toggle_setting", %{"setting" => setting}, socket) do
    settings = Map.update!(socket.assigns.settings, String.to_atom(setting), &(!&1))
    {:noreply, assign(socket, :settings, settings)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">Notification Settings</h1>

      <div class="bg-white shadow-lg rounded-lg p-6">
        <div class="space-y-6">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-lg font-medium">Email Notifications</h3>
              <p class="text-gray-500">Receive notifications via email</p>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" class="sr-only peer" checked={@settings.email_notifications} phx-click="toggle_setting" phx-value-setting="email_notifications" phx-target={@myself} />
              <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600">
              </div>
            </label>
          </div>

          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-lg font-medium">Push Notifications</h3>
              <p class="text-gray-500">Receive notifications in your browser</p>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" class="sr-only peer" checked={@settings.push_notifications} phx-click="toggle_setting" phx-value-setting="push_notifications" phx-target={@myself} />
              <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600">
              </div>
            </label>
          </div>

          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-lg font-medium">Reduced Motion</h3>
              <p class="text-gray-500">Minimize animations and transitions</p>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" class="sr-only peer" checked={@settings.reduced_motion} phx-click="toggle_setting" phx-value-setting="reduced_motion" name="reduced_motion" phx-target={@myself} />
              <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600">
              </div>
            </label>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
