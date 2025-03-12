defmodule HydepwnsLiveview.Repo.Migrations.CreateThemes do
  use Ecto.Migration

  def change do
    create table(:themes) do
      add :name, :string
      add :mode, :string
      add :colors, :map
      add :is_default, :boolean, default: false

      timestamps()
    end

    create unique_index(:themes, [:name])
  end
end
