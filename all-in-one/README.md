# Lilishop All-In-One 单镜像单容器

这个目录用于构建一个单容器全量体验镜像。镜像内包含：

- nginx
- lilishop-all 后端
- buyer / seller / manager / im 前端资源
- 容器内 uni-app H5 开发服务（nginx 代理到 `/h5/`）
- MariaDB（MySQL 协议兼容）
- Redis
- Elasticsearch
- RocketMQ nameserver / broker
- XXL-Job Admin
- 可选 Kibana / Logstash / RocketMQ Dashboard

访问口径：All-In-One 只暴露统一 HTTP 入口。买家 PC、商家端、运营端、IM Web、H5 以及后端 `/api/` 均通过同一个域名和端口访问，不再额外暴露各端独立 API 端口。

数据库口径：常规部署和项目技术栈仍以 MySQL 为准；本镜像内置 MariaDB 只是为了在单容器本地体验中提供 MySQL 协议兼容数据库，不代表生产部署或常规 `docker-compose` 部署已经切换为 MariaDB。

## 构建

需要在 `opensource` 聚合目录执行，保证构建上下文能访问 `lilishop`、`lilishop-ui`、`lilishop-uniapp` 和 `docker`。

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -f docker/all-in-one/Dockerfile \
  -t lilishop-all-in-one:dev \
  .
```

本地只构建当前平台：

```bash
docker build \
  -f docker/all-in-one/Dockerfile \
  -t lilishop-all-in-one:dev \
  .
```

默认镜像包含 Elasticsearch、RocketMQ、MariaDB、Redis、XXL-Job 和各端运行所需内容；其中 MariaDB 按 MySQL 协议兼容数据库使用。Kibana / Logstash 默认不打进镜像，避免首次构建额外下载数百 MB。需要调试链路时可显式开启：

```bash
docker build \
  --build-arg INCLUDE_KIBANA=true \
  --build-arg INCLUDE_LOGSTASH=true \
  -f docker/all-in-one/Dockerfile \
  -t lilishop-all-in-one:dev \
  .
```

## 安装脚本

macOS / Linux:

```bash
./docker/install/install-lilishop.sh
```

Windows PowerShell:

```powershell
.\docker\install\install-lilishop.ps1
```

脚本会提示输入域名/IP、端口、密码、数据目录和组件开关，然后执行一个 `docker run` 启动完整环境。

默认镜像为 `ccr.ccs.tencentyun.com/lilishop/lilishop-all-in-one:lite`。安装脚本默认会在每次执行时拉取远端最新同名镜像，避免本地已有旧 tag 时继续启动旧版本。

如果需要使用本地自行构建的开发镜像，可显式指定本地镜像并关闭强制拉取：

```bash
LILISHOP_IMAGE=lilishop-all-in-one:dev LILISHOP_FORCE_PULL=false ./docker/install/install-lilishop.sh
```

Windows PowerShell:

```powershell
$env:LILISHOP_IMAGE="lilishop-all-in-one:dev"; $env:LILISHOP_FORCE_PULL="false"; .\docker\install\install-lilishop.ps1
```

Elasticsearch 是后端搜索与日志索引依赖，安装脚本固定启用；Kibana、Logstash、RocketMQ Dashboard 是可选附加组件。Kibana / Logstash 只有在构建镜像时开启对应 `INCLUDE_*` 参数后才能在运行时启用。

## 资源建议

这个镜像故意把所有服务放进一个容器，目的是降低启动门槛，不是生产高可用部署方式。

- CPU：建议 4 核以上
- 内存：最低 8GB，建议 12GB - 16GB
- 磁盘：最低 30GB，建议 50GB+

首次启动会初始化数据库和索引，慢是正常的。
如果复用已有数据目录，请继续使用原来的 `MYSQL_ROOT_PASSWORD`；数据库 root 密码已经写入数据目录，脚本无法自动猜测旧密码。

## 常用命令

```bash
docker logs -f lilishop-all
docker exec -it lilishop-all supervisorctl status
docker stop lilishop-all
docker rm -f lilishop-all
```

## 平台兼容

镜像按 `linux/amd64` 和 `linux/arm64` 构建：

- Intel Mac / 大多数 Windows PC：`linux/amd64`
- Apple Silicon Mac / ARM Windows：`linux/arm64`

如果目标环境拉不到对应架构镜像，安装脚本会提示用户选择平台；也可以手动设置 `--platform`。
