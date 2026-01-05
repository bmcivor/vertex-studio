# Taiga Playbook

The Taiga playbook deploys the Taiga project management platform (Jira replacement) on the lab machine.

## What It Does

- Checks if `/opt/taiga` directory exists
- Clones the official `taigaio/taiga-docker` repository (version 6.9.0) if not already present
- Templates environment configuration (`.env` file) with lab-specific settings
- Runs database migrations using `taiga-manage migrate`
- Starts all Taiga services with `--force-recreate` to ensure proper networking:
  - `taiga-db` - PostgreSQL database
  - `taiga-back` - Backend API (Django/Python)
  - `taiga-front` - Frontend (Angular)
  - `taiga-gateway` - Nginx reverse proxy
  - `taiga-events` - WebSocket server for real-time updates
  - `taiga-async` - Celery worker for background tasks
  - `taiga-protected` - Protected file serving
  - `taiga-async-rabbitmq` - Message broker for async tasks
  - `taiga-events-rabbitmq` - Message broker for events

## Prerequisites

- Docker must be installed (run bootstrap playbook first)
- Lab user must be in the docker group

## Configuration

The `.env` file is templated with the following key settings:

- `TAIGA_DOMAIN`: Automatically set to lab server IP address with port 9000
- `TAIGA_SCHEME`: http (https can be configured later with reverse proxy)
- `SECRET_KEY`: Set to `changeme-secret-key-12345` (should be changed for production)
- Database credentials: username `taiga`, password `changeme` (should be updated for production)
- RabbitMQ credentials: username `taiga`, password `changeme`, vhost `taiga` (should be updated for production)
- Email backend: console (logs emails instead of sending, configure SMTP for production)
- Telemetry: Disabled

## Usage

```bash
make taiga
```

## Accessing Taiga

Once deployed, Taiga is accessible at:

**http://192.168.20.15:9000**

Default credentials need to be created manually (see Post-Deployment section).

## Post-Deployment

### Create Admin User

After first deployment, create an admin user:

```bash
ssh lab-owner@192.168.20.15
cd /opt/taiga
./taiga-manage.sh createsuperuser
```

Follow the prompts to set username, email, and password.

## Idempotence

The playbook is idempotent with some caveats:

- Repository clone is skipped if `/opt/taiga` already exists
- `.env` file is regenerated each run (templates can be updated)
- Services are recreated on each run (`--force-recreate`) to ensure correct container networking
- Database migrations are run each time but only apply new migrations

## Troubleshooting

### 502 Bad Gateway

If you see a 502 error, check container status:

```bash
ssh lab-owner@192.168.20.15 'docker ps --filter name=taiga'
```

All containers should show status "Up". If gateway shows "Up" but others are restarting, check logs:

```bash
docker logs taiga-taiga-back-1
docker logs taiga-taiga-front-1
```

### Container IP Issues

The playbook uses `--force-recreate` to ensure containers get fresh IPs and the gateway can connect properly. If issues persist, manually restart:

```bash
cd /opt/taiga
docker compose down
docker compose up -d
```
