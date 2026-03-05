# n8n Local Starter

A small starter repo for running **n8n locally** on **Mac** or **Linux** using Docker Compose.

It includes:
- a local `docker-compose.yml`
- a sample `.env.example`
- a Mac setup script
- GitHub Actions to validate the Compose config and package the starter files

## What this setup runs

- `n8n` on `http://localhost:5678`
- persistent local data in `./data`

This follows n8n's documented Docker and Docker Compose self-hosting paths, which are the recommended local starting points for most users. It also uses the `stable` image tag, which n8n documents as the production-oriented release channel rather than `beta`. See:
- n8n Docker docs
- n8n Docker Compose docs
- n8n release notes

## Quick start

```bash
cp .env.example .env
./scripts/setup-mac.sh
```

Then open:

`http://localhost:5678`

## Files

- `docker-compose.yml` — local n8n service
- `.env.example` — environment variables to copy into `.env`
- `scripts/setup-mac.sh` — installs/checks Docker Desktop, prepares folders, starts n8n on macOS
- `.github/workflows/ci.yml` — validates the Compose file and packages the repo as an artifact

## Manual start

```bash
cp .env.example .env
mkdir -p data

docker compose up -d
```

## Stop

```bash
docker compose down
```

## Update

```bash
docker compose pull
docker compose up -d
```

n8n recommends updating self-hosted instances regularly and reviewing release notes before larger upgrades.

## Local webhook notes

For simple local testing, use the webhook URLs shown inside n8n and call them from your machine.

Example:

```bash
curl -X POST http://localhost:5678/webhook-test/your-test-path \
  -H "Content-Type: application/json" \
  -d '{"message":"hello"}'
```

For public SaaS webhooks, `localhost` is not publicly reachable. Use a tunnel or deploy n8n behind a public URL.

## macOS prerequisites

- Docker Desktop for Mac installed and running
- a writable local project directory

## Notes

- This starter does **not** include PostgreSQL. It is intentionally small for local development.
- Credentials are encrypted by n8n. Keep your `N8N_ENCRYPTION_KEY` stable.
- The data directory `./data` is mounted into the container so your local state persists across restarts.

## Suggested next step

If you want, add a second Compose file for PostgreSQL so local development more closely matches production.
