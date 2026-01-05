# Docker Playbook

Installs and configures Docker and Docker Compose on the lab machine.

## What It Does

- Adds Docker repository
- Installs Docker Engine
- Installs Docker Compose plugin
- Configures Docker daemon
- Adds user to docker group
- Enables Docker service

## Usage

```bash
ansible-playbook playbooks/docker.yaml
```

## Post-Installation

After running this playbook, the user will need to log out and back in for docker group membership to take effect.

## Tasks

(To be documented when playbook is created)
