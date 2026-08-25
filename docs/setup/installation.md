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

Use the IP address you noted in step 1. The name `shadowlands` does not resolve yet: the
hostname is only changed by the bootstrap playbook, which needs working SSH first, and
MagicDNS is not available until Tailscale is installed by `make tailscale`.

```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519

# Copy key to lab machine
ssh-copy-id lab-owner@192.168.20.15

# Test connection
ssh lab-owner@192.168.20.15
```

You should be able to SSH without entering a password. If this doesn't work, Ansible will not be able to connect.

Once bootstrap and Tailscale have run, the host answers to `shadowlands` and you can switch
`ansible_host` over to it.

### Clone Repository

```bash
mkdir -p ~/Development/Lab
cd ~/Development/Lab
git clone git@github.com:bmcivor/vertex-studio.git
cd vertex-studio
```

### Developer CLI (`vertex-studio`)

From the repository root, install a small launcher onto your `PATH` so you can run the same targets as `make` from any directory (for example `vertex-studio ping` instead of `make ping`).

```bash
make install
```

- **Default location**: `PREFIX` is `$(HOME)/.local`, so the command is installed to **`~/.local/bin/vertex-studio`**. Override with `make install PREFIX=/other/prefix` (installs to `$PREFIX/bin/vertex-studio`).
- **Staging / packaging**: set **`DESTDIR`** (prepended to paths, GNU convention), e.g. `make install DESTDIR=/tmp/stage`.
- **PATH**: If `~/.local/bin` is not on your `PATH`, `make install` prints an example `export PATH=...` line. The installer does **not** modify your shell rc files.
- **Repository moves**: the installed script records the absolute path to the clone at install time. After moving or recloning the repo, run **`make install`** again from the new tree.
- **Remove**: `make uninstall` (use the same **`PREFIX`** and **`DESTDIR`** you used for install).
- **Output**: The Makefile sets **`.SILENT`**, so **`make`** targets do not echo recipe lines (e.g. `docker-compose run …`) before they run. The installed script also runs `make --no-print-directory -s -C …`, so `vertex-studio` omits directory traces as well. Command output (Ansible, Docker, etc.) is unchanged. Use **`make -n`** in the repo to preview commands without running them.

### Configure Inventory

Copy and edit the host variables file:

```bash
cp inventory/host_vars/labserver.yaml.example inventory/host_vars/labserver.yaml
```

Update `inventory/host_vars/labserver.yaml` with:
- `ansible_host`: actual lab machine hostname (e.g., shadowlands)
- `ansible_user`: username you created during Fedora install

### Create the Vault Password File

`ansible.cfg` sets `vault_password_file = .vault_password`, and the encrypted
`inventory/group_vars/all/vault.yaml` is committed to the repository. The password file itself
is gitignored, so it does not come with the clone and you must create it before anything runs.
Without it, every target fails, including `make ping`.

```bash
install -m 600 /dev/null .vault_password
```

Then open `.vault_password` in an editor and put the vault password on the first line. Creating
it with a shell redirect instead writes the password into your shell history and leaves the
file world-readable.

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
