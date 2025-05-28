defmodule HydepwnsLiveview.Resources.ResourceSystem do
  @moduledoc """
  In-memory resource system for testing and demonstration.
  Provides create, list, get, update, delete, and reset operations.
  """

  @agent_name __MODULE__.Agent

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> %{} end, name: @agent_name)
  end

  @doc """
  Creates a new resource with the given attributes. Assigns a unique integer id.
  """
  def create_resource(attrs) do
    id = System.unique_integer([:positive]) |> Integer.to_string()
    resource = Map.merge(%{id: id}, attrs) |> Map.put(:id, id)
    case Map.get(resource, :type) do
      "document" ->
        changeset = HydepwnsLiveview.Resources.DocumentResource.changeset(resource)
        if changeset.valid? do
          valid_resource = Ecto.Changeset.apply_changes(changeset)
          valid_resource = Map.put(valid_resource, :__resource_module__, HydepwnsLiveview.Resources.DocumentResource)
          Agent.update(@agent_name, &Map.put(&1, id, valid_resource))
          {:ok, valid_resource}
        else
          {:error, changeset}
        end
      "folder" ->
        changeset = HydepwnsLiveview.Resources.FolderResource.changeset(resource)
        if changeset.valid? do
          valid_resource = Ecto.Changeset.apply_changes(changeset)
          valid_resource = Map.put(valid_resource, :__resource_module__, HydepwnsLiveview.Resources.FolderResource)
          Agent.update(@agent_name, &Map.put(&1, id, valid_resource))
          {:ok, valid_resource}
        else
          {:error, changeset}
        end
      _ ->
        Agent.update(@agent_name, &Map.put(&1, id, resource))
        {:ok, resource}
    end
  end

  @doc """
  Lists all resources.
  """
  def list_resources do
    Agent.get(@agent_name, &Map.values(&1))
  end

  @doc """
  Gets a resource by id.
  """
  def get_resource(id) do
    Agent.get(@agent_name, &Map.get(&1, id))
  end

  @doc """
  Updates a resource by id with new attributes.
  """
  def update_resource(id, attrs) do
    Agent.get_and_update(@agent_name, fn state ->
      case Map.get(state, id) do
        nil -> {{:error, :not_found}, state}
        resource ->
          updated =
            if is_struct(resource) do
              struct(resource, Map.merge(Map.from_struct(resource), attrs))
            else
              Map.merge(resource, attrs)
            end
          updated = Map.put(updated, :id, id)
          {{:ok, updated}, Map.put(state, id, updated)}
      end
    end)
  end

  @doc """
  Deletes a resource by id.
  """
  def delete_resource(id) do
    Agent.get_and_update(@agent_name, fn state ->
      case Map.has_key?(state, id) do
        true -> {:ok, Map.delete(state, id)}
        false -> {{:error, :not_found}, state}
      end
    end)
  end

  @doc """
  Resets the store (for tests).
  """
  def reset_store do
    Agent.update(@agent_name, fn _ -> %{} end)
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