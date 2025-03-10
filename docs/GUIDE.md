# Hydepwns Developer Guide

Welcome to Hydepwns, a monospace-focused web experience built with Phoenix LiveView, following the principles of [The Monospace Web](https://github.com/owickstrom/the-monospace-web).

## Overview

Hydepwns features:

- Pixel-perfect monospace typography
- Character-based grid layout
- Three theme options: light, dark, and dim
- Real-time updates with Phoenix LiveView
- Minimal JavaScript footprint
- Seamless theme toggling with persistent user preferences

## Technology Stack

- [Elixir](https://elixir-lang.org/) - Functional programming language
- [Phoenix Framework](https://phoenixframework.org/) - Web framework for Elixir
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) - Real-time user experiences with server-rendered HTML
- [PostgreSQL](https://www.postgresql.org/) - Database backend
- [Dart Sass](https://sass-lang.com/dart-sass/) - CSS preprocessing
- [esbuild](https://esbuild.github.io/) - JavaScript bundling

## Prerequisites

- [Elixir](https://elixir-lang.org/install.html) (1.14 or later)
- [Phoenix Framework](https://phoenixframework.org/docs/installation) (1.7.20 or later)
- [PostgreSQL](https://www.postgresql.org/download/) (12 or later)
- [Node.js](https://nodejs.org/) (14 or later, for asset compilation)

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-username/hydepwns.git
   cd hydepwns
   ```

2. **Install dependencies**

   ```bash
   mix deps.get
   ```

3. **Setup the database**

   Ensure PostgreSQL is running, then:

   ```bash
   mix ecto.setup
   ```

   This will create the database, run migrations, and seed initial data.

4. **Install and compile assets**

   ```bash
   mix assets.setup
   mix assets.build
   ```

   These commands will install esbuild and dart-sass if missing, then compile the JavaScript and CSS assets.

## Running the Application

Start the Phoenix server:

```bash
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) in your browser to see the application.

## Project Structure

- `lib/hydepwns_liveview` - Core application logic
- `lib/hydepwns_liveview_web` - Web-related modules (controllers, views, templates)
- `lib/hydepwns_liveview_web/components` - Reusable UI components
- `lib/hydepwns_liveview_web/live` - LiveView modules
- `assets` - Static assets (CSS, JavaScript, images)
- `test` - Test files

### Key Components

- `theme_toggle.ex` - Component for switching between themes
- `assets/js/hooks/theme.js` - JavaScript for theme persistence and application
- `assets/css/themes.css` - Theme-specific CSS variables

## Development Workflow

### Theme System

The project uses a custom theme system with Light, Dark, and Dim modes:

- **Light**: White background with black text (default)
- **Dark**: Black background with white text
- **Dim**: Deep purple background with accents

Themes can be toggled using the theme buttons in the top-right corner of the page. The theme toggle component uses LiveView hooks for seamless theme switching without page reloads. User theme preferences are stored in local storage for persistence across sessions.

For detailed information, see [Themes Documentation](THEMES.md).

### Live Reloading

- Phoenix LiveView provides instant UI updates without page refreshes
- CSS and JavaScript changes are automatically reloaded in development
- For LiveView best practices, see [LiveView Documentation](LIVEVIEW.md)

### Testing

Run tests with:

```bash
mix test
```

### Code Quality

We follow the Elixir community style guide. To check your code:

```bash
# Format code
mix format

# Run static code analysis
mix credo
```

## Troubleshooting

### Common Issues

1. **Theme System**:
   - If theme toggling doesn't work, check that the `ThemeToggle` hook is properly initialized in app.js
   - Verify the theme toggle component has both `phx-hook` and `id` attributes
   - Check that the root HTML element has a data-theme attribute

2. **SASS compilation errors**:
   - Ensure you're using the Dart Sass math functions correctly
   - The `round()` function accepts only one argument

3. **Database connection issues**:
   - Check that PostgreSQL is running
   - Verify credentials in `config/dev.exs`

4. **Asset compilation failures**:
   - Try reinstalling asset tools with `mix assets.setup`
   - Check for JavaScript syntax errors in your browser console

## Contribution Guidelines

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

For more detailed contribution guidelines, see [Contributing Documentation](CONTRIBUTING.md).

## Deployment

For detailed deployment instructions, see [Deployment Guide](DEPLOYMENT.md).

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [The Monospace Web](https://github.com/owickstrom/the-monospace-web) - Inspiration for the project
- [Monaspace Fonts](https://github.com/githubnext/monaspace) - Beautiful monospace fonts used in this project
