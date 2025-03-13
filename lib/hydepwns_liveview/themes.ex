defmodule HydepwnsLiveview.Themes do
  @moduledoc """
  The Themes context.

  DEPRECATED: This module is maintained for backward compatibility.
  Please use HydepwnsLiveview.ThemeSystem for new code.
  """

  import Ecto.Query, warn: false
  alias HydepwnsLiveview.Repo
  alias HydepwnsLiveview.Themes.Theme
  alias HydepwnsLiveview.ThemeSystem

  @doc """
  Returns the list of themes.

  DEPRECATED: Use ThemeSystem.list_themes/0 instead.

  ## Examples

      iex> list_themes()
      [%Theme{}, ...]

  """
  def list_themes do
    IO.warn(
      "HydepwnsLiveview.Themes.list_themes/0 is deprecated. " <>
        "Use HydepwnsLiveview.ThemeSystem.list_themes/0 instead."
    )

    ThemeSystem.list_themes()
  end

  @doc """
  Gets a single theme.

  DEPRECATED: Use ThemeSystem.get_theme!/1 instead.

  Raises `Ecto.NoResultsError` if the Theme does not exist.

  ## Examples

      iex> get_theme!(123)
      %Theme{}

      iex> get_theme!(456)
      ** (Ecto.NoResultsError)

  """
  def get_theme!(id) do
    IO.warn(
      "HydepwnsLiveview.Themes.get_theme!/1 is deprecated. " <>
        "Use HydepwnsLiveview.ThemeSystem.get_theme!/1 instead."
    )

    ThemeSystem.get_theme!(id)
  end

  @doc """
  Gets a single theme by name.

  DEPRECATED: Use ThemeSystem.get_theme_by_name/1 instead.

  Returns nil if the Theme does not exist.

  ## Examples

      iex> get_theme_by_name("dark")
      %Theme{}

      iex> get_theme_by_name("nonexistent")
      nil

  """
  def get_theme_by_name(name) when is_binary(name) do
    IO.warn(
      "HydepwnsLiveview.Themes.get_theme_by_name/1 is deprecated. " <>
        "Use HydepwnsLiveview.ThemeSystem.get_theme_by_name/1 instead."
    )

    ThemeSystem.get_theme_by_name(name)
  end

  @doc """
  Gets the default theme.

  DEPRECATED: Use ThemeSystem.get_default_theme/0 instead.

  Returns nil if no default theme exists.

  ## Examples

      iex> get_default_theme()
      %Theme{}

      iex> get_default_theme()
      nil

  """
  def get_default_theme do
    IO.warn(
      "HydepwnsLiveview.Themes.get_default_theme/0 is deprecated. " <>
        "Use HydepwnsLiveview.ThemeSystem.get_default_theme/0 instead."
    )

    ThemeSystem.get_default_theme()
  end

  @doc """
  Creates a theme.

  DEPRECATED: Use ThemeSystem.create_theme/1 instead.

  ## Examples

      iex> create_theme(%{field: value})
      {:ok, %Theme{}}

      iex> create_theme(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_theme(attrs \\ %{}) do
    IO.warn(
      "HydepwnsLiveview.Themes.create_theme/1 is deprecated. " <>
        "Use HydepwnsLiveview.ThemeSystem.create_theme/1 instead."
    )

    ThemeSystem.create_theme(attrs)
  end

  @doc """
  Updates a theme.

  DEPRECATED: Use ThemeSystem.update_theme/2 instead.

  ## Examples

      iex> update_theme(theme, %{field: new_value})
      {:ok, %Theme{}}

      iex> update_theme(theme, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_theme(%Theme{} = theme, attrs) do
    IO.warn(
      "HydepwnsLiveview.Themes.update_theme/2 is deprecated. " <>
        "Use HydepwnsLiveview.ThemeSystem.update_theme/2 instead."
    )

    ThemeSystem.update_theme(theme, attrs)
  end

  @doc """
  Deletes a theme.

  DEPRECATED: Use ThemeSystem.delete_theme/1 instead.

  ## Examples

      iex> delete_theme(theme)
      {:ok, %Theme{}}

      iex> delete_theme(theme)
      {:error, %Ecto.Changeset{}}

  """
  def delete_theme(%Theme{} = theme) do
    IO.warn(
      "HydepwnsLiveview.Themes.delete_theme/1 is deprecated. " <>
        "Use HydepwnsLiveview.ThemeSystem.delete_theme/1 instead."
    )

    ThemeSystem.delete_theme(theme)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking theme changes.

  DEPRECATED: Use ThemeSystem.change_theme/2 instead.

  ## Examples

      iex> change_theme(theme)
      %Ecto.Changeset{data: %Theme{}}

  """
  def change_theme(%Theme{} = theme, attrs \\ %{}) do
    IO.warn(
      "HydepwnsLiveview.Themes.change_theme/2 is deprecated. " <>
        "Use HydepwnsLiveview.ThemeSystem.change_theme/2 instead."
    )

    ThemeSystem.change_theme(theme, attrs)
  end
end
