defmodule HydepwnsLiveview.ThemeSystemFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HydepwnsLiveview.ThemeSystem` context.
  """

  @doc """
  Generate a theme.
  """
  def theme_fixture(attrs \\ %{}) do
    {:ok, theme} =
      attrs
      |> Enum.into(%{
        name: "some name",
        settings: %{}
      })
      |> HydepwnsLiveview.ThemeSystem.create_theme()

    theme
  end
end
