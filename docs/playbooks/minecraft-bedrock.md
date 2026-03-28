# Minecraft Bedrock Playbook

Deploys and manages a private Minecraft Bedrock Dedicated Server on the lab box using Docker.

## What It Does

- **Deploy:** Creates `/opt/minecraft-bedrock`, templates docker-compose with your config, starts the container. World and server config persist in a Docker volume.
- **Destroy:** Stops the container and removes the volume (deleting the world). Run `make minecraft-bedrock` afterward to start a fresh server with a new world. You can instead add a second playbook task that runs `docker compose up -d` when `minecraft_bedrock_destroy` is true for a one-step recreate.

## Prerequisites

- Bootstrap completed (Docker on the lab server).
- Bedrock container image settings in `inventory/group_vars/all/vars.yaml`:
  - `minecraft_bedrock_image` — image name (e.g. `itzg/minecraft-bedrock-server`).
  - `minecraft_bedrock_version` — **Docker image tag** from Docker Hub (the itzg wrapper release).
  - `minecraft_bedrock_package_version` — value passed to the container as **`VERSION`** ([itzg/minecraft-bedrock-server](https://github.com/itzg/docker-minecraft-bedrock-server)): which **Mojang** Bedrock Dedicated Server zip to download. Use `LATEST` to follow the current stable build from minecraft.net, or set the exact version string that matches the Linux zip filename (`bedrock-server-<version>.zip`). The image tag and the Mojang zip version are **not** the same thing; pinning both to the same number can produce a 404 if Mojang never published that zip name.
- Gameplay and server properties (level name, gamemode, difficulty, etc.) are in `roles/minecraft-bedrock/defaults/main.yaml` (overridable via inventory if you add keys there).

## Versions and client mismatch

Bedrock clients only join a server whose dedicated server build matches their protocol. After a client update, if you see a version mismatch, redeploy with `make minecraft-bedrock` so the container can pull a current server build (especially when `minecraft_bedrock_package_version` is `LATEST`). Bump `minecraft_bedrock_version` when you want a newer itzg image (wrapper scripts and base image). The named volume is **not** removed by a normal deploy, so the world is kept; do **not** run `make minecraft-bedrock-destroy` unless you intend to delete the world volume.

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