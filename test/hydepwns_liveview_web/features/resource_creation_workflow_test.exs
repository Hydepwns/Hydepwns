defmodule HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!

  import HydepwnsLiveview.TestSupport.ResourceFixtures,
    only: [create_test_resource: 1]

  import HydepwnsLiveview.TestSupport.ResourceSystemHelper
  alias HydepwnsLiveviewWeb.TestMockHelper

  defp accept_confirm(session) do
    # Wallaby 0.30+ does not have accept_confirm, so we simulate clicking confirm
    # If you use a custom modal, you may need to adjust this
    session |> click(Query.button("OK"))
  end

  setup do
    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()

    setup_resource_system()
    resource = create_test_resource(%{type: "document", status: "published"})
    {:ok, resource: resource}
  end

  test "user can create a new resource", %{session: session} do
    session
    |> visit("/resources/new")
    |> fill_in(Query.text_field("Name"), with: "Test Resource")
    |> fill_in(Query.text_field("Description"), with: "Test Description")
    |> click(Query.button("Save Resource"))
    # Manually visit the dashboard page to simulate the redirect
    |> visit("/resources")
    # Wait for the dashboard page to load
    |> Wallaby.Browser.assert_has(Query.text("Resources"))
    # Print the page HTML for debugging
    |> page_source()
    |> then(fn html ->
      IO.puts("\n=== PAGE HTML AFTER RESOURCE CREATION ===")
      IO.puts(html)
      IO.puts("=== END PAGE HTML ===\n")
      html
    end)
    # Check for flash message
    |> Wallaby.Browser.assert_has(Query.css("[data-test-id*='flash']"))
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
    {:ok, _resource} = create_test_resource(%{})

    session
    |> visit("/resources")
    |> click(Query.link("Delete"))
    |> accept_confirm()
    |> Wallaby.Browser.assert_has(Query.text("Resource deleted successfully"))
  end
end
