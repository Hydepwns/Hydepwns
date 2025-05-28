defmodule HydepwnsLiveviewWeb.Features.ResourceRelationshipWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  setup :set_mox_global

  @moduledoc """
  End-to-end tests for the Resource Relationship Management workflow.

  This test suite verifies the complete user experience of:
  - Creating resource relationships
  - Managing relationship hierarchies
  - Validating relationship constraints
  - Event generation for relationship changes
  """

  alias HydepwnsLiveview.TestSupport.ResourceFixtures
  alias HydepwnsLiveviewWeb.MockHelper

  setup %{session: session} do
    unique = System.unique_integer([:positive])
    {:ok, parent} =
      ResourceFixtures.create_test_resource(%{name: "Parent Resource #{unique}", type: "folder"})

    {:ok, child} =
      ResourceFixtures.create_test_resource(%{name: "Child Resource #{unique}", type: "document"})

    # Add Mox expectation for fetch_data
    MockHelper.setup_mocks()
    MockHelper.expect_api_call(:external_api, :fetch_data, fn _id ->
      {:ok, %{"id" => "mock", "name" => "Mock Resource", "status" => "active"}}
    end)

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
      |> click(link(child.name))
      |> click(link("Edit"))

      # Set parent relationship
      session
      |> click(Query.select("resource[parent_id]"))
      |> click(Query.option(parent.name))
      |> click(button("Save"))

      # Verify relationship was created
      Wallaby.Browser.assert_has(session, css(".alert-success", text: "Resource updated successfully"))
      Wallaby.Browser.assert_has(session, css(".parent-resource", text: parent.name))

      # Verify relationship events
      session
      |> click(link("View Events"))
      |> Wallaby.Browser.assert_has(css(".event-row", text: "resource.relationship.created"))
    end

    test "user can manage multiple relationships", %{
      session: session,
      parent: parent,
      child: child
    } do
      # Create a second child
      session
      |> click(link("Create New Resource"))
      |> fill_in(text_field("resource[name]"), with: "Second Child")
      |> fill_in(text_field("resource[type]"), with: "document")
      |> click(Query.select("resource[parent_id]"))
      |> click(Query.option(parent.name))
      |> click(button("Create Resource"))

      # Navigate to parent resource
      session
      |> click(link(parent.name))

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
      |> click(link(child.name))
      |> click(link("Edit"))
      |> click(Query.select("resource[parent_id]"))
      |> click(Query.option(parent.name))
      |> click(button("Save"))

      # Try to make parent a child of child (circular)
      session
      |> click(link(parent.name))
      |> click(link("Edit"))
      |> click(Query.select("resource[parent_id]"))
      |> click(Query.option(child.name))
      |> click(button("Save"))

      # Verify error message
      Wallaby.Browser.assert_has(session, css(".error-message", text: "Circular relationship detected"))
    end

    test "user can remove relationships", %{session: session, parent: parent, child: child} do
      # First create the relationship
      session
      |> click(link(child.name))
      |> click(link("Edit"))
      |> click(Query.select("resource[parent_id]"))
      |> click(Query.option(parent.name))
      |> click(button("Save"))

      # Remove the relationship
      session
      |> click(link(child.name))
      |> click(link("Edit"))
      |> click(Query.select("resource[parent_id]"))
      |> click(Query.option(""))
      |> click(button("Save"))

      # Verify relationship was removed
      Wallaby.Browser.assert_has(session, css(".alert-success", text: "Resource updated successfully"))
      Wallaby.Browser.refute_has(session, css(".parent-resource", text: parent.name))

      # Verify relationship removal event
      session
      |> click(link("View Events"))
      |> Wallaby.Browser.assert_has(css(".event-row", text: "resource.relationship.removed"))
    end

    test "relationship constraints are enforced", %{
      session: session,
      parent: parent,
      child: child
    } do
      # Try to create invalid relationship type
      session
      |> click(link(child.name))
      |> click(link("Edit"))
      # Self-reference
      |> click(Query.select("resource[parent_id]"))
      |> click(Query.option(child.name))
      |> click(button("Save"))

      # Verify error message
      Wallaby.Browser.assert_has(session, css(".error-message", text: "Invalid relationship type"))

      # Try to create relationship with incompatible types
      session
      |> click(link("Create New Resource"))
      |> fill_in(text_field("resource[name]"), with: "Invalid Child")
      |> fill_in(text_field("resource[type]"), with: "folder")
      # Document can't be parent of folder
      |> click(Query.select("resource[parent_id]"))
      |> click(Query.option(child.name))
      |> click(button("Create Resource"))

      # Verify error message
      Wallaby.Browser.assert_has(session, css(".error-message", text: "Incompatible resource types"))
    end

    test "relationship changes trigger UI updates", %{
      session: session,
      parent: parent,
      child: child
    } do
      # Open two browser windows (simulate with two sessions)
      dashboard_view = session

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
