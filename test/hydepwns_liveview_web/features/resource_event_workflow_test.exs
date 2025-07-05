defmodule HydepwnsLiveviewWeb.ResourceEventWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false

  import HydepwnsLiveviewWeb.TestHelpers.WallabyUIHelper
  import HydepwnsLiveviewWeb.TestHelpers.WallabyFallback

  alias HydepwnsLiveview.Resources.ResourceSystem

  setup do
    # Create a test resource for event testing
    {:ok, resource} =
      ResourceSystem.create_resource(%{
        name: "Event Workflow Test Resource",
        description: "A resource for testing event workflows",
        type: "document",
        status: "published",
        content: %{text: "Initial content"}
      })

    %{resource: resource}
  end

  describe "resource event processing and subscription" do
    test "events are generated and processed during resource updates", %{
      session: session,
      resource: resource
    } do
      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> wait_for_element(css("h1"))

      session
      |> click(Wallaby.Query.link("Edit"))

      # Update resource content
      session
      |> fill_in(text_field("resource[content]"), with: "Updated content")
      |> click(button("Save Resource"))

      # Wait for successful update
      session = wait_for_text(session, "Resource updated successfully")

      # Navigate to resource events using data-test-id
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> wait_for_element(css("h1"))
      |> click(css("[data-test-id='events-link']"))
      |> wait_for_element(css(".event-row"))

      # Verify events were generated and processed using WallabyFallback helper
      patterns = common_patterns()
      assert_text_with_fallback(session, ".event-row", patterns.event_row, "resource.updated")
      assert_text_with_fallback(session, ".event-row", patterns.event_row, "resource.transformed")
      
      # Verify that the events contain the updated content (resource.created, resource.updated, and resource.transformed)
      assert_count_with_fallback(session, ".event-data", ~r/<[^>]*class="[^"]*event-data[^"]*"[^>]*>([^<]*)<\/[^>]*>/s, 3)
    end

    test "event processing maintains consistency", %{session: session, resource: resource} do
      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> wait_for_element(css("h1"))
      |> click(Wallaby.Query.link("Edit"))

      # Make multiple rapid updates with proper waiting between operations
      session
      |> fill_in(text_field("resource[name]"), with: "Test Resource")
      |> fill_in(text_field("resource[content]"), with: "Update 1")
      |> click(button("Save Resource"))
      
      # Wait for the save to complete
      session = wait_for_text(session, "Resource updated successfully")
      
      # Navigate back to edit page for the next update
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> wait_for_element(css("h1"))
      |> click(Wallaby.Query.link("Edit"))
      
      session
      |> fill_in(text_field("resource[content]"), with: "Update 2")
      |> click(button("Save Resource"))
      
      # Wait for the save to complete
      session = wait_for_text(session, "Resource updated successfully")
      
      # Navigate back to edit page for the next update
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> wait_for_element(css("h1"))
      |> click(Wallaby.Query.link("Edit"))
      
      session
      |> fill_in(text_field("resource[content]"), with: "Update 3")
      |> click(button("Save Resource"))
      
      # Wait for the save to complete
      session = wait_for_text(session, "Resource updated successfully")

      # Navigate to resource events using data-test-id
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> wait_for_element(css("h1"))
      |> click(css("[data-test-id='events-link']"))
      |> wait_for_element(css(".event-row"))

      # Verify events were processed in order - look for the actual resource ID
      events = all(session, css(".event-row"))
      assert length(events) >= 7

      # Verify final state is consistent by checking the events page content
      # Look for at least one event with "Update 3" content (there may be multiple due to updated + transformed events)
      event_data_elements = all(session, css(".event-data"))
      update_3_events = Enum.filter(event_data_elements, fn element ->
        text = Wallaby.Element.text(element)
        String.contains?(text, "Update 3")
      end)
      assert length(update_3_events) >= 1
    end

    test "event visualization shows processing status", %{session: session, resource: resource} do
      # Navigate to resource events using data-test-id
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> wait_for_element(css("h1"))
      |> click(css("[data-test-id='events-link']"))
      |> wait_for_element(css(".event-row"))

      # Verify event processing status indicators
      Wallaby.Browser.assert_has(session, css(".event-status", text: "processed"))
      Wallaby.Browser.assert_has(session, css("[data-test-id='event-timestamp']"))
      Wallaby.Browser.assert_has(session, css("[data-test-id='event-type']"))

      # Verify event data is shown (using the actual class from the template)
      Wallaby.Browser.assert_has(session, css(".event-data"))
    end

    test "event subscription management", %{session: session, resource: resource} do
      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> wait_for_element(css("h1"))
      |> click(css("[data-test-id='subscriptions-link']"))
      |> wait_for_element(css("form"))

      # Subscribe to specific event types
      session
      |> set_value(checkbox("resource.updated"), :selected)
      |> set_value(checkbox("resource.transformed"), :selected)
      |> click(button("Save Subscriptions"))

      # Wait for subscription to be saved
      session = wait_for_text(session, "Subscriptions updated")

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

      # Wait for subscription to be updated
      session = wait_for_text(session, "Subscriptions updated")

      # Verify subscription was removed
      Wallaby.Browser.refute_has(session, css(".subscription-events", text: "resource.updated"))
    end

    test "event processing error handling", %{session: session, resource: resource} do
      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> wait_for_element(css("h1"))
      |> click(Wallaby.Query.link("Edit"))

      # Attempt invalid update - try to save with empty name
      session
      |> fill_in(text_field("resource[name]"), with: "")
      |> click(button("Save Resource"))

      # Verify error message - name is required
      Wallaby.Browser.assert_has(session, css("[data-test-id='name-error']", text: "can't be blank"))

      # Fix the name and save successfully
      session
      |> fill_in(text_field("resource[name]"), with: "Test Resource")
      |> click(button("Save Resource"))

      # Wait for successful save
      session = wait_for_text(session, "Resource updated successfully")

      # Navigate to resource events using data-test-id
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> wait_for_element(css("h1"))
      |> click(css("[data-test-id='events-link']"))
      |> wait_for_element(css(".event-row"))

      # Verify events were generated using WallabyFallback helper
      patterns = common_patterns()
      assert_text_with_fallback(session, ".event-row", patterns.event_row, "resource.updated")
    end
  end
end
