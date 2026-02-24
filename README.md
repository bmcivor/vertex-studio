# Vertex Studio

A self-hosted development platform featuring project management, CI/CD, and LLM integration. All managed with Ansible.

## Features

- **Project Management**: Taiga for agile workflows and issue tracking
- **CI/CD**: Jenkins with custom plugin image
- **LLM-Assisted Development**: Local LLM using 3090 GPU (planned)
- **Documentation**: MkDocs served via nginx
- **Monitoring**: Grafana, Prometheus, and Loki for metrics and logs
- **Infrastructure as Code**: Fully automated Ansible deployment

## Quick Start

### Prerequisites

- Lab machine with Fedora Server installed
- Dev machine with Docker and Docker Compose
- SSH key-based authentication configured between machines
- Optional: Tailscale VPN for remote access

### Initial Setup

1. **Copy SSH key to lab machine**

   Before Ansible can connect, you need SSH key authentication configured:

   ```bash
   # Generate SSH key if you don't have one
   ssh-keygen -t ed25519
   
   # Copy key to lab machine
   ssh-copy-id lab-owner@shadowlands
   
   # Test connection
   ssh lab-owner@shadowlands
   ```

2. **Configure inventory**

   Copy and edit the host variables:

   ```bash
   cp inventory/host_vars/labserver.yaml.example inventory/host_vars/labserver.yaml
   # Edit with your lab machine's hostname and username
   ```

3. **Build and test**

   ```bash
   make build      # Build Ansible container
   make ping       # Test connection to lab machine
   ```

4. **Deploy platform**

   ```bash
   make bootstrap  # Initial server setup (packages, Docker, SSH hardening)
   make taiga      # Deploy Taiga project management
   make mkdocs     # Deploy documentation server
   ```

## Access

Once deployed:

- **Taiga**: http://shadowlands:9000
- **Documentation**: http://shadowlands:8080
- **Grafana**: http://shadowlands:3000
- **Prometheus**: http://shadowlands:9091
- **cAdvisor**: http://shadowlands:8082
- **Loki**: http://shadowlands:3100
- **Jenkins**: http://shadowlands:8083
- **Ollama**: http://shadowlands:11434
- **Stable Diffusion WebUI**: http://shadowlands:7860
- **Stable Diffusion gallery**: http://shadowlands:8081
- **Minecraft Bedrock**: shadowlands:19132 (UDP; add server in Bedrock client)

## Available Commands

```bash
make help                      # Show all targets
make build                     # Build Ansible Docker container
make ping                      # Test connection to lab machine
make bootstrap                 # Run bootstrap playbook
make bootstrap-verbose         # Run bootstrap with verbose output
make lab                       # Deploy complete platform (bootstrap + all apps)
make taiga                     # Deploy Taiga project management
make mkdocs                    # Deploy MkDocs documentation
make grafana                   # Deploy Grafana monitoring dashboard
make prometheus                # Deploy Prometheus and cAdvisor for metrics
make loki                      # Deploy Loki and Promtail for log collection
make jenkins                   # Deploy Jenkins CI server
make minecraft-bedrock         # Deploy Minecraft Bedrock server
make minecraft-bedrock-destroy # Destroy Minecraft Bedrock server (wipe world, leave stopped)
make clean                     # Remove Docker containers and images
```

## Project Structure

```
vertex-studio/
├── ansible.cfg           # Ansible configuration
├── inventory/            # Infrastructure inventory
│   └── host_vars/        # Host-specific variables
├── playbooks/            # Ansible playbooks
├── roles/                # Ansible roles
├── docs/                 # MkDocs documentation source
├── mkdocs.yml            # MkDocs configuration
├── Dockerfile            # Ansible container
├── docker-compose.yaml   # Container orchestration
├── Makefile              # Build commands
└── README.md
```

## Vertex apps (ideas)

Studio deploys **vertex-*** apps as container images to the host. These are independent apps; studio pulls the built image and runs them. Ideas for future vertex-* apps:

| App | Purpose |
|-----|---------|
| **vertex-block** | First app; establishes build → image → studio deploy pattern. |
| **vertex-dashboard** | Single "lab home" page with links to Taiga, Grafana, Jenkins, MkDocs, etc. |
| **vertex-notify** | Notifications when builds fail, backups complete, or services go down (Discord/Slack/email/webhook). |
| **vertex-backup** | Backup orchestrator: Taiga DB, Minecraft volume, configs; scheduled runs, optional notify on completion/failure. |
| **vertex-health** | Checks service endpoints (and e.g. Minecraft port); exposes up/down or metrics for Grafana/alerting. |
| **vertex-registry** | Private container registry so studio pulls your built images from the lab. |
| **vertex-bot** | Chat bot (Discord/Slack/Matrix) to query Ollama, check status, trigger Stable Diffusion or backups. |
| **vertex-sync** | Sync config, backup metadata, or env files between the lab and another location. |

## Documentation

Full documentation is deployed to the lab server:

```bash
make mkdocs
# Access at http://shadowlands:8080
```

## License

See [LICENSE](LICENSE) file.
