defmodule HydepwnsLiveview.ThemeSystemFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HydepwnsLiveview.ThemeSystem` context.
  """

  @doc """
  Generate a theme.
  """
  def theme_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Test Theme",
        mode: "light",
        primary_color: "#3B82F6",
        secondary_color: "#10B981",
        background_color: "#FFFFFF",
        text_color: "#1F2937",
        is_default: false
      })

    {:ok, theme} = HydepwnsLiveview.ThemeSystem.create_theme(attrs)
    theme
  end

  @doc """
  Generate a light theme.
  """
  def light_theme_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Light Theme",
        mode: "light",
        primary_color: "#3B82F6",
        secondary_color: "#10B981",
        background_color: "#FFFFFF",
        text_color: "#1F2937",
        is_default: false
      })

    {:ok, theme} = HydepwnsLiveview.ThemeSystem.create_theme(attrs)
    theme
  end

  @doc """
  Generate a dark theme.
  """
  def dark_theme_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Dark Theme",
        mode: "dark",
        primary_color: "#60A5FA",
        secondary_color: "#34D399",
        background_color: "#1F2937",
        text_color: "#F9FAFB",
        is_default: false
      })

    {:ok, theme} = HydepwnsLiveview.ThemeSystem.create_theme(attrs)
    theme
  end

  @doc """
  Generate a system theme.
  Returns {:ok, theme} on success, {:error, changeset} on failure.
  """
  def system_theme_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "system",
      mode: "system",
      primary_color: "#8b5cf6",
      secondary_color: "#ec4899",
      background_color: "#111827",
      text_color: "#f9fafb",
      is_default: false,
      settings: %{
        font_size: "medium",
        line_height: "normal",
        contrast: "normal",
        animations: true
      }
    })
    |> HydepwnsLiveview.ThemeSystem.create_theme()
  end

  @doc """
  Generate a dim theme.
  Returns {:ok, theme} on success, {:error, changeset} on failure.
  """
  def dim_theme_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "dim",
      mode: "dim",
      primary_color: "#818cf8",
      secondary_color: "#6ee7b7",
      background_color: "#1f2937",
      text_color: "#e5e7eb",
      is_default: false,
      settings: %{
        font_size: "medium",
        line_height: "normal",
        contrast: "medium",
        animations: true
      }
    })
    |> HydepwnsLiveview.ThemeSystem.create_theme()
  end

  @doc """
  Generate a high contrast theme.
  Returns {:ok, theme} on success, {:error, changeset} on failure.
  """
  def high_contrast_theme_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "high-contrast-#{System.unique_integer()}",
      mode: "dark",
      primary_color: "#ffffff",
      secondary_color: "#ffffff",
      background_color: "#000000",
      text_color: "#ffffff",
      is_default: false,
      settings: %{
        font_size: "large",
        line_height: "wide",
        contrast: "high",
        animations: false
      }
    })
    |> HydepwnsLiveview.ThemeSystem.create_theme()
  end

  @doc """
  Generate a custom theme.
  """
  def custom_theme_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Custom Theme",
        mode: "light",
        primary_color: "#8B5CF6",
        secondary_color: "#F59E0B",
        background_color: "#F3F4F6",
        text_color: "#111827",
        is_default: false
      })

    {:ok, theme} = HydepwnsLiveview.ThemeSystem.create_theme(attrs)
    theme
  end

  @doc """
  Generate a list of all default themes.
  Returns a list of {:ok, theme} or {:error, changeset} results.
  """
  def default_themes_fixture do
    [
      light_theme_fixture(),
      dark_theme_fixture(),
      system_theme_fixture(),
      dim_theme_fixture()
    ]
  end
end

defmodule HydepwnsLiveview.TestSupport.ThemeFixtures do
  @moduledoc """
  Compatibility module for test theme fixtures. Provides create_test_theme/1 for use in tests.
  """
  alias HydepwnsLiveview.ThemeSystemFixtures

  @doc """
  Create a test theme. Accepts optional attrs map.
  """
  def create_test_theme(attrs \\ %{}) do
    ThemeSystemFixtures.theme_fixture(attrs)
  end
end
