# Vertex Studio

A self-hosted development platform: project management, CI/CD, observability, GPU workloads, and optional services—all deployed with Ansible from a containerized control environment.

## Features

- **Project management**: Taiga for agile workflows and issue tracking
- **CI/CD**: Jenkins (custom plugin image); GitHub webhooks trigger builds on the lab host
- **Documentation**: MkDocs site served via nginx
- **Observability**: Grafana, Prometheus, cAdvisor, Loki, and Promtail
- **LLM**: Ollama on the lab host (e.g. LLaVA) with GPU when NVIDIA stack is installed
- **Image generation**: Stable Diffusion WebUI (AUTOMATIC1111) and optional gallery
- **Remote access**: Tailscale for reaching the lab outside the LAN
- **Private registry** (optional): Docker Registry v2 and Registry UI (`make registry`; not part of the default full-lab playbook)
- **Minecraft Bedrock**: Deploy or tear down via dedicated playbook targets
- **Infrastructure as code**: Playbooks and roles under `playbooks/` and `roles/`

## Quick start

### Prerequisites

- **Dev machine**: Docker and Docker Compose (drives the Ansible container)
- **Lab machine**: Fedora Server (or compatible target for the playbooks), SSH access
- **SSH**: Key-based auth to the lab host configured before running Ansible
- **Inventory**: Copy `inventory/host_vars/labserver.yaml.example` to `inventory/host_vars/labserver.yaml` and set hostname, user, and secrets as needed. Vault-related values use `inventory/group_vars/all/vault.yaml` with `.vault_password` for Ansible Vault (see project docs).

### Build and connect

```bash
make build   # Build Ansible Docker image
make ping    # Verify Ansible can reach the lab host
```

### Deploy

- **Full stack** (bootstrap plus Tailscale, NVIDIA drivers, NVIDIA Container Toolkit, Stable Diffusion, Ollama, Taiga, MkDocs, Prometheus, Loki, Grafana, Jenkins, Minecraft Bedrock):

  ```bash
  make lab
  ```

  This is a long run and assumes GPU/Tailscale/Minecraft are desired; use individual targets below for a smaller footprint.

- **Bootstrap only** (base packages, Docker, SSH hardening, etc.):

  ```bash
  make bootstrap
  ```

- **Common individual targets**: `make taiga`, `make mkdocs`, `make jenkins`, `make prometheus`, `make loki`, `make grafana`, `make registry`, `make tailscale`, `make ollama`, `make stable-diffusion`, `make minecraft-bedrock`, etc. See `make help` and [docs](docs/index.md).

## Access (after deploy)

Use your lab host name or IP where examples show `shadowlands`. With Tailscale, use your tailnet hostname (see [docs/services.md](docs/services.md)).

| Service | Default URL / port |
|--------|---------------------|
| Taiga | `http://shadowlands:9000` |
| MkDocs | `http://shadowlands:8080` |
| Grafana | `http://shadowlands:3000` |
| Prometheus | `http://shadowlands:9091` |
| cAdvisor | `http://shadowlands:8082` |
| Loki | `http://shadowlands:3100` |
| Jenkins | `http://shadowlands:8083` |
| Ollama | `http://shadowlands:11434` |
| Stable Diffusion WebUI | `http://shadowlands:7860` |
| SD gallery | `http://shadowlands:8081` |
| Docker Registry (API) | `http://shadowlands:5000` |
| Registry UI | `http://shadowlands:8084` |
| Minecraft Bedrock | `shadowlands:19132` (UDP) |

Jenkins may be configured for HTTPS on the Tailscale hostname; see role variables and [design docs](docs/design/jenkins-github-integration.md).

## Makefile targets

```bash
make help                      # All targets
make build                     # Build Ansible container
make ping                      # Test connectivity to lab
make bootstrap                 # Bootstrap playbook
make bootstrap-verbose         # Bootstrap with -vv
make lab                       # Full platform (see playbooks/lab.yaml)
make taiga / mkdocs / tailscale
make nvidia / nvidia-container
make stable-diffusion / ollama
make grafana / prometheus / loki
make registry                  # Docker Registry + UI (not in make lab)
make jenkins
make minecraft-bedrock
make minecraft-bedrock-destroy
make reboot / shutdown         # power.yaml
make bump-patch|bump-minor|bump-major
make clean
```

## Project layout

```
vertex-studio/
├── ansible.cfg
├── docker-compose.yaml      # Ansible control container
├── Dockerfile
├── Makefile
├── Jenkinsfile
├── pyproject.toml           # Project metadata / version
├── inventory/
│   ├── lab.yaml             # Host list (e.g. labserver)
│   ├── group_vars/all/      # Shared vars (and vault)
│   └── host_vars/           # Per-host overrides (see .example)
├── playbooks/               # Entry playbooks (bootstrap, lab, per-service)
├── roles/                   # Service roles
├── docs/                    # MkDocs source (built/deployed by playbook)
├── mkdocs.yml
└── README.md
```

## Vertex apps (roadmap)

Studio can run **vertex-*** apps as container images pulled on the host. Ideas for future or companion apps:

| App | Purpose |
|-----|---------|
| **vertex-block** | First app; build → image → deploy pattern |
| **vertex-dashboard** | Single “lab home” with links to Taiga, Grafana, Jenkins, MkDocs, etc. |
| **vertex-notify** | Notifications for builds, backups, incidents (Discord/Slack/email/webhook) |
| **vertex-backup** | Backup orchestration for DBs, volumes, configs |
| **vertex-health** | Endpoint checks; metrics or status for Grafana/alerting |
| **vertex-registry** | Deeper registry integration beyond the optional Docker Registry role |
| **vertex-bot** | Chat bot for Ollama, status, SD, backups |
| **vertex-sync** | Sync config or metadata between lab and other environments |

## Documentation

Site source lives under `docs/`. Deploy with `make mkdocs` and open the MkDocs URL on the lab host, or run a local preview with MkDocs if configured on your workstation.

## License

See [LICENSE](LICENSE).
