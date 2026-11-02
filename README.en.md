<div align="center">
  <img src="https://lilishop-oss.oss-cn-beijing.aliyuncs.com/4c864e133c2944efad1f7282ac8a3b9e.png" width="80" alt="Lilishop Logo" />
  <h1>Lilishop(PickMall) - Containerized Deployment & Operations (Docker)</h1>

  <p>
    <a href="https://github.com/lilishop/docker"><img src="https://img.shields.io/github/stars/lilishop/docker.svg?style=social&logo=github" alt="GitHub Stars" /></a>
    <a href="https://gitee.com/beijing_hongye_huicheng/docker"><img src="https://gitee.com/beijing_hongye_huicheng/docker/badge/star.svg?theme=dark" alt="Gitee Stars" /></a>
    <a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License" /></a>
    <a href="https://www.docker.com/"><img src="https://img.shields.io/badge/Docker-20.10+-blue.svg" alt="Docker" /></a>
    <a href="https://docs.docker.com/compose/"><img src="https://img.shields.io/badge/Docker%20Compose-2.x-brightgreen.svg" alt="Docker Compose" /></a>
  </p>

  <p>
    <a href="https://pickmall.cn">🏠 Official Website</a> ·
    <a href="https://bdwx2tfwwt.feishu.cn/wiki/space/7675179368632617952?ccm_open_type=lark_wiki_spaceLink&open_tab_from=wiki_home">📖 Documentation</a> ·
    <a href="#2-online-demo">💻 Online Demo</a> ·
    <a href="#8-community--support">💬 WeChat Group</a>
  </p>

  <p>
    <a href="./README.md">简体中文</a> | <b>English</b>
  </p>
</div>

> ⭐ **If you like this project, please click `Star` in the top-right corner to support us! Your Star is our greatest motivation for continuous open-source iteration!**

**LILISHOP** is an open-source e-commerce system built with Spring Boot, Vue 3, and uni-app. It supports B2B2C multi-vendor marketplaces, WeChat Mini Programs, H5, Android/iOS Apps, live-streaming e-commerce, affiliate distribution, and flash sales.

### ✨ Why Choose Lilishop
- 🟢 **True MIT License**: Free for commercial use and private secondary development without licensing concerns.
- 🚀 **Out-of-the-Box Containerization**: Clean and lightweight Docker Compose middleware orchestration alongside multi-client local development launch scripts.
- 🧩 **Full-Platform Production-Ready**: Complete operational and runtime environment covering Platform Admin, Seller Panel, PC Mall, Mobile H5, WeChat Mini Program, Mobile Apps, and IM Customer Service.

---

## 1. Overview

**Lilishop** is a feature-complete B2B2C multi-vendor mall system with a decoupled frontend-backend architecture and open-source code across all tiers.  
The backend is built with **Spring Boot 4** (Java 21) offering high cohesion and loose coupling; the frontend covers PC, management panels, H5, Mini Programs, and mobile apps based on **Vue 3** and **uni-app**.

This repository (`docker`) is the **Container Orchestration, Middleware Configuration, and Database Baseline Repository**, providing:
1. **Standard Docker Compose Orchestration**: Streamlined middleware definitions for MySQL 8.x and Redis 7.x.
2. **Local Multi-Repo Development Tools**: Joint-debugging scripts (`start-dev`) that streamline port assignments and reverse proxy setups for multi-frontend and backend development.
3. **Database Baseline & Idempotent Patches**: Full database initialization DDL/DML and dual-safe incremental upgrade patch mechanisms.
4. **Reverse Proxy & Gateway Configurations**: Pre-configured Nginx routing rules for frontend static assets and backend API routing.

- **Official Website**: <https://pickmall.cn>
- **Documentation**: [Product Documentation](https://bdwx2tfwwt.feishu.cn/wiki/space/7675179368632617952?ccm_open_type=lark_wiki_spaceLink&open_tab_from=wiki_home)
- **Gitee Repository**: <https://gitee.com/beijing_hongye_huicheng/docker>
- **GitHub Main Repository**: <https://github.com/lilishop/lilishop>

---

## 2. Online Demo

> **Note**: The verification code for the demo environment is `111111`. The demo environment is deployed from the `master` branch.

| Portal | URL | Demo Credentials |
| :--- | :--- | :--- |
| **Platform Admin Panel (`manager`)** | <https://admin-b2b2c.pickmall.cn> | Account: `admin` / Password: `123456` |
| **Seller / Store Panel (`seller`)** | <https://store-b2b2c.pickmall.cn> | Account: `13011111111` / Password: `111111` |
| **PC Buyer Mall (`buyer`)** | <https://pc-b2b2c.pickmall.cn> | SMS Code Login: `111111` |
| **Mobile H5 (`uni-app`)** | <https://m-b2b2c.pickmall.cn> | SMS Code Login: `111111` |

| WeChat Mini Program | Mobile H5 ([Visit Directly](https://m-b2b2c.pickmall.cn)) |
| :---: | :---: |
| <img src="https://static.pickmall.cn/images/h5-qrcode.png" width="180" alt="WeChat Mini Program QR Code" /> | <img src="https://lilishop-wechat.oss-cn-beijing.aliyuncs.com/h5-qrcode.png" width="180" alt="Mobile H5 QR Code" /> |

---

## 3. Architecture & Key Features

### Key Features
- **Streamlined Production Orchestration**: Standalone Docker Compose recipes for core infrastructure (MySQL, Redis), maintaining lightweight high performance and persistence security.
- **Local Dev Orchestration**: Cross-project launcher for developers holding all source code repositories, managing ports and local environment overrides automatically.
- **Dual-Safe Idempotent Patches**: Database patches employ `CREATE TABLE IF NOT EXISTS` and dynamic column existence checks to guarantee safe executions during automated container bootstrap or manual schema migration.
- **Microservice / Modular Readiness**: Supports decoupled deployment for middleware, backend APIs (`buyer-api`, `manager-api`, `im-api`), and static frontend packages.

### Middleware & Components
| Component / Service | Image / Version | Default Port | Description |
| :--- | :--- | :--- | :--- |
| **MySQL** | `mysql:8.0.30` | `3306` | Core relational database configured with utf8mb4 and optimized connection pool |
| **Redis** | `redis:7.0.4` | `6379` | Distributed cache, session storage, distributed locks, Redisson delayed task queue |
| **Nginx** | `nginx:alpine` | `80` / `443` | Reverse proxy gateway, SSL termination, and static asset delivery |

---

## 4. Quick Start & Deployment Guide

### 4.1 Prerequisites
- **Docker 20.10+** and **Docker Compose v2+**.
- **Node.js 18+** if running the local source code joint-debugging tool.

---

### 4.2 Option 1: Docker Compose Middleware Deployment (Recommended for Production & Staging)

Use `docker-compose.yml` to spin up core middleware services (MySQL 8.0 & Redis 7.0):

```bash
cd docker
docker compose up -d
```

- **MySQL 8.0**: Persistent data volume mounted under `../volumes/data/mysqldata`.
- **Redis 7.0**: Persistent data volume mounted under `../volumes/data/redsidata`.

---

### 4.3 Option 2: Local Full Environment Joint-Debugging (For Source Development)

When developing across `lilishop`, `lilishop-ui`, and `lilishop-uniapp` repositories in the same directory, run:

- **macOS / Linux**:
  ```bash
  ./docker/start-dev.sh
  ```
- **Windows**:
  ```bat
  docker\start-dev.cmd
  ```

#### Default Port Mappings
| Service | Access URL | Source Directory |
| :--- | :--- | :--- |
| **PC Buyer Mall** | `http://127.0.0.1:10000` | `lilishop-ui/buyer` |
| **Mobile H5** | `http://127.0.0.1:10001` | `lilishop-uniapp` (H5 runtime) |
| **Seller Panel** | `http://127.0.0.1:10002` | `lilishop-ui/seller` |
| **Platform Admin** | `http://127.0.0.1:10003` | `lilishop-ui/manager` |
| **IM Web** | `http://127.0.0.1:8000` | `lilishop-ui/im` |

#### Useful CLI Commands
```bash
# Check status of running dev processes
node docker/scripts/dev-env.mjs status

# Stop all joint-debugging services
node docker/scripts/dev-env.mjs stop

# Reconfigure and restart
node docker/scripts/dev-env.mjs start --reconfigure
```

---

### 4.4 Database Initialization & Safe Patches

- **Baseline Schema**: `docker/init/mysql/lilishop.sql` holds the full DDL and initial baseline seed data.
- **Incremental Patches**: `docker/init/mysql/patches/` contains incremental schema updates across releases.
- **Idempotence & Safety**:
  - Mounted automatically to `/docker-entrypoint-initdb.d` in Compose mode;
  - `999_apply_patches.sh` executes patches sequentially during database bootstrapping;
  - Every patch follows idempotent guidelines (`CREATE TABLE IF NOT EXISTS` or existence checks) to ensure smooth operations on both blank and active databases.

---

## 5. Directory Structure

```text
docker
├── config/                   # Middleware configuration templates
│   └── my.cnf                # MySQL configuration (utf8mb4, timezone, connections)
├── init/                     # Database initial scripts and patches
│   └── mysql/
│       ├── lilishop.sql      # Full database baseline schema and seed data
│       ├── 999_apply_patches.sh # Automatic patch runner script
│       └── patches/          # Incremental version patches
├── scripts/                  # Development environment management scripts
│   ├── dev-env.mjs           # Multi-repo dev process manager
│   └── dev-env-lib.mjs       # Dev utility functions and port checks
├── docker-compose.yml        # Standard middleware Compose file
├── docker-compose-lili-source.yml # Source build compose orchestration
├── docker-compose-minio.yml  # MinIO object storage compose file
├── nginx.conf                # Nginx gateway reverse proxy configuration
├── start-dev.sh / .cmd       # One-click dev start script (Shell / Batch)
└── stop-dev.sh / .cmd        # One-click dev stop script (Shell / Batch)
```

---

## 6. Associated Repositories

This repository focuses on **Container Orchestration, Middleware Configuration, and Database Scripts** (`docker`). The complete ecosystem is composed of four main repositories:

| Repository | Purpose | Links |
| :--- | :--- | :--- |
| **`lilishop`** | Backend Services (Spring Boot 4 / Java 21) | [Gitee](https://gitee.com/beijing_hongye_huicheng/lilishop) · [GitHub](https://github.com/lilishop/lilishop) |
| **`lilishop-ui`** | PC Mall / Seller Panel / Admin Panel / IM Web Frontend | [Gitee](https://gitee.com/beijing_hongye_huicheng/lilishop-ui) |
| **`lilishop-uniapp`** | Buyer H5 / WeChat Mini Program / Android & iOS Apps | [Gitee](https://gitee.com/beijing_hongye_huicheng/lilishop-uniapp) |
| **`docker`** | Container Orchestration, Middleware & DB Scripts | [Gitee](https://gitee.com/beijing_hongye_huicheng/docker) · [MySQL Scripts](https://gitee.com/beijing_hongye_huicheng/docker/tree/master/init/mysql) |

---

## 7. License & Intellectual Property

This project is licensed under the [MIT License](./LICENSE), copyright owned by **Beijing Hongye Huicheng Technology Co., Ltd. (北京宏业汇成科技有限公司)**. Free for personal and commercial use, research, and modification, provided the original copyright and license notice are preserved.

---

## 8. Community & Support

We welcome questions and contributions! Please refer to the [Product Documentation](https://bdwx2tfwwt.feishu.cn/wiki/space/7675179368632617952?ccm_open_type=lark_wiki_spaceLink&open_tab_from=wiki_home) before asking questions.

- **[Online Support](https://work.weixin.qq.com/kfid/kfc4d8dc24a73c15f44)**
- **WeChat Group**:  
  <img src="https://lilishop-wechat.oss-cn-beijing.aliyuncs.com/wechat.jpg" width="200" alt="WeChat Community Group" />

---

## 9. Roadmap

### ✅ Completed Features
| Module | Module |
| :--- | :--- |
| ✅ Timed Product Shelf / Off-shelf | ✅ Product / Member Grouping |
| ✅ Virtual Sales Counts | ✅ Special VAT Invoices |
| ✅ Pinned Comments | ✅ Member Level System |
| ✅ Shopping Cards | ✅ Tencent Cloud Live Streaming |
| ✅ Electronic Card/Key Products | ✅ Two-Tier Distribution System |
| ✅ Scheduled Task Center | ✅ Appointment & Service Products |
| ✅ Theme Color Configuration | ✅ No-Shipment Fulfillment Mode |
| ✅ Multi-dimensional Analytics | ✅ Operations & Financial Reports |
| ✅ Category Navigation Templates | ✅ Mobile Floor Decoration Suite |
| ✅ PC Floor Decoration Refactoring | ✅ Unified Header Navigation |
| ✅ Independent PC Store List | ✅ Sensitive Words Scenario Filtering |

### 🔜 Upcoming Features
- 🔜 Store Settlement Summary & Ledger
- 🔜 Payment Methods & Financial Analytics
- 🔜 WeChat Channels Store Integration
- 🔜 Douyin Store Integration
- 🔜 WeChat Mini-Program Native Refactoring & Experience Alignment
- 🔜 OpenAPI Platform & Developer Center
