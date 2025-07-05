defmodule HydepwnsLiveviewWeb.ResourceEventSystemWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false

  import HydepwnsLiveviewWeb.TestHelpers.WallabyUIHelper

  alias HydepwnsLiveview.Resources.ResourceSystem

  setup do
    # Create a test resource for event testing
    {:ok, resource} =
      ResourceSystem.create_resource(%{
        name: "Event Test Resource",
        description: "A resource for testing event generation",
        type: "document",
        status: "published",
        content: %{text: "Test content"}
      })

    %{resource: resource}
  end

  describe "event generation and processing" do
    test "resource creation generates events", %{session: session} do
      # Navigate to resources page
      session
      |> visit("/resources")
      |> wait_for_text("Resources")

      # Create a new resource
      session
      |> click(button("Create Resource"))
      |> wait_for_element(css("form"))
      |> fill_in(text_field("resource[name]"), with: "Event Test Resource")
      |> fill_in(text_field("resource[description]"), with: "A resource for testing events")
      |> set_value(select("resource[status]"), "published")
      |> click(button("Create Resource"))

      # Wait for successful creation
      session = wait_for_text(session, "Resource created successfully")

      # Navigate to events dashboard
      session
      |> click(Query.css("[data-test-id='view-events-link']"))
      |> wait_for_element(css(".event-row"))

      # Verify resource.created event is visible
      created_events = all(session, css(".event-row[data-event-type*='resource.created']"))
      assert length(created_events) >= 1

      # Verify the event data contains the resource name
      event_data_elements = all(session, css(".event-row[data-event-type*='resource.created'] .event-data"))
      assert Enum.any?(event_data_elements, fn element ->
        Wallaby.Element.text(element) =~ "Event Test Resource"
      end)
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

      # Wait for successful update
      session = wait_for_text(session, "Resource updated successfully")

      # Navigate to events dashboard
      session
      |> click(Query.css("[data-test-id='view-events-link']"))
      |> wait_for_element(css(".event-row"))

      # Verify resource.updated event is visible
      updated_events = all(session, css(".event-row[data-event-type*='resource.updated'] .event-data", text: "Updated description"))
      assert length(updated_events) >= 1
    end

    test "resource deletion generates events", %{session: session, resource: resource} do
      # Navigate to the resource view page
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))

      # Delete the resource
      accept_confirm(session, fn s ->
        click(s, Query.css("[data-test-id='delete-resource-button']"))
      end)

      # Wait for successful deletion
      session = wait_for_text(session, "Resource deleted successfully")

      # Navigate to events dashboard
      session = visit(session, "/events")
      session = wait_for_element(session, css(".event-row"))

      # Verify resource.deleted event is visible
      deleted_events = all(session, css(".event-row[data-event-type*='resource.deleted']"))
      assert length(deleted_events) >= 1

      # Verify the deleted resource ID is present in the event
      resource_id_elements = all(session, css(".event-resource-id.text-xs.text-gray-500"))
      resource_ids = Enum.map(resource_id_elements, &Wallaby.Element.text/1)
      assert resource.id in resource_ids

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
      |> wait_for_text("Resources")

      # First, create a resource to ensure we have a "created" event
      session
      |> click(button("Create Resource"))
      |> wait_for_element(css("form"))
      |> fill_in(text_field("resource[name]"), with: "Filter Test Resource")
      |> fill_in(text_field("resource[description]"), with: "Resource for filtering test")
      |> set_value(select("resource[status]"), "published")
      |> click(button("Create Resource"))

      # Wait for successful creation
      session = wait_for_text(session, "Resource created successfully")

      # Update the resource to generate an 'updated' event
      session
      |> click(Query.css("[data-test-id*='resource-link']", text: "Filter Test Resource"))
      |> click(Query.css("[data-test-id='edit-resource-link']"))
      |> fill_in(text_field("resource[description]"), with: "Updated for filter test")
      |> click(button("Save Resource"))

      # Wait for successful update
      session = wait_for_text(session, "Resource updated successfully")

      # Navigate to events dashboard
      session
      |> click(Query.css("[data-test-id='events-link']"))
      |> wait_for_element(css(".event-row"))

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

      # Verify all event types are shown again - check for at least one of each type
      created_events = all(session, css(".event-type", text: "created"))
      updated_events = all(session, css(".event-type", text: "updated"))
      
      assert length(created_events) >= 1
      assert length(updated_events) >= 1
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
      session = wait_for_text(session, "Notification settings updated")

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
      |> visit("/resources")
      |> wait_for_text("Resources")

      # Create a resource to trigger real-time updates
      session
      |> click(button("Create Resource"))
      |> wait_for_element(css("form"))
      |> fill_in(text_field("resource[name]"), with: "Real-time Test Resource")
      |> fill_in(text_field("resource[description]"), with: "Testing real-time updates")
      |> set_value(select("resource[status]"), "published")
      |> click(button("Create Resource"))

      # Wait for the resource to appear in the dashboard
      session = wait_for_text(session, "Real-time Test Resource")

      # Verify the resource appears in the dashboard without page refresh
      assert has_text?(session, "Real-time Test Resource")
    end
  end

  describe "event error handling" do
    test "handles event processing errors gracefully", %{session: session} do
      # Navigate to resources page
      session
      |> visit("/resources")
      |> wait_for_text("Resources")

      # Try to create a resource with invalid data
      session
      |> click(button("Create Resource"))
      |> wait_for_element(css("form"))
      |> fill_in(text_field("resource[name]"), with: "")  # Empty name should cause validation error
      |> click(button("Create Resource"))

      # Verify error message is displayed
      assert has_text?(session, "can't be blank")

      # Fix the error and create successfully
      session
      |> fill_in(text_field("resource[name]"), with: "Valid Resource Name")
      |> fill_in(text_field("resource[description]"), with: "Valid description")
      |> set_value(select("resource[status]"), "published")
      |> click(button("Create Resource"))

      # Verify successful creation
      session = wait_for_text(session, "Resource created successfully")
    end
  end
end
