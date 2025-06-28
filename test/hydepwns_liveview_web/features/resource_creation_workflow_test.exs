defmodule HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!

  import HydepwnsLiveview.TestSupport.ResourceFixtures,
    only: [create_test_resource: 1]

  import HydepwnsLiveview.TestSupport.ResourceSystemHelper
  alias HydepwnsLiveviewWeb.TestMockHelper

  setup do
    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()

    # Start MockEventStore if not already started
    case HydepwnsLiveview.TestSupport.MockEventStore.start_link([]) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end

    setup_resource_system()
    resource = create_test_resource(%{type: "document", status: "published"})
    {:ok, resource: resource}
  end

  test "user can create a new resource", %{session: session} do
    session
    |> visit("/resources/new")
    |> fill_in(Query.text_field("Name"), with: "Unique Test Resource #{:rand.uniform(10000)}")
    |> fill_in(Query.text_field("Description"), with: "Test Description")
    |> click(Query.button("Create Resource"))
    |> visit("/resources")
    |> Wallaby.Browser.assert_has(Query.text("Resources"))
    
    # Assert that a resource link with the unique name is present
    |> Wallaby.Browser.assert_has(Query.link("Unique Test Resource"))
  end

  test "user can edit an existing resource", %{session: session} do
    {:ok, resource} = create_test_resource(%{})

    session
    |> visit("/resources/#{resource.id}/edit")
    |> fill_in(Query.text_field("Name"), with: "Updated Resource")
    |> fill_in(Query.text_field("Description"), with: "Updated Description")
    |> click(Query.button("Save Resource"))
    |> Wallaby.Browser.assert_has(Query.text("Resource updated successfully"))
  end

  test "user can delete a resource", %{session: session} do
    {:ok, resource} = create_test_resource(%{name: "Resource to Delete"})
    
    session
    |> visit("/resources")
    |> Wallaby.Browser.assert_has(Query.text("Resources"))
    |> click(Query.css("[data-test-id='delete-resource-#{resource.id}']"))
    |> Wallaby.Browser.assert_has(Query.text("Resources"))
    
    # Wait for the resource to be removed and assert it's no longer present
    |> fn session ->
      refute_has(session, Query.link("Resource to Delete"), timeout: 2000)
      session
    end.()
  end
end
