# Hermes Agent — Nous Research AI agent gateway (OpenAI-compatible API). Deploy on Railway with one click.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/bNpOxM)

Hermes Agent is Nous Research's self-hosted agent runtime: chat platforms, tools, and an OpenAI-compatible HTTP API on one gateway. This template ships the **official** `nousresearch/hermes-agent` image, digest-pinned, with the correct persistent volume and zero required deploy-time inputs.

## Why this template
- **Official image, digest-pinned:** `nousresearch/hermes-agent:v0.22.0@sha256:c69536a39e885b8943329bda68cdf44492458b96aa74a212239bde9d2aeb406a` (same as `stable`).
- **Correct persistence:** Railway volume at `/opt/data` (Hermes's real data path). Many other templates mount `/data`, which does **not** persist memory/config.
- **Zero deploy-time config:** `API_SERVER_KEY` is auto-generated; LLM provider keys (`OPENROUTER_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, etc.) are optional and added after deploy via Variables.
- **Public surface is the API:** OpenAI-compatible server on port `8642`. Dashboard stays off by default (official docs: basic auth is not meant for the public internet).

## Services
| Service | Source | Notes |
|---|---|---|
| hermes-agent | `nousresearch/hermes-agent:v0.22.0@sha256:c69536a39e885b8943329bda68cdf44492458b96aa74a212239bde9d2aeb406a` | port 8642, public domain, volume `/opt/data`, health `/health`, start `hermes gateway run` |

**Start command** (required — upstream default CMD is interactive CLI, which exits on Railway):
```
hermes gateway run
```
The repo `Dockerfile` sets the same `CMD`. Keep the image ENTRYPOINT (s6 `/init`).

## Variables
| Variable | Template value | Secret |
|---|---|---|
| PORT | `8642` | |
| API_SERVER_ENABLED | `true` | |
| API_SERVER_HOST | `0.0.0.0` | |
| API_SERVER_PORT | `8642` | |
| API_SERVER_KEY | `${{secret(48, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")}}` — Bearer token for `/v1` | yes |
| API_SERVER_CORS_ORIGINS | `*` | |
| OPENROUTER_API_KEY | `` (empty — set after deploy) | |
| ANTHROPIC_API_KEY | `` (empty — set after deploy) | |
| OPENAI_API_KEY | `` (empty — set after deploy) | |
| TELEGRAM_BOT_TOKEN | `` (empty — set after deploy) | |
| TELEGRAM_ALLOWED_USERS | `` (empty — set after deploy) | |
| HERMES_API_URL | `https://${{RAILWAY_PUBLIC_DOMAIN}}/v1` | |
| HERMES_ALLOW_ROOT_GATEWAY | `1` (Railway may run the entrypoint as root; s6 still drops to the hermes user for services) | |
| RAILWAY_RUN_UID | `0` (lets s6 chown `/opt/data` on first boot) | |
| HERMES_UID | `10000` | |
| HERMES_GID | `10000` | |

## After deploy
1. Open Railway → service → **Variables** and copy `API_SERVER_KEY`.
2. (Optional) Add an LLM key: `OPENROUTER_API_KEY`, `ANTHROPIC_API_KEY`, or `OPENAI_API_KEY`, then redeploy if needed.
3. Call the OpenAI-compatible API:

```bash
curl https://<your-domain>/v1/models \
  -H "Authorization: Bearer $API_SERVER_KEY"

curl https://<your-domain>/v1/chat/completions \
  -H "Authorization: Bearer $API_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"hermes-agent","messages":[{"role":"user","content":"Hello"}]}'
```

Health (no auth): `GET https://<your-domain>/health` → `200` `{"status":"ok","platform":"hermes-agent","version":"0.22.0"}`.

## Notes
- Template editor (unpublished): https://railway.com/workspace/templates/5d1812bb-64f4-4a4f-bb6b-9be81ffb3377
- Health: `/health` (Railway lifecycle). First boot can take a few minutes while config is seeded — healthcheck timeout is 300s.
- Volume `/opt/data` is the single source of truth for Hermes state — run **one replica** only.
- Do **not** mount `/data`; that path is incorrect for this image.
- Dashboard (`HERMES_DASHBOARD=1`) is optional and not enabled here; use SSH tunnel or private networking if you turn it on.
- Upstream: https://github.com/NousResearch/hermes-agent · Docs: https://hermes-agent.nousresearch.com/docs/user-guide/docker
