# Prometheus Playbook

Deploys Prometheus and cAdvisor to collect Docker container and host metrics.

## What It Does

- Deploys Prometheus metrics database
- Deploys cAdvisor to collect Docker container metrics
- Configures Prometheus to scrape cAdvisor automatically
- Exposes Prometheus UI on port 9090
- Exposes cAdvisor UI on port 8082

## Usage

```bash
make prometheus
```

## Access

After deployment:

- **Prometheus UI**: `http://shadowlands:9091`
- **cAdvisor UI**: `http://shadowlands:8082`

## What Gets Collected

- **Docker Container Metrics**: CPU, memory, network I/O, disk I/O per container
- **Container Stats**: Restarts, uptime, resource limits
- **Host Metrics**: Basic system metrics from cAdvisor

## Connecting to Grafana

1. In Grafana (`http://shadowlands:3000`), go to **Configuration > Data Sources**
2. Click **Add data source**
3. Select **Prometheus**
4. Set URL to: `http://prometheus:9090` (or `http://shadowlands:9091` if not on same network)
5. Click **Save & Test**

## Prometheus Query Examples

In Prometheus UI (`http://shadowlands:9091`), try these queries:

```
# Container CPU usage
container_cpu_usage_seconds_total

# Container memory usage
container_memory_usage_bytes

# All containers
container_spec_memory_limit_bytes
```

## Data Retention

Prometheus stores metrics in a Docker volume. Default retention is 15 days. Data persists across container restarts.

## Removing Prometheus

```bash
# Stop and remove containers
ssh shadowlands "cd /opt/prometheus && docker compose down"

# Remove data (optional - deletes all metrics)
ssh shadowlands "docker volume rm prometheus-data"
```
