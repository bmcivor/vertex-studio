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

### 3. Set Up SSH Keys

On your dev machine:

```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy key to lab machine
ssh-copy-id username@lab-ip

# Test connection
ssh username@lab-ip
```

## Dev Machine Setup

### Install Ansible

On Fedora:

```bash
sudo dnf install -y ansible-core
ansible --version
```

### Clone Repository

```bash
cd ~/Development/Lab
cd vertex-studio
```

### Configure Inventory

Edit `inventory/lab.yaml` and update:
- `ansible_host`: actual lab machine IP
- `ansible_user`: username you created during Fedora install

### Test Ansible Connection

```bash
ansible all -m ping
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
