defmodule HydepwnsLiveview.TypeValidationTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  alias HydepwnsLiveview.Utils.SocketValidator
  import HydepwnsLiveviewWeb.LiveSocketTestHelpers
  import Phoenix.LiveViewTest
  import ExUnit.CaptureLog

  # Define a test LiveView module with type specs
  defmodule TestTypeLive do
    use HydepwnsLiveviewWeb.BaseLive,
      required_assigns: [:string_value, :integer_value, :theme],
      type_specs: %{
        string_value: :string,
        integer_value: :integer,
        optional_list: :list,
        theme: {:one_of, ["dark", "light", "dim"]},
        user: %{
          name: :string,
          admin: :boolean
        },
        tags: {:list, :string},
        id_or_name: {:union, [:integer, :string]}
      }

    def mount(_params, session, socket) do
      socket =
        socket
        |> Phoenix.Component.assign(:string_value, Map.get(session, "string_value", "default"))
        |> Phoenix.Component.assign(:integer_value, Map.get(session, "integer_value", 42))
        |> Phoenix.Component.assign(:theme, Map.get(session, "theme", "dark"))
        |> assign_optional_values(session)

      {:ok, socket}
    end

    def render(assigns) do
      ~H"""
      <div>
        <p>String value: {@string_value}</p>
        <p>Integer value: {@integer_value}</p>
        <p>Theme: {@theme}</p>
        <%= if Map.has_key?(assigns, :optional_list) do %>
          <p>Optional list: {inspect(@optional_list)}</p>
        <% end %>
        <%= if Map.has_key?(assigns, :user) do %>
          <p>User: {@user.name} (Admin: {@user.admin})</p>
        <% end %>
        <%= if Map.has_key?(assigns, :tags) do %>
          <p>Tags: {inspect(@tags)}</p>
        <% end %>
        <%= if Map.has_key?(assigns, :id_or_name) do %>
          <p>ID or Name: {inspect(@id_or_name)}</p>
        <% end %>
      </div>
      """
    end

    defp assign_optional_values(socket, session) do
      socket
      |> maybe_assign(:optional_list, Map.get(session, "optional_list"))
      |> maybe_assign(:user, Map.get(session, "user"))
      |> maybe_assign(:tags, Map.get(session, "tags"))
      |> maybe_assign(:id_or_name, Map.get(session, "id_or_name"))
    end

    defp maybe_assign(socket, _key, nil), do: socket
    defp maybe_assign(socket, key, value), do: Phoenix.Component.assign(socket, key, value)
  end

  describe "type_validation/3 function" do
    test "validates basic types correctly" do
      # Create test socket with assigns of different types
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          string_value: "test",
          integer_value: 42,
          boolean_value: true,
          map_value: %{key: "value"},
          list_value: [1, 2, 3],
          enum_value: "dark"
        )

      # Valid types should return :ok
      assert {:ok, _} = SocketValidator.type_validation(socket, :string_value, :string)
      assert {:ok, _} = SocketValidator.type_validation(socket, :integer_value, :integer)
      assert {:ok, _} = SocketValidator.type_validation(socket, :boolean_value, :boolean)
      assert {:ok, _} = SocketValidator.type_validation(socket, :map_value, :map)
      assert {:ok, _} = SocketValidator.type_validation(socket, :list_value, :list)

      assert {:ok, _} =
               SocketValidator.type_validation(
                 socket,
                 :enum_value,
                 {:one_of, ["dark", "light", "dim"]}
               )

      # Invalid types should return an error
      assert {:error, message, _} =
               SocketValidator.type_validation(socket, :string_value, :integer)

      assert message =~ "expected integer"

      assert {:error, message, _} =
               SocketValidator.type_validation(socket, :integer_value, :string)

      assert message =~ "expected string"

      assert {:error, message, _} =
               SocketValidator.type_validation(
                 socket,
                 :enum_value,
                 {:one_of, ["red", "green", "blue"]}
               )

      assert message =~ "expected one of"
    end

    test "validates nested schemas correctly" do
      # Create test socket with a nested map assign
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          user: %{
            name: "Test User",
            age: 30,
            settings: %{
              theme: "dark",
              notifications: true
            }
          }
        )

      # Define a schema for the user map
      user_schema = %{
        name: :string,
        age: :integer,
        settings: %{
          theme: {:one_of, ["dark", "light"]},
          notifications: :boolean
        }
      }

      # Valid schema should return :ok
      assert {:ok, _} = SocketValidator.type_validation(socket, :user, user_schema)

      # Create a socket with invalid nested data
      invalid_socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          user: %{
            name: "Test User",
            # Should be an integer
            age: "thirty",
            settings: %{
              # Not in allowed list
              theme: "blue",
              # Should be boolean
              notifications: "yes"
            }
          }
        )

      # Invalid nested data should return error
      assert {:error, message, _} =
               SocketValidator.type_validation(invalid_socket, :user, user_schema)

      assert message =~ "schema validation failed"
      assert message =~ "age: expected integer"
      assert message =~ "settings.theme: expected one of"
      assert message =~ "settings.notifications: expected boolean"
    end

    test "validates lists with type specs correctly" do
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          string_list: ["one", "two", "three"],
          mixed_list: ["one", 2, true],
          empty_list: []
        )

      # Valid list of strings
      assert {:ok, _} = SocketValidator.type_validation(socket, :string_list, {:list, :string})

      # Empty list should be valid
      assert {:ok, _} = SocketValidator.type_validation(socket, :empty_list, {:list, :string})

      # Mixed list should fail string validation
      assert {:error, message, _} =
               SocketValidator.type_validation(socket, :mixed_list, {:list, :string})

      assert message =~ "list validation failed"
      assert message =~ "item at index 1: expected string"
    end

    test "validates union types correctly" do
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          id_as_int: 42,
          id_as_string: "ABC123",
          neither: true
        )

      # Both representations should be valid with union type
      assert {:ok, _} =
               SocketValidator.type_validation(socket, :id_as_int, {:union, [:integer, :string]})

      assert {:ok, _} =
               SocketValidator.type_validation(
                 socket,
                 :id_as_string,
                 {:union, [:integer, :string]}
               )

      # Non-matching type should fail
      assert {:error, message, _} =
               SocketValidator.type_validation(socket, :neither, {:union, [:integer, :string]})

      assert message =~ "Value matched none of the union types"
    end

    test "handles custom validation functions" do
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          email: "user@example.com",
          invalid_email: "not-an-email"
        )

      # Define a simple email validator function
      email_validator = fn email ->
        String.match?(email, ~r/@/)
      end

      # Valid email
      assert {:ok, _} =
               SocketValidator.type_validation(socket, :email, {:custom, email_validator})

      # Invalid email
      assert {:error, message, _} =
               SocketValidator.type_validation(socket, :invalid_email, {:custom, email_validator})

      assert message =~ "failed custom validation"
    end

    test "emits telemetry events for validation failures" do
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          # Not a string
          string_value: 123,
          view: TestTypeLive
        )

      # Set up telemetry handler for testing
      ref =
        :telemetry_test.attach_event_handlers(self(), [
          [:hydepwns, :socket_validator, :validation, :type_error]
        ])

      # Trigger a validation error
      SocketValidator.type_validation(socket, :string_value, :string)

      # Assert we received the expected telemetry event
      assert_receive {
        [:hydepwns, :socket_validator, :validation, :type_error],
        %{count: 1},
        %{key: :string_value, type_spec: :string, validation_type: :type_validation}
      }

      # Clean up
      :telemetry.detach(ref)
    end

    test "context_aware_error generates helpful error messages" do
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          integer_as_string: "42",
          theme: "yellow",
          view: TestTypeLive
        )

      # Generate error message for wrong type that can be easily converted
      {:error, basic_message, _} =
        SocketValidator.type_validation(socket, :integer_as_string, :integer)

      context_message =
        SocketValidator.context_aware_error(basic_message, :integer_as_string, socket)

      # Should include helpful suggestion for this case
      assert context_message =~ "Convert the string to an integer"

      # Test suggestion for one_of error
      {:error, enum_message, _} =
        SocketValidator.type_validation(socket, :theme, {:one_of, ["dark", "light", "dim"]})

      context_message =
        SocketValidator.context_aware_error(enum_message, :theme, socket)

      # Should include value and type information
      assert context_message =~ "Current value: \"yellow\""
      assert context_message =~ "(string)"
    end

    test "validates maps with optional fields" do
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          # Complete user with all fields
          complete_user: %{
            name: "User One",
            age: 30,
            email: "user@example.com"
          },
          # Partial user missing optional field
          partial_user: %{
            name: "User Two",
            age: 25
          }
        )

      # Schema with optional email field
      user_schema = %{
        name: :string,
        age: :integer,
        email: {:optional, :string}
      }

      # Both should pass validation
      assert {:ok, _} = SocketValidator.type_validation(socket, :complete_user, user_schema)
      assert {:ok, _} = SocketValidator.type_validation(socket, :partial_user, user_schema)

      # Required field missing should fail
      invalid_user = %{name: "No Age"}
      socket = Phoenix.Component.assign(socket, invalid_user: invalid_user)

      assert {:error, message, _} =
               SocketValidator.type_validation(socket, :invalid_user, user_schema)

      assert message =~ "missing field"
      assert message =~ "age"
    end

    test "validates list_of_maps correctly" do
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          # Valid list of user maps
          users: [
            %{name: "User 1", role: "admin"},
            %{name: "User 2", role: "user"},
            %{name: "User 3", role: "user"}
          ],
          # Invalid list with one bad item
          mixed_users: [
            %{name: "User 1", role: "admin"},
            # name should be string
            %{name: 123, role: "user"},
            %{name: "User 3", role: "user"}
          ]
        )

      # Define schema for user objects
      user_schema = %{
        name: :string,
        role: {:one_of, ["admin", "user", "guest"]}
      }

      # Valid list of users
      assert {:ok, _} =
               SocketValidator.type_validation(socket, :users, {:list_of_maps, user_schema})

      # Invalid list with type error
      assert {:error, message, _} =
               SocketValidator.type_validation(socket, :mixed_users, {:list_of_maps, user_schema})

      assert message =~ "list_of_maps validation failed"
      assert message =~ "item at index 1"
      assert message =~ "name: expected string"
    end

    test "validates complex nested structures" do
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          organization: %{
            name: "Example Org",
            founded: 2020,
            settings: %{
              public: true,
              theme: "dark"
            },
            members: [
              %{name: "User 1", role: "admin"},
              %{name: "User 2", role: "user"}
            ],
            tags: ["tech", "startup"]
          }
        )

      # Complex nested schema with various validations
      org_schema = %{
        name: :string,
        founded: :integer,
        settings: %{
          public: :boolean,
          theme: {:one_of, ["light", "dark", "system"]},
          analytics: {:optional, :boolean}
        },
        members:
          {:list_of_maps,
           %{
             name: :string,
             role: {:one_of, ["admin", "user", "guest"]},
             bio: {:optional, :string}
           }},
        tags: {:list, :string}
      }

      # Valid complex structure
      assert {:ok, _} =
               SocketValidator.type_validation(socket, :organization, org_schema)

      # Add invalid organization with type errors
      invalid_org = %{
        name: "Bad Org",
        # Should be integer
        founded: "not a number",
        settings: %{
          public: true,
          # Not in allowed values
          theme: "invalid_theme"
        },
        members: [
          # Invalid role
          %{name: "User", role: "invalid_role"}
        ],
        # Mixed list, should all be strings
        tags: ["tag", 123]
      }

      socket = Phoenix.Component.assign(socket, invalid_org: invalid_org)

      assert {:error, message, _} =
               SocketValidator.type_validation(socket, :invalid_org, org_schema)

      assert message =~ "schema validation failed"
      assert message =~ "founded: expected integer"
      assert message =~ "settings.theme: expected one of"
      assert message =~ "members"
      assert message =~ "role: expected one of"
      assert message =~ "tags"
      assert message =~ "expected string"
    end
  end

  describe "BaseLive integration with type validation" do
    # Define a test route in the Router for the TestTypeLive module
    # This would typically go in your router_test.exs file
    # For example: live "/test-types", TypeValidationTest.TestTypeLive

    test "validates types during mount lifecycle", %{conn: conn} do
      # Create valid session data
      session = %{
        "string_value" => "test string",
        "integer_value" => 42,
        "theme" => "dark",
        "user" => %{
          "name" => "Test User",
          "admin" => true
        },
        "tags" => ["tag1", "tag2"],
        "id_or_name" => "ID123"
      }

      # Test with valid data
      {:ok, view} =
        mount_and_validate_types(
          conn,
          "/test-types",
          %{
            string_value: :string,
            integer_value: :integer,
            theme: {:one_of, ["dark", "light", "dim"]},
            tags: {:list, :string},
            id_or_name: {:union, [:integer, :string]},
            user: %{
              name: :string,
              admin: :boolean
            }
          },
          session
        )

      # Check that assigns have the expected values
      assert view.assigns.string_value == "test string"
      assert view.assigns.integer_value == 42
      assert view.assigns.theme == "dark"
      assert view.assigns.id_or_name == "ID123"
      assert view.assigns.tags == ["tag1", "tag2"]
    end

    test "property-based testing of type validation", %{conn: conn} do
      # Define type specs for property testing
      type_specs = %{
        string_value: :string,
        integer_value: :integer,
        theme: {:one_of, ["dark", "light", "dim"]},
        tags: {:list, :string},
        id_or_name: {:union, [:integer, :string]}
      }

      # Use the property testing helper (several iterations with random valid data)
      assert property_test_types(conn, "/test-types", type_specs, 3)
    end

    test "logs validation errors with context information", %{conn: conn} do
      # Create invalid session data
      invalid_session = %{
        # Not a string
        "string_value" => 123,
        # Not an integer
        "integer_value" => "42",
        # Not in allowed list
        "theme" => "invalid"
      }

      # Capture logs to assert on warnings
      logs =
        capture_log(fn ->
          # Mount with invalid data should still succeed but log warnings
          {:ok, _view} = live(conn, "/test-types", invalid_session)
        end)

      # Check that logs contain context-aware error messages
      assert logs =~ "Type validation error for string_value"
      assert logs =~ "Type validation error for integer_value"
      assert logs =~ "Type validation error for theme"
    end

    test "tests boundary conditions with mutations", %{conn: conn} do
      # Define basic type specs
      type_specs = %{
        string_value: :string,
        integer_value: :integer,
        theme: {:one_of, ["dark", "light", "dim"]}
      }

      # Generate variations for boundary testing
      mutations = generate_type_mutations(type_specs)

      for {key, value, expected_result} <- Enum.take(mutations, 5) do
        # Create session with the mutation
        session =
          %{
            "string_value" => "default",
            "integer_value" => 42,
            "theme" => "dark"
          }
          |> Map.put(to_string(key), value)

        # Mount should succeed regardless of validation results
        {:ok, view, _html} = live(conn, "/test-types", session)

        # For valid mutations, the value should be preserved
        # For invalid ones, BaseLive should handle the error gracefully
        case expected_result do
          :valid ->
            assert view.assigns[key] == value

          :invalid ->
            # The BaseLive implementation will keep invalid values,
            # but log warnings about them
            :ok
        end
      end
    end
  end
end
