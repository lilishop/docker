#!/usr/bin/env bash
set -euo pipefail

cd "${LILI_HOME}/uniapp"

export NODE_OPTIONS="${NODE_OPTIONS:---openssl-legacy-provider}"
export VUE_APP_API_BASE_URL="${LILI_H5_API_BASE_URL:-/api}"
export VUE_APP_WAP_URL="${LILI_H5_WAP_URL:-http://${LILI_HOST}:${LILI_HTTP_PORT}/h5}"
export VUE_APP_IM_WEB_URL="${LILI_H5_IM_WEB_URL:-http://${LILI_HOST}:${LILI_HTTP_PORT}/im}"
export VUE_APP_IM_WS_URL="${LILI_H5_IM_WS_URL:-ws://${LILI_HOST}:${LILI_HTTP_PORT}/lili/webSocket}"

exec ./node_modules/.bin/cross-env \
  NODE_ENV=development \
  UNI_INPUT_DIR=. \
  UNI_OUTPUT_DIR=unpackage/dist/dev/h5 \
  UNI_PLATFORM=h5 \
  ./node_modules/.bin/vue-cli-service uni-serve \
  --host 0.0.0.0 \
  --port "${LILI_H5_PORT}" \
  --public "${LILI_HOST}:${LILI_HTTP_PORT}"
