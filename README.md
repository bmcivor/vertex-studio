# Vertex Studio

A self-hosted development platform featuring project management, CI/CD, and LLM integration. All managed with Ansible.

## Features

- **Project Management**: Taiga for agile workflows and issue tracking
- **CI/CD**: GitLab with integrated runners (planned)
- **LLM-Assisted Development**: Local LLM using 3090 GPU (planned)
- **Documentation**: MkDocs for platform documentation
- **Infrastructure as Code**: Fully automated Ansible deployment

## Quick Start

### Prerequisites

- Lab machine with Fedora Server installed
- Dev machine with Ansible installed
- SSH key-based authentication configured between machines

### Initial Setup

1. **Configure inventory**

   Edit `inventory/lab.yaml` with your lab machine's IP and username.

2. **Test connection**

   ```bash
   ansible all -m ping
   ```

3. **Deploy platform**

   ```bash
   # Full deployment
   ansible-playbook site.yaml

   # Or step-by-step
   ansible-playbook playbooks/bootstrap.yaml
   ansible-playbook playbooks/docker.yaml
   ansible-playbook playbooks/taiga.yaml
   ```

## Documentation

Full documentation is available via MkDocs:

```bash
# View locally
pip install mkdocs mkdocs-material
mkdocs serve

# Or deploy to lab machine
ansible-playbook playbooks/mkdocs.yaml
# Then access at http://<lab-ip>:8000
```

## Project Structure

```
vertex-studio/
├── ansible.cfg           # Ansible configuration
├── inventory/            # Infrastructure inventory
├── playbooks/            # Ansible playbooks
├── roles/                # Ansible roles
├── docs/                 # MkDocs documentation
├── mkdocs.yml            # MkDocs configuration
└── README.md
```

## Contributing

This is a personal project for learning and experimentation. If you find it useful and want to adapt it for your own use, feel free to fork it.

## License

See [LICENSE](LICENSE) file.
