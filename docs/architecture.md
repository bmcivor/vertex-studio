# Architecture

## Overview

Vertex Studio is a self-hosted development platform designed to provide a complete software development lifecycle infrastructure at home.

## Components

### Platform Layer

- **Ansible**: Infrastructure as code for reproducible deployments
- **Docker**: Container runtime for all services
- **Traefik** (planned): Reverse proxy with automatic TLS

### Development Layer

- **GitLab** (planned): Self-hosted Git with integrated CI/CD
- **Taiga**: Project management and issue tracking
- **Local LLM** (planned): Development assistance using 3090 GPU

## Network Architecture

```
Internet
  │
  └─> Router/Firewall
        │
        └─> Lab Server (Fedora Server)
              │
              ├─> Taiga (port 9000)
              ├─> MkDocs (port 8080)
              ├─> GitLab (port 8080) - planned
              └─> Local LLM (port 11434) - planned
```

## Design Decisions

### Docker Compose First

**Decision**: Start with Docker Compose, design for k3s migration later.

**Rationale**: 
- Faster initial implementation
- Lower operational complexity
- Easier to learn and debug
- Migration path documented for future

### Single Node Initially

**Decision**: Deploy on single lab machine initially.

**Rationale**:
- Simplifies initial setup
- Hardware with 3090 can handle workload
- Multi-node can be added later if needed

### Internal Access Only

**Decision**: No external internet exposure initially.

**Rationale**:
- Simpler security model
- Focus on functionality first
- External access via VPN can be added later
