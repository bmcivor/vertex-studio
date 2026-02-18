# Minecraft Bedrock Playbook

Deploys and manages a private Minecraft Bedrock Dedicated Server on the lab box using Docker.

## What It Does

- **Deploy:** Creates `/opt/minecraft-bedrock`, templates docker-compose with your config, starts the container. World and server config persist in a Docker volume.
- **Destroy:** Stops the container and removes the volume (deleting the world). Run `make minecraft-bedrock` afterward to start a fresh server with a new world. You can instead add a second playbook task that runs `docker compose up -d` when `minecraft_bedrock_destroy` is true for a one-step recreate.

## Prerequisites

- Bootstrap completed (Docker on the lab server).
- Image and version set in `inventory/group_vars/all.yaml` (`minecraft_bedrock_image`, `minecraft_bedrock_version`). Server options are in `roles/minecraft-bedrock/defaults/main.yaml`.

## Usage

**Deploy or update the server:**

```bash
make minecraft-bedrock
```

**Destroy the world and start a new one:**

```bash
make minecraft-bedrock-destroy
```

## Connecting from the Client

1. Open Minecraft (Bedrock) on your gaming PC or other device.
2. Go to **Play** → **Servers** (or **Friends** → **Add Server** / **Add external server**).
3. Add server:
   - **Address:** The lab server hostname or IP (e.g. `shadowlands` if DNS/Tailscale resolves it, or the LAN/Tailscale IP).
   - **Port:** `19132`

Save and join. The server is reachable on the host’s port 19132 (UDP).

## Where the World Lives

World and server config live in the Docker named volume `minecraft-bedrock-data`, used by the container at `/data`. The volume is on the lab host’s disk; it persists across container restarts and host reboots. To include it in backups, see [Backup and Restore](../operations/backup.md) and add the volume’s data path (e.g. under Docker’s volume storage on the host) to your backup procedure.

## Recreate Flow

Running `make minecraft-bedrock-destroy` runs `docker compose down -v` in `/opt/minecraft-bedrock` (removing the volume) and skips the role, so the server is left stopped. Run `make minecraft-bedrock` to start it again with a new world. Optionally add a second playbook task that runs `docker compose up -d` when `minecraft_bedrock_destroy` is true for a single-command recreate.