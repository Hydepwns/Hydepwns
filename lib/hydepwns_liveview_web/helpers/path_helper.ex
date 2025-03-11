defmodule HydepwnsLiveviewWeb.Helpers.PathHelper do
  @moduledoc """
  Helper functions for handling paths in LiveView.
  """

  @doc """
  Assigns the current path to the socket without relying on params.
  This works in both the initial render and subsequent live navigation.
  """
  def assign_current_path(socket) do
    # For LiveView, we can get the current path from the URI or socket assigns
    # We don't need params which isn't available in the socket during mount
    Phoenix.Component.assign(
      socket,
      :current_path,
      case socket.assigns[:live_action] do
        nil -> "/"
        action -> "/#{action}"
      end
    )
  end

  @doc """
  Assigns a specific path to the socket.
  """
  def assign_specific_path(socket, path) do
    Phoenix.Component.assign(socket, :current_path, path)
  end
end
