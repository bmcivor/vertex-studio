# Installation

## Lab Machine Setup

### 1. Install Fedora Server

1. Download Fedora Server ISO
2. Create bootable USB
3. Boot lab machine from USB
4. Follow installation wizard:
   - Set hostname: `labserver`
   - Create user account
   - Configure network (DHCP is fine initially)
   - Note the IP address after installation

### 2. Configure SSH

On the lab machine:

```bash
# Enable and start SSH
sudo systemctl enable --now sshd

# Check SSH is running
sudo systemctl status sshd

# Note your IP address
ip addr show
```

### 3. Configure Passwordless Sudo

Ansible requires passwordless sudo to run playbooks. On the lab machine:

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

Save and exit. Changes take effect immediately.

## Dev Machine Setup

### Set Up SSH Keys

**IMPORTANT**: This must be done before running any Ansible commands.

On your dev machine:

```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519

# Copy key to lab machine
ssh-copy-id lab-owner@shadowlands

# Test connection
ssh lab-owner@shadowlands
```

You should be able to SSH without entering a password. If this doesn't work, Ansible will not be able to connect.

### Clone Repository

```bash
cd ~/Development/Lab
cd vertex-studio
```

### Configure Inventory

Copy and edit the host variables file:

```bash
cp inventory/host_vars/labserver.yaml.example inventory/host_vars/labserver.yaml
```

Update `inventory/host_vars/labserver.yaml` with:
- `ansible_host`: actual lab machine hostname (e.g., shadowlands)
- `ansible_user`: username you created during Fedora install

### Build Ansible Container

```bash
make build
```

### Test Ansible Connection

```bash
make ping
```

Expected output:
```
labserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

## Next Steps

Proceed to [Configuration](configuration.md) to customize your deployment.
