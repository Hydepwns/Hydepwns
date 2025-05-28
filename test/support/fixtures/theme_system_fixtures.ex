defmodule HydepwnsLiveview.ThemeSystemFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HydepwnsLiveview.ThemeSystem` context.
  """

  @doc """
  Generate a theme with default values.
  Returns {:ok, theme} on success, {:error, changeset} on failure.
  """
  def theme_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "test-theme-#{System.unique_integer()}",
      mode: "light",
      colors: %{
        primary: "#3b82f6",
        secondary: "#10b981",
        accent: "#f59e0b",
        background: "#ffffff",
        text: "#1f2937",
        border: "#e5e7eb",
        error: "#ef4444",
        success: "#22c55e",
        warning: "#f59e0b",
        info: "#3b82f6"
      },
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
  Generate a light theme.
  Returns {:ok, theme} on success, {:error, changeset} on failure.
  """
  def light_theme_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "light",
      mode: "light",
      colors: %{
        primary: "#3b82f6",
        secondary: "#10b981",
        accent: "#f59e0b",
        background: "#ffffff",
        text: "#1f2937",
        border: "#e5e7eb",
        error: "#ef4444",
        success: "#22c55e",
        warning: "#f59e0b",
        info: "#3b82f6"
      },
      is_default: true,
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
  Generate a dark theme.
  Returns {:ok, theme} on success, {:error, changeset} on failure.
  """
  def dark_theme_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "dark",
      mode: "dark",
      colors: %{
        primary: "#60a5fa",
        secondary: "#34d399",
        accent: "#fbbf24",
        background: "#111827",
        text: "#f9fafb",
        border: "#374151",
        error: "#f87171",
        success: "#4ade80",
        warning: "#fbbf24",
        info: "#60a5fa"
      },
      is_default: false,
      settings: %{
        font_size: "medium",
        line_height: "normal",
        contrast: "high",
        animations: true
      }
    })
    |> HydepwnsLiveview.ThemeSystem.create_theme()
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
      colors: %{
        primary: "#8b5cf6",
        secondary: "#ec4899",
        accent: "#f43f5e",
        background: "system",
        text: "system",
        border: "system",
        error: "#f87171",
        success: "#4ade80",
        warning: "#fbbf24",
        info: "#60a5fa"
      },
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
      colors: %{
        primary: "#818cf8",
        secondary: "#6ee7b7",
        accent: "#fcd34d",
        background: "#1f2937",
        text: "#e5e7eb",
        border: "#374151",
        error: "#f87171",
        success: "#4ade80",
        warning: "#fbbf24",
        info: "#60a5fa"
      },
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
      colors: %{
        primary: "#ffffff",
        secondary: "#ffffff",
        accent: "#ffffff",
        background: "#000000",
        text: "#ffffff",
        border: "#ffffff",
        error: "#ff0000",
        success: "#00ff00",
        warning: "#ffff00",
        info: "#0000ff"
      },
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
  Generate a theme with custom settings.
  Returns {:ok, theme} on success, {:error, changeset} on failure.
  """
  def custom_theme_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "custom-#{System.unique_integer()}",
      mode: "light",
      colors: %{
        primary: "#ff0000",
        secondary: "#00ff00",
        accent: "#0000ff",
        background: "#ffffff",
        text: "#000000",
        border: "#cccccc",
        error: "#ff0000",
        success: "#00ff00",
        warning: "#ffff00",
        info: "#0000ff"
      },
      is_default: false,
      settings: %{
        font_size: "small",
        line_height: "narrow",
        contrast: "low",
        animations: false
      }
    })
    |> HydepwnsLiveview.ThemeSystem.create_theme()
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
