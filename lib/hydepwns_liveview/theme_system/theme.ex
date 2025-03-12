defmodule HydepwnsLiveview.ThemeSystem.Theme do
  use Ecto.Schema
  import Ecto.Changeset

  schema "themes" do
    field :name, :string
    field :settings, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(theme, attrs) do
    theme
    |> cast(attrs, [:name, :settings])
    |> validate_required([:name])
  end
end
