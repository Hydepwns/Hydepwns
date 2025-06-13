import Config

# Discord Provider Configurations
config :hydepwns_liveview, :discord_providers,
  default: %{
    bot_token: System.get_env("DISCORD_BOT_TOKEN"),
    embed_color: 0x3498db, # Blue
    thumbnail_url: System.get_env("DISCORD_THUMBNAIL_URL"),
    mention_role: System.get_env("DISCORD_MENTION_ROLE_ID")
  },
  custom: %{
    bot_token: System.get_env("CUSTOM_DISCORD_BOT_TOKEN"),
    embed_color: 0xe74c3c, # Red
    thumbnail_url: System.get_env("CUSTOM_DISCORD_THUMBNAIL_URL"),
    mention_role: System.get_env("CUSTOM_DISCORD_MENTION_ROLE_ID"),
    # Custom attachments configuration
    attachments: [
      %{
        filename: "logo.png",
        description: "Company Logo",
        content_type: "image/png"
      }
    ]
  } 