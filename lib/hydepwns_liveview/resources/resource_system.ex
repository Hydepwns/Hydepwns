defmodule HydepwnsLiveview.Resources.ResourceSystem do
  @moduledoc """
  Resource system for managing resources in the application.
  Provides create, list, get, update, delete, and reset operations.
  """

  use GenServer
  alias HydepwnsLiveview.Resources.Resource
  alias HydepwnsLiveview.RepoHelper
  alias HydepwnsLiveview.Events.ResourceIntegration.ResourceEventGenerator

  @doc """
  Starts the resource system.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @doc """
  Creates a new resource with the given attributes.
  """
  def create_resource(attrs) do
    case %Resource{}
         |> Resource.changeset(attrs)
         |> RepoHelper.insert() do
      {:ok, resource} ->
        # Generate event for resource creation
        IO.puts("🔵 ResourceSystem.create_resource: Resource created, generating event for #{resource.id}")
        case ResourceEventGenerator.resource_created(resource, %{action: "create"}) do
          {:ok, event} ->
            IO.puts("✅ ResourceSystem.create_resource: Event generated successfully: #{event.type}")
            Phoenix.PubSub.broadcast(HydepwnsLiveview.PubSub, "resources", {:resource_created, resource})
            {:ok, resource}
          {:error, reason} ->
            IO.puts("❌ ResourceSystem.create_resource: Event generation failed: #{inspect(reason)}")
            Phoenix.PubSub.broadcast(HydepwnsLiveview.PubSub, "resources", {:resource_created, resource})
            {:ok, resource}  # Still return the resource even if event generation fails
        end
      error -> error
    end
  end

  @doc """
  Lists all resources.
  """
  def list_resources do
    RepoHelper.all(Resource)
  end

  @doc """
  Gets a resource by id.
  """
  def get_resource(id) do
    case RepoHelper.get(Resource, id) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  @doc """
  Updates a resource by id with new attributes.
  """
  def update_resource(id, attrs) do
    case RepoHelper.get(Resource, id) do
      nil ->
        {:error, :not_found}

      resource ->
        case resource
             |> Resource.changeset(attrs)
             |> RepoHelper.update() do
          {:ok, updated_resource} ->
            # Generate event for resource update
            ResourceEventGenerator.resource_updated(updated_resource, attrs, %{action: "update"})
            Phoenix.PubSub.broadcast(HydepwnsLiveview.PubSub, "resources", {:resource_updated, updated_resource})
            {:ok, updated_resource}
          error -> error
        end
    end
  end

  @doc """
  Deletes a resource by id.
  """
  def delete_resource(id) do
    case RepoHelper.get(Resource, id) do
      nil ->
        {:error, :not_found}

      resource ->
        case RepoHelper.delete(resource) do
          {:ok, deleted_resource} ->
            # Generate event for resource deletion
            ResourceEventGenerator.resource_deleted(deleted_resource, %{action: "delete"})
            {:ok, deleted_resource}
          error -> error
        end
    end
  end

  @doc """
  Resets the store (for tests).
  """
  def reset_store do
    RepoHelper.delete_all(Resource)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
