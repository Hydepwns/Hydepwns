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
  def handle_event("validate", %{"resource" => resource_params}, socket) do
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

  @impl true
  def handle_event("save", %{"resource" => resource_params}, socket) do
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

  defp save_resource(socket, :edit, resource_params) do
    IO.inspect(socket.assigns.parent_pid, label: "[DEBUG] parent_pid in save_resource")

    # Ensure content is always a map with :text key for the Resource schema
    resource_params_with_map_content =
      case Map.get(resource_params, "content") do
        content when is_binary(content) ->
          Map.put(resource_params, "content", %{"text" => content})

        content when is_map(content) ->
          resource_params

        _ ->
          Map.put(resource_params, "content", %{"text" => ""})
      end

    IO.puts(
      "🔍 ResourceFormComponent: Content before update: #{inspect(resource_params_with_map_content["content"])}"
    )

    case ResourceSystem.update_resource(
           socket.assigns.resource.id,
           resource_params_with_map_content
         ) do
      {:ok, updated_resource} ->
        # Send event to parent LiveView for notification
        IO.puts("🔍 Sending :resource_updated message to parent LiveView")
        send(socket.assigns.parent_pid, {:resource_updated, updated_resource})

        # Update the form with the new resource data
        updated_resource_with_text_content =
          if Map.has_key?(updated_resource, :content) and is_map(updated_resource.content) do
            # Extract text from content map for form display
            content_text = Map.get(updated_resource.content, :text, "")
            %{updated_resource | content: content_text}
          else
            updated_resource
          end

        # Convert struct to map with string keys only
        resource_map =
          updated_resource_with_text_content
          |> Map.from_struct()
          |> Map.drop([:__meta__])
          |> Enum.map(fn {k, v} -> {to_string(k), v} end)
          |> Map.new()

        updated_changeset = Resource.changeset(updated_resource_with_text_content, resource_map)

        {:noreply,
         socket
         |> assign(:resource, updated_resource_with_text_content)
         |> assign(:changeset, updated_changeset)}

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
      <.form :let={f} for={@changeset} id="resource-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <div class="space-y-6">
          <div>
            <.input field={f[:name]} type="text" label="Name" />
            <.error :for={error <- f[:name].errors} data-test-id="name-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                other -> inspect(other)
              end}
            </.error>
          </div>

          <div>
            <.input field={f[:description]} type="textarea" label="Description" />
            <.error :for={error <- f[:description].errors} data-test-id="description-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                other -> inspect(other)
              end}
            </.error>
          </div>

          <div>
            <.input field={f[:content]} type="textarea" label="Content" value={@changeset.data.content || ""} />
            <.error :for={error <- f[:content].errors} data-test-id="content-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                other -> inspect(other)
              end}
            </.error>
          </div>

          <div>
            <.input field={f[:type]} type="select" label="Type" options={[{"Document", "document"}, {"Folder", "folder"}, {"Task", "task"}, {"Note", "note"}]} />
            <.error :for={error <- f[:type].errors} data-test-id="type-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                other -> inspect(other)
              end}
            </.error>
          </div>

          <div>
            <.input field={f[:status]} type="select" label="Status" options={[{"Draft", "draft"}, {"Published", "published"}, {"Active", "active"}, {"Archived", "archived"}]} />
            <.error :for={error <- f[:status].errors} data-test-id="status-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                other -> inspect(other)
              end}
            </.error>
          </div>

          <div>
            <.input field={f[:parent_id]} type="select" label="Parent" options={[{"None", ""} | Enum.map(@resources, &{&1.name, &1.id})]} />
            <.error :for={error <- f[:parent_id].errors} data-test-id="parent-id-error">
              {case error do
                {message, _opts} -> message
                message when is_binary(message) -> message
                other -> inspect(other)
              end}
            </.error>
          </div>

          <div class="flex justify-end space-x-4">
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
              {if @changeset.data.id, do: "Save Resource", else: "Create Resource"}
            </button>
          </div>
        </div>
      </.form>
    </div>
    """
  end
end
