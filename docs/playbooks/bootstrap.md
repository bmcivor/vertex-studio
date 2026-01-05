# Bootstrap Playbook

The bootstrap playbook configures the base operating system for the lab machine.

## What It Does

- Installs Docker CE:
  - Adds Docker repository
  - Installs docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin
  - Enables and starts Docker service
  - Adds user to docker group
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
make bootstrap
```

For verbose output:

```bash
make bootstrap-verbose
```

## Idempotence

The playbook is idempotent and can be run multiple times safely. Subsequent runs will show `ok` status for tasks already in the desired state.
