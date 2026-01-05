# Troubleshooting

## Common Issues

### Ansible Connection Issues

**Problem**: `ansible all -m ping` fails

**Solutions**:
- Verify SSH keys are properly configured
- Check lab machine IP is correct in inventory
- Ensure SSH service is running on lab machine
- Test manual SSH connection first

### Docker Permission Issues

**Problem**: User cannot run docker commands

**Solution**: User needs to log out and back in after being added to docker group

### Container Won't Start

**Problem**: Docker container fails to start

**Steps**:
1. Check container logs: `docker logs <container-name>`
2. Verify port is not already in use: `sudo ss -tulpn | grep <port>`
3. Check disk space: `df -h`
4. Verify Docker service is running: `systemctl status docker`

### Firewall Blocking Access

**Problem**: Cannot access services from dev machine

**Solution**: Verify firewall rules allow required ports:

```bash
sudo firewall-cmd --list-all
```

## Getting Help

- Check container logs
- Review Ansible playbook output
- Verify service status with systemctl
- Check disk space and system resources
