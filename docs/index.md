# Vertex Studio

A self-hosted development platform built with Ansible, featuring:

- **Project Management**: Taiga for issue tracking and agile workflows
- **CI/CD Pipeline**: GitLab with integrated runners
- **LLM Integration**: Local LLM for development assistance using 3090 GPU
- **Container Orchestration**: Docker Compose (with k3s migration path)

## Quick Start

### Prerequisites

- Dev machine with Ansible installed
- Lab machine with Fedora Server installed
- SSH key-based authentication configured

### Deploy Platform

```bash
# Deploy everything
ansible-playbook site.yaml

# Or deploy step-by-step
ansible-playbook playbooks/bootstrap.yaml
ansible-playbook playbooks/docker.yaml
ansible-playbook playbooks/taiga.yaml
```

## Architecture

See [Architecture](architecture.md) for detailed system design.

## Access Points

After deployment, services will be accessible at:

- Taiga: `http://<lab-ip>:9000`
- MkDocs: `http://<lab-ip>:8000`
- GitLab: `http://<lab-ip>:8080` (future)
- Local LLM: `http://<lab-ip>:11434` (future)
