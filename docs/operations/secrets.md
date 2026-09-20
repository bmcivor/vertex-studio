# Secrets

All secrets live in one encrypted file, `inventory/group_vars/all/vault.yaml`, which is
committed. The password that decrypts it is in `.vault_password`, which is gitignored and has
to exist before any playbook runs — see
[Create the Vault Password File](../setup/installation.md#create-the-vault-password-file).

`ansible.cfg` sets `vault_password_file`, so nothing prompts for a password.

## Editing the vault

```bash
docker compose run --rm ansible "ansible-vault edit inventory/group_vars/all/vault.yaml"
```

The repository is bind-mounted into the container, so the edit lands on the real file. The
image sets `EDITOR=vim`; without an editor present `ansible-vault edit` fails before it opens
anything.

Do not decrypt the file in place to edit it. This repository is public, and a decrypted
`vault.yaml` sitting in the working tree is one careless commit away from being published.

## Rotating the GitHub token

Jenkins authenticates to GitHub with a classic personal access token. It expires, and when it
does Jenkins fails quietly — see
[branch indexing fails with 401](troubleshooting.md#jenkins-branch-indexing-fails-with-401-bad-credentials).

### Where the value goes

```
vault.yaml (github_pat)
    │  ansible templates it
    ▼
roles/jenkins/templates/env.j2  →  /opt/jenkins/.env  (GITHUB_PAT, mode 0600)
    │  docker compose reads it
    ▼
jenkins-casc.yaml.j2  →  the "github-pat" credential in Jenkins
```

Nothing reads the vault at runtime. The value is baked into `/opt/jenkins/.env` when the
playbook runs, so **changing the vault alone has no effect** — the playbook has to run again.

### Steps

1. **Regenerate the token.** GitHub → avatar → **Settings** → **Developer settings** →
   **Personal access tokens** → **Tokens (classic)**. Open the existing token and use
   **Regenerate token** rather than creating a new one, so the scopes carry over.

   Scopes required: **`repo`** and **`admin:repo_hook`**. `repo` covers private repositories,
   which several of the indexed ones are. `admin:repo_hook` lets Jenkins manage webhooks.

   Set an expiry deliberately. The token expiring unnoticed is the failure this page exists for.

2. **Put it in the vault.** Replace the `github_pat` value using the command above.

3. **Deploy.** This re-renders `.env` and restarts Jenkins:

   ```bash
   make jenkins
   ```

4. **Verify before assuming it worked.** In Jenkins, open any multibranch job →
   **Scan Repository Now** → **Scan Repository Log**. Branch indexing should find branches
   rather than returning 401.

   If it still fails, check `/opt/jenkins/.env` on the host actually changed. A stale `.env`
   means the playbook did not re-render it.

## What else is in the vault

| Variable | Used by |
|----------|---------|
| `github_pat` | Jenkins, to index repositories and manage webhooks |
| `jenkins_admin_password` | The Jenkins admin account, via JCasC |

Both are rendered into `/opt/jenkins/.env` at mode `0600`. Neither is readable from a
playbook run's output.
