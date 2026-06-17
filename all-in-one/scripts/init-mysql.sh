#!/usr/bin/env bash
set -euo pipefail

initialized=false
if [ ! -d "$LILI_DATA/mysql/mysql" ]; then
  initialized=true
  echo "[all-in-one] 初始化 MariaDB 数据目录..."
  mariadb-install-db --user=mysql --datadir="$LILI_DATA/mysql" --skip-test-db >/dev/null
fi

mysqld_safe --datadir="$LILI_DATA/mysql" --socket=/run/mysqld/mysqld.sock --pid-file=/run/mysqld/mysqld.pid &
mysql_pid=$!

for _ in $(seq 1 60); do
  if mariadb-admin ping --socket=/run/mysqld/mysqld.sock --silent; then
    break
  fi
  sleep 1
done

if [ "$initialized" = "true" ]; then
  mariadb --socket=/run/mysqld/mysqld.sock <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS lilishop DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
FLUSH PRIVILEGES;
SQL

  if [ -f "$LILI_HOME/init/mysql/lilishop.sql" ]; then
    # 上游 SQL 以 MySQL 8 为准，MariaDB 不支持 utf8mb4_0900_ai_ci，导入时做兼容映射。
    sed 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' "$LILI_HOME/init/mysql/lilishop.sql" \
      | mariadb --socket=/run/mysqld/mysqld.sock -uroot -p"${MYSQL_ROOT_PASSWORD}" lilishop
  fi

  if [ -d "$LILI_HOME/init/mysql/patches" ]; then
    for patch_sql in "$LILI_HOME"/init/mysql/patches/*.sql; do
      [ -f "$patch_sql" ] || continue
      # 补丁用于对齐旧初始化库和当前代码字段，要求脚本本身可重复执行。
      sed 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' "$patch_sql" \
        | mariadb --socket=/run/mysqld/mysqld.sock -uroot -p"${MYSQL_ROOT_PASSWORD}" lilishop
    done
  fi
fi

sql_escape() {
  printf "%s" "$1" | sed "s/'/''/g"
}

make_bcrypt_md5_hash() {
  local env_name="$1"
  local default_value="$2"
  PASSWORD_VALUE="${!env_name:-$default_value}" python3 - <<'PY'
import bcrypt
import hashlib
import os

# 登录链路使用 BCrypt(MD5(明文密码))，这里保持和业务认证契约一致。
password = os.environ["PASSWORD_VALUE"].encode("utf-8")
md5_value = hashlib.md5(password).hexdigest().encode("utf-8")
print(bcrypt.hashpw(md5_value, bcrypt.gensalt(rounds=10)).decode("utf-8"))
PY
}

admin_hash="$(
  make_bcrypt_md5_hash LILI_ADMIN_PASSWORD "123456"
)"
store_password_hash="$(
  make_bcrypt_md5_hash LILI_STORE_PASSWORD "111111"
)"
admin_username="$(sql_escape "${LILI_ADMIN_USERNAME:-admin}")"
admin_hash_sql="$(sql_escape "$admin_hash")"
store_username="$(sql_escape "${LILI_STORE_USERNAME:-13011111111}")"
store_password_hash_sql="$(sql_escape "$store_password_hash")"

mariadb --socket=/run/mysqld/mysqld.sock -uroot -p"${MYSQL_ROOT_PASSWORD}" lilishop <<SQL
UPDATE li_admin_user
SET username='${admin_username}', password='${admin_hash_sql}'
WHERE id = 1337306110277476352
LIMIT 1;

UPDATE li_member
SET username='${store_username}', mobile='${store_username}', password='${store_password_hash_sql}'
WHERE id = 1376417684140326912
LIMIT 1;
SQL

mariadb-admin --socket=/run/mysqld/mysqld.sock -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
wait "$mysql_pid" || true
