defmodule HydepwnsLiveviewWeb.ThemeHTML do
  use HydepwnsLiveviewWeb, :html

  embed_templates "theme_html/*"

  @doc """
  Renders a theme form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def theme_form(assigns)
end
