# Hydepwns - A Monospace Web Experience

Welcome to Hydepwns, a monospace-focused web experience built with Phoenix LiveView, following the principles of [The Monospace Web](https://github.com/owickstrom/the-monospace-web).

## Features

- Pixel-perfect monospace typography
- Character-based grid layout
- Three theme options: light, dark, and dim
- Real-time updates with Phoenix LiveView
- Minimal JavaScript footprint

## Technology Stack

- [Elixir](https://elixir-lang.org/) - Functional programming language
- [Phoenix Framework](https://phoenixframework.org/) - Web framework for Elixir
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) - Real-time user experiences with server-rendered HTML
- [PostgreSQL](https://www.postgresql.org/) - Database backend

## Prerequisites

- Elixir 1.18 or higher
- Erlang/OTP 26 or higher
- PostgreSQL 14 or higher
- Node.js 18 or higher (for asset compilation)

## Getting Started

To start your Phoenix server:

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/hydepwns.git
   cd hydepwns
   ```

2. Install dependencies
   ```bash
   mix deps.get
   ```

3. Create and migrate your database
   ```bash
   mix ecto.setup
   ```

4. Start Phoenix server
   ```bash
   mix phx.server
   ```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Development

### Running Tests

```bash
mix test
```

### Code Style

We follow the Elixir community style guide. To check your code:

```bash
mix format
mix credo
```

## Theme System

The application supports three themes:
- **Light**: White background with black text (default)
- **Dark**: Black background with white text
- **Dim**: Deep purple background with accents

Themes can be toggled using the theme buttons in the top-right corner of the page.

## Project Structure

- `lib/hydepwns_liveview` - Core application logic
- `lib/hydepwns_liveview_web` - Web-related modules (controllers, views, templates)
- `lib/hydepwns_liveview_web/components` - Reusable UI components
- `lib/hydepwns_liveview_web/live` - LiveView modules
- `assets` - Static assets (CSS, JavaScript, images)
- `test` - Test files

## Contribution Guidelines

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [The Monospace Web](https://github.com/owickstrom/the-monospace-web) - Inspiration for the project
- [Monaspace Fonts](https://github.com/githubnext/monaspace) - Beautiful monospace fonts used in this project 