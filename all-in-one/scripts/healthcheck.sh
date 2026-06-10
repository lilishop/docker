#!/usr/bin/env bash
set -euo pipefail

curl -fsS "http://127.0.0.1:${LILI_API_PORT:-8080}/actuator/health" >/dev/null
curl -fsS "http://127.0.0.1/" >/dev/null
curl -fsS "http://127.0.0.1/h5/" >/dev/null
