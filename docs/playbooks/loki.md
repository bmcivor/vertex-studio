# Loki Playbook

Deploys Loki and Promtail for log aggregation and collection from Docker containers.

## What It Does

- Deploys Loki log aggregation system
- Deploys Promtail to collect logs from all Docker containers
- Automatically discovers and tails container logs
- Exposes Loki API on port 3100

## Usage

```bash
make loki
```

## Access

Loki API is available at `http://shadowlands:3100` (not typically accessed directly).

## What Gets Collected

- **All Docker container logs**: Automatically discovers and collects logs from all running containers
- **Log streams**: Separated by container name
- **Real-time**: Logs are collected as they're written

## Connecting to Grafana

1. In Grafana (`http://shadowlands:3000`), go to **Configuration > Data Sources**
2. Click **Add data source**
3. Select **Loki**
4. Set URL to: `http://loki:3100` (or `http://shadowlands:3100` if not on same network)
5. Click **Save & Test**

## Viewing Logs in Grafana

After connecting Loki as a data source:

1. Go to **Explore** (compass icon)
2. Select **Loki** from the data source dropdown
3. Use LogQL queries to filter logs:
   - `{container="grafana"}` - Logs from Grafana container
   - `{container=~".*"}` - All container logs
   - `{container="taiga"} |= "error"` - Error logs from Taiga

## Log Retention

Logs are stored in a Docker volume. Default retention is unlimited (configured in `loki-config.yaml`).

## Removing Loki

```bash
# Stop and remove containers
ssh shadowlands "cd /opt/loki && docker compose down"

# Remove data (optional - deletes all logs)
ssh shadowlands "docker volume rm loki_loki-data"
```
