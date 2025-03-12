defmodule HydepwnsLiveview.Themes do
  @moduledoc """
  The Themes context.
  """

  import Ecto.Query, warn: false
  alias HydepwnsLiveview.Repo

  alias HydepwnsLiveview.Themes.Theme

  @doc """
  Returns the list of themes.

  ## Examples

      iex> list_themes()
      [%Theme{}, ...]

  """
  def list_themes do
    Repo.all(Theme)
  end

  @doc """
  Gets a single theme.

  Raises `Ecto.NoResultsError` if the Theme does not exist.

  ## Examples

      iex> get_theme!(123)
      %Theme{}

      iex> get_theme!(456)
      ** (Ecto.NoResultsError)

  """
  def get_theme!(id), do: Repo.get!(Theme, id)

  @doc """
  Gets a single theme by name.

  Returns nil if the Theme does not exist.

  ## Examples

      iex> get_theme_by_name("dark")
      %Theme{}

      iex> get_theme_by_name("nonexistent")
      nil

  """
  def get_theme_by_name(name) when is_binary(name) do
    Repo.get_by(Theme, name: name)
  end

  @doc """
  Gets the default theme.

  Returns nil if no default theme exists.

  ## Examples

      iex> get_default_theme()
      %Theme{}

      iex> get_default_theme()
      nil

  """
  def get_default_theme do
    Repo.get_by(Theme, is_default: true)
  end

  @doc """
  Creates a theme.

  ## Examples

      iex> create_theme(%{field: value})
      {:ok, %Theme{}}

      iex> create_theme(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_theme(attrs \\ %{}) do
    result =
      %Theme{}
      |> Theme.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, theme} ->
        if theme.is_default do
          unset_other_defaults(theme.id)
        end

        {:ok, theme}

      error ->
        error
    end
  end

  @doc """
  Updates a theme.

  ## Examples

      iex> update_theme(theme, %{field: new_value})
      {:ok, %Theme{}}

      iex> update_theme(theme, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_theme(%Theme{} = theme, attrs) do
    result =
      theme
      |> Theme.changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, updated_theme} ->
        if updated_theme.is_default do
          unset_other_defaults(updated_theme.id)
        end

        {:ok, updated_theme}

      error ->
        error
    end
  end

  @doc """
  Deletes a theme.

  ## Examples

      iex> delete_theme(theme)
      {:ok, %Theme{}}

      iex> delete_theme(theme)
      {:error, %Ecto.Changeset{}}

  """
  def delete_theme(%Theme{} = theme) do
    Repo.delete(theme)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking theme changes.

  ## Examples

      iex> change_theme(theme)
      %Ecto.Changeset{data: %Theme{}}

  """
  def change_theme(%Theme{} = theme, attrs \\ %{}) do
    Theme.changeset(theme, attrs)
  end

  # Unset default flag for all other themes
  defp unset_other_defaults(current_id) do
    query =
      from t in Theme,
        where: t.is_default == true and t.id != ^current_id

    Repo.update_all(query, set: [is_default: false])
  end
end
