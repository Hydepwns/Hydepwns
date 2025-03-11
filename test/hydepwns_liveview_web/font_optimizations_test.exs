defmodule HydepwnsLiveviewWeb.FontOptimizationsTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "Font optimizations" do
    test "root layout includes font optimization tags", %{conn: conn} do
      conn = get(conn, "/")
      html = html_response(conn, 200)

      # Test that the preconnect tag is present
      assert html =~ ~s(<link rel="preconnect" href="https://fonts.cdnfonts.com" crossorigin />)
      
      # Test that the preload tags are present
      assert html =~ ~s(<link rel="preload" href="/assets/fonts/MonaspaceArgon-Regular.woff2" as="font" type="font/woff2" crossorigin />)
      assert html =~ ~s(<link rel="preload" href="/assets/fonts/MonaspaceArgon-Bold.woff2" as="font" type="font/woff2" crossorigin />)
      
      # Test that the fonts-loading class is present
      assert html =~ ~s(class="fonts-loading")
      
      # Test that the critical CSS is inlined
      assert html =~ ~s(font-family: 'Monaspace Argon Fallback', monospace)
      
      # Test that the font caching script is present
      assert html =~ "FONTS_LOADED_KEY"
      assert html =~ "fonts-cached"
    end

    test "style guide page includes font examples", %{conn: conn} do
      {:ok, view, html} = live(conn, "/style-guide")

      # Test that the font examples are present
      assert html =~ "Monaspace Argon"
      assert html =~ "JetBrains Mono"
      
      # Test that the font examples have the correct classes
      assert html =~ "font-example"
      assert html =~ "fallback-font"
    end
  end
end 