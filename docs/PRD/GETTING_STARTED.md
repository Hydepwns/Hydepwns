# Getting Started with Hydepwns

Welcome to Hydepwns! This guide will help you understand the project's purpose and get you up and running quickly.

## What Makes Hydepwns Special?

Hydepwns is more than just a personal website – it's an exploration of what the web can be when we embrace monospace typography and grid-based design. Inspired by [The Monospace Web](https://github.com/owickstrom/the-monospace-web) philosophy, this project demonstrates how precise character alignment and thoughtful design can create a distinctive digital experience.

The project also serves as a showcase for several architectural patterns in Phoenix LiveView development:

- **Resource-Oriented Architecture**: Structured approach to managing data and relationships
- **Real-time Validation**: Nested validation with dependency resolution
- **Responsive Monospace Design**: Grid precision across different device sizes
- **Theme System**: User preference-aware display modes

Whether you're interested in the design aspects, the technical implementation, or simply want to explore a different approach to web development, Hydepwns offers something unique.

## Who Is This Project For?

- **Phoenix/Elixir Developers**: Looking for architectural patterns and LiveView implementations
- **Typography Enthusiasts**: Interested in monospace design and grid-based layouts
- **Web Developers**: Exploring alternatives to mainstream web design approaches
- **Open Source Contributors**: Wanting to participate in a thoughtfully documented project

## Prerequisites

Before you begin, make sure you have the following installed:

- Elixir 1.14+ and Erlang
- PostgreSQL database server
- Node.js and npm for asset compilation
- Git

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd hydepwns
```

### 2. Install Dependencies

```bash
# Install Elixir dependencies
mix deps.get

# Install and compile assets
mix assets.setup
mix assets.build
```

### 3. Database Setup

```bash
# Create, migrate, and seed the database
mix ecto.setup
```

### 4. Start the Application

```bash
# Start the Phoenix server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) to see the application.

## Development Workflow

### Running Tests

```bash
# Run all tests
mix test

# Run specific tests
mix test test/path/to/test_file.exs
```

### Code Formatting

```bash
# Format all code
mix format
```

### Project Structure

The project follows standard Phoenix LiveView architecture:

- `lib/hydepwns_web` - Web-related code (controllers, views, templates)
- `lib/hydepwns` - Business logic and schemas
- `assets` - CSS, JavaScript, and other assets
- `priv` - Resources necessary for the application

## Docker Development (Alternative)

If you prefer using Docker for development:

```bash
# Build the Docker image
docker-compose build

# Start the services
docker-compose up

# Run commands inside the container
docker-compose exec app mix ecto.setup
```

For more detailed information, see the [Docker Setup](DEVELOPMENT/DOCKER_SETUP.md) guide.

## Next Steps

After getting your environment set up, here are some suggested paths to explore:

1. **Explore the UI**: Visit the running application to see the monospace design in action
2. **Review the Architecture**: Check out the [Architecture Overview](ARCHITECTURE/ARCHITECTURE.md)
3. **Understand the Design**: Read the [Design Principles](DESIGN/DESIGN_PRINCIPLES.md)
4. **Dive into a Feature**: The [Resource Management System](FEATURES/RESOURCE_MANAGEMENT.md) is a good place to start

## Community and Support

Hydepwns is an open source project, and we welcome contributions and questions. If you're interested in participating:

- Review the [Contributing Guide](DEVELOPMENT/CONTRIBUTING.md)
- Check the [Project Roadmap](PROJECT_MANAGEMENT/ROADMAP.md) for future plans
- Open an issue if you encounter problems or have suggestions

## Troubleshooting

If you encounter issues:

1. Make sure all prerequisites are properly installed
2. Check the database connection settings in `config/dev.exs`
3. Ensure all environment variables are set correctly
4. Consult [Known Issues](PROJECT_MANAGEMENT/KNOWN_ISSUES.md) for common problems

For help, please open an issue on the repository or reach out to the project maintainers. 