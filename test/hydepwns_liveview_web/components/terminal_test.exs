defmodule HydepwnsLiveviewWeb.Components.TerminalTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias HydepwnsLiveviewWeb.Components.Terminal

  describe "terminal/1" do
    test "renders a basic terminal" do
      html =
        render_component(&Terminal.terminal/1, %{
          id: "test-terminal",
          height: 10,
          width: 60
        })

      assert html =~ "test-terminal"
      assert html =~ "terminal"
      assert html =~ "terminal__input"
      assert html =~ "terminal__output"
    end

    test "renders a terminal with welcome message" do
      welcome_message = "Welcome to the test terminal"
      
      html =
        render_component(&Terminal.terminal/1, %{
          id: "test-terminal",
          height: 10,
          width: 60,
          welcome_message: welcome_message
        })

      assert html =~ "test-terminal"
      assert html =~ welcome_message
    end

    test "renders a terminal with custom prompt" do
      custom_prompt = "user@test:~$ "
      
      html =
        render_component(&Terminal.terminal/1, %{
          id: "test-terminal",
          height: 10,
          width: 60,
          prompt: custom_prompt
        })

      assert html =~ "test-terminal"
      assert html =~ custom_prompt
    end

    test "renders a terminal with custom theme" do
      html =
        render_component(&Terminal.terminal/1, %{
          id: "test-terminal",
          height: 10,
          width: 60,
          theme: "light"
        })

      assert html =~ "test-terminal"
      assert html =~ "terminal--light"
    end

    test "renders a terminal with fullscreen option" do
      html =
        render_component(&Terminal.terminal/1, %{
          id: "test-terminal",
          height: 10,
          width: 60,
          fullscreen: true
        })

      assert html =~ "test-terminal"
      assert html =~ "terminal__fullscreen-toggle"
    end
  end

  describe "terminal update/2" do
    test "handles command input" do
      {:ok, view, _html} =
        live_isolated_component(
          &Terminal.terminal/1,
          %{
            id: "test-terminal",
            height: 10,
            width: 60
          }
        )

      # Simulate command input
      assert view
             |> element("form")
             |> render_change(%{"command" => "help"})

      # Verify the command was processed
      assert render(view) =~ "help"
    end
  end
end 