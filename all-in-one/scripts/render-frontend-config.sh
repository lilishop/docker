#!/usr/bin/env bash
set -euo pipefail

render_config() {
  local app="$1"
  local prefix="$2"
  local config_file="$LILI_HOME/runtime/frontend-config-$app.js"

  LILI_API_PREFIX="$prefix" envsubst '${LILI_HOST} ${LILI_HTTP_PORT} ${LILI_API_PREFIX}' < "$LILI_HOME/templates/frontend-config.js.tpl" > "$config_file"
  if [ -d "$LILI_HOME/www/$app" ]; then
    cp "$config_file" "$LILI_HOME/www/$app/config.js"
    cp "$config_file" "$LILI_HOME/www/$app/config.local.js" 2>/dev/null || true
  fi
}

render_config buyer ""
render_config seller "/store"
render_config manager "/manager"
render_config im ""
render_config h5 ""
