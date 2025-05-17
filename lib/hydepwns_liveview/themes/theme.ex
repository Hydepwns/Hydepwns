defmodule HydepwnsLiveview.Themes.Theme do
  @moduledoc """
  DEPRECATED: Use HydepwnsLiveview.ThemeSystem.Models.Theme instead.

  This module is maintained for backward compatibility and delegates to
  the consolidated Theme model.
  """

  defdelegate changeset(theme, attrs), to: HydepwnsLiveview.ThemeSystem.Models.Theme
end
