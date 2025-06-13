defmodule HydepwnsLiveviewWeb.ResourceFormLive do
  @moduledoc """
  LiveView for creating and editing resources.
  """

  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Resources
  alias HydepwnsLiveview.ResourceSystem.Models.Resource
  import Phoenix.HTML.Form

  import HydepwnsLiveviewWeb.Components.Common.CoreComponents
  import HydepwnsLiveviewWeb.Components.UI.FormComponents

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
         |> push_navigate(to: ~p"/resources")}

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
         |> push_navigate(to: ~p"/resources")}

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
        data-test-id="resource-form"
      >
        <div class="bg-white shadow rounded-lg p-6">
          <div class="space-y-6">
            <div>
              <HydepwnsLiveviewWeb.Components.UI.FormComponents.label for={f[:name].id}>Name</HydepwnsLiveviewWeb.Components.UI.FormComponents.label>
              <.input
                field={f[:name]}
                type="text"
                id="name"
                data-test-id="name-input"
                required
              />
              <.error :for={msg <- Keyword.get_values(f[:name].errors, :name)} data-test-id="error-message">
                <%= msg %>
              </.error>
            </div>

            <div>
              <HydepwnsLiveviewWeb.Components.UI.FormComponents.label for={f[:type].id}>Type</HydepwnsLiveviewWeb.Components.UI.FormComponents.label>
              <.input
                field={f[:type]}
                type="select"
                id="type"
                data-test-id="type-input"
                options={[Folder: "folder", Document: "document"]}
                required
              />
              <.error :for={msg <- Keyword.get_values(f[:type].errors, :type)} data-test-id="error-message">
                <%= msg %>
              </.error>
            </div>

            <div>
              <HydepwnsLiveviewWeb.Components.UI.FormComponents.label for={f[:parent_id].id}>Parent Resource</HydepwnsLiveviewWeb.Components.UI.FormComponents.label>
              <.input
                field={f[:parent_id]}
                type="select"
                id="parent_id"
                data-test-id="parent-id-select"
                options={Resources.list_resources() |> Enum.map(&{&1.name, &1.id})}
              />
              <.error :for={msg <- Keyword.get_values(f[:parent_id].errors, :parent_id)} data-test-id="error-message">
                <%= msg %>
              </.error>
            </div>

            <div>
              <HydepwnsLiveviewWeb.Components.UI.FormComponents.label for={f[:description].id}>Description</HydepwnsLiveviewWeb.Components.UI.FormComponents.label>
              <.input
                field={f[:description]}
                type="textarea"
                id="description"
                data-test-id="description-input"
              />
              <.error :for={msg <- Keyword.get_values(f[:description].errors, :description)} data-test-id="error-message">
                <%= msg %>
              </.error>
            </div>

            <div>
              <HydepwnsLiveviewWeb.Components.UI.FormComponents.label for={f[:status].id}>Status</HydepwnsLiveviewWeb.Components.UI.FormComponents.label>
              <.input
                field={f[:status]}
                type="select"
                id="status"
                data-test-id="status-input"
                options={[Active: "active", Inactive: "inactive"]}
                required
              />
              <.error :for={msg <- Keyword.get_values(f[:status].errors, :status)} data-test-id="error-message">
                <%= msg %>
              </.error>
            </div>

            <div class="flex justify-end space-x-4">
              <.link
                navigate={~p"/resources"}
                class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded"
                data-test-id="cancel-resource-button"
              >
                Cancel
              </.link>
              <HydepwnsLiveviewWeb.Components.UI.FormComponents.button
                type="submit"
                phx-disable-with="Saving..."
                data-test-id="save-resource"
              >
                Save Resource
              </HydepwnsLiveviewWeb.Components.UI.FormComponents.button>
            </div>
          </div>
        </div>
      </.form>
    </div>
    """
  end
end
