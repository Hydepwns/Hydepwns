defmodule HydepwnsLiveviewWeb.Features.ResourceCreationWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: false
  import HydepwnsLiveview.TestSupport.ResourceFixtures, only: [create_test_resource: 1, create_test_resource: 0]
  import HydepwnsLiveview.TestSupport.ResourceSystemHelper
  import Wallaby.Query

  import HydepwnsLiveviewWeb.Components.Common.CoreComponents
  import HydepwnsLiveviewWeb.Components.UI.FormComponents

  alias HydepwnsLiveview.Resources
  alias HydepwnsLiveview.Resources.Resource

  defp accept_confirm(session) do
    # Wallaby 0.30+ does not have accept_confirm, so we simulate clicking confirm
    # If you use a custom modal, you may need to adjust this
    session |> click(Query.button("OK"))
  end

  setup do
    setup_resource_system()
    resource = create_test_resource(%{type: "document", status: "active"})
    {:ok, resource: resource}
  end

  test "user can create a new resource", %{session: session} do
    session
    |> visit("/resources/new")
    |> fill_in(Query.text_field("Name"), with: "Test Resource")
    |> fill_in(Query.text_field("Description"), with: "Test Description")
    |> click(Query.button("Save Resource"))
    |> Wallaby.Browser.assert_has(Query.text("Resource created successfully"))
  end

  test "user can edit an existing resource", %{session: session} do
    {:ok, resource} = create_test_resource(%{})

    session
    |> visit("/resources/#{resource.id}/edit")
    |> fill_in(Query.text_field("Name"), with: "Updated Resource")
    |> fill_in(Query.text_field("Description"), with: "Updated Description")
    |> click(Query.button("Save Resource"))
    |> Wallaby.Browser.assert_has(Query.text("Resource updated successfully"))
  end

  test "user can delete a resource", %{session: session} do
    {:ok, resource} = create_test_resource(%{})

    session
    |> visit("/resources")
    |> click(Query.link("Delete"))
    |> accept_confirm()
    |> Wallaby.Browser.assert_has(Query.text("Resource deleted successfully"))
  end
end
