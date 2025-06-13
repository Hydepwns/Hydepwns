# Event Adapters

This directory contains adapters for different notification channels including SMS, Push notifications, Webhooks, and Email.

## SMS Adapter

This adapter provides SMS notification functionality using multiple providers (Twilio, MessageBird, and Nexmo).

## Setup

1. Add the required dependencies to your `mix.exs`:

   ```elixir
   defp deps do
     [
       {:twilio, "~> 0.4.0"},
       {:httpoison, "~> 1.8"},
       {:jason, "~> 1.2"}
     ]
   end
   ```

2. Configure your SMS providers in `config/sms_providers.exs`:

   ```elixir
   config :hydepwns_liveview, :sms_providers,
     twilio: %{
       account_sid: System.get_env("TWILIO_ACCOUNT_SID"),
       auth_token: System.get_env("TWILIO_AUTH_TOKEN"),
       from_number: System.get_env("TWILIO_FROM_NUMBER")
     },
     messagebird: %{
       api_key: System.get_env("MESSAGEBIRD_API_KEY"),
       originator: System.get_env("MESSAGEBIRD_ORIGINATOR")
     },
     nexmo: %{
       api_key: System.get_env("NEXMO_API_KEY"),
       api_secret: System.get_env("NEXMO_API_SECRET"),
       from_number: System.get_env("NEXMO_FROM_NUMBER")
     }
   ```

3. Set up your environment variables:

   ```bash
   # Twilio
   export TWILIO_ACCOUNT_SID="your_account_sid"
   export TWILIO_AUTH_TOKEN="your_auth_token"
   export TWILIO_FROM_NUMBER="your_twilio_number"

   # MessageBird
   export MESSAGEBIRD_API_KEY="your_api_key"
   export MESSAGEBIRD_ORIGINATOR="your_originator"

   # Nexmo
   export NEXMO_API_KEY="your_api_key"
   export NEXMO_API_SECRET="your_api_secret"
   export NEXMO_FROM_NUMBER="your_nexmo_number"
   ```

## Usage

The SMS adapter can be used to send SMS notifications through any of the supported providers:

```elixir
# Example usage with Twilio
config = %{
  provider: "twilio",
  account_sid: System.get_env("TWILIO_ACCOUNT_SID"),
  auth_token: System.get_env("TWILIO_AUTH_TOKEN"),
  from_number: System.get_env("TWILIO_FROM_NUMBER")
}

reminder = %{
  recipient: "+1234567890",
  message: "Your reminder message",
  title: "Reminder Title",
  id: "reminder_123"
}

HydepwnsLiveview.Events.Adapters.SMSAdapter.send_reminder(reminder, settings, config, encrypted_message)
```

## Features

- Support for multiple SMS providers (Twilio, MessageBird, Nexmo)
- Phone number validation
- Message length handling
- Error handling and logging
- Provider-specific configurations
- Secure credential management using environment variables

## Error Handling

The adapter includes comprehensive error handling for:

- Invalid phone numbers
- API errors
- Network issues
- Provider-specific errors

All errors are logged and returned in a consistent format.

## Message Format

Messages are automatically formatted to:

- Fit within standard SMS length limits (160 characters)
- Include a reference ID
- Maintain readability

## Security

- Credentials are stored in environment variables
- API keys and tokens are never logged
- Phone numbers are validated before sending
- All API communications are over HTTPS

## Push Adapter

The PushAdapter provides push notification functionality using multiple providers (Firebase Cloud Messaging and OneSignal).

### Setup

1. Configure your push notification providers in `config/push_providers.exs`:

   ```elixir
   config :hydepwns_liveview, :push_providers,
     fcm: %{
       project_id: System.get_env("FCM_PROJECT_ID"),
       oauth_token: System.get_env("FCM_OAUTH_TOKEN"),
       service_account_path: System.get_env("FCM_SERVICE_ACCOUNT_PATH")
     },
     onesignal: %{
       app_id: System.get_env("ONESIGNAL_APP_ID"),
       api_key: System.get_env("ONESIGNAL_API_KEY"),
       android_channel_id: System.get_env("ONESIGNAL_ANDROID_CHANNEL_ID")
     }
   ```

2. Set up your environment variables:

   ```bash
   # Firebase Cloud Messaging
   export FCM_PROJECT_ID="your_project_id"
   export FCM_OAUTH_TOKEN="your_oauth_token"
   export FCM_SERVICE_ACCOUNT_PATH="path/to/service-account.json"

   # OneSignal
   export ONESIGNAL_APP_ID="your_app_id"
   export ONESIGNAL_API_KEY="your_api_key"
   export ONESIGNAL_ANDROID_CHANNEL_ID="your_channel_id"
   ```

### Usage

The PushAdapter can be used to send push notifications through any of the supported providers:

```elixir
# Example usage with Firebase Cloud Messaging
config = %{
  provider: "fcm",
  project_id: System.get_env("FCM_PROJECT_ID"),
  oauth_token: System.get_env("FCM_OAUTH_TOKEN")
}

reminder = %{
  recipient: "device_token_here",
  message: "Your reminder message",
  title: "Reminder Title",
  id: "reminder_123"
}

HydepwnsLiveview.Events.Adapters.PushAdapter.send_reminder(reminder, settings, config, encrypted_message)
```

### Features

- Support for multiple push notification providers (FCM, OneSignal)
- Device token validation
- Structured notification payloads
- Platform-specific configurations (Android/iOS)
- Error handling and logging
- Provider-specific configurations
- Secure credential management using environment variables

### Error Handling

The adapter includes comprehensive error handling for:

- Invalid device tokens
- API errors
- Network issues
- Provider-specific errors
- Authentication failures

All errors are logged and returned in a consistent format.

### Notification Format

Notifications are structured to support:

- Title and body text
- Custom data payload
- Platform-specific settings
- Sound and badge configurations
- Click actions

### Security

- Credentials are stored in environment variables
- API keys and tokens are never logged
- Device tokens are validated before sending
- All API communications are over HTTPS
- OAuth2 authentication for FCM
- Basic authentication for OneSignal

## Webhook Adapter

The WebhookAdapter provides functionality for sending notifications to custom webhook endpoints with support for multiple authentication methods, retries, and custom payload formatting.

### Setup

1. Configure your webhook providers in `config/webhook_providers.exs`:

   ```elixir
   config :hydepwns_liveview, :webhook_providers,
     default: %{
       version: "1.0",
       max_retries: 3,
       retry_delay: 1000,
       timeout: 5000,
       auth: %{
         type: "bearer",
         token: System.get_env("WEBHOOK_AUTH_TOKEN")
       },
       custom_headers: %{
         "X-Webhook-Source" => "hydepwns_liveview",
         "X-Webhook-Version" => "1.0"
       }
     }
   ```

2. Set up your environment variables:

   ```bash
   # Default webhook configuration
   export WEBHOOK_AUTH_TOKEN="your_auth_token"

   # Custom webhook configuration (if needed)
   export CUSTOM_WEBHOOK_URL="https://api.example.com/webhooks"
   export CUSTOM_WEBHOOK_USERNAME="your_username"
   export CUSTOM_WEBHOOK_PASSWORD="your_password"
   ```

### Usage

The WebhookAdapter can be used to send notifications to any webhook endpoint:

```elixir
# Example usage with default configuration
config = %{
  webhook_url: "https://api.example.com/webhooks",
  auth: %{
    type: "bearer",
    token: System.get_env("WEBHOOK_AUTH_TOKEN")
  }
}

reminder = %{
  recipient: "webhook_endpoint",
  message: "Your reminder message",
  title: "Reminder Title",
  id: "reminder_123"
}

HydepwnsLiveview.Events.Adapters.WebhookAdapter.send_reminder(reminder, settings, config, encrypted_message)
```

### Features

- Support for multiple authentication methods:
  - Bearer token
  - Basic authentication
  - API key
  - Custom headers
- Automatic retries for failed requests
- Custom payload transformation
- Structured webhook payloads
- Comprehensive error handling
- Detailed logging
- Configurable timeouts and retry settings

### Error Handling

The adapter includes comprehensive error handling for:

- Invalid webhook URLs
- Authentication failures
- Network issues
- Server errors (with retries)
- Payload transformation errors
- Timeout errors

All errors are logged and returned in a consistent format.

### Webhook Payload Format

The default webhook payload structure:

```json
{
  "event": "reminder",
  "timestamp": "2024-03-14T12:00:00Z",
  "data": {
    "reminder_id": "reminder_123",
    "title": "Reminder Title",
    "message": "Your reminder message",
    "recipient": "webhook_endpoint",
    "encrypted_message": "encrypted_data"
  },
  "metadata": {
    "source": "hydepwns_liveview",
    "version": "1.0"
  }
}
```

### Security

- Credentials are stored in environment variables
- Support for HTTPS endpoints only
- Multiple authentication methods
- Custom header support
- Payload encryption support
- Rate limiting support (via configuration)
- Timeout protection

### Customization

The adapter supports customization through:

- Custom payload transformation
- Custom headers
- Configurable retry settings
- Custom authentication methods
- Custom error handling
- Custom logging

## Email Adapter

The EmailAdapter provides functionality for sending encrypted email notifications with support for multiple email providers and rich HTML content.

### Setup

1. Configure your email providers in `config/email_providers.exs`:

   ```elixir
   config :hydepwns_liveview, :email_providers,
     default: %{
       provider: "sendgrid",
       from_email: System.get_env("EMAIL_FROM_ADDRESS"),
       from_name: System.get_env("EMAIL_FROM_NAME"),
       api_key: System.get_env("SENDGRID_API_KEY")
     }
   ```

2. Set up your environment variables:

   ```bash
   # SendGrid configuration
   export EMAIL_FROM_ADDRESS="noreply@example.com"
   export EMAIL_FROM_NAME="Hydepwns Liveview"
   export SENDGRID_API_KEY="your_sendgrid_api_key"

   # SMTP configuration (if using SMTP)
   export SMTP_FROM_ADDRESS="noreply@example.com"
   export SMTP_FROM_NAME="Hydepwns Liveview"
   export SMTP_RELAY="smtp.example.com"
   export SMTP_PORT="587"
   export SMTP_USERNAME="your_username"
   export SMTP_PASSWORD="your_password"
   ```

### Usage

The EmailAdapter can be used to send encrypted email notifications:

```elixir
# Example usage with SendGrid
config = %{
  provider: "sendgrid",
  from_email: System.get_env("EMAIL_FROM_ADDRESS"),
  from_name: System.get_env("EMAIL_FROM_NAME"),
  api_key: System.get_env("SENDGRID_API_KEY")
}

reminder = %{
  recipient: "user@example.com",
  message: "Your reminder message",
  title: "Reminder Title",
  id: "reminder_123"
}

HydepwnsLiveview.Events.Adapters.EmailAdapter.send_reminder(reminder, settings, config, encrypted_message)
```

### Features

- Support for multiple email providers:
  - SendGrid
  - SMTP
  - Custom providers
- Rich HTML email templates
- Plain text fallback
- Attachment support
- Encrypted message handling
- Email validation
- Comprehensive error handling
- Detailed logging

### Email Content

The adapter supports:

- HTML and plain text versions
- Custom styling
- Encrypted message sections
- Attachments
- Custom templates
- Dynamic content

### Error Handling

The adapter includes comprehensive error handling for:

- Invalid email addresses
- Provider API errors
- SMTP errors
- Network issues
- Authentication failures
- Content formatting errors

All errors are logged and returned in a consistent format.

### Security

- Email address validation
- Secure credential management
- Encrypted message support
- SSL/TLS support for SMTP
- API key protection
- Custom authentication methods

### Customization

The adapter supports customization through:

- Custom email templates
- Custom styling
- Custom providers
- Custom authentication
- Custom error handling
- Custom logging

## Discord Adapter

The DiscordAdapter provides functionality for sending notifications to Discord channels with rich embeds and proper error handling.

### Setup

1. Configure your Discord providers in `config/discord_providers.exs`:

   ```elixir
   config :hydepwns_liveview, :discord_providers,
     default: %{
       bot_token: System.get_env("DISCORD_BOT_TOKEN"),
       embed_color: 0x3498db, # Blue
       thumbnail_url: System.get_env("DISCORD_THUMBNAIL_URL"),
       mention_role: System.get_env("DISCORD_MENTION_ROLE_ID")
     }
   ```

2. Set up your environment variables:

   ```bash
   # Discord configuration
   export DISCORD_BOT_TOKEN="your_bot_token"
   export DISCORD_THUMBNAIL_URL="https://example.com/thumbnail.png"
   export DISCORD_MENTION_ROLE_ID="role_id_here"
   ```

### Usage

The DiscordAdapter can be used to send notifications to Discord channels:

```elixir
# Example usage with default configuration
config = %{
  bot_token: System.get_env("DISCORD_BOT_TOKEN"),
  embed_color: 0x3498db,
  thumbnail_url: System.get_env("DISCORD_THUMBNAIL_URL")
}

reminder = %{
  recipient: "channel_id_here",
  message: "Your reminder message",
  title: "Reminder Title",
  id: "reminder_123"
}

HydepwnsLiveview.Events.Adapters.DiscordAdapter.send_reminder(reminder, settings, config, encrypted_message)
```

### Features

- Rich embed support:
  - Custom colors
  - Thumbnails
  - Fields
  - Timestamps
  - Footers
- Role mentions
- File attachments
- Rate limit handling
- Channel ID validation
- Comprehensive error handling
- Detailed logging

### Message Format

The adapter creates rich embeds with:

- Title and description
- Encrypted message in code block
- Reference ID
- Timestamp
- Custom thumbnail
- Role mentions (optional)
- File attachments (optional)

### Error Handling

The adapter includes comprehensive error handling for:

- Invalid channel IDs
- Authentication failures
- Permission errors
- Rate limits
- Network issues
- API errors

All errors are logged and returned in a consistent format.

### Security

- Bot token protection
- Channel ID validation
- Rate limit protection
- Secure API communication
- Proper error handling
- No sensitive data exposure

### Customization

The adapter supports customization through:

- Custom embed colors
- Custom thumbnails
- Custom attachments
- Role mentions
- Custom error handling
- Custom logging

## TelegramAdapter

The `TelegramAdapter` sends notifications to Telegram channels and users with rich formatting and interactive buttons.

### Setup

1. Configure Telegram providers in `config/telegram_providers.exs`:

   ```elixir
   config :hydepwns_liveview, :telegram_providers,
     default: %{
       bot_token: System.get_env("TELEGRAM_BOT_TOKEN"),
       disable_notification: false,
       inline_keyboard: [
         [
           %{
             text: "View Details",
             url: "https://example.com/reminders/{id}"
           }
         ]
       ]
     }
   ```

2. Set up environment variables:

   ```bash
   export TELEGRAM_BOT_TOKEN="your_bot_token"
   ```

### Usage

```elixir
# Send to a user
TelegramAdapter.send_reminder(
  reminder,
  %{recipient: "123456789"},
  Application.get_env(:hydepwns_liveview, :telegram_providers)[:default],
  encrypted_message
)

# Send to a channel
TelegramAdapter.send_reminder(
  reminder,
  %{recipient: "-1001234567890"},
  Application.get_env(:hydepwns_liveview, :telegram_providers)[:default],
  encrypted_message
)
```

### Features

- Rich message formatting with MarkdownV2
- Interactive inline keyboards
- Support for both users and channels
- Silent notifications option
- Rate limit handling
- Proper error handling and logging

### Message Format

Messages are formatted with MarkdownV2 and include:

- Title (bold)
- Message body
- Encrypted message in code block
- Reference ID
- Timestamp
- Optional inline keyboard buttons

### Error Handling

The adapter handles various error cases:

- Invalid chat IDs
- Authentication failures
- Rate limits
- Network errors
- API errors

### Security

- Bot tokens are stored in environment variables
- Markdown escaping to prevent injection
- Rate limit handling to prevent abuse

### Customization

You can customize:

- Message formatting
- Inline keyboard buttons
- Notification settings
- Error handling behavior
