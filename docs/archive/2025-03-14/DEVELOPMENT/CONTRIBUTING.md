---
title: Contributing Guide
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - development
  - contributing-guide
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - table-of-contents
  - code-of-conduct
  - getting-started
  - development-workflow
  - code-style
  - testing
  - pull-requests
  - code-review
  - documentation
  - release-process
  - questions-
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Contributing Guide

> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

# Contributing Guide


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about CONTRIBUTING.


Thank you for your interest in contributing to the Hydepwns project! This guide outlines the process for contributing to the project, including guidelines for code style, testing, and submitting changes.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Testing](#testing)
- [Pull Requests](#pull-requests)
- [Code Review](#code-review)
- [Documentation](#documentation)
- [Release Process](#release-process)

## Code of Conduct

All contributors are expected to adhere to our code of conduct, which promotes a respectful and inclusive environment. Please be sure to read and follow it.

## Getting Started

### Prerequisites

Before you begin contributing, make sure you have the following installed:

- Elixir (version specified in the project)
- Phoenix Framework
- PostgreSQL
- Node.js (for asset compilation)

### Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/hydepwns.git`
3. Set up the development environment

See [Development Setup](DEVELOPMENT_SETUP.md) for detailed instructions on setting up your development environment.

## Development Workflow

1. Create a new branch for your feature or bugfix:
   ```markdown
   git checkout -b feature/your-feature-name
   ```markdown
   or
   ```markdown
   git checkout -b fix/issue-description
   ```markdown

2. Make your changes, adding tests as appropriate

3. Ensure all tests pass:
   ```markdown
   mix test
   ```markdown

4. Commit your changes with a clear, descriptive message:
   ```markdown
   git commit -m "Add feature X" or "Fix issue with Y"
   ```markdown

5. Push your branch to your fork:
   ```markdown
   git push origin feature/your-feature-name
   ```markdown

6. Open a pull request against the main repository

## Code Style

We follow the standard Elixir style guide with a few additional conventions:

- Use 2 spaces for indentation
- Keep lines under 100 characters when possible
- Use `snake_case` for variable and function names
- Use `CamelCase` for module names
- Document all public functions with `@doc` and `@spec`

Run the formatter before committing:
```markdown
mix format
```markdown

## Testing

All new features should include appropriate tests. We aim for high test coverage and use a combination of:

- Unit tests
- Integration tests
- End-to-end tests

When fixing bugs, please add a test that reproduces the bug to ensure it doesn't happen again.

To run the test suite:
```markdown
mix test
```markdown

- See [Testing Guide](TESTING_GUIDE.md) for more details

## Pull Requests

When submitting a pull request:

1. Reference any relevant issues
2. Include screenshots for UI changes
3. Update documentation as needed
4. Ensure CI checks pass
5. Get at least one review from a maintainer

## Code Review

All code changes require review. Reviewers will check for:

- Functional correctness
- Test coverage
- Code style and quality
- Documentation quality

## Documentation

Update documentation when making changes:

- Update API documentation for changed functions
- Update guides if changing behavior
- Add examples for new features

## Release Process

Releases are managed by the core team. The process generally involves:

1. Updating the CHANGELOG.md
2. Updating version numbers
3. Creating a tagged release
4. Publishing to relevant platforms

## Questions?

If you have any questions, feel free to open an issue or reach out to the maintainers. 

## References

- [Project Documentation](../README.md)
