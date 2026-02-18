# Vertex Studio

A self-hosted development platform built with Ansible, featuring:

- **Project Management**: Taiga for issue tracking and agile workflows
- **CI/CD**: Jenkins on the lab box; webhooks from GitHub trigger builds
- **LLM Integration**: Ollama for local LLM (e.g. LLaVA) using 3090 GPU
- **Documentation**: MkDocs served via nginx
- **Monitoring**: Grafana, Prometheus, Loki, and cAdvisor for metrics and logs
- **Stable Diffusion**: AUTOMATIC1111 WebUI with GPU (SDXL); optional gallery for outputs
- **Minecraft Bedrock**: Private Bedrock server (world on lab; deploy/destroy via playbook)
- **Remote Access**: Tailscale VPN for reaching the lab from elsewhere
- **Container Orchestration**: Docker Compose (with k3s migration path)

## Quick Start

### Prerequisites

- Dev machine with Docker and Docker Compose
- Lab machine with Fedora Server installed
- SSH key-based authentication configured

### Deploy Platform

```bash
# Build Ansible container
make build

# Test connection
make ping

# Deploy full platform (bootstrap + all apps)
make lab
```

Or deploy step-by-step: `make bootstrap`, then individual targets (`make taiga`, `make mkdocs`, `make minecraft-bedrock`, etc.). See [Lab Playbook](playbooks/lab.md) for the full list.

## Architecture

See [Architecture](architecture.md) for detailed system design.

## Access Points

After deployment, services will be accessible at:

- Taiga: `http://<lab-ip>:9000`
- MkDocs: `http://<lab-ip>:8080`
- Grafana: `http://<lab-ip>:3000`
- Prometheus: `http://<lab-ip>:9091`
- cAdvisor: `http://<lab-ip>:8082`
- Loki: `http://<lab-ip>:3100` (log ingestion API)
- Jenkins: `http://<lab-ip>:8083`
- Ollama (LLM API): `http://<lab-ip>:11434`
- Stable Diffusion WebUI: `http://<lab-ip>:7860`
- Stable Diffusion gallery: `http://<lab-ip>:8081`
- Minecraft Bedrock: `<lab-ip>:19132` (UDP; add server in Bedrock client)
