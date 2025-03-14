---
title: Docker-Setup
description: >-
  ---

  title: Docker Development Environment

  description: Guide to setting up and using the Docker-based development
  environment for the Hydepwns project

  category: development

  subcategory: tools

  order: 2

  last_updated: 2024-04-20

  contributors:
    - devops_team
    - documentation_team
  status: active

  priority: medium

  tags:
    - docker
    - development
    - environment
    - setup
  ---
topics:
  - development
  - tools
  - docker-setup
  - main-content
  - examples
  - related-documents
  - docker-development-environment
  - overview
  - files
  - prerequisites
  - getting-started
  - from-the-project-root-directory
  - running-commands
  - run-tests
  - start-an-iex-console
  - run-any-other-command
  - stopping-the-environment
  - configuration
  - troubleshooting
  - performance-tips
  - references
  - code-examples
  - testing
last_updated: '2025-03-14'
---
# Docker-Setup

---
title: Docker Development Environment
description: Guide to setting up and using the Docker-based development environment for the Hydepwns project
category: development
subcategory: tools
order: 2
last_updated: 2024-04-20
contributors:
  - devops_team
  - documentation_team
status: active
priority: medium
tags:
  - docker
  - development
  - environment
  - setup
---


## Main Content


## Examples

Examples will be added here.


## Related Documents

* No references yet

# Docker-Setup

---
title: Docker Development Environment
description: Guide to setting up and using the Docker-based development environment for the Hydepwns project
category: development
subcategory: tools
order: 2
last_updated: 2024-04-20
contributors:
  - devops_team
  - documentation_team
status: active
priority: medium
tags:
  - docker
  - development
  - environment
  - setup
---

# Docker Development Environment

This document describes the Docker-based development environment for the Hydepwns project.

## Overview

We provide Docker configurations to make it easier to set up a consistent development environment. The Docker setup includes:

- The main application container with Elixir, Phoenix, and Node.js
- PostgreSQL database for development
- PostgreSQL database for testing

## Files

All Docker-related files are located in the `docker/` directory:

- `docker-compose.yml` - Defines the multi-container Docker application
- `Dockerfile.dev` - Defines the development container image

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

### Starting the Environment

```bash
# From the project root directory
docker-compose -f docker/docker-compose.yml up -d
```markdown

This will:
1. Build the application image if it doesn't exist
2. Start the PostgreSQL database containers
3. Start the application container
4. Mount your local project directory into the container

The application will be available at [http://localhost:4000](http://localhost:4000).

## Running Commands

You can run commands inside the running container:

```bash
# Run tests
docker-compose -f docker/docker-compose.yml exec app mix test

# Start an IEx console
docker-compose -f docker/docker-compose.yml exec app iex -S mix

# Run any other command
docker-compose -f docker/docker-compose.yml exec app [command]
```markdown

## Stopping the Environment

```bash
docker-compose -f docker/docker-compose.yml down
```markdown

To remove volumes as well (this will delete all data):

```bash
docker-compose -f docker/docker-compose.yml down -v
```markdown

## Configuration

### Environment Variables

The environment variables for the application and databases are defined in the `docker-compose.yml` file.

### Customizing the Setup

If you need to customize the Docker setup:

1. Create a `docker-compose.override.yml` file in the `docker/` directory
2. Add your customizations (ports, volumes, environment variables, etc.)
3. Run docker-compose normally - it will automatically merge the override file

## Troubleshooting

### Common Issues

#### Port Conflicts

If you see an error like "port is already allocated", change the port mapping in your `docker-compose.override.yml`:

```yaml
services:
  app:
    ports:
      - "4001:4000"  # Map container port 4000 to host port 4001
```markdown

#### Database Connection Issues

If the application can't connect to the database, ensure:

1. The database containers are running: `docker-compose -f docker/docker-compose.yml ps`
2. The database connection URL in the application container matches the database service name

## Performance Tips

- Use named volumes for dependencies and build artifacts (already configured)
- On macOS and Windows, be aware of file system performance issues when sharing folders 

## References

- [Project Documentation](../README.md)
