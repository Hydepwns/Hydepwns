defmodule HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!
  import Wallaby.Query
  alias HydepwnsLiveviewWeb.TestMockHelper
  alias HydepwnsLiveview.TestSupport.ResourceSystemHelper

  @moduledoc """
  End-to-end tests for the Resource Event Processing and Subscription workflow.

  This test suite verifies the complete user experience of:
  - Event Generation
  - Event Processing
  - Event Subscription
  - Real-time Updates
  - Event Visualization
  """

  alias HydepwnsLiveview.TestSupport.ResourceFixtures

  setup %{session: session} do
    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()

    # Ensure the resource system is properly set up
    ResourceSystemHelper.setup_resource_system()

    {:ok, resource} =
      ResourceFixtures.create_test_resource(%{
        id: "test-resource-id",
        name: "Test Resource",
        type: "document",
        content: %{text: "Initial content"}
      })

    {:ok, session: visit_and_wait(session, "/resources"), resource: resource}
  end

  describe "resource event processing and subscription" do
    test "events are generated and processed during resource updates", %{
      session: session,
      resource: resource
    } do
      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> click(Wallaby.Query.link("Edit"))

      # Update resource content
      session
      |> fill_in(text_field("resource[content]"), with: "Updated content")
      |> click(button("Save"))

      # DEBUG: Wait a moment for any DOM updates
      :timer.sleep(1500)
      
      # DEBUG: Print the current page HTML to see what's actually rendered
      html = Wallaby.Browser.page_source(session)
      IO.puts("🔍 Current page HTML after save:")
      IO.puts(html)
      
      # DEBUG: Check if any flash elements exist at all
      flash_elements = all(session, css("[class*='alert']"))
      IO.puts("🔍 Found #{length(flash_elements)} flash elements:")
      Enum.each(flash_elements, fn element ->
        text = Wallaby.Element.text(element)
        class = Wallaby.Element.attr(element, "class")
        IO.puts("  - Class: #{class}, Text: #{text}")
      end)
      
      # DEBUG: Check if the specific alert-success element exists
      success_elements = all(session, css(".alert-success"))
      IO.puts("🔍 Found #{length(success_elements)} .alert-success elements:")
      Enum.each(success_elements, fn element ->
        text = Wallaby.Element.text(element)
        IO.puts("  - Text: #{text}")
      end)

      # Verify success message - add more specific waiting
      :timer.sleep(1500)
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Resource updated successfully")
      )

      # Navigate to events dashboard directly from the resource show page
      session
      |> click(Wallaby.Query.link("View Events"))

      # Verify events were generated and processed
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.updated"))
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.transformed"))
      
      # Verify that the events contain the updated content (both resource.updated and resource.transformed)
      assert Wallaby.Browser.all(session, css(".event-data", text: "Updated content")) |> length() == 2
    end

    test "event processing maintains consistency", %{session: session, resource: resource} do
      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> click(Wallaby.Query.link("Edit"))

      # Make multiple rapid updates
      session
      |> fill_in(text_field("resource[content]"), with: "Update 1")
      |> click(button("Save"))
      |> fill_in(text_field("resource[content]"), with: "Update 2")
      |> click(button("Save"))
      |> fill_in(text_field("resource[content]"), with: "Update 3")
      |> click(button("Save"))

      # Navigate to events dashboard
      session
      |> click(Wallaby.Query.link("View Events"))

      # Verify events were processed in order
      events = all(session, css(".event-row"))
      assert length(events) >= 3

      # Verify final state is consistent
      Wallaby.Browser.assert_has(session, css(".resource-content", text: "Update 3"))
    end

    test "event visualization shows processing status", %{session: session, resource: resource} do
      # Navigate to events dashboard
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> click(Wallaby.Query.link("View Events"))

      # Verify event processing status indicators
      Wallaby.Browser.assert_has(session, css(".event-status", text: "processed"))
      Wallaby.Browser.assert_has(session, css(".event-timestamp"))
      Wallaby.Browser.assert_has(session, css(".event-type"))

      # Verify event details are shown
      Wallaby.Browser.assert_has(session, css(".event-details"))
      Wallaby.Browser.assert_has(session, css(".event-metadata"))
    end

    test "event subscription management", %{session: session, resource: resource} do
      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> click(Wallaby.Query.link("Manage Subscriptions"))

      # Subscribe to specific event types
      session
      |> set_value(checkbox("resource.updated"), :selected)
      |> set_value(checkbox("resource.transformed"), :selected)
      |> click(button("Save Subscriptions"))

      # Verify subscription status
      Wallaby.Browser.assert_has(session, css(".subscription-status", text: "Active"))
      Wallaby.Browser.assert_has(session, css(".subscription-events", text: "resource.updated"))

      Wallaby.Browser.assert_has(
        session,
        css(".subscription-events", text: "resource.transformed")
      )

      # Unsubscribe from events
      session
      |> set_value(checkbox("resource.updated"), :unselected)
      |> click(button("Save Subscriptions"))

      # Verify subscription was removed
      Wallaby.Browser.refute_has(session, css(".subscription-events", text: "resource.updated"))
    end

    test "event processing error handling", %{session: session, resource: resource} do
      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> click(Wallaby.Query.link("Edit"))

      # Attempt invalid update - try to save with empty name instead of content
      session
      |> fill_in(text_field("resource[name]"), with: "")
      |> click(button("Save"))

      # Verify error message - name is required, not content
      Wallaby.Browser.assert_has(session, css("[data-test-id='name-error']", text: "can't be blank"))

      # Navigate to events dashboard
      session
      |> click(Wallaby.Query.link("View Events"))

      # Verify error event was generated
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.validation_error"))
      Wallaby.Browser.assert_has(session, css(".event-data", text: "can't be blank"))
    end
  end
end
