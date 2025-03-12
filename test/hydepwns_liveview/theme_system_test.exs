defmodule HydepwnsLiveview.ThemeSystemTest do
  use HydepwnsLiveview.DataCase

  alias HydepwnsLiveview.ThemeSystem

  describe "themes" do
    alias HydepwnsLiveview.ThemeSystem.Theme

    import HydepwnsLiveview.ThemeSystemFixtures

    @invalid_attrs %{name: nil, settings: nil}

    test "list_themes/0 returns all themes" do
      theme = theme_fixture()
      assert ThemeSystem.list_themes() == [theme]
    end

    test "get_theme!/1 returns the theme with given id" do
      theme = theme_fixture()
      assert ThemeSystem.get_theme!(theme.id) == theme
    end

    test "create_theme/1 with valid data creates a theme" do
      valid_attrs = %{name: "some name", settings: %{}}

      assert {:ok, %Theme{} = theme} = ThemeSystem.create_theme(valid_attrs)
      assert theme.name == "some name"
      assert theme.settings == %{}
    end

    test "create_theme/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ThemeSystem.create_theme(@invalid_attrs)
    end

    test "update_theme/2 with valid data updates the theme" do
      theme = theme_fixture()
      update_attrs = %{name: "some updated name", settings: %{}}

      assert {:ok, %Theme{} = theme} = ThemeSystem.update_theme(theme, update_attrs)
      assert theme.name == "some updated name"
      assert theme.settings == %{}
    end

    test "update_theme/2 with invalid data returns error changeset" do
      theme = theme_fixture()
      assert {:error, %Ecto.Changeset{}} = ThemeSystem.update_theme(theme, @invalid_attrs)
      assert theme == ThemeSystem.get_theme!(theme.id)
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
  end
end
