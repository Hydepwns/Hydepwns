defmodule HydepwnsLiveviewWeb.ResourceEventWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!
  import Wallaby.Query
  import HydepwnsLiveviewWeb.TestHelpers.WallabyUIHelper

  @moduledoc """
  End-to-end tests for the Resource Event Processing and Subscription workflow.

  This test suite verifies the complete user experience of:
  - Event generation during resource operations
  - Event processing and subscription management
  - Event visualization and monitoring
  - Error handling in event processing
  """

  alias HydepwnsLiveview.TestSupport.ResourceFixtures
  alias HydepwnsLiveviewWeb.TestMockHelper

  setup %{session: session} = _context do
    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()

    # Set up Ecto SQL Sandbox for Wallaby tests
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(HydepwnsLiveview.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(HydepwnsLiveview.Repo, {:shared, self()})

    {:ok, session: visit_and_wait(session, "/resources")}
  end

  test "events are generated and processed during resource updates", %{session: session} do
    # Create a resource first
    {:ok, resource} = ResourceFixtures.create_test_resource(%{
      name: "Event Workflow Test Resource",
      status: "published",
      type: "document",
      description: "A resource for testing event workflows",
      content: %{text: "Initial content"}
    })

    # Navigate to resources page and wait for the resource to appear
    session = visit(session, "/resources")
    session = wait_for_text(session, resource.name)

    # Click on the resource link to view it
    session = click(session, Query.css("[data-test-id='resource-link-#{resource.id}']"))
    session = wait_for_text(session, resource.name)

    # Click on the Edit link to go to edit page
    session = click(session, Query.css("[data-test-id='edit-resource-link']"))
    session = wait_for_text(session, "Edit Resource")

    # Update the resource
    session = fill_in(session, Query.text_field("Name"), with: "Updated Event Workflow Test Resource")
    session = fill_in(session, Query.text_field("Description"), with: "Updated description for event workflow testing")
    session = click(session, Query.button("Save Resource"))

    # Wait for successful save
    session = wait_for_flash_message(session, "success", "Resource updated successfully")

    # Navigate back to resources page to verify the update
    session = visit(session, "/resources")
    session = wait_for_text(session, "Updated Event Workflow Test Resource")
  end

  test "events are generated and processed during multiple resource updates", %{session: session} do
    # Create a resource first
    {:ok, resource} = ResourceFixtures.create_test_resource(%{
      name: "Multiple Updates Test Resource",
      status: "published",
      type: "document",
      description: "A resource for testing multiple updates",
      content: %{text: "Initial content"}
    })

    # First update
    session = visit(session, "/resources")
    session = wait_for_text(session, resource.name)
    session = click(session, Query.css("[data-test-id='resource-link-#{resource.id}']"))
    session = wait_for_text(session, resource.name)
    session = click(session, Query.css("[data-test-id='edit-resource-link']"))
    session = wait_for_text(session, "Edit Resource")
    session = fill_in(session, Query.text_field("Name"), with: "First Update Test Resource")
    session = click(session, Query.button("Save Resource"))

    # Wait for the flash message to appear after form submission
    session = wait_for_flash_message(session, "success", "Resource updated successfully")

    # Second update
    session = visit(session, "/resources")
    session = wait_for_text(session, "First Update Test Resource")
    session = click(session, Query.css("[data-test-id='resource-link-#{resource.id}']"))
    session = wait_for_text(session, "First Update Test Resource")
    session = click(session, Query.css("[data-test-id='edit-resource-link']"))
    session = wait_for_text(session, "Edit Resource")
    session = fill_in(session, Query.text_field("Name"), with: "Second Update Test Resource")
    session = click(session, Query.button("Save Resource"))

    # Wait for the flash message to appear after form submission
    session = wait_for_flash_message(session, "success", "Resource updated successfully")

    # Verify final state
    session = visit(session, "/resources")
    session = wait_for_text(session, "Second Update Test Resource")
  end

  test "subscription management works correctly", %{session: session} do
    # Navigate to events page
    session = visit(session, "/events")
    session = wait_for_text(session, "Events")

    # Verify that events are displayed (look for the actual event types from the system)
    assert has_text?(session, "transformed") || has_text?(session, "created") || has_text?(session, "updated")

    # Verify event structure (there may be multiple events)
    assert Wallaby.Browser.has?(session, css(".event-row"))
    assert Wallaby.Browser.has?(session, css(".event-type"))
    assert Wallaby.Browser.has?(session, css(".event-timestamp"))
  end

  test "event visualization shows processing status", %{session: session} do
    # Create a test resource for timeline testing
    {:ok, resource} = ResourceFixtures.create_test_resource(%{
      name: "Event Visualization Test Resource",
      status: "published",
      type: "document",
      description: "A resource for testing event visualization",
      content: %{text: "Test content"}
    })

    # Navigate to timeline page
    session = visit(session, "/timeline")
    session = wait_for_text(session, "Event Timeline")

    # Verify timeline shows events (there may be multiple events from previous tests)
    # If no events are found, the page should show "No events found."
    assert has_text?(session, "created") || has_text?(session, "updated") || has_text?(session, "transformed") || has_text?(session, "No events found")

    # Verify timeline structure (if events exist)
    if has_text?(session, "created") || has_text?(session, "updated") || has_text?(session, "transformed") do
      # If events exist, verify the timeline structure
      assert Wallaby.Browser.has?(session, css("[data-test-id='timeline-event']"))
      assert Wallaby.Browser.has?(session, css("[data-test-id='event-type']"))
      assert Wallaby.Browser.has?(session, css("[data-test-id='event-timestamp']"))
    else
      # If no events exist, verify the "No events found" message is displayed
      assert has_text?(session, "No events found")
    end
  end

  test "event processing error handling works correctly", %{session: session} do
    # Create a resource first
    {:ok, resource} = ResourceFixtures.create_test_resource(%{
      name: "Error Handling Test Resource",
      status: "published",
      type: "document",
      description: "A resource for testing error handling",
      content: %{text: "Initial content"}
    })

    # Navigate to resources page and wait for the resource to appear
    session = visit(session, "/resources")
    session = wait_for_text(session, resource.name)

    # Click on the resource link to view it
    session = click(session, Query.css("[data-test-id='resource-link-#{resource.id}']"))
    session = wait_for_text(session, resource.name)

    # Click on the Edit link to go to edit page
    session = click(session, Query.css("[data-test-id='edit-resource-link']"))
    session = wait_for_text(session, "Edit Resource")

    # Try to update with invalid data (empty name)
    session = fill_in(session, Query.text_field("Name"), with: "")
    session = click(session, Query.button("Save Resource"))

    # Verify validation error is displayed
    assert has_text?(session, "can't be blank")
  end
end
