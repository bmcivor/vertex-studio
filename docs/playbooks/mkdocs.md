# MkDocs Playbook

Deploys project documentation to the lab server.

## What It Does

- Syncs `docs/` directory and `mkdocs.yml` to `/opt/mkdocs` on the lab server
- Builds static HTML using mkdocs-material
- Serves via nginx container on port 8080

## Usage

```bash
make mkdocs
```

## Updating Documentation

1. Edit files in `docs/`
2. Run `make mkdocs`
3. Changes are live immediately

## Access

http://192.168.20.15:8080
