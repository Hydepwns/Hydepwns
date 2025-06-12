defmodule HydepwnsLiveviewWeb.ThemeView do
  use HydepwnsLiveviewWeb, :html

  def render("show.json", %{theme: theme}) do
    %{
      id: theme.id,
      name: theme.name,
      description: theme.description,
      css_file: theme.css_file,
      settings: theme.settings,
      status: theme.status
    }
  end
end

  