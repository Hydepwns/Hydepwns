defmodule HydepwnsLiveviewWeb.Components.StyleGuideTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias HydepwnsLiveviewWeb.Components.StyleGuide

  describe "style_guide component" do
    test "renders the style guide with all sections" do
      html =
        render_component(StyleGuide, %{id: "test-style-guide"})

      # Test that all main sections are present
      assert html =~ "Hydepwns Monospace Style Guide"
      assert html =~ "Typography"
      assert html =~ "Color Palette"
      assert html =~ "Grid System"
      assert html =~ "Components"
      assert html =~ "Animations"
      assert html =~ "Accessibility"
    end

    test "includes typography examples" do
      html =
        render_component(StyleGuide, %{id: "test-style-guide"})

      # Test typography section content
      assert html =~ "Monaspace Argon"
      assert html =~ "JetBrains Mono"
      assert html =~ "Heading 1"
      assert html =~ "Body Text"
      assert html =~ "Bold Text"
      assert html =~ "Italic Text"
    end

    test "includes color palette examples" do
      html =
        render_component(StyleGuide, %{id: "test-style-guide"})

      # Test color palette section content
      assert html =~ "Light Theme"
      assert html =~ "Dark Theme"
      assert html =~ "Text Color"
      assert html =~ "Background Color"
    end

    test "includes grid system examples" do
      html =
        render_component(StyleGuide, %{id: "test-style-guide"})

      # Test grid system section content
      assert html =~ "MonoGrid Component"
      assert html =~ "Basic Usage"
      assert html =~ "Grid with Borders"
    end

    test "includes component examples" do
      html =
        render_component(StyleGuide, %{id: "test-style-guide"})

      # Test components section content
      assert html =~ "Terminal Component"
      assert html =~ "ASCII Art Generator"
      assert html =~ "Diagram Editor"
      assert html =~ "Theme Toggle"
    end

    test "includes animation examples" do
      html =
        render_component(StyleGuide, %{id: "test-style-guide"})

      # Test animations section content
      assert html =~ "Typewriter Animation"
      assert html =~ "Grid Animation"
    end

    test "includes accessibility examples" do
      html =
        render_component(StyleGuide, %{id: "test-style-guide"})

      # Test accessibility section content
      assert html =~ "Keyboard Navigation"
      assert html =~ "Reduced Motion"
      assert html =~ "High Contrast Mode"
    end
  end
end 