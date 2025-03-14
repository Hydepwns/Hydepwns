---
title: Hydepwns Quickstart Guide
description: '## Overview'
topics:
  - guides
  - getting-started
  - hydepwns-quickstart-guide
  - overview
  - main-content
  - examples
  - related-documents
  - technology-stack
  - prerequisites
  - quick-installation
  - running-the-application
  - key-features
  - troubleshooting
  - next-steps
  - references
  - code-examples
  - architecture
  - development
last_updated: '2025-03-14'
---
# Hydepwns Quickstart Guide

## Overview


## Main Content


## Examples

Examples will be added here.


## Related Documents

* No references yet

This document provides information about Quickstart.


This quickstart guide will help you set up and run Hydepwns quickly, a monospace-focused web experience built with Phoenix LiveView.

## Technology Stack

- [Elixir](https://elixir-lang.org/) - Functional programming language
- [Phoenix Framework](https://phoenixframework.org/) - Web framework for Elixir
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) - Real-time user experiences with server-rendered HTML
- [PostgreSQL](https://www.postgresql.org/) - Database backend
- [Dart Sass](https://sass-lang.com/dart-sass/) - CSS preprocessing
- [esbuild](https://esbuild.github.io/) - JavaScript bundling

## Prerequisites

Before you begin, ensure you have installed:

- [Elixir](https://elixir-lang.org/install.html) (1.14 or later)
- [Phoenix Framework](https://phoenixframework.org/docs/installation) (1.7.20 or later)
- [PostgreSQL](https://www.postgresql.org/download/) (12 or later)
- [Node.js](https://nodejs.org/) (14 or later, for asset compilation)

## Quick Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-username/hydepwns.git
   cd hydepwns
   ```markdown

2. **Install dependencies**

   ```bash
   mix deps.get
   ```markdown

3. **Setup the database**

   Ensure PostgreSQL is running, then:

   ```bash
   mix ecto.setup
   ```markdown

   This will create the database, run migrations, and seed initial data.

4. **Install and compile assets**

   ```bash
   mix assets.setup
   mix assets.build
   ```markdown

   These commands will install esbuild and dart-sass if missing, then compile the JavaScript and CSS assets.

## Running the Application

Start the Phoenix server:

```bash
mix phx.server
```markdown

Now you can visit [`localhost:4000`](http://localhost:4000) in your browser to see the application.

## Key Features

- **Monospace Typography**: Pixel-perfect character grid alignment
- **Theme System**: Light, Dark, and Dim modes with persistent user preferences
- **Phoenix LiveView**: Real-time updates without page reloads
- **Minimal JavaScript**: Server-driven UI with focused client-side enhancements

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

## Next Steps

After setting up the application, you may want to:

1. Explore the [full installation guide](installation.md) for more detailed setup options
2. Review the [project overview](overview.md) to understand the project's goals and features
3. Check out the [contributing guide](../../development/contributing/getting-started.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> if you'd like to participate
4. Learn about the [architecture](../../reference/architecture/overview.md) of the application 

## References

- [Project Documentation](../README.md)
