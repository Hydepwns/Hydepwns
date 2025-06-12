defmodule HydepwnsLiveviewWeb.ResourceFormLive do
  @moduledoc """
  LiveView for creating and editing resources.
  """

  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Resources
  alias HydepwnsLiveview.Resources.Resource

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
    |> assign(:page_title, "New Resource")
    |> assign(:resource, %Resource{})
    |> assign(:changeset, Resources.change_resource(%Resource{}))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Resource")
    |> assign(:resource, Resources.get_resource!(id))
    |> assign(:changeset, Resources.change_resource(Resources.get_resource!(id)))
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"resource" => resource_params}, socket) do
    changeset =
      socket.assigns.resource
      |> Resources.change_resource(resource_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"resource" => resource_params}, socket) do
    save_resource(socket, socket.assigns.live_action, resource_params)
  end

  defp save_resource(socket, :edit, resource_params) do
    case Resources.update_resource(socket.assigns.resource, resource_params) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource updated successfully")
         |> push_redirect(to: ~p"/resources")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_resource(socket, :new, resource_params) do
    case Resources.create_resource(resource_params) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource created successfully")
         |> push_redirect(to: ~p"/resources")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-2xl font-bold mb-6"><%= @page_title %></h1>

      <.form
        :let={f}
        for={@changeset}
        id="resource-form"
        phx-change="validate"
        phx-submit="save"
      >
        <div class="bg-white shadow rounded-lg p-6">
          <div class="space-y-6">
            <div>
              <.label for={f[:title].id}>Title</.label>
              <.input field={f[:title]} type="text" />
              <.error :for={msg <- Keyword.get_values(f[:title].errors, :title)}>
                <%= msg %>
              </.error>
            </div>

            <div>
              <.label for={f[:type].id}>Type</.label>
              <.input field={f[:type]} type="select" options={[Article: "article", Video: "video", Document: "document"]} />
              <.error :for={msg <- Keyword.get_values(f[:type].errors, :type)}>
                <%= msg %>
              </.error>
            </div>

            <div>
              <.label for={f[:description].id}>Description</.label>
              <.input field={f[:description]} type="textarea" />
              <.error :for={msg <- Keyword.get_values(f[:description].errors, :description)}>
                <%= msg %>
              </.error>
            </div>

            <div>
              <.label for={f[:status].id}>Status</.label>
              <.input field={f[:status]} type="select" options={[Draft: "draft", Published: "published", Archived: "archived"]} />
              <.error :for={msg <- Keyword.get_values(f[:status].errors, :status)}>
                <%= msg %>
              </.error>
            </div>

            <div class="flex justify-end">
              <.link navigate={~p"/resources"} class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded mr-2">
                Cancel
              </.link>
              <.button type="submit" phx-disable-with="Saving...">
                Save Resource
              </.button>
            </div>
          </div>
        </div>
      </.form>
    </div>
    """
  end
end
