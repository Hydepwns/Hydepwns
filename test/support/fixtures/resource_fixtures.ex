defmodule HydepwnsLiveview.ResourceSystemFixtures do
  @moduledoc """
  This module contains test fixtures for the resource system.
  """

  alias HydepwnsLiveview.Resources.ResourceSystem

  @doc """
  Creates a test resource with the given attributes.
  """
  def resource_fixture(attrs \\ %{}) do
    {:ok, resource} = ResourceSystem.create_resource(attrs)
    resource
  end
end

defmodule HydepwnsLiveview.TestSupport.ResourceFixtures do
  @moduledoc """
  Test helpers for creating resource entities for tests.
  """
  alias HydepwnsLiveview.ResourceSystemFixtures

  @doc """
  Create a test resource. Accepts optional attrs map.
  Returns {:ok, resource} on success, {:error, changeset} on failure.
  """
  def create_test_resource(attrs \\ %{}) do
    unique_suffix = System.unique_integer([:positive]) |> Integer.to_string()
    attrs =
      Map.merge(
        %{
          name: "Test Resource #{unique_suffix}",
          type: "document",
          content: "Test content"
        },
        attrs
      )

    resource = ResourceSystemFixtures.resource_fixture(attrs)
    {:ok, resource}
  end

  @doc """
  Create a test user. Accepts optional attrs map.
  Returns {:ok, user} on success, {:error, changeset} on failure.
  """
  def create_user(attrs \\ %{}) do
    %HydepwnsLiveview.Schemas.User{}
    |> HydepwnsLiveview.Schemas.User.changeset(attrs)
    |> HydepwnsLiveview.Repo.insert()
  end
end
