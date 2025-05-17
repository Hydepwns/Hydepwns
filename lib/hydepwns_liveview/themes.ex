defmodule HydepwnsLiveview.Themes do
  @moduledoc """
  DEPRECATED: This module is maintained for backward compatibility.
  Please use HydepwnsLiveview.ThemeSystem for new code.
  """

  alias HydepwnsLiveview.ThemeSystem

  def list_themes, do: ThemeSystem.list_themes()
  def get_theme!(id), do: ThemeSystem.get_theme!(id)
  def get_theme_by_name(name), do: ThemeSystem.get_theme_by_name(name)
  def get_default_theme, do: ThemeSystem.get_default_theme()
  def create_theme(attrs \\ %{}), do: ThemeSystem.create_theme(attrs)
  def update_theme(theme, attrs), do: ThemeSystem.update_theme(theme, attrs)
  def delete_theme(theme), do: ThemeSystem.delete_theme(theme)
  def change_theme(theme, attrs \\ %{}), do: ThemeSystem.change_theme(theme, attrs)
end
