# Lab Playbook

Master playbook that deploys the complete Vertex Studio platform in a single command.

## Purpose

Provides a single entry point to deploy all platform components in the correct order. Use this for fresh deployments or full redeployments.

## What It Runs

1. **bootstrap.yaml** - Base system configuration and Docker installation
2. **tailscale.yaml** - Install Tailscale VPN
3. **nvidia.yaml** - Install NVIDIA drivers
4. **nvidia-container.yaml** - Install NVIDIA Container Toolkit
5. **stable-diffusion.yaml** - Deploy Stable Diffusion WebUI
6. **ollama.yaml** - Install Ollama LLM
7. **taiga.yaml** - Project management deployment
8. **mkdocs.yaml** - Documentation server deployment
9. **prometheus.yaml** - Deploy Prometheus and cAdvisor
10. **loki.yaml** - Deploy Loki and Promtail
11. **grafana.yaml** - Deploy Grafana monitoring dashboard
12. **jenkins.yaml** - Deploy Jenkins CI server
13. **minecraft-bedrock.yaml** - Deploy Minecraft Bedrock server (with `minecraft_bedrock_destroy=false`)

## Usage

```bash
make lab
```

Or with verbose output:

```bash
docker-compose run --rm ansible "ansible-playbook playbooks/lab.yaml -vv"
```

## Maintenance

**When adding new applications**, update `playbooks/lab.yaml` to include the new playbook in the appropriate order. Consider dependencies:

- Infrastructure/base components first
- Applications that depend on others come after their dependencies
- Independent applications can be in any order

## When to Use

- Fresh lab machine setup
- Full platform redeployment
- Ensuring all components are in sync

For individual component updates, use the specific `make` targets (`make taiga`, `make mkdocs`, `make minecraft-bedrock`, etc.) instead.
