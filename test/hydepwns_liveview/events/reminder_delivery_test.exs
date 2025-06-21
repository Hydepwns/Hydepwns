defmodule HydepwnsLiveview.Events.ReminderDeliveryTest do
  use HydepwnsLiveview.DataCase

  alias HydepwnsLiveview.Events
  alias HydepwnsLiveview.Events.ReminderDelivery

  describe "send_reminder/1" do
    setup do
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

      # Create a reminder
      {:ok, reminder} =
        Events.create_event_reminder(%{
          event_id: event.id,
          reminder_time: DateTime.utc_now() |> DateTime.add(-60, :second),
          status: "pending",
          recipient: "test@example.com"
        })

      %{event: event, settings: settings, reminder: reminder}
    end

    test "successfully sends a reminder", %{reminder: reminder} do
      assert {:ok, updated_reminder} = ReminderDelivery.send_reminder(reminder)
      assert updated_reminder.status == "sent"
      assert updated_reminder.sent_at != nil
    end

    test "fails to send a non-pending reminder", %{reminder: reminder} do
      {:ok, sent_reminder} = Events.update_event_reminder(reminder, %{status: "sent"})

      assert {:error, "Reminder is not in pending status"} =
               ReminderDelivery.send_reminder(sent_reminder)
    end

    test "fails when event settings are missing", %{reminder: reminder} do
      # Delete event settings
      Events.delete_event_settings(Events.get_event_settings_by_event_id(reminder.event_id))

      assert {:error, "No event settings found"} = ReminderDelivery.send_reminder(reminder)
    end
  end
end
