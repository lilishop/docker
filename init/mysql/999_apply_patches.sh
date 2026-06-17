#!/usr/bin/env bash
set -e

patch_dir="/docker-entrypoint-initdb.d/patches"
database="${MYSQL_DATABASE:-lilishop}"

if [ ! -d "$patch_dir" ]; then
  exit 0
fi

for patch_sql in "$patch_dir"/*.sql; do
  [ -f "$patch_sql" ] || continue
  echo "[mysql-init] applying patch: $patch_sql"
  docker_process_sql --database="$database" < "$patch_sql"
done
