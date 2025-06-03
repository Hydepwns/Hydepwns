defmodule ThemeHelper do
  @moduledoc """
  Test helper for ensuring at least one valid theme exists in the DB.
  Use in test setup or before mounting LiveViews that require themes.
  """

  alias HydepwnsLiveview.ThemeSystem

  @default_theme %{
    "id" => "default",
    "name" => "Default Theme",
    "mode" => "light",
    "colors" => %{"primary" => "#3b82f6", "background" => "#ffffff", "text" => "#1f2937"},
    "settings" => %{
      "animations" => true,
      "contrast" => "normal",
      "font_size" => "medium",
      "line_height" => "normal"
    },
    "is_default" => true
  }

  @doc """
  Ensures at least one theme exists in the DB. Creates a default theme if none exist.
  Returns the created or found theme struct.
  """
  def ensure_theme_exists(attrs \\ %{}) do
    themes = ThemeSystem.list_themes()
    cond do
      themes == [] ->
        {:ok, theme} = ThemeSystem.create_theme(Map.merge(@default_theme, attrs))
        theme
      Map.has_key?(attrs, :name) or Map.has_key?(attrs, "name") ->
        name = Map.get(attrs, :name) || Map.get(attrs, "name")
        ThemeSystem.get_theme_by_name(name) || List.first(themes)
      true ->
        List.first(themes)
    end
  end
end
