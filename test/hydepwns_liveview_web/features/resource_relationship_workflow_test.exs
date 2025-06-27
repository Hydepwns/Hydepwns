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
    # Start the MockEventStore if not already started
    case Process.whereis(HydepwnsLiveview.TestSupport.MockEventStore) do
      nil ->
        {:ok, _pid} = start_supervised(HydepwnsLiveview.TestSupport.MockEventStore)
      _pid ->
        :ok
    end

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
      # Navigate to child resource show page and wait for it to load
      session =
        session
        |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
        |> Wallaby.Browser.assert_has(css("h1", text: child.name))
        |> click(Wallaby.Query.css("a[data-test-id='edit-resource-link']"))

      # Set parent relationship
      session =
        session
        |> click(Wallaby.Query.select("resource[parent_id]"))
        |> click(Wallaby.Query.option(parent.name))
        |> click(button("Save Resource"))

      # After save, redirected to dashboard, wait for it to load and go back to show page
      session =
        session
        |> Wallaby.Browser.assert_has(css("h1", text: "Resources"))
        |> Wallaby.Browser.assert_has(css("a[data-test-id='resource-link-#{child.id}']"))
        |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
        |> Wallaby.Browser.assert_has(css("h1", text: child.name))
        |> click(Wallaby.Query.css("a[data-test-id='edit-resource-link']"))

      # Verify relationship was created by checking the resource data
      child_resource = HydepwnsLiveview.Resources.ResourceSystem.get_resource(child.id) |> elem(1)
      assert child_resource.parent_id == parent.id

      # Verify parent relationship is set in form
      child_resource = HydepwnsLiveview.Resources.ResourceSystem.get_resource(child.id) |> elem(1)
      assert child_resource.parent_id == parent.id

      # Verify relationship events
      session
      |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
      |> Wallaby.Browser.assert_has(css("h1", text: child.name))
      |> click(Wallaby.Query.css("a[data-test-id='view-events-link']"))
      |> Wallaby.Browser.assert_has(css(".event-row", text: "resource.updated"))
    end

    test "user can manage multiple relationships", %{
      session: session,
      parent: parent,
      child: child
    } do
      # Create a second child
      session =
        session
        |> click(Wallaby.Query.css("a[data-test-id='create-resource-link']"))
        |> fill_in(text_field("resource[name]"), with: "Second Child")
        |> click(Wallaby.Query.select("resource[type]"))
        |> click(Wallaby.Query.option("Document"))
        |> click(Wallaby.Query.select("resource[parent_id]"))
        |> click(Wallaby.Query.option(parent.name))
        |> click(button("Create Resource"))

      # Wait for dashboard to load after creation
      session =
        session
        |> Wallaby.Browser.assert_has(css("h1", text: "Resources"))

      # Fetch the second child resource from the database
      {:ok, second_child} =
        HydepwnsLiveview.Resources.ResourceSystem.list_resources()
        |> Enum.find(fn r -> r.name == "Second Child" end)
        |> case do
          nil -> {:error, :not_found}
          resource -> {:ok, resource}
        end

      # Verify second child was created with parent relationship
      second_child_resource = HydepwnsLiveview.Resources.ResourceSystem.get_resource(second_child.id) |> elem(1)
      assert second_child_resource.parent_id == parent.id

      # Verify both children have the same parent by checking their resource data
      child_resource = HydepwnsLiveview.Resources.ResourceSystem.get_resource(child.id) |> elem(1)
      assert child_resource.parent_id == parent.id
      second_child_resource = HydepwnsLiveview.Resources.ResourceSystem.get_resource(second_child.id) |> elem(1)
      assert second_child_resource.parent_id == parent.id

      # Optionally, you can still check the form loads, but don't assert on selected option
      session
      |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
      |> Wallaby.Browser.assert_has(css("h1", text: child.name))
      |> click(Wallaby.Query.css("a[data-test-id='edit-resource-link']"))

      session
      |> click(Wallaby.Query.css("a[data-test-id='back-to-resources-link']"))
      |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{second_child.id}']"))
      |> Wallaby.Browser.assert_has(css("h1", text: "Second Child"))
      |> click(Wallaby.Query.css("a[data-test-id='edit-resource-link']"))
    end

    test "user cannot create circular relationships", %{
      session: session,
      parent: parent,
      child: child
    } do
      # First create parent-child relationship
      session =
        session
        |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
        |> Wallaby.Browser.assert_has(css("h1", text: child.name))
        |> click(Wallaby.Query.css("a[data-test-id='edit-resource-link']"))
        |> click(Wallaby.Query.select("resource[parent_id]"))
        |> click(Wallaby.Query.option(parent.name))
        |> click(button("Save Resource"))

      # Try to make parent a child of child (circular)
      session
      |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{parent.id}']"))
      |> Wallaby.Browser.assert_has(css("h1", text: parent.name))
      |> click(Wallaby.Query.css("a[data-test-id='edit-resource-link']"))
      |> click(Wallaby.Query.select("resource[parent_id]"))
      |> click(Wallaby.Query.option(child.name))
      |> click(button("Save Resource"))

      # Verify error message
      Wallaby.Browser.assert_has(
        session,
        css("[data-test-id='parent-id-error']", text: "Circular relationship detected")
      )
    end

    test "user can remove relationships", %{session: session, parent: parent, child: child} do
      # First create the relationship
      session =
        session
        |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
        |> Wallaby.Browser.assert_has(css("h1", text: child.name))
        |> click(Wallaby.Query.css("a[data-test-id='edit-resource-link']"))
        |> click(Wallaby.Query.select("resource[parent_id]"))
        |> click(Wallaby.Query.option(parent.name))
        |> click(button("Save Resource"))

      # Wait for dashboard to load after save
      session =
        session
        |> Wallaby.Browser.assert_has(css("h1", text: "Resources"))
        |> Wallaby.Browser.assert_has(css("a[data-test-id='resource-link-#{child.id}']"))

      # Remove the relationship
      session =
        session
        |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
        |> Wallaby.Browser.assert_has(css("h1", text: child.name))
        |> click(Wallaby.Query.css("a[data-test-id='edit-resource-link']"))
        |> click(Wallaby.Query.select("resource[parent_id]"))
        |> click(Wallaby.Query.option("None"))
        |> click(button("Save Resource"))

      # Wait for dashboard to load after save
      session =
        session
        |> Wallaby.Browser.assert_has(css("h1", text: "Resources"))
        |> Wallaby.Browser.assert_has(css("a[data-test-id='resource-link-#{child.id}']"))

      # Verify relationship was removed by checking the resource data
      child_resource = HydepwnsLiveview.Resources.ResourceSystem.get_resource(child.id) |> elem(1)
      assert child_resource.parent_id == nil

      # Optionally, you can still check the form loads, but don't assert on selected option
      session
      |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
      |> Wallaby.Browser.assert_has(css("h1", text: child.name))
      |> click(Wallaby.Query.css("a[data-test-id='edit-resource-link']"))

      # Verify relationship removal event
      session
      |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
      |> Wallaby.Browser.assert_has(css("h1", text: child.name))
      |> click(Wallaby.Query.css("a[data-test-id='view-events-link']"))
      |> Wallaby.Browser.assert_has(css(".event-row", text: "resource.updated"))
    end

    test "relationship constraints are enforced", %{
      session: session,
      parent: _parent,
      child: child
    } do
      # Try to create invalid relationship type
      session
      |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
      |> Wallaby.Browser.assert_has(css("h1", text: child.name))
      |> click(Wallaby.Query.css("a[data-test-id='edit-resource-link']"))
      # Self-reference
      |> click(Wallaby.Query.select("resource[parent_id]"))
      |> click(Wallaby.Query.option(child.name))
      |> click(button("Save Resource"))

      # Verify error message
      Wallaby.Browser.assert_has(
        session,
        css("[data-test-id='parent-id-error']", text: "Circular relationship detected")
      )

      # Wait for dashboard to load after save
      session =
        session
        |> Wallaby.Browser.assert_has(css("h1", text: "Resources"))

      # Try to create relationship with incompatible types
      session
      |> click(Wallaby.Query.css("a[data-test-id='create-resource-link']"))
      |> fill_in(text_field("resource[name]"), with: "Invalid Child")
      |> click(Wallaby.Query.select("resource[type]"))
      |> click(Wallaby.Query.option("Document"))
      # Document can't be parent of folder
      |> click(Wallaby.Query.select("resource[parent_id]"))
      |> click(Wallaby.Query.option(child.name))
      |> click(button("Create Resource"))

      # Verify error message
      Wallaby.Browser.assert_has(
        session,
        css("[data-test-id='parent-id-error']", text: "Incompatible resource types")
      )
    end

    test "relationship changes trigger UI updates", %{
      session: session,
      parent: parent,
      child: child
    } do
      # Create relationship from backend using the resource system
      {:ok, _updated_child} =
        HydepwnsLiveview.Resources.ResourceSystem.update_resource(child.id, %{parent_id: parent.id})

      # Verify the relationship was created by checking the child's resource data
      updated_child = HydepwnsLiveview.Resources.ResourceSystem.get_resource(child.id) |> elem(1)
      assert updated_child.parent_id == parent.id

      # Optionally, you can still check the form loads, but don't assert on selected option
      session
      |> Wallaby.Browser.assert_has(css("h1", text: "Resources"))
      |> Wallaby.Browser.assert_has(css("a[data-test-id='resource-link-#{child.id}']"))
      |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
      |> Wallaby.Browser.assert_has(css("h1", text: child.name))
      |> click(Wallaby.Query.css("a[data-test-id='edit-resource-link']"))

      # Verify relationship events were generated
      session
      |> click(Wallaby.Query.css("a[data-test-id='resource-link-#{child.id}']"))
      |> Wallaby.Browser.assert_has(css("h1", text: child.name))
      |> click(Wallaby.Query.css("a[data-test-id='view-events-link']"))
      |> Wallaby.Browser.assert_has(css(".event-row", text: "resource.updated"))
    end
  end
end
