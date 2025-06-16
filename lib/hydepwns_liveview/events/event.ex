defmodule HydepwnsLiveview.Events.Event do
  @moduledoc """
  Event schema and functions for the event sourcing system.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    field :type, :string
    field :data, :map
    field :metadata, :map, default: %{}
    field :resource_type, :string
    field :resource_id, :string
    field :timestamp, :utc_datetime
    field :version, :integer, default: 1
    field :aggregate_id, :string
    field :aggregate_type, :string
    field :correlation_id, :string
    field :causation_id, :string
    field :user_id, :binary_id

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields ~w(type data resource_type resource_id)a
  @optional_fields ~w(metadata version aggregate_id aggregate_type correlation_id causation_id user_id)a

  @doc """
  Creates a changeset for an event with validation.
  """
  def changeset(event, attrs) do
    event
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_type()
    |> validate_data()
    |> validate_metadata()
    |> validate_timestamp()
  end

  defp validate_type(changeset) do
    case get_change(changeset, :type) do
      nil -> changeset
      type when is_binary(type) and type != "" -> changeset
      _ -> add_error(changeset, :type, "must be a non-empty string")
    end
  end

  defp validate_data(changeset) do
    case get_change(changeset, :data) do
      nil -> changeset
      data when is_map(data) -> changeset
      _ -> add_error(changeset, :data, "must be a map")
    end
  end

  defp validate_metadata(changeset) do
    case get_change(changeset, :metadata) do
      nil -> changeset
      metadata when is_map(metadata) -> changeset
      _ -> add_error(changeset, :metadata, "must be a map")
    end
  end

  defp validate_timestamp(changeset) do
    case get_change(changeset, :timestamp) do
      nil -> put_change(changeset, :timestamp, DateTime.utc_now())
      timestamp when is_struct(timestamp, DateTime) -> changeset
      _ -> add_error(changeset, :timestamp, "must be a DateTime")
    end
  end

  @doc """
  Creates a new event with the given type and data.
  """
  @spec create(String.t(), map()) :: {:ok, map()} | {:error, term()}
  def create(type, data) when is_binary(type) and is_map(data) do
    case HydepwnsLiveview.Events.Core.Event.create(type, data) do
      {:ok, event} ->
        case HydepwnsLiveview.Events.EventBus.publish(event) do
          :ok -> {:ok, event}
          error -> error
        end

      error ->
        error
    end
  end
end
