defmodule HydepwnsLiveviewWeb.Features.ResourceEventSystemWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  setup :set_mox_global
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
  alias HydepwnsLiveviewWeb.MockHelper

  setup %{session: session} do
    {:ok, resource_fixture} = ResourceFixtures.create_test_resource(%{name: "Test Resource"})
    MockHelper.setup_mocks()

    MockHelper.expect_api_call(:external_api, :fetch_data, fn _id ->
      {:ok, %{"id" => "mock", "name" => "Mock Resource", "status" => "active"}}
    end)

    {:ok, session: visit_and_wait(session, "/resources"), resource: resource_fixture}
  end

  describe "resource creation and event generation" do
    test "user can create a resource and see events generated", %{session: session} do
      # Click on "Create New Resource" button
      session
      |> click(link("Create New Resource"))

      # Fill out the form
      session
      |> fill_in(text_field("resource[name]"), with: "New Resource")
      |> fill_in(text_field("resource[description]"), with: "This is a test resource")
      |> fill_in(text_field("resource[status]"), with: "active")
      |> click(button("Create Resource"))

      # Verify resource was created
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Resource created successfully")
      )

      # Navigate to events dashboard
      session
      |> click(link("View Events"))

      # Verify resource.created event is visible
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.created"))
      Wallaby.Browser.assert_has(session, css(".event-resource-id", text: "New Resource"))
    end

    test "resource update generates events", %{session: session, resource: resource} do
      # Navigate to the resource edit page
      session
      |> click(link(resource.name))
      |> click(link("Edit"))

      # Update the resource
      session
      |> fill_in(text_field("resource[description]"), with: "Updated description")
      |> click(button("Save"))

      # Verify update success
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Resource updated successfully")
      )

      # Navigate to events dashboard
      session
      |> click(link("View Events"))

      # Verify resource.updated event is visible
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.updated"))
      Wallaby.Browser.assert_has(session, css(".event-data", text: "Updated description"))
    end

    test "resource deletion generates events", %{session: session, resource: resource} do
      # Navigate to the resource view page
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))

      # Delete the resource
      accept_confirm(session, fn s ->
        click(s, button("Delete Resource"))
      end)

      # Verify deletion success
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Resource deleted successfully")
      )

      # Navigate to events dashboard
      session
      |> click(link("View Events"))

      # Verify resource.deleted event is visible
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.deleted"))
      Wallaby.Browser.assert_has(session, css(".event-resource-id", text: resource.id))
    end
  end

  describe "event visualization and monitoring" do
    test "user can view event timeline", %{session: session} do
      # Navigate to event timeline
      session
      |> click(link("Events"))
      |> click(link("Timeline"))

      # Verify timeline components are present
      Wallaby.Browser.assert_has(session, css(".event-timeline"))
      Wallaby.Browser.assert_has(session, css(".timeline-event", count: {:at_least, 1}))

      # Click on a timeline event
      session
      |> click(css(".timeline-event", at: 0))

      # Verify event details are shown
      Wallaby.Browser.assert_has(session, css(".event-details"))
      Wallaby.Browser.assert_has(session, css(".event-type"))
      Wallaby.Browser.assert_has(session, css(".event-timestamp"))
      Wallaby.Browser.assert_has(session, css(".event-data"))
    end

    test "user can filter events", %{session: session} do
      # Navigate to events dashboard
      session
      |> click(link("Events"))

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

      # Subscribe to resource.created events
      session
      |> set_value(checkbox("notification_settings[resource.created]"), :selected)
      |> click(button("Save Settings"))

      # Verify settings saved
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Notification settings updated")
      )

      # Create a new resource to trigger event
      session
      |> click(link("Resources"))
      |> click(link("Create New Resource"))
      |> fill_in(text_field("resource[name]"), with: "Notification Test")
      |> click(button("Create Resource"))

      # Verify notification appears
      Wallaby.Browser.assert_has(session, css(".notification", text: "Resource created"))
    end
  end

  describe "event-driven UI updates" do
    test "UI updates in real-time when events occur", %{session: session} do
      # Open two browser windows (simulate with two sessions)
      # In a real test environment, we'd need to use another method to open a second session
      # For this example, we'll simulate the backend event generation

      # Navigate to the resource dashboard
      dashboard_view = session

      # Generate an event from the backend
      {:ok, _event} =
        HydepwnsLiveview.Events.ResourceEventGenerator.resource_created(
          HydepwnsLiveview.Resources.TestResource,
          "live-update-test",
          %{name: "Live Update Test"}
        )

      # Verify the UI updates automatically (with small wait for update)
      Process.sleep(500)
      Wallaby.Browser.assert_has(dashboard_view, css(".resource-row", text: "Live Update Test"))

      # Verify the event count badge updates
      Wallaby.Browser.assert_has(dashboard_view, css(".event-badge", text: {:at_least, "1"}))
    end
  end
end
