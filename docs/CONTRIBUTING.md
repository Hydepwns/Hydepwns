# Contributing to Hydepwns

Thank you for your interest in contributing to Hydepwns! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct (see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)).

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report:

1. Check the [existing issues](https://github.com/yourusername/hydepwns/issues) to see if the problem has already been reported
2. If you're unable to find an open issue addressing the problem, create a new one

When creating a bug report, please include as much detail as possible:

- A clear and descriptive title
- Steps to reproduce the behavior
- Expected behavior
- Actual behavior
- Screenshots if applicable
- Environment details (OS, browser, version, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues:

1. Check if the enhancement has already been suggested
2. Create a new issue with a clear title and detailed description
3. Explain why this enhancement would be useful to most users

### Pull Requests

1. Fork the repository
2. Create a new branch for your feature or bugfix
3. Make your changes
4. Add or update tests as needed
5. Update documentation if necessary
6. Submit a pull request

## Development Process

### Setting Up Your Development Environment

See [docs/DEVELOPMENT_SETUP.md](docs/DEVELOPMENT_SETUP.md) for detailed instructions on setting up your development environment.

> **Note:** For Docker-based development, the Docker configuration files are located in the `docker/` directory.

### Pull Request Process

1. Ensure your code follows the project's style guide
2. Update documentation as necessary
3. Add tests for any new features
4. Ensure the test suite passes
5. Make sure your code lints without errors
6. Submit your pull request

### Branching Strategy

- `main` branch is always deployable
- Create feature branches from `main` using the naming convention `feature/your-feature-name`
- Create bugfix branches using the naming convention `fix/issue-description`

### Commit Messages

Follow these best practices for commit messages:

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests after the first line
- Consider starting the commit message with an applicable emoji:
  - ✨ `:sparkles:` for new features
  - 🐛 `:bug:` for bug fixes
  - 📚 `:books:` for documentation changes
  - ♻️ `:recycle:` for refactoring code
  - 🧪 `:test_tube:` for adding tests
  - 🎨 `:art:` for improving structure/format of the code

## Style Guides

### Elixir Style Guide

We follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide). Additionally:

- Use the `mix format` tool to format your code
- Run `mix credo --strict` to enforce style guidelines
- Add proper documentation to modules and functions

### JavaScript Style Guide

- Use modern ES6+ features when possible
- Follow the [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- Use camelCase for variables and functions

### CSS/SCSS Style Guide

- Use BEM (Block Element Modifier) methodology for naming CSS classes
- Use variables for colors, spacing, and other repeated values
- Follow a mobile-first approach for responsive design

### Testing Guidelines

- Write tests for all new features and bug fixes
- Ensure all tests pass before submitting a pull request
- Strive for good test coverage, especially for critical functionality
- See [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md) for more details

## Documentation

- Update the README.md with any changes to interface, architecture, or setup
- Update the documentation when changing functionality
- Use clear, concise language and provide examples when possible

## Getting Help

If you need help with your contribution, you can:

- Ask questions in GitHub issues
- Contact the maintainers via email
- Join our community chat (if available)

Thank you for contributing to Hydepwns! 