defmodule HydepwnsLiveviewWeb.Components.ThemeToggleTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias HydepwnsLiveviewWeb.Components.ThemeToggle

  describe "theme_toggle/1" do
    test "renders theme toggle buttons" do
      html =
        render_component(&ThemeToggle.theme_toggle/1, %{})

      assert html =~ "theme-toggle"
      assert html =~ "light-theme"
      assert html =~ "dim-theme"
      assert html =~ "dark-theme"
    end
  end
end
