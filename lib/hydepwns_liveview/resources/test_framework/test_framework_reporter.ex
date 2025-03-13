defmodule HydepwnsLiveview.Resources.TestFrameworkReporter do
  @moduledoc """
  Provides reporting and visualization capabilities for TestFramework results.

  This module generates HTML reports from TestFramework test results,
  making it easier to understand test outcomes, event sequences, and state transitions.

  Features:
  - HTML report generation
  - Event sequence visualization
  - State transition visualization
  - Test suite summary reports
  """

  alias HydepwnsLiveview.Resources.TestFramework

  @doc """
  Generates an HTML report for a scenario test result.

  ## Parameters
  * `result` - The result from TestFramework.scenario_test/3
  * `opts` - Report options

  ## Returns
  * HTML string for the report
  """
  def generate_scenario_report(result, opts \\ []) do
    title = Keyword.get(opts, :title, "Scenario Test Report")
    timestamp = DateTime.utc_now() |> DateTime.to_string()

    case result do
      {:ok, context} ->
        """
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>#{title}</title>
          <style>
            #{report_css()}
          </style>
        </head>
        <body>
          <div class="container">
            <h1>#{title}</h1>
            <div class="report-meta">
              <p>Generated: #{timestamp}</p>
              <p>Resource: #{context.resource_type}</p>
              <p>Resource ID: #{context.resource_id}</p>
            </div>
            
            <div class="status success">
              <h2>✅ Test Passed</h2>
            </div>
            
            <h2>Event Sequence</h2>
            #{generate_event_sequence(context.events)}
            
            <h2>Final State</h2>
            #{generate_state_visualization(context.current_state)}
          </div>
        </body>
        </html>
        """

      {:error, errors, context} ->
        """
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>#{title}</title>
          <style>
            #{report_css()}
          </style>
        </head>
        <body>
          <div class="container">
            <h1>#{title}</h1>
            <div class="report-meta">
              <p>Generated: #{timestamp}</p>
              <p>Resource: #{context.resource_type}</p>
              <p>Resource ID: #{context.resource_id}</p>
            </div>
            
            <div class="status failure">
              <h2>❌ Test Failed</h2>
            </div>
            
            <h2>Errors</h2>
            <div class="errors">
              #{errors |> Enum.map(fn error -> "<div class=\"error\">#{error}</div>" end) |> Enum.join("\n")}
            </div>
            
            <h2>Event Sequence</h2>
            #{generate_event_sequence(context.events)}
            
            <h2>Final State</h2>
            #{generate_state_visualization(context.current_state)}
          </div>
        </body>
        </html>
        """
    end
  end

  @doc """
  Generates an HTML report for a property test result.

  ## Parameters
  * `result` - The result from TestFramework.property_test/3
  * `opts` - Report options

  ## Returns
  * HTML string for the report
  """
  def generate_property_test_report(result, opts \\ []) do
    title = Keyword.get(opts, :title, "Property Test Report")
    timestamp = DateTime.utc_now() |> DateTime.to_string()

    case result do
      {:ok, stats} ->
        """
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>#{title}</title>
          <style>
            #{report_css()}
          </style>
        </head>
        <body>
          <div class="container">
            <h1>#{title}</h1>
            <div class="report-meta">
              <p>Generated: #{timestamp}</p>
            </div>
            
            <div class="status success">
              <h2>✅ Property Test Passed</h2>
              <p>Successful iterations: #{stats.successes}</p>
            </div>
            
            <div class="chart-container">
              <h2>Test Results</h2>
              <div class="chart">
                <div class="chart-bar success" style="width: 100%;">
                  <span>100% Success (#{stats.successes} iterations)</span>
                </div>
              </div>
            </div>
          </div>
        </body>
        </html>
        """

      {:error, stats} ->
        failures = length(stats.failures)
        success_rate = Float.round(stats.successes / (stats.successes + failures) * 100, 1)
        failure_rate = Float.round(failures / (stats.successes + failures) * 100, 1)

        failure_details =
          stats.failures
          |> Enum.map(fn failure ->
            """
            <div class="failure-detail">
              <h4>Failure on iteration #{failure.iteration} (Seed: #{failure.seed})</h4>
              <h5>Errors:</h5>
              <ul>
                #{failure.errors |> Enum.map(fn error -> "<li>#{error}</li>" end) |> Enum.join("\n")}
              </ul>
              <h5>Events:</h5>
              #{generate_event_sequence(failure.events)}
            </div>
            """
          end)
          |> Enum.join("\n")

        """
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>#{title}</title>
          <style>
            #{report_css()}
          </style>
        </head>
        <body>
          <div class="container">
            <h1>#{title}</h1>
            <div class="report-meta">
              <p>Generated: #{timestamp}</p>
            </div>
            
            <div class="status failure">
              <h2>❌ Property Test Failed</h2>
              <p>Successful iterations: #{stats.successes}</p>
              <p>Failed iterations: #{failures}</p>
            </div>
            
            <div class="chart-container">
              <h2>Test Results</h2>
              <div class="chart">
                <div class="chart-bar success" style="width: #{success_rate}%;">
                  <span>#{success_rate}% Success (#{stats.successes} iterations)</span>
                </div>
                <div class="chart-bar failure" style="width: #{failure_rate}%;">
                  <span>#{failure_rate}% Failure (#{failures} iterations)</span>
                </div>
              </div>
            </div>
            
            <h2>Failure Details</h2>
            <div class="failures">
              #{failure_details}
            </div>
          </div>
        </body>
        </html>
        """
    end
  end

  @doc """
  Generates an HTML report for a test suite result.

  ## Parameters
  * `result` - The result from TestFramework.test_suite/3
  * `opts` - Report options

  ## Returns
  * HTML string for the report
  """
  def generate_test_suite_report(result, opts \\ []) do
    title = Keyword.get(opts, :title, "Test Suite Report")
    timestamp = DateTime.utc_now() |> DateTime.to_string()

    success_rate = Float.round(result.passed / result.total_tests * 100, 1)
    failure_rate = Float.round(result.failed / result.total_tests * 100, 1)

    # Generate detailed results for each test
    test_results =
      result.results
      |> Enum.map(fn {name, test_result} ->
        case test_result do
          {:ok, _} ->
            """
            <div class="test-result success">
              <h3>✅ #{name}</h3>
              <p>Status: Passed</p>
            </div>
            """

          {:error, errors, _} ->
            """
            <div class="test-result failure">
              <h3>❌ #{name}</h3>
              <p>Status: Failed</p>
              <h4>Errors:</h4>
              <ul>
                #{errors |> Enum.map(fn error -> "<li>#{error}</li>" end) |> Enum.join("\n")}
              </ul>
            </div>
            """
        end
      end)
      |> Enum.join("\n")

    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>#{title}</title>
      <style>
        #{report_css()}
      </style>
    </head>
    <body>
      <div class="container">
        <h1>#{title}</h1>
        <div class="report-meta">
          <p>Generated: #{timestamp}</p>
          <p>Resource Type: #{result.resource_type}</p>
        </div>
        
        <div class="status #{if result.failed == 0, do: "success", else: "failure"}">
          <h2>Test Suite Summary</h2>
          <p>Total Tests: #{result.total_tests}</p>
          <p>Passed: #{result.passed}</p>
          <p>Failed: #{result.failed}</p>
        </div>
        
        <div class="chart-container">
          <h2>Test Results</h2>
          <div class="chart">
            <div class="chart-bar success" style="width: #{success_rate}%;">
              <span>#{success_rate}% Success (#{result.passed} tests)</span>
            </div>
            #{if result.failed > 0 do
      """
      <div class="chart-bar failure" style="width: #{failure_rate}%;">
        <span>#{failure_rate}% Failure (#{result.failed} tests)</span>
      </div>
      """
    end}
          </div>
        </div>
        
        <h2>Test Details</h2>
        <div class="test-results">
          #{test_results}
        </div>
      </div>
    </body>
    </html>
    """
  end

  @doc """
  Saves a report to a file.

  ## Parameters
  * `report` - The HTML report string
  * `filename` - The output file path

  ## Returns
  * `:ok` if successful, `{:error, reason}` otherwise
  """
  def save_report(report, filename) do
    File.write(filename, report)
  end

  @doc """
  Runs a scenario test and generates a report.

  ## Parameters
  * `resource_module` - The resource module to test
  * `scenario` - The test scenario function
  * `opts` - Test and report options

  ## Returns
  * `{:ok, report_path}` if successful, `{:error, reason}` otherwise
  """
  def run_scenario_and_report(resource_module, scenario, opts \\ []) do
    # Extract options
    report_title = Keyword.get(opts, :title, "Scenario Test Report")

    report_path =
      Keyword.get(
        opts,
        :output_path,
        "test_reports/scenario_report_#{DateTime.utc_now() |> DateTime.to_unix()}.html"
      )

    # Ensure the directory exists
    report_dir = Path.dirname(report_path)
    File.mkdir_p(report_dir)

    # Run the test
    result = TestFramework.scenario_test(resource_module, scenario, opts)

    # Generate and save the report
    report = generate_scenario_report(result, title: report_title)

    case save_report(report, report_path) do
      :ok -> {:ok, report_path}
      error -> error
    end
  end

  @doc """
  Runs a property test and generates a report.

  ## Parameters
  * `resource_module` - The resource module to test
  * `property` - The property function
  * `opts` - Test and report options

  ## Returns
  * `{:ok, report_path}` if successful, `{:error, reason}` otherwise
  """
  def run_property_test_and_report(resource_module, property, opts \\ []) do
    # Extract options
    report_title = Keyword.get(opts, :title, "Property Test Report")

    report_path =
      Keyword.get(
        opts,
        :output_path,
        "test_reports/property_report_#{DateTime.utc_now() |> DateTime.to_unix()}.html"
      )

    # Ensure the directory exists
    report_dir = Path.dirname(report_path)
    File.mkdir_p(report_dir)

    # Run the test
    result = TestFramework.property_test(resource_module, property, opts)

    # Generate and save the report
    report = generate_property_test_report(result, title: report_title)

    case save_report(report, report_path) do
      :ok -> {:ok, report_path}
      error -> error
    end
  end

  @doc """
  Runs a test suite and generates a report.

  ## Parameters
  * `resource_module` - The resource module to test
  * `test_cases` - The test cases map
  * `opts` - Test and report options

  ## Returns
  * `{:ok, report_path}` if successful, `{:error, reason}` otherwise
  """
  def run_test_suite_and_report(resource_module, test_cases, opts \\ []) do
    # Extract options
    report_title = Keyword.get(opts, :title, "Test Suite Report")

    report_path =
      Keyword.get(
        opts,
        :output_path,
        "test_reports/test_suite_report_#{DateTime.utc_now() |> DateTime.to_unix()}.html"
      )

    # Ensure the directory exists
    report_dir = Path.dirname(report_path)
    File.mkdir_p(report_dir)

    # Run the test suite
    result = TestFramework.test_suite(resource_module, test_cases, opts)

    # Generate and save the report
    report = generate_test_suite_report(result, title: report_title)

    case save_report(report, report_path) do
      :ok -> {:ok, report_path}
      error -> error
    end
  end

  # Private helper functions

  defp generate_event_sequence(events) do
    event_items =
      events
      |> Enum.with_index()
      |> Enum.map(fn {event, index} ->
        """
        <div class="event-item">
          <div class="event-index">#{index + 1}</div>
          <div class="event-details">
            <div class="event-header">
              <span class="event-type">#{event.type}</span>
              <span class="event-id">#{event.resource_id}</span>
            </div>
            <div class="event-data">
              <pre>#{inspect(event.data, pretty: true)}</pre>
            </div>
            #{if map_size(event.metadata) > 0 do
          """
          <div class="event-metadata">
            <details>
              <summary>Metadata</summary>
              <pre>#{inspect(event.metadata, pretty: true)}</pre>
            </details>
          </div>
          """
        else
          ""
        end}
          </div>
        </div>
        """
      end)
      |> Enum.join("\n")

    """
    <div class="event-sequence">
      #{if events == [] do
      "<div class=\"no-events\">No events</div>"
    else
      event_items
    end}
    </div>
    """
  end

  defp generate_state_visualization(state) do
    # Convert state to a list of key-value pairs for display
    state_entries =
      state
      |> Map.to_list()
      |> Enum.map(fn {key, value} ->
        """
        <tr>
          <td class="state-key">#{key}</td>
          <td class="state-value">#{format_state_value(value)}</td>
        </tr>
        """
      end)
      |> Enum.join("\n")

    """
    <div class="state-visualization">
      <table class="state-table">
        <thead>
          <tr>
            <th>Field</th>
            <th>Value</th>
          </tr>
        </thead>
        <tbody>
          #{state_entries}
        </tbody>
      </table>
    </div>
    """
  end

  defp format_state_value(value) when is_map(value) do
    """
    <details>
      <summary>Map</summary>
      <pre>#{inspect(value, pretty: true)}</pre>
    </details>
    """
  end

  defp format_state_value(value) when is_list(value) do
    if Enum.empty?(value) do
      "[]"
    else
      """
      <details>
        <summary>List (#{length(value)} items)</summary>
        <pre>#{inspect(value, pretty: true)}</pre>
      </details>
      """
    end
  end

  defp format_state_value(%DateTime{} = value) do
    DateTime.to_string(value)
  end

  defp format_state_value(value) do
    inspect(value)
  end

  defp report_css do
    """
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
      line-height: 1.6;
      color: #333;
      background-color: #f8f9fa;
    }

    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 2rem;
    }

    h1, h2, h3, h4 {
      margin-bottom: 1rem;
      color: #2c3e50;
    }

    h1 {
      font-size: 2.5rem;
      border-bottom: 2px solid #eaecef;
      padding-bottom: 0.5rem;
    }

    h2 {
      font-size: 1.75rem;
      margin-top: 2rem;
    }

    .report-meta {
      display: flex;
      flex-wrap: wrap;
      gap: 1rem;
      margin-bottom: 2rem;
      font-size: 0.9rem;
      color: #6c757d;
    }

    .status {
      border-radius: 8px;
      padding: 1.5rem;
      margin-bottom: 2rem;
    }

    .success {
      background-color: #d4edda;
      color: #155724;
      border: 1px solid #c3e6cb;
    }

    .failure {
      background-color: #f8d7da;
      color: #721c24;
      border: 1px solid #f5c6cb;
    }

    .chart-container {
      margin: 2rem 0;
    }

    .chart {
      display: flex;
      height: 40px;
      width: 100%;
      border-radius: 4px;
      overflow: hidden;
    }

    .chart-bar {
      display: flex;
      align-items: center;
      justify-content: center;
      min-width: 60px;
      height: 100%;
      transition: width 0.3s ease;
    }

    .chart-bar span {
      color: white;
      font-weight: bold;
      text-shadow: 0 0 2px rgba(0,0,0,0.5);
      white-space: nowrap;
    }

    .event-sequence {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      margin-bottom: 2rem;
    }

    .event-item {
      display: flex;
      border: 1px solid #dee2e6;
      border-radius: 4px;
      overflow: hidden;
      background-color: white;
    }

    .event-index {
      background-color: #e9ecef;
      color: #495057;
      font-weight: bold;
      padding: 1rem;
      display: flex;
      align-items: center;
      justify-content: center;
      min-width: 60px;
    }

    .event-details {
      flex: 1;
      padding: 1rem;
    }

    .event-header {
      display: flex;
      justify-content: space-between;
      margin-bottom: 0.5rem;
    }

    .event-type {
      font-weight: bold;
      color: #0066cc;
    }

    .event-id {
      color: #6c757d;
      font-size: 0.9rem;
    }

    .event-data, .event-metadata {
      background-color: #f8f9fa;
      border-radius: 4px;
      padding: 0.5rem;
      margin-top: 0.5rem;
    }

    .event-metadata {
      margin-top: 0.5rem;
      color: #6c757d;
    }

    .no-events {
      text-align: center;
      padding: 2rem;
      color: #6c757d;
      font-style: italic;
      background-color: #f8f9fa;
      border-radius: 4px;
    }

    .state-visualization {
      background-color: white;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }

    .state-table {
      width: 100%;
      border-collapse: collapse;
    }

    .state-table th, .state-table td {
      padding: 0.75rem 1rem;
      text-align: left;
      border-bottom: 1px solid #e9ecef;
    }

    .state-table th {
      background-color: #f8f9fa;
      font-weight: bold;
    }

    .state-key {
      font-weight: 600;
      width: 30%;
    }

    .test-results {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 1rem;
    }

    .test-result {
      padding: 1.5rem;
      border-radius: 8px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }

    .errors, .failures {
      margin-bottom: 2rem;
    }

    .error, .failure-detail {
      padding: 1rem;
      margin-bottom: 1rem;
      border-radius: 4px;
      background-color: #f8d7da;
      border: 1px solid #f5c6cb;
      color: #721c24;
    }

    pre {
      font-family: 'Courier New', Courier, monospace;
      white-space: pre-wrap;
      word-break: break-word;
      font-size: 0.9rem;
    }

    details {
      margin: 0.5rem 0;
    }

    summary {
      cursor: pointer;
      user-select: none;
    }

    details > pre {
      margin-top: 0.5rem;
      padding: 0.5rem;
      background-color: #f1f3f5;
      border-radius: 4px;
    }

    @media (max-width: 768px) {
      .container {
        padding: 1rem;
      }
      
      .test-results {
        grid-template-columns: 1fr;
      }
      
      .event-sequence {
        overflow-x: auto;
      }
    }
    """
  end
end
