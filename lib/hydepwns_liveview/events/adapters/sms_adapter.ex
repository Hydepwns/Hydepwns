defmodule HydepwnsLiveview.Events.Adapters.SMSAdapter do
  @moduledoc """
  Adapter for sending SMS reminders.
  Supports multiple SMS providers including Twilio and MessageBird.
  """

  @behaviour HydepwnsLiveview.Events.Adapters.Adapter
  require Logger

  @impl true
  def send_reminder(reminder, settings, config, encrypted_message) do
    with {:ok, phone_number} <- validate_phone_number(reminder.recipient),
         {:ok, message} <- build_sms_message(reminder, encrypted_message),
         {:ok, response} <- send_sms(phone_number, message, config) do
      Logger.info("SMS sent successfully to #{phone_number}")
      {:ok, "SMS sent successfully"}
    else
      {:error, :invalid_number} ->
        Logger.error("Invalid phone number: #{reminder.recipient}")
        {:error, "Invalid phone number"}
      {:error, reason} ->
        Logger.error("Failed to send SMS: #{inspect(reason)}")
        {:error, "Failed to send SMS"}
    end
  end

  # Private functions

  defp validate_phone_number(recipient) do
    # Basic phone number validation
    case Regex.run(~r/^\+?[1-9]\d{1,14}$/, recipient) do
      [number] -> {:ok, number}
      _ -> {:error, :invalid_number}
    end
  end

  defp build_sms_message(reminder, encrypted_message) do
    # Build a concise SMS message that fits within standard SMS length limits
    message = cond do
      reminder.message && String.length(reminder.message) <= 160 ->
        reminder.message
      reminder.message ->
        String.slice(reminder.message, 0, 157) <> "..."
      true ->
        "Reminder: #{reminder.title || 'Event reminder'}"
    end

    # Add a short link or reference if needed
    message = message <> "\nRef: #{reminder.id}"

    {:ok, message}
  end

  defp send_sms(phone_number, message, config) do
    case config.provider do
      "twilio" ->
        send_twilio_sms(phone_number, message, config)
      "messagebird" ->
        send_messagebird_sms(phone_number, message, config)
      "nexmo" ->
        send_nexmo_sms(phone_number, message, config)
      _ ->
        {:error, "Unsupported SMS provider"}
    end
  end

  defp send_twilio_sms(phone_number, message, config) do
    try do
      client = Twilio.client(config.account_sid, config.auth_token)
      
      case Twilio.Message.create(client, %{
        to: phone_number,
        from: config.from_number,
        body: message
      }) do
        {:ok, response} ->
          {:ok, %{message_id: response.sid}}
        {:error, reason} ->
          Logger.error("Twilio API error: #{inspect(reason)}")
          {:error, "Failed to send SMS via Twilio"}
      end
    rescue
      e ->
        Logger.error("Twilio error: #{inspect(e)}")
        {:error, "Twilio service error"}
    end
  end

  defp send_messagebird_sms(phone_number, message, config) do
    try do
      client = MessageBird.client(config.api_key)
      
      case MessageBird.Message.create(client, %{
        recipients: [phone_number],
        originator: config.originator,
        body: message
      }) do
        {:ok, response} ->
          {:ok, %{message_id: response.id}}
        {:error, reason} ->
          Logger.error("MessageBird API error: #{inspect(reason)}")
          {:error, "Failed to send SMS via MessageBird"}
      end
    rescue
      e ->
        Logger.error("MessageBird error: #{inspect(e)}")
        {:error, "MessageBird service error"}
    end
  end

  defp send_nexmo_sms(phone_number, message, config) do
    try do
      # Nexmo API endpoint
      url = "https://rest.nexmo.com/sms/json"
      
      # Prepare request body
      body = Jason.encode!(%{
        api_key: config.api_key,
        api_secret: config.api_secret,
        to: phone_number,
        from: config.from_number,
        text: message
      })

      # Send request
      case HTTPoison.post(url, body, [{"Content-Type", "application/json"}]) do
        {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
          case Jason.decode(response_body) do
            {:ok, %{"messages" => [%{"message-id" => message_id} | _]}} ->
              {:ok, %{message_id: message_id}}
            {:ok, %{"messages" => [%{"error-text" => error} | _]}} ->
              Logger.error("Nexmo API error: #{error}")
              {:error, "Failed to send SMS via Nexmo: #{error}"}
            _ ->
              Logger.error("Unexpected Nexmo response: #{response_body}")
              {:error, "Unexpected response from Nexmo"}
          end
        {:ok, %HTTPoison.Response{status_code: status}} ->
          Logger.error("Nexmo HTTP error: #{status}")
          {:error, "Nexmo service error: HTTP #{status}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error("Nexmo request error: #{inspect(reason)}")
          {:error, "Failed to connect to Nexmo"}
      end
    rescue
      e ->
        Logger.error("Nexmo error: #{inspect(e)}")
        {:error, "Nexmo service error"}
    end
  end
end 