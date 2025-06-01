defmodule HydepwnsLiveviewWeb.Features.ResourceEventWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  setup :set_mox_global
  import Wallaby.Query
  alias HydepwnsLiveviewWeb.MockHelper

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
    HydepwnsLiveview.Resources.ResourceSystem.reset_store()

    {:ok, resource} =
      ResourceFixtures.create_test_resource(%{
        name: "Test Resource",
        type: "document",
        content: "Initial content"
      })

    MockHelper.setup_mocks()

    {:ok, session: visit_and_wait(session, "/resources"), resource: resource}
  end

  describe "resource event processing and subscription" do
    test "events are generated and processed during resource updates", %{
      session: session,
      resource: resource
    } do
      MockHelper.expect_api_call(:external_api, :fetch_data, fn id ->
        {:ok,
         %{
           "id" => id,
           "name" => resource.name,
           "content" => resource.content,
           "type" => resource.type,
           "status" => "active"
         }}
      end)

      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> click(link("Edit"))

      # Update resource content
      session
      |> fill_in(text_field("resource[content]"), with: "Updated content")
      |> click(button("Save"))

      # Verify success message
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Resource updated successfully")
      )

      # Navigate to events dashboard
      session
      |> click(link("View Events"))

      # Verify events were generated and processed
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.updated"))
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.transformed"))
      Wallaby.Browser.assert_has(session, css(".event-data", text: "Updated content"))
    end

    test "event processing maintains consistency", %{session: session, resource: resource} do
      MockHelper.expect_api_call(:external_api, :fetch_data, fn id ->
        {:ok,
         %{
           "id" => id,
           "name" => resource.name,
           "content" => resource.content,
           "type" => resource.type,
           "status" => "active"
         }}
      end)

      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> click(link("Edit"))

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
      |> click(link("View Events"))

      # Verify events were processed in order
      events = all(session, css(".event-row"))
      assert length(events) >= 3

      # Verify final state is consistent
      Wallaby.Browser.assert_has(session, css(".resource-content", text: "Update 3"))
    end

    test "event visualization shows processing status", %{session: session, resource: resource} do
      MockHelper.expect_api_call(:external_api, :fetch_data, fn id ->
        {:ok,
         %{
           "id" => id,
           "name" => resource.name,
           "content" => resource.content,
           "type" => resource.type,
           "status" => "active"
         }}
      end)

      # Navigate to events dashboard
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> click(link("View Events"))

      # Verify event processing status indicators
      Wallaby.Browser.assert_has(session, css(".event-status", text: "processed"))
      Wallaby.Browser.assert_has(session, css(".event-timestamp"))
      Wallaby.Browser.assert_has(session, css(".event-type"))

      # Verify event details are shown
      Wallaby.Browser.assert_has(session, css(".event-details"))
      Wallaby.Browser.assert_has(session, css(".event-metadata"))
    end

    test "event subscription management", %{session: session, resource: resource} do
      MockHelper.expect_api_call(:external_api, :fetch_data, fn id ->
        {:ok,
         %{
           "id" => id,
           "name" => resource.name,
           "content" => resource.content,
           "type" => resource.type,
           "status" => "active"
         }}
      end)

      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> click(link("Manage Subscriptions"))

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
      MockHelper.expect_api_call(:external_api, :fetch_data, fn id ->
        {:ok,
         %{
           "id" => id,
           "name" => resource.name,
           "content" => resource.content,
           "type" => resource.type,
           "status" => "active"
         }}
      end)

      # Navigate to resource
      session
      |> click(Query.css("[data-test-id='resource-link-#{resource.id}']"))
      |> click(link("Edit"))

      # Attempt invalid update
      session
      # Invalid empty content
      |> fill_in(text_field("resource[content]"), with: "")
      |> click(button("Save"))

      # Verify error message
      Wallaby.Browser.assert_has(session, css(".error-message", text: "Content can't be blank"))

      # Navigate to events dashboard
      session
      |> click(link("View Events"))

      # Verify error event was generated
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.validation_error"))
      Wallaby.Browser.assert_has(session, css(".event-data", text: "Content can't be blank"))
    end
  end
end
