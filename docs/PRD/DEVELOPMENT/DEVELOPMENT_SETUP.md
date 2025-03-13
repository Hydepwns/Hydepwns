# Development Environment Setup

This guide provides instructions for setting up your development environment for the Hydepwns project. Follow these steps to get started quickly.

## Prerequisites

Before setting up the project, ensure you have the following installed:

- **Elixir** (version 1.14.3 or higher)
- **Erlang/OTP** (version 25.3 or higher)
- **PostgreSQL** (version 13 or higher)
- **Node.js** (version 16 or higher)
- **npm** (version 8 or higher)
- **Git**

### Installing Prerequisites

#### macOS (using Homebrew)

```bash
# Install Homebrew if you don't already have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Elixir and Erlang
brew install elixir

# Install PostgreSQL
brew install postgresql
brew services start postgresql

# Install Node.js and npm
brew install node
```

#### Ubuntu/Debian

```bash
# Add Erlang Solutions repository
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update

# Install Elixir and Erlang
sudo apt-get install esl-erlang elixir

# Install PostgreSQL
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install nodejs
```

#### Windows

We recommend using WSL2 (Windows Subsystem for Linux) with Ubuntu and following the Ubuntu/Debian instructions above. Alternatively:

1. Install Elixir and Erlang using the Windows installers from [Erlang Solutions](https://www.erlang-solutions.com/resources/download.html)
2. Install PostgreSQL using the installer from [postgresql.org](https://www.postgresql.org/download/windows/)
3. Install Node.js and npm using the installer from [nodejs.org](https://nodejs.org/)

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/hydepwns.git
cd hydepwns
```

### 2. Install Elixir Dependencies

```bash
# Install hex package manager and Phoenix
mix local.hex --force
mix local.rebar --force
mix archive.install hex phx_new 1.7.0 --force

# Install project dependencies
mix deps.get
```

### 3. Database Setup

```bash
# Create the database user (if needed)
# For PostgreSQL, you may need to create a user with appropriate permissions
# On Ubuntu/Debian, you can run:
sudo -u postgres psql -c "CREATE USER hydepwns WITH PASSWORD 'hydepwns' CREATEDB;"

# Configure the database connection
# Edit config/dev.exs to match your database credentials if different

# Create and migrate the database
mix ecto.create
mix ecto.migrate

# Seed the database with initial data (if available)
mix run priv/repo/seeds.exs
```

### 4. Assets Setup

```bash
# Install Node.js dependencies
cd assets
npm install
cd ..

# Compile assets
mix assets.deploy
```

### 5. Start the Development Server

```bash
# Start the Phoenix server
mix phx.server

# Alternatively, start with an interactive Elixir console
iex -S mix phx.server
```

The application should now be running at [http://localhost:4000](http://localhost:4000).

## Development Workflow

### Running Tests

```bash
# Run all tests
mix test

# Run specific tests
mix test test/path/to/test_file.exs

# Run tests with coverage
mix test --cover
```

### Code Quality Tools

```bash
# Run formatter
mix format

# Run Credo for static code analysis
mix credo --strict

# Run Dialyzer for type checking (if configured)
mix dialyzer
```

### Database Management

```bash
# Reset database (drop, create, and migrate)
mix ecto.reset

# Generate a new migration
mix ecto.gen.migration migration_name
```

### Asset Management

```bash
# Watch and compile assets automatically
mix assets.deploy --watch
```

## Docker Development Environment (Optional)

We also provide a Docker Compose setup for easier development.

### Prerequisites

- Docker
- Docker Compose

### Setup

```bash
# Build and start containers
docker-compose -f docker/docker-compose.yml up -d

# Run commands inside the container
docker-compose -f docker/docker-compose.yml exec app mix test
```

For detailed instructions on using the Docker development environment, see [DOCKER_SETUP.md](DOCKER_SETUP.md).

## Troubleshooting

### Common Issues

#### Database Connection Problems

If you encounter issues connecting to the database, ensure:

1. PostgreSQL is running
2. The database user exists with the correct permissions
3. The connection settings in `config/dev.exs` match your PostgreSQL configuration

#### Assets Not Compiling

If you have issues with assets:

1. Make sure Node.js and npm are installed and up to date
2. Try removing `node_modules` and reinstalling: `rm -rf assets/node_modules && cd assets && npm install`
3. Ensure all asset dependencies are installed

#### Port Already in Use

If port 4000 is already in use, you can change the port in `config/dev.exs`:

```elixir
config :hydepwns_liveview, HydepwnsLiveviewWeb.Endpoint,
  http: [port: 4001],  # Change to any available port
  # ... other settings
```

## Getting Help

If you encounter issues not covered here, please:

1. Check existing GitHub issues
2. Create a new issue with detailed steps to reproduce the problem
3. Reach out to the team on our communication channels

## Development Best Practices

1. **Branch Strategy**: Create feature branches from `main` and submit pull requests
2. **Tests**: Write tests for all new features and bug fixes
3. **Documentation**: Update documentation for any changes to APIs or functionality
4. **Code Style**: Follow the Elixir style guide and ensure code passes all quality checks
5. **Commits**: Write clear, concise commit messages that explain the "why" not just the "what" 