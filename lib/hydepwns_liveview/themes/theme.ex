defmodule HydepwnsLiveview.Themes.Theme do
  use Ecto.Schema
  import Ecto.Changeset

  schema "themes" do
    field :name, :string
    field :mode, :string, default: "light"
    field :colors, :map, default: %{}
    field :is_default, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(theme, attrs) do
    theme
    |> cast(attrs, [:name, :mode, :colors, :is_default])
    |> validate_required([:name, :mode])
    |> validate_inclusion(:mode, ["light", "dark", "system"])
    |> unique_constraint(:name)
  end

  # If this theme is being set as default, unset any existing default
  defp maybe_handle_default(changeset) do
    case get_change(changeset, :is_default) do
      true ->
        # Only proceed if we're actually changing to true and the changeset is valid
        if changeset.valid? do
          # Get the current ID (if it exists)
          theme_id = get_field(changeset, :id)

          # Unset any existing default themes
          # We'll do this in the Themes context instead to avoid query issues
          # in the changeset
          changeset = put_change(changeset, :__unset_other_defaults__, true)
          changeset
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
