defmodule HydepwnsLiveviewWeb.Components.Interactive.TerminalTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias HydepwnsLiveviewWeb.TestLive.TerminalTestLive

  describe "terminal live component" do
    test "renders a basic terminal", %{conn: conn} do
      {:ok, view, html} =
        live_isolated(conn, TerminalTestLive, session: %{"id" => "test-terminal"})

      assert html =~ "terminal-container"
      assert html =~ "terminal-screen"
      assert has_element?(view, "#test-terminal")
    end

    test "renders a terminal with welcome message", %{conn: conn} do
      welcome_message = "Welcome to the test terminal!"

      {:ok, view, html} =
        live_isolated(conn, TerminalTestLive,
          session: %{
            "id" => "test-terminal",
            "welcome_message" => welcome_message
          }
        )

      assert html =~ "terminal-container"
      assert html =~ "terminal-screen"
      assert has_element?(view, "#test-terminal")
    end

    test "renders a terminal with custom prompt", %{conn: conn} do
      custom_prompt = "test-prompt$ "

      {:ok, view, html} =
        live_isolated(conn, TerminalTestLive,
          session: %{
            "id" => "test-terminal",
            "prompt" => custom_prompt
          }
        )

      assert html =~ "terminal-container"
      assert has_element?(view, "#test-terminal")
    end

    test "renders a terminal with custom theme", %{conn: conn} do
      {:ok, view, html} =
        live_isolated(conn, TerminalTestLive,
          session: %{
            "id" => "test-terminal",
            "theme" => "light"
          }
        )

      assert html =~ "terminal-container"
      assert has_element?(view, "#test-terminal")
    end

    test "renders a terminal with fullscreen option", %{conn: conn} do
      {:ok, view, html} =
        live_isolated(conn, TerminalTestLive,
          session: %{
            "id" => "test-terminal",
            "fullscreen" => true
          }
        )

      assert html =~ "terminal-container"
      assert has_element?(view, "#test-terminal")
    end
  end
end
