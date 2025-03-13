defmodule HydepwnsLiveviewWeb.ExternalAPIIntegrationTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Mox

  alias HydepwnsLiveviewWeb.MockHelper

  # Make sure mocks are verified after each test
  setup :verify_on_exit!

  setup do
    # Set up mocks for all tests
    MockHelper.setup_mocks()
    :ok
  end

  describe "external API integration" do
    test "displays data from external API when loaded", %{conn: conn} do
      # Set up expectations for the API call
      MockHelper.expect_api_call(:external_api, :fetch_data, fn _id ->
        {:ok, %{"id" => "123", "name" => "Test Resource", "status" => "active"}}
      end)

      # This is a placeholder test - replace with an actual route in your app
      # that would make external API calls
      {:ok, view, _html} = live(conn, "/resources/123")

      # Assert that the data from the mocked API is displayed
      assert has_element?(view, "[data-test-id='resource-name']", "Test Resource")
      assert has_element?(view, "[data-test-id='resource-status']", "active")
    end

    test "handles API errors gracefully", %{conn: conn} do
      # Set up expectations for a failed API call
      MockHelper.expect_api_call(:external_api, :fetch_data, fn _id ->
        {:error, %{reason: "API unavailable"}}
      end)

      # This is a placeholder test
      {:ok, view, _html} = live(conn, "/resources/123")

      # Assert that error message is displayed
      assert has_element?(view, "[data-test-id='error-message']", "Unable to load resource")
      refute has_element?(view, "[data-test-id='resource-name']")
    end

    test "allows user to update resource data", %{conn: conn} do
      # Set up expectations for initial data fetch
      MockHelper.expect_api_call(:external_api, :fetch_data, fn _id ->
        {:ok, %{"id" => "123", "name" => "Test Resource", "status" => "active"}}
      end)

      # Set up expectations for update call
      MockHelper.expect_api_call(:external_api, :update_resource, fn _id, data ->
        {:ok, Map.put(data, "id", "123")}
      end)

      # Load the page
      {:ok, view, _html} = live(conn, "/resources/123")

      # Simulate user updating the resource
      view
      |> element("form")
      |> render_submit(%{
        "resource" => %{
          "name" => "Updated Resource",
          "status" => "inactive"
        }
      })

      # Assert that success message is displayed
      assert has_element?(
               view,
               "[data-test-id='success-message']",
               "Resource updated successfully"
             )

      # Assert that updated data is displayed
      assert has_element?(view, "[data-test-id='resource-name']", "Updated Resource")
      assert has_element?(view, "[data-test-id='resource-status']", "inactive")
    end
  end
end
