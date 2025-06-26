defmodule HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!
  import Wallaby.Query

  @moduledoc """
  End-to-end tests for the Resource Relationship Management workflow.

  This test suite verifies the complete user experience of:
  - Creating resource relationships
  - Managing relationship hierarchies
  - Validating relationship constraints
  - Event generation for relationship changes
  """

  alias HydepwnsLiveview.TestSupport.ResourceFixtures
  alias HydepwnsLiveviewWeb.TestMockHelper

  setup %{session: session} do
    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()

    unique = System.unique_integer([:positive])

    {:ok, parent} =
      ResourceFixtures.create_test_resource(%{
        id: "parent-#{unique}",
        name: "Parent Resource #{unique}",
        type: "folder"
      })

    {:ok, child} =
      ResourceFixtures.create_test_resource(%{
        id: "child-#{unique}",
        name: "Child Resource #{unique}",
        type: "document"
      })

    {:ok, session: visit_and_wait(session, "/resources"), parent: parent, child: child}
  end

  describe "resource relationship management" do
    test "user can create a parent-child relationship", %{
      session: session,
      parent: parent,
      child: child
    } do
      # Navigate to child resource
      session
      |> click(Wallaby.Query.link(child.name))
      |> click(Wallaby.Query.link("Edit"))

      # Set parent relationship
      session
      |> click(Wallaby.Query.select("resource[parent_id]"))
      |> click(Wallaby.Query.option(parent.name))
      |> click(Wallaby.Query.css("[data-test-id='save-resource']"))

      # Verify relationship was created
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Resource updated successfully")
      )

      Wallaby.Browser.assert_has(session, css(".parent-resource", text: parent.name))

      # Verify relationship events
      session
      |> click(Wallaby.Query.link("View Events"))
      |> Wallaby.Browser.assert_has(css(".event-row", text: "resource.relationship.created"))
    end

    test "user can manage multiple relationships", %{
      session: session,
      parent: parent,
      child: child
    } do
      # Create a second child
      session
      |> click(Wallaby.Query.link("Create New Resource"))
      |> fill_in(text_field("resource[name]"), with: "Second Child")
      |> fill_in(text_field("resource[type]"), with: "document")
      |> click(Wallaby.Query.select("resource[parent_id]"))
      |> click(Wallaby.Query.option(parent.name))
      |> click(button("Create Resource"))

      # Navigate to parent resource
      session
      |> click(Wallaby.Query.link(parent.name))

      # Verify both children are listed
      Wallaby.Browser.assert_has(session, css(".child-resource", text: child.name))
      Wallaby.Browser.assert_has(session, css(".child-resource", text: "Second Child"))

      # Verify relationship count
      Wallaby.Browser.assert_has(session, css(".relationship-count", text: "2"))
    end

    test "user cannot create circular relationships", %{
      session: session,
      parent: parent,
      child: child
    } do
      # First create parent-child relationship
      session
      |> click(Wallaby.Query.link(child.name))
      |> click(Wallaby.Query.link("Edit"))
      |> click(Wallaby.Query.select("resource[parent_id]"))
      |> click(Wallaby.Query.option(parent.name))
      |> click(Wallaby.Query.css("[data-test-id='save-resource']"))

      # Try to make parent a child of child (circular)
      session
      |> click(Wallaby.Query.link(parent.name))
      |> click(Wallaby.Query.link("Edit"))
      |> click(Wallaby.Query.select("resource[parent_id]"))
      |> click(Wallaby.Query.option(child.name))
      |> click(Wallaby.Query.css("[data-test-id='save-resource']"))

      # Verify error message
      Wallaby.Browser.assert_has(
        session,
        css(".error-message", text: "Circular relationship detected")
      )
    end

    test "user can remove relationships", %{session: session, parent: parent, child: child} do
      # First create the relationship
      session
      |> click(Wallaby.Query.link(child.name))
      |> click(Wallaby.Query.link("Edit"))
      |> click(Wallaby.Query.select("resource[parent_id]"))
      |> click(Wallaby.Query.option(parent.name))
      |> click(Wallaby.Query.css("[data-test-id='save-resource']"))

      # Remove the relationship
      session
      |> click(Wallaby.Query.link(child.name))
      |> click(Wallaby.Query.link("Edit"))
      |> click(Wallaby.Query.select("resource[parent_id]"))
      |> click(Wallaby.Query.option(""))
      |> click(Wallaby.Query.css("[data-test-id='save-resource']"))

      # Verify relationship was removed
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Resource updated successfully")
      )

      Wallaby.Browser.refute_has(session, css(".parent-resource", text: parent.name))

      # Verify relationship removal event
      session
      |> click(Wallaby.Query.link("View Events"))
      |> Wallaby.Browser.assert_has(css(".event-row", text: "resource.relationship.removed"))
    end

    test "relationship constraints are enforced", %{
      session: session,
      parent: _parent,
      child: child
    } do
      # Try to create invalid relationship type
      session
      |> click(Wallaby.Query.link(child.name))
      |> click(Wallaby.Query.link("Edit"))
      # Self-reference
      |> click(Wallaby.Query.select("resource[parent_id]"))
      |> click(Wallaby.Query.option(child.name))
      |> click(Wallaby.Query.css("[data-test-id='save-resource']"))

      # Verify error message
      Wallaby.Browser.assert_has(
        session,
        css(".error-message", text: "Invalid relationship type")
      )

      # Try to create relationship with incompatible types
      session
      |> click(Wallaby.Query.link("Create New Resource"))
      |> fill_in(text_field("resource[name]"), with: "Invalid Child")
      |> fill_in(text_field("resource[type]"), with: "folder")
      # Document can't be parent of folder
      |> click(Wallaby.Query.select("resource[parent_id]"))
      |> click(Wallaby.Query.option(child.name))
      |> click(Wallaby.Query.css("[data-test-id='save-resource']"))

      # Verify error message
      Wallaby.Browser.assert_has(
        session,
        css(".error-message", text: "Incompatible resource types")
      )
    end

    test "relationship changes trigger UI updates", %{
      session: session,
      parent: parent,
      child: child
    } do
      # Open two browser windows (simulate with two sessions)
      _dashboard_view = session

      # Create relationship from backend
      {:ok, _relationship} =
        HydepwnsLiveview.Resources.RelationshipManager.create_relationship(
          parent.id,
          child.id,
          "parent_child"
        )

      # Verify UI updates automatically
      Process.sleep(500)
      Wallaby.Browser.assert_has(dashboard_view, css(".relationship-row", text: parent.name))
      Wallaby.Browser.assert_has(dashboard_view, css(".relationship-row", text: child.name))

      # Verify relationship count updates
      Wallaby.Browser.assert_has(dashboard_view, css(".relationship-count", text: "1"))
    end
  end
end
