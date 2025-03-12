defmodule HydepwnsLiveviewWeb.ThemeController do
  use HydepwnsLiveviewWeb, :controller

  alias HydepwnsLiveview.Themes
  alias HydepwnsLiveview.Themes.Theme

  def index(conn, _params) do
    themes = Themes.list_themes()
    render(conn, :index, themes: themes)
  end

  def new(conn, _params) do
    changeset = Themes.change_theme(%Theme{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"theme" => theme_params}) do
    case Themes.create_theme(theme_params) do
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

  def show(conn, %{"id" => id}) do
    theme = Themes.get_theme!(id)
    render(conn, :show, theme: theme)
  end

  def edit(conn, %{"id" => id}) do
    theme = Themes.get_theme!(id)
    changeset = Themes.change_theme(theme)
    render(conn, :edit, theme: theme, changeset: changeset)
  end

  def update(conn, %{"id" => id, "theme" => theme_params}) do
    theme = Themes.get_theme!(id)

    case Themes.update_theme(theme, theme_params) do
      {:ok, theme} ->
        render(conn, :show, theme: theme)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: HydepwnsLiveviewWeb.ErrorJSON)
        |> render(:error, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    theme = Themes.get_theme!(id)
    {:ok, _theme} = Themes.delete_theme(theme)

    conn
    |> put_status(:no_content)
    |> send_resp(:no_content, "")
  end
end
