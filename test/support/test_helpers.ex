defmodule HydepwnsLiveview.TestHelpers do
  @moduledoc """
  Helper functions for tests, particularly for managing database sandbox access.
  """

  @doc """
  Allows a process to use the database sandbox connection.
  Useful for LiveView processes that need database access.
  """
  def allow_process_in_sandbox(pid \\ self()) do
    Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, pid, self())
  end

  @doc """
  Checks out a sandbox connection and sets it to manual mode.
  """
  def checkout_sandbox do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(HydepwnsLiveview.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(HydepwnsLiveview.Repo, :manual)
  end

  @doc """
  Allows a LiveView process to use the database.
  This is commonly needed in LiveView tests.
  """
  def allow_liveview_process(view_pid) do
    Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, view_pid, self())
  end
end
