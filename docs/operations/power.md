# Power Management

Control power state of the lab machine.

## Usage

```bash
make reboot    # Reboot the lab machine
make shutdown  # Shutdown the lab machine
```

## Implementation

Both commands use the same playbook with different power states:

```bash
ansible-playbook playbooks/power.yaml -e power_state=reboot
ansible-playbook playbooks/power.yaml -e power_state=shutdown
```

## Notes

- Requires `become: true` (sudo) on the target machine
- Connection will be lost immediately after shutdown
- Reboot waits for the machine to come back online before completing
