# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     HydepwnsLiveview.Repo.insert!(%HydepwnsLiveview.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias HydepwnsLiveview.ThemeSystem
alias HydepwnsLiveview.ThemeSystem.Models.Theme

# Clear existing themes
HydepwnsLiveview.Repo.delete_all(Theme)

# Create default themes
light_theme = %{
  id: "light",
  name: "light",
  mode: "light",
  is_default: true,
  colors: %{
    primary: "#3b82f6",
    secondary: "#10b981",
    accent: "#f59e0b",
    background: "#ffffff",
    text: "#1f2937"
  }
}

dark_theme = %{
  id: "dark",
  name: "dark",
  mode: "dark",
  is_default: false,
  colors: %{
    primary: "#60a5fa",
    secondary: "#34d399",
    accent: "#fbbf24",
    background: "#111827",
    text: "#f9fafb"
  }
}

system_theme = %{
  id: "system",
  name: "system",
  mode: "system",
  is_default: false,
  colors: %{
    primary: "#8b5cf6",
    secondary: "#ec4899",
    accent: "#f43f5e",
    background: "system",
    text: "system"
  }
}

# Insert themes
{:ok, _} = ThemeSystem.create_theme(light_theme)
{:ok, _} = ThemeSystem.create_theme(dark_theme)
{:ok, _} = ThemeSystem.create_theme(system_theme)

IO.puts("Database seeded with default themes!")
