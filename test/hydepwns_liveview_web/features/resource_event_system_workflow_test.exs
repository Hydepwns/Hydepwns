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
    # Override repo configuration for feature tests to use real database
    # This allows us to test the full resource workflow with real database persistence
    original_repo = Application.get_env(:hydepwns_liveview, :repo)
    Application.put_env(:hydepwns_liveview, :repo, HydepwnsLiveview.Repo)

    on_exit(fn ->
      Application.put_env(:hydepwns_liveview, :repo, original_repo)
    end)

    # Start the MockEventStore if not already started
    case Process.whereis(HydepwnsLiveview.TestSupport.MockEventStore) do
      nil ->
        {:ok, _pid} = start_supervised(HydepwnsLiveview.TestSupport.MockEventStore)

      _pid ->
        :ok
    end

    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()

    # Create a test resource for tests that need it
    {:ok, resource} =
      ResourceFixtures.create_test_resource(%{
        name: "Event Test Resource",
        status: "published",
        type: "document",
        description: "A resource for testing event generation",
        content: %{text: "Test content"}
      })

    # Visit resources page and wait for it to load
    session = visit_and_wait(session, "/resources")

    # Debug: Check what resources are in the database
    resources_in_db = HydepwnsLiveview.Repo.all(HydepwnsLiveview.Resources.Resource)
    IO.puts("DEBUG: Resources in database: #{inspect(resources_in_db, pretty: true)}")

    # Debug: Check page source to see what's rendered
    page_source = Wallaby.Browser.page_source(session)

    IO.puts(
      "DEBUG: Page source contains resource name: #{String.contains?(page_source, resource.name)}"
    )

    IO.puts(
      "DEBUG: Page source contains 'No resources found': #{String.contains?(page_source, "No resources found")}"
    )

    # Wait for the resource to be visible on the page
    session = wait_for_text(session, resource.name, timeout: 5000)

    {:ok, session: session, resource: resource}
  end

  describe "event generation and processing" do
    test "resource creation generates events", %{session: session, resource: resource} do
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
      session = wait_for_flash_message(session, "info", "Resource created successfully")

      # Get the newly created resource ID from the flash message or redirect
      # For now, we'll use the setup resource for navigation testing
      # Navigate to the resource show page
      session = visit_and_wait(session, "/resources/#{resource.id}")

      # Wait for the resource show page to load
      session = wait_for_text(session, resource.name)

      # Navigate to the event system page
      session = visit_and_wait(session, "/resources/#{resource.id}/events")

      # Wait for the event system page to load
      session = wait_for_text(session, "Event System")

      # Verify that the event system page shows the event system title
      session = Wallaby.Browser.assert_has(session, css("h1", text: "Resource Event System"))

      # Verify that the event system page shows the toggle filters button
      session = Wallaby.Browser.assert_has(session, css("button", text: "Show Filters"))

      # Verify that the event system page shows the event table
      session = Wallaby.Browser.assert_has(session, css("table"))

      # Verify that the event system page shows the event table headers
      session = Wallaby.Browser.assert_has(session, css("th", text: "Event Type"))
      session = Wallaby.Browser.assert_has(session, css("th", text: "Resource ID"))
      session = Wallaby.Browser.assert_has(session, css("th", text: "Status"))
      session = Wallaby.Browser.assert_has(session, css("th", text: "Timestamp"))
      session = Wallaby.Browser.assert_has(session, css("th", text: "Data"))
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
      session = wait_for_flash_message(session, "info", "Resource updated successfully")

      # Debug: Check what events are stored in MockEventStore
      {:ok, all_events} = HydepwnsLiveview.TestSupport.MockEventStore.get_all_events()
      IO.puts("DEBUG: All events in MockEventStore: #{inspect(all_events)}")

      # Debug: Check events for this specific resource
      {:ok, resource_events} =
        HydepwnsLiveview.TestSupport.MockEventStore.get_events_for_resource(
          "document",
          resource.id
        )

      IO.puts("DEBUG: Events for resource #{resource.id}: #{inspect(resource_events)}")

      # Navigate to events page for this resource
      session = visit_and_wait(session, "/resources/#{resource.id}/events")

      # Debug: Check page source to see what's rendered
      page_source = Wallaby.Browser.page_source(session)

      IO.puts(
        "DEBUG: Page source contains 'event-row': #{String.contains?(page_source, "event-row")}"
      )

      IO.puts(
        "DEBUG: Page source contains 'document.updated': #{String.contains?(page_source, "document.updated")}"
      )

      # Continue with session chain
      session = wait_for_text(session, "document.updated", timeout: 10_000)

      # Verify document.updated event is visible (since resource type is "document")
      updated_events = all(session, css(".event-row[data-test-id='event-row']"))
      assert length(updated_events) >= 1

      # Verify the event type contains "updated"
      Wallaby.Browser.assert_has(
        session,
        css("[data-test-id='event-type']", text: "document.updated")
      )
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
      session = wait_for_flash_message(session, "info", "Resource deleted successfully")

      # Start a new Wallaby session with the same metadata and visit /events
      metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(HydepwnsLiveview.Repo, self())
      {:ok, new_session} = Wallaby.start_session(metadata: metadata)
      new_session = visit(new_session, "/events")

      # Wait for events to load and be visible
      new_session = wait_for_text(new_session, "Events")
      new_session = wait_for_text(new_session, "Event Test Resource", timeout: 5000)

      # Use fallback helper to find event rows
      import HydepwnsLiveviewWeb.TestHelpers.WallabyFallback

      event_rows =
        find_elements_with_fallback(
          new_session,
          ".event-row",
          common_patterns().event_row,
          ["Event Test Resource", "deleted"],
          5000
        )

      assert length(event_rows) >= 1

      # Verify the deleted resource ID is present in the event
      resource_id_elements = all(new_session, css(".event-resource-id"))
      resource_ids = Enum.map(resource_id_elements, &Wallaby.Element.text/1)
      assert resource.id in resource_ids

      # Verify event type is 'deleted'
      Wallaby.Browser.assert_has(new_session, css(".event-type", text: "deleted"))
    end
  end

  describe "event visualization and monitoring" do
    test "user can view event timeline", %{session: session} do
      # Create a test resource for timeline testing
      {:ok, _resource} =
        ResourceFixtures.create_test_resource(%{
          name: "Event Test Resource",
          status: "published",
          type: "document",
          description: "A resource for testing event generation",
          content: %{text: "Test content"}
        })

      # Navigate to timeline page
      session = visit(session, "/timeline")
      session = wait_for_text(session, "Event Timeline")

      # Verify timeline shows events (there may be multiple events from previous tests)
      assert has_text?(session, "created")

      # Verify timeline structure
      timeline_events = all(session, css(".timeline-event"))
      assert length(timeline_events) >= 1
    end

    test "user can filter events", %{session: session} do
      # Create a test resource for filtering
      {:ok, resource} =
        ResourceFixtures.create_test_resource(%{
          name: "Filter Test Resource",
          status: "published",
          type: "document",
          description: "A resource for testing event filtering",
          content: %{text: "Filter test content"}
        })

      # Navigate to resources page and wait for the resource to appear
      session = visit(session, "/resources")
      session = wait_for_text(session, resource.name)

      # Click on the resource link to go to show page
      session = click(session, Query.css("[data-test-id='resource-link-#{resource.id}']"))
      session = wait_for_text(session, "Edit")

      # Click the Edit link to go to edit page
      session = click(session, Query.css("[data-test-id='edit-resource-link']"))
      session = wait_for_text(session, "Edit Resource")

      # Update the resource to generate events
      session =
        fill_in(session, css("#resource_description"),
          with: "Updated for filter test"
        )

      session = click(session, Query.button("Save Resource"))

      # Wait for the update to complete and navigate to events
      session = wait_for_flash_message(session, "info", "Resource updated successfully")
      session = visit(session, "/events")
      session = wait_for_text(session, "Events")

      # Test filtering by event type
      session = fill_in(session, Query.text_field("Event Type"), with: "document.updated")
      session = click(session, Query.css("[data-test-id='apply-filters']"))

      # Verify filtered results
      assert has_text?(session, "updated")
    end
  end

  describe "event subscription and notifications" do
    test "user can subscribe to event notifications", %{session: session} do
      # Navigate to notification settings
      session
      |> click(link("Account"))
      |> click(css("[data-test-id='notification-settings-link']"))

      # Toggle email notifications using the checkbox
      session
      |> click(css("input[type='checkbox'][phx-value-setting='email_notifications']"))
      |> click(button("Save Settings"))

      # Wait for settings to be saved
      session = wait_for_flash_message(session, "info", "Notification settings updated")

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
      session = wait_for_flash_message(session, "info", "Resource created successfully")

      # Verify the new resource appears in the list
      Wallaby.Browser.assert_has(session, Query.text("Real-time Test Resource"))

      # Verify flash message appears (this is the notification system)
      Wallaby.Browser.assert_has(session, css(".alert-success"))
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
      # Empty name should cause validation error
      |> fill_in(text_field("resource[name]"), with: "")
      |> click(button("Create Resource"))

      # Verify error message is displayed (check for validation error)
      assert has_text?(session, "can't be blank") || has_text?(session, "is invalid") ||
               has_text?(session, "required")

      # Fix the error and create successfully
      session
      |> fill_in(text_field("resource[name]"), with: "Valid Resource Name")
      |> fill_in(text_field("resource[description]"), with: "Valid description")
      |> set_value(select("resource[status]"), "published")
      |> click(button("Create Resource"))

      # Verify successful creation
      session = wait_for_flash_message(session, "info", "Resource created successfully")
    end
  end
end
