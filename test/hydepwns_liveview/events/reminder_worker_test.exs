defmodule HydepwnsLiveview.Events.ReminderWorkerTest do
  use HydepwnsLiveview.DataCase, async: false

  alias HydepwnsLiveview.Events

  setup do
    # ReminderWorker is already started globally in the application

    # Create an event directly in the database (not using MockEventStore)
    {:ok, event} =
      %HydepwnsLiveview.Events.Core.Event{}
      |> HydepwnsLiveview.Events.Core.Event.changeset(%{
        type: "calendar_event.created",
        data: %{
          title: "Test Event",
          description: "Test Description",
          start_time: DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second),
          end_time: DateTime.utc_now() |> DateTime.add(7200, :second) |> DateTime.truncate(:second)
        },
        resource_type: "calendar_event",
        resource_id: Ecto.UUID.generate(),
        timestamp: DateTime.utc_now() |> DateTime.truncate(:second)
      })
      |> HydepwnsLiveview.Repo.insert()

    # Create event settings
    {:ok, settings} =
      Events.create_event_settings(%{
        event_id: event.id,
        reminder_time: 30,
        reminder_type: "email",
        reminder_message: "Test reminder message"
      })

    # Create a due reminder
    {:ok, due_reminder} =
      Events.create_event_reminder(%{
        event_id: event.id,
        reminder_time: DateTime.utc_now() |> DateTime.add(-60, :second) |> DateTime.truncate(:second),
        status: "pending",
        recipient: "test@example.com"
      })

    # Create a future reminder
    {:ok, future_reminder} =
      Events.create_event_reminder(%{
        event_id: event.id,
        reminder_time: DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.truncate(:second),
        status: "pending",
        recipient: "test@example.com"
      })

    # Allow ReminderWorker process to use the test DB connection
    Ecto.Adapters.SQL.Sandbox.allow(HydepwnsLiveview.Repo, self(), Process.whereis(HydepwnsLiveview.Events.ReminderWorker))

    %{
      event: event,
      settings: settings,
      due_reminder: due_reminder,
      future_reminder: future_reminder
    }
  end

  test "processes due reminders", %{due_reminder: due_reminder} do
    # Manually trigger the reminder worker to process reminders
    send(HydepwnsLiveview.Events.ReminderWorker, :check_reminders)
    
    # Wait longer for processing
    Process.sleep(200)

    # Check that the due reminder was processed
    updated_reminder = Events.get_event_reminder!(due_reminder.id)
    IO.inspect(updated_reminder, label: "Updated reminder status")
    assert updated_reminder.status == "sent"
    assert updated_reminder.sent_at != nil
  end

  test "does not process future reminders", %{future_reminder: future_reminder} do
    # Manually trigger the reminder worker to process reminders
    send(HydepwnsLiveview.Events.ReminderWorker, :check_reminders)
    
    # Wait a bit for processing
    Process.sleep(50)

    # Check that the future reminder was not processed
    updated_reminder = Events.get_event_reminder!(future_reminder.id)
    assert updated_reminder.status == "pending"
    assert updated_reminder.sent_at == nil
  end
end
