# Jenkins Playbook

Deploys Jenkins CI server with GitHub integration, configured via
Jenkins Configuration as Code (JCasC).

## What It Does

- Builds a custom Jenkins image with plugins and Docker CLI baked in
- Configures Jenkins declaratively via JCasC (admin user, credentials, pipelines)
- Deploys via Docker Compose on port 8083
- Mounts the host Docker socket so pipelines can build/run containers
- Persists Jenkins data in a Docker volume

## Usage

```bash
make jenkins
```

Jenkins is also deployed as part of the full platform (`make lab`). See [Lab Playbook](lab.md).

## Access

- **Local**: `http://shadowlands:8083`
- **Public** (via Tailscale Funnel): `https://shadowlands.tail252efc.ts.net`

Login with the admin credentials stored in the encrypted vault.

## Architecture

```
GitHub (push / PR event)
    │
    │  webhook POST
    ▼
Tailscale Funnel (HTTPS port 443)
    │
    │  proxies to localhost:8083
    ▼
Jenkins container (shadowlands:8083)
    │
    │  clones repo, runs Jenkinsfile
    │  uses host Docker daemon via socket
    ▼
Docker daemon (shadowlands)
    │
    │  builds test image, runs tests
    ▼
Results reported back to GitHub commit status
```

## How It Works

1. **plugins.txt** lists required plugins with pinned versions
2. **Dockerfile** extends the official Jenkins image, copies the Docker CLI from `docker:cli`, and installs plugins via `jenkins-plugin-cli`
3. **JCasC** (`jenkins-casc.yaml.j2`) defines admin user, GitHub credentials, and multibranch pipeline jobs
4. **Ansible** copies files to `/opt/jenkins`, builds the custom image, renders secrets to `.env`, and starts the container
5. **Docker socket** is mounted into the container with the host's Docker GID added via `group_add`

## Configuration

**Plaintext variables** in `inventory/group_vars/all/vars.yaml`:

| Variable | Description |
|----------|-------------|
| `jenkins_image` | Base image (default: `jenkins/jenkins`) |
| `jenkins_version` | Jenkins version (default: `2.550`) |
| `jenkins_admin_user` | Admin username (default: `admin`) |
| `jenkins_url` | Public Jenkins URL for webhooks |
| `github_username` | GitHub username for repo access |
| `jenkins_repos` | List of GitHub repos to create multibranch pipelines for |

**Encrypted variables** in `inventory/group_vars/all/vault.yaml`:

| Variable | Description |
|----------|-------------|
| `jenkins_admin_password` | Admin login password |
| `github_pat` | GitHub Personal Access Token |

## Secrets Management

Secrets are encrypted with Ansible Vault. The vault password file (`.vault_password`)
sits in the workspace root and is listed in `.gitignore`.

```bash
# Edit encrypted secrets
docker-compose run --rm ansible "ansible-vault edit inventory/group_vars/all/vault.yaml"
```

The vault is decrypted automatically during playbook runs via the
`vault_password_file` setting in `ansible.cfg`. No `--ask-vault-pass` needed.

## Adding a New Project Pipeline

1. Add a `Jenkinsfile` to the project's repo root
2. Add the repo name to `jenkins_repos` in `inventory/group_vars/all/vars.yaml`
3. Run `make jenkins` to redeploy
4. Add a webhook in the GitHub repo: Settings > Webhooks
    - URL: `https://shadowlands.tail252efc.ts.net/github-webhook/`
    - Content type: `application/json`
    - Events: Pushes and Pull requests

## Manual Setup Steps

These are one-time steps that cannot be automated via Ansible:

### 1. Vault password file

Create `.vault_password` in the workspace root with your chosen password:

```bash
echo "your-vault-password" > .vault_password
```

Keep this password safe. If lost, you must recreate `vault.yaml` from scratch.

### 2. GitHub Personal Access Token

Create at: GitHub > Settings > Developer settings > Personal access tokens

**Classic token** scopes needed: `repo` (full) + `admin:repo_hook` (full)

Store in vault:

```bash
docker-compose run --rm ansible "ansible-vault edit inventory/group_vars/all/vault.yaml"
```

### 3. Tailscale Funnel

Enable Funnel in the Tailscale admin console (one-time):

```bash
sudo tailscale funnel --bg 8083
```

If Funnel is not enabled on your tailnet, the command will provide a link
to enable it. Funnel with `--bg` persists across reboots.

### 4. GitHub Webhooks

For each repo in `jenkins_repos`, add a webhook in GitHub:

- Settings > Webhooks > Add webhook
- URL: `https://shadowlands.tail252efc.ts.net/github-webhook/`
- Content type: `application/json`
- Events: Pushes and Pull requests

## Data Persistence

Jenkins data is stored in the `jenkins-data` Docker volume, mapped to
`/var/jenkins_home`. Data persists across container restarts and playbook re-runs.

## Removing Jenkins

```bash
# Stop and remove containers
ssh shadowlands "cd /opt/jenkins && docker compose down"

# Remove data (optional - deletes all jobs and config)
ssh shadowlands "docker volume rm jenkins_jenkins-data"

# Turn off Tailscale Funnel
ssh shadowlands "sudo tailscale funnel --https=443 off"
```
