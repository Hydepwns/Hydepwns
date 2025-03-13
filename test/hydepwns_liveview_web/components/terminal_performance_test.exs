defmodule HydepwnsLiveviewWeb.Components.TerminalPerformanceTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import HydepwnsLiveviewWeb.PerformanceHelper

  @moduledoc """
  Performance tests for the Terminal component.

  These tests measure and verify performance metrics for the Terminal component
  to ensure it remains performant across different operations and devices.
  """

  @tag :performance
  test "terminal component performance metrics", %{conn: conn} do
    # Define actions to test
    actions = [
      {"enter_command",
       fn view ->
         view
         |> element("[data-test-id='terminal-input']")
         |> render_keyup(%{value: "test command"})
       end},
      {"execute_command",
       fn view ->
         view
         |> element("[data-test-id='terminal-input']")
         |> render_submit()
       end},
      {"toggle_fullscreen",
       fn view ->
         view
         |> element("[data-test-id='terminal-fullscreen-toggle']")
         |> render_click()
       end},
      {"toggle_theme",
       fn view ->
         view
         |> element("[data-test-id='theme-toggle']")
         |> render_click()
       end}
    ]

    # Define performance thresholds (in ms for time-based metrics)
    thresholds = %{
      # Initial render should be < 300ms
      initial_render: 300,
      # Typing should be < 50ms
      enter_command: 50,
      # Command execution should be < 100ms
      execute_command: 100,
      # UI transitions should be < 50ms
      toggle_fullscreen: 50,
      # Theme change should be < 75ms
      toggle_theme: 75,
      # Memory usage should be < 5MB
      memory_usage: 5_000_000
    }

    # Run the performance test suite
    metrics =
      performance_test_suite(
        conn,
        "/components/terminal",
        "terminal_component",
        actions,
        thresholds
      )

    # Additional specific assertions
    assert metrics.initial_render < 250,
           "Initial render time should be under 250ms for optimal user experience"
  end

  @tag :performance
  test "terminal command execution performance", %{conn: conn} do
    # Get the LiveView
    {:ok, view, _html} = live(conn, "/components/terminal")

    # Test different types of commands with varying complexity
    commands = [
      {"help", "Simple built-in command"},
      {"echo Hello, world!", "Command with parameters"},
      {"ls -la", "Shell command with options"},
      {"cat /etc/passwd | grep root", "Piped commands"}
    ]

    # Measure and record each command's performance
    command_metrics =
      Enum.map(commands, fn {command, description} ->
        # Measure execution time
        time =
          measure_live_action(view, fn view ->
            view
            |> element("[data-test-id='terminal-input']")
            |> render_keyup(%{value: command})
            |> element("[data-test-id='terminal-form']")
            |> render_submit()
          end)

        # Record individual command metrics
        record_metrics("terminal_command_#{command}", %{
          command: command,
          description: description,
          execution_time: time
        })

        # Assert performance for this command
        assert time < 150,
               "Command '#{command}' execution time (#{time}ms) exceeded threshold of 150ms"

        {command, time}
      end)
      |> Map.new()

    # Measure memory impact of executing all commands
    {_, memory_impact} =
      measure_memory(fn ->
        Enum.each(commands, fn {command, _} ->
          view
          |> element("[data-test-id='terminal-input']")
          |> render_keyup(%{value: command})
          |> element("[data-test-id='terminal-form']")
          |> render_submit()
        end)
      end)

    # Record combined metrics
    record_metrics(
      "terminal_commands_combined",
      Map.merge(command_metrics, %{
        memory_impact: memory_impact,
        command_count: length(commands)
      })
    )

    # Assert overall memory impact
    assert memory_impact < 10_000_000,
           "Memory impact of executing commands (#{memory_impact} bytes) exceeded threshold of 10MB"
  end

  @tag :performance
  test "terminal performance on simulated low-end device", %{conn: conn} do
    # Apply CPU and memory throttling through JavaScript
    {:ok, view, _html} = live(conn, "/components/terminal")

    # Inject throttling script
    throttle_script = """
    // Simulate a low-end device by creating CPU and memory pressure
    (function() {
      const startTime = Date.now();
      
      // Create CPU pressure
      const interval = setInterval(() => {
        if (Date.now() - startTime > 5000) {
          clearInterval(interval);
          window.throttlingActive = false;
          return;
        }
        
        // Busy wait to create CPU pressure
        const end = Date.now() + 10;
        while(Date.now() < end) {}
      }, 50);
      
      // Create memory pressure
      const memoryPressure = [];
      for (let i = 0; i < 1000; i++) {
        memoryPressure.push(new Array(10000).fill('x'));
      }
      
      window.throttlingActive = true;
      window.memoryPressure = memoryPressure;
    })();
    """

    render_hook(view, "eval_js", %{js: throttle_script})

    # Wait for throttling to be active
    Process.sleep(100)

    # Define actions to test under throttling
    throttled_actions = [
      {"type_command",
       fn view ->
         view
         |> element("[data-test-id='terminal-input']")
         |> render_keyup(%{value: "test under throttling"})
       end},
      {"execute_command",
       fn view ->
         view
         |> element("[data-test-id='terminal-form']")
         |> render_submit()
       end}
    ]

    # Measure each action under throttling
    throttled_metrics =
      Enum.map(throttled_actions, fn {action_name, action_fn} ->
        time = measure_live_action(view, action_fn)
        {action_name, time}
      end)
      |> Map.new()

    # Record the throttled metrics
    record_metrics("terminal_throttled", throttled_metrics)

    # The thresholds should be more lenient for throttled conditions
    assert throttled_metrics.type_command < 100,
           "Typing under throttling should still be responsive (<100ms)"

    assert throttled_metrics.execute_command < 200,
           "Command execution under throttling should be under 200ms"
  end
end
