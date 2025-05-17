defmodule HydepwnsLiveview.TestSupport.ResourceFixtures do
  @moduledoc """
  Test helpers for creating resource entities for tests.
  """
  alias HydepwnsLiveview.ResourceSystemFixtures

  @doc """
  Create a test resource. Accepts optional attrs map.
  """
  def create_test_resource(attrs \\ %{}) do
    # If you have a ResourceSystemFixtures, delegate to it; otherwise, implement inline
    if Code.ensure_loaded?(ResourceSystemFixtures) and function_exported?(ResourceSystemFixtures, :resource_fixture, 1) do
      ResourceSystemFixtures.resource_fixture(attrs)
    else
      # Inline fallback: adjust fields as needed for your schema
      {:ok, resource} =
        Map.merge(%{
          name: "Test Resource #{System.unique_integer()}",
          description: "A resource for testing",
          type: "default",
          data: %{}
        }, attrs)
        |> HydepwnsLiveview.ResourceSystem.create_resource()
      resource
    end
  end

  @doc """
  Create a test user. Accepts optional attrs map.
  """
  def create_user(attrs \\ %{}) do
    %HydepwnsLiveview.Schemas.User{}
    |> HydepwnsLiveview.Schemas.User.changeset(attrs)
    |> HydepwnsLiveview.Repo.insert!()
  end
end 