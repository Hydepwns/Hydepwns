defmodule HydepwnsLiveview.Resources.ResourceSystem do
  @moduledoc """
  Resource system for managing resources in the application.
  Provides create, list, get, update, delete, and reset operations.
  """

  use GenServer
  alias HydepwnsLiveview.Resources.Resource
  alias HydepwnsLiveview.RepoHelper
  alias HydepwnsLiveview.Events.ResourceIntegration.ResourceEventGenerator
  alias HydepwnsLiveview.Transformations.TransformationPipeline

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
    IO.puts("🔍 ResourceSystem.create_resource: Starting with attrs: #{inspect(attrs)}")
    
    changeset = %Resource{}
    |> Resource.changeset(attrs)
    
    IO.puts("🔍 ResourceSystem.create_resource: Changeset valid? #{changeset.valid?}")
    IO.puts("🔍 ResourceSystem.create_resource: Changeset errors: #{inspect(changeset.errors)}")
    
    case RepoHelper.insert(changeset) do
      {:ok, resource} ->
        IO.puts("✅ ResourceSystem.create_resource: Resource created successfully with ID: #{resource.id}")
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
      {:error, changeset} ->
        IO.puts("❌ ResourceSystem.create_resource: Insert failed with errors: #{inspect(changeset.errors)}")
        {:error, changeset}
      error ->
        IO.puts("❌ ResourceSystem.create_resource: Unexpected error: #{inspect(error)}")
        error
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
    IO.puts("🔍 ResourceSystem.update_resource: Starting update for resource #{id}")
    case RepoHelper.get(Resource, id) do
      nil ->
        IO.puts("❌ ResourceSystem.update_resource: Resource not found")
        {:error, :not_found}

      resource ->
        IO.puts("🔍 ResourceSystem.update_resource: Found resource, creating changeset")
        case resource
             |> Resource.changeset(attrs)
             |> RepoHelper.update() do
          {:ok, updated_resource} ->
            IO.puts("✅ ResourceSystem.update_resource: Resource updated successfully")
            # Generate event for resource update
            IO.puts("🔍 ResourceSystem.update_resource: Generating resource_updated event")
            case ResourceEventGenerator.resource_updated(updated_resource, attrs, %{action: "update"}) do
              {:ok, _event} ->
                IO.puts("✅ ResourceSystem.update_resource: resource_updated event generated successfully")
              {:error, reason} ->
                IO.puts("❌ ResourceSystem.update_resource: resource_updated event generation failed: #{inspect(reason)}")
            end
            Phoenix.PubSub.broadcast(HydepwnsLiveview.PubSub, "resources", {:resource_updated, updated_resource})
            
            # Apply transformations and generate transformed event
            IO.puts("🔍 ResourceSystem.update_resource: Applying transformations")
            case TransformationPipeline.apply_transformations(
              updated_resource,
              :resource,
              :update,
              phase: :after_validation,
              original_resource: resource
            ) do
              {:ok, transformed_resource, _context} ->
                IO.puts("✅ ResourceSystem.update_resource: Transformations applied successfully")
                # Generate event for resource transformation
                case ResourceEventGenerator.resource_event(transformed_resource, "transformed", %{}, %{action: "transform"}) do
                  {:ok, _event} ->
                    IO.puts("✅ ResourceSystem.update_resource: transformed event generated successfully")
                  {:error, reason} ->
                    IO.puts("❌ ResourceSystem.update_resource: transformed event generation failed: #{inspect(reason)}")
                end
                Phoenix.PubSub.broadcast(HydepwnsLiveview.PubSub, "resources", {:resource_transformed, transformed_resource})
                IO.puts("✅ ResourceSystem.update_resource: Returning transformed resource")
                {:ok, transformed_resource}
              
              {:error, _resource, _context} ->
                IO.puts("❌ ResourceSystem.update_resource: Transformations failed, returning updated resource")
                # Transformation failed, but still return the updated resource
                {:ok, updated_resource}
            end
          error -> 
            IO.puts("❌ ResourceSystem.update_resource: RepoHelper.update failed: #{inspect(error)}")
            error
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
