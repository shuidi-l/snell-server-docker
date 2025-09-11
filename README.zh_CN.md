<p align="center">
  <a href="README.md">English</a> | <a>中文</a>
</p>

# Snell Server Docker 镜像
 [![Build](https://github.com/shuidi-l/snell-server/actions/workflows/build-push.yml/badge.svg)](https://github.com/shuidi-l/snell-server/actions/workflows/build-push.yml) [![Release](https://img.shields.io/github/release/shuidi-l/snell-server.svg?style=flat-square&logo=github&logoColor=fff&color=005AA4)](https://github.com/shuidi-l/snell-server/releases) [![Docker Pulls](https://img.shields.io/docker/pulls/1byte/snell-server.svg?style=&logo=docker)](https://hub.docker.com/r/1byte/snell-server) [![Repository License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://opensource.org/license/mit)

一个轻量级的、支持多架构（`linux/amd64` 和 `linux/arm64`）的 Snell Server Docker 镜像。  
支持通过环境变量进行配置，当未提供时使用安全默认值：随机 PSK 和随机端口（>1024）。

## 可用镜像

本项目提供两个来源的 Docker 镜像：

- **Docker Hub**: `1byte/snell-server`
- **GitHub Container Registry (GHCR)**: `ghcr.io/shuidi-l/snell-server`

两个镜像完全相同，您可以根据偏好选择使用其中一个。

## 特性

- **多阶段构建** 以获得更小的镜像大小
- **多架构支持**：`linux/amd64`、`linux/arm64`
- **可通过环境变量配置**
- **安全默认值**：随机端口和随机 32 字符 PSK
- **最小依赖**：基于 [frolvlad/alpine-glibc](https://github.com/Docker-Hub-frolvlad/docker-alpine-glibc)，提供 glibc 兼容性
- **条件配置**：仅在提供值时写入可选字段
- **输入验证**：在启动前验证 IPv6 和 OBFS 值

## 环境变量

| 变量        | 默认值                     | 描述                                     | 验证规则 |
| ----------- | --------------------------- | ---------------------------------------- | -------- |
| `PORT`      | 随机 1025–65535            | 监听端口                                 | 必须是 1025–65535 之间的整数 |
| `PSK`       | 随机 32 字符字母数字        | 预共享密钥                               | 必需 |
| `IPv6`      | 未设置（可选）              | 启用 IPv6                                | 如果提供，必须是 `true` 或 `false` |
| `OBFS`      | 未设置（可选）              | 混淆模式                                 | 如果提供，必须是 `off` 或 `http` |
| `OBFS_HOST` | 未设置（可选）              | 混淆主机                                 | 仅在 `OBFS=http` 时使用 |
| `TFO`       | `true`                      | 启用 TCP Fast Open                       | 布尔值 |

## 配置行为

服务器使用条件配置写入：

- **IPv6**：仅在设置 `IPv6` 环境变量时写入配置
- **OBFS**：仅在设置 `OBFS` 环境变量时写入配置
- **OBFS_HOST**：仅在 `OBFS=http` 且设置 `OBFS_HOST` 时写入配置
- **已有配置文件**：如果已经存在 `snell-server.conf`（例如通过 volume 挂载），脚本将直接使用该文件并跳过生成

## Docker 镜像

### Docker Hub

```bash
docker pull 1byte/snell-server
```

### GitHub Container Registry (GHCR)

```bash
docker pull ghcr.io/shuidi-l/snell-server
```

## 构建镜像

### 本地构建：

```bash
# 使用默认 Snell 版本构建（5.0.0）
docker build -t 1byte/snell-server .

# 使用指定 Snell 版本构建
docker build --build-arg SNELL_VERSION=4.1.1 -t 1byte/snell-server:4.1.1 .
```

### 多架构构建（需要 buildx）：

```bash
# 使用默认 Snell 版本构建（5.0.0）
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t 1byte/snell-server:latest .

# 使用指定 Snell 版本构建
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg SNELL_VERSION=4.1.1 \
  -t 1byte/snell-server:v4.1.1 .
```

## 运行示例

### 默认配置（随机端口和 PSK）

```bash
# 使用 Docker Hub
docker run --rm 1byte/snell-server

# 使用 GitHub Container Registry
docker run --rm ghcr.io/shuidi-l/snell-server
```

### 指定端口和 PSK

```bash
# 使用 Docker Hub
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  1byte/snell-server

# 使用 GitHub Container Registry
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  ghcr.io/shuidi-l/snell-server
```

### 启用 IPv6

```bash
# 使用 Docker Hub
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  -e IPv6=true \
  1byte/snell-server

# 使用 GitHub Container Registry
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  -e IPv6=true \
  ghcr.io/shuidi-l/snell-server
```

### 启用混淆并自定义主机

```bash
# 使用 Docker Hub
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=http \
  -e OBFS_HOST=my.domain.com \
  1byte/snell-server

# 使用 GitHub Container Registry
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=http \
  -e OBFS_HOST=my.domain.com \
  ghcr.io/shuidi-l/snell-server
```

### 禁用混淆

```bash
# 使用 Docker Hub
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=off \
  1byte/snell-server

# 使用 GitHub Container Registry
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=off \
  ghcr.io/shuidi-l/snell-server
```

### 完整配置示例

```bash
# 使用 Docker Hub
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  -e IPv6=true \
  -e OBFS=http \
  -e OBFS_HOST=gateway.icloud.com \
  -e TFO=false \
  1byte/snell-server

# 使用 GitHub Container Registry
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  -e IPv6=true \
  -e OBFS=http \
  -e OBFS_HOST=gateway.icloud.com \
  -e TFO=false \
  ghcr.io/shuidi-l/snell-server
```

## 使用 docker-compose 运行

### 快速开始

1. 确保 `docker-compose.yml` 位于当前工作目录
2. 通过 `.env` 文件（推荐）或 Shell 提供环境变量

示例 `.env`（与 `docker-compose.yml` 同目录）：

```env
PORT=8234
PSK=mysecurepsk
# IPv6=false
# TFO=true
# OBFS=http
# OBFS_HOST=gateway.icloud.com
```

启动服务：

```bash
docker compose up -d
```

### 使用自定义 snell-server.conf

如果你已经有 `snell-server.conf`，可通过挂载使用，脚本会跳过自动生成：

```yaml
services:
  snell-server:
    # ...
    volumes:
      - ./snell-server.conf:/app/snell-server.conf
```

启用该挂载后，容器将使用你提供的配置文件，环境变量将不再用于生成配置。

## 错误处理

服务器在启动前验证所有输入值：

- **无效的 PORT**：必须是 1025 到 65535 之间的整数
- **无效的 IPv6**：如果提供，必须是 `true` 或 `false`
- **无效的 OBFS**：如果提供，必须是 `off` 或 `http`

如果任何验证失败，服务器将显示错误消息并以代码 1 退出。

## 许可证

[LICENSE](LICENSE)
