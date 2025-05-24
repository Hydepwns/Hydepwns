defmodule HydepwnsLiveview.ThemeSystemTest do
  use HydepwnsLiveview.DataCase

  alias HydepwnsLiveview.ThemeSystem
  alias HydepwnsLiveview.ThemeSystem.Models.Theme

  describe "themes" do
    import HydepwnsLiveview.ThemeSystemFixtures

    @invalid_attrs %{name: nil, mode: nil, colors: nil, is_default: nil, settings: nil}

    defp atomize_keys(map) when is_map(map) do
      map
      |> Enum.map(fn {k, v} ->
        key = if is_binary(k), do: String.to_atom(k), else: k
        value = if is_map(v), do: atomize_keys(v), else: v
        {key, value}
      end)
      |> Enum.into(%{})
    end

    test "list_themes/0 returns all themes" do
      {:ok, theme_fixture} = theme_fixture()
      [theme_from_db] = ThemeSystem.list_themes()

      assert Map.from_struct(theme_from_db)
             |> Map.update!(:colors, &atomize_keys/1)
             |> Map.update!(:settings, &atomize_keys/1)
             |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
               Map.from_struct(theme_fixture)
               |> Map.update!(:colors, &atomize_keys/1)
               |> Map.update!(:settings, &atomize_keys/1)
               |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])
    end

    test "get_theme!/1 returns the theme with given id" do
      {:ok, theme_fixture} = theme_fixture()
      theme_from_db = ThemeSystem.get_theme!(theme_fixture.id)

      assert Map.from_struct(theme_from_db)
             |> Map.update!(:colors, &atomize_keys/1)
             |> Map.update!(:settings, &atomize_keys/1)
             |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
               Map.from_struct(theme_fixture)
               |> Map.update!(:colors, &atomize_keys/1)
               |> Map.update!(:settings, &atomize_keys/1)
               |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])
    end

    test "get_theme_by_name/1 returns the theme with given name" do
      {:ok, theme_fixture} = theme_fixture()
      theme_from_db = ThemeSystem.get_theme_by_name(theme_fixture.name)

      assert Map.from_struct(theme_from_db)
             |> Map.update!(:colors, &atomize_keys/1)
             |> Map.update!(:settings, &atomize_keys/1)
             |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
               Map.from_struct(theme_fixture)
               |> Map.update!(:colors, &atomize_keys/1)
               |> Map.update!(:settings, &atomize_keys/1)
               |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])

      assert ThemeSystem.get_theme_by_name("nonexistent") == nil
    end

    test "get_default_theme/0 returns the default theme" do
      {:ok, light_theme_fixture} = light_theme_fixture(is_default: false)
      {:ok, dark_theme_fixture} = dark_theme_fixture(is_default: false)

      # Set light theme as default and assert
      {:ok, _} = ThemeSystem.set_default_theme(light_theme_fixture)
      reloaded_light_theme = ThemeSystem.get_theme!(light_theme_fixture.id)
      default_from_db = ThemeSystem.get_default_theme()
      assert Map.from_struct(default_from_db)
             |> Map.update!(:colors, &atomize_keys/1)
             |> Map.update!(:settings, &atomize_keys/1)
             |> Map.drop([:id, :inserted_at, :updated_at, :__meta__, :__unset_other_defaults__]) ==
               Map.from_struct(reloaded_light_theme)
               |> Map.update!(:colors, &atomize_keys/1)
               |> Map.update!(:settings, &atomize_keys/1)
               |> Map.drop([:id, :inserted_at, :updated_at, :__meta__, :__unset_other_defaults__])

      # Set dark theme as default and assert
      {:ok, _} = ThemeSystem.set_default_theme(dark_theme_fixture)
      reloaded_dark_theme = ThemeSystem.get_theme!(dark_theme_fixture.id)
      default_from_db = ThemeSystem.get_default_theme()
      assert Map.from_struct(default_from_db)
             |> Map.update!(:colors, &atomize_keys/1)
             |> Map.update!(:settings, &atomize_keys/1)
             |> Map.drop([:id, :inserted_at, :updated_at, :__meta__, :__unset_other_defaults__]) ==
               Map.from_struct(reloaded_dark_theme)
               |> Map.update!(:colors, &atomize_keys/1)
               |> Map.update!(:settings, &atomize_keys/1)
               |> Map.drop([:id, :inserted_at, :updated_at, :__meta__, :__unset_other_defaults__])
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
      {:ok, theme} = theme_fixture()

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
      {:ok, theme_before_update} = theme_fixture()

      assert {:error, %Ecto.Changeset{}} =
               ThemeSystem.update_theme(theme_before_update, @invalid_attrs)

      theme_after_failed_update = ThemeSystem.get_theme!(theme_before_update.id)

      assert Map.from_struct(theme_after_failed_update)
             |> Map.update!(:colors, &atomize_keys/1)
             |> Map.update!(:settings, &atomize_keys/1)
             |> Map.drop([:id, :inserted_at, :updated_at, :__meta__]) ==
               Map.from_struct(theme_before_update)
               |> Map.update!(:colors, &atomize_keys/1)
               |> Map.update!(:settings, &atomize_keys/1)
               |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])
    end

    test "delete_theme/1 deletes the theme" do
      {:ok, theme} = theme_fixture()
      assert {:ok, %Theme{}} = ThemeSystem.delete_theme(theme)
      assert_raise Ecto.NoResultsError, fn -> ThemeSystem.get_theme!(theme.id) end
    end

    test "change_theme/1 returns a theme changeset" do
      {:ok, theme} = theme_fixture()
      assert %Ecto.Changeset{} = ThemeSystem.change_theme(theme)
    end

    test "set_default_theme/1 sets a theme as default and unsets others" do
      {:ok, light_theme} = light_theme_fixture(is_default: false)
      {:ok, dark_theme} = dark_theme_fixture(is_default: false)

      # Set light theme as default
      {:ok, _} = ThemeSystem.set_default_theme(light_theme)
      reloaded_light_theme = ThemeSystem.get_theme!(light_theme.id)
      assert Map.from_struct(ThemeSystem.get_default_theme())
             |> Map.update!(:colors, &atomize_keys/1)
             |> Map.update!(:settings, &atomize_keys/1)
             |> Map.drop([:id, :inserted_at, :updated_at, :__meta__, :__unset_other_defaults__]) ==
               Map.from_struct(reloaded_light_theme)
               |> Map.update!(:colors, &atomize_keys/1)
               |> Map.update!(:settings, &atomize_keys/1)
               |> Map.drop([:id, :inserted_at, :updated_at, :__meta__, :__unset_other_defaults__])

      # Set dark theme as default
      assert {:ok, _} = ThemeSystem.set_default_theme(dark_theme)
      reloaded_dark_theme = ThemeSystem.get_theme!(dark_theme.id)
      assert reloaded_dark_theme.is_default == true

      # Verify light theme is no longer default
      reloaded_light_theme = ThemeSystem.get_theme!(light_theme.id)
      assert reloaded_light_theme.is_default == false

      # Verify dark theme is now default
      assert Map.from_struct(ThemeSystem.get_default_theme())
             |> Map.update!(:colors, &atomize_keys/1)
             |> Map.update!(:settings, &atomize_keys/1)
             |> Map.drop([:id, :inserted_at, :updated_at, :__meta__, :__unset_other_defaults__]) ==
               Map.from_struct(reloaded_dark_theme)
               |> Map.update!(:colors, &atomize_keys/1)
               |> Map.update!(:settings, &atomize_keys/1)
               |> Map.drop([:id, :inserted_at, :updated_at, :__meta__, :__unset_other_defaults__])
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
