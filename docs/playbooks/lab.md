# Lab Playbook

Master playbook that deploys the complete Vertex Studio platform in a single command.

## Purpose

Provides a single entry point to deploy all platform components in the correct order. Use this for fresh deployments or full redeployments.

## What It Runs

1. **bootstrap.yaml** - Base system configuration and Docker installation
2. **taiga.yaml** - Project management deployment
3. **mkdocs.yaml** - Documentation server deployment

## Usage

```bash
make lab
```

Or with verbose output:

```bash
docker-compose run --rm ansible "ansible-playbook playbooks/lab.yaml -vv"
```

## Maintenance

**When adding new applications**, update `playbooks/lab.yaml` to include the new playbook in the appropriate order. Consider dependencies:

- Infrastructure/base components first
- Applications that depend on others come after their dependencies
- Independent applications can be in any order

## When to Use

- Fresh lab machine setup
- Full platform redeployment
- Ensuring all components are in sync

For individual component updates, use the specific `make` targets (`make taiga`, `make mkdocs`, etc.) instead.
