defmodule HydepwnsLiveview.Events.Adapters.EmailAdapter do
  @moduledoc """
  Adapter for sending encrypted email reminders.
  Supports multiple email providers including SendGrid, SMTP, and custom providers.
  """

  @behaviour HydepwnsLiveview.Events.Adapters.Adapter
  require Logger

  @impl true
  def send_reminder(reminder, _settings, config, encrypted_message) do
    with {:ok, email} <- validate_email(reminder.recipient),
         {:ok, email_content} <- build_email_content(reminder, encrypted_message, config),
         {:ok, _response} <- send_email(email, email_content, config) do
      Logger.info("Email sent successfully to #{email}")
      {:ok, "Email sent successfully"}
    else
      {:error, :invalid_email} ->
        Logger.error("Invalid email address: #{reminder.recipient}")
        {:error, "Invalid email address"}

      {:error, reason} ->
        Logger.error("Failed to send email: #{inspect(reason)}")
        {:error, "Failed to send email"}
    end
  end

  # Private functions

  defp validate_email(email) do
    # Basic email validation
    case Regex.run(~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/, email) do
      [valid_email] -> {:ok, valid_email}
      _ -> {:error, :invalid_email}
    end
  end

  defp build_email_content(reminder, encrypted_message, config) do
    # Build email content with both plain text and HTML versions
    content = %{
      subject: reminder.title || "Event Reminder",
      text: build_plain_text_content(reminder, encrypted_message, config),
      html: build_html_content(reminder, encrypted_message, config),
      attachments: build_attachments(reminder, config)
    }

    {:ok, content}
  end

  defp build_plain_text_content(reminder, encrypted_message, config) do
    """
    Hello,

    #{reminder.message || "You have a reminder"}

    Encrypted Message:
    #{encrypted_message}

    Reference: #{reminder.id}
    Sent at: #{DateTime.utc_now() |> DateTime.to_iso8601()}

    Best regards,
    #{config.from_name || "Hydepwns Liveview"}
    """
  end

  defp build_html_content(reminder, encrypted_message, config) do
    """
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .message { margin: 20px 0; }
          .encrypted { background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0; }
          .footer { margin-top: 30px; font-size: 0.9em; color: #666; }
        </style>
      </head>
      <body>
        <div class="container">
          <h2>#{reminder.title || "Event Reminder"}</h2>
          <div class="message">
            #{reminder.message || "You have a reminder"}
          </div>
          <div class="encrypted">
            <strong>Encrypted Message:</strong><br>
            #{encrypted_message}
          </div>
          <div class="footer">
            <p>Reference: #{reminder.id}</p>
            <p>Sent at: #{DateTime.utc_now() |> DateTime.to_iso8601()}</p>
            <p>Best regards,<br>#{config.from_name || "Hydepwns Liveview"}</p>
          </div>
        </div>
      </body>
    </html>
    """
  end

  defp build_attachments(reminder, config) do
    attachments = case config.attachments do
      attachments when is_list(attachments) ->
        Enum.map(attachments, fn attachment ->
          %{
            filename: attachment.filename,
            content: attachment.content,
            type: attachment.type
          }
        end)

      _ ->
        []
    end

    # Add reminder-specific attachments if any
    reminder_attachments = case reminder.attachments do
      attachments when is_list(attachments) -> attachments
      _ -> []
    end

    attachments ++ reminder_attachments
  end

  defp send_email(email, content, config) do
    case config.provider do
      "sendgrid" ->
        send_sendgrid_email(email, content.subject, content.text, config.api_key)

      "smtp" ->
        send_smtp_email(email, content, config)

      "custom" ->
        send_custom_email(email, content, config)

      _ ->
        {:error, "Unsupported email provider"}
    end
  end

  defp send_sendgrid_email(to, subject, body, api_key) do
    url = "https://api.sendgrid.com/v3/mail/send"

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    body =
      Jason.encode!(%{
        personalizations: [%{to: [%{email: to}]}],
        from: %{email: "noreply@hydepwns.com"},
        subject: subject,
        content: [%{type: "text/plain", value: body}]
      })

    case HTTPoison.post(url, body, headers) do
      {:ok, %{status_code: status_code}} when status_code in 200..299 ->
        {:ok, "Email sent successfully"}

      {:ok, %{status_code: status_code}} ->
        {:error, "Failed to send email with status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to send email: #{reason}"}
    end
  end

  defp send_smtp_email(email, content, config) do
    try do
      # Configure SMTP settings
      smtp_config = [
        relay: config.smtp_relay,
        port: config.smtp_port,
        username: config.smtp_username,
        password: config.smtp_password,
        ssl: config.smtp_ssl,
        tls: config.smtp_tls,
        auth: config.smtp_auth
      ]

      # Create email message
      message = %Swoosh.Email{
        to: email,
        from: {config.from_name, config.from_email},
        subject: content.subject,
        text_body: content.text,
        html_body: content.html,
        attachments: content.attachments
      }

      # Send email using Swoosh
      case Swoosh.Mailer.deliver(message, smtp_config) do
        {:ok, _response} ->
          {:ok, %{message_id: Ecto.UUID.generate()}}

        {:error, reason} ->
          Logger.error("SMTP error: #{inspect(reason)}")
          {:error, "Failed to send email via SMTP"}
      end
    rescue
      e ->
        Logger.error("SMTP error: #{inspect(e)}")
        {:error, "SMTP service error"}
    end
  end

  defp send_custom_email(email, content, config) do
    try do
      # Call custom email provider function
      case config.custom_provider.send_email(email, content, config) do
        {:ok, response} ->
          {:ok, %{message_id: response.message_id}}

        {:error, reason} ->
          Logger.error("Custom provider error: #{inspect(reason)}")
          {:error, "Failed to send email via custom provider"}
      end
    rescue
      e ->
        Logger.error("Custom provider error: #{inspect(e)}")
        {:error, "Custom provider service error"}
    end
  end
end
