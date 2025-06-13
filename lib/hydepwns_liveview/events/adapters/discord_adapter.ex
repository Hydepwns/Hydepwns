defmodule HydepwnsLiveview.Events.Adapters.DiscordAdapter do
  @moduledoc """
  Adapter for sending notifications to Discord channels.
  Supports rich embeds, attachments, and proper error handling.
  """

  @behaviour HydepwnsLiveview.Events.Adapters.Adapter
  require Logger

  @impl true
  def send_reminder(reminder, settings, config, encrypted_message) do
    with {:ok, channel_id} <- validate_channel_id(reminder.recipient),
         {:ok, message} <- build_discord_message(reminder, encrypted_message, config),
         {:ok, response} <- send_discord_message(channel_id, message, config) do
      Logger.info("Discord message sent successfully to channel #{channel_id}")
      {:ok, "Discord message sent successfully"}
    else
      {:error, :invalid_channel} ->
        Logger.error("Invalid Discord channel ID: #{reminder.recipient}")
        {:error, "Invalid Discord channel ID"}
      {:error, reason} ->
        Logger.error("Failed to send Discord message: #{inspect(reason)}")
        {:error, "Failed to send Discord message"}
    end
  end

  # Private functions

  defp validate_channel_id(channel_id) do
    # Discord channel IDs are 17-19 digits
    case Regex.run(~r/^\d{17,19}$/, channel_id) do
      [valid_id] -> {:ok, valid_id}
      _ -> {:error, :invalid_channel}
    end
  end

  defp build_discord_message(reminder, encrypted_message, config) do
    # Build a rich embed message
    embed = %{
      title: reminder.title || "Event Reminder",
      description: reminder.message || "You have a reminder",
      color: config.embed_color || 0x3498db, # Default to blue
      fields: [
        %{
          name: "Encrypted Message",
          value: "```\n#{encrypted_message}\n```",
          inline: false
        },
        %{
          name: "Reference",
          value: reminder.id,
          inline: true
        },
        %{
          name: "Sent At",
          value: DateTime.utc_now() |> DateTime.to_iso8601(),
          inline: true
        }
      ],
      footer: %{
        text: "Hydepwns Liveview"
      },
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    # Add thumbnail if configured
    embed = if config.thumbnail_url do
      Map.put(embed, :thumbnail, %{url: config.thumbnail_url})
    else
      embed
    end

    # Build the complete message
    message = %{
      content: config.mention_role && "<@&#{config.mention_role}>" || nil,
      embed: embed
    }

    # Add attachments if any
    message = case build_attachments(reminder, config) do
      [] -> message
      attachments -> Map.put(message, :attachments, attachments)
    end

    {:ok, message}
  end

  defp build_attachments(reminder, config) do
    case config.attachments do
      attachments when is_list(attachments) ->
        Enum.map(attachments, fn attachment ->
          %{
            filename: attachment.filename,
            description: attachment.description,
            content_type: attachment.content_type
          }
        end)
      _ -> []
    end
  end

  defp send_discord_message(channel_id, message, config) do
    try do
      # Discord API endpoint
      url = "https://discord.com/api/v10/channels/#{channel_id}/messages"
      
      # Prepare request body
      body = Jason.encode!(message)

      # Send request
      headers = [
        {"Content-Type", "application/json"},
        {"Authorization", "Bot #{config.bot_token}"},
        {"User-Agent", "HydepwnsLiveview (https://github.com/your-repo, v1.0)"}
      ]

      case HTTPoison.post(url, body, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
          case Jason.decode(response_body) do
            {:ok, %{"id" => message_id}} ->
              {:ok, %{message_id: message_id}}
            {:ok, error} ->
              Logger.error("Discord API error: #{inspect(error)}")
              {:error, "Failed to send Discord message"}
            {:error, _} ->
              Logger.error("Invalid Discord API response")
              {:error, "Invalid Discord API response"}
          end
        {:ok, %HTTPoison.Response{status_code: 401}} ->
          Logger.error("Discord authentication error")
          {:error, "Discord authentication failed"}
        {:ok, %HTTPoison.Response{status_code: 403}} ->
          Logger.error("Discord permission error")
          {:error, "Insufficient permissions to send message"}
        {:ok, %HTTPoison.Response{status_code: 429, body: response_body}} ->
          handle_rate_limit(response_body)
        {:ok, %HTTPoison.Response{status_code: status}} ->
          Logger.error("Discord HTTP error: #{status}")
          {:error, "Discord service error: HTTP #{status}"}
        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error("Discord request error: #{inspect(reason)}")
          {:error, "Failed to connect to Discord"}
      end
    rescue
      e ->
        Logger.error("Discord error: #{inspect(e)}")
        {:error, "Discord service error"}
    end
  end

  defp handle_rate_limit(response_body) do
    case Jason.decode(response_body) do
      {:ok, %{"retry_after" => retry_after}} ->
        Logger.warning("Discord rate limit hit, retry after #{retry_after}ms")
        Process.sleep(retry_after)
        {:error, "Rate limited, please retry"}
      {:ok, error} ->
        Logger.error("Discord rate limit error: #{inspect(error)}")
        {:error, "Discord rate limit error"}
      {:error, _} ->
        Logger.error("Invalid Discord rate limit response")
        {:error, "Discord rate limit error"}
    end
  end
end 