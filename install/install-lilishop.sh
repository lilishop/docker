#!/usr/bin/env bash
set -euo pipefail

DEFAULT_IMAGE="${LILISHOP_IMAGE:-lilishop-all-in-one:dev}"
DEFAULT_CONTAINER="${LILISHOP_CONTAINER:-lilishop-all}"

tty_in="/dev/stdin"
if [ -t 0 ]; then
  tty_in="/dev/tty"
fi

say() {
  printf '%s\n' "$*"
}

prompt() {
  local label="$1"
  local default_value="$2"
  local answer
  printf '%s [%s]: ' "$label" "$default_value" > /dev/stderr
  IFS= read -r answer < "$tty_in" || answer=""
  if [ -z "$answer" ]; then
    printf '%s' "$default_value"
  else
    printf '%s' "$answer"
  fi
}

prompt_bool() {
  local label="$1"
  local default_value="$2"
  local answer
  printf '%s [%s]: ' "$label" "$default_value" > /dev/stderr
  IFS= read -r answer < "$tty_in" || answer=""
  answer="${answer:-$default_value}"
  case "$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')" in
    y|yes|1|true|on|是) printf 'true' ;;
    *) printf 'false' ;;
  esac
}

detect_platform() {
  case "$(uname -m)" in
    x86_64|amd64) printf 'linux/amd64' ;;
    arm64|aarch64) printf 'linux/arm64' ;;
    *) printf 'linux/amd64' ;;
  esac
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    say "未检测到 docker 命令。请先安装 Docker Desktop 或 Docker Engine。"
    exit 1
  fi
  if ! docker info >/dev/null 2>&1; then
    say "Docker 未运行。请先启动 Docker Desktop 或 Docker daemon。"
    exit 1
  fi
}

image_exists() {
  docker image inspect "$1" >/dev/null 2>&1
}

pull_image_if_needed() {
  local image="$1"
  local platform="$2"
  local force_pull="${LILISHOP_FORCE_PULL:-false}"

  case "$(printf '%s' "$force_pull" | tr '[:upper:]' '[:lower:]')" in
    y|yes|1|true|on|是)
      say "强制拉取镜像：${image} (${platform})"
      docker pull --platform "$platform" "$image"
      return
      ;;
  esac

  if image_exists "$image"; then
    say "本地已存在镜像：${image}，跳过拉取。需要强制更新可设置 LILISHOP_FORCE_PULL=true。"
    return
  fi

  say "开始拉取镜像：${image} (${platform})"
  docker pull --platform "$platform" "$image"
}

print_warning() {
  cat >&2 <<'EOF'

============================================================
Lilishop All-In-One 单容器环境
============================================================
这个脚本会启动一个“很重”的单容器镜像，容器内包含：
nginx、后端 lilishop-all、MariaDB(MySQL 协议兼容)、Redis、
Elasticsearch、RocketMQ、XXL-Job、PC/商家/运营/IM 前端资源，
以及容器内运行并由 nginx 代理的 uni-app H5 服务。

请尽量给 Docker Desktop 分配更大的资源：
- CPU: 建议 4 核以上
- 内存: 最低 8GB，建议 12GB - 16GB
- 磁盘: 最低 30GB，建议 50GB+

首次启动会初始化数据库和索引，慢是正常的。
这是本地体验/演示/低门槛私有试用包，不是生产高可用部署方式。
数据会挂载到你输入的目录；删除该目录会导致数据丢失。
============================================================

EOF
}

main() {
  require_docker
  print_warning

  local platform host http_port api_port mysql_port redis_port data_dir image container_name
  local mysql_password redis_password admin_username admin_password enable_es enable_kibana enable_logstash enable_dashboard
  local java_opts es_java_opts

  platform="$(prompt "镜像平台 linux/amd64 或 linux/arm64" "$(detect_platform)")"
  image="$(prompt "镜像名称" "$DEFAULT_IMAGE")"
  container_name="$(prompt "容器名称" "$DEFAULT_CONTAINER")"
  host="$(prompt "对外访问 IP/域名" "127.0.0.1")"
  http_port="$(prompt "HTTP 访问端口" "80")"
  api_port="$(prompt "后端 API 端口" "8080")"
  mysql_port="$(prompt "MySQL 兼容端口" "3306")"
  redis_port="$(prompt "Redis 端口" "6379")"
  data_dir="$(prompt "数据持久化目录" "$HOME/lilishop-data")"
  mysql_password="$(prompt "数据库 root 密码" "lilishop")"
  redis_password="$(prompt "Redis 密码" "lilishop")"
  admin_username="$(prompt "初始化管理员账号" "admin")"
  admin_password="$(prompt "初始化管理员密码" "123456")"
  enable_es="true"
  say "Elasticsearch: true（后端搜索服务必需，完整环境固定启用）"
  say "Kibana / Logstash 默认镜像不包含；如需启用，请使用 INCLUDE_KIBANA / INCLUDE_LOGSTASH 重新构建镜像。"
  enable_kibana="$(prompt_bool "启用 Kibana（需要镜像已包含 Kibana）" "no")"
  enable_logstash="$(prompt_bool "启用 Logstash（需要镜像已包含 Logstash）" "no")"
  enable_dashboard="$(prompt_bool "启用 RocketMQ Dashboard" "no")"
  java_opts="$(prompt "后端 JVM 参数" "-Xms512m -Xmx1024m")"
  es_java_opts="$(prompt "ES JVM 参数" "-Xms512m -Xmx512m")"

  mkdir -p "$data_dir"

  if docker ps -a --format '{{.Names}}' | grep -Fxq "$container_name"; then
    local replace
    replace="$(prompt_bool "容器 $container_name 已存在，是否删除并重建" "yes")"
    if [ "$replace" = "true" ]; then
      docker rm -f "$container_name" >/dev/null
    else
      say "已取消。"
      exit 0
    fi
  fi

  pull_image_if_needed "$image" "$platform"

  say "启动单容器环境..."
  docker run -d \
    --name "$container_name" \
    --restart unless-stopped \
    --platform "$platform" \
    -p "$http_port:80" \
    -p "$api_port:$api_port" \
    -p "$mysql_port:3306" \
    -p "$redis_port:6379" \
    -v "$data_dir:/data" \
    -e "LILI_HOST=$host" \
    -e "LILI_HTTP_PORT=$http_port" \
    -e "LILI_API_PORT=$api_port" \
    -e "MYSQL_ROOT_PASSWORD=$mysql_password" \
    -e "REDIS_PASSWORD=$redis_password" \
    -e "LILI_ADMIN_USERNAME=$admin_username" \
    -e "LILI_ADMIN_PASSWORD=$admin_password" \
    -e "ENABLE_ELASTICSEARCH=$enable_es" \
    -e "ENABLE_KIBANA=$enable_kibana" \
    -e "ENABLE_LOGSTASH=$enable_logstash" \
    -e "ENABLE_ROCKETMQ_DASHBOARD=$enable_dashboard" \
    -e "JAVA_OPTS=$java_opts" \
    -e "ES_JAVA_OPTS=$es_java_opts" \
    "$image"

  cat <<EOF

已启动。首次初始化可能需要几分钟。

访问地址：
- 买家端: http://$host:$http_port/
- 商家端: http://$host:$http_port/seller/
- 运营端: http://$host:$http_port/manager/
- IM: http://$host:$http_port/im/
- H5: http://$host:$http_port/h5/
- API: http://$host:$api_port/

常用命令：
- 查看日志: docker logs -f $container_name
- 查看进程: docker exec -it $container_name supervisorctl status
- 停止服务: docker stop $container_name
- 删除容器: docker rm -f $container_name

数据目录：$data_dir
EOF
}

main "$@"
