# Services

All services are hosted on `shadowlands` and accessible via Tailscale VPN using the MagicDNS hostname.

## Web Services

| Service | URL | Description |
|---------|-----|-------------|
| Jenkins | `https://shadowlands.tail252efc.ts.net` | CI/CD server |
| Grafana | `http://shadowlands.tail252efc.ts.net:3000` | Monitoring dashboards |
| Prometheus | `http://shadowlands.tail252efc.ts.net:9091` | Metrics collection |
| cAdvisor | `http://shadowlands.tail252efc.ts.net:8082` | Container metrics |
| Registry UI | `http://shadowlands.tail252efc.ts.net:8084` | Docker registry browser |
| MkDocs | `http://shadowlands.tail252efc.ts.net:8080` | This documentation site |
| SD Gallery | `http://shadowlands.tail252efc.ts.net:8081` | Stable Diffusion image gallery |

## APIs / Internal

| Service | URL | Description |
|---------|-----|-------------|
| Docker Registry | `http://shadowlands.tail252efc.ts.net:5000` | Container image registry (v2 API) |
| Loki | `http://shadowlands.tail252efc.ts.net:3100` | Log aggregation |

## Other

| Service | Address | Description |
|---------|---------|-------------|
| Minecraft Bedrock | `shadowlands.tail252efc.ts.net:19132` (UDP) | Bedrock game server |

## Access

All URLs require [Tailscale](https://tailscale.com/) to be running on your device and connected to the same Tailnet.
