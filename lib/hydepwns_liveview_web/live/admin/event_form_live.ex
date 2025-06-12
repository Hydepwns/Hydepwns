defmodule HydepwnsLiveviewWeb.EventFormLive do
  @moduledoc """
  LiveView for creating and editing events in the admin dashboard.
  """

  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Events
  alias HydepwnsLiveview.Events.Event

  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [input: 1]
  import HydepwnsLiveviewWeb.CoreComponents

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

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{})
    |> assign(:changeset, Events.change_event(%Event{}))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, Events.get_event!(id))
    |> assign(:changeset, Events.change_event(Events.get_event!(id)))
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset =
      socket.assigns.event
      |> Events.change_event(event_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.live_action, event_params)
  end

  defp save_event(socket, :edit, event_params) do
    case Events.update_event(socket.assigns.event, event_params) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event updated successfully")
         |> push_redirect(to: ~p"/admin/events")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_event(socket, :new, event_params) do
    case Events.create_event(event_params) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created successfully")
         |> push_redirect(to: ~p"/admin/events")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="max-w-2xl mx-auto">
        <h1 class="text-2xl font-bold mb-6"><%= @page_title %></h1>

        <.form
          :let={f}
          for={@changeset}
          id="event-form"
          phx-change="validate"
          phx-submit="save"
          class="space-y-6"
        >
          <div>
            <.input field={f[:name]} type="text" label="Name" />
          </div>

          <div>
            <.input field={f[:description]} type="textarea" label="Description" />
          </div>

          <div>
            <.input field={f[:date]} type="datetime-local" label="Date" />
          </div>

          <div>
            <.input field={f[:location]} type="text" label="Location" />
          </div>

          <div>
            <.input field={f[:status]} type="select" label="Status" options={["draft", "published", "cancelled"]} />
          </div>

          <div class="flex justify-end space-x-4">
            <.link navigate={~p"/admin/events"} class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded">
              Cancel
            </.link>
            <.button type="submit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
              Save
            </.button>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end 