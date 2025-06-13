defmodule HydepwnsLiveview.Events.ReminderDelivery do
  @moduledoc """
  Handles the delivery of event reminders through various channels.
  """

  alias HydepwnsLiveview.Events
  alias HydepwnsLiveview.Events.EventReminder
  alias HydepwnsLiveview.Events.DeliveryService
  alias HydepwnsLiveview.Repo

  @doc """
  Sends a reminder and updates its status.
  Returns {:ok, reminder} on success or {:error, reason} on failure.
  """
  def send_reminder(reminder) do
    case reminder.status do
      "pending" -> do_send_reminder(reminder)
      _ -> {:error, "Reminder is not in pending status"}
    end
  end

  defp do_send_reminder(reminder) do
    Repo.transaction(fn ->
      case get_event_settings(reminder.event_id) do
        {:ok, settings} ->
          case deliver_reminder(reminder, settings) do
            {:ok, _} ->
              update_reminder_status(reminder, "sent")
            {:error, reason} ->
              update_reminder_status(reminder, "failed", reason)
              Repo.rollback(reason)
          end
        {:error, reason} ->
          update_reminder_status(reminder, "failed", reason)
          Repo.rollback(reason)
      end
    end)
  end

  defp get_event_settings(event_id) do
    case Events.get_event_settings_by_event_id(event_id) do
      nil -> {:error, "No event settings found"}
      settings -> {:ok, settings}
    end
  end

  defp deliver_reminder(reminder, settings) do
    # Convert reminder_type to atom for the delivery service
    delivery_type = String.to_existing_atom(settings.reminder_type)

    # Send the reminder using the delivery service
    case DeliveryService.send_reminder(reminder, delivery_type, settings) do
      {:ok, _} = result -> result
      {:error, reason} -> {:error, "Failed to send reminder: #{reason}"}
    end
  end

  defp update_reminder_status(reminder, status, error_message \\ nil) do
    reminder
    |> EventReminder.changeset(%{
      status: status,
      sent_at: DateTime.utc_now(),
      error_message: error_message
    })
    |> Repo.update()
  end
end 