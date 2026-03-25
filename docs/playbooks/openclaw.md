# OpenClaw Playbook

Deploys the [OpenClaw](https://docs.openclaw.ai/) gateway in Docker against the **host** [Ollama](ollama.md) service. Inference stays on the lab machine; the Control UI is reachable on the Tailscale hostname when `openclaw_gateway_bind` is `tailnet` or `lan`.

## Prerequisites

1. **Ollama** must be installed and running first (same host, default `http://127.0.0.1:11434`).

   ```bash
   make ollama
   ```

2. **Tailscale** (recommended) — if you use `openclaw_gateway_bind: tailnet`, the gateway listens on the Tailscale interface. Install Tailscale before OpenClaw if you rely on that bind mode.

## Usage

```bash
make openclaw
```

## Lab playbook

`playbooks/lab.yaml` does **not** include OpenClaw. Deploy it explicitly with `make openclaw` when you want the gateway on the lab host.

## Configuration

**Plaintext** — `inventory/group_vars/all/vars.yaml`:

| Variable | Purpose |
| -------- | ------- |
| `openclaw_image` | Container image (default `ghcr.io/openclaw/openclaw`) |
| `openclaw_version` | Image tag; change to upgrade, then re-run `make openclaw` |
| `openclaw_gateway_port` | Gateway HTTP/WebSocket port (default `18789`) |
| `openclaw_gateway_bind` | `loopback`, `lan`, `tailnet`, or `auto` — see [OpenClaw gateway docs](https://docs.openclaw.ai/gateway/configuration-reference#gateway) |

**Encrypted** — `inventory/group_vars/all/vault.yaml` (same vault as Jenkins; edit with `ansible-vault edit` or `docker-compose run --rm ansible "ansible-vault edit …"` per [Jenkins playbook](jenkins.md#secrets-management)):

| Variable | Purpose |
| -------- | ------- |
| `openclaw_gateway_auth_token` | Gateway Control UI shared secret (required when bind is not loopback) |

The role uses **`network_mode: host`** so the container can reach Ollama on `127.0.0.1:11434`. The container sets `OLLAMA_API_KEY=ollama-local` so OpenClaw can discover Ollama models without pointing at the OpenAI-compatible `/v1` URL (which breaks tool calling for Ollama).

The default model is `ollama/llava`, matching the Ollama playbook.

## Control UI

After deploy, open `http://127.0.0.1:18789` on the host or `http://shadowlands.tail252efc.ts.net:18789` from another machine on the tailnet (see [Services](../services.md)). Sign in with the configured gateway token.

## Firewall

If you use `bind: lan` and a host firewall blocks the gateway port, allow TCP `18789` (or your chosen port) for Tailscale or trusted interfaces.

## Troubleshooting

- **Gateway will not start** — Run `openclaw doctor` inside the container (see upstream docs) or check container logs: `docker logs openclaw`.
- **Strict config validation** — Invalid keys or types in `openclaw.json` prevent startup. Edit `/opt/openclaw/config/openclaw.json` on the host and restart: `cd /opt/openclaw && docker compose restart`.
- **`tailnet` bind fails** — Ensure Tailscale is up on the host. Alternatively set `openclaw_gateway_bind` to `lan` or `loopback` (loopback is host-local only unless you use SSH port forwarding).
- **No models** — Confirm Ollama is running and `llava` is pulled (`ollama list` on the host).
