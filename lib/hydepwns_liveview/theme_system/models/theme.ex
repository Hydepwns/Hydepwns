defmodule HydepwnsLiveview.ThemeSystem.Models.Theme do
  @moduledoc """
  Schema and validation for the Theme model.

  This consolidated model represents a theme in the application,
  with support for different modes, color settings, and default theme status.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "themes" do
    field :name, :string
    field :mode, :string, default: "light"
    field :colors, :map, default: %{}
    field :is_default, :boolean, default: false
    field :settings, :map, default: %{}
    field :__unset_other_defaults__, :boolean, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates a changeset for a theme.

  ## Parameters

  - theme: The theme struct to change
  - attrs: The attributes to apply to the theme

  ## Returns

  An Ecto.Changeset with validations applied
  """
  def changeset(theme, attrs) do
    attrs = for {k, v} <- attrs, into: %{}, do: {to_string(k), v}

    # Extract colors from attrs
    colors = cond do
      # If colors are provided as a nested map, use them directly
      Map.has_key?(attrs, "colors") && is_map(attrs["colors"]) ->
        attrs["colors"]
      # Otherwise, try to build from flattened fields
      true ->
        %{
          "primary" => attrs["primary"] || attrs["colors"]["primary"],
          "secondary" => attrs["secondary"] || attrs["colors"]["secondary"],
          "accent" => attrs["accent"] || attrs["colors"]["accent"],
          "background" => attrs["background"] || attrs["colors"]["background"],
          "text" => attrs["text"] || attrs["colors"]["text"],
          "border" => attrs["border"] || attrs["colors"]["border"],
          "error" => attrs["error"] || attrs["colors"]["error"],
          "success" => attrs["success"] || attrs["colors"]["success"],
          "warning" => attrs["warning"] || attrs["colors"]["warning"],
          "info" => attrs["info"] || attrs["colors"]["info"]
        }
    end

    # Extract settings from attrs
    settings = cond do
      # If settings are provided as a nested map, use them directly
      Map.has_key?(attrs, "settings") && is_map(attrs["settings"]) ->
        attrs["settings"]
      # Otherwise, try to build from flattened fields
      true ->
        %{
          "font_family" => attrs["font_family"] || attrs["settings"]["font_family"],
          "font_size" => attrs["font_size"] || attrs["settings"]["font_size"],
          "line_height" => attrs["line_height"] || attrs["settings"]["line_height"],
          "spacing_unit" => attrs["spacing_unit"] || attrs["settings"]["spacing_unit"],
          "contrast" => attrs["contrast"] || attrs["settings"]["contrast"],
          "animations" => attrs["animations"] || attrs["settings"]["animations"],
          "reduced_motion" => attrs["reduced_motion"] || attrs["settings"]["reduced_motion"]
        }
    end

    # Remove nil values
    colors = Map.filter(colors, fn {_k, v} -> v != nil end)
    settings = Map.filter(settings, fn {_k, v} -> v != nil end)

    # Merge with existing values
    colors = Map.merge(theme.colors || %{}, colors)
    settings = Map.merge(theme.settings || %{}, settings)

    attrs = Map.merge(attrs, %{
      "colors" => colors,
      "settings" => settings
    })

    theme
    |> cast(attrs, [:id, :name, :mode, :colors, :is_default, :settings])
    |> validate_required([:name, :mode])
    |> validate_inclusion(:mode, ["light", "dark", "dim", "system"])
    |> unique_constraint(:name)
    |> maybe_handle_default()
  end

  @doc """
  Validates a theme from non-schema parameters.

  Useful for validating theme settings without a database.

  ## Parameters

  - params: Map of parameters to validate

  ## Returns

  A validated map or changeset with errors
  """
  def validate_theme(params) do
    params = for {k, v} <- params, into: %{}, do: {to_string(k), v}

    types = %{
      id: :integer,
      name: :string,
      mode: :string,
      colors: :map,
      is_default: :boolean,
      settings: :map
    }

    {%{}, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:name, :mode])
    |> validate_inclusion(:mode, ["light", "dark", "dim", "system"])
  end

  # If this theme is being set as default, unset any existing default
  defp maybe_handle_default(changeset) do
    case get_change(changeset, :is_default) do
      true ->
        # Only proceed if we're actually changing to true and the changeset is valid
        if changeset.valid? do
          # Mark that we need to unset other defaults
          put_change(changeset, :__unset_other_defaults__, true)
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
