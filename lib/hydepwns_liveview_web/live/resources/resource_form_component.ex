defmodule HydepwnsLiveviewWeb.ResourceFormComponent do
  @moduledoc """
  LiveComponent for handling resource form interactions.
  Provides functionality for creating and editing resources with validation.
  """
  use HydepwnsLiveviewWeb, :live_component

  alias HydepwnsLiveview.Resources.ResourceSystem
  alias HydepwnsLiveview.Resources.Resource
  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [input: 1, error: 1]

  @impl true
  def update(%{resource: resource} = assigns, socket) do
    # Normalize parent_id to "" for the form if nil
    resource = if Map.get(resource, :parent_id) == nil, do: Map.put(resource, :parent_id, ""), else: resource
    
    # Convert content map to JSON string for form display
    resource_with_json_content =
      if Map.has_key?(resource, :content) and is_map(resource.content) do
        %{resource | content: Jason.encode!(resource.content)}
      else
        resource
      end
    
    # Ensure required fields have default values for new resources (only on mount)
    resource_with_defaults = 
      if resource_with_json_content.id == nil do
        %{resource_with_json_content | 
          type: resource_with_json_content.type || "document",
          status: resource_with_json_content.status || "draft"
        }
      else
        resource_with_json_content
      end
    
    # Create changeset with existing resource data to preserve values like parent_id
    # Convert struct to map, excluding Ecto metadata fields
    resource_map = 
      resource_with_defaults
      |> Map.from_struct()
      |> Map.drop([:__meta__])
    
    changeset = Resource.changeset(resource_with_defaults, resource_map)

    # Extract flash messages from assigns if present
    flash_messages = Map.get(assigns, :flash_messages, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:flash_messages, flash_messages)}
  end

  @impl true
  def handle_event("validate", %{"resource" => resource_params}, socket) do
    resource_params = process_form_params(resource_params)
    changeset =
      socket.assigns.resource
      |> Resource.changeset(resource_params)
      |> Map.put(:action, :validate)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"resource" => resource_params}, socket) do
    resource_params = process_form_params(resource_params)
    save_resource(socket, socket.assigns.action, resource_params)
  end

  defp parse_content_json(params) do
    case Map.get(params, "content") do
      nil -> params
      "" -> Map.put(params, "content", %{})
      content when is_binary(content) ->
        case Jason.decode(content) do
          {:ok, map} -> Map.put(params, "content", map)
          _ -> Map.put(params, "content", %{})
        end
      _ -> params
    end
  end

  defp process_form_params(params) do
    params
    |> parse_content_json()
    |> process_parent_id()
  end

  defp process_parent_id(params) do
    case Map.get(params, "parent_id") do
      "" -> 
        IO.puts("🔍 Converting empty parent_id to nil")
        Map.put(params, "parent_id", nil)
      "None" -> 
        IO.puts("🔍 Converting 'None' parent_id to nil")
        Map.put(params, "parent_id", nil)
      value -> 
        IO.puts("🔍 parent_id value: #{inspect(value)}")
        params
    end
  end

  defp save_resource(socket, :edit, resource_params) do
    case ResourceSystem.update_resource(socket.assigns.resource.id, resource_params) do
      {:ok, updated_resource} ->
        # Send event to parent LiveView for notification
        send(socket.assigns.parent_pid, {:resource_updated, updated_resource})
        
        # Update the form with the new resource data
        updated_resource_with_json_content =
          if Map.has_key?(updated_resource, :content) and is_map(updated_resource.content) do
            %{updated_resource | content: Jason.encode!(updated_resource.content)}
          else
            updated_resource
          end
        
        resource_map = 
          updated_resource_with_json_content
          |> Map.from_struct()
          |> Map.drop([:__meta__])
        
        updated_changeset = Resource.changeset(updated_resource_with_json_content, resource_map)
        
        {:noreply, 
         socket
         |> assign(:resource, updated_resource_with_json_content)
         |> assign(:changeset, updated_changeset)
         |> put_flash(:info, "Resource updated successfully")}
      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_resource(socket, :new, resource_params) do
    case ResourceSystem.create_resource(resource_params) do
      {:ok, resource} ->
        # Send event to parent LiveView for notification
        send(socket.assigns.parent_pid, {:resource_created, resource})
        
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @flash_messages && @flash_messages[:info] do %>
        <div class="alert alert-info" data-test-id="flash-info">
          <%= @flash_messages[:info] %>
        </div>
      <% end %>

      <.form :let={f} for={@changeset} id="resource-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <div class="space-y-6">
          <div>
            <.input field={f[:name]} type="text" label="Name" />
            <.error :for={error <- f[:name].errors}>
              <%= case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                other -> inspect(other)
              end %>
            </.error>
          </div>

          <div>
            <.input field={f[:description]} type="textarea" label="Description" />
            <.error :for={error <- f[:description].errors}>
              <%= case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                other -> inspect(other)
              end %>
            </.error>
          </div>

          <div>
            <.input field={f[:type]} type="select" label="Type" options={[{"Document", "document"}, {"Folder", "folder"}, {"Task", "task"}, {"Note", "note"}]} />
            <.error :for={error <- f[:type].errors}>
              <%= case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                other -> inspect(other)
              end %>
            </.error>
          </div>

          <div>
            <.input field={f[:status]} type="select" label="Status" options={[{"Draft", "draft"}, {"Published", "published"}, {"Archived", "archived"}]} />
            <.error :for={error <- f[:status].errors}>
              <%= case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                other -> inspect(other)
              end %>
            </.error>
          </div>

          <div>
            <.input field={f[:parent_id]} type="select" label="Parent" options={[{"None", ""} | Enum.map(@resources, &{&1.name, &1.id})]} />
            <.error :for={error <- f[:parent_id].errors} data-test-id="parent-id-error">
              <%= case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                other -> inspect(other)
              end %>
            </.error>
          </div>

          <div class="flex justify-end space-x-4">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
              <%= if @changeset.data.id, do: "Save Resource", else: "Create Resource" %>
            </button>
          </div>
        </div>
      </.form>
    </div>
    """
  end
end
