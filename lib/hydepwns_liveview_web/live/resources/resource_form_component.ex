defmodule HydepwnsLiveviewWeb.ResourceFormComponent do
  @moduledoc """
  LiveComponent for handling resource form interactions.
  Provides functionality for creating and editing resources with validation.
  """
  use HydepwnsLiveviewWeb, :live_component

  alias HydepwnsLiveview.Resources.ResourceSystem
  alias HydepwnsLiveview.Resources.Resource
  import HydepwnsLiveviewWeb.Components.UI.FormComponents, only: [input: 1, button: 1, error: 1, translate_error: 1]

  @impl true
  def update(%{resource: resource} = assigns, socket) do
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
    
    changeset = Resource.changeset(resource_with_defaults, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"resource" => resource_params}, socket) do
    resource_params = parse_content_json(resource_params)
    changeset =
      socket.assigns.resource
      |> Resource.changeset(resource_params)
      |> Map.put(:action, :validate)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"resource" => resource_params}, socket) do
    resource_params = parse_content_json(resource_params)
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

  defp save_resource(socket, :edit, resource_params) do
    case ResourceSystem.update_resource(socket.assigns.resource.id, resource_params) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource updated successfully")
         |> push_navigate(to: "/resources")}
      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_resource(socket, :new, resource_params) do
    case ResourceSystem.create_resource(resource_params) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource created successfully")
         |> push_navigate(to: "/resources")}
      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
