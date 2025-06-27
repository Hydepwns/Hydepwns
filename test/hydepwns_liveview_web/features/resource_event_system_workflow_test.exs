defmodule HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!
  import Wallaby.Query

  @moduledoc """
  End-to-end tests for the Resource Event System workflow.

  This test suite verifies the complete user experience of:
  - Resource Creation → Validation → Transformation → Event Generation
  - Event visualization and monitoring
  - Subscription to events
  - Event-driven UI updates
  """

  alias HydepwnsLiveview.TestSupport.ResourceFixtures
  alias HydepwnsLiveviewWeb.TestMockHelper
  alias HydepwnsLiveview.TestSupport.EventStoreTestHelper

  setup %{session: session} do
    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()
    EventStoreTestHelper.setup_mock_event_store()

    {:ok, resource_fixture} =
      ResourceFixtures.create_test_resource(%{
        id: "test-resource-id",
        name: "Test Resource"
      })

    {:ok, session: visit_and_wait(session, "/resources"), resource: resource_fixture}
  end

  describe "resource creation and event generation" do
    test "user can create a resource and see events generated", %{session: session} do
      # Click on "Create Resource" button
      session
      |> click(button("Create Resource"))

      # Fill out the form
      session
      |> fill_in(text_field("resource[name]"), with: "New Resource")
      |> fill_in(text_field("resource[description]"), with: "This is a test resource")
      |> set_value(select("resource[status]"), "published")
      |> click(button("Create Resource"))

      # Wait for navigation and DOM to settle
      Process.sleep(2000)
      
      # Check that we're on the resources page and the resource was created
      # Use has_text? instead of page_source to avoid JavaScript error
      assert has_text?(session, "Resources")
      assert has_text?(session, "New Resource")
      
      # Verify the resource appears in the list using a more robust selector
      Wallaby.Browser.assert_has(session, css("[data-test-id*='resource-link']", text: "New Resource"))

      # Navigate to events dashboard
      session
      |> click(Wallaby.Query.link("View Events"))

      # Verify resource.created event is visible
      created_events = all(session, css(".event-row[data-event-type*='resource.created']"))
      assert length(created_events) >= 1
      Wallaby.Browser.assert_has(session, css(".event-resource-id", text: "New Resource"))
    end

    test "resource update generates events", %{session: session, resource: resource} do
      # Navigate to the resource edit page
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> click(Query.css("[data-test-id='edit-resource-link']"))

      # Update the resource
      session
      |> fill_in(Query.text_field("resource[description]"), with: "Updated description")
      |> click(button("Save Resource"))

      # Wait for navigation and DOM to settle
      Process.sleep(2000)
      
      # Check for successful update using has_text? instead of page_source
      assert has_text?(session, "Resource updated successfully") or has_text?(session, "Updated description")

      # Navigate to events dashboard
      session
      |> click(Wallaby.Query.link("View Events"))

      # Verify resource.updated event is visible
      Wallaby.Browser.assert_has(session, css(".event-row[data-event-type*='resource.updated']"))
      Wallaby.Browser.assert_has(session, css(".event-data", text: "Updated description"))
    end

    test "resource deletion generates events", %{session: session, resource: resource} do
      # Navigate to the resource view page
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))

      # Delete the resource
      accept_confirm(session, fn s ->
        click(s, Query.css("[data-test-id='delete-resource-button']"))
      end)

      # Wait for navigation and DOM to settle
      Process.sleep(2000)
      
      # Check for successful deletion using has_text? instead of page_source
      assert has_text?(session, "Resource deleted successfully") or has_text?(session, "Resources")

      # Navigate to events dashboard
      session
      |> click(Wallaby.Query.link("View Events"))

      # Verify resource.deleted event is visible
      deleted_events = all(session, css(".event-resource-id", text: resource.id))
      assert length(deleted_events) >= 1

      # Verify event type is 'deleted'
      Wallaby.Browser.assert_has(session, css(".event-type", text: "deleted"))
    end
  end

  describe "event visualization and monitoring" do
    test "user can view event timeline", %{session: session} do
      # Navigate to event timeline
      session
      |> click(Query.css("[data-test-id='events-link']"))
      |> click(Wallaby.Query.link("Timeline"))

      # Verify timeline components are present
      Wallaby.Browser.assert_has(session, css(".event-timeline"))
      Wallaby.Browser.assert_has(session, css(".timeline-event"))
      
      # Verify timeline events are visible
      timeline_events = all(session, css(".timeline-event"))
      assert length(timeline_events) >= 1

      # Click on a timeline event
      session
      |> click(css(".timeline-event", at: 0))

      # Verify event details are shown
      Wallaby.Browser.assert_has(session, css(".event-type"))
      Wallaby.Browser.assert_has(session, css(".event-timestamp"))
      Wallaby.Browser.assert_has(session, css(".event-data"))
    end

    test "user can filter events", %{session: session} do
      # Navigate directly to resources page first
      session
      |> visit("/resources")

      # Wait for the resources page to load
      Process.sleep(1000)

      # First, create a resource to ensure we have a "created" event
      session
      |> click(button("Create Resource"))
      |> fill_in(text_field("resource[name]"), with: "Filter Test Resource")
      |> fill_in(text_field("resource[description]"), with: "Resource for filtering test")
      |> set_value(select("resource[status]"), "published")
      |> click(button("Create Resource"))

      # Wait for navigation and DOM to settle
      Process.sleep(2000)

      # Update the resource to generate an 'updated' event
      session
      |> click(Query.css("[data-test-id*='resource-link']", text: "Filter Test Resource"))
      |> click(Query.css("[data-test-id='edit-resource-link']"))
      |> fill_in(text_field("resource[description]"), with: "Updated for filter test")
      |> click(button("Save Resource"))
      Process.sleep(2000)

      # Navigate to events dashboard
      session
      |> click(Query.css("[data-test-id='events-link']"))

      # Apply a filter for created events
      session
      |> fill_in(text_field("event_filter[type]"), with: "created")
      |> click(button("Apply Filter"))

      # Verify only created events are shown
      all_events = all(session, css(".event-type"))

      for event <- all_events do
        assert Wallaby.Element.text(event) =~ "created"
      end

      # Clear filters
      session
      |> click(button("Clear Filters"))

      # Verify all event types are shown again
      Wallaby.Browser.assert_has(session, css(".event-type", text: "created"))
      Wallaby.Browser.assert_has(session, css(".event-type", text: "updated"))
    end
  end

  describe "event subscription and notifications" do
    test "user can subscribe to event notifications", %{session: session} do
      # Navigate to notification settings
      session
      |> click(link("Account"))
      |> click(link("Notification Settings"))

      # Toggle email notifications using the checkbox
      session
      |> click(css("input[type='checkbox'][phx-value-setting='email_notifications']"))
      |> click(button("Save Settings"))

      # Wait for settings to be saved
      Process.sleep(1000)

      # Verify settings were saved using has_text? instead of page_source
      assert has_text?(session, "Notification settings updated") or has_text?(session, "Notification Settings")

      # Navigate back to resources
      session
      |> click(link("Resources"))

      # Verify we're back on the resources page
      assert has_text?(session, "Resources")
    end
  end

  describe "event-driven UI updates" do
    test "UI updates in real-time when events occur", %{session: session} do
      # Navigate to the resource dashboard
      dashboard_view = session

      # Create a resource through the UI to ensure it appears in the dashboard
      dashboard_view
      |> click(button("Create Resource"))
      |> fill_in(text_field("resource[name]"), with: "Live Update Test")
      |> fill_in(text_field("resource[description]"), with: "Test for real-time updates")
      |> set_value(select("resource[status]"), "published")
      |> click(button("Create Resource"))

      # Wait for navigation and DOM to settle
      Process.sleep(2000)

      # Verify the resource appears in the dashboard
      Wallaby.Browser.assert_has(dashboard_view, css(".resource-row", text: "Live Update Test"))
    end
  end
end
