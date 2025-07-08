defmodule HydepwnsLiveviewWeb.ResourceEventSystemWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!
  import Wallaby.Query
  import HydepwnsLiveviewWeb.TestHelpers.WallabyUIHelper

  @moduledoc """
  End-to-end tests for the Resource Event System workflow.

  This test suite verifies the complete user experience of:
  - Event generation during resource operations
  - Event visualization and monitoring
  - Event filtering and search
  - Event-driven UI updates
  - Event subscription and notifications
  - Event error handling
  """

  alias HydepwnsLiveview.TestSupport.ResourceFixtures
  alias HydepwnsLiveviewWeb.TestMockHelper

  setup %{session: session} = _context do
    # Start the MockEventStore if not already started
    case Process.whereis(HydepwnsLiveview.TestSupport.MockEventStore) do
      nil ->
        {:ok, _pid} = start_supervised(HydepwnsLiveview.TestSupport.MockEventStore)
      _pid ->
        :ok
    end

    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()

    # Set up Ecto SQL Sandbox for Wallaby tests
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(HydepwnsLiveview.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(HydepwnsLiveview.Repo, {:shared, self()})

    # Create a test resource for tests that need it
    {:ok, resource} = ResourceFixtures.create_test_resource(%{
      name: "Event Test Resource",
      status: "published",
      type: "document",
      description: "A resource for testing event generation",
      content: %{text: "Test content"}
    })

    {:ok, session: visit_and_wait(session, "/resources"), resource: resource}
  end

  describe "event generation and processing" do
    test "resource creation generates events", %{session: session} do
      # Navigate to resources page
      session
      |> visit("/resources")
      |> wait_for_text("Resources")

      # Create a new resource using the link instead of button
      session
      |> click(Query.css("[data-test-id='create-resource-link']"))
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
      # Create a test resource for timeline testing
      {:ok, resource} = ResourceFixtures.create_test_resource(%{
        name: "Event Test Resource",
        status: "published",
        type: "document",
        description: "A resource for testing event generation",
        content: %{text: "Test content"}
      })

      # Navigate to timeline page
      session = visit(session, "/events/timeline")
      session = wait_for_text(session, "Timeline")

      # Verify timeline shows events (there may be multiple events from previous tests)
      assert has_text?(session, "document.created")

      # Verify timeline structure
      Wallaby.Browser.assert_has(session, css(".timeline-event"))
    end

    test "user can filter events", %{session: session} do
      # Create a test resource for filtering
      {:ok, resource} = ResourceFixtures.create_test_resource(%{
        name: "Filter Test Resource",
        status: "published",
        type: "document",
        description: "A resource for testing event filtering",
        content: %{text: "Filter test content"}
      })

      # Navigate to resources page and wait for the resource to appear
      session = visit(session, "/resources")
      session = wait_for_text(session, resource.name)

      # Click on the resource link
      session = click(session, Query.css("[data-test-id='resource-link-#{resource.id}']"))
      session = wait_for_text(session, "Edit Resource")

      # Update the resource to generate events
      session = fill_in(session, Query.text_field("Description"), with: "Updated for filter test")
      session = click(session, Query.button("Save Resource"))

      # Wait for the update to complete and navigate to events
      session = visit(session, "/events")
      session = wait_for_text(session, "Events")

      # Test filtering by event type
      session = fill_in(session, Query.text_field("Event Type"), with: "document.updated")
      session = click(session, Query.button("Filter"))

      # Verify filtered results
      assert has_text?(session, "document.updated")
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
      # Navigate to resources page
      session
      |> visit("/resources")
      |> wait_for_text("Resources")

      # Create a new resource to trigger real-time updates
      session
      |> click(Query.css("[data-test-id='create-resource-link']"))
      |> wait_for_element(css("form"))
      |> fill_in(text_field("resource[name]"), with: "Real-time Test Resource")
      |> fill_in(text_field("resource[description]"), with: "Testing real-time updates")
      |> set_value(select("resource[status]"), "published")
      |> click(button("Create Resource"))

      # Wait for successful creation and real-time update
      session = wait_for_text(session, "Resource created successfully")

      # Verify the new resource appears in the list
      Wallaby.Browser.assert_has(session, Query.text("Real-time Test Resource"))

      # Verify notification appears
      Wallaby.Browser.assert_has(session, css(".notification"))
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
      |> click(Query.css("[data-test-id='create-resource-link']"))
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
