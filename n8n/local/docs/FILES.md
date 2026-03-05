# File Guide

## docker-compose.yml
Runs a single local n8n container with a mounted `./data` directory.

## .env.example
Baseline environment variables. Copy to `.env` before starting.

## scripts/setup-mac.sh
macOS helper script that checks Docker, creates `.env`, validates Compose, pulls the image, and starts n8n.

## .github/workflows/ci.yml
GitHub Actions workflow that validates the Compose file, starts n8n, checks `/healthz`, and uploads the starter files as an artifact.
