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

默认镜像包含 Elasticsearch、RocketMQ、MariaDB、Redis、XXL-Job 和各端运行所需内容；Kibana / Logstash 默认不打进镜像，避免首次构建额外下载数百 MB。需要调试链路时可显式开启：

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

如果本地已经存在输入的镜像，安装脚本会直接使用本地镜像，避免开发验证时因为未推送到镜像仓库而失败。需要强制拉取远端镜像时设置：

```bash
LILISHOP_FORCE_PULL=true ./docker/install/install-lilishop.sh
```

Windows PowerShell:

```powershell
$env:LILISHOP_FORCE_PULL="true"; .\docker\install\install-lilishop.ps1
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
