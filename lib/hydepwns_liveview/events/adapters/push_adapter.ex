defmodule HydepwnsLiveview.Events.Adapters.PushAdapter do
  @moduledoc """
  Adapter for sending push notifications to mobile devices.
  Supports multiple push notification services and proper error handling.
  """

  @behaviour HydepwnsLiveview.Events.Adapters.Adapter
  require Logger

  @impl true
  def send_reminder(reminder, _settings, config, encrypted_message) do
    with {:ok, device_token} <- validate_device_token(reminder.recipient),
         {:ok, notification} <- build_push_notification(reminder, encrypted_message, config),
         {:ok, _response} <- send_push_notification(device_token, notification, config) do
      Logger.info("Push notification sent successfully to device #{device_token}")
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
    # Basic token validation (should be a non-empty string)
    case token do
      token when is_binary(token) and byte_size(token) > 0 ->
        {:ok, token}
      _ ->
        {:error, :invalid_token}
    end
  end

  defp build_push_notification(reminder, encrypted_message, config) do
    # Build a push notification with title and body
    notification = %{
      title: reminder.title,
      body: reminder.message,
      data: %{
        reminder_id: reminder.id,
        encrypted_message: encrypted_message,
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }

    # Add custom data if configured
    notification = case config.custom_data do
      data when is_map(data) ->
        Map.update!(notification, :data, &Map.merge(&1, data))
      _ ->
        notification
    end

    {:ok, notification}
  end

  defp send_push_notification(device_token, notification, config) do
    case config.provider do
      "onesignal" -> send_onesignal_notification(device_token, notification, config)
      "firebase" -> send_firebase_notification(device_token, notification, config)
      _ -> {:error, "Unsupported push notification provider"}
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

  defp send_firebase_notification(device_token, notification, config) do
    try do
      # Firebase Cloud Messaging API endpoint
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
          android: %{
            notification: %{
              channel_id: config.android_channel_id
            }
          },
          apns: %{
            payload: %{
              aps: %{
                badge: 1
              }
            }
          }
        }
      })

      # Send request
      headers = [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{config.server_key}"}
      ]

      case HTTPoison.post(url, body, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
          case Jason.decode(response_body) do
            {:ok, %{"name" => message_id}} ->
              {:ok, %{message_id: message_id}}
            {:ok, error} ->
              Logger.error("Firebase API error: #{inspect(error)}")
              {:error, "Failed to send Firebase notification"}
            {:error, _} ->
              Logger.error("Invalid Firebase API response")
              {:error, "Invalid Firebase API response"}
          end
        {:ok, %HTTPoison.Response{status_code: 401}} ->
          Logger.error("Firebase authentication error")
          {:error, "Firebase authentication failed"}
        {:ok, %HTTPoison.Response{status_code: status}} ->
          Logger.error("Firebase HTTP error: #{status}")
          {:error, "Firebase service error: HTTP #{status}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error("Firebase request error: #{inspect(reason)}")
          {:error, "Failed to connect to Firebase"}
      end
    rescue
      e ->
        Logger.error("Firebase error: #{inspect(e)}")
        {:error, "Firebase service error"}
    end
  end
end 