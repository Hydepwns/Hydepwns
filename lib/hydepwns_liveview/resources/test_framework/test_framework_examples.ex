defmodule HydepwnsLiveview.Resources.TestFrameworkExamples do
  @moduledoc """
  This module provides comprehensive examples for using the TestFramework module
  to test event-sourced resources in the Hydepwns application.

  It includes examples of:
  - Basic scenario testing
  - Property-based testing
  - Test helpers and reusable commands
  - State verification techniques
  - Custom event generation for testing

  Each example is documented in detail to serve as a reference for developers.
  """

  alias HydepwnsLiveview.Resources.TestFramework
  alias HydepwnsLiveview.Events.Core.Event

  # Sample resource module for the examples
  # In a real application, you would use your actual resource modules
  defmodule SampleTodoResource do
    @moduledoc """
    Sample Todo resource for demonstration purposes.
    """

    def resource_type, do: "todo"

    def initial_state do
      %{
        id: nil,
        title: "",
        completed: false,
        created_at: nil,
        updated_at: nil,
        assigned_to: nil,
        priority: "normal",
        tags: []
      }
    end

    def create(title, opts \\ []) do
      now = DateTime.utc_now()
      id = Keyword.get(opts, :id, "todo-#{:rand.uniform(1000)}")
      assigned_to = Keyword.get(opts, :assigned_to, nil)
      priority = Keyword.get(opts, :priority, "normal")
      tags = Keyword.get(opts, :tags, [])

      state = initial_state()

      if String.length(title) > 0 do
        event = %Event{
          type: "created",
          resource_type: resource_type(),
          resource_id: id,
          data: %{
            id: id,
            title: title,
            assigned_to: assigned_to,
            priority: priority,
            tags: tags,
            created_at: now,
            updated_at: now
          },
          metadata: %{},
          correlation_id: Ecto.UUID.generate()
        }

        {:ok, apply_event(state, event), [event]}
      else
        {:error, "Title cannot be empty"}
      end
    end

    def complete(state) do
      now = DateTime.utc_now()

      if state.completed do
        {:error, "Todo is already completed"}
      else
        event = %Event{
          type: "completed",
          resource_type: resource_type(),
          resource_id: state.id,
          data: %{
            completed: true,
            updated_at: now
          },
          metadata: %{},
          correlation_id: Ecto.UUID.generate()
        }

        {:ok, apply_event(state, event), [event]}
      end
    end

    def update_title(state, title) do
      now = DateTime.utc_now()

      if String.length(title) > 0 do
        event = %Event{
          type: "title_updated",
          resource_type: resource_type(),
          resource_id: state.id,
          data: %{
            title: title,
            updated_at: now
          },
          metadata: %{},
          correlation_id: Ecto.UUID.generate()
        }

        {:ok, apply_event(state, event), [event]}
      else
        {:error, "Title cannot be empty"}
      end
    end

    def assign(state, user_id) do
      now = DateTime.utc_now()

      event = %Event{
        type: "assigned",
        resource_type: resource_type(),
        resource_id: state.id,
        data: %{
          assigned_to: user_id,
          updated_at: now
        },
        metadata: %{},
        correlation_id: Ecto.UUID.generate()
      }

      {:ok, apply_event(state, event), [event]}
    end

    def update_priority(state, priority) do
      now = DateTime.utc_now()

      if priority in ["low", "normal", "high", "urgent"] do
        event = %Event{
          type: "priority_updated",
          resource_type: resource_type(),
          resource_id: state.id,
          data: %{
            priority: priority,
            updated_at: now
          },
          metadata: %{},
          correlation_id: Ecto.UUID.generate()
        }

        {:ok, apply_event(state, event), [event]}
      else
        {:error, "Invalid priority value"}
      end
    end

    def add_tag(state, tag) do
      now = DateTime.utc_now()

      if tag in state.tags do
        {:error, "Tag already exists"}
      else
        event = %Event{
          type: "tag_added",
          resource_type: resource_type(),
          resource_id: state.id,
          data: %{
            tag: tag,
            updated_at: now
          },
          metadata: %{},
          correlation_id: Ecto.UUID.generate()
        }

        {:ok, apply_event(state, event), [event]}
      end
    end

    def remove_tag(state, tag) do
      now = DateTime.utc_now()

      if tag not in state.tags do
        {:error, "Tag does not exist"}
      else
        event = %Event{
          type: "tag_removed",
          resource_type: resource_type(),
          resource_id: state.id,
          data: %{
            tag: tag,
            updated_at: now
          },
          metadata: %{},
          correlation_id: Ecto.UUID.generate()
        }

        {:ok, apply_event(state, event), [event]}
      end
    end

    def apply_event(state, %{type: "created"} = event) do
      %{
        state
        | id: event.data.id,
          title: event.data.title,
          assigned_to: event.data.assigned_to,
          priority: event.data.priority,
          tags: event.data.tags,
          created_at: event.data.created_at,
          updated_at: event.data.updated_at
      }
    end

    def apply_event(state, %{type: "completed"} = event) do
      %{state | completed: event.data.completed, updated_at: event.data.updated_at}
    end

    def apply_event(state, %{type: "title_updated"} = event) do
      %{state | title: event.data.title, updated_at: event.data.updated_at}
    end

    def apply_event(state, %{type: "assigned"} = event) do
      %{state | assigned_to: event.data.assigned_to, updated_at: event.data.updated_at}
    end

    def apply_event(state, %{type: "priority_updated"} = event) do
      %{state | priority: event.data.priority, updated_at: event.data.updated_at}
    end

    def apply_event(state, %{type: "tag_added"} = event) do
      %{state | tags: [event.data.tag | state.tags], updated_at: event.data.updated_at}
    end

    def apply_event(state, %{type: "tag_removed"} = event) do
      %{
        state
        | tags: Enum.filter(state.tags, &(&1 != event.data.tag)),
          updated_at: event.data.updated_at
      }
    end

    def event_types do
      [
        "created",
        "completed",
        "title_updated",
        "assigned",
        "priority_updated",
        "tag_added",
        "tag_removed"
      ]
    end
  end

  @doc """
  Example 1: Basic Scenario Testing

  This example demonstrates how to create a simple scenario test for a Todo resource.
  It shows creating a todo, updating its title, and marking it as complete.
  """
  def example_basic_scenario do
    # Define the test scenario as a function
    scenario = fn context ->
      context
      |> TestFramework.when_command(
        fn _state -> SampleTodoResource.create("Buy groceries") end,
        # We expect a created event
        [%{type: "created"}]
      )
      |> TestFramework.when_command(
        fn state -> SampleTodoResource.update_title(state, "Buy groceries today") end,
        # We expect a title_updated event
        [%{type: "title_updated"}]
      )
      |> TestFramework.when_command(
        fn state -> SampleTodoResource.complete(state) end,
        # We expect a completed event
        [%{type: "completed"}]
      )
      |> TestFramework.then_state(fn state ->
        state.completed == true &&
          state.title == "Buy groceries today"
      end)
    end

    # Run the scenario test
    result = TestFramework.scenario_test(SampleTodoResource, scenario)

    case result do
      {:ok, context} ->
        IO.puts("✅ Basic scenario test passed")
        {:ok, context}

      {:error, errors, context} ->
        IO.puts("❌ Basic scenario test failed")
        IO.inspect(errors, label: "Errors")
        {:error, errors, context}
    end
  end

  @doc """
  Example 2: Given Events and State Verification

  This example demonstrates setting up initial state with given events
  and then verifying specific fields in the final state.
  """
  def example_given_events_and_state_verification do
    # Create some initial events to set up the state
    resource_id = "todo-123"
    creation_time = DateTime.utc_now()

    initial_events = [
      %Event{
        type: "created",
        resource_type: "todo",
        resource_id: resource_id,
        data: %{
          id: resource_id,
          title: "Write documentation",
          assigned_to: "user-456",
          priority: "high",
          tags: ["docs", "important"],
          created_at: creation_time,
          updated_at: creation_time
        },
        metadata: %{},
        correlation_id: Ecto.UUID.generate()
      }
    ]

    # Define the test scenario
    scenario = fn context ->
      context
      |> TestFramework.given_events(initial_events)
      |> TestFramework.when_command(fn state ->
        SampleTodoResource.update_priority(state, "urgent")
      end)
      |> TestFramework.when_command(fn state -> SampleTodoResource.add_tag(state, "deadline") end)
      |> TestFramework.then_fields(%{
        title: "Write documentation",
        priority: "urgent",
        assigned_to: "user-456",
        tags: ["deadline", "docs", "important"]
      })
    end

    # Run the scenario test
    result = TestFramework.scenario_test(SampleTodoResource, scenario)

    case result do
      {:ok, context} ->
        IO.puts("✅ Given events and state verification test passed")
        {:ok, context}

      {:error, errors, context} ->
        IO.puts("❌ Given events and state verification test failed")
        IO.inspect(errors, label: "Errors")
        {:error, errors, context}
    end
  end

  @doc """
  Example 3: Using Command Helpers for Readability

  This example demonstrates creating reusable command helpers to make tests
  more readable and maintainable.
  """
  def example_command_helpers do
    # Define some command helpers
    create_todo =
      TestFramework.command_helper(
        :create_todo,
        fn _state, args -> SampleTodoResource.create(args.title, args) end,
        fn args, _ctx -> [%{type: "created", resource_id: args[:id]}] end
      )

    complete_todo =
      TestFramework.command_helper(
        :complete_todo,
        fn state, _args -> SampleTodoResource.complete(state) end,
        fn _args, _ctx -> [%{type: "completed"}] end
      )

    add_tag =
      TestFramework.command_helper(
        :add_tag,
        fn state, args -> SampleTodoResource.add_tag(state, args.tag) end,
        fn args, _ctx -> [%{type: "tag_added", data: %{tag: args.tag}}] end
      )

    # Define the test scenario using command helpers
    scenario = fn context ->
      {_, create_fn} = create_todo
      {_, complete_fn} = complete_todo
      {_, add_tag_fn} = add_tag

      context
      |> create_fn.(%{title: "Finish the project", id: "todo-999", priority: "high"})
      |> add_tag_fn.(%{tag: "project"})
      |> add_tag_fn.(%{tag: "deadline"})
      |> complete_fn.(%{})
      |> TestFramework.then_state(fn state ->
        state.completed == true &&
          state.priority == "high" &&
          "project" in state.tags &&
          "deadline" in state.tags
      end)
    end

    # Run the scenario test
    result = TestFramework.scenario_test(SampleTodoResource, scenario)

    case result do
      {:ok, context} ->
        IO.puts("✅ Command helpers test passed")
        {:ok, context}

      {:error, errors, context} ->
        IO.puts("❌ Command helpers test failed")
        IO.inspect(errors, label: "Errors")
        {:error, errors, context}
    end
  end

  @doc """
  Example 4: Property-Based Testing

  This example demonstrates property-based testing by creating random
  event sequences and verifying that certain properties hold.
  """
  def example_property_based_testing do
    # Define a property that should hold for all possible event sequences
    property = fn context ->
      # Property: If a todo is marked as completed, it stays completed
      # regardless of other operations

      # Check if the todo was ever completed
      was_completed =
        Enum.any?(context.events, fn event ->
          event.type == "completed"
        end)

      if was_completed do
        # If it was completed, the final state should show it as completed
        TestFramework.then_state(context, fn state ->
          state.completed == true
        end)
      else
        # If it was never completed, we don't make any assertions
        context
      end
    end

    # Run the property test with 50 iterations
    result = TestFramework.property_test(SampleTodoResource, property, iterations: 50)

    case result do
      {:ok, stats} ->
        IO.puts("✅ Property test passed for #{stats.successes} iterations")
        {:ok, stats}

      {:error, stats} ->
        IO.puts("❌ Property test failed")
        IO.inspect(stats.failures, label: "Failures")
        {:error, stats}
    end
  end

  @doc """
  Example 5: Test Suite Creation

  This example demonstrates how to create a comprehensive test suite
  with multiple test cases.
  """
  def example_test_suite do
    # Define multiple test cases
    test_cases = %{
      "todo_creation" => fn context ->
        context
        |> TestFramework.when_command(fn _state -> SampleTodoResource.create("Test Todo") end)
        |> TestFramework.then_fields(%{
          title: "Test Todo",
          completed: false
        })
      end,
      "todo_completion" => fn context ->
        context
        |> TestFramework.when_command(fn _state -> SampleTodoResource.create("Test Todo") end)
        |> TestFramework.when_command(fn state -> SampleTodoResource.complete(state) end)
        |> TestFramework.then_fields(%{
          completed: true
        })
      end,
      "reject_empty_title" => fn context ->
        result =
          TestFramework.when_command(
            context,
            fn _state -> SampleTodoResource.create("") end
          )

        # Expect an error in the context
        if length(result.errors) > 0 do
          result
        else
          %{result | errors: ["Expected an error for empty title but none was present"]}
        end
      end,
      "tags_management" => fn context ->
        context
        |> TestFramework.when_command(fn _state -> SampleTodoResource.create("Test Todo") end)
        |> TestFramework.when_command(fn state -> SampleTodoResource.add_tag(state, "test") end)
        |> TestFramework.when_command(fn state ->
          SampleTodoResource.add_tag(state, "example")
        end)
        |> TestFramework.when_command(fn state ->
          SampleTodoResource.remove_tag(state, "test")
        end)
        |> TestFramework.then_state(fn state ->
          state.tags == ["example"]
        end)
      end
    }

    # Run the test suite
    results = TestFramework.test_suite(SampleTodoResource, test_cases)

    IO.puts("Test Suite Results:")
    IO.puts("- Total Tests: #{results.total_tests}")
    IO.puts("- Passed: #{results.passed}")
    IO.puts("- Failed: #{results.failed}")

    results
  end

  @doc """
  Example 6: Custom Event Generation and Advanced Scenario Testing

  This example demonstrates how to create custom events for testing
  complex scenarios that might be difficult to set up through commands.
  """
  def example_custom_events_and_advanced_scenario do
    # Create a function that generates a sequence of realistic events
    generate_complex_scenario = fn resource_id ->
      now = DateTime.utc_now()

      [
        # Created with specific attributes
        %Event{
          type: "created",
          resource_type: "todo",
          resource_id: resource_id,
          data: %{
            id: resource_id,
            title: "Implement feature X",
            assigned_to: "user-123",
            priority: "normal",
            tags: ["feature", "sprint-5"],
            created_at: DateTime.add(now, -3600, :second),
            updated_at: DateTime.add(now, -3600, :second)
          },
          metadata: %{author: "user-admin"},
          correlation_id: Ecto.UUID.generate()
        },

        # Title updated
        %Event{
          type: "title_updated",
          resource_type: "todo",
          resource_id: resource_id,
          data: %{
            title: "Implement feature X with tests",
            updated_at: DateTime.add(now, -3000, :second)
          },
          metadata: %{author: "user-123"},
          correlation_id: Ecto.UUID.generate()
        },

        # Priority changed
        %Event{
          type: "priority_updated",
          resource_type: "todo",
          resource_id: resource_id,
          data: %{
            priority: "high",
            updated_at: DateTime.add(now, -2400, :second)
          },
          metadata: %{author: "user-manager"},
          correlation_id: Ecto.UUID.generate()
        },

        # Reassigned
        %Event{
          type: "assigned",
          resource_type: "todo",
          resource_id: resource_id,
          data: %{
            assigned_to: "user-456",
            updated_at: DateTime.add(now, -1800, :second)
          },
          metadata: %{author: "user-manager"},
          correlation_id: Ecto.UUID.generate()
        },

        # Tag added
        %Event{
          type: "tag_added",
          resource_type: "todo",
          resource_id: resource_id,
          data: %{
            tag: "urgent",
            updated_at: DateTime.add(now, -1200, :second)
          },
          metadata: %{author: "user-manager"},
          correlation_id: Ecto.UUID.generate()
        }
      ]
    end

    # Define a test scenario that uses custom events
    scenario = fn context ->
      resource_id = "todo-complex-123"
      events = generate_complex_scenario.(resource_id)

      context
      |> TestFramework.given_events(events)
      |> TestFramework.when_command(fn state -> SampleTodoResource.complete(state) end)
      |> TestFramework.then_state(fn state ->
        state.title == "Implement feature X with tests" &&
          state.assigned_to == "user-456" &&
          state.priority == "high" &&
          Enum.sort(state.tags) == Enum.sort(["feature", "sprint-5", "urgent"]) &&
          state.completed == true
      end)
    end

    # Run the scenario test
    result = TestFramework.scenario_test(SampleTodoResource, scenario)

    case result do
      {:ok, context} ->
        IO.puts("✅ Custom events and advanced scenario test passed")
        {:ok, context}

      {:error, errors, context} ->
        IO.puts("❌ Custom events and advanced scenario test failed")
        IO.inspect(errors, label: "Errors")
        {:error, errors, context}
    end
  end

  @doc """
  Run all examples in sequence and report the results.
  """
  def run_all_examples do
    examples = [
      {"Basic Scenario Testing", &example_basic_scenario/0},
      {"Given Events and State Verification", &example_given_events_and_state_verification/0},
      {"Command Helpers", &example_command_helpers/0},
      {"Property-Based Testing", &example_property_based_testing/0},
      {"Test Suite Creation", &example_test_suite/0},
      {"Custom Events and Advanced Scenarios", &example_custom_events_and_advanced_scenario/0}
    ]

    results =
      Enum.map(examples, fn {name, example_fn} ->
        IO.puts("\n\n========= Running Example: #{name} =========\n")

        {time, result} = :timer.tc(example_fn)
        execution_time_ms = time / 1000

        IO.puts("\n========= Example: #{name} completed in #{execution_time_ms}ms =========\n")

        {name, result, execution_time_ms}
      end)

    successful =
      Enum.count(results, fn
        {_, {:ok, _}, _} -> true
        {_, %{failed: 0}, _} -> true
        _ -> false
      end)

    total = length(results)

    IO.puts("\n\n========= Examples Summary =========")
    IO.puts("Total Examples: #{total}")
    IO.puts("Successful: #{successful}")
    IO.puts("Failed: #{total - successful}")

    if successful == total do
      IO.puts("\n✅ All examples passed!")
    else
      IO.puts("\n❌ Some examples failed!")
    end

    results
  end
end
