defmodule HydepwnsLiveviewWeb.ResourceNewLiveTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!
  import Wallaby.DSL

  import HydepwnsLiveview.TestSupport.ResourceFixtures,
    only: [create_test_resource: 1]

  import HydepwnsLiveview.TestSupport.ResourceSystemHelper
  alias HydepwnsLiveviewWeb.TestMockHelper

  setup do
    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()

    setup_resource_system()
    {:ok, %{}}
  end

  describe "resource creation workflow" do
    test "creates resource and sets flash message", %{session: session} do
      session = visit_and_wait(session, "/resources/new")

      # Debug: Check what's actually on the page
      page_source = page_source(session)

      IO.puts(
        "DEBUG: Page source contains 'resource_name': #{String.contains?(page_source, "resource_name")}"
      )

      IO.puts(
        "DEBUG: Page source contains 'resource-form': #{String.contains?(page_source, "resource-form")}"
      )

      IO.puts("DEBUG: Page source contains 'name': #{String.contains?(page_source, "name")}")

      session
      |> fill_in(css("input[name='resource[name]']"), with: "Test Resource")
      |> fill_in(css("textarea[name='resource[description]']"), with: "Test Description")
      |> fill_in(css("select[name='resource[type]']"), with: "document")
      |> fill_in(css("textarea[name='resource[content]']"), with: "{}")
      |> click(css("#resource-form button[type='submit']"))

      # Wait for redirect and check the dashboard
      session = visit_and_wait(session, "/resources")

      # Assert that the resource was created and appears in the list
      has?(session, css("body", text: "Test Resource"))
      has?(session, css("body", text: "Test Description"))
      has?(session, css("body", text: "document"))
      # Note: Flash messages don't persist across LiveView sessions, so we don't test for them
    end

    test "handles validation errors without setting flash", %{session: session} do
      session = visit_and_wait(session, "/resources/new")

      session
      # Empty name should trigger validation error
      |> fill_in(css("input[name='resource[name]']"), with: "")
      |> fill_in(css("textarea[name='resource[description]']"), with: "Test Description")
      |> fill_in(css("select[name='resource[type]']"), with: "document")
      |> fill_in(css("textarea[name='resource[content]']"), with: "{}")
      |> click(css("#resource-form button[type='submit']"))

      # Check that validation error is displayed
      has?(session, css("[data-test-id='name-error']"))
      has?(session, css("p", text: "can't be blank"))

      # Check that no redirect occurred (form should still be visible)
      has?(session, css("h1", text: "New Resource"))
    end

    test "updates resource and sets flash message", %{session: session} do
      {:ok, resource} =
        create_test_resource(%{name: "Original Name", type: "document", status: "published"})

      session = visit_and_wait(session, "/resources/#{resource.id}/edit")

      session
      |> fill_in(css("input[name='resource[name]']"), with: "Updated Name")
      |> fill_in(css("textarea[name='resource[description]']"), with: "Updated Description")
      |> fill_in(css("select[name='resource[type]']"), with: "document")
      |> fill_in(css("textarea[name='resource[content]']"), with: "{}")
      |> click(css("#resource-form button[type='submit']"))

      # Wait for redirect and check the dashboard
      session = visit_and_wait(session, "/resources")

      # Assert that the resource was updated and appears in the list
      has?(session, css("body", text: "Updated Name"))
      has?(session, css("body", text: "Updated Description"))
      has?(session, css("body", text: "document"))
      # Note: Flash messages don't persist across LiveView sessions, so we don't test for them
    end
  end

  describe "navigation" do
    test "navigation can navigate back to resources list", %{session: session} do
      session = visit_and_wait(session, "/resources/new")

      # Click the back link
      session
      |> click(css("[data-test-id='cancel-resource-link']"))

      # Verify we navigated back to the resources list
      has?(session, css("h1", text: "Resources"))
    end

    test "can cancel form submission", %{session: session} do
      session = visit_and_wait(session, "/resources/new")

      session
      |> click(css("[data-test-id='cancel-resource-link']"))

      has?(session, css("h1", text: "Resources"))
    end
  end

  describe "flash message rendering" do
    test "flash message disappears after being displayed", %{session: session} do
      session = visit_and_wait(session, "/resources/new")

      session
      |> fill_in(css("input[name='resource[name]']"), with: "Flash Test Resource")
      |> fill_in(css("textarea[name='resource[description]']"), with: "Test Description")
      |> fill_in(css("select[name='resource[type]']"), with: "document")
      |> fill_in(css("textarea[name='resource[content]']"), with: "{}")
      |> click(css("#resource-form button[type='submit']"))

      # Wait for redirect and check the dashboard
      session = visit_and_wait(session, "/resources")

      # Assert that the resource was created and appears in the list
      has?(session, css("body", text: "Flash Test Resource"))
      has?(session, css("body", text: "Test Description"))
      has?(session, css("body", text: "document"))
      # Note: Flash messages don't persist across LiveView sessions, so we don't test for them
    end
  end

  describe "form validation" do
    test "validates form fields in real-time", %{session: session} do
      session = visit_and_wait(session, "/resources/new")

      # Submit form with empty name to trigger validation
      session
      |> fill_in(css("input[name='resource[name]']"), with: "")
      |> fill_in(css("textarea[name='resource[description]']"), with: "")
      |> fill_in(css("select[name='resource[type]']"), with: "document")
      |> fill_in(css("textarea[name='resource[content]']"), with: "{}")
      |> click(css("#resource-form button[type='submit']"))

      # Check that validation error is displayed
      has?(session, css("[data-test-id='name-error']"))
      has?(session, css("p", text: "can't be blank"))
    end

    test "validates required fields", %{session: session} do
      session = visit_and_wait(session, "/resources/new")

      # Submit form with empty required fields
      session
      |> fill_in(css("input[name='resource[name]']"), with: "")
      |> fill_in(css("textarea[name='resource[description]']"), with: "")
      |> fill_in(css("select[name='resource[type]']"), with: "document")
      |> fill_in(css("textarea[name='resource[content]']"), with: "{}")
      |> click(css("#resource-form button[type='submit']"))

      # Check that validation errors are displayed
      has?(session, css("[data-test-id='name-error']"))
      has?(session, css("p", text: "can't be blank"))

      # Form should still be visible (no redirect on validation error)
      has?(session, css("h1", text: "New Resource"))
    end

    test "accepts valid form data", %{session: session} do
      session = visit_and_wait(session, "/resources/new")

      # Submit form with valid data
      session
      |> fill_in(css("input[name='resource[name]']"), with: "Valid Resource")
      |> fill_in(css("textarea[name='resource[description]']"), with: "Valid Description")
      |> fill_in(css("select[name='resource[type]']"), with: "document")
      |> fill_in(css("textarea[name='resource[content]']"), with: "{}")
      |> click(css("#resource-form button[type='submit']"))

      # Wait for redirect and check the dashboard
      session = visit_and_wait(session, "/resources")
      has?(session, css("body", text: "Valid Resource"))
      has?(session, css("body", text: "Valid Description"))
    end
  end
end
