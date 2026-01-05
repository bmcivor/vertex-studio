# Taiga Playbook

Deploys Taiga project management system using Docker Compose.

## What It Does

- Creates directory structure for Taiga
- Deploys Taiga containers:
  - Frontend
  - Backend
  - PostgreSQL database
  - RabbitMQ message queue
- Configures persistent storage
- Sets up environment variables

## Usage

```bash
ansible-playbook playbooks/taiga.yaml
```

## Accessing Taiga

After deployment, access Taiga at:

```
http://<lab-ip>:9000
```

Initial setup will prompt you to create an admin account.

## Tasks

(To be documented when playbook is created)

## Configuration

(To be documented when playbook is created)
