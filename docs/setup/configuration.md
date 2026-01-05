# Configuration

## Inventory Configuration

The inventory file defines your lab infrastructure.

### Set Up Host Variables

After Fedora Server is installed, edit `inventory/host_vars/labserver.yaml` with your actual values:

```yaml
ansible_host: 192.168.1.100  # Your lab machine IP
ansible_user: blake           # Your username
```

This file is gitignored so your local config won't be committed.

## Ansible Configuration

The `ansible.cfg` file controls Ansible behavior:

- `inventory`: Points to your inventory file
- `host_key_checking`: Disabled for home lab convenience
- `retry_files_enabled`: Disabled to avoid clutter
- `become`: Enabled for sudo operations

## Service Configuration

Service-specific configuration will be documented as roles are created:

- Bootstrap configuration
- Docker configuration
- Taiga configuration
- GitLab configuration (future)

## Security Considerations

For a home lab environment:

- SSH key authentication is required
- Services initially accessible only on local network
- Firewall configured via bootstrap playbook
- Secrets should not be committed to git

### Managing Secrets

(To be implemented)

Consider using Ansible Vault for sensitive data:

```bash
ansible-vault create secrets.yaml
ansible-vault edit secrets.yaml
```
