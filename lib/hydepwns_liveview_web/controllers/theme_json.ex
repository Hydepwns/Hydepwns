defmodule HydepwnsLiveviewWeb.ThemeJSON do
  alias HydepwnsLiveview.ThemeSystem.Models.Theme

  @doc """
  Renders a list of themes.
  """
  def index(%{themes: themes}) do
    %{data: for(theme <- themes, do: data(theme))}
  end

  @doc """
  Renders a single theme.
  """
  def show(%{theme: theme}) do
    %{data: data(theme)}
  end

  @doc """
  Renders a theme.
  """
  def data(%Theme{} = theme) do
    %{
      id: theme.id,
      name: theme.name,
      description: theme.description,
      colors: theme.colors,
      fonts: theme.fonts,
      spacing: theme.spacing,
      border_radius: theme.border_radius,
      shadows: theme.shadows,
      inserted_at: theme.inserted_at,
      updated_at: theme.updated_at
    }
  end
end
