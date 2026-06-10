#!/usr/bin/env bash
set -euo pipefail

export LILI_HOME="${LILI_HOME:-/opt/lilishop}"
export LILI_DATA="${LILI_DATA:-/data}"
export LILI_HOST="${LILI_HOST:-127.0.0.1}"
export LILI_HTTP_PORT="${LILI_HTTP_PORT:-80}"
export LILI_API_PORT="${LILI_API_PORT:-8080}"
export LILI_H5_PORT="${LILI_H5_PORT:-10001}"
export MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-lilishop}"
export REDIS_PASSWORD="${REDIS_PASSWORD:-lilishop}"
export ENABLE_ELASTICSEARCH="${ENABLE_ELASTICSEARCH:-true}"
export ENABLE_KIBANA="${ENABLE_KIBANA:-false}"
export ENABLE_LOGSTASH="${ENABLE_LOGSTASH:-false}"
export ENABLE_ROCKETMQ_DASHBOARD="${ENABLE_ROCKETMQ_DASHBOARD:-false}"
export LILI_DEMO_SITE="${LILI_DEMO_SITE:-false}"

mkdir -p \
  "$LILI_DATA/mysql" \
  "$LILI_DATA/redis" \
  "$LILI_DATA/elasticsearch" \
  "$LILI_DATA/rocketmq/logs" \
  "$LILI_DATA/rocketmq/store" \
  "$LILI_DATA/xxl-job" \
  "$LILI_DATA/logs" \
  "$LILI_HOME/runtime"

chown -R mysql:mysql "$LILI_DATA/mysql"
chown -R elasticsearch:elasticsearch "$LILI_DATA/elasticsearch"

# 单镜像运行时依赖大量模板，启动时统一渲染，避免用户重新构建镜像才能换域名或密码。
# 只替换白名单变量，避免 nginx/logstash 等配置里的原生 $变量 被 envsubst 清空。
envsubst '${LILI_API_PORT} ${LILI_DATA} ${MYSQL_ROOT_PASSWORD} ${REDIS_PASSWORD} ${ENABLE_ELASTICSEARCH} ${LILI_DEMO_SITE}' < "$LILI_HOME/templates/application-runtime.yml.tpl" > "$LILI_HOME/runtime/application-runtime.yml"
envsubst '${LILI_API_PORT} ${LILI_H5_PORT}' < "$LILI_HOME/templates/nginx.conf.tpl" > /etc/nginx/nginx.conf
envsubst '${LILI_DATA} ${REDIS_PASSWORD}' < "$LILI_HOME/templates/redis.conf.tpl" > "$LILI_HOME/runtime/redis.conf"
envsubst '${LILI_DATA}' < "$LILI_HOME/templates/elasticsearch.yml.tpl" > "$LILI_HOME/elasticsearch/config/elasticsearch.yml"
envsubst '${LILI_DATA}' < "$LILI_HOME/templates/broker.conf.tpl" > "$LILI_HOME/runtime/broker.conf"
envsubst '${MYSQL_ROOT_PASSWORD}' < "$LILI_HOME/templates/xxl-job-application.properties.tpl" > "$LILI_HOME/runtime/xxl-job-application.properties"
envsubst < "$LILI_HOME/templates/logstash-springboot.conf.tpl" > "$LILI_HOME/runtime/logstash-springboot.conf"

"$LILI_HOME/scripts/render-frontend-config.sh"
"$LILI_HOME/scripts/init-mysql.sh"
"$LILI_HOME/scripts/render-supervisor-includes.sh"

exec "$@"
