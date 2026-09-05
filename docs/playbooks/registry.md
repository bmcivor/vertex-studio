# Registry Playbook

Deploys a private Docker Registry and a web UI for browsing it to the lab server.

Unlike most services here, this one is **not** part of `make lab`. It is deployed on its own.

## What It Does

- Merges `insecure-registries` and `features.containerd-snapshotter: false` into
  `/etc/docker/daemon.json` on the lab host, so the daemon will talk to the registry over plain
  HTTP
- Restarts the Docker daemon so that change takes effect
- Deploys Docker Registry v2 on port 5000
- Deploys the joxit registry UI on port 8084, proxying to the registry

## Restarting Docker restarts everything else

The daemon.json change notifies a handler that restarts Docker, and the play flushes handlers
immediately so the daemon is ready before the registry starts. Every other container on the
host goes down and comes back up with it, including Taiga, Jenkins, Grafana and MkDocs.

Run this when a short outage of the whole lab is acceptable.

## Usage

```bash
make registry
```

## Access

- Registry API: `http://shadowlands:5000/v2/`
- Registry UI: `http://shadowlands.tail252efc.ts.net:8084`

List the images currently held:

```bash
curl -s http://shadowlands:5000/v2/_catalog
```

List the tags of one image:

```bash
curl -s http://shadowlands:5000/v2/vertex-studio/tags/list
```

## Versions

Set in `inventory/group_vars/all/vars.yaml`:

- `registry_image` / `registry_version`
- `registry_ui_image` / `registry_ui_version`

## Relationship to Jenkins

`Jenkinsfile` builds and pushes an image on a git tag, targeting
`shadowlands:5000/vertex-studio:${TAG_NAME}`. That is why the daemon needs the
`insecure-registries` entry: the push is plain HTTP.

## Removing the Registry

```bash
# Stop and remove containers
ssh shadowlands "cd /opt/registry && docker compose down"

# Remove stored images (optional - this deletes every pushed image)
ssh shadowlands "docker volume rm registry_registry-data"
```

Removing the registry does not revert the `daemon.json` change. Edit
`/etc/docker/daemon.json` by hand and restart Docker if you want the `insecure-registries`
entry gone.
