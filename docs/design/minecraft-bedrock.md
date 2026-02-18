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
| **Docs** | `docs/playbooks/minecraft-bedrock.md` — usage, connect, backup note. |

## Technical Choices

- **Image:** Use a maintained Bedrock server image (e.g. `itzg/minecraft-bedrock-server`). Accepts env vars for version, level name, gamemode, etc. First run downloads server binary and generates world in a data volume.
- **Port:** Bedrock default **19132/udp** (expose from container).
- **Data:** Persistent volume (bind mount or named volume) for world + server config so world survives container recreate.
- **EULA:** Image typically requires `EULA=TRUE` (or equivalent) in env; document in role/defaults or template.

## Implementation Steps

1. **Role skeleton** — Create `roles/minecraft-bedrock/` with `tasks/main.yaml` (stub or full tasks).
2. **Defaults** — `roles/minecraft-bedrock/defaults/main.yaml`: image name and tag, host port (19132), server name, level name, gamemode (e.g. survival), other env vars the image needs.
3. **Docker Compose template** — `roles/minecraft-bedrock/templates/docker-compose.yaml.j2`: one service, image from defaults, port 19132:19132/udp, env (EULA, SERVER_NAME, LEVEL_NAME, etc.), volume for data dir.
4. **Tasks** — Create `/opt/minecraft-bedrock` (owner/group consistent with other roles), template docker-compose into that dir, run `docker compose up -d` (and optionally `--force-recreate` if you want idempotent converge).
5. **Playbook** — `playbooks/minecraft-bedrock.yaml`: hosts labserver, become, role `minecraft-bedrock`.
6. **Makefile** — Add `minecraft-bedrock` target and `make help` line (pattern: `check-docker` then `docker-compose run --rm ansible "ansible-playbook playbooks/minecraft-bedrock.yaml"`).
7. **Docs** — `docs/playbooks/minecraft-bedrock.md`: what the playbook does, how to connect (client: add server by IP/hostname, port 19132), where world lives (`/opt/minecraft-bedrock` or volume path), note that world can be added to backup strategy (see `docs/operations/backup.md`).
8. **Optional** — Add `import_playbook: minecraft-bedrock.yaml` to `playbooks/lab.yaml` only if you want the server deployed every time you run `make lab`.

## Backup

- World and server config live under the container’s data volume (or bind mount). Document the path in the playbook doc so it can be included in the lab backup strategy when that’s implemented.

## Out of Scope (for this design)

- RCON / admin CLI (can be added later via image env if the image supports it).
- Multiple Bedrock instances or Java/Bedrock mix (future enhancement).
