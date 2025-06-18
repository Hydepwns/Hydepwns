defmodule HydepwnsLiveview.Events.Schemas.ReplaySession do
  @moduledoc """
  Schema for managing event replay sessions, tracking their status and results.
  Used for replaying event sequences and analyzing historical state changes.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]
  schema "event_replay_sessions" do
    field :name, :string
    field :resource_type, :string
    field :resource_id, :string
    field :start_event_id, :binary_id
    field :end_event_id, :binary_id
    field :status, :string, default: "pending"
    field :metadata, :map, default: %{}
    field :results, :map, default: %{}

    timestamps()
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t() | binary(),
          name: String.t(),
          resource_type: String.t(),
          resource_id: String.t(),
          start_event_id: Ecto.UUID.t() | binary() | nil,
          end_event_id: Ecto.UUID.t() | binary() | nil,
          status: String.t(),
          metadata: map(),
          results: map(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(session, attrs) do
    session
    |> cast(attrs, [
      :name,
      :resource_type,
      :resource_id,
      :start_event_id,
      :end_event_id,
      :status,
      :metadata,
      :results
    ])
    |> validate_required([:name, :resource_type, :resource_id])
    |> validate_inclusion(:status, ["pending", "running", "completed", "failed"])
  end
end
