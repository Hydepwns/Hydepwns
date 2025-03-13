defmodule HydepwnsLiveview.Utils.ChangeTrackerTest do
  use ExUnit.Case, async: true
  alias HydepwnsLiveview.Utils.ChangeTracker

  describe "track_change/3" do
    test "tracks changes to a resource" do
      resource = %{
        id: "123",
        name: "Original Name",
        email: "original@example.com",
        active: true,
        settings: %{
          theme: "light",
          notifications: true
        }
      }

      changes = %{
        name: "New Name",
        email: "new@example.com"
      }

      metadata = %{
        actor: "test@example.com",
        reason: "Test update",
        source: "test"
      }

      {:ok, updated_resource} = ChangeTracker.track_change(resource, changes, metadata)

      # Check that changes were applied
      assert updated_resource.name == "New Name"
      assert updated_resource.email == "new@example.com"

      # Check that history was created
      assert updated_resource.__change_history__ != nil
      assert length(updated_resource.__change_history__) == 1

      # Check history record
      [change] = updated_resource.__change_history__
      assert change.version == 1
      assert change.before == resource
      assert change.changes == changes
      assert change.metadata.actor == "test@example.com"
      assert change.metadata.reason == "Test update"
      assert change.metadata.source == "test"
      assert change.metadata.timestamp != nil
    end

    test "supports selective field tracking" do
      resource = %{
        id: "123",
        name: "Original Name",
        email: "original@example.com",
        role: "user"
      }

      changes = %{
        name: "New Name",
        email: "new@example.com",
        role: "admin"
      }

      # Track only name and role changes
      metadata = %{
        tracked_fields: [:name, :role]
      }

      {:ok, updated_resource} = ChangeTracker.track_change(resource, changes, metadata)

      # All changes should be applied to the resource
      assert updated_resource.name == "New Name"
      assert updated_resource.email == "new@example.com"
      assert updated_resource.role == "admin"

      # But only tracked fields should be in the change record
      [change] = updated_resource.__change_history__
      assert Map.has_key?(change.changes, :name)
      assert Map.has_key?(change.changes, :role)
      refute Map.has_key?(change.changes, :email)
    end
  end

  describe "diff/2" do
    test "creates a diff between simple resources" do
      resource_v1 = %{
        id: "123",
        name: "Original Name",
        email: "original@example.com",
        __change_history__: [%{version: 1}]
      }

      resource_v2 = %{
        id: "123",
        name: "New Name",
        email: "original@example.com",
        __change_history__: [%{version: 2}, %{version: 1}]
      }

      {:ok, diff} = ChangeTracker.diff(resource_v2, version1: 1, version2: 2)

      assert Map.has_key?(diff, :name)
      assert diff.name.before == "Original Name"
      assert diff.name.after == "New Name"
      # No change
      refute Map.has_key?(diff, :email)
    end

    test "creates a deep diff for nested structures" do
      resource_v1 = %{
        id: "123",
        settings: %{
          theme: "light",
          notifications: true,
          preferences: %{
            language: "en"
          }
        },
        tags: ["tag1", "tag2"],
        __change_history__: [%{version: 1}]
      }

      resource_v2 = %{
        id: "123",
        settings: %{
          theme: "dark",
          notifications: true,
          preferences: %{
            language: "fr"
          }
        },
        tags: ["tag1", "tag3"],
        __change_history__: [%{version: 2}, %{version: 1}]
      }

      # Track change to simulate history
      {:ok, tracked_resource} =
        ChangeTracker.track_change(resource_v1, %{
          settings: resource_v2.settings,
          tags: resource_v2.tags
        })

      # Create diff
      {:ok, diff} = ChangeTracker.diff(tracked_resource)

      # Check settings diff
      assert diff.settings.before == resource_v1.settings
      assert diff.settings.after == resource_v2.settings

      # Check nested diff
      nested_diff = diff.settings.nested_diff
      assert nested_diff.theme.before == "light"
      assert nested_diff.theme.after == "dark"

      # Check deeply nested diff
      assert nested_diff.preferences.nested_diff.language.before == "en"
      assert nested_diff.preferences.nested_diff.language.after == "fr"

      # Check array diff
      assert diff.tags.before == ["tag1", "tag2"]
      assert diff.tags.after == ["tag1", "tag3"]
    end
  end
end
