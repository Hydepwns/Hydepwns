defmodule HydepwnsLiveview.Resources.ResourceSystem do
  @moduledoc """
  Resource system for managing resources in the application.
  Provides create, list, get, update, delete, and reset operations.
  """

  use GenServer
  alias HydepwnsLiveview.Resources.Resource
  alias HydepwnsLiveview.RepoHelper

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
    %Resource{}
    |> Resource.changeset(attrs)
    |> RepoHelper.insert()
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
        resource
        |> Resource.changeset(attrs)
        |> RepoHelper.update()
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
        RepoHelper.delete(resource)
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
