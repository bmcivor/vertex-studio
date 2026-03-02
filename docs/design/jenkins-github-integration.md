# Jenkins + GitHub Integration Design

## Goal

Deploy Jenkins on shadowlands via Ansible, configured to automatically run
CI pipelines on vertex-block (and later vertex-studio) when pull requests
are opened or tags are pushed on GitHub.

## Architecture

```
GitHub (github.com/bmcivor/vertex-block)
    │
    │  webhook POST on push / PR event
    ▼
Tailscale Funnel (public HTTPS on port 443)
    │
    │  reverse-proxies to localhost:8083
    ▼
Jenkins container (shadowlands:8083)
    │
    │  clones repo, runs Jenkinsfile
    │  uses host Docker daemon via mounted socket
    ▼
Docker daemon (shadowlands)
    │
    │  builds test image, runs pytest
    ▼
Results reported back to GitHub commit status
```

---

## Current State

What already exists and works:

- Jenkins Ansible role builds a custom Docker image with plugins baked in
- Deploys via Docker Compose on port 8083
- Jenkinsfile exists in vertex-block (builds test image, runs pytest, cleans up)
- vertex-block Dockerfile has a `test` multi-stage target with dev deps + tests

What is broken or missing:

| Problem | Detail |
|---------|--------|
| Wrong volume path | Compose mounts `jenkins-data:/var/lib/jenkins` but the official image uses `/var/jenkins_home` |
| Useless volume | `jenkins-config:/etc/jenkins` serves no purpose with the official image |
| No Docker CLI | Jenkinsfile runs `docker build` / `docker run` but the CLI isn't installed in the Jenkins image |
| No Docker socket | Socket not mounted, so even with CLI, no connection to the daemon |
| No socket permissions | Jenkins user (UID 1000) won't have access to the Docker socket without group membership |
| Missing plugin | `github-branch-source` is required for GitHub multibranch pipelines but isn't in plugins.txt |
| No JCasC | No Configuration as Code - Jenkins has no admin user, no credentials, no jobs defined |
| No secrets management | No mechanism to pass passwords/tokens to Jenkins without committing them to git |
| No public ingress | GitHub can't reach Jenkins to deliver webhooks (private network) |

---

## Component Design

### 1. Plugin List

**File:** `roles/jenkins/files/plugins.txt`

Current plugins (user-verified versions):
```
configuration-as-code:2037.v8e5349845172
github:1.46.0
workflow-aggregator:608.v67378e9d3db_1
git:5.10.0
credentials:1490.ve7532596f1fd
job-dsl:3654.vdf58f53e2d15
```

Addition needed:
```
github-branch-source:1967.vdea_d580c1a_b_a_
```

**Why:** The `github-branch-source` plugin provides the `github {}` block inside
`branchSources {}` in Job DSL scripts. Without it, you cannot define a
GitHub-backed multibranch pipeline in JCasC. This is confirmed by the official
JCasC demo: https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/demos/jobs/multibranch-github.yaml

**Version source:** Jenkins plugin index (https://plugins.jenkins.io/github-branch-source/).
Requires minimum Jenkins 2.504.1 — compatible with our Jenkins 2.550.

### 2. Custom Docker Image

**File:** `roles/jenkins/templates/Dockerfile.j2`

Current state installs plugins only. Needs to also install the Docker CLI so
that Jenkinsfile `sh 'docker build ...'` commands have a binary to execute.

Implemented Dockerfile:
```dockerfile
FROM {{ jenkins_image }}:{{ jenkins_version }}

USER root

COPY --from=docker:cli /usr/local/bin/docker /usr/local/bin/docker

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

USER jenkins
```

**Why `COPY --from=docker:cli`:** The Debian `docker.io` package installs the
daemon and init scripts but not the CLI binary in Debian Trixie (the base of
Jenkins 2.550). Copying the CLI from Docker's official `docker:cli` image is
the reliable approach for containers that only need the client.

### 3. Docker Compose Configuration

**File:** `roles/jenkins/templates/docker-compose.yaml.j2`

Three problems to fix:

**a) Volume path**

The official `jenkins/jenkins` image sets `JENKINS_HOME=/var/jenkins_home`.
Source: https://github.com/jenkinsci/docker

Change: `jenkins-data:/var/lib/jenkins` → `jenkins-data:/var/jenkins_home`
Remove: `jenkins-config:/etc/jenkins` (unused)

**b) Docker socket mount**

Add volume: `/var/run/docker.sock:/var/run/docker.sock`

This lets the Docker CLI inside Jenkins talk to the host Docker daemon.

**c) Socket permissions via group_add**

The Docker socket on the host is owned by `root:docker` with a specific GID.
The Jenkins user (UID 1000) inside the container needs to be in a group with
the same GID.

Docker Compose supports `group_add` which adds the container process to
additional groups. It requires a numeric GID (not a group name).
Source: https://stackoverflow.com/questions/60056354

The GID varies per host, so it must be detected dynamically by Ansible:

```yaml
# In tasks/main.yaml
- name: Get Docker group GID
  ansible.builtin.command: getent group docker
  register: docker_group_info
  changed_when: false

- name: Set Docker GID fact
  ansible.builtin.set_fact:
    docker_gid: "{{ docker_group_info.stdout.split(':')[2] }}"
```

Then in docker-compose.yaml.j2:
```yaml
group_add:
  - "{{ docker_gid }}"
```

**Proposed full docker-compose.yaml.j2:**
```yaml
services:
  jenkins:
    image: "jenkins-custom:{{ jenkins_version }}"
    container_name: jenkins
    restart: unless-stopped
    ports:
      - "8083:8080"
    env_file:
      - .env
    environment:
      - CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs/jenkins-casc.yaml
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false
    volumes:
      - jenkins-data:/var/jenkins_home
      - ./jenkins-casc.yaml:/var/jenkins_home/casc_configs/jenkins-casc.yaml:ro
      - /var/run/docker.sock:/var/run/docker.sock
    group_add:
      - "{{ docker_gid }}"
    networks:
      - default

volumes:
  jenkins-data:

networks:
  default:
    name: jenkins-network
```

### 4. Secrets Management

**Problem:** Jenkins needs an admin password and a GitHub PAT. These can't be
committed to git in plaintext. Previous attempts with `--ask-vault-pass` broke
the `make lab` workflow because it required interactive input for non-Jenkins
playbooks too.

**Solution: `vault_password_file` in ansible.cfg**

How it works:

1. A file called `.vault_password` sits in the workspace root, containing just
   the vault password on a single line. This file is never committed (added to
   `.gitignore`).

2. `ansible.cfg` gets one new line: `vault_password_file = .vault_password`

3. Every Ansible command automatically uses this file for vault decryption.
   No `--ask-vault-pass` needed. No Makefile changes needed. Both `make jenkins`
   and `make lab` work unchanged.

**Why this works with the Docker-based Ansible setup:**

The vertex-studio workspace is mounted at `/app` inside the Ansible container
(defined in `docker-compose.yaml`: `volumes: - .:/app`). Ansible reads
`ansible.cfg` from the working directory (`/app`). The relative path
`.vault_password` resolves to `/app/.vault_password`, which exists because
it's part of the mounted workspace.

Source: https://stackoverflow.com/questions/48551369

**Files involved:**

`ansible.cfg` — add one line:
```ini
[defaults]
vault_password_file = .vault_password
```

`.gitignore` — add:
```
.vault_password
```

`inventory/group_vars/all/vault.yaml` — secrets file (encrypted):
```yaml
jenkins_admin_password: "the-actual-password"
github_pat: "ghp_xxxxxxxxxxxx"
```

`roles/jenkins/templates/env.j2` — rendered to `/opt/jenkins/.env` on shadowlands:
```
JENKINS_ADMIN_PASSWORD={{ jenkins_admin_password }}
GITHUB_PAT={{ github_pat }}
```

Permissions on the `.env` file: `0600` (only owner can read).

**Encryption workflow (run once, then whenever secrets change):**
```bash
# Create vault password file (one-time setup, never committed)
echo "your-chosen-vault-password" > .vault_password

# Create vault.yaml with your actual secrets, then encrypt it
docker-compose run --rm ansible "ansible-vault encrypt inventory/group_vars/all/vault.yaml"

# Later, to edit secrets
docker-compose run --rm ansible "ansible-vault edit inventory/group_vars/all/vault.yaml"
```

**Secret flow diagram:**
```
vault.yaml (encrypted in git)
    │
    │  Ansible decrypts at playbook runtime using .vault_password
    ▼
jenkins_admin_password, github_pat (Ansible variables)
    │
    │  Ansible templates env.j2
    ▼
/opt/jenkins/.env on shadowlands (plaintext, 0600 perms)
    │
    │  docker-compose reads .env automatically
    ▼
Environment variables inside Jenkins container
    │
    │  JCasC resolves ${JENKINS_ADMIN_PASSWORD} and ${GITHUB_PAT}
    ▼
Jenkins admin user + GitHub credential configured
```

### 5. JCasC (Jenkins Configuration as Code)

**File:** `roles/jenkins/templates/jenkins-casc.yaml.j2`

JCasC lets you define Jenkins configuration in YAML. On startup, Jenkins reads
the file and applies it — creating the admin user, storing credentials, and
setting up jobs.

**Requirements:**
- `configuration-as-code` plugin (in plugins.txt)
- `job-dsl` plugin (in plugins.txt) — required for the `jobs:` root element
- `github-branch-source` plugin (to be added) — required for `github {}` in branchSources
- `JAVA_OPTS=-Djenkins.install.runSetupWizard=false` — skips the setup wizard
  since JCasC handles all initial config
- `CASC_JENKINS_CONFIG` env var — tells Jenkins where to find the YAML file

Source for `jobs:` requiring job-dsl: https://github.com/jenkinsci/job-dsl-plugin/wiki/JCasC
Source for skip wizard: https://sharadchhetri.com/automate-jenkins-setup-wizard-docker-jcac

**Proposed JCasC template:**

Repos are defined as an explicit list in `all.yaml`. The JCasC Jinja2 template
loops over the list to generate one `multibranchPipelineJob` per repo. Adding
a new project is one line in `all.yaml`.

This uses the officially demonstrated and verified Job DSL syntax from:
https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/demos/jobs/multibranch-github.yaml

The GitHub Organization Folder approach (`organizationFolder`) was investigated
and rejected — it has a documented bug (JENKINS-54877) where branch discovery
traits require a fragile XML `configure` block workaround for GitHub.

```yaml
jenkins:
  systemMessage: "Managed by JCasC via vertex-studio"
  numExecutors: 2
  mode: NORMAL

  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "{{ jenkins_admin_user }}"
          password: "${JENKINS_ADMIN_PASSWORD}"

  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false

credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              scope: GLOBAL
              id: "github-pat"
              username: "{{ github_username }}"
              password: "${GITHUB_PAT}"
              description: "GitHub PAT"

unclassified:
  location:
    url: "{{ jenkins_url }}"

jobs:
{% for repo in jenkins_repos %}
  - script: >
      multibranchPipelineJob('{{ repo }}') {
        branchSources {
          github {
            id('{{ repo }}')
            scanCredentialsId('github-pat')
            repoOwner('{{ github_username }}')
            repository('{{ repo }}')
          }
        }
        orphanedItemStrategy {
          discardOldItems {
            numToKeep(5)
          }
        }
      }
{% endfor %}
```

**How secrets work in JCasC:**

`{{ jenkins_admin_user }}` and `{{ github_username }}` are Ansible template
variables — resolved when Ansible copies the file. These are not secrets.

`${JENKINS_ADMIN_PASSWORD}` and `${GITHUB_PAT}` are JCasC environment variable
references — resolved by Jenkins at startup from the container's environment
variables (which come from the `.env` file via docker-compose).

Source: https://jenkins-configuration-as-code.netlify.app/docs/secrets/

**Note on env vars for secrets:** The JCasC docs say env vars can leak in
Jenkins UI and logs, and recommend Docker secrets or Vault for production.
For a homelab on a private network, env vars are an acceptable tradeoff.
Docker secrets require Swarm mode which is overkill here.

### 6. Tailscale Funnel

**Purpose:** GitHub needs to reach Jenkins over the internet to deliver webhooks.
Jenkins is on a private network behind Tailscale. Funnel exposes a local service
publicly over HTTPS.

**Command:** `sudo tailscale funnel --bg 8083`

This creates a reverse proxy:
`https://shadowlands.tail252efc.ts.net` (port 443) → `localhost:8083`

(The tailnet name `tail252efc.ts.net` is visible in the vertex-studio
docker-compose.yaml DNS search configuration.)

**Persistence:** With the `--bg` flag, Funnel persists across reboots and
Tailscale restarts. Confirmed by official docs:
https://tailscale.com/kb/1311/tailscale-funnel

> "If you use the tailscale funnel command with the -bg flag, it runs
> persistently in the background until you turn it off. When you reboot
> the device or restart Tailscale from the command line, Funnel will
> automatically resume sharing."

**Allowed public ports:** 443, 8443, or 10000 only. Since we're using the
default (443), this is fine.

**Prerequisites that need manual verification:**
1. MagicDNS is enabled in Tailscale admin console
2. HTTPS certificates are enabled in Tailscale admin console
3. Funnel is enabled in the tailnet ACL policy
4. Tailscale on shadowlands is v1.38.3 or newer

To check: `sudo tailscale funnel status` on shadowlands. If Funnel isn't
enabled, the error message tells you exactly what to enable.

**Ansible task:**
```yaml
- name: Enable Tailscale Funnel for Jenkins
  ansible.builtin.command:
    cmd: tailscale funnel --bg 8083
  changed_when: true
```

**Variable in group_vars/all.yaml:**
```yaml
jenkins_url: "https://shadowlands.tail252efc.ts.net"
```

### 7. GitHub Personal Access Token

**Manual step — cannot be automated.**

Go to: GitHub → Settings → Developer settings → Personal access tokens

**Option A: Classic PAT (simpler)**
- Scopes: `repo` (full) + `admin:repo_hook` (full)
- `repo`: clone repos, report commit statuses
- `admin:repo_hook`: auto-register webhooks on repos

**Option B: Fine-grained PAT (more secure)**
- Repository access: select vertex-block (and vertex-studio later)
- Permissions: Contents (Read), Pull requests (Read), Commit statuses (Read & Write), Webhooks (Read & Write)

Classic is less setup. Fine-grained is scoped to specific repos only.

Once created, the token goes into `vault.yaml` as `github_pat`.

### 8. Webhook Registration

Two options:

**Option A (automatic):** Jenkins auto-registers webhooks via the
`github-branch-source` plugin when it scans the repository. Requires the
PAT to have webhook write permission (admin:repo_hook for classic, or
Webhooks Read & Write for fine-grained).

**Option B (manual):** Add webhook in GitHub repo settings:
- URL: `https://shadowlands.tail252efc.ts.net/github-webhook/`
- Content type: `application/json`
- Events: Pushes + Pull requests

Option A is preferred since the goal is automation.

---

## Variables Summary

**`inventory/group_vars/all/vars.yaml`** (plaintext, committed):
```yaml
jenkins_image: "jenkins/jenkins"
jenkins_version: "2.550"
jenkins_admin_user: "admin"
jenkins_url: "https://shadowlands.tail252efc.ts.net"
github_username: "bmcivor"
jenkins_repos:
  - vertex-block
```

**`inventory/group_vars/all/vault.yaml`** (encrypted, committed):
```yaml
jenkins_admin_password: "your-password"
github_pat: "ghp_your-token"
```

Note: `group_vars/all/` is a directory. Ansible loads every YAML file inside
it for the `all` group. This replaces the previous single `group_vars/all.yaml`
file.

---

## Ansible Tasks (full role)

**`roles/jenkins/tasks/main.yaml`:**
```yaml
---
- name: Create jenkins directory
  ansible.builtin.file:
    path: /opt/jenkins
    state: directory
    owner: "{{ ansible_user }}"
    group: docker
    mode: '0755'

- name: Get Docker group GID
  ansible.builtin.command: getent group docker
  register: docker_group_info
  changed_when: false

- name: Set Docker GID fact
  ansible.builtin.set_fact:
    docker_gid: "{{ docker_group_info.stdout.split(':')[2] }}"

- name: Copy plugins.txt
  ansible.builtin.copy:
    src: plugins.txt
    dest: /opt/jenkins/plugins.txt
    owner: "{{ ansible_user }}"
    group: docker
    mode: '0644'

- name: Copy Dockerfile
  ansible.builtin.template:
    src: Dockerfile.j2
    dest: /opt/jenkins/Dockerfile
    owner: "{{ ansible_user }}"
    group: docker
    mode: '0644'

- name: Build Jenkins
  ansible.builtin.command:
    cmd: docker build -t jenkins-custom:{{ jenkins_version }} .
    chdir: /opt/jenkins

- name: Copy JCasC configuration
  ansible.builtin.template:
    src: jenkins-casc.yaml.j2
    dest: /opt/jenkins/jenkins-casc.yaml
    owner: "{{ ansible_user }}"
    group: docker
    mode: '0644'

- name: Create .env file for secrets
  ansible.builtin.template:
    src: env.j2
    dest: /opt/jenkins/.env
    owner: "{{ ansible_user }}"
    group: docker
    mode: '0600'

- name: Copy docker-compose.yaml
  ansible.builtin.template:
    src: docker-compose.yaml.j2
    dest: /opt/jenkins/docker-compose.yaml
    owner: "{{ ansible_user }}"
    group: docker
    mode: '0644'

- name: Start Jenkins
  ansible.builtin.command:
    cmd: docker compose up -d --force-recreate
    chdir: /opt/jenkins

- name: Enable Tailscale Funnel for Jenkins
  ansible.builtin.command:
    cmd: tailscale funnel --bg 8083
  changed_when: true
```

---

## Implementation Order with POC Tests

| Step | Change | How to verify |
|------|--------|---------------|
| 1 | Add `github-branch-source` to plugins.txt | `make jenkins`, check build log shows plugin downloaded |
| 2 | Install Docker CLI in Dockerfile.j2 | `make jenkins`, then `ssh shadowlands "docker exec jenkins docker --version"` |
| 3 | Fix volumes + socket + group_add in compose + GID detection in tasks | `make jenkins`, then `ssh shadowlands "docker exec jenkins docker ps"` |
| 4 | Secrets: ansible.cfg + .gitignore + vault.yaml + env.j2 | Create `.vault_password`, encrypt vault, `make jenkins` succeeds without --ask-vault-pass |
| 5 | JCasC template + compose env vars | `make jenkins`, check Jenkins logs for "Configuration loaded", login with admin creds |
| 6 | Tailscale Funnel task + jenkins_url variable | `curl https://shadowlands.tail252efc.ts.net` returns Jenkins page |
| 7 | GitHub PAT (manual) + store in vault | Push to vertex-block, verify Jenkins triggers a build |

Each step is done independently. You review and approve before moving to the next.

---

## Open Questions

1. **Tailscale Funnel** — have you used it before? Need to check it's enabled
   in your tailnet ACL. Run `sudo tailscale funnel status` on shadowlands.

2. **Classic vs fine-grained PAT** — preference?

3. **Volume path change** — the fix means any data in the old `/var/lib/jenkins`
   volume is orphaned. Since this is a fresh setup, that should be fine?

4. **vertex-studio pipeline** — ansible linting on MR/tag. Part of this work
   or follow-up after vertex-block is proven?
