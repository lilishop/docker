# Lilishop(PickMall) 开源商城系统

[![GitHub Stars](https://img.shields.io/github/stars/hongyehuicheng/lilishop.svg?style=social&logo=github)](https://github.com/hongyehuicheng/lilishop)
[![Gitee Stars](https://gitee.com/beijing_hongye_huicheng/lilishop/badge/star.svg?theme=dark)](https://gitee.com/beijing_hongye_huicheng/lilishop)
<p align="right">
  简体中文 | <a href="./README.en.md">English</a>
</p>

## All-In-One 本地体验说明

`master` 分支的 All-In-One 是“完整单容器本地体验/验证形态”，默认镜像名为 `ccr.ccs.tencentyun.com/lilishop/lilishop-all-in-one:lite`。安装脚本默认会在每次执行时拉取远端最新同名镜像；如需使用本地开发镜像，可通过 `LILISHOP_IMAGE` 指定并设置 `LILISHOP_FORCE_PULL=false`。

该形态会把多个运行组件放进一个容器，降低首次启动和演示门槛。它包含 nginx、`lilishop-all` 后端、买家 PC、商家端、运营端、IM Web 前端资源、uni-app H5 运行服务、MariaDB、Redis、Elasticsearch、RocketMQ 和 XXL-Job Admin；Kibana、Logstash、RocketMQ Dashboard 属于可选附加组件，需要构建镜像时显式包含后才能在运行时启用。

数据库口径：常规部署和项目技术栈仍以 MySQL 为准，`docker-compose.yml` 默认使用 MySQL 镜像，后端也继续使用 MySQL JDBC 连接。All-In-One 镜像内置 MariaDB 是单容器本地体验的打包实现，作为 MySQL 协议兼容数据库使用，不代表生产部署或常规部署已经切换为 MariaDB。

All-In-One 不是生产高可用架构，也不是完整系统架构文档。完整架构、模块边界和技术选型请以官方文档及 `lilishop`、`lilishop-ui`、`lilishop-uniapp`、`docker` 各源码仓库为准。

LILISHOP 是基于 Spring Boot / Spring Cloud / Vue / Uniapp 开发的 Java 开源商城系统，支持 B2B2C 多商户商城、小程序商城、微服务商城、直播电商、分销返佣、秒杀活动、Docker 私有化部署。

## 核心特性

- Java商城系统
- 开源商城系统
- SpringBoot商城系统
- SpringCloud微服务商城
- B2B2C商城源码
- 多商户商城系统
- 小程序商城源码
- Uniapp商城系统
- Vue商城系统
- Docker商城部署
- 多语言商城

适用于：

- 企业级商城系统
- 私有化商城部署
- Java商城系统二次开发
- 开源商城源码学习
- 多商户电商平台
---

### 1. 项目简介

**Lilishop** 是一款功能完善的B2B2C多商户商城系统，采用前后端分离架构，全端代码开源。
后端基于 **SpringBoot3** 构建，具备高内聚、低耦合的特性，支持分布式部署。
前端覆盖PC、H5、小程序和APP，基于 **Vue** 和 **uni-app** 开发。

-   **官方网站**: <https://pickmall.cn>
-   **官方文档**: <https://docs.pickmall.cn>

#### 项目仓库

Lilishop 由 4 个独立仓库组成，均同步托管于 GitHub 与 Gitee：

| 仓库 | 说明 | GitHub | Gitee |
| :--- | :--- | :--- | :--- |
| **lilishop** | 后端服务（Spring Boot / Java 21） | [github.com/lilishop/lilishop](https://github.com/lilishop/lilishop) | [gitee.com/beijing_hongye_huicheng/lilishop](https://gitee.com/beijing_hongye_huicheng/lilishop) |
| **lilishop-ui** | PC 端 Web 前端（管理端 / 商家端 / 买家端 / IM） | [github.com/lilishop/lilishop-ui](https://github.com/lilishop/lilishop-ui) | [gitee.com/beijing_hongye_huicheng/lilishop-ui](https://gitee.com/beijing_hongye_huicheng/lilishop-ui) |
| **lilishop-uniapp** | 买家端移动应用（H5 / 小程序 / APP） | [github.com/lilishop/lilishop-uniapp](https://github.com/lilishop/lilishop-uniapp) | [gitee.com/beijing_hongye_huicheng/lilishop-uniapp](https://gitee.com/beijing_hongye_huicheng/lilishop-uniapp) |
| **docker** | 基础设施 docker-compose 配置 | [github.com/lilishop/docker](https://github.com/lilishop/docker) | [gitee.com/beijing_hongye_huicheng/docker](https://gitee.com/beijing_hongye_huicheng/docker) |


---

### 2. 核心特性

-   **全端覆盖**: 一套代码库支持PC、H5、小程序、APP，降低开发和维护成本。
-   **商家入驻**: 支持多商家入驻，构建平台化电商生态。
-   **All-In-One 后端**: 当前分支推荐使用 `lilishop-all` 统一后端入口，降低本地体验和私有化部署门槛。
-   **前后端分离**: 清晰的职责划分，便于团队协作和独立开发。
-   **容器化支持**: 提供Docker镜像和docker-compose配置，实现一键部署。
-   **功能完善**: 涵盖客户、订单、商品、促销、店铺、运营、统计等完整电商业务模块。

---

### 3. 在线演示

**注意**: 演示站手机验证码统一为 `111111`。演示环境部署于 `master` 分支。

-   **平台管理端**: <https://admin-b2b2c.pickmall.cn>
    -   账号: `admin`
    -   密码: `123456`
-   **店铺管理端**: <https://store-b2b2c.pickmall.cn>
    -   账号: `13011111111`
    -   密码: `111111`
-   **商城PC端**: <https://pc-b2b2c.pickmall.cn>
-   **微信小程序**:
    ![移动端体验二维码](https://static.pickmall.cn/images/h5-qrcode.png)

---

### 4. 快速开始

#### 环境准备与部署
详细的本地部署指南，请参考官方文档：
[**部署文档 -> 环境准备**](https://docs.pickmall.cn/deply/deply.html)

#### 数据库初始化
-   **推荐方式**: 使用项目提供的 `docker-compose` 配置，可自动完成数据库（MySQL, Redis, Elasticsearch等）的部署与初始化。
-   **手动方式**: 如果您选择手动部署，SQL脚本位于以下地址。请确保获取与您代码版本一致的SQL文件。
    [**数据库脚本 (Gitee)**](https://gitee.com/beijing_hongye_huicheng/docker/tree/master/init/mysql)

#### 一键启动本地全环境

在 `opensource` 聚合目录下，脚本会启动 Docker 中间件、后端 `lilishop-all`、买家 PC、商家端、运营端、IM Web 和 uniapp H5。

macOS:

```bash
./docker/start-dev.sh
```

Windows:

```bat
docker\start-dev.cmd
```

首次执行会提示输入本机对外访问的 IP/域名，以及各端访问地址；直接回车会使用本地默认端口。脚本生成的运行时文件位于 `docker/.runtime/`，前端本地覆盖配置位于各项目的 `config.local.js` 或 `.env.development.local`，这些文件不会提交到仓库。

常用命令：

```bash
node docker/scripts/dev-env.mjs config --defaults
node docker/scripts/dev-env.mjs start --reconfigure
node docker/scripts/dev-env.mjs start --dry-run
node docker/scripts/dev-env.mjs status
node docker/scripts/dev-env.mjs stop
```

默认端口：

| 服务 | 地址 |
| :--- | :--- |
| 买家 PC | `http://127.0.0.1:10000` |
| uniapp H5 | `http://127.0.0.1:10001` |
| 商家端 | `http://127.0.0.1:10002` |
| 运营端 | `http://127.0.0.1:10003` |
| IM Web | `http://127.0.0.1:8000` |

#### 单镜像单容器 All-In-One（master 完整版）

如果希望把本地完整体验环境封装到一个容器中启动，可使用 `docker/all-in-one`。`master` 分支默认使用已发布镜像 `ccr.ccs.tencentyun.com/lilishop/lilishop-all-in-one:lite`，安装脚本默认会先拉取远端最新镜像再启动。All-In-One 只暴露一个 HTTP 入口，各端前端和统一后端 `/api/` 都通过该入口访问。

macOS / Linux:

```bash
./docker/install/install-lilishop.sh
```

Windows PowerShell:

```powershell
.\docker\install\install-lilishop.ps1
```

如果需要使用本地自行构建的开发镜像：

```bash
LILISHOP_IMAGE=lilishop-all-in-one:dev LILISHOP_FORCE_PULL=false ./docker/install/install-lilishop.sh
```

该模式会启动一个较重的单容器，容器内包含 nginx、后端、PC / 商家端 / 运营端 / IM Web 前端资源、uni-app H5 运行服务、MariaDB（MySQL 协议兼容）、Redis、Elasticsearch、RocketMQ 和 XXL-Job Admin。MariaDB 仅是 All-In-One 镜像内置的 MySQL 兼容实现；常规部署仍以 MySQL 为准。Elasticsearch 默认启用；Kibana、Logstash、RocketMQ Dashboard 是可选附加组件。建议 Docker Desktop 分配 `4+ CPU`、`12GB - 16GB` 内存和 `50GB+` 磁盘。详细说明见 `docker/all-in-one/README.md`。

---

### 5. 架构文档边界

本仓库首页不再维护不完整的系统架构图和技术栈表，避免与实际源码、部署形态和分支差异产生偏差。当前仓库主要说明 Docker 部署、开发环境启动、数据库脚本和 All-In-One 单容器体验方式。

完整架构请以官方文档及源码为准：

- 后端源码：`lilishop`
- PC / 商家端 / 运营端 / IM Web：`lilishop-ui`
- H5 / 小程序 / APP：`lilishop-uniapp`
- 部署、SQL、镜像与启动脚本：`docker`

All-In-One 仅用于本地体验、演示或验证，不代表生产高可用部署架构。生产部署应按实际访问量、稳定性、监控、备份和扩缩容要求拆分数据库、缓存、搜索、消息、任务调度、前端静态资源和后端服务。

### 6. 功能列表

[功能清单](https://bdwx2tfwwt.feishu.cn/sheets/FFQKscQKDhUx60to1k9cbMngnYb?from=from_copylink)





### 7. 开源与授权

1.  **开源协议**: 本项目遵循 `AGPL-3.0` 开源协议。
2.  **使用范围**: 仅允许用于个人学习、研究和非商业用途。
3.  **禁止行为**: 禁止将本项目的代码和资源用于任何形式的商业销售。
4.  **商业授权**: 如需商业使用，必须获得官方授权。授权为一次性永久授权，并提供持续的版本升级服务。详情请联系官网客服。
5.  **软件著作权**: 本软件受国家计算机软件著作权保护（登记号：2021SR0805085）。

---

### 8. 社区与支持

我们欢迎任何形式的交流与贡献。在提问前，请先查阅 [官方文档](https://docs.pickmall.cn/) ，并参考 [《提问的智慧》](https://github.com/ryanhanwu/How-To-Ask-Questions-The-Smart-Way/blob/master/README-zh_CN.md) 以便高效沟通。

-   **[在线客服](https://work.weixin.qq.com/kfid/kfc4d8dc24a73c15f44)**
-   **微信交流1群（已满）**
-   **微信交流2群**:
    ![微信群](https://lilishop-wechat.oss-cn-beijing.aliyuncs.com/wechat.jpg)
