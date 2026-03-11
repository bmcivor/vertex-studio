# Docker Registry Investigation

Investigation into running Docker Registry locally for storing images built by Jenkins. Findings and assumptions documented; see Assumptions & Risks section.

---

## What We Have Today

- **Jenkins** on shadowlands, builds vertex-block test image, runs pytest, deletes image
- **vertex-block Dockerfile** has `test` and `prod` stages; only `test` is used
- **No prod image** is built or persisted
- **No git tag detection** in the Jenkinsfile

---

## Docker Registry (registry:2 / registry:3)

The official image. CNCF Distribution project. Docker Hub tags:

- `registry:2` — v2 API implementation (long-standing)
- `registry:3.0.0` / `registry:3.0` / `registry:latest` — v3.0.0 (April 2025); same digest as latest

**Assumption check:** Doc previously said "registry:2 remains the standard." Docker Hub now shows `registry:latest` = `registry:3.0.0`. For maximum compatibility, pin `registry:2` explicitly if you want the older v2 line; otherwise `registry:2` or `registry:3.0.0` both work. No breaking changes documented for basic HTTP use.

**Source:** https://hub.docker.com/_/registry  
**Docs:** https://docs.docker.com/registry/ (redirects to deprecated notice; config docs at docker-docs.uclv.cu and distribution GitHub)

### Requirements

| Requirement | Detail |
|-------------|--------|
| Docker | Must run on a host with Docker |
| Port | 5000 by default (configurable) |
| Storage | `/var/lib/registry` inside container; mount a volume for persistence |
| Filesystem | Standard filesystem works; btrfs is *not* required (Oracle doc referred to their specific setup) |
| Disk | 15–20GB+ recommended for non-trivial use |

### Basic Run (No Auth, HTTP)

```bash
docker run -d -p 5000:5000 \
  --restart=always \
  -v /opt/registry/data:/var/lib/registry \
  --name registry \
  registry:2
```

### Docker Daemon Configuration

Docker clients (including the host daemon used by Jenkins via the socket) treat non-HTTPS registries as insecure. You must add the registry to `insecure-registries` in `/etc/docker/daemon.json`:

```json
{
  "insecure-registries": ["shadowlands:5000"]
}
```

Then: `sudo systemctl restart docker`

**Why:** Docker expects HTTPS by default. For a local/private registry on HTTP, this is the standard approach.

**Security:** Insecure registries are vulnerable to MITM. Acceptable for isolated lab/private network; not for internet-exposed registries.

**Hostname vs IP:** Both work. `insecure-registries` accepts either (e.g. `shadowlands:5000` or `192.168.1.10:5000`).

**Docker 29+ caveat:** When Docker Engine 29+ uses the containerd image store (default on fresh installs), `insecure-registries` may be ignored. Push/pull fails with TLS errors despite the registry appearing in `docker info`. Bug: [docker/cli#6748](https://github.com/docker/cli/issues/6748). Workaround: set `"containerd-snapshotter": false` in daemon.json to use the legacy storage driver.

**POC result (shadowlands):** Docker 29.2.1. daemon.json exists (nvidia runtime only); no containerd-snapshotter override. Insecure-registries will likely need the workaround.

### Authentication (Optional)

Registry supports HTTP Basic Auth via htpasswd:

1. Generate htpasswd file (bcrypt):
   ```bash
   docker run --rm --entrypoint htpasswd httpd:2 -Bbn admin secretpassword > auth/htpasswd
   ```

2. Configure registry with env vars:
   ```
   REGISTRY_AUTH=htpasswd
   REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm
   REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd
   ```

3. Clients run `docker login shadowlands:5000` before push/pull.

**Caveat:** Over HTTP, credentials are sent in plaintext. TLS is recommended if using auth.

### TLS (Optional)

For HTTPS, you need a cert and key. Options:

- Self-signed cert (clients must trust it or use `insecure-registries` anyway)
- Let's Encrypt (requires public hostname)
- Tailscale Funnel (if exposing registry publicly)

For local-only use, HTTP + `insecure-registries` is typical.

### Configuration File

Registry can use a `config.yml` instead of env vars. Mount it:

```
-v /path/to/config.yml:/etc/docker/registry/config.yml
```

Example structure (from distribution repo):

- `version`: 0.1
- `log`: level, formatter
- `storage`: backend (filesystem, S3, etc.), rootdirectory
- `http`: addr, headers
- `auth`: htpasswd realm and path
- `health`: storage health check

Env vars override config using `REGISTRY_SECTION_OPTION` (e.g. `REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY`).

---

## Pushing from Jenkins

Jenkins runs `docker` commands via the host Docker socket. So:

- The **host** Docker daemon does the push
- The host must have `insecure-registries` configured
- Jenkins needs the registry URL in the image tag: `shadowlands:5000/vertex-block:v0.1.1`

### With Authentication

**Option A: `docker login` in pipeline**

```groovy
sh 'docker login -u $REGISTRY_USER -p $REGISTRY_PASS shadowlands:5000'
sh 'docker push shadowlands:5000/vertex-block:v0.1.1'
```

Credentials from Jenkins credentials store (Username/Password), injected as env vars.

**Option B: `withDockerRegistry` (Docker Pipeline plugin)**

```groovy
withDockerRegistry([credentialsId: 'registry-creds', url: 'http://shadowlands:5000']) {
    sh 'docker push shadowlands:5000/vertex-block:v0.1.1'
}
```

Requires **Docker Pipeline** plugin. Handles login/logout around the block.

**POC result:** No docker-related plugins in Jenkins. Add `docker-workflow` to plugins.txt if using `withDockerRegistry`.

### Without Authentication

If the registry has no auth, no login needed. Just tag and push.

---

## Image Naming

Format: `[registry-host]:[port]/[repository]/[image]:[tag]`

Examples:

- `shadowlands:5000/vertex-block:v0.1.1`
- `shadowlands:5000/vertex-block:latest`

The repository can be a simple name or a path (e.g. `myorg/vertex-block`). Registry doesn't enforce structure; it's just a namespace.

---

## Garbage Collection

Deleting a tag does not free disk space immediately. Registry keeps blob layers until garbage collection runs.

**Command:**
```bash
docker exec registry /bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml
```

**POC result:** Both registry:2 and registry:3.0.0 have the binary at `/bin/registry`.

**Flags:**
- `--delete-untagged`: Remove blobs not referenced by any manifest (required for effective cleanup in 2.7+)

**When:** Run periodically (cron) or after bulk tag deletion. Registry should be in read-only mode during GC for consistency (the command handles this).

**Automation:** No built-in retention policy. You'd need to:
1. Delete old tags via Registry API
2. Run garbage-collect

Or use a third-party tool/script for retention.

---

## What Would Need to Change

### 1. Deploy Registry

- Add Ansible role or tasks to deploy `registry:2` on shadowlands
- Port 5000 (POC: free on shadowlands)
- Persistent volume for `/var/lib/registry`
- Optional: config.yml, auth, TLS

### 2. Docker Daemon

- Add `insecure-registries` to `/etc/docker/daemon.json` on shadowlands
- Restart Docker daemon

### 3. Jenkinsfile (vertex-block)

- Use `when { buildingTag() }` to run prod build/push only for tag builds
- `TAG_NAME` env var is set automatically when build is triggered by a tag
- If tagged: build `prod` stage, tag image with `TAG_NAME`, push to registry
- If not tagged: current behaviour (test only, no push)

### 3b. JCasC: Enable Tag Discovery

**Finding:** Multibranch pipelines do not discover or build tags by default. You must enable "Discover tags" in the GitHub branch source configuration.

**Trait:** `gitHubTagDiscovery` (github-branch-source plugin; @Symbol added in JENKINS-45504).

**Structure assumption:** Current JCasC uses the Job DSL shorthand:

```groovy
branchSources {
  github {
    id('repo')
    scanCredentialsId('github-pat')
    repoOwner('...')
    repository('repo')
  }
}
```

The Job DSL built-in `github` shorthand (BranchSourcesContext) builds fixed XML and **does not support traits**. To add `gitHubTagDiscovery`, you must use the full form:

```groovy
branchSources {
  branchSource {
    source {
      github {
        id('repo')
        scanCredentialsId('github-pat')
        repoOwner('...')
        repository('repo')
        traits {
          gitHubTagDiscovery()
        }
      }
    }
  }
}
```

**Verify:** The full form is provided by the github-branch-source plugin's Job DSL extension. Confirm the plugin version (1967.vdea_d580c1a_b_a_) supports this. If the shorthand is the only form available in our Job DSL context, a `configure` block may be needed to inject the trait XML directly.

**Second assumption:** Discovering tags is not enough. The Branch API plugin does **not** build tags by default. Even with `gitHubTagDiscovery`, tag items may be created but not built. The **basic-branch-build-strategies** plugin provides `buildTags` to enable building tag discoveries. Not currently in plugins.txt. **Verify:** Does github-branch-source's tag discovery alone trigger builds, or do we need basic-branch-build-strategies?

### 4. Jenkins

- If using auth: add registry credentials to Jenkins (via JCasC or manually)
- If using `withDockerRegistry`: requires **Docker Pipeline** plugin (`docker-workflow`). Not currently in plugins.txt; would need to add it.
- Alternative: use `sh 'docker login ...'` with credentials from Jenkins secret store; no extra plugin.

### 5. Garbage Collection

- Decide on retention (e.g. keep last N tags per image)
- Cron job or Ansible task to run GC periodically

---

## Open Questions

1. **Auth** — Do we need it? If registry is only reachable on the lab network, maybe not.
2. **Tag source** — Jenkins multibranch: how do we get the git tag for the current commit? (`env.TAG_NAME` exists for tag builds; need to verify multibranch behaviour)
3. **Network** — Will anything other than shadowlands pull from the registry? If so, they need `insecure-registries` too, and network access to shadowlands:5000.

---

## Summary: Effort Estimate

| Task | Complexity |
|------|------------|
| Deploy registry container + volume | Low |
| Configure daemon.json | Low |
| Modify Jenkinsfile for tag detection + prod build + push | Medium |
| Add registry credentials to Jenkins (if auth) | Low |
| Set up garbage collection cron | Low–Medium |
| Documentation | Low |

**Total:** Roughly one small Ansible role + Jenkinsfile changes + daemon config. No external services or cloud dependencies.

---

## Assumptions & Risks (Review)

| Item | Status |
|------|--------|
| `insecure-registries` works with hostname | Verified: both hostname and IP accepted |
| `insecure-registries` works on Docker 29+ | **Risk:** shadowlands runs 29.2.1; workaround required (containerd-snapshotter: false) |
| `registry:2` vs `registry:3` | Clarified: both available; latest = 3.0.0; pin explicitly if desired |
| JCasC shorthand `github { }` supports traits | **Assumption:** No — use full `branchSource { source { github { traits { } } } }` form |
| Tag discovery alone triggers builds | **Unverified:** basic-branch-build-strategies may be required for tag builds |
| GC command path | **Verified:** `/bin/registry` in both registry:2 and registry:3.0.0 |
| Port 5000 free on shadowlands | **Verified:** Free |
| Docker Pipeline plugin | **Verified:** Not installed; add to plugins.txt if using `withDockerRegistry` |
