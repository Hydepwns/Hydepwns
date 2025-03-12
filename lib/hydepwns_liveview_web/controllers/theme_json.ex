defmodule HydepwnsLiveviewWeb.ThemeJSON do
  alias HydepwnsLiveview.Themes.Theme

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

  defp data(%Theme{} = theme) do
    %{
      id: theme.id,
      name: theme.name,
      mode: theme.mode,
      colors: theme.colors,
      is_default: theme.is_default,
      inserted_at: theme.inserted_at,
      updated_at: theme.updated_at
    }
  end
end
