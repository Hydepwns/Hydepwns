defmodule ThemeHelper do
  @moduledoc """
  Test helper for ensuring at least one valid theme exists in the DB.
  Use in test setup or before mounting LiveViews that require themes.
  """

  alias HydepwnsLiveview.ThemeSystem

  @default_theme %{
    "name" => "Default Theme",
    "mode" => "light",
    "colors" => %{"primary" => "#3b82f6", "background" => "#ffffff", "text" => "#1f2937"},
    "settings" => %{"animations" => true, "contrast" => "normal", "font_size" => "medium", "line_height" => "normal"},
    "is_default" => true
  }

  @doc """
  Ensures at least one theme exists in the DB. Creates a default theme if none exist.
  """
  def ensure_theme_exists(attrs \\ %{}) do
    if ThemeSystem.list_themes() == [] do
      ThemeSystem.create_theme(Map.merge(@default_theme, attrs))
    end
    :ok
  end
end 