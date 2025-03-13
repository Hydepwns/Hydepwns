defmodule Mix.Tasks.TestFrameworkDemo do
  @moduledoc """
  Runs the TestFramework examples and generates visual reports.

  ## Usage

  ```
  mix test_framework_demo
  ```

  This task will:

  1. Run all examples from TestFrameworkExamples
  2. Generate HTML reports for each test
  3. Open the reports in your default browser

  ## Options

  * `--report-dir` - Directory to save reports (default: "test_reports")
  * `--open` - Whether to open reports in browser (default: true)
  * `--example` - Run a specific example (e.g. "basic_scenario")
  """

  use Mix.Task

  alias HydepwnsLiveview.Resources.TestFrameworkExamples
  alias HydepwnsLiveview.Resources.TestFrameworkReporter

  @shortdoc "Run TestFramework examples and generate reports"

  @impl Mix.Task
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [
          report_dir: :string,
          open: :boolean,
          example: :string
        ],
        aliases: [
          r: :report_dir,
          o: :open,
          e: :example
        ]
      )

    report_dir = Keyword.get(opts, :report_dir, "test_reports")
    open_reports = Keyword.get(opts, :open, true)
    specific_example = Keyword.get(opts, :example)

    # Ensure report directory exists
    File.mkdir_p!(report_dir)

    # Get list of examples
    examples =
      if specific_example do
        [{specific_example, get_example_function(specific_example)}]
      else
        [
          {"basic_scenario", &TestFrameworkExamples.example_basic_scenario/0},
          {"given_events", &TestFrameworkExamples.example_given_events_and_state_verification/0},
          {"command_helpers", &TestFrameworkExamples.example_command_helpers/0},
          {"property_testing", &TestFrameworkExamples.example_property_based_testing/0},
          {"test_suite", &TestFrameworkExamples.example_test_suite/0},
          {"advanced_scenario",
           &TestFrameworkExamples.example_custom_events_and_advanced_scenario/0}
        ]
      end

    # Run examples and generate reports
    reports = run_examples_and_generate_reports(examples, report_dir)

    # Display summary
    display_summary(reports)

    # Open reports in browser if requested
    if open_reports do
      reports
      |> Enum.filter(fn {_, path, _} -> path != nil end)
      |> Enum.each(fn {_, path, _} ->
        open_in_browser(path)
      end)
    end
  end

  defp get_example_function(example_name) do
    case example_name do
      "basic_scenario" -> &TestFrameworkExamples.example_basic_scenario/0
      "given_events" -> &TestFrameworkExamples.example_given_events_and_state_verification/0
      "command_helpers" -> &TestFrameworkExamples.example_command_helpers/0
      "property_testing" -> &TestFrameworkExamples.example_property_based_testing/0
      "test_suite" -> &TestFrameworkExamples.example_test_suite/0
      "advanced_scenario" -> &TestFrameworkExamples.example_custom_events_and_advanced_scenario/0
      _ -> raise "Unknown example: #{example_name}"
    end
  end

  defp run_examples_and_generate_reports(examples, report_dir) do
    Enum.map(examples, fn {name, example_fn} ->
      IO.puts("\n\n== Running example: #{name} ==\n")

      # Run the example
      result = example_fn.()

      # Generate report path
      report_path = Path.join(report_dir, "#{name}_report.html")

      # Generate report based on result type
      case result do
        {:ok, context} ->
          # Scenario test result
          report =
            TestFrameworkReporter.generate_scenario_report({:ok, context},
              title: "#{name} Example Report"
            )

          :ok = TestFrameworkReporter.save_report(report, report_path)
          {name, report_path, :passed}

        {:error, errors, context} ->
          # Failed scenario test result
          report =
            TestFrameworkReporter.generate_scenario_report({:error, errors, context},
              title: "#{name} Example Report"
            )

          :ok = TestFrameworkReporter.save_report(report, report_path)
          {name, report_path, :failed}

        %{total_tests: _, passed: _, failed: _} = suite_result ->
          # Test suite result
          report =
            TestFrameworkReporter.generate_test_suite_report(suite_result,
              title: "#{name} Example Report"
            )

          :ok = TestFrameworkReporter.save_report(report, report_path)
          status = if suite_result.failed == 0, do: :passed, else: :failed
          {name, report_path, status}

        {:ok, %{successes: _}} ->
          # Passed property test
          report =
            TestFrameworkReporter.generate_property_test_report(result,
              title: "#{name} Example Report"
            )

          :ok = TestFrameworkReporter.save_report(report, report_path)
          {name, report_path, :passed}

        {:error, %{failures: _}} ->
          # Failed property test
          report =
            TestFrameworkReporter.generate_property_test_report(result,
              title: "#{name} Example Report"
            )

          :ok = TestFrameworkReporter.save_report(report, report_path)
          {name, report_path, :failed}

        _ ->
          IO.puts("Unknown result type for #{name}")
          {name, nil, :unknown}
      end
    end)
  end

  defp display_summary(reports) do
    passed = Enum.count(reports, fn {_, _, status} -> status == :passed end)
    failed = Enum.count(reports, fn {_, _, status} -> status == :failed end)
    unknown = Enum.count(reports, fn {_, _, status} -> status == :unknown end)

    IO.puts("\n\n== TestFramework Demo Summary ==")
    IO.puts("Total examples: #{length(reports)}")
    IO.puts("Passed: #{passed}")
    IO.puts("Failed: #{failed}")

    if unknown > 0 do
      IO.puts("Unknown status: #{unknown}")
    end

    IO.puts("\nReports generated:")

    reports
    |> Enum.filter(fn {_, path, _} -> path != nil end)
    |> Enum.each(fn {name, path, status} ->
      status_icon =
        case status do
          :passed -> "✅"
          :failed -> "❌"
          _ -> "❓"
        end

      IO.puts("#{status_icon} #{name}: #{path}")
    end)
  end

  defp open_in_browser(path) do
    abs_path = Path.expand(path)

    {cmd, args} =
      case :os.type() do
        {:win32, _} -> {"cmd", ["/c", "start", "", abs_path]}
        {:unix, :darwin} -> {"open", [abs_path]}
        {:unix, _} -> {"xdg-open", [abs_path]}
      end

    System.cmd(cmd, args)
  end
end
