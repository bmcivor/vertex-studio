# Tailscale Playbook

Installs [Tailscale](https://tailscale.com/) VPN on the lab machine for secure remote access.

## What It Does

1. Adds the Tailscale package repository
2. Installs the `tailscale` package
3. Enables and starts the `tailscaled` service

## Usage

```bash
make tailscale
```

## Post-Installation

After the playbook completes, SSH into the lab machine and authenticate:

```bash
ssh lab-owner@192.168.20.15
sudo tailscale up
```

This will output a URL. Open it in your browser to authenticate with your Tailscale account.

Once authenticated, the machine will appear in your Tailscale admin console and receive a stable IP (100.x.x.x range).

## Connecting Remotely

After setup, you can SSH using the Tailscale IP or hostname:

```bash
# Using Tailscale IP
ssh lab-owner@100.x.x.x

# Using MagicDNS hostname (if enabled)
ssh lab-owner@shadowlands
```

## Updating Ansible Inventory

Once Tailscale is working, you can update `inventory/hosts` to use the Tailscale IP for future Ansible runs from anywhere:

```ini
[lab]
labserver ansible_host=100.x.x.x
```
