#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    err "Required command not found: $1"
    exit 1
  }
}

info "Checking macOS..."
if [[ "$(uname -s)" != "Darwin" ]]; then
  err "This script is for macOS only."
  exit 1
fi

require_cmd docker

if [[ ! -f .env ]]; then
  info "No .env file found. Creating one from .env.example"
  cp .env.example .env
fi

mkdir -p data

info "Checking whether Docker Desktop is running..."
if ! docker info >/dev/null 2>&1; then
  warn "Docker does not appear to be running."
  warn "Please start Docker Desktop, then rerun this script."
  exit 1
fi

info "Validating docker compose configuration..."
docker compose config >/dev/null

info "Pulling the latest n8n stable image..."
docker compose pull

info "Starting n8n..."
docker compose up -d

info "Waiting briefly for the container to initialize..."
sleep 5

if docker compose ps | grep -q n8n-local; then
  info "n8n is starting. Open: http://localhost:5678"
else
  err "Container did not start as expected. Check logs with: docker compose logs -f"
  exit 1
fi
