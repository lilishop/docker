#!/usr/bin/env bash
set -e

# compose 把 docker/init/mysql 挂到 /docker-entrypoint-initdb.d。MySQL entrypoint
# 按 glob 执行：数字文件先于字母，因此本脚本排在 lilishop.sql **之前**。
# 每个 patches/*.sql 必须对「基表尚不存在」和「基表已存在」两种状态都安全。

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
