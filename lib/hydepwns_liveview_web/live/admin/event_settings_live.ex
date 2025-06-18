defmodule HydepwnsLiveviewWeb.Admin.EventSettingsLive do
  @moduledoc """
  LiveView for managing event settings in the admin dashboard.
  """

  use HydepwnsLiveviewWeb, :live_view

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [label: 1]
  alias HydepwnsLiveview.Events

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Event Settings")}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action)}
  end

  defp apply_action(socket, :index) do
    socket
    |> assign(:settings, Events.get_event_settings())
    |> assign(:changeset, Events.change_event_settings(%{}))
  end

  @impl Phoenix.LiveView
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
      <div class="bg-white shadow rounded-lg p-6">
        <div class="space-y-6">
          <div>
            <h3 class="text-lg font-medium">Event Settings</h3>
            <.form :let={f} for={@changeset} id="settings-form" phx-submit="save">
              <div class="space-y-4">
                <div>
                  <.label for={f[:timezone].id}>Timezone</.label>
                  <select name={f[:timezone].name} id={f[:timezone].id} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500">
                    <%= for tz <- Events.list_timezones() do %>
                      <option value={tz}><%= tz %></option>
                    <% end %>
                  </select>
                </div>

                <div class="flex justify-end space-x-4">
                  <HydepwnsLiveviewWeb.Components.UI.FormComponents.button type="submit" phx-disable-with="Saving...">
                    Save Settings
                  </HydepwnsLiveviewWeb.Components.UI.FormComponents.button>
                </div>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
