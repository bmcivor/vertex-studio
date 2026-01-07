# Vertex Studio

A self-hosted development platform featuring project management, CI/CD, and LLM integration. All managed with Ansible.

## Features

- **Project Management**: Taiga for agile workflows and issue tracking
- **CI/CD**: GitLab with integrated runners (planned)
- **LLM-Assisted Development**: Local LLM using 3090 GPU (planned)
- **Documentation**: MkDocs served via nginx
- **Infrastructure as Code**: Fully automated Ansible deployment

## Quick Start

### Prerequisites

- Lab machine with Fedora Server installed
- Dev machine with Docker and Docker Compose
- SSH key-based authentication configured between machines

### Initial Setup

1. **Configure inventory**

   Copy and edit the host variables:

   ```bash
   cp inventory/host_vars/labserver.yaml.example inventory/host_vars/labserver.yaml
   # Edit with your lab machine's IP and username
   ```

2. **Build and test**

   ```bash
   make build      # Build Ansible container
   make ping       # Test connection to lab machine
   ```

3. **Deploy platform**

   ```bash
   make bootstrap  # Initial server setup (packages, Docker, SSH hardening)
   make taiga      # Deploy Taiga project management
   make mkdocs     # Deploy documentation server
   ```

## Access

Once deployed:

- **Taiga**: http://192.168.20.15:9000
- **Documentation**: http://192.168.20.15:8080

## Available Commands

```bash
make help             # Show all targets
make build            # Build Ansible Docker container
make ping             # Test connection to lab machine
make bootstrap        # Run bootstrap playbook
make bootstrap-verbose # Run bootstrap with verbose output
make taiga            # Deploy Taiga project management
make mkdocs           # Deploy MkDocs documentation
make clean            # Remove Docker containers and images
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

## Documentation

Full documentation is deployed to the lab server:

```bash
make mkdocs
# Access at http://192.168.20.15:8080
```

## License

See [LICENSE](LICENSE) file.
