defmodule HydepwnsLiveviewWeb.Components.Interactive.Terminal.AsciiArt do
  @moduledoc """
  ASCII art templates for use in terminal command responses.

  This module provides various ASCII art templates and helpers for displaying
  visually appealing responses to terminal commands.
  """

  @doc """
  Returns the ASCII art logo for the Hydepwns project.
  """
  def logo do
    """
       __  __           __                                 
      / / / /_  ______/ /__  ____  _      ______  _____   
     / /_/ / / / / __  / _ \\/ __ \\| | /| / / __ \\/ ___/   
    / __  / /_/ / /_/ /  __/ /_/ /| |/ |/ / / / / /__     
    /_/ /_/\\__, /\\__,_/\\___/ .___/ |__/|__/_/ /_/\\___/     
         /____/          /_/                              
    =====================================================
    """
  end

  @doc """
  Returns an ASCII art success indicator.
  """
  def success do
    """
     ╭───────────────────────────────╮
     │  ✓  Operation successful!     │
     ╰───────────────────────────────╯
    """
  end

  @doc """
  Returns an ASCII art error indicator.
  """
  def error do
    """
     ╭───────────────────────────────╮
     │  ✗  Operation failed!         │
     ╰───────────────────────────────╯
    """
  end

  @doc """
  Returns an ASCII art warning indicator.
  """
  def warning do
    """
     ╭───────────────────────────────╮
     │  ⚠  Warning!                  │
     ╰───────────────────────────────╯
    """
  end

  @doc """
  Returns a stylized header with the given text.
  """
  def header(text) do
    padding = div(80 - String.length(text), 2)
    left_padding = String.duplicate("═", padding)
    right_padding = String.duplicate("═", 80 - padding - String.length(text))

    """
    ╔════════════════════════════════════════════════════════════════════════════════╗
    ║#{left_padding}#{text}#{right_padding}║
    ╚════════════════════════════════════════════════════════════════════════════════╝
    """
  end

  @doc """
  Returns an ASCII art help screen.
  """
  def help do
    """
     ╭───────────────────────────────────────────────────────────────────╮
     │                   TERMINAL COMMAND REFERENCE                       │
     ├───────────────────────────────────────────────────────────────────┤
     │  help       - Display this help screen                            │
     │  clear      - Clear the terminal screen                           │
     │  echo       - Display a line of text                              │
     │  date       - Display the current date and time                   │
     │  theme      - Change the terminal theme                           │
     │  history    - Show command history                                │
     │  info       - Display system information                          │
     │  preferences - Customize terminal appearance                      │
     ╰───────────────────────────────────────────────────────────────────╯
    """
  end

  @doc """
  Returns an ASCII art theme preview.
  """
  def theme_preview do
    """
     ╭───────────────────────────────────────────────────────────────────╮
     │                   AVAILABLE THEME OPTIONS                          │
     ├───────────────────────────────────────────────────────────────────┤
     │  light      - Light background with dark text                     │
     │  dark       - Dark background with light text                     │
     │  dim        - Dark background with softer text colors             │
     │  synthwave  - Dark background with neon pink/blue accents         │
     │  high-contrast - High contrast for better accessibility           │
     ╰───────────────────────────────────────────────────────────────────╯
    """
  end

  @doc """
  Returns an ASCII art directory listing.
  """
  def directory_listing do
    """
     ╭───────────────────────────────────────────────────────────────────╮
     │                      SITE DIRECTORY                                │
     ├──────────────┬─────────────────────────────────────────────────────┤
     │  /           │ Home page                                          │
     │  /about      │ About page                                         │
     │  /projects   │ Projects showcase                                  │
     │  /style-guide│ Component library and documentation                │
     │  /api-docs   │ API documentation                                  │
     │  /gallery    │ ASCII art gallery                                  │
     ╰──────────────┴─────────────────────────────────────────────────────╯
    """
  end

  @doc """
  Returns an ASCII art progress bar.
  """
  def progress_bar(percent) do
    filled = round(percent / 2)
    empty = 50 - filled

    bar = String.duplicate("█", filled) <> String.duplicate("░", empty)

    """
     ╭───────────────────────────────────────────────────────────────────╮
     │  Progress: [#{bar}] #{percent}%  │
     ╰───────────────────────────────────────────────────────────────────╯
    """
  end

  @doc """
  Returns a simple ASCII art calendar.
  """
  def calendar do
    current_date = Date.utc_today()
    month = Calendar.strftime(current_date, "%B %Y")

    """
     ╭───────────────────────────────────────────────────────────────────╮
     │                        #{month}                           │
     ├───────┬───────┬───────┬───────┬───────┬───────┬───────────────────┤
     │   Su  │   Mo  │   Tu  │   We  │   Th  │   Fr  │   Sa              │
     ├───────┼───────┼───────┼───────┼───────┼───────┼───────────────────┤
     │       │       │       │       │       │       │                   │
     │       │       │       │       │       │       │                   │
     │       │       │       │       │       │       │                   │
     │       │       │       │       │       │       │                   │
     │       │       │       │       │       │       │                   │
     ╰───────┴───────┴───────┴───────┴───────┴───────┴───────────────────╯
    """
  end

  @doc """
  Returns an ASCII art system info display.
  """
  def system_info do
    """
     ╭───────────────────────────────────────────────────────────────────╮
     │                        SYSTEM INFORMATION                          │
     ├───────────────────────────┬───────────────────────────────────────┤
     │  Elixir Version           │  1.14.3                               │
     │  Phoenix Version          │  1.7.2                                │
     │  LiveView Version         │  0.19.5                               │
     │  Node.js Version          │  18.16.0                              │
     │  Database                 │  PostgreSQL 14                        │
     │  Theme                    │  Synthwave                            │
     │  Server Uptime            │  12d 14h 32m                          │
     ╰───────────────────────────┴───────────────────────────────────────╯
    """
  end

  def header_art do
    """
    / / / /_  ______/ /__  ____  _      ______  _____   
    / /_/ / / / / __  / _ \\/ __ \\| | /| / / __ \\/ ___/   
    / __  / /_/ / /_/ /  __/ /_/ /| |/ |/ / / / / /__     
    /_/ /_/\\__, /\\__,_/\\___/ .___/ |__/|__/_/ /_/\\___/     
          /____/          /_/                              
    =====================================================
    """
  end
end
