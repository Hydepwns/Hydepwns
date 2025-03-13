defmodule HydepwnsLiveviewWeb.PerformanceHelper do
  @moduledoc """
  Helper for performance testing.

  This module provides utilities for measuring and recording performance metrics
  of LiveView components and pages.
  """

  import ExUnit.Assertions
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint HydepwnsLiveviewWeb.Endpoint

  @doc """
  Measures the time it takes to render a LiveView.

  ## Parameters

  - `conn` - The connection
  - `path` - The path to visit

  ## Returns

  The render time in milliseconds

  ## Examples

  ```elixir
  time = measure_live_render(conn, "/")
  assert time < 200 # Assert render time is under 200ms
  ```
  """
  def measure_live_render(conn, path) do
    start_time = System.monotonic_time(:millisecond)

    {:ok, _view, _html} = live(conn, path)

    end_time = System.monotonic_time(:millisecond)
    end_time - start_time
  end

  @doc """
  Measures the time it takes to perform an action in a LiveView.

  ## Parameters

  - `view` - The LiveView
  - `action_fn` - Function that performs the action on the view

  ## Returns

  The action time in milliseconds

  ## Examples

  ```elixir
  {:ok, view, _} = live(conn, "/")
  time = measure_live_action(view, fn view -> 
    view
    |> element("button")
    |> render_click()
  end)
  assert time < 50 # Assert action time is under 50ms
  ```
  """
  def measure_live_action(view, action_fn) do
    start_time = System.monotonic_time(:millisecond)

    action_fn.(view)

    end_time = System.monotonic_time(:millisecond)
    end_time - start_time
  end

  @doc """
  Records performance metrics to a file for later analysis.

  ## Parameters

  - `name` - Name of the test
  - `metrics` - Map of metrics to record

  ## Examples

  ```elixir
  record_metrics("home_page_load", %{
    initial_render: 120,
    click_response: 45,
    memory_usage: 15_000_000
  })
  ```
  """
  def record_metrics(name, metrics) do
    # Create the directory if it doesn't exist
    File.mkdir_p!("test/performance_results")

    # Get the current date for the filename
    date = Date.utc_today() |> Date.to_string()

    # Create a record with timestamp and metrics
    record = %{
      name: name,
      timestamp: DateTime.utc_now() |> DateTime.to_string(),
      metrics: metrics
    }

    # Convert to JSON
    json = Jason.encode!(record, pretty: true)

    # Append to the day's log file
    filename = "test/performance_results/#{date}.jsonl"
    File.write!(filename, json <> "\n", [:append])
  end

  @doc """
  Asserts that performance metrics are within acceptable thresholds.

  ## Parameters

  - `metrics` - Map of metrics to check
  - `thresholds` - Map of maximum acceptable values

  ## Examples

  ```elixir
  metrics = %{
    initial_render: 120,
    click_response: 45,
    memory_usage: 15_000_000
  }

  thresholds = %{
    initial_render: 200,
    click_response: 50,
    memory_usage: 20_000_000
  }

  assert_performance(metrics, thresholds)
  ```
  """
  def assert_performance(metrics, thresholds) do
    Enum.each(thresholds, fn {key, max_value} ->
      actual_value = Map.get(metrics, key)

      assert actual_value <= max_value,
             "Performance threshold exceeded for #{key}. Expected <= #{max_value}, got #{actual_value}"
    end)
  end

  @doc """
  Measures memory usage of a function.

  ## Parameters

  - `fun` - Function to measure

  ## Returns

  Tuple with function result and memory usage in bytes

  ## Examples

  ```elixir
  {result, memory} = measure_memory(fn -> 
    Enum.map(1..1000, &(&1 * 2))
  end)
  ```
  """
  def measure_memory(fun) do
    # Force garbage collection before measuring
    :erlang.garbage_collect()

    # Get initial memory
    {_, initial} = :erlang.process_info(self(), :memory)

    # Run the function
    result = fun.()

    # Force garbage collection to get accurate measurement
    :erlang.garbage_collect()

    # Get final memory
    {_, final} = :erlang.process_info(self(), :memory)

    # Return the result and memory difference
    {result, final - initial}
  end

  @doc """
  Runs a complete performance test suite for a LiveView.

  ## Parameters

  - `conn` - The connection
  - `path` - The path to visit
  - `name` - Name of the test
  - `actions` - List of {name, action_fn} tuples to test
  - `thresholds` - Map of maximum acceptable values

  ## Examples

  ```elixir
  performance_test_suite(conn, "/", "home_page", [
    {"click_button", fn view -> element(view, "button") |> render_click() end},
    {"submit_form", fn view -> element(view, "form") |> render_submit(%{}) end}
  ], %{
    initial_render: 200,
    click_button: 50,
    submit_form: 100,
    memory_usage: 20_000_000
  })
  ```
  """
  def performance_test_suite(conn, path, name, actions, thresholds) do
    # Measure initial render time
    initial_render = measure_live_render(conn, path)

    # Get view for actions
    {:ok, view, _html} = live(conn, path)

    # Measure each action
    action_metrics =
      Enum.map(actions, fn {action_name, action_fn} ->
        time = measure_live_action(view, action_fn)
        {action_name, time}
      end)
      |> Map.new()

    # Measure memory usage
    {_, memory_usage} =
      measure_memory(fn ->
        Enum.each(actions, fn {_, action_fn} -> action_fn.(view) end)
      end)

    # Combine all metrics
    metrics =
      Map.merge(action_metrics, %{
        initial_render: initial_render,
        memory_usage: memory_usage
      })

    # Record metrics for later analysis
    record_metrics(name, metrics)

    # Assert performance thresholds
    assert_performance(metrics, thresholds)

    # Return metrics for potential further assertions
    metrics
  end
end
