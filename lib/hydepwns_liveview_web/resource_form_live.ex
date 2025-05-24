defmodule HydepwnsLiveviewWeb.ResourceFormLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Layouts, :app}

  alias HydepwnsLiveview.Resources.ResourceSystem

  @impl true
  # Edit action - Renamed from mount
  def do_mount(%{"id" => id}, _session, socket) do
    resource = ResourceSystem.get_resource(String.to_integer(id))

    socket =
      socket
      |> assign(:page_title, "Edit Resource")
      |> assign(:resource, resource)
      |> assign(:action, :edit)
      |> assign(:errors, nil)

    socket
  end

  # New action - Renamed from mount
  def do_mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "New Resource")
      # Or a changeset
      |> assign(:resource, %{name: "", description: "", type: "", data: %{}})
      |> assign(:action, :new)
      |> assign(:errors, nil)

    socket
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>{if @action == :edit, do: "Edit Resource (#{@resource.id})", else: "Create New Resource"}</h1>
      <.form for={%{}} phx-submit="save_resource">
        <div>
          <label>Name</label>
          <input type="text" name="resource[name]" value={@resource.name} class={if @action == :edit, do: "resource-name-edit", else: "resource-name"} />
          <% name_error = @errors && Enum.find(@errors, fn {k, _} -> k == :name end) %>
          <%= if name_error do %>
            <div class="error-message"><%= elem(name_error, 1) %></div>
          <% end %>
        </div>
        <div>
          <label>Description</label>
          <textarea name="resource[description]" class={if @action == :edit, do: "resource-description-edit", else: "resource-description"}><%= @resource.description %></textarea>
          <% description_error = @errors && Enum.find(@errors, fn {k, _} -> k == :description end) %>
          <%= if description_error do %>
            <div class="error-message"><%= elem(description_error, 1) %></div>
          <% end %>
        </div>
        <div>
          <label>Type</label>
          <input type="text" name="resource[type]" value={@resource.type} class={if @action == :edit, do: "resource-type-edit", else: "resource-type"} />
          <% type_error = @errors && Enum.find(@errors, fn {k, _} -> k == :type end) %>
          <%= if type_error do %>
            <div class="error-message"><%= elem(type_error, 1) %></div>
          <% end %>
        </div>
        <div>
          <label>Content (e.g. Markdown for type 'markdown', or JSON for other data)</label>
          <textarea name="resource[content]" rows="5"><%= Map.get(@resource, :content, Map.get(@resource.data, :content, "")) %></textarea>
          <% content_error = @errors && Enum.find(@errors, fn {k, _} -> k == :content end) %>
          <%= if content_error do %>
            <div class="error-message"><%= elem(content_error, 1) %></div>
          <% end %>
        </div>
        <div>
          <label>Status</label>
          <input type="text" name="resource[status]" value={Map.get(@resource, :status, "active")} />
          <% status_error = @errors && Enum.find(@errors, fn {k, _} -> k == :status end) %>
          <%= if status_error do %>
            <div class="error-message"><%= elem(status_error, 1) %></div>
          <% end %>
        </div>

        <button type="submit">Create Resource</button>
      </.form>
      <.link navigate={~p"/resources"}>Back to Resources</.link>
    </div>
    """
  end

  @impl true
  def handle_event("save_resource", %{"resource" => resource_params}, socket) do
    action = socket.assigns.action

    merged_attrs =
      if action == :edit do
        existing_resource = socket.assigns.resource
        Map.merge(existing_resource, resource_params)
        |> Map.put("id", existing_resource.id)
      else
        resource_params
      end

    content = Map.get(resource_params, "content", Map.get(merged_attrs, :content))
    data_attrs =
      if content,
        do: Map.put(merged_attrs.data || %{}, :content, content),
        else: merged_attrs.data
    final_attrs = Map.put(merged_attrs, :data, data_attrs)

    case action do
      :new ->
        case ResourceSystem.create_resource(final_attrs) do
          {:ok, new_resource} ->
            {:noreply,
             socket
             |> put_flash(:info, "Resource created successfully")
             |> push_navigate(to: ~p"/resources/#{new_resource.id}")}
          {:error, errors} ->
            {:noreply,
             assign(socket, errors: errors, resource: final_attrs)}
        end
      :edit ->
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
