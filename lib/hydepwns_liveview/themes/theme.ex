defmodule HydepwnsLiveview.Themes.Theme do
  @moduledoc """
  DEPRECATED: Use HydepwnsLiveview.ThemeSystem.Models.Theme instead.

  This module is maintained for backward compatibility and delegates to
  the consolidated Theme model.
  """

  defdelegate changeset(theme, attrs), to: HydepwnsLiveview.ThemeSystem.Models.Theme

  # Re-export the schema definition
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      alias HydepwnsLiveview.ThemeSystem.Models.Theme

      # Forward to the new model
      defdelegate changeset(theme, attrs), to: Theme
    end
  end

  # Define the struct fields to match the schema
  defstruct [
    :id,
    :name,
    :mode,
    :colors,
    :is_default,
    :settings,
    :inserted_at,
    :updated_at
  ]
end
