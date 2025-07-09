defmodule HydepwnsLiveviewWeb.ResourceRelationshipLiveTest do
  use HydepwnsLiveviewWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import Mox
  setup :set_mox_from_context
  setup :verify_on_exit!

  @moduledoc """
  LiveView tests for Resource Relationship Management using Phoenix.LiveViewTest.

  These tests provide more reliable state assertions by directly interacting
  with the LiveView process, avoiding PubSub timing issues that can occur
  in Wallaby browser tests.
  """

  alias HydepwnsLiveview.TestSupport.ResourceFixtures
  alias HydepwnsLiveviewWeb.TestMockHelper

  setup %{conn: conn} do
    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()

    # Start MockEventStore if not already started
    case Process.whereis(HydepwnsLiveview.TestSupport.MockEventStore) do
      nil ->
        {:ok, _pid} = start_supervised(HydepwnsLiveview.TestSupport.MockEventStore)
      _pid ->
        :ok
    end

    # ConnCase already handles sandbox setup for async tests
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

    {:ok, conn: conn, parent: parent, child: child}
  end

  describe "resource relationship management" do
    test "dashboard displays resources correctly", %{conn: conn, parent: parent, child: child} do
      {:ok, view, html} = live(conn, "/resources")
      assert has_element?(view, "a[data-test-id='resource-link-#{parent.id}']")
      assert has_element?(view, "a[data-test-id='resource-link-#{child.id}']")
      assert has_element?(view, "a[data-test-id='resource-link-#{parent.id}']", parent.name)
      assert has_element?(view, "a[data-test-id='resource-link-#{child.id}']", child.name)
    end

    test "resource creation with parent relationship", %{conn: conn, parent: parent} do
      {:ok, view, html} = live(conn, "/resources")
      view = element(view, "a[data-test-id='create-resource-link']") |> render_click()
      view
      |> form("#resource-form", %{
        "resource[name]" => "New Child Resource",
        "resource[type]" => "document",
        "resource[parent_id]" => parent.id
      })
      |> render_submit()
      assert_redirect(view, "/resources")
      {:ok, dashboard_view, html} = follow_redirect(view, conn)
      resources = HydepwnsLiveview.Resources.ResourceSystem.list_resources()
      new_resource = Enum.find(resources, fn r -> r.name == "New Child Resource" end)
      assert new_resource != nil
      assert new_resource.parent_id == parent.id
      assert has_element?(dashboard_view, "a[data-test-id='resource-link-#{new_resource.id}']")
    end

    test "resource update with parent relationship", %{conn: conn, parent: parent, child: child} do
      {:ok, updated_child} = HydepwnsLiveview.Resources.ResourceSystem.update_resource(child.id, %{"parent_id" => nil})
      {:ok, view, html} = live(conn, "/resources/#{child.id}")
      assert has_element?(view, "h1", child.name)

      # Click edit link and handle the live redirect
      {:error, {:live_redirect, %{to: edit_path}}} = element(view, "a[data-test-id='edit-resource-link']") |> render_click()
      {:ok, edit_view, html} = live(conn, edit_path)

      # Now fill and submit the form on the edit page
      edit_view
      |> form("#resource-form", %{
        "resource[parent_id]" => parent.id
      })
      |> render_submit()
      assert_redirect(edit_view, "/resources/#{child.id}")
      # Instead of follow_redirect, fetch the new LiveView
      {:ok, show_view, html} = live(conn, "/resources/#{child.id}")
      updated_child = HydepwnsLiveview.Resources.ResourceSystem.get_resource(child.id) |> elem(1)
      assert updated_child.parent_id == parent.id
      assert has_element?(show_view, "h1", child.name)
    end

    test "resource list updates reflect relationships", %{conn: conn, parent: parent, child: child} do
      {:ok, updated_child} = HydepwnsLiveview.Resources.ResourceSystem.update_resource(child.id, %{"parent_id" => parent.id})
      {:ok, view, html} = live(conn, "/resources")
      assert has_element?(view, "a[data-test-id='resource-link-#{parent.id}']")
      assert has_element?(view, "a[data-test-id='resource-link-#{child.id}']")
      updated_child = HydepwnsLiveview.Resources.ResourceSystem.get_resource(child.id) |> elem(1)
      assert updated_child.parent_id == parent.id
    end

    test "relationship validation validates compatible resource types", %{conn: conn} do
      {:ok, document} = ResourceFixtures.create_test_resource(%{
        id: "document-1667",
        name: "Test Document",
        type: "document"
      })
      {:ok, folder} = ResourceFixtures.create_test_resource(%{
        id: "folder-1410",
        name: "Test Folder",
        type: "folder"
      })
      {:ok, view, html} = live(conn, "/resources/#{document.id}/edit")
      view
      |> form("#resource-form", %{
        "resource[parent_id]" => document.id
      })
      |> render_submit()
      assert has_element?(view, "[data-test-id='parent-id-error']")
      assert has_element?(view, "[data-test-id='parent-id-error']", "Circular relationship detected")
      view
      |> form("#resource-form", %{
        "resource[parent_id]" => folder.id
      })
      |> render_submit()
      assert_redirect(view, "/resources/#{document.id}")
      {:ok, show_view, html} = follow_redirect(view, conn)
      updated_document = HydepwnsLiveview.Resources.ResourceSystem.get_resource(document.id) |> elem(1)
      assert updated_document.parent_id == folder.id
      assert has_element?(show_view, "h1", document.name)
    end

    test "relationship removal works correctly", %{conn: conn, parent: parent, child: child} do
      {:ok, updated_child} = HydepwnsLiveview.Resources.ResourceSystem.update_resource(child.id, %{"parent_id" => parent.id})
      {:ok, view, html} = live(conn, "/resources/#{child.id}/edit")
      view
      |> form("#resource-form", %{
        "resource[parent_id]" => ""
      })
      |> render_submit()
      assert_redirect(view, "/resources/#{child.id}")
      {:ok, show_view, html} = follow_redirect(view, conn)
      updated_child = HydepwnsLiveview.Resources.ResourceSystem.get_resource(child.id) |> elem(1)
      assert updated_child.parent_id == nil
      assert has_element?(show_view, "h1", child.name)
    end

    test "circular relationship prevention", %{conn: conn, parent: parent, child: child} do
      {:ok, updated_child} = HydepwnsLiveview.Resources.ResourceSystem.update_resource(child.id, %{"parent_id" => parent.id})
      {:ok, view, html} = live(conn, "/resources/#{parent.id}/edit")
      view
      |> form("#resource-form", %{
        "resource[parent_id]" => child.id
      })
      |> render_submit()
      assert has_element?(view, "[data-test-id='parent-id-error']")
      assert has_element?(view, "[data-test-id='parent-id-error']", "Circular relationship detected")
      updated_parent = HydepwnsLiveview.Resources.ResourceSystem.get_resource(parent.id) |> elem(1)
      assert updated_parent.parent_id == nil
    end
  end
end
