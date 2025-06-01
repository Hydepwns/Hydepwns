defmodule HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  setup :set_mox_global

  @moduledoc """
  End-to-end tests for the Resource Creation workflow.

  This test suite verifies the complete user experience of:
  - Resource Creation
  - Validation
  - Transformation
  - Event Generation
  """

  alias HydepwnsLiveview.TestSupport.ResourceFixtures
  alias HydepwnsLiveviewWeb.MockHelper

  setup do
    # Create a resource directly for the dashboard
    HydepwnsLiveview.Resources.ResourceSystem.create_resource(%{
      name: "Test User",
      description: "A test user resource",
      type: "document",
      status: "active",
      content: "Test content for resource"
    })

    :ok
  end

  setup %{session: session} do
    # Start session and visit the resource dashboard
    session = visit_and_wait(session, "/admin/resources")
    # Dump the HTML for debugging
    html = Wallaby.Browser.page_source(session)

    IO.puts(
      "\n===== RESOURCE DASHBOARD HTML =====\n" <> html <> "\n===============================\n"
    )

    # Add Mox expectation for fetch_data
    MockHelper.setup_mocks()

    MockHelper.expect_api_call(:external_api, :fetch_data, fn _id ->
      {:ok, %{"id" => "mock", "name" => "Mock Resource", "status" => "active"}}
    end)

    {:ok, session: session}
  end

  describe "resource creation workflow" do
    test "user can create a resource with validation", %{session: session} do
      # Wait for the resource type select to be present
      try do
        Wallaby.Browser.assert_has(
          session,
          Wallaby.Query.css("[data-test-id='resource-type-select']", timeout: 2000)
        )
      rescue
        e ->
          html = Wallaby.Browser.page_source(session)

          IO.puts(
            "\n===== DEBUG: resource-type-select NOT FOUND =====\n" <>
              html <> "\n===============================\n"
          )

          reraise(e, __STACKTRACE__)
      end

      # Select a resource type first
      session =
        session
        |> click(css("[data-test-id='resource-type-select']"))
        |> click(Query.option("user"))

      # Click on "Create New Resource" button
      session
      |> click(css("[data-test-id='create-new-resource']"))

      # Try to submit empty form (validation test)
      session
      |> click(css("[data-test-id='save-resource']"))

      # Verify validation errors
      try do
        Wallaby.Browser.assert_has(
          session,
          Wallaby.Query.css(".error-message", text: "Name can't be blank", timeout: 2000)
        )
      rescue
        e ->
          html = Wallaby.Browser.page_source(session)

          IO.puts(
            "\n===== DEBUG: Name can't be blank error NOT FOUND =====\n" <>
              html <> "\n===============================\n"
          )

          reraise(e, __STACKTRACE__)
      end

      try do
        Wallaby.Browser.assert_has(
          session,
          Wallaby.Query.css(".error-message", text: "Description can't be blank", timeout: 2000)
        )
      rescue
        e ->
          html = Wallaby.Browser.page_source(session)

          IO.puts(
            "\n===== DEBUG: Description can't be blank error NOT FOUND =====\n" <>
              html <> "\n===============================\n"
          )

          reraise(e, __STACKTRACE__)
      end

      # Fill out the form with valid data
      session
      |> fill_in(css("[data-test-id='name-input']"), with: "Test Resource")
      |> fill_in(css("[data-test-id='description-input']"), with: "This is a test resource")
      |> fill_in(css("[data-test-id='type-input']"), with: "document")
      |> fill_in(css("[data-test-id='status-input']"), with: "active")
      |> click(css("[data-test-id='save-resource']"))

      # Verify resource was created
      try do
        Wallaby.Browser.assert_has(
          session,
          Wallaby.Query.css("[data-test-id='flash-success']",
            text: "Resource created successfully",
            timeout: 2000
          )
        )
      rescue
        e ->
          html = Wallaby.Browser.page_source(session)

          IO.puts(
            "\n===== DEBUG: flash-success NOT FOUND =====\n" <>
              html <> "\n===============================\n"
          )

          reraise(e, __STACKTRACE__)
      end

      # Verify resource details
      try do
        Wallaby.Browser.assert_has(session, css(".resource-name", text: "Test Resource"))
      rescue
        e ->
          html = Wallaby.Browser.page_source(session)

          IO.puts(
            "\n===== DEBUG: resource-name NOT FOUND =====\n" <>
              html <> "\n===============================\n"
          )

          reraise(e, __STACKTRACE__)
      end

      try do
        Wallaby.Browser.assert_has(
          session,
          css(".resource-description", text: "This is a test resource")
        )
      rescue
        e ->
          html = Wallaby.Browser.page_source(session)

          IO.puts(
            "\n===== DEBUG: resource-description NOT FOUND =====\n" <>
              html <> "\n===============================\n"
          )

          reraise(e, __STACKTRACE__)
      end

      try do
        Wallaby.Browser.assert_has(session, css(".resource-type", text: "document"))
      rescue
        e ->
          html = Wallaby.Browser.page_source(session)

          IO.puts(
            "\n===== DEBUG: resource-type NOT FOUND =====\n" <>
              html <> "\n===============================\n"
          )

          reraise(e, __STACKTRACE__)
      end

      try do
        Wallaby.Browser.assert_has(session, css(".resource-status", text: "active"))
      rescue
        e ->
          html = Wallaby.Browser.page_source(session)

          IO.puts(
            "\n===== DEBUG: resource-status NOT FOUND =====\n" <>
              html <> "\n===============================\n"
          )

          reraise(e, __STACKTRACE__)
      end

      # Take screenshot after form submit
      Wallaby.Browser.take_screenshot(session, name: "resource-creation-after-submit")

      IO.puts(
        "\n===== RESOURCE CREATION HTML AFTER SUBMIT =====\n" <>
          Wallaby.Browser.page_source(session) <> "\n===============================\n"
      )
    end

    test "resource transformation is applied during creation", %{session: session} do
      Wallaby.Browser.assert_has(
        session,
        Wallaby.Query.css("[data-test-id='resource-type-select']", timeout: 2000)
      )

      session =
        session
        |> click(css("[data-test-id='resource-type-select']"))
        |> click(Query.option("user"))

      session
      |> click(css("[data-test-id='create-new-resource']"))
      |> fill_in(css("[data-test-id='name-input']"), with: "Transform Test")
      |> fill_in(css("[data-test-id='content-input']"), with: "This is a test content")
      |> fill_in(css("[data-test-id='type-input']"), with: "markdown")
      |> click(css("[data-test-id='save-resource']"))

      # Verify transformation was applied
      Wallaby.Browser.assert_has(
        session,
        css(".resource-content", text: "This is a test content")
      )

      Wallaby.Browser.assert_has(session, css(".resource-html"))

      # Verify markdown was transformed to HTML
      Wallaby.Browser.assert_has(session, css(".resource-html p", text: "This is a test content"))
    end

    test "events are generated during resource creation", %{session: session} do
      Wallaby.Browser.assert_has(
        session,
        Wallaby.Query.css("[data-test-id='resource-type-select']", timeout: 2000)
      )

      session =
        session
        |> click(css("[data-test-id='resource-type-select']"))
        |> click(Query.option("user"))

      session
      |> click(css("[data-test-id='create-new-resource']"))
      |> fill_in(css("[data-test-id='name-input']"), with: "Event Test")
      |> fill_in(css("[data-test-id='description-input']"), with: "Testing event generation")
      |> click(css("[data-test-id='save-resource']"))

      # Navigate to events dashboard
      session
      |> click(link("View Events"))

      # Verify events were generated
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.created"))
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.transformed"))
      Wallaby.Browser.assert_has(session, css(".event-row", text: "resource.validated"))

      # Verify event data
      Wallaby.Browser.assert_has(session, css(".event-data", text: "Event Test"))
      Wallaby.Browser.assert_has(session, css(".event-data", text: "Testing event generation"))
    end

    test "resource creation with relationships", %{session: session} do
      Wallaby.Browser.assert_has(
        session,
        Wallaby.Query.css("[data-test-id='resource-type-select']", timeout: 2000)
      )

      session =
        session
        |> click(css("[data-test-id='resource-type-select']"))
        |> click(Query.option("user"))

      # Create a parent resource first
      session
      |> click(css("[data-test-id='create-new-resource']"))
      |> fill_in(css("[data-test-id='name-input']"), with: "Parent Resource")
      |> fill_in(css("[data-test-id='type-input']"), with: "folder")
      |> click(css("[data-test-id='save-resource']"))

      # Create a child resource
      session
      |> click(css("[data-test-id='create-new-resource']"))
      |> fill_in(css("[data-test-id='name-input']"), with: "Child Resource")
      |> fill_in(css("[data-test-id='type-input']"), with: "document")
      |> click(css("[data-test-id='parent-id-select']"))
      |> click(css("[data-test-id='parent-id-option']"))
      |> click(css("[data-test-id='save-resource']"))

      # Verify relationship was created
      Wallaby.Browser.assert_has(session, css(".resource-relationships"))
      Wallaby.Browser.assert_has(session, css(".parent-resource", text: "Parent Resource"))

      # Verify relationship events
      session
      |> click(link("View Events"))
      |> Wallaby.Browser.assert_has(css(".event-row", text: "resource.relationship.created"))
    end

    test "resource creation with validation rules", %{session: session} do
      Wallaby.Browser.assert_has(
        session,
        Wallaby.Query.css("[data-test-id='resource-type-select']", timeout: 2000)
      )

      session =
        session
        |> click(css("[data-test-id='resource-type-select']"))
        |> click(Query.option("user"))

      # Try to create a resource with invalid data
      session
      |> click(css("[data-test-id='create-new-resource']"))
      # Too short
      |> fill_in(css("[data-test-id='name-input']"), with: "a")
      # Invalid type
      |> fill_in(css("[data-test-id='type-input']"), with: "invalid_type")
      |> click(css("[data-test-id='save-resource']"))

      # Verify validation errors
      Wallaby.Browser.assert_has(
        session,
        Wallaby.Query.css(".error-message", text: "Name is too short", timeout: 2000)
      )

      Wallaby.Browser.assert_has(
        session,
        Wallaby.Query.css(".error-message", text: "Invalid resource type", timeout: 2000)
      )

      # Create with valid data
      session
      |> fill_in(css("[data-test-id='name-input']"), with: "Valid Resource")
      |> fill_in(css("[data-test-id='type-input']"), with: "document")
      |> click(css("[data-test-id='save-resource']"))

      # Verify success
      Wallaby.Browser.assert_has(
        session,
        Wallaby.Query.css("[data-test-id='flash-success']",
          text: "Resource created successfully",
          timeout: 2000
        )
      )
    end
  end
end
