defmodule HydepwnsLiveview.Events.Adapters.PushAdapter do
  @moduledoc """
  Adapter for sending push notifications.
  Supports multiple push notification providers including Firebase Cloud Messaging (FCM).
  """

  @behaviour HydepwnsLiveview.Events.Adapters.Adapter
  require Logger

  @impl true
  def send_reminder(reminder, settings, config, encrypted_message) do
    with {:ok, device_token} <- validate_device_token(reminder.recipient),
         {:ok, notification} <- build_push_notification(reminder, encrypted_message),
         {:ok, response} <- send_push_notification(device_token, notification, config) do
      Logger.info("Push notification sent successfully to device: #{device_token}")
      {:ok, "Push notification sent successfully"}
    else
      {:error, :invalid_token} ->
        Logger.error("Invalid device token: #{reminder.recipient}")
        {:error, "Invalid device token"}
      {:error, reason} ->
        Logger.error("Failed to send push notification: #{inspect(reason)}")
        {:error, "Failed to send push notification"}
    end
  end

  # Private functions

  defp validate_device_token(token) do
    # Basic FCM token validation (FCM tokens are typically 140-160 characters)
    case String.length(token) do
      len when len >= 140 and len <= 160 ->
        {:ok, token}
      _ ->
        {:error, :invalid_token}
    end
  end

  defp build_push_notification(reminder, encrypted_message) do
    # Build a structured notification payload
    notification = %{
      title: reminder.title || "Event Reminder",
      body: reminder.message || "You have a reminder",
      data: %{
        reminder_id: reminder.id,
        encrypted_message: encrypted_message,
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
      },
      android: %{
        priority: "high",
        notification: %{
          sound: "default",
          click_action: "FLUTTER_NOTIFICATION_CLICK"
        }
      },
      apns: %{
        payload: %{
          aps: %{
            sound: "default",
            badge: 1
          }
        }
      }
    }

    {:ok, notification}
  end

  defp send_push_notification(device_token, notification, config) do
    case config.provider do
      "fcm" ->
        send_fcm_notification(device_token, notification, config)
      "onesignal" ->
        send_onesignal_notification(device_token, notification, config)
      _ ->
        {:error, "Unsupported push notification provider"}
    end
  end

  defp send_fcm_notification(device_token, notification, config) do
    try do
      # FCM API endpoint
      url = "https://fcm.googleapis.com/v1/projects/#{config.project_id}/messages:send"
      
      # Prepare request body
      body = Jason.encode!(%{
        message: %{
          token: device_token,
          notification: %{
            title: notification.title,
            body: notification.body
          },
          data: notification.data,
          android: notification.android,
          apns: notification.apns
        }
      })

      # Send request with OAuth2 token
      headers = [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{config.oauth_token}"}
      ]

      case HTTPoison.post(url, body, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
          case Jason.decode(response_body) do
            {:ok, %{"name" => message_id}} ->
              {:ok, %{message_id: message_id}}
            {:ok, %{"error" => error}} ->
              Logger.error("FCM API error: #{inspect(error)}")
              {:error, "Failed to send FCM notification: #{error.message}"}
            _ ->
              Logger.error("Unexpected FCM response: #{response_body}")
              {:error, "Unexpected response from FCM"}
          end
        {:ok, %HTTPoison.Response{status_code: 401}} ->
          Logger.error("FCM authentication error")
          {:error, "FCM authentication failed"}
        {:ok, %HTTPoison.Response{status_code: status}} ->
          Logger.error("FCM HTTP error: #{status}")
          {:error, "FCM service error: HTTP #{status}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error("FCM request error: #{inspect(reason)}")
          {:error, "Failed to connect to FCM"}
      end
    rescue
      e ->
        Logger.error("FCM error: #{inspect(e)}")
        {:error, "FCM service error"}
    end
  end

  defp send_onesignal_notification(device_token, notification, config) do
    try do
      # OneSignal API endpoint
      url = "https://onesignal.com/api/v1/notifications"
      
      # Prepare request body
      body = Jason.encode!(%{
        app_id: config.app_id,
        include_player_ids: [device_token],
        headings: %{"en" => notification.title},
        contents: %{"en" => notification.body},
        data: notification.data,
        android_channel_id: config.android_channel_id,
        ios_badgeType: "Increase",
        ios_badgeCount: 1
      })

      # Send request
      headers = [
        {"Content-Type", "application/json"},
        {"Authorization", "Basic #{config.api_key}"}
      ]

      case HTTPoison.post(url, body, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
          case Jason.decode(response_body) do
            {:ok, %{"id" => notification_id}} ->
              {:ok, %{message_id: notification_id}}
            {:ok, %{"errors" => errors}} ->
              Logger.error("OneSignal API error: #{inspect(errors)}")
              {:error, "Failed to send OneSignal notification"}
            _ ->
              Logger.error("Unexpected OneSignal response: #{response_body}")
              {:error, "Unexpected response from OneSignal"}
          end
        {:ok, %HTTPoison.Response{status_code: 401}} ->
          Logger.error("OneSignal authentication error")
          {:error, "OneSignal authentication failed"}
        {:ok, %HTTPoison.Response{status_code: status}} ->
          Logger.error("OneSignal HTTP error: #{status}")
          {:error, "OneSignal service error: HTTP #{status}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error("OneSignal request error: #{inspect(reason)}")
          {:error, "Failed to connect to OneSignal"}
      end
    rescue
      e ->
        Logger.error("OneSignal error: #{inspect(e)}")
        {:error, "OneSignal service error"}
    end
  end
end 