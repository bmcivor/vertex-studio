# Minecraft Bedrock Server (Design)

## Goal

- Run a **private** Minecraft Bedrock Dedicated Server on the lab box.
- World and config live on the server so the gaming PC can be reformatted without losing the world.
- No Realms or cloud; full control of world files and backups.

## Scope

- Single Bedrock server instance.
- Deployed via Ansible (role + playbook), consistent with other vertex-studio services.
- Docker-based; included in full `make lab` deploy; can also be deployed or destroyed via standalone playbook.

## Components

| Component | Purpose |
|-----------|--------|
| **Role** `minecraft-bedrock` | Create `/opt/minecraft-bedrock`, template docker-compose, start container. |
| **Playbook** `playbooks/minecraft-bedrock.yaml` | Run role on `labserver` with `become`. |
| **Makefile** | Target `make minecraft-bedrock` to run the playbook. |
| **Docs** | `docs/playbooks/minecraft-bedrock.md` — usage, version variables, connect, backup. |

## Technical Choices

- **Image:** [itzg/minecraft-bedrock-server](https://github.com/itzg/docker-minecraft-bedrock-server). Inventory sets `minecraft_bedrock_image` and **`minecraft_bedrock_version`** (Docker Hub **image tag**). The Bedrock game binary is downloaded at container start from Mojang, not baked into the image.
- **Mojang build:** Compose passes **`VERSION`** from **`minecraft_bedrock_package_version`** (e.g. `LATEST` or an exact zip version). That value must match Mojang’s `bedrock-server-<VERSION>.zip`; it is independent of the Docker image tag.
- **Port:** Bedrock default **19132/udp** (expose from container).
- **Data:** Persistent named volume for world + server config; normal deploy keeps the volume. Destroy playbook removes it with `docker compose down -v`.
- **EULA:** `EULA=TRUE` and other server options via role defaults and compose template.

## Implementation Steps

1. **Role skeleton** — Create `roles/minecraft-bedrock/` with `tasks/main.yaml` (stub or full tasks).
2. **Inventory** — `inventory/group_vars/all/vars.yaml`: `minecraft_bedrock_image`, `minecraft_bedrock_version` (image tag), `minecraft_bedrock_package_version` (itzg `VERSION` / Mojang zip selector).
3. **Defaults** — `roles/minecraft-bedrock/defaults/main.yaml`: gameplay and `server.properties`-related env (EULA, level name, gamemode, difficulty, etc.).
4. **Docker Compose template** — `roles/minecraft-bedrock/templates/docker-compose.yaml.j2`: image from inventory, port 19132:19132/udp, env including `VERSION` and server options, named volume for `/data`.
5. **Tasks** — Create `/opt/minecraft-bedrock` (owner/group consistent with other roles), template docker-compose into that dir, run `docker compose up -d --force-recreate`.
6. **Playbook** — `playbooks/minecraft-bedrock.yaml`: hosts labserver, become, role `minecraft-bedrock`.
7. **Makefile** — `minecraft-bedrock` and `minecraft-bedrock-destroy` targets via Ansible container.
8. **Docs** — `docs/playbooks/minecraft-bedrock.md`: usage, version variables, connect, backup note.
9. **Optional** — `import_playbook: minecraft-bedrock.yaml` in `playbooks/lab.yaml` when the server should run on every `make lab`.

## Backup

- World and server config live under the container’s data volume (or bind mount). Document the path in the playbook doc so it can be included in the lab backup strategy when that’s implemented.

## Out of Scope (for this design)

- RCON / admin CLI (can be added later via image env if the image supports it).
- Multiple Bedrock instances or Java/Bedrock mix (future enhancement).
