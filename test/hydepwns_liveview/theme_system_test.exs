defmodule HydepwnsLiveview.ThemeSystemTest do
  use HydepwnsLiveview.DataCase

  alias HydepwnsLiveview.ThemeSystem
  alias HydepwnsLiveview.ThemeSystem.Models.Theme

  describe "themes" do
    import HydepwnsLiveview.ThemeSystemFixtures

    @invalid_attrs %{name: nil, mode: nil, colors: nil, is_default: nil, settings: nil}

    test "list_themes/0 returns all themes" do
      theme_fixture = theme_fixture()
      [theme_from_db] = ThemeSystem.list_themes()
      assert Map.from_struct(theme_from_db) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
             Map.from_struct(theme_fixture) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])
    end

    test "get_theme!/1 returns the theme with given id" do
      theme_fixture = theme_fixture()
      theme_from_db = ThemeSystem.get_theme!(theme_fixture.id)
      assert Map.from_struct(theme_from_db) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
             Map.from_struct(theme_fixture) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])
    end

    test "get_theme_by_name/1 returns the theme with given name" do
      theme_fixture = theme_fixture()
      theme_from_db = ThemeSystem.get_theme_by_name(theme_fixture.name)
      assert Map.from_struct(theme_from_db) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
             Map.from_struct(theme_fixture) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])
      assert ThemeSystem.get_theme_by_name("nonexistent") == nil
    end

    test "get_default_theme/0 returns the default theme" do
      light_theme_fixture = light_theme_fixture()
      dark_theme_fixture = dark_theme_fixture()

      default_from_db = ThemeSystem.get_default_theme()

      # Compare relevant fields, ignoring ids and timestamps
      assert Map.from_struct(default_from_db) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
             Map.from_struct(light_theme_fixture) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])

      refute Map.from_struct(default_from_db) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
             Map.from_struct(dark_theme_fixture) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])
    end

    test "create_theme/1 with valid data creates a theme" do
      valid_attrs = %{
        name: "custom-theme",
        mode: "light",
        colors: %{
          primary: "#ff0000",
          secondary: "#00ff00",
          accent: "#0000ff",
          background: "#ffffff",
          text: "#000000"
        },
        is_default: false,
        settings: %{}
      }

      assert {:ok, %Theme{} = theme} = ThemeSystem.create_theme(valid_attrs)
      assert theme.name == "custom-theme"
      assert theme.mode == "light"
      assert theme.colors == valid_attrs.colors
      assert theme.is_default == false
      assert theme.settings == %{}
    end

    test "create_theme/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ThemeSystem.create_theme(@invalid_attrs)
    end

    test "create_theme/1 with invalid mode returns error changeset" do
      attrs = %{
        name: "invalid-theme",
        mode: "invalid-mode",
        colors: %{},
        is_default: false,
        settings: %{}
      }

      assert {:error, %Ecto.Changeset{}} = ThemeSystem.create_theme(attrs)
    end

    test "update_theme/2 with valid data updates the theme" do
      theme = theme_fixture()

      update_attrs = %{
        name: "updated-theme",
        mode: "dark",
        colors: %{
          primary: "#ff0000",
          secondary: "#00ff00"
        }
      }

      assert {:ok, %Theme{} = theme} = ThemeSystem.update_theme(theme, update_attrs)
      assert theme.name == "updated-theme"
      assert theme.mode == "dark"
      assert theme.colors == update_attrs.colors
    end

    test "update_theme/2 with invalid data returns error changeset" do
      theme_before_update = theme_fixture()
      assert {:error, %Ecto.Changeset{}} = ThemeSystem.update_theme(theme_before_update, @invalid_attrs)
      theme_after_failed_update = ThemeSystem.get_theme!(theme_before_update.id)

      assert Map.from_struct(theme_after_failed_update) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
             Map.from_struct(theme_before_update) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])
    end

    test "delete_theme/1 deletes the theme" do
      theme = theme_fixture()
      assert {:ok, %Theme{}} = ThemeSystem.delete_theme(theme)
      assert_raise Ecto.NoResultsError, fn -> ThemeSystem.get_theme!(theme.id) end
    end

    test "change_theme/1 returns a theme changeset" do
      theme = theme_fixture()
      assert %Ecto.Changeset{} = ThemeSystem.change_theme(theme)
    end

    test "set_default_theme/1 sets a theme as default and unsets others" do
      light_theme = light_theme_fixture()
      dark_theme = dark_theme_fixture()

      # Initially light theme should be default
      # assert ThemeSystem.get_default_theme() == light_theme
      assert Map.from_struct(ThemeSystem.get_default_theme()) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
             Map.from_struct(light_theme) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])

      # Set dark theme as default
      assert {:ok, updated_dark_theme} = ThemeSystem.set_default_theme(dark_theme)
      assert updated_dark_theme.is_default == true

      # Verify light theme is no longer default
      light_theme = ThemeSystem.get_theme!(light_theme.id)
      assert light_theme.is_default == false

      # Verify dark theme is now default
      # assert ThemeSystem.get_default_theme() == dark_theme
      assert Map.from_struct(ThemeSystem.get_default_theme()) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
             Map.from_struct(dark_theme) |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])
    end

    test "validate_theme/1 validates theme parameters" do
      valid_params = %{
        name: "valid-theme",
        mode: "light",
        colors: %{},
        is_default: false,
        settings: %{}
      }

      valid_changeset = Theme.validate_theme(valid_params)
      assert valid_changeset.valid?
      assert valid_changeset.errors == []

      invalid_params = %{
        name: nil,
        mode: "invalid-mode",
        colors: %{},
        is_default: false,
        settings: %{}
      }

      invalid_changeset = Theme.validate_theme(invalid_params)
      refute invalid_changeset.valid?
      assert Keyword.has_key?(invalid_changeset.errors, :name)
      assert Keyword.has_key?(invalid_changeset.errors, :mode)
    end
  end
end
