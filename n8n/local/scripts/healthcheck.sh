#!/usr/bin/env bash
set -euo pipefail
curl -fsS http://localhost:5678/healthz >/dev/null
