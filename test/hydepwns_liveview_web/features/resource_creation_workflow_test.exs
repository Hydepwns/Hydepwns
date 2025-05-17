defmodule HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false

  @moduledoc """
  End-to-end tests for the Resource Creation workflow.

  This test suite verifies the complete user experience of:
  - Resource Creation
  - Validation
  - Transformation
  - Event Generation
  """

  import Wallaby.Query
  import Wallaby.Browser
  alias HydepwnsLiveview.TestSupport.ResourceFixtures

  setup %{session: session} do
    # Start session and visit the resource dashboard
    {:ok, session: visit_and_wait(session, "/resources")}
  end

  describe "resource creation workflow" do
    test "user can create a resource with validation", %{session: session} do
      # Click on "Create New Resource" button
      session
      |> click(link("Create New Resource"))

      # Try to submit empty form (validation test)
      session
      |> click(button("Create Resource"))

      # Verify validation errors
      assert_has(session, css(".error-message", text: "Name can't be blank"))
      assert_has(session, css(".error-message", text: "Description can't be blank"))

      # Fill out the form with valid data
      session
      |> fill_in(text_field("resource[name]"), with: "Test Resource")
      |> fill_in(text_field("resource[description]"), with: "This is a test resource")
      |> fill_in(text_field("resource[type]"), with: "document")
      |> fill_in(text_field("resource[status]"), with: "active")
      |> click(button("Create Resource"))

      # Verify resource was created
      assert_has(session, css(".alert-success", text: "Resource created successfully"))

      # Verify resource details
      assert_has(session, css(".resource-name", text: "Test Resource"))
      assert_has(session, css(".resource-description", text: "This is a test resource"))
      assert_has(session, css(".resource-type", text: "document"))
      assert_has(session, css(".resource-status", text: "active"))
    end

    test "resource transformation is applied during creation", %{session: session} do
      # Create a resource with transformation rules
      session
      |> click(link("Create New Resource"))
      |> fill_in(text_field("resource[name]"), with: "Transform Test")
      |> fill_in(text_field("resource[content]"), with: "This is a test content")
      |> fill_in(text_field("resource[type]"), with: "markdown")
      |> click(button("Create Resource"))

      # Verify transformation was applied
      assert_has(session, css(".resource-content", text: "This is a test content"))
      assert_has(session, css(".resource-html"))

      # Verify markdown was transformed to HTML
      assert_has(session, css(".resource-html p", text: "This is a test content"))
    end

    test "events are generated during resource creation", %{session: session} do
      # Create a new resource
      session
      |> click(link("Create New Resource"))
      |> fill_in(text_field("resource[name]"), with: "Event Test")
      |> fill_in(text_field("resource[description]"), with: "Testing event generation")
      |> click(button("Create Resource"))

      # Navigate to events dashboard
      session
      |> click(link("View Events"))

      # Verify events were generated
      assert_has(session, css(".event-row", text: "resource.created"))
      assert_has(session, css(".event-row", text: "resource.transformed"))
      assert_has(session, css(".event-row", text: "resource.validated"))

      # Verify event data
      assert_has(session, css(".event-data", text: "Event Test"))
      assert_has(session, css(".event-data", text: "Testing event generation"))
    end

    test "resource creation with relationships", %{session: session} do
      # Create a parent resource first
      session
      |> click(link("Create New Resource"))
      |> fill_in(text_field("resource[name]"), with: "Parent Resource")
      |> fill_in(text_field("resource[type]"), with: "folder")
      |> click(button("Create Resource"))

      # Create a child resource
      session
      |> click(link("Create New Resource"))
      |> fill_in(text_field("resource[name]"), with: "Child Resource")
      |> fill_in(text_field("resource[type]"), with: "document")
      |> click(Query.select("resource[parent_id]"))
      |> click(Query.option("Parent Resource"))
      |> click(button("Create Resource"))

      # Verify relationship was created
      assert_has(session, css(".resource-relationships"))
      assert_has(session, css(".parent-resource", text: "Parent Resource"))

      # Verify relationship events
      session
      |> click(link("View Events"))
      |> assert_has(css(".event-row", text: "resource.relationship.created"))
    end

    test "resource creation with validation rules", %{session: session} do
      # Try to create a resource with invalid data
      session
      |> click(link("Create New Resource"))
      # Too short
      |> fill_in(text_field("resource[name]"), with: "a")
      # Invalid type
      |> fill_in(text_field("resource[type]"), with: "invalid_type")
      |> click(button("Create Resource"))

      # Verify validation errors
      assert_has(session, css(".error-message", text: "Name is too short"))
      assert_has(session, css(".error-message", text: "Invalid resource type"))

      # Create with valid data
      session
      |> fill_in(text_field("resource[name]"), with: "Valid Resource")
      |> fill_in(text_field("resource[type]"), with: "document")
      |> click(button("Create Resource"))

      # Verify success
      assert_has(session, css(".alert-success", text: "Resource created successfully"))
    end
  end
end
