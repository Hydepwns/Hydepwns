defmodule HydepwnsLiveviewWeb.TestHelpers do
  @moduledoc """
  Helper functions for testing LiveView components.
  """

  import Phoenix.LiveViewTest

  # Private helper functions

  defp check_element_exists?(view, selector) do
    case render(view) do
      html when is_binary(html) ->
        with {:ok, document} <- Floki.parse_document(html),
             elements when elements != [] <- Floki.find(document, selector) do
          true
        else
          _ -> false
        end
      _ -> false
    end
  end
end 