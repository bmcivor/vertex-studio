# Configuration

## Inventory Configuration

The inventory file defines your lab infrastructure.

### Set Up Host Variables

After Fedora Server is installed, edit `inventory/host_vars/labserver.yaml` with your actual values:

```yaml
ansible_host: shadowlands      # Your lab machine hostname
ansible_user: lab-owner        # Your username
```

This file is gitignored so your local config won't be committed.

## Ansible Configuration

The `ansible.cfg` file controls Ansible behavior:

Under `[defaults]`:

- `inventory`: Points to your inventory file
- `roles_path`: Where roles are looked up (`roles`)
- `host_key_checking`: Disabled for home lab convenience
- `retry_files_enabled`: Disabled to avoid clutter
- `interpreter_python`: `auto_silent`, which suppresses interpreter-discovery warnings
- `vault_password_file`: `.vault_password`, so vault-encrypted files decrypt without prompting

Under `[ssh_connection]`:

- `ssh_args`: enables SSH connection multiplexing and sets a dumb terminal

Privilege escalation is not configured here. Each playbook sets `become: true` on the play
itself.

## Service Configuration

Service-specific configuration will be documented as roles are created:

- Bootstrap configuration
- Docker configuration
- Taiga configuration

## Security Considerations

For a home lab environment:

- SSH key authentication is required
- Services initially accessible only on local network
- Firewall configured via bootstrap playbook
- Secrets should not be committed to git

### Managing Secrets

Ansible Vault is already in use and is not optional. `ansible.cfg` sets
`vault_password_file = .vault_password`, and the encrypted vault lives at
`inventory/group_vars/all/vault.yaml`, which is committed. The password file is gitignored, so
create it before running anything: see
[Create the Vault Password File](installation.md#create-the-vault-password-file).

Edit the vault through the control container, which already has the password file mounted:

```bash
docker compose run --rm ansible "ansible-vault edit inventory/group_vars/all/vault.yaml"
```

Vaulted variables are referenced from templates like any other variable. `roles/jenkins` is the
worked example: it templates `jenkins_admin_password` and `github_pat` into a `0600` `.env`
file on the host.

There is no `secrets.yaml` in this project. Creating one would have no effect, because nothing
loads it.
