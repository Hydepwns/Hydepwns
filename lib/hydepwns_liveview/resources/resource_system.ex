defmodule HydepwnsLiveview.Resources.ResourceSystem do
  @moduledoc """
  Resource system for managing resources in the application.
  Provides create, list, get, update, delete, and reset operations.
  """

  use GenServer
  alias HydepwnsLiveview.Resources.Resource
  alias HydepwnsLiveview.RepoHelper
  alias HydepwnsLiveview.Events.ResourceEventGenerator
  alias HydepwnsLiveview.Transformations.TransformationPipeline
  import Ecto.Query

  @doc """
  Starts the resource system.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    init_cache()
    {:ok, %{}}
  end

  @doc """
  Creates a new resource with the given attributes.
  """
  def create_resource(attrs) do
    IO.puts("🔍 ResourceSystem.create_resource: Starting with attrs: #{inspect(attrs)}")

    changeset =
      %Resource{}
      |> Resource.changeset(attrs)

    IO.puts("🔍 ResourceSystem.create_resource: Changeset valid? #{changeset.valid?}")
    IO.puts("🔍 ResourceSystem.create_resource: Changeset errors: #{inspect(changeset.errors)}")

    case RepoHelper.insert(changeset) do
      {:ok, resource} ->
        IO.puts(
          "✅ ResourceSystem.create_resource: Resource created successfully with ID: #{resource.id}"
        )

        # Invalidate cache
        invalidate_resource_cache()
        # Generate event for resource creation
        IO.puts(
          "🔵 ResourceSystem.create_resource: Resource created, generating event for #{resource.id}"
        )

        event_data = Map.from_struct(resource) |> Map.drop([:__meta__, :__struct__])
        case ResourceEventGenerator.resource_created(resource.__struct__, resource.id, event_data, %{action: "create"}) do
          {:ok, event} ->
            IO.puts(
              "✅ ResourceSystem.create_resource: Event generated successfully: #{event.type}"
            )

            Phoenix.PubSub.broadcast(
              HydepwnsLiveview.PubSub,
              "resources",
              {:resource_created, resource}
            )

            {:ok, resource}

          {:error, reason} ->
            IO.puts(
              "❌ ResourceSystem.create_resource: Event generation failed: #{inspect(reason)}"
            )

            Phoenix.PubSub.broadcast(
              HydepwnsLiveview.PubSub,
              "resources",
              {:resource_created, resource}
            )

            # Still return the resource even if event generation fails
            {:ok, resource}
        end

      {:error, changeset} ->
        IO.puts(
          "❌ ResourceSystem.create_resource: Insert failed with errors: #{inspect(changeset.errors)}"
        )

        {:error, changeset}

      error ->
        IO.puts("❌ ResourceSystem.create_resource: Unexpected error: #{inspect(error)}")
        error
    end
  end

  @doc """
  Lists all resources with optional pagination and caching.
  """
  def list_resources(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)
    use_cache = Keyword.get(opts, :use_cache, true)

    if use_cache do
      cached_list_resources(limit, offset)
    else
      direct_list_resources(limit, offset)
    end
  end

  @doc """
  Lists resources with optional filtering and pagination.
  """
  def list_resources_with_filters(filters, opts \\ []) when is_map(filters) do
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)
    use_cache = Keyword.get(opts, :use_cache, true)

    if use_cache do
      cached_list_resources_with_filters(filters, limit, offset)
    else
      direct_list_resources_with_filters(filters, limit, offset)
    end
  end

  @doc """
  Gets the total count of resources (for pagination).
  """
  def count_resources(filters \\ %{}) do
    query = from(r in Resource)

    query =
      case filters do
        %{type: type} when not is_nil(type) ->
          from(r in query, where: r.type == ^type)

        _ ->
          query
      end

    query =
      case filters do
        %{status: status} when not is_nil(status) ->
          from(r in query, where: r.status == ^status)

        _ ->
          query
      end

    query =
      case filters do
        %{parent_id: parent_id} when not is_nil(parent_id) ->
          from(r in query, where: r.parent_id == ^parent_id)

        _ ->
          query
      end

    RepoHelper.aggregate(query, :count, :id)
  end

  # Private functions for direct database queries
  defp direct_list_resources(limit, offset) do
    resources =
      Resource
      |> order_by([r], desc: r.inserted_at)
      |> limit(^limit)
      |> offset(^offset)
      |> RepoHelper.all()

    if Mix.env() == :test do
      IO.puts(
        "[DEBUG] direct_list_resources/2 returned #{length(resources)} resources: #{inspect(Enum.map(resources, & &1.name))}"
      )
    end

    resources
  end

  defp direct_list_resources_with_filters(filters, limit, offset) do
    query = from(r in Resource)

    query =
      case filters do
        %{type: type} when not is_nil(type) ->
          from(r in query, where: r.type == ^type)

        _ ->
          query
      end

    query =
      case filters do
        %{status: status} when not is_nil(status) ->
          from(r in query, where: r.status == ^status)

        _ ->
          query
      end

    query =
      case filters do
        %{parent_id: parent_id} when not is_nil(parent_id) ->
          from(r in query, where: r.parent_id == ^parent_id)

        _ ->
          query
      end

    query
    |> order_by([r], desc: r.inserted_at)
    |> limit(^limit)
    |> offset(^offset)
    |> RepoHelper.all()
  end

  # Private functions for cached queries
  defp cached_list_resources(limit, offset) do
    cache_key = "resources:list:#{limit}:#{offset}"

    case get_cache(cache_key) do
      {:ok, resources} ->
        resources

      {:error, :not_found} ->
        resources = direct_list_resources(limit, offset)
        # Cache for 5 minutes
        set_cache(cache_key, resources, 300)
        resources
    end
  end

  defp cached_list_resources_with_filters(filters, limit, offset) do
    cache_key = "resources:filtered:#{hash_filters(filters)}:#{limit}:#{offset}"

    case get_cache(cache_key) do
      {:ok, resources} ->
        resources

      {:error, :not_found} ->
        resources = direct_list_resources_with_filters(filters, limit, offset)
        # Cache for 5 minutes
        set_cache(cache_key, resources, 300)
        resources
    end
  end

  # Simple cache implementation using ETS
  defp get_cache(key) do
    case :ets.lookup(:resource_cache, key) do
      [{^key, value, expiry}] ->
        if DateTime.compare(expiry, DateTime.utc_now()) == :gt do
          {:ok, value}
        else
          :ets.delete(:resource_cache, key)
          {:error, :not_found}
        end

      [] ->
        {:error, :not_found}
    end
  end

  defp set_cache(key, value, ttl_seconds) do
    expiry = DateTime.add(DateTime.utc_now(), ttl_seconds, :second)
    :ets.insert(:resource_cache, {key, value, expiry})
    :ok
  end

  defp hash_filters(filters) do
    :erlang.phash2(filters)
  end

  # Initialize cache table on startup
  defp init_cache do
    case :ets.info(:resource_cache) do
      :undefined ->
        :ets.new(:resource_cache, [:set, :public, :named_table])

      _ ->
        :ok
    end
  end

  # Invalidate all resource cache entries
  defp invalidate_resource_cache do
    :ets.delete_all_objects(:resource_cache)
  end

  # Reset the cache (for testing)
  def reset_cache do
    :ets.delete_all_objects(:resource_cache)
  end

  @doc """
  Gets a resource by id.
  """
  def get_resource(id) when is_nil(id) or id == "" do
    {:error, :not_found}
  end

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
        IO.puts(
          "🔍 ResourceSystem.update_resource: Found resource #{resource.id}, creating changeset"
        )

        case resource
             |> Resource.changeset(attrs)
             |> RepoHelper.update() do
          {:ok, updated_resource} ->
            IO.puts("✅ ResourceSystem.update_resource: Resource updated successfully")
            # Invalidate cache
            invalidate_resource_cache()
            # Generate event for resource update
            IO.puts("🔍 ResourceSystem.update_resource: Generating resource_updated event")

            case ResourceEventGenerator.resource_updated(updated_resource.__struct__, updated_resource.id, attrs, %{action: "update"}) do
              {:ok, _event} ->
                IO.puts(
                  "✅ ResourceSystem.update_resource: resource_updated event generated successfully"
                )

              {:error, reason} ->
                IO.puts(
                  "❌ ResourceSystem.update_resource: resource_updated event generation failed: #{inspect(reason)}"
                )
            end

            Phoenix.PubSub.broadcast(
              HydepwnsLiveview.PubSub,
              "resources",
              {:resource_updated, updated_resource}
            )

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
                case ResourceEventGenerator.generate_event(transformed_resource.__struct__, %{type: "transformed", resource_id: transformed_resource.id, data: %{}, metadata: %{action: "transform"}}) do
                  {:ok, _event} ->
                    IO.puts(
                      "✅ ResourceSystem.update_resource: transformed event generated successfully"
                    )

                  {:error, reason} ->
                    IO.puts(
                      "❌ ResourceSystem.update_resource: transformed event generation failed: #{inspect(reason)}"
                    )
                end

                Phoenix.PubSub.broadcast(
                  HydepwnsLiveview.PubSub,
                  "resources",
                  {:resource_transformed, transformed_resource}
                )

                IO.puts("✅ ResourceSystem.update_resource: Returning transformed resource")
                {:ok, transformed_resource}

              {:error, _resource, _context} ->
                IO.puts(
                  "❌ ResourceSystem.update_resource: Transformations failed, returning updated resource"
                )

                # Transformation failed, but still return the updated resource
                {:ok, updated_resource}
            end

          error ->
            IO.puts(
              "❌ ResourceSystem.update_resource: RepoHelper.update failed: #{inspect(error)}"
            )

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
            # Invalidate cache
            invalidate_resource_cache()
            # Generate event for resource deletion
            event_data = Map.from_struct(deleted_resource) |> Map.drop([:__meta__, :__struct__])
            case ResourceEventGenerator.resource_deleted(deleted_resource.__struct__, deleted_resource.id, event_data, %{action: "delete"}) do
              {:ok, _event} ->
                IO.puts(
                  "✅ ResourceSystem.delete_resource: resource_deleted event generated successfully"
                )

              {:error, reason} ->
                IO.puts(
                  "❌ ResourceSystem.delete_resource: resource_deleted event generation failed: #{inspect(reason)}"
                )
            end

            # Broadcast PubSub message for real-time updates
            Phoenix.PubSub.broadcast(
              HydepwnsLiveview.PubSub,
              "resources",
              {:resource_deleted, deleted_resource}
            )

            {:ok, deleted_resource}

          error ->
            error
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
