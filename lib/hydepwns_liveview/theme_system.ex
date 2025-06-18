defmodule HydepwnsLiveview.ThemeSystem do
  @moduledoc """
  The ThemeSystem context.

  This module provides functions for managing themes in the application,
  including creating, updating, and retrieving themes. It also handles
  setting default themes and theme preferences.
  """

  import Ecto.Query, warn: false
  alias HydepwnsLiveview.Repo
  alias HydepwnsLiveview.ThemeSystem.Models.Theme

  @doc """
  Returns the list of themes.
  """
  def list_themes do
    Repo.all(Theme)
  end

  @doc """
  Gets a single theme.
  Raises `Ecto.NoResultsError` if the Theme does not exist.
  """
  def get_theme!(id), do: Repo.get!(Theme, id)

  @doc """
  Creates a theme.
  """
  def create_theme(attrs \\ %{}) do
    %Theme{}
    |> Theme.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a theme.
  """
  def update_theme(%Theme{} = theme, attrs) do
    theme
    |> Theme.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a theme.
  """
  def delete_theme(%Theme{} = theme) do
    Repo.delete(theme)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking theme changes.
  """
  def change_theme(%Theme{} = theme, attrs \\ %{}) do
    Theme.changeset(theme, attrs)
  end

  @doc """
  Applies a theme to the application.
  """
  def apply_theme(%Theme{} = theme) do
    # Update the application's theme settings
    Application.put_env(:hydepwns_liveview, :theme, %{
      mode: theme.mode,
      primary_color: theme.primary_color,
      secondary_color: theme.secondary_color,
      background_color: theme.background_color,
      text_color: theme.text_color
    })

    {:ok, theme}
  end

  @doc """
  Ensures a default theme exists.
  """
  def ensure_default_theme do
    case get_default_theme() do
      nil -> create_default_theme()
      theme -> theme
    end
  end

  @spec get_theme_by_name(String.t()) :: Theme.t() | nil
  def get_theme_by_name(name) when is_binary(name) do
    Repo.get_by(Theme, name: name)
  end

  @spec get_default_theme() :: Theme.t() | nil
  def get_default_theme do
    Repo.get_by(Theme, is_default: true)
  end

  @spec set_default_theme(Theme.t()) :: {:ok, Theme.t()} | {:error, Ecto.Changeset.t()}
  def set_default_theme(%Theme{} = theme) do
    update_theme(theme, %{is_default: true})
  end

  @spec get_current_theme() :: {:ok, Theme.t()} | {:error, :no_theme}
  def get_current_theme do
    case Process.get(:current_theme) do
      nil -> {:error, :no_theme}
      theme -> {:ok, theme}
    end
  end

  # Unsets default status for all themes except the given ID
  defp unset_other_defaults(except_id) do
    from(t in Theme, where: t.id != ^except_id and t.is_default == true)
    |> Repo.update_all(set: [is_default: false])
  end

  defp create_default_theme do
    %Theme{
      name: "Default",
      is_default: true,
      colors: %{
        primary: "#4F46E5",
        secondary: "#6B7280",
        background: "#FFFFFF",
        text: "#111827"
      }
    }
    |> Repo.insert!()
  end
end
