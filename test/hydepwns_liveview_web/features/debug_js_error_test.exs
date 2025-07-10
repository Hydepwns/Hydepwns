defmodule HydepwnsLiveviewWeb.DebugJSErrorTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!
  import Wallaby.Query
  import HydepwnsLiveviewWeb.TestHelpers.WallabyUIHelper

  @moduledoc """
  Tests for debugging JavaScript errors in the application.
  """

  alias HydepwnsLiveviewWeb.TestMockHelper

  setup %{session: session} = _context do
    # Override repo configuration for feature tests to use real database
    # This allows us to test the full resource workflow with real database persistence
    original_repo = Application.get_env(:hydepwns_liveview, :repo)
    Application.put_env(:hydepwns_liveview, :repo, HydepwnsLiveview.Repo)

    on_exit(fn ->
      Application.put_env(:hydepwns_liveview, :repo, original_repo)
    end)

    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()

    # Set up Ecto SQL Sandbox for Wallaby tests
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(HydepwnsLiveview.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(HydepwnsLiveview.Repo, {:shared, self()})

    # Create a test resource for the parent selector in the form
    import HydepwnsLiveview.TestSupport.ResourceFixtures

    {:ok, _resource} =
      create_test_resource(%{
        name: "Test Parent Resource",
        type: "folder",
        status: "published"
      })

    {:ok, session: visit_and_wait(session, "/resources")}
  end

  test "resource creation workflow without JavaScript errors", %{session: session} do
    session
    |> visit("/resources")
    |> wait_for_text("Resources")

    # Use the link instead of button for creating resources
    session =
      session
      |> click(Query.css("[data-test-id='create-resource-link']"))
      |> wait_for_element(css("form#resource-form"))
      |> fill_in(text_field("resource[name]"), with: "Test Resource")
      |> fill_in(text_field("resource[description]"), with: "Test Description")
      |> set_value(select("resource[status]"), "published")
      |> click(button("Create Resource"))

    # Wait for successful creation
    session = wait_for_flash_message(session, "success", "Resource created successfully")
  end

  test "minimal navigation test", %{session: session} do
    session
    |> visit("/")
    |> wait_for_text("Hydepwns")

    # Navigate directly to resources page since home page doesn't have navigation
    session = visit(session, "/resources")
    session = wait_for_text(session, "Resources")

    # Try to create a resource using the link
    session = click(session, Query.css("[data-test-id='create-resource-link']"))
    session = wait_for_element(session, css("form#resource-form"))

    # Verify we're on the resource creation form
    assert has_text?(session, "New Resource")
  end
end
