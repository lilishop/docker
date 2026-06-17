$ErrorActionPreference = "Stop"

function Ask($Label, $Default) {
  $value = Read-Host "$Label [$Default]"
  if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
  return $value.Trim()
}

function Ask-Bool($Label, $Default) {
  $value = Ask $Label $Default
  $normalized = $value.ToLowerInvariant()
  if ($normalized -in @("y", "yes", "1", "true", "on", "是")) { return "true" }
  return "false"
}

function Detect-Platform {
  if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq [System.Runtime.InteropServices.Architecture]::Arm64) {
    return "linux/arm64"
  }
  return "linux/amd64"
}

function Require-Docker {
  $docker = Get-Command docker -ErrorAction SilentlyContinue
  if (-not $docker) {
    throw "未检测到 docker 命令。请先安装 Docker Desktop。"
  }
  docker info *> $null
  if ($LASTEXITCODE -ne 0) {
    throw "Docker 未运行。请先启动 Docker Desktop。"
  }
}

function Env-OrDefault($Name, $Default) {
  $value = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
  return $value
}

function Image-Exists($ImageName) {
  docker image inspect $ImageName *> $null
  return $LASTEXITCODE -eq 0
}

function Pull-Image-IfNeeded($ImageName, $Platform) {
  # 默认面向发布镜像安装，优先拉取远端同名 tag；离线开发可设置 LILISHOP_FORCE_PULL=false 复用本地镜像。
  $forcePull = (Env-OrDefault "LILISHOP_FORCE_PULL" "true").ToLowerInvariant()
  if ($forcePull -in @("y", "yes", "1", "true", "on", "是")) {
    Write-Host "强制拉取镜像：$ImageName ($Platform)"
    docker pull --platform $Platform $ImageName
    return
  }

  if (Image-Exists $ImageName) {
    Write-Host "本地已存在镜像：$ImageName，按 LILISHOP_FORCE_PULL=false 跳过拉取。"
    return
  }

  Write-Host "开始拉取镜像：$ImageName ($Platform)"
  docker pull --platform $Platform $ImageName
}

Require-Docker

Write-Host ""
Write-Host "============================================================"
Write-Host "Lilishop All-In-One 单容器环境"
Write-Host "============================================================"
Write-Host "这个脚本会启动一个很重的单容器镜像，容器内包含 nginx、"
Write-Host "后端 lilishop-all、MariaDB(MySQL 协议兼容)、Redis、"
Write-Host "Elasticsearch、RocketMQ、XXL-Job、PC/商家/运营/IM 前端资源，"
Write-Host "以及容器内运行的 uni-app H5 服务。"
Write-Host ""
Write-Host "建议 Docker Desktop 资源：4+ CPU、12GB-16GB 内存、50GB+ 磁盘。"
Write-Host "首次启动会初始化数据库和索引，慢是正常的。"
Write-Host "这是本地体验/演示/低门槛私有试用包，不是生产高可用部署方式。"
Write-Host "============================================================"
Write-Host ""

$Image = Ask "镜像名称" (Env-OrDefault "LILISHOP_IMAGE" "ccr.ccs.tencentyun.com/lilishop/lilishop-all-in-one:lite")
$ContainerName = Ask "容器名称" (Env-OrDefault "LILISHOP_CONTAINER" "lilishop-all")
$Platform = Ask "镜像平台 linux/amd64 或 linux/arm64" (Detect-Platform)
$HostName = Ask "对外访问 IP/域名" "127.0.0.1"
$HttpPort = Ask "HTTP 访问端口" "80"
$MysqlPort = Ask "MySQL 兼容端口" "3306"
$RedisPort = Ask "Redis 端口" "6379"
$DataDir = Ask "数据持久化目录" (Join-Path $HOME "lilishop-data")
$MysqlPassword = Ask "数据库 root 密码" "lilishop"
$RedisPassword = Ask "Redis 密码" "lilishop"
$AdminUsername = Ask "初始化管理员账号" "admin"
$AdminPassword = Ask "初始化管理员密码" "123456"
$StoreUsername = Ask "初始化商家账号" "13011111111"
$StorePassword = Ask "初始化商家密码" "111111"
$EnableEs = "true"
Write-Host "Elasticsearch: true（后端搜索服务必需，完整环境固定启用）"
Write-Host "Kibana / Logstash 默认镜像不包含；如需启用，请使用 INCLUDE_KIBANA / INCLUDE_LOGSTASH 重新构建镜像。"
$EnableKibana = Ask-Bool "启用 Kibana（需要镜像已包含 Kibana）" "no"
$EnableLogstash = Ask-Bool "启用 Logstash（需要镜像已包含 Logstash）" "no"
$EnableDashboard = Ask-Bool "启用 RocketMQ Dashboard" "no"
$JavaOpts = Ask "后端 JVM 参数" "-Xms512m -Xmx1024m"
$EsJavaOpts = Ask "ES JVM 参数" "-Xms512m -Xmx512m"

New-Item -ItemType Directory -Force -Path $DataDir | Out-Null

$existing = docker ps -a --format "{{.Names}}" | Where-Object { $_ -eq $ContainerName }
if ($existing) {
  $replace = Ask-Bool "容器 $ContainerName 已存在，是否删除并重建" "yes"
  if ($replace -eq "true") {
    docker rm -f $ContainerName | Out-Null
  } else {
    Write-Host "已取消。"
    exit 0
  }
}

Pull-Image-IfNeeded $Image $Platform

Write-Host "启动单容器环境..."
docker run -d `
  --name $ContainerName `
  --restart unless-stopped `
  --platform $Platform `
  -p "${HttpPort}:80" `
  -p "${MysqlPort}:3306" `
  -p "${RedisPort}:6379" `
  -v "${DataDir}:/data" `
  -e "LILI_HOST=$HostName" `
  -e "LILI_HTTP_PORT=$HttpPort" `
  -e "MYSQL_ROOT_PASSWORD=$MysqlPassword" `
  -e "REDIS_PASSWORD=$RedisPassword" `
  -e "LILI_ADMIN_USERNAME=$AdminUsername" `
  -e "LILI_ADMIN_PASSWORD=$AdminPassword" `
  -e "LILI_STORE_USERNAME=$StoreUsername" `
  -e "LILI_STORE_PASSWORD=$StorePassword" `
  -e "ENABLE_ELASTICSEARCH=$EnableEs" `
  -e "ENABLE_KIBANA=$EnableKibana" `
  -e "ENABLE_LOGSTASH=$EnableLogstash" `
  -e "ENABLE_ROCKETMQ_DASHBOARD=$EnableDashboard" `
  -e "JAVA_OPTS=$JavaOpts" `
  -e "ES_JAVA_OPTS=$EsJavaOpts" `
  $Image

Write-Host ""
Write-Host "已启动。首次初始化可能需要几分钟。"
Write-Host "- 买家端: http://${HostName}:${HttpPort}/"
Write-Host "- 商家端: http://${HostName}:${HttpPort}/seller/"
Write-Host "- 运营端: http://${HostName}:${HttpPort}/manager/"
Write-Host "- IM: http://${HostName}:${HttpPort}/im/"
Write-Host "- H5: http://${HostName}:${HttpPort}/h5/"
Write-Host "- 统一后端: http://${HostName}:${HttpPort}/api/"
Write-Host ""
Write-Host "查看日志: docker logs -f $ContainerName"
Write-Host "查看进程: docker exec -it $ContainerName supervisorctl status"
Write-Host "数据目录: $DataDir"
