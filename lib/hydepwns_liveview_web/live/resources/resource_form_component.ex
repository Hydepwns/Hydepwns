defmodule HydepwnsLiveviewWeb.ResourceFormComponent do
  @moduledoc """
  LiveComponent for handling resource form interactions.
  Provides functionality for creating and editing resources with validation.
  """
  use HydepwnsLiveviewWeb, :live_component

  alias HydepwnsLiveview.Resources.ResourceSystem
  alias HydepwnsLiveview.Resources.Resource

  @impl true
  def update(%{resource: resource} = assigns, socket) do
    IO.inspect(assigns, label: "[DEBUG] assigns in update/2")
    IO.puts("[DEBUG] ResourceFormComponent.update/2 - @myself: #{inspect(assigns[:myself])}")
    IO.puts("[DEBUG] ResourceFormComponent.update/2 - parent_pid: #{inspect(assigns[:parent_pid])}")

    # Normalize parent_id to "" for the form if nil
    resource =
      if Map.get(resource, :parent_id) == nil,
        do: Map.put(resource, :parent_id, ""),
        else: resource

    # Convert content map to plain text for form display
    resource_with_text_content =
      cond do
        Map.has_key?(resource, :content) and is_map(resource.content) ->
          %{resource | content: Map.get(resource.content, :text, "")}

        true ->
          resource
      end

    # Ensure required fields have default values for new resources (only on mount)
    _resource_with_defaults =
      if resource_with_text_content.id == nil do
        %{
          resource_with_text_content
          | type: resource_with_text_content.type || "document",
            status: resource_with_text_content.status || "draft"
        }
      else
        resource_with_text_content
      end

    # Create changeset with the processed resource data (with text content)
    changeset = Resource.changeset(resource_with_text_content, %{})
    # Force content to be a string for the form
    content_text = resource_with_text_content.content || ""
    changeset = %{changeset | data: %{changeset.data | content: content_text}}

    changeset =
      if changeset.params,
        do: %{changeset | params: Map.put(changeset.params, "content", content_text)},
        else: changeset

    IO.inspect(changeset.data.content, label: "[DEBUG] changeset.data.content before assign")
    IO.inspect(resource_with_text_content.parent_id, label: "[DEBUG] resource.parent_id")

    # Prepare options for select fields
    type_options = [
      {"Document", "document"},
      {"Folder", "folder"},
      {"Task", "task"},
      {"Note", "note"}
    ]

    status_options = [
      {"Draft", "draft"},
      {"Published", "published"},
      {"Active", "active"},
      {"Archived", "archived"}
    ]

    # Filter out resources that would create circular relationships
    # A resource cannot be its own parent, and a child cannot be a parent of its parent
    current_resource_id = resource_with_text_content.id

    filtered_resources =
      (assigns[:resources] || [])
      |> Enum.filter(fn potential_parent ->
        # Skip if this is the same resource (self-reference)
        if current_resource_id && potential_parent.id == current_resource_id do
          false
        else
          # Skip if this would create a circular relationship
          # A child cannot be a parent of its own parent
          if current_resource_id && potential_parent.parent_id == current_resource_id do
            false
          else
            true
          end
        end
      end)

    parent_options = [
      {"None", ""} | Enum.map(filtered_resources, fn resource -> {resource.name, resource.id} end)
    ]

    IO.inspect(parent_options, label: "[DEBUG] parent_options")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:type_options, type_options)
     |> assign(:status_options, status_options)
     |> assign(:parent_options, parent_options)}
  end

  @impl true
  def handle_event(event, params, socket) do
    IO.puts("=== ResourceFormComponent.handle_event/3 CALLED: event=#{inspect(event)}, params=#{inspect(params)} ===")
    IO.puts("🔍 ResourceFormComponent: handle_event/3 called with event: '#{event}', params: #{inspect(params)}")
    IO.puts("🔍 ResourceFormComponent: socket assigns keys: #{inspect(Map.keys(socket.assigns))}")
    IO.puts("🔍 ResourceFormComponent: socket assigns id: #{inspect(socket.assigns[:id])}")
    IO.puts("🔍 ResourceFormComponent: socket assigns parent_pid: #{inspect(socket.assigns[:parent_pid])}")
    IO.inspect(socket.assigns, label: "[DEBUG] assigns in handle_event/3")

    case event do
      "validate" ->
        IO.puts("🔍 ResourceFormComponent: handle_event('validate') params: #{inspect(params)}")
        handle_validate(params, socket)
      "save" ->
        IO.puts("🔍 ResourceFormComponent: handle_event('save') params: #{inspect(params)}")
        handle_save(params, socket)
      _ ->
        IO.puts("🔍 ResourceFormComponent: Received unexpected event: '#{event}'")
        {:noreply, socket}
    end
  end

  defp handle_validate(%{"resource" => resource_params}, socket) do
    resource_params = process_form_params(resource_params)

    changeset =
      socket.assigns.resource
      |> Resource.changeset(resource_params)
      |> Map.put(:action, :validate)

    # Ensure content is always plain text in the changeset
    content_text = Map.get(resource_params, "content", "") || ""
    changeset = %{changeset | data: %{changeset.data | content: content_text}}

    changeset =
      if changeset.params,
        do: %{changeset | params: Map.put(changeset.params, "content", content_text)},
        else: changeset

    {:noreply, assign(socket, :changeset, changeset)}
  end

  defp handle_save(%{"resource" => resource_params} = params, socket) do
    IO.puts("[DEBUG] handle_save/2 received params: #{inspect(params)}")
    IO.puts("[DEBUG] handle_save/2 received resource_params: #{inspect(resource_params)}")
    resource_params = process_form_params(resource_params)
    save_resource(socket, socket.assigns.action, resource_params)
  end

  defp parse_content_json(params) do
    content = Map.get(params, "content")
    IO.inspect(content, label: "[DEBUG] parse_content_json input")

    result =
      case content do
        nil ->
          params

        "" ->
          Map.put(params, "content", "")

        content when is_map(content) ->
          Map.put(params, "content", Map.get(content, :text, ""))

        content when is_binary(content) ->
          case Jason.decode(content) do
            {:ok, %{"text" => text}} -> Map.put(params, "content", text)
            _ -> Map.put(params, "content", content)
          end

        _ ->
          params
      end

    IO.inspect(result, label: "[DEBUG] parse_content_json output")
    result
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
      value ->
        IO.puts("🔍 parent_id value: #{inspect(value)}")
        params
    end
  end

  defp notify_parent(socket, msg) do
    IO.puts("[DEBUG] ResourceFormComponent.notify_parent called with message: #{inspect(msg)}")
    IO.puts("[DEBUG] Component self(): #{inspect(self())}")
    IO.puts("[DEBUG] Component parent_pid: #{inspect(socket.assigns[:parent_pid])}")

    if socket.assigns[:parent_pid] do
      IO.puts("[DEBUG] Sending message to parent_pid: #{inspect(socket.assigns.parent_pid)}")
      send(socket.assigns.parent_pid, msg)
    else
      IO.puts("[ERROR] parent_pid is nil in notify_parent!")
    end
  end

  defp save_resource(socket, :edit, resource_params) do
    IO.puts("[DEBUG] ResourceFormComponent.save_resource(:edit) called")

    case ResourceSystem.update_resource(socket.assigns.resource, resource_params) do
      {:ok, resource} ->
        # Notify parent and let it handle the flash message and redirect
        notify_parent(socket, {:resource_updated, resource})
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_resource(socket, :new, resource_params) do
    IO.puts(
      "[DEBUG] ResourceFormComponent.save_resource(:new) called with params: #{inspect(resource_params)}"
    )

    case ResourceSystem.create_resource(resource_params) do
      {:ok, resource} ->
        IO.puts(
          "[DEBUG] ResourceFormComponent: Resource created successfully, sending message to parent"
        )

        notify_parent(socket, {:resource_created, resource})

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts(
          "[DEBUG] ResourceFormComponent: Resource creation failed with errors: #{inspect(changeset.errors)}"
        )

        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div data-debug="ResourceFormComponent-template-rendered">
      <form id="resource-form" phx-change="validate" phx-submit="save" phx-target={@id} data-test-id="resource-form">
        <div class="space-y-6">
          <div>
            <div class="form-group">
              <label for="resource-form_name" class="block text-sm font-semibold leading-6 text-zinc-800" data-test-id="resource-form_name-label">
                Name
              </label>
              <input type="text" id="resource-form_name" name="resource[name]" value={@resource.name} class="form-control" />
              <%= if @changeset.errors[:name] do %>
                <div class="mt-1 text-sm text-red-600" data-test-id="name-error">
                  <%= for {_field, {message, _opts}} <- @changeset.errors do %>
                    <%= if _field == :name do %>
                      <%= message %>
                    <% end %>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>

          <div data-test-id="resource-form_description-container">
            <div data-test-id="resource-form_description-container">
              <label for="resource-form_description" class="block text-sm font-semibold leading-6 text-zinc-800" data-test-id="resource-form_description-label">
                Description
              </label>
              <textarea id="resource-form_description" name="resource[description]" data-test-id="resource-form_description" class="mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 min-h-[6rem] border-zinc-300 focus:border-zinc-400">{@resource.description}</textarea>
            </div>
          </div>

          <div data-test-id="resource-form_content-container">
            <div data-test-id="resource-form_content-container">
              <label for="resource-form_content" class="block text-sm font-semibold leading-6 text-zinc-800" data-test-id="resource-form_content-label">
                Content
              </label>
              <textarea id="resource-form_content" name="resource[content]" data-test-id="resource-form_content" class="mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 min-h-[6rem] border-zinc-300 focus:border-zinc-400">{if is_map(@resource.content), do: Map.get(@resource.content, :text, ""), else: @resource.content}</textarea>
            </div>
          </div>

          <div data-test-id="resource-form_type-container">
            <div data-test-id="resource-form_type-container">
              <label for="resource-form_type" class="block text-sm font-semibold leading-6 text-zinc-800" data-test-id="resource-form_type-label">
                Type
              </label>
              <select id="resource-form_type" name="resource[type]" class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm" data-test-id="resource-form_type">
                <%= for {value, label} <- @type_options do %>
                  <option value={value} selected={@resource.type == value}><%= label %></option>
                <% end %>
              </select>
            </div>
          </div>

          <div data-test-id="resource-form_status-container">
            <div data-test-id="resource-form_status-container">
              <label for="resource-form_status" class="block text-sm font-semibold leading-6 text-zinc-800" data-test-id="resource-form_status-label">
                Status
              </label>
              <select id="resource-form_status" name="resource[status]" class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm" data-test-id="resource-form_status">
                <%= for {value, label} <- @status_options do %>
                  <option value={value} selected={@resource.status == value}><%= label %></option>
                <% end %>
              </select>
            </div>
          </div>

          <div data-test-id="resource-form_parent_id-container">
            <div data-test-id="resource-form_parent_id-container">
              <label for="resource-form_parent_id" class="block text-sm font-semibold leading-6 text-zinc-800" data-test-id="resource-form_parent_id-label">
                Parent
              </label>
              <select id="resource-form_parent_id" name="resource[parent_id]" class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm" data-test-id="resource-form_parent_id" phx-no-feedback>
                <%= for {value, label} <- @parent_options do %>
                  <option value={value} selected={@resource.parent_id == value} data-test-id={"parent-option-#{value}"}><%= label %></option>
                <% end %>
              </select>
              <%= if @changeset.errors[:parent_id] do %>
                <div class="mt-1 text-sm text-red-600" data-test-id="parent-id-error">
                  <%= for {_field, {message, _opts}} <- @changeset.errors do %>
                    <%= if _field == :parent_id do %>
                      <%= message %>
                    <% end %>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>

          <div class="flex justify-end space-x-4">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700" data-test-id="save-resource-button">
              Save Resource
            </button>
          </div>
        </div>
      </form>
    </div>
    """
  end
end
