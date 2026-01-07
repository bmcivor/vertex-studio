# Vertex Studio

A self-hosted development platform built with Ansible, featuring:

- **Project Management**: Taiga for issue tracking and agile workflows
- **CI/CD Pipeline**: GitLab with integrated runners (planned)
- **LLM Integration**: Local LLM for development assistance using 3090 GPU (planned)
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

# Deploy step-by-step
make bootstrap
make taiga
make mkdocs
```

## Architecture

See [Architecture](architecture.md) for detailed system design.

## Access Points

After deployment, services will be accessible at:

- Taiga: `http://<lab-ip>:9000`
- MkDocs: `http://<lab-ip>:8080`
- GitLab: `http://<lab-ip>:8080` (planned)
- Local LLM: `http://<lab-ip>:11434` (planned)
