defmodule HydepwnsLiveview.Utils.ContextValidationTrackingTest do
  use ExUnit.Case, async: true
  alias HydepwnsLiveview.Utils.ChangeTracker
  alias HydepwnsLiveview.Utils.ContextValidation

  # Define a simple resource module for testing
  defmodule TestResource do
    use HydepwnsLiveview.Utils.LiveViewResource

    # Define validation rules
    def __validation_rules__ do
      [
        role_valid: fn resource, context ->
          allowed_roles = Map.get(context, :allowed_roles, ["user", "admin"])

          if resource.role in allowed_roles do
            :ok
          else
            {:error, "Invalid role: #{resource.role}. Allowed roles: #{inspect(allowed_roles)}"}
          end
        end,
        email_valid: fn resource ->
          if String.contains?(resource.email, "@") do
            :ok
          else
            {:error, "Invalid email format"}
          end
        end
      ]
    end
  end

  describe "update_with_tracking with context validation" do
    test "uses context-aware validation when context_validation is true" do
      # Create a test resource
      resource = %{
        id: "123",
        name: "Test User",
        email: "user@example.com",
        role: "user",
        __resource_module__: TestResource
      }

      # Update with a valid role (according to default context)
      changes = %{role: "admin"}
      metadata = %{context_validation: true, validation_rules: [:role_valid]}

      {:ok, updated_resource} = TestResource.update_with_tracking(resource, changes, metadata)
      assert updated_resource.role == "admin"

      # Update with an invalid role using a custom context
      changes = %{role: "manager"}

      metadata = %{
        context_validation: true,
        validation_rules: [:role_valid],
        validation_context: %{allowed_roles: ["user", "editor"]}
      }

      result = TestResource.update_with_tracking(resource, changes, metadata)
      assert {:error, _} = result
    end

    test "falls back to relationship validation when context_validation is false" do
      # Create a test resource
      resource = %{
        id: "123",
        name: "Test User",
        email: "user@example.com",
        role: "user",
        __resource_module__: TestResource
      }

      # In this test, we'll use a stub for validate_update
      # Since relationship validation is more about foreign keys and references
      # which we're not testing here

      # Update with valid field - should work
      changes = %{email: "new@example.com"}

      {:ok, updated_resource} = TestResource.update_with_tracking(resource, changes)
      assert updated_resource.email == "new@example.com"

      # Check that the change was tracked
      [change] = updated_resource.__change_history__
      assert change.changes.email == "new@example.com"
    end

    test "combines context validation with optimistic concurrency control" do
      # Create a test resource with history
      resource = %{
        id: "123",
        name: "Test User",
        email: "user@example.com",
        role: "user",
        __resource_module__: TestResource,
        __change_history__: [%{version: 1}]
      }

      # Update with valid expected version
      changes = %{name: "Updated Name"}

      metadata = %{
        context_validation: true,
        validation_rules: [:email_valid],
        expected_version: 1
      }

      {:ok, updated_resource} = TestResource.update_with_tracking(resource, changes, metadata)
      assert updated_resource.name == "Updated Name"

      # Update with invalid expected version
      changes = %{name: "Another Name"}

      metadata = %{
        context_validation: true,
        validation_rules: [:email_valid],
        # But now the resource is at version 2
        expected_version: 1
      }

      result = TestResource.update_with_tracking(updated_resource, changes, metadata)
      assert {:error, :stale_resource} = result
    end
  end
end
