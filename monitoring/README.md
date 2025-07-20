# Monitoring Configuration

This directory contains all monitoring-related configuration files for the HydepwnsLiveview application.

## Contents

- `prometheus.yml` - Prometheus configuration for scraping metrics
- `start_monitoring.sh` - Script to start the monitoring stack
- `grafana/` - Grafana provisioning configuration and dashboards

## Quick Start

From the project root:

```bash
# Start monitoring stack
./monitoring/start_monitoring.sh

# Stop monitoring stack
docker-compose -f docker/docker-compose.monitoring.yml down
```

## Documentation

For detailed setup and usage instructions, see [docs/MONITORING_SETUP.md](../docs/MONITORING_SETUP.md).

## Access Points

- **Prometheus**: <http://localhost:9090>
- **Grafana**: <http://localhost:3000> (admin/admin)
- **Application Metrics**: <http://localhost:9568/metrics>
