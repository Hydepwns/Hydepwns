defmodule HydepwnsLiveviewWeb.ResourceFormLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Layouts, :app}

  alias HydepwnsLiveview.Resources
  alias HydepwnsLiveview.Resources.DocumentResource

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    resource = Resources.get_resource!(id)
    changeset = Resources.change_resource(resource, %{})
    form = to_form(changeset, as: :resource)
    {:ok, assign(socket, resource: resource, form: form, page_title: "Edit Resource")}
  end

  @impl true
  def mount(_params, _session, socket) do
    resource = %DocumentResource{}
    changeset = Resources.change_resource(resource, %{})
    form = to_form(changeset, as: :resource)
    {:ok, assign(socket, resource: resource, form: form, page_title: "New Resource")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="max-w-2xl mx-auto">
        <h1 class="text-2xl font-bold mb-6">
          <%= if @resource.id, do: "Edit Resource", else: "New Resource" %>
        </h1>

        <.simple_form
          for={@form}
          id="resource-form"
          phx-change="validate"
          phx-submit="save"
          data-test-id="resource-form"
          as={:resource}
        >
          <:inner_block_simple_form :let={f}>
            <.input field={f[:id]} type="text" label="ID" data-test-id="resource-id-input" />
            <.input field={f[:name]} type="text" label="Name" data-test-id="resource-name-input" />
            <.input field={f[:type]} type="text" label="Type" data-test-id="resource-type-input" />
            <.input field={f[:content]} type="textarea" label="Content" data-test-id="resource-content-input" value={Jason.encode!(f[:content].value || %{})} />
            <.input field={f[:description]} type="textarea" label="Description" data-test-id="resource-description-input" />
            <.input field={f[:status]} type="text" label="Status" data-test-id="resource-status-input" />
            <.input field={f[:parent_id]} type="number" label="Parent ID" data-test-id="resource-parent-id-input" />
          </:inner_block_simple_form>

          <:actions>
            <.button phx-disable-with="Saving..." data-test-id="save-resource-button">
              Save Resource
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"resource" => resource_params}, socket) do
    form =
      socket.assigns.resource
      |> Resources.change_resource(resource_params)
      |> to_form(as: :resource)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"resource" => resource_params}, socket) do
    save_resource(socket, socket.assigns.resource, resource_params)
  end

  defp save_resource(socket, %DocumentResource{} = resource, resource_params) do
    case Resources.update_resource(resource, resource_params) do
      {:ok, resource} ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource updated successfully")
         |> push_navigate(to: ~p"/resources/#{resource}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :resource))}
    end
  end

  defp save_resource(socket, _resource, resource_params) do
    case Resources.create_resource(resource_params) do
      {:ok, resource} ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource created successfully")
         |> push_navigate(to: ~p"/resources/#{resource}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :resource))}
    end
  end
end
