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

  @spec list_themes() :: [Theme.t()]
  def list_themes do
    themes = Repo.all(Theme)
    themes
  end

  @spec get_theme!(term()) :: Theme.t()
  def get_theme!(id), do: Repo.get!(Theme, id)

  @spec get_theme_by_name(String.t()) :: Theme.t() | nil
  def get_theme_by_name(name) when is_binary(name) do
    Repo.get_by(Theme, name: name)
  end

  @spec get_default_theme() :: Theme.t() | nil
  def get_default_theme do
    Repo.get_by(Theme, is_default: true)
  end

  @spec create_theme(map()) :: {:ok, Theme.t()} | {:error, Ecto.Changeset.t()}
  def create_theme(attrs \\ %{}) do
    %Theme{}
    |> Theme.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_theme(Theme.t(), map()) :: {:ok, Theme.t()} | {:error, Ecto.Changeset.t()}
  def update_theme(%Theme{} = theme, attrs) do
    result =
      theme
      |> Theme.changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, theme} ->
        # If this is a default theme, unset other defaults
        if theme.__unset_other_defaults__ do
          unset_other_defaults(theme.id)
        end

        {:ok, theme}

      error ->
        error
    end
  end

  @spec delete_theme(Theme.t()) :: {:ok, Theme.t()} | {:error, Ecto.Changeset.t()}
  def delete_theme(%Theme{} = theme) do
    Repo.delete(theme)
  end

  @spec change_theme(Theme.t(), map()) :: Ecto.Changeset.t()
  def change_theme(%Theme{} = theme, attrs \\ %{}) do
    Theme.changeset(theme, attrs)
  end

  @spec set_default_theme(Theme.t()) :: {:ok, Theme.t()} | {:error, Ecto.Changeset.t()}
  def set_default_theme(%Theme{} = theme) do
    update_theme(theme, %{is_default: true})
  end

  @spec ensure_default_theme() :: Theme.t()
  def ensure_default_theme do
    case get_default_theme() do
      nil ->
        {:ok, theme} = create_theme(%{
          name: "Default",
          description: "Default theme",
          is_default: true,
          palette: %{},
          mode: "dark"
        })
        theme
      theme ->
        theme
    end
  end

  @spec get_current_theme() :: {:ok, Theme.t()} | {:error, :no_theme}
  def get_current_theme do
    case Process.get(:current_theme) do
      nil -> {:error, :no_theme}
      theme -> {:ok, theme}
    end
  end

  @spec apply_theme(Theme.t()) :: {:ok, Theme.t()} | {:error, :invalid_theme}
  def apply_theme(%Theme{} = theme) do
    Process.put(:current_theme, theme)
    {:ok, theme}
  end

  # Unsets default status for all themes except the given ID
  defp unset_other_defaults(except_id) do
    from(t in Theme, where: t.id != ^except_id and t.is_default == true)
    |> Repo.update_all(set: [is_default: false])
  end
end
