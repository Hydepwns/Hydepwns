defmodule HydepwnsLiveviewWeb.EventSettingsLive do
  @moduledoc """
  LiveView for managing event settings in the admin dashboard.
  """

  use HydepwnsLiveviewWeb, :live_view
  import HydepwnsLiveviewWeb.CoreComponents

  alias HydepwnsLiveview.Events

  @behaviour Phoenix.LiveView

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = HydepwnsLiveview.ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    {:ok, assign(socket, theme_class: theme_class)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Event Settings")
    |> assign(:settings, Events.get_event_settings())
    |> assign(:changeset, Events.change_event_settings(%{}))
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"settings" => settings_params}, socket) do
    changeset =
      socket.assigns.settings
      |> Events.change_event_settings(settings_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"settings" => settings_params}, socket) do
    case Events.update_event_settings(socket.assigns.settings, settings_params) do
      {:ok, settings} ->
        {:noreply,
         socket
         |> put_flash(:info, "Settings updated successfully")
         |> assign(:settings, settings)
         |> assign(:changeset, Events.change_event_settings(settings))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Event Settings</h1>
      </div>

      <div class="bg-white shadow rounded-lg overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-semibold text-gray-900">General Settings</h2>
        </div>
        <div class="p-6">
          <.form
            :let={_f}
            for={@changeset}
            id="settings-form"
            phx-change="validate"
            phx-submit="save"
            class="space-y-6"
          >
            <div>
              <label class="block text-sm font-medium text-gray-700">Default Event Status</label>
              <select
                name="settings[default_status]"
                class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
              >
                <option value="draft">Draft</option>
                <option value="published">Published</option>
                <option value="cancelled">Cancelled</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700">Default Time Zone</label>
              <select
                name="settings[timezone]"
                class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
              >
                <%= for tz <- Events.list_timezones() do %>
                  <option value={tz}><%= tz %></option>
                <% end %>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700">Default Event Duration (minutes)</label>
              <input
                type="number"
                name="settings[default_duration]"
                min="15"
                step="15"
                class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700">Maximum Events Per Day</label>
              <input
                type="number"
                name="settings[max_events_per_day]"
                min="1"
                class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700">Enable Reminders</label>
              <div class="mt-2">
                <label class="inline-flex items-center">
                  <input
                    type="checkbox"
                    name="settings[enable_reminders]"
                    class="rounded border-gray-300 text-indigo-600 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
                  />
                  <span class="ml-2">Send automatic reminders for events</span>
                </label>
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700">Reminder Time (hours before event)</label>
              <input
                type="number"
                name="settings[reminder_time]"
                min="1"
                max="48"
                class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
              />
            </div>

            <div class="flex justify-end">
              <.button type="submit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                Save Settings
              </.button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end
end 