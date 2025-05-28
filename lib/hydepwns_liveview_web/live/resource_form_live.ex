defmodule HydepwnsLiveviewWeb.ResourceFormLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Layouts, :app}

  alias HydepwnsLiveview.Resources.ResourceSystem
  alias HydepwnsLiveview.Events.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "New Resource")
     |> assign(:resource, %{
       name: "",
       description: "",
       type: "",
       status: "active",
       parent_id: nil
     })
     |> assign(:parent_resources, ResourceSystem.list_resources())}
  end

  @impl true
  def handle_event("save", %{"resource" => resource_params}, socket) do
    case ResourceSystem.create_resource(resource_params) do
      {:ok, resource} ->
        Event.create("resource.created", %{resource: resource})
        {:noreply,
         socket
         |> put_flash(:info, "Resource created successfully")
         |> redirect(to: ~p"/resources")}

      {:error, errors} ->
        # errors is a list of {field, message}
        error_map = Enum.group_by(errors, fn {field, _msg} -> field end, fn {_field, msg} -> msg end)
        {:noreply,
         socket
         |> put_flash(:error, "Failed to create resource")
         |> assign(:resource, resource_params)
         |> assign(:errors, error_map)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">Create New Resource</h1>

      <.form
        :let={_f}
        for={@resource}
        phx-submit="save"
        class="max-w-lg mx-auto bg-white shadow-lg rounded-lg p-6"
      >
        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="resource_name">
            Name
          </label>
          <input
            type="text"
            name="resource[name]"
            id="resource_name"
            value={@resource.name}
            class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            data-test-id="name-input"
            required
          />
          <%= if @errors && Map.has_key?(@errors, :name) do %>
            <%= for msg <- @errors[:name] do %>
              <div class="error-message"><%= msg %></div>
            <% end %>
          <% end %>
        </div>

        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="resource_description">
            Description
          </label>
          <textarea
            name="resource[description]"
            id="resource_description"
            class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            data-test-id="description-input"
            required
          ><%= @resource.description %></textarea>
          <%= if @errors && Map.has_key?(@errors, :description) do %>
            <%= for msg <- @errors[:description] do %>
              <div class="error-message"><%= msg %></div>
            <% end %>
          <% end %>
        </div>

        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="resource_type">
            Type
          </label>
          <input
            type="text"
            name="resource[type]"
            id="resource_type"
            value={@resource.type}
            class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            data-test-id="type-input"
            required
          />
          <%= if @errors && Map.has_key?(@errors, :type) do %>
            <%= for msg <- @errors[:type] do %>
              <div class="error-message"><%= msg %></div>
            <% end %>
          <% end %>
        </div>

        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="resource_status">
            Status
          </label>
          <input
            type="text"
            name="resource[status]"
            id="resource_status"
            value={@resource.status}
            class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            data-test-id="status-input"
          />
        </div>

        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="resource_parent_id">
            Parent Resource
          </label>
          <select
            name="resource[parent_id]"
            id="resource_parent_id"
            class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            data-test-id="parent-id-select"
          >
            <option value="">None</option>
            <%= for parent <- @parent_resources do %>
              <option value={parent.id} data-test-id="parent-id-option"><%= parent.name %></option>
            <% end %>
          </select>
        </div>

        <div class="flex items-center justify-between">
          <button
            type="submit"
            class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
            data-test-id="save-resource"
          >
            Create Resource
          </button>
          <.link
            navigate={~p"/resources"}
            class="inline-block align-baseline font-bold text-sm text-blue-500 hover:text-blue-800"
          >
            Cancel
          </.link>
        </div>
      </.form>
    </div>
    """
  end
end 