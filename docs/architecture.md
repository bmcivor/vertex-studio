# Architecture

## Overview

Vertex Studio is a self-hosted development platform designed to provide a complete software development lifecycle infrastructure at home.

## Components

### Platform Layer

- **Ansible**: Infrastructure as code for reproducible deployments
- **Docker**: Container runtime for all services
- **Traefik** (planned): Reverse proxy with automatic TLS

### Development Layer

- **GitHub**: Source of truth for code (existing remotes)
- **Jenkins**: CI server on the lab box; webhooks from GitHub trigger builds. See [Local pipeline design](design/local-pipeline.md).
- **Taiga**: Project management and issue tracking
- **Ollama**: Local LLM (e.g. LLaVA) using 3090 GPU
- **Stable Diffusion**: AUTOMATIC1111 WebUI with GPU for image generation
- **Minecraft Bedrock**: Private Bedrock server (world on lab)
- **Tailscale**: VPN for remote access to the lab

### Monitoring Layer

- **Grafana**: Metrics and log visualization dashboard
- **Prometheus**: Metrics collection and storage
- **cAdvisor**: Docker container metrics collection
- **Loki**: Log aggregation system
- **Promtail**: Log collection agent

## Network Architecture

```
Internet
  │
  └─> Router/Firewall
        │
        └─> Lab Server (Fedora Server)
              │
              ├─> Taiga (port 9000)
              ├─> MkDocs (port 8080)
              ├─> Grafana (port 3000)
              ├─> Prometheus (port 9091)
              ├─> cAdvisor (port 8082)
              ├─> Loki (port 3100)
              ├─> Jenkins (port 8083)
              ├─> Ollama (port 11434)
              ├─> Stable Diffusion WebUI (port 7860)
              ├─> Stable Diffusion gallery (port 8081)
              └─> Minecraft Bedrock (port 19132/udp)
```

## Design Decisions

### Docker Compose First

**Decision**: Start with Docker Compose, design for k3s migration later.

**Rationale**: 
- Faster initial implementation
- Lower operational complexity
- Easier to learn and debug
- Migration path documented for future

### Single Node Initially

**Decision**: Deploy on single lab machine initially.

**Rationale**:
- Simplifies initial setup
- Hardware with 3090 can handle workload
- Multi-node can be added later if needed

### Internal Access Only

**Decision**: No external internet exposure initially.

**Rationale**:
- Simpler security model
- Focus on functionality first
- External access via VPN can be added later
