---
title: Contributing to Hydepwns
description: A guide for new contributors to get started with the project
topics:
  - contributing
  - development
  - getting-started
  - guidelines
  - workflow
last_updated: '2025-03-14'
---

# Contributing to Hydepwns

## Overview

Welcome to the Hydepwns contributing guide! We're excited that you're interested in contributing to the project. This guide will help you understand our development process and how you can get involved.

## Prerequisites

Before you start contributing, make sure you have:

1. Read our [Code of Conduct](./code-of-conduct.md)
2. Installed all [development dependencies](../setup/development-environment.md)
3. Familiarized yourself with our [architecture](../../reference/architecture/overview.md)

## Getting Started

### 1. Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/hydepwns.git
   cd hydepwns
   ```
3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/original/hydepwns.git
   ```

### 2. Set Up Development Environment

1. Install dependencies:
   ```bash
   mix deps.get
   mix assets.setup
   ```

2. Set up the database:
   ```bash
   mix ecto.setup
   ```

3. Start the development server:
   ```bash
   mix phx.server
   ```

## Development Workflow

### 1. Choose an Issue

1. Browse open issues on GitHub
2. Comment on an issue you'd like to work on
3. Wait for assignment or approval from maintainers

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 3. Make Changes

1. Write your code
2. Add tests for new functionality
3. Update documentation as needed
4. Follow our [coding standards](../guidelines/coding-standards.md)

### 4. Test Your Changes

```bash
# Run the test suite
mix test

# Run the linter
mix credo

# Format code
mix format
```

### 5. Commit Your Changes

```bash
git add .
git commit -m "feat: add new feature"
# or
git commit -m "fix: resolve issue with X"
```

Follow our [commit message conventions](../guidelines/commit-messages.md).

### 6. Keep Your Branch Updated

```bash
git fetch upstream
git rebase upstream/main
```

### 7. Submit a Pull Request

1. Push your changes to your fork
2. Create a pull request on GitHub
3. Fill out the pull request template
4. Wait for review

## Code Review Process

1. Maintainers will review your code
2. Address any feedback or requested changes
3. Once approved, your code will be merged

## Testing Guidelines

### Writing Tests

- Write tests for all new features
- Maintain or improve code coverage
- Follow our [testing guidelines](../guidelines/testing.md)

### Running Tests

```bash
# Run all tests
mix test

# Run specific test file
mix test test/path/to/file_test.exs

# Run tests with coverage
mix test --cover
```

## Documentation

### Updating Documentation

1. Update relevant documentation files
2. Follow our [documentation style guide](../guidelines/documentation-style.md)
3. Test documentation changes locally

### Building Documentation

```bash
# Generate documentation
mix docs
```

## Best Practices

### Code Quality

- Follow our coding standards
- Write clear, maintainable code
- Include comments where necessary
- Keep functions focused and small

### Pull Requests

- Keep changes focused and atomic
- Include tests and documentation
- Update the changelog if required
- Reference related issues

## Getting Help

- Join our community chat
- Ask questions in GitHub discussions
- Tag maintainers for urgent issues

## Additional Resources

- [Development Environment Setup](../setup/development-environment.md)
- [Architecture Overview](../../reference/architecture/overview.md)
- [Testing Guidelines](../guidelines/testing.md)
- [Documentation Style Guide](../guidelines/documentation-style.md)

## Recognition

Contributors are recognized in:

- Project changelog
- Contributors list
- Release notes

Thank you for contributing to Hydepwns! 