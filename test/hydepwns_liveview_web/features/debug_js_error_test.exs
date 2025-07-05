defmodule HydepwnsLiveviewWeb.DebugJSErrorTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false

  import HydepwnsLiveviewWeb.TestHelpers.WallabyUIHelper

  setup %{test: _test} do
    # Set up mocks before each test
    HydepwnsLiveviewWeb.TestMockHelper.setup_mocks()
    :ok
  end

  test "resource creation workflow without JavaScript errors", %{session: session} do
    # Start with a simple page visit
    session = visit(session, "/resources")
    |> wait_for_text("Resources")
    
    # Create a resource without triggering JavaScript errors
    session
    |> click(button("Create Resource"))
    |> wait_for_element(css("form"))
    |> fill_in(text_field("resource[name]"), with: "Test Resource")
    |> fill_in(text_field("resource[description]"), with: "Test resource description")
    |> set_value(select("resource[status]"), "published")
    |> click(button("Create Resource"))
    
    # Wait for successful creation
    session = wait_for_text(session, "Resource created successfully")
    
    # Verify the resource appears in the list
    assert has_text?(session, "Test Resource")
  end

  test "minimal navigation test", %{session: session} do
    # Test simple navigation without form submission
    session = visit(session, "/")
    |> wait_for_element(css("body"))
    
    # Navigate directly to resources page since there's no navigation menu
    session = visit(session, "/resources")
    |> wait_for_text("Resources")
    
    # Check if we can navigate without errors
    assert has_text?(session, "Resources")
    
    # Try clicking create button without filling form
    session = click(session, button("Create Resource"))
    |> wait_for_element(css("form"))
    
    # Should be on the form page
    assert has_text?(session, "Create Resource")
  end
end 