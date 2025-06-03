defmodule HydepwnsLiveviewWeb.ThemeController do
  use HydepwnsLiveviewWeb, :controller

  alias HydepwnsLiveview.ThemeSystem.Models.Theme

  @doc """
  Lists all themes.
  Phoenix controller action: renders the index page for themes.
  """
  def index(conn, _params) do
    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    render(conn, :index, themes: themes)
  end

  @doc """
  Renders the form for creating a new theme.
  Phoenix controller action: renders the new theme form.
  """
  def new(conn, _params) do
    changeset = HydepwnsLiveview.ThemeSystem.change_theme(%Theme{})
    render(conn, :new, changeset: changeset)
  end

  @doc """
  Creates a new theme.
  Phoenix controller action: handles POST to create a theme and renders result.
  """
  def create(conn, %{"theme" => theme_params}) do
    case HydepwnsLiveview.ThemeSystem.create_theme(theme_params) do
      {:ok, theme} ->
        conn
        |> put_status(:created)
        |> render(:show, theme: theme)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: HydepwnsLiveviewWeb.ErrorJSON)
        |> render(:error, changeset: changeset)
    end
  end

  @doc """
  Shows a single theme.
  Phoenix controller action: renders the show page for a theme by ID.
  """
  def show(conn, %{"id" => "new"}) do
    changeset = HydepwnsLiveview.ThemeSystem.change_theme(%Theme{})
    render(conn, :new, changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    theme = HydepwnsLiveview.ThemeSystem.get_theme!(id)
    render(conn, :show, theme: theme)
  end

  @doc """
  Renders the form for editing an existing theme.
  Phoenix controller action: renders the edit form for a theme by ID.
  """
  def edit(conn, %{"id" => "new"}) do
    changeset = HydepwnsLiveview.ThemeSystem.change_theme(%Theme{})
    render(conn, :new, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    theme = HydepwnsLiveview.ThemeSystem.get_theme!(id)
    changeset = HydepwnsLiveview.ThemeSystem.change_theme(theme)
    render(conn, :edit, theme: theme, changeset: changeset)
  end

  @doc """
  Updates an existing theme.
  Phoenix controller action: handles PUT/PATCH to update a theme and renders result.
  """
  def update(conn, %{"id" => id, "theme" => theme_params}) do
    theme = HydepwnsLiveview.ThemeSystem.get_theme!(id)

    case HydepwnsLiveview.ThemeSystem.update_theme(theme, theme_params) do
      {:ok, theme} ->
        render(conn, :show, theme: theme)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: HydepwnsLiveviewWeb.ErrorJSON)
        |> render(:error, changeset: changeset)
    end
  end

  @doc """
  Deletes a theme.
  Phoenix controller action: handles DELETE for a theme by ID.
  """
  def delete(conn, %{"id" => id}) do
    if is_nil(id) or id == "" do
      conn
      |> put_flash(:error, "Invalid theme id.")
      |> redirect(to: Routes.theme_path(conn, :index))
    else
      theme = HydepwnsLiveview.ThemeSystem.get_theme!(id)
      {:ok, _theme} = HydepwnsLiveview.ThemeSystem.delete_theme(theme)

      conn
      |> put_flash(:info, "Theme deleted successfully.")
      |> redirect(to: Routes.theme_path(conn, :index))
    end
  end
end
