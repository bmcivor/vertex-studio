# Local CI/CD Pipeline (Design)

## Goal

- **Trigger:** Tag a commit or merge to `main` on GitHub.
- **Result:** Builds and tests run on the lab box; eventually push artifacts to a private package repo (e.g. Nexus).
- **Constraint:** Code stays on GitHub as the remote; no migration to another Git host.

## Chosen Approach: GitHub + Jenkins on the Box

- **Source of truth:** GitHub (existing remotes unchanged).
- **CI server:** Jenkins (or similar) running on the lab server, alongside other vertex-studio services.
- **Flow:** GitHub sends webhooks (on push/tag) to Jenkins; Jenkins runs pipelines on the same machine (agent on the box), runs build/test, and later can push to a registry or Nexus.

### Why Jenkins (Option 4)

- You get **local management**: job definitions, credentials, plugins, and config live on your infra.
- No dependency on GitHub Actions runner model; you own the whole pipeline definition and execution environment.
- Familiarity with Jenkins reduces ramp-up.
- Webhook → job is a standard pattern; GitHub has built-in webhook support for “push” and “tag” events.

## What “Local Management” Gives You

- **Job/pipeline config** on the lab server (Jenkinsfile or job DSL), versioned in repos or managed in Jenkins.
- **Credentials** (GitHub token, registry credentials, Nexus) stored in Jenkins, not in GitHub secrets.
- **Plugins and tooling** (Docker, any build tools) installed on the runner/agent you control.
- **Visibility and logs** on your own Grafana/Loki stack if you wire Jenkins logs into it later.
- **No vendor lock-in** on the CI engine; you can swap or replicate elsewhere.

## High-Level Architecture

```
GitHub (source of truth)
  │
  │  push / tag event
  │  (webhook)
  ▼
Lab Server
  │
  ├─ Jenkins (CI server)
  │     └─ Agent / executor (same box or dedicated container)
  │
  ├─ Build context: clone from GitHub, build (e.g. Docker), test
  │
  └─ (Later) Push artifacts → private registry or Nexus
```

- GitHub repo → webhook URL points to Jenkins (e.g. `https://jenkins.yourlab.local/github-webhook/` or via Tailscale).
- Jenkins receives webhook, triggers pipeline (e.g. by branch/tag), checks out from GitHub, runs build and test.
- Runner/agent runs on the lab server so builds use local Docker, GPU if needed, etc.

## Phases (Planning)

1. **Phase 1 – Jenkins + GitHub**
   - Deploy Jenkins (Docker or native) on the lab server.
   - Configure GitHub webhook (push/tag) → Jenkins.
   - One or two pilot repos: on merge to `main` or on tag, trigger a simple build (e.g. `docker build` + optional test). No artifact publishing yet.

2. **Phase 2 – Build and test**
   - Pipelines for vertex-block, vertex-studio, or other Lab repos: build, test, maybe build Docker images.
   - Store images in a local registry or GitHub Container Registry (GHCR), depending on preference.

3. **Phase 3 – Private package repo (e.g. Nexus)**
   - Introduce Nexus (or similar) for private packages.
   - Jenkins pushes built artifacts/images to Nexus after successful build (e.g. on tag).

No code or playbooks in this doc; this is the architecture to implement in follow-up work (Ansible role for Jenkins, webhook setup, example Jenkinsfile in a repo).

## Open Decisions (to resolve when implementing)

- **Jenkins vs other:** Jenkins chosen for experience and local control; alternatives (Drone, Gitea Actions, etc.) could be revisited if requirements change.
- **Jenkins hostname/URL:** How GitHub reaches Jenkins (Tailscale, local DNS, or ngrok-style tunnel) affects webhook URL and firewall.
- **Secrets:** Where to store GitHub token and later Nexus/registry credentials (Jenkins credential store vs external vault).
- **Pilot repo:** Which repo to use for the first webhook → build pipeline (e.g. vertex-block or vertex-studio).

## References

- [GitHub webhooks](https://docs.github.com/en/webhooks)
- [Jenkins GitHub plugin](https://plugins.jenkins.io/github/) / [GitHub Branch Source](https://plugins.jenkins.io/github-branch-source/) for webhook and multibranch.
