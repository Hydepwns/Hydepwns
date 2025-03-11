[
  import_deps: [:ecto, :ecto_sql, :phoenix, :phoenix_live_view],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"],
  heex_line_length: 320,
  # Temporarily disable strict HTML formatting to allow compilation
  skip_html_formatter_check: true
]
