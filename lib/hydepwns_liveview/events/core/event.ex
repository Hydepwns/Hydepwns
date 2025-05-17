defmodule HydepwnsLiveview.Events.Core.Event do
  @moduledoc """
  Schema and struct for representing events in the system.

  Events are immutable records of things that have happened in the system.
  They are the core building blocks of the event-driven architecture.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]
  schema "events" do
    field :type, :string
    field :resource_id, :string
    field :resource_type, :string
    field :data, :map, default: %{}
    field :metadata, :map, default: %{}
    field :correlation_id, :binary_id
    field :causation_id, :binary_id
    field :timestamp, :utc_datetime_usec, default: nil

    timestamps()
  end

  @type t :: %__MODULE__{
    id: Ecto.UUID.t() | binary(),
    type: String.t(),
    resource_id: String.t(),
    resource_type: String.t(),
    data: map(),
    metadata: map(),
    correlation_id: Ecto.UUID.t() | binary(),
    causation_id: Ecto.UUID.t() | binary() | nil,
    timestamp: DateTime.t() | nil,
    inserted_at: NaiveDateTime.t() | nil,
    updated_at: NaiveDateTime.t() | nil
  }

  @doc """
  Creates a new event struct.

  ## Parameters

  * `type` - The type of event (required)
  * `attrs` - Map of event attributes
    * `:resource_id` - ID of the resource this event relates to (required)
    * `:resource_type` - Type of the resource this event relates to (required)
    * `:data` - The event payload data (default: %{})
    * `:metadata` - Additional metadata about the event (default: %{})
    * `:correlation_id` - ID to correlate related events (default: new UUID)
    * `:causation_id` - ID of the event that caused this one (default: nil)
    * `:timestamp` - When the event occurred (default: now)

  ## Returns

  * `{:ok, event}` - The event was created successfully
  * `{:error, changeset}` - The event failed validation
  """
  @spec create(String.t(), map()) :: {:ok, __MODULE__.t()} | {:error, Ecto.Changeset.t()}
  def create(type, attrs \\ %{}) when is_binary(type) do
    # Pre-process attributes
    attrs = Map.put(attrs, :type, type)
    attrs = set_default_timestamp(attrs)
    attrs = set_default_ids(attrs)

    %__MODULE__{}
    |> cast(attrs, [
      :type,
      :resource_id,
      :resource_type,
      :data,
      :metadata,
      :correlation_id,
      :causation_id,
      :timestamp
    ])
    |> validate_required([:type, :resource_id, :resource_type, :timestamp])
    |> validate_length(:type, min: 3)
    |> validate_length(:resource_id, min: 1)
    |> validate_length(:resource_type, min: 1)
    |> apply_action(:create)
  end

  @doc """
  Creates a new event struct, raising an error if validation fails.

  See `create/2` for parameters.

  ## Returns

  * `event` - The event struct

  ## Raises

  * `Ecto.InvalidChangesetError` - If the event is invalid
  """
  @spec create!(String.t(), map()) :: __MODULE__.t()
  def create!(type, attrs \\ %{}) do
    case create(type, attrs) do
      {:ok, event} ->
        event

      {:error, changeset} ->
        raise Ecto.InvalidChangesetError, action: :create, changeset: changeset
    end
  end

  @doc """
  Creates a follow-up event that preserves correlation context.

  This is useful for creating events that are causally related to another event.

  ## Parameters

  * `original_event` - The event that this new event follows from
  * `type` - The type of the new event
  * `attrs` - Additional attributes for the new event

  ## Returns

  * `{:ok, event}` - The event was created successfully
  * `{:error, changeset}` - The event failed validation
  """
  @spec create_follow_up(__MODULE__.t(), String.t(), map()) :: {:ok, __MODULE__.t()} | {:error, Ecto.Changeset.t()}
  def create_follow_up(original_event, type, attrs \\ %{}) do
    # Maintain the correlation ID but set the causation ID to the original event's ID
    attrs =
      Map.merge(attrs, %{
        correlation_id: original_event.correlation_id,
        causation_id: original_event.id
      })

    create(type, attrs)
  end

  # Private functions

  # Sets default timestamp if not provided
  defp set_default_timestamp(%{timestamp: _} = attrs), do: attrs
  defp set_default_timestamp(attrs), do: Map.put(attrs, :timestamp, DateTime.utc_now())

  # Sets default IDs if not provided
  defp set_default_ids(attrs) do
    attrs
    |> set_default_correlation_id()
    |> set_default_causation_id()
  end

  defp set_default_correlation_id(%{correlation_id: _} = attrs), do: attrs

  defp set_default_correlation_id(attrs),
    do: Map.put(attrs, :correlation_id, Ecto.UUID.generate())

  defp set_default_causation_id(%{causation_id: _} = attrs), do: attrs
  defp set_default_causation_id(attrs), do: Map.put(attrs, :causation_id, nil)
end
