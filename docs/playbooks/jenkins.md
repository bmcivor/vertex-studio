# Jenkins Playbook

Deploys Jenkins CI server with plugins baked into a custom Docker image.

## What It Does

- Builds a custom Jenkins image from the official image + plugins
- Deploys Jenkins via Docker Compose
- Persists Jenkins data in Docker volumes
- Exposes Jenkins UI on port 8083

## Usage

Deploy Jenkins standalone:

```bash
make jenkins
```

Jenkins is also deployed as part of the full platform (`make lab`). See [Lab Playbook](lab.md).

## Access

After deployment:

- **Jenkins UI**: `http://shadowlands:8083`

## How It Works

1. **plugins.txt** lists required plugins with pinned versions (in `roles/jenkins/files/plugins.txt`)
2. **Dockerfile** extends the official Jenkins image and runs `jenkins-plugin-cli` to install plugins at build time
3. **Ansible** copies files to `/opt/jenkins`, builds the custom image, and starts the container
4. **Volumes** persist Jenkins home (`jenkins-data`) and config (`jenkins-config`)

## Configuration

Variables in `inventory/group_vars/all.yaml`:

- `jenkins_image`: Base image (default: `jenkins/jenkins`)
- `jenkins_version`: Jenkins version (default: `2.550`)

Optional environment variable when running the container:

- `JENKINS_ADMIN_PASSWORD`: Override default admin password (default: `admin`)

Note: The official Jenkins image does not auto-create users from env vars. On first run, use the setup wizard. Credentials are whatever you configure during setup.

## Data Persistence

Jenkins data is stored in Docker volumes:

- `jenkins-data`: Jenkins home (jobs, plugins, config)
- `jenkins-config`: Additional config

Data persists across container restarts and playbook re-runs.

## Removing Jenkins

```bash
# Stop and remove containers
ssh shadowlands "cd /opt/jenkins && docker compose down"

# Remove data (optional - deletes all jobs and config)
ssh shadowlands "docker volume ls"  # Find volume names (e.g. jenkins_jenkins-data)
ssh shadowlands "docker volume rm <volume-name>"
```
