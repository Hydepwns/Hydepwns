defmodule HydepwnsLiveview.Events.EventReminder do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_reminders" do
    field :title, :string
    field :message, :string
    field :reminder_time, :integer
    field :is_active, :boolean, default: true
    field :reminder_type, :string
    field :recipients, {:array, :string}

    belongs_to :event, HydepwnsLiveview.Events.Event

    timestamps()
  end

  @doc false
  def changeset(reminder, attrs) do
    reminder
    |> cast(attrs, [
      :title,
      :message,
      :reminder_time,
      :is_active,
      :reminder_type,
      :recipients,
      :event_id
    ])
    |> validate_required([:title, :message, :reminder_time, :reminder_type, :event_id])
    |> validate_inclusion(:reminder_type, ["email", "sms", "push"])
    |> validate_number(:reminder_time, greater_than: 0, less_than_or_equal_to: 48)
    |> foreign_key_constraint(:event_id)
  end
end
