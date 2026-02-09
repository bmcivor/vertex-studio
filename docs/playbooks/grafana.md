# Grafana Playbook

Deploys self-hosted Grafana monitoring dashboard to the lab server.

## What It Does

- Deploys Grafana container on lab server
- Exposes web UI on port 3000
- No cloud account required - fully self-hosted
- Persistent data storage via Docker volumes

## Usage

```bash
make grafana
```

## Access

After deployment, access Grafana at:

- Local network: `http://shadowlands:3000`
- Tailscale: `http://<tailscale-ip>:3000`

## Default Login

- Username: `admin`
- Password: `admin`

**Important**: Change the password on first login.

## Next Steps

Grafana will be empty until you add a data source. To monitor Docker containers and host metrics, you'll need to:

1. **Add a metrics collector** (Prometheus + cAdvisor recommended)
2. **Configure Grafana data source** to point to your metrics collector
3. **Import or create dashboards** to visualize metrics

## Data Persistence

Grafana data (dashboards, data sources, users) is stored in Docker volumes:
- `grafana-data` - Grafana database and dashboards
- `grafana-config` - Configuration files

Data persists across container restarts.

## Removing Grafana

```bash
# Stop and remove container
ssh shadowlands "cd /opt/grafana && docker compose down"

# Remove data (optional - this deletes all dashboards/config)
ssh shadowlands "docker volume rm grafana-data grafana-config"
```
