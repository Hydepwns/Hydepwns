defmodule HydepwnsLiveviewWeb.Live.ResourceFormLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Components.Layout.Layouts, :app}

  alias HydepwnsLiveview.ResouceSystem

  @impl true
  def do_mount(%{"id" => id}, _session, socket) do # Edit action - Renamed from mount
    resource = ResourceSystem.get_resource(String.to_integer(id))
    socket =
      socket
      |> assign(:page_title, "Edit Resource")
      |> assign(:resource, resource)
      |> assign(:action, :edit)
    socket
  end

  def do_mount(_params, _session, socket) do # New action - Renamed from mount
    socket =
      socket
      |> assign(:page_title, "New Resource")
      |> assign(:resource, %{name: "", description: "", type: "", data: %{}}) # Or a changeset
      |> assign(:action, :new)
    socket
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1><%= if @action == :edit, do: "Edit Resource (#{@resource.id})", else: "Create New Resource" %></h1>
      <.form for={%{}} phx-submit="save_resource">
        <div>
          <label>Name</label>
          <input type="text" name="resource[name]" value={@resource.name} class={if @action == :edit, do: "resource-name-edit", else: "resource-name"} />
        </div>
        <div>
          <label>Description</label>
          <textarea name="resource[description]" class={if @action == :edit, do: "resource-description-edit", else: "resource-description"}><%= @resource.description %></textarea>
        </div>
        <div>
          <label>Type</label>
          <input type="text" name="resource[type]" value={@resource.type} class={if @action == :edit, do: "resource-type-edit", else: "resource-type"} />
        </div>
         <div>
          <label>Content (e.g. Markdown for type 'markdown', or JSON for other data)</label>
          <textarea name="resource[content]" rows="5"><%= Map.get(@resource, :content, Map.get(@resource.data, :content, "")) %></textarea>
        </div>
        <div>
          <label>Status</label>
          <input type="text" name="resource[status]" value={Map.get(@resource, :status, "active")} />
        </div>

        <button type="submit">Create Resource</button>
      </.form>
      <.link navigate={~p"/resources"}>Back to Resources</.link>
    </div>
    """
  end

  @impl true
  def handle_event("save_resource", %{"resource" => resource_params}, socket) do
    # In a real app, use a changeset and context for validation and creation/update
    # For now, simple creation/update for testing purposes
    action = socket.assigns.action

    merged_attrs = 
      if action == :edit do
        existing_resource = socket.assigns.resource
        Map.merge(existing_resource, resource_params)
        |> Map.put("id", existing_resource.id) # Ensure ID is preserved as integer
      else
        resource_params
      end

    # Simulate content extraction if not directly in params
    content = Map.get(resource_params, "content", Map.get(merged_attrs, :content))
    data_attrs = if content, do: Map.put(merged_attrs.data || %{}, :content, content), else: merged_attrs.data
    final_attrs = Map.put(merged_attrs, :data, data_attrs)

    case action do
      :new ->
        {:ok, new_resource} = ResourceSystem.create_resource(final_attrs)
        {:noreply, 
          socket
          |> put_flash(:info, "Resource created successfully")
          |> push_navigate(to: ~p"/resources/#{new_resource.id}")}
      :edit ->
        # Placeholder for update - ResourceSystem doesn't have update yet
        # {:ok, updated_resource} = ResourceSystem.update_resource(socket.assigns.resource.id, final_attrs)
        IO.inspect(final_attrs, label: "UPDATE RESOURCE (placeholder)")
        {:noreply, 
          socket
          |> put_flash(:info, "Resource updated successfully (placeholder)")
          |> push_navigate(to: ~p"/resources/#{socket.assigns.resource.id}")}
    end
  end

  @impl Phoenix.LiveView
  def handle_info(_msg, socket) do
    # Default implementation if no specific handling is needed
    {:noreply, socket}
  end
end 