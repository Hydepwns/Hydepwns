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
    IO.inspect(assigns, label: "[DEBUG] assigns in update/2")
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

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event(event, params, socket) do
    IO.puts(
      "[DEBUG] handle_event/3 called with event: #{inspect(event)}, params: #{inspect(params)}"
    )

    IO.inspect(socket.assigns, label: "[DEBUG] assigns in handle_event/3")

    case event do
      "validate" -> handle_validate(params, socket)
      "save" -> handle_save(params, socket)
      _ -> {:noreply, socket}
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

  defp handle_save(%{"resource" => resource_params}, socket) do
    IO.puts(
      "[DEBUG] ResourceFormComponent.handle_event('save') called with params: #{inspect(resource_params)}"
    )

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

      "None" ->
        IO.puts("🔍 Converting 'None' parent_id to nil")
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
      <.form :let={f} for={@changeset} id="resource-form" phx-change="validate" phx-submit="save" phx-target={@myself}>
        <div class="space-y-6">
          <div>
            <.input field={f[:name]} type="text" label="Name" />
            <.error :for={error <- f[:name].errors} data-test-id="name-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                _ -> "Invalid name"
              end}
            </.error>
          </div>

          <div data-test-id="resource-form_description-container">
            <.input field={f[:description]} type="textarea" label="Description" />
            <.error :for={error <- f[:description].errors} data-test-id="description-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                _ -> "Invalid description"
              end}
            </.error>
          </div>

          <div data-test-id="resource-form_content-container">
            <.input field={f[:content]} type="textarea" label="Content" />
            <.error :for={error <- f[:content].errors} data-test-id="content-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                _ -> "Invalid content"
              end}
            </.error>
          </div>

          <div data-test-id="resource-form_type-container">
            <.input
              field={f[:type]}
              type="select"
              label="Type"
              options={[
                {"Document", "document"},
                {"Folder", "folder"},
                {"Task", "task"},
                {"Note", "note"}
              ]}
            />
            <.error :for={error <- f[:type].errors} data-test-id="type-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                _ -> "Invalid type"
              end}
            </.error>
          </div>

          <div data-test-id="resource-form_status-container">
            <.input
              field={f[:status]}
              type="select"
              label="Status"
              options={[
                {"Draft", "draft"},
                {"Published", "published"},
                {"Active", "active"},
                {"Archived", "archived"}
              ]}
            />
            <.error :for={error <- f[:status].errors} data-test-id="status-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                _ -> "Invalid status"
              end}
            </.error>
          </div>

          <div data-test-id="resource-form_parent_id-container">
            <.input
              field={f[:parent_id]}
              type="select"
              label="Parent"
              options={[
                {"None", ""} | Enum.map(@resources, fn resource -> {resource.name, resource.id} end)
              ]}
            />
            <.error :for={error <- f[:parent_id].errors} data-test-id="parent_id-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                _ -> "Invalid parent"
              end}
            </.error>
          </div>

          <div class="flex justify-end space-x-4">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
              {if @action == :new, do: "Create Resource", else: "Update Resource"}
            </button>
          </div>
        </div>
      </.form>
    </div>
    """
  end
end
