# Bootstrap Playbook

The bootstrap playbook configures the base operating system for the lab machine.

## What It Does

- Updates all system packages to latest versions
- Installs developer tools: vim, git, curl, wget, htop, tmux, nano, tree
- Sets hostname to `shadowlands`
- Sets timezone to `Australia/Brisbane`
- Configures SSH hardening:
  - Disables root SSH login
  - Disables password authentication (SSH keys only)
- Installs and enables fail2ban for brute-force protection

## Prerequisites

The lab user must have passwordless sudo configured. On the lab machine:

```bash
sudo visudo
```

Change:
```
%wheel  ALL=(ALL)       ALL
```

To:
```
%wheel  ALL=(ALL)       NOPASSWD: ALL
```

## Usage

```bash
docker-compose run --rm ansible "ansible-playbook playbooks/bootstrap.yaml"
```

For verbose output:

```bash
docker-compose run --rm ansible "ansible-playbook playbooks/bootstrap.yaml -vv"
```

## Idempotence

The playbook is idempotent and can be run multiple times safely. Subsequent runs will show `ok` status for tasks already in the desired state.
