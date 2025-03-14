---
title: Deployment Guide
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.

  > The current version of this document is now at
  [reference/deployment/overview.md](../../reference/deployment/overview.md) <!-- TODO: Fix broken link -->
  <!-- TODO: Fix broken link -->.
topics:
  - prd
  - deployment
  - deployment-guide
  - main-content
  - examples
  - related-documents
  - overview
  - prerequisites
  - hydepwns-project
  - install-dependencies
  - setup-database
  - install-and-compile-assets
  - start-phoenix-server
  - environment-variables
  - required-variables
  - optional-variables
  - general-deployment-steps
  - deployment-options
  - ssl-configuration
  - post-deployment-verification
  - troubleshooting
  - references
  - code-examples
  - testing
  - development
last_updated: '2025-03-14'
---
# Deployment Guide

> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.
> The current version of this document is now at [reference/deployment/overview.md](../../reference/deployment/overview.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->.


## Main Content


## Examples

Examples will be added here.


## Related Documents

* No references yet

# Deployment Guide


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.
> The current version of this document is now at [reference/deployment/overview.md](../../reference/deployment/overview.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link -->.


## Overview

This document provides information about DEPLOYMENT.


This guide outlines the steps needed to deploy the Hydepwns application to various environments.

## Prerequisites

- Elixir 1.14+ and Erlang installed on the deployment server
- PostgreSQL database server
- Git access to the repository
- DNS configuration for your domain (if applicable)

## Hydepwns Project

This repository contains a Phoenix LiveView application that implements a personal website with a focus on monospace typography and clean grid-based layouts.

### Key Features

- **Monospace Typography**: Pixel-perfect character grid alignment
- **Theme System**: Light, Dark, and Dim modes with persistent preferences
- **Phoenix LiveView**: Real-time user experiences without JavaScript
- **Responsive Design**: Mobile-friendly layouts that maintain grid precision

### Documentation

Comprehensive documentation is available in the `docs/PRD/` directory:

- [Getting Started Guide](../GETTING_STARTED.md) - Setup, installation, and development workflow
- [Architecture Overview](../ARCHITECTURE/ARCHITECTURE.md) - System design and requirements
- [Design Principles](../DESIGN/DESIGN_PRINCIPLES.md) - Core design principles and monospace design
- [LiveView Integration](../FEATURES/LIVEVIEW.md) - Using Phoenix LiveView
- [Theme System](../FEATURES/guides/design/themes.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> - Theme implementation details
- [Contributing Guide](../DEVELOPMENT/CONTRIBUTING.md) - How to contribute (including testing)

### Quick Start

```bash
# Install dependencies
mix deps.get

# Setup database
mix ecto.setup

# Install and compile assets
mix assets.setup
mix assets.build

# Start Phoenix server
mix phx.server
```markdown

Visit [`localhost:4000`](http://localhost:4000) to see the application.

See [Getting Started Guide](../GETTING_STARTED.md) for detailed instructions.

## Environment Variables

Configure the following environment variables for your deployment:

```bash
# Required variables
DATABASE_URL=postgresql://username:password@localhost/hydepwns_prod
SECRET_KEY_BASE=your-secret-key-base
PHX_HOST=your-domain.com
PORT=4000

# Optional variables
POOL_SIZE=10
PHX_SERVER=true
```markdown

## General Deployment Steps

Regardless of the deployment platform, these steps are required:

1. **Generate a production-ready release**:

   ```bash
   # Generate secret key base
   mix phx.gen.secret
   
   # Compile assets
   MIX_ENV=prod mix assets.deploy
   
   # Build the release
   MIX_ENV=prod mix release
   ```markdown

2. **Database setup**:

   ```bash
   MIX_ENV=prod mix ecto.setup
   ```markdown

## Deployment Options

### Option 1: Traditional Server Deployment

1. **Copy the release to your server**:

   ```bash
   scp -r _build/prod/rel/hydepwns_liveview user@your-server:/app
   ```markdown

2. **Run the release**:

   ```bash
   # On your server
   cd /app
   bin/hydepwns_liveview start
   ```markdown

3. **Set up a process manager** (systemd example):

   Create a service file at `/etc/systemd/system/hydepwns.service`:

   ```bash
   [Unit]
   Description=Hydepwns Phoenix Application
   After=network.target postgresql.service

   [Service]
   Type=simple
   User=appuser
   WorkingDirectory=/app
   ExecStart=/app/bin/hydepwns_liveview start
   Restart=on-failure
   RestartSec=5
   Environment=PORT=4000
   Environment=PHX_HOST=your-domain.com
   Environment=DATABASE_URL=postgresql://username:password@localhost/hydepwns_prod
   Environment=SECRET_KEY_BASE=your-secret-key-base
   Environment=PHX_SERVER=true

   [Install]
   WantedBy=multi-user.target
   ```markdown

   Then enable and start the service:

   ```bash
   sudo systemctl enable hydepwns
   sudo systemctl start hydepwns
   ```markdown

4. **Set up a reverse proxy** with Nginx:

   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:4000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection "upgrade";
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```markdown

### Option 2: Docker Deployment

1. **Create a Dockerfile**:

   ```dockerfile
   FROM elixir:1.14-alpine AS build

   # Install build dependencies
   RUN apk add --update git build-base nodejs npm

   # Prepare build directory
   WORKDIR /app

   # Install hex + rebar
   RUN mix local.hex --force && \
       mix local.rebar --force

   # Set build ENV
   ENV MIX_ENV=prod

   # Install dependencies
   COPY mix.exs mix.lock ./
   COPY config config
   RUN mix deps.get --only prod
   RUN mix deps.compile

   # Build assets
   COPY assets assets
   COPY priv priv
   RUN mix assets.deploy

   # Build project
   COPY lib lib
   RUN mix compile

   # Build release
   RUN mix release

   # Prepare release image
   FROM alpine:3.16 AS app
   RUN apk add --update bash openssl

   WORKDIR /app

   RUN chown nobody:nobody /app

   USER nobody:nobody

   COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/hydepwns_liveview ./

   ENV HOME=/app
   ENV PHX_SERVER=true

   CMD ["bin/hydepwns_liveview", "start"]
   ```markdown

2. **Build and run the Docker image**:

   ```bash
   docker build -t hydepwns:latest .
   docker run -p 4000:4000 \
     -e DATABASE_URL=postgresql://username:password@host.docker.internal/hydepwns_prod \
     -e SECRET_KEY_BASE=your-secret-key-base \
     -e PHX_HOST=your-domain.com \
     hydepwns:latest
   ```markdown

### Option 3: Fly.io Deployment

1. **Install the Fly CLI**:

   ```bash
   curl -L https://fly.io/install.sh | sh
   ```markdown

2. **Create a fly.toml file**:

   ```toml
   app = "hydepwns"
   primary_region = "sea"
   kill_signal = "SIGTERM"

   [env]
     PHX_HOST = "your-app-name.fly.dev"
     PORT = "8080"

   [http_service]
     internal_port = 8080
     force_https = true
     auto_stop_machines = true
     auto_start_machines = true
     min_machines_running = 0
     processes = ["app"]
     [http_service.concurrency]
       type = "connections"
       hard_limit = 1000
       soft_limit = 500

   [[vm]]
     cpu_kind = "shared"
     cpus = 1
     memory_mb = 1024
   ```markdown

3. **Deploy to Fly.io**:

   ```bash
   fly auth login
   fly launch
   
   # For the database
   fly postgres create
   fly postgres attach --app hydepwns your-postgres-app-name
   
   # Set secret key
   fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)
   
   # Deploy
   fly deploy
   ```markdown

## SSL Configuration

For production deployments, always use HTTPS. If deploying with Nginx:

1. **Install Certbot**:

   ```bash
   sudo apt install certbot python3-certbot-nginx
   ```markdown

2. **Generate SSL certificates**:

   ```bash
   sudo certbot --nginx -d your-domain.com
   ```markdown

3. **Auto-renewal**:

   ```bash
   sudo certbot renew --dry-run
   ```markdown

## Post-Deployment Verification

After deploying, verify that:

1. The application is running and accessible
2. SSL is properly configured
3. All application features work as expected
4. The theme system switches between themes properly
5. Error monitoring is in place

## Troubleshooting

Common deployment issues:

1. **Database connection errors**:
   - Verify the DATABASE_URL environment variable
   - Check that the database server is accessible from the application server
   - Ensure database credentials are correct
   - See [Known Issues](../PROJECT_MANAGEMENT/KNOWN_ISSUES.md) for common database problems

2. **Asset loading issues**:
   - Confirm that assets were properly compiled with `mix assets.deploy`
   - Check browser console for 404 errors on CSS/JS files

3. **SSL certificate problems**:
   - Renew certificates if expired
   - Ensure proper SSL configuration in web server

4. **Application crashes**:
   - Check application logs with `journalctl -u hydepwns` (for systemd)
   - Verify all required environment variables are set
   - Consult the [Architecture Overview](../ARCHITECTURE/ARCHITECTURE.md) for system requirements


## References

- [Project Documentation](../README.md)
