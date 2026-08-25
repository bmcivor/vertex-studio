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
ssh lab-owner@shadowlands
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

Once Tailscale is working, update `inventory/host_vars/labserver.yaml` so Ansible reaches the
host over the tailnet from anywhere:

```yaml
ansible_host: shadowlands.tail252efc.ts.net
ansible_user: lab-owner
```

Prefer the MagicDNS hostname over the raw `100.x.x.x` address. The Ansible control container is
already pointed at MagicDNS in `docker-compose.yaml`, which sets the Tailscale resolver and a
tailnet search domain.

The host list itself lives in `inventory/lab.yaml` in YAML format, with a single host
`labserver` in the `all` group.
