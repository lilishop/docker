<div align="center">
  <img src="https://lilishop-oss.oss-cn-beijing.aliyuncs.com/4c864e133c2944efad1f7282ac8a3b9e.png" width="80" alt="Lilishop Logo" />
  <h1>Lilishop(PickMall) 开源商城系统 - 容器化运维与部署 (Docker)</h1>

  <p>
    <a href="https://github.com/lilishop/docker"><img src="https://img.shields.io/github/stars/lilishop/docker.svg?style=social&logo=github" alt="GitHub Stars" /></a>
    <a href="https://gitee.com/beijing_hongye_huicheng/docker"><img src="https://gitee.com/beijing_hongye_huicheng/docker/badge/star.svg?theme=dark" alt="Gitee Stars" /></a>
    <a href="./LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-blue.svg" alt="License" /></a>
    <a href="https://www.docker.com/"><img src="https://img.shields.io/badge/Docker-20.10+-blue.svg" alt="Docker" /></a>
    <a href="https://docs.docker.com/compose/"><img src="https://img.shields.io/badge/Docker%20Compose-2.x-brightgreen.svg" alt="Docker Compose" /></a>
  </p>

  <p>
    <a href="https://pickmall.cn">🏠 官方网站</a> ·
    <a href="https://bdwx2tfwwt.feishu.cn/wiki/space/7675179368632617952?ccm_open_type=lark_wiki_spaceLink&open_tab_from=wiki_home">📖 产品文档</a> ·
    <a href="#2-在线演示">💻 在线演示</a> ·
    <a href="#8-社区与支持">💬 微信交流群</a>
  </p>

  <p>
    <b>简体中文</b> | <a href="./README.en.md">English</a>
  </p>
</div>

> ⭐ **如果觉得项目不错，请点击右上角 `Star` 收藏支持！您的 Star 是我们持续开源迭代的最大动力！**

**LILISHOP** 是基于 Spring Boot / Vue 3 / uni-app 开发的开源商城系统，支持 B2B2C 多商户商城、微信小程序商城、H5 商城、APP 商城、直播电商、分销返佣、秒杀活动。

### ✨ 为什么选择 Lilishop
- 🟢 **真 Apache-2.0 协议**：支持免费商用与私有化闭源二开，无版权后顾之忧。
- 🚀 **开箱即用容器化**：提供轻量精简的 Docker Compose 中间件编排与多端本地一键联调工具，大幅降低环境搭建与前后端联调门槛。
- 🧩 **全端生产级完整闭环**：覆盖平台运营端、商家店铺端、PC 商城端、移动 H5、微信小程序、APP 与 IM 在线客服端的整套环境编排与数据库初始化。

---

## 1. 项目简介

**Lilishop** 是一款功能完善的 B2B2C 多商户商城系统，采用前后端分离架构，全端代码开源。  
后端基于 **Spring Boot 4**（Java 21）构建，具备高内聚、低耦合的特性，支持分布式与集群扩展；前端覆盖 PC、管理后台、H5、小程序和 APP，基于 **Vue 3** 和 **uni-app** 开发。

本仓库（`docker`）为 **容器化部署编排、环境配置与数据库初始化主仓库**，提供以下能力：
1. **标准 Docker Compose 中间件编排**：一键编排 MySQL 8.x、Redis 7.x 等核心中间件服务。
2. **本地全环境一键联调工具**：多端本地开发启动脚本（`start-dev`），打通前端多工程、后端 API 与中间件的联调网络。
3. **数据库基线与安全补丁机制**：内置完整的系统初始化 SQL 脚本及双向幂等安全的增量补丁更新机制。
4. **反向代理与网关配置**：提供配套的 Nginx 配置文件，方便快速配置静态资源路由与多端 API 反向代理。

- **官方网站**: <https://pickmall.cn>
- **官方文档**: [产品文档](https://bdwx2tfwwt.feishu.cn/wiki/space/7675179368632617952?ccm_open_type=lark_wiki_spaceLink&open_tab_from=wiki_home)
- **Gitee 仓库**: <https://gitee.com/beijing_hongye_huicheng/docker>
- **GitHub 主仓库**: <https://github.com/lilishop/lilishop>

---

## 2. 在线演示

> **注意**: 演示站手机验证码统一为 `111111`。演示环境部署于 `master` 分支。

| 演示站点 | 访问地址 | 演示账号 |
| :--- | :--- | :--- |
| **平台运营管理端 (`manager`)** | <https://admin-b2b2c.pickmall.cn> | 账号：`admin` / 密码：`123456` |
| **商家店铺管理端 (`seller`)** | <https://store-b2b2c.pickmall.cn> | 账号：`13011111111` / 密码：`111111` |
| **商城 PC 买家端 (`buyer`)** | <https://pc-b2b2c.pickmall.cn> | 可使用手机号验证码 `111111` 登录 |
| **移动端 H5 (`uni-app`)** | <https://m-b2b2c.pickmall.cn> | 可使用手机号验证码 `111111` 登录 |

| 微信小程序 | 移动端 H5（[点击直接访问](https://m-b2b2c.pickmall.cn)） |
| :---: | :---: |
| <img src="https://static.pickmall.cn/images/h5-qrcode.png" width="180" alt="微信小程序体验码" /> | <img src="https://lilishop-wechat.oss-cn-beijing.aliyuncs.com/h5-qrcode.png" width="180" alt="移动端 H5 体验二维码" /> |
| 微信扫码体验小程序 | 手机扫码或访问 <https://m-b2b2c.pickmall.cn> |

---

## 3. 部署架构与核心特性

### 核心特性
- **轻量解耦的生产级编排**：聚焦核心中间件，保持架构精简高内聚，数据卷持久化挂载安全可靠。
- **全链路本地联调**：面向多仓库源码协同开发者，通过统一的脚本自动检测端口冲突、生成本地开发覆盖配置，一键拉起或停止所有工程。
- **高兼容与安全补丁体系**：数据库升级补丁支持 `CREATE TABLE IF NOT EXISTS` 与动态判断，无论容器自动初始化还是手动执行，均具备严格幂等性。
- **微服务与独立部署就绪**：支持中间件、后端 API（`buyer-api`、`manager-api`、`im-api`）与各端前端解耦分发部署。

### 核心中间件与组件清单
| 组件 / 服务 | 镜像 / 版本 | 默认端口 | 职责说明 |
| :--- | :--- | :--- | :--- |
| **MySQL** | `mysql:8.0.30` | `3306` | 电商核心业务关系型数据库，配置字符集与连接调优 |
| **Redis** | `redis:7.0.4` | `6379` | 分布式缓存、Session 状态、分布式锁、Redisson 延时任务队列 |
| **Nginx** | `nginx:alpine` | `80` / `443` | 静态前端资源分发与多端 API 反向代理网关 |

---

## 4. 快速开始与使用指南

### 4.1 环境准备
- 安装 **Docker 20.10+** 及 **Docker Compose v2+**。
- 若使用本地全环境源码联调脚本，需安装 **Node.js 18+**。

---

### 4.2 方式一：Docker Compose 中间件编排部署（推荐生产与测试）

使用 `docker-compose.yml` 即可一键在服务器或本地拉起商城所需的全部核心基础中间件（MySQL 8.0 与 Redis 7.0）：

```bash
cd docker
docker compose up -d
```

- **MySQL 8.0**：数据持久化挂载保存在宿主机的 `../volumes/data/mysqldata` 目录下。
- **Redis 7.0**：数据持久化保存在宿主机的 `../volumes/data/redsidata` 目录下。

---

### 4.3 方式二：本地全环境一键联调（面向源码二次开发）

当同时在同一父目录下克隆了 `lilishop`、`lilishop-ui`、`lilishop-uniapp` 和 `docker` 四个核心仓库时，可使用一键脚本启动完整多端联调环境：

- **macOS / Linux**:
  ```bash
  ./docker/start-dev.sh
  ```
- **Windows**:
  ```bat
  docker\start-dev.cmd
  ```

#### 默认端口映射
| 服务模块 | 访问端口 | 对应仓库 / 职责 |
| :--- | :--- | :--- |
| **买家 PC 端** | `http://127.0.0.1:10000` | `lilishop-ui/buyer` |
| **移动端 H5** | `http://127.0.0.1:10001` | `lilishop-uniapp` (H5 运行态) |
| **商家店铺管理端** | `http://127.0.0.1:10002` | `lilishop-ui/seller` |
| **平台运营管理端** | `http://127.0.0.1:10003` | `lilishop-ui/manager` |
| **IM 客服端** | `http://127.0.0.1:8000` | `lilishop-ui/im` |

#### 常用联调控制命令
```bash
# 查看当前所有开发进程状态
node docker/scripts/dev-env.mjs status

# 停止所有正在运行的联调服务
node docker/scripts/dev-env.mjs stop

# 重新配置并启动服务
node docker/scripts/dev-env.mjs start --reconfigure
```

---

### 4.4 数据库初始化与安全补丁机制

- **基线 SQL 脚本**：`docker/init/mysql/lilishop.sql` 为系统基础库表结构与初始种子数据。
- **增量补丁目录**：`docker/init/mysql/patches/` 包含历次版本迭代的表结构升级补丁。
- **安全幂等规则**：
  - 在 Docker Compose 模式下，`./init/mysql` 映射至容器的 `/docker-entrypoint-initdb.d`；
  - 官方 MySQL entrypoint 按照文件名顺序执行 SQL，`999_apply_patches.sh` 配合增量补丁统一应用；
  - 每个补丁均遵循幂等设计原则（如 `CREATE TABLE IF NOT EXISTS`、判断列不存在后再执行 `ALTER TABLE`），保证在空库初始化或已有数据库增量升级时均安全稳定；
  - 对于已经初始化并运行中的现有数据库，新版本升级时直接执行对应版本补丁 SQL 即可。

---

## 5. 目录结构

```text
docker
├── config/                   # 【中间件配置文件】
│   └── my.cnf                # MySQL 核心配置（utf8mb4、时区、连接池调优）
├── init/                     # 【数据库初始化与补丁】
│   └── mysql/
│       ├── lilishop.sql      # 数据库基线表结构与种子数据
│       ├── 999_apply_patches.sh # 补丁批量自动应用脚本
│       └── patches/          # 历次版本增量升级补丁 SQL
├── scripts/                  # 【本地全端联调控制库】
│   ├── dev-env.mjs           # 多端本地启动与进程管理入口
│   └── dev-env-lib.mjs       # 环境配置检测、网络连通性与端口工具库
├── docker-compose.yml        # 标准多中间件容器编排配置文件
├── docker-compose-lili-source.yml # 源码构建联调编排文件
├── docker-compose-minio.yml  # MinIO 对象存储编排文件
├── nginx.conf                # Nginx 生产反向代理网关配置
├── start-dev.sh / .cmd       # 本地多端联调一键启动入口（Shell / Batch）
└── stop-dev.sh / .cmd        # 本地多端联调一键停止入口（Shell / Batch）
```

---

## 6. 配套源码仓库

本仓库专注于 **容器化编排、中间件配置与数据库脚本**（`docker`）。完整系统由以下四个核心仓库组成：

| 仓库名称 | 职责说明 | 仓库地址 |
| :--- | :--- | :--- |
| **`lilishop`** | 后端服务源码（Spring Boot 4 / Java 21） | [Gitee](https://gitee.com/beijing_hongye_huicheng/lilishop) · [GitHub](https://github.com/lilishop/lilishop) |
| **`lilishop-ui`** | PC 商城 / 商家端 / 运营管理端 / IM Web 前端 | [Gitee](https://gitee.com/beijing_hongye_huicheng/lilishop-ui) |
| **`lilishop-uniapp`** | 买家端 H5 / 微信小程序 / Android & iOS APP | [Gitee](https://gitee.com/beijing_hongye_huicheng/lilishop-uniapp) |
| **`docker`** | 容器化部署编排、镜像与数据库脚本 | [Gitee](https://gitee.com/beijing_hongye_huicheng/docker) · [MySQL 脚本](https://gitee.com/beijing_hongye_huicheng/docker/tree/master/init/mysql) |

---

## 7. 开源与授权

本项目遵循 [Apache-2.0](./LICENSE) 开源协议，版权归 **北京宏业汇成科技有限公司** 所有。允许个人及企业免费用于学习、研究、修改和商业用途（需保留原始版权和许可声明）。

---

## 8. 社区与支持

我们欢迎任何形式的交流与贡献。在提问前，请先查阅 [产品文档](https://bdwx2tfwwt.feishu.cn/wiki/space/7675179368632617952?ccm_open_type=lark_wiki_spaceLink&open_tab_from=wiki_home)，并参考 [《提问的智慧》](https://github.com/ryanhanwu/How-To-Ask-Questions-The-Smart-Way/blob/master/README-zh_CN.md) 以便高效沟通。

- **[在线客服](https://work.weixin.qq.com/kfid/kfc4d8dc24a73c15f44)**
- **微信交流群**:  
  <img src="https://lilishop-wechat.oss-cn-beijing.aliyuncs.com/wechat.jpg" width="200" alt="微信群" />

---

## 9. 升级计划

### ✅ 已完成特性
| 功能模块 | 功能模块 |
| :--- | :--- |
| ✅ 出库单 / 库存流水 | ✅ 商品定时上下架 |
| ✅ 商品分组 / 会员分组 | ✅ 专用发票（发票上传） |
| ✅ 商品虚拟销量 | ✅ 客户等级体系 |
| ✅ 置顶评论 | ✅ 腾讯云-云直播 |
| ✅ 购物卡 | ✅ 二级分销 |
| ✅ 卡密商品 | ✅ 预约服务商品 |
| ✅ 定时任务管理 | ✅ 新增无需配送发货方式 |
| ✅ 主题色管理 | ✅ 敏感词场景化过滤 |
| ✅ 多维统计（营业/商品/会员/积分/储值/营销/分销） | ✅ 经营报表（店铺业绩/商品同比环比/订单明细/销售汇总） |
| ✅ 分类页多模板设置 | ✅ 移动端楼层装修组件库 |
| ✅ PC端楼层装修重构 | ✅ 全站统一顶栏 |
| ✅ PC端店铺独立列表 | |

### 🔜 近期规划中
- 🔜 店铺结算汇总 & 结算台账
- 🔜 支付方式汇总 & 钱包流水 & 财务汇总
- 🔜 微信小店对接
- 🔜 抖店对接
- 🔜 微信小程序原生重构与体验对齐
- 🔜 OpenAPI 开放平台与开发者中心
