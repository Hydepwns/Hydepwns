defmodule HydepwnsLiveview.Events.ReminderWorkerTest do
  use HydepwnsLiveview.DataCase, async: true

  alias HydepwnsLiveview.Events
  alias HydepwnsLiveview.Events.{Event, EventSettings, EventReminder, ReminderWorker}

  setup do
    # Start the reminder worker
    start_supervised!(ReminderWorker)

    # Create an event
    {:ok, event} =
      Events.create_event(%{
        title: "Test Event",
        description: "Test Description",
        start_time: DateTime.utc_now() |> DateTime.add(3600, :second),
        end_time: DateTime.utc_now() |> DateTime.add(7200, :second)
      })

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
        reminder_time: DateTime.utc_now() |> DateTime.add(-60, :second),
        status: "pending",
        recipient: "test@example.com"
      })

    # Create a future reminder
    {:ok, future_reminder} =
      Events.create_event_reminder(%{
        event_id: event.id,
        reminder_time: DateTime.utc_now() |> DateTime.add(3600, :second),
        status: "pending",
        recipient: "test@example.com"
      })

    %{
      event: event,
      settings: settings,
      due_reminder: due_reminder,
      future_reminder: future_reminder
    }
  end

  test "processes due reminders", %{due_reminder: due_reminder} do
    # Wait for the worker to process reminders
    Process.sleep(100)

    # Check that the due reminder was processed
    updated_reminder = Events.get_event_reminder!(due_reminder.id)
    assert updated_reminder.status == "sent"
    assert updated_reminder.sent_at != nil
  end

  test "does not process future reminders", %{future_reminder: future_reminder} do
    # Wait for the worker to process reminders
    Process.sleep(100)

    # Check that the future reminder was not processed
    updated_reminder = Events.get_event_reminder!(future_reminder.id)
    assert updated_reminder.status == "pending"
    assert updated_reminder.sent_at == nil
  end
end
