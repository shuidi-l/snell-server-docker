<p align="center">
  <a href="README.md">English</a> | <a>中文</a>
</p>

# Snell Server Docker 镜像

一个轻量级的、支持多架构（`linux/amd64` 和 `linux/arm64`）的 Snell Server Docker 镜像。  
支持通过环境变量进行配置，当未提供时使用安全默认值：随机 PSK 和随机端口（>1024）。

## 特性

- **多阶段构建** 以获得更小的镜像大小
- **多架构支持**：`linux/amd64`、`linux/arm64`
- **可通过环境变量配置**
- **安全默认值**：随机端口和随机 32 字符 PSK
- **最小依赖**：基于 `alpine`
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

## 构建镜像

### 本地构建：

```bash
docker build -t 1byte/snell-server .
```

### 多架构构建（需要 buildx）：

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t 1byte/snell-server:latest .
```

## 运行示例

### 默认配置（随机端口和 PSK）

```bash
docker run --rm 1byte/snell-server
```

### 指定端口和 PSK

```bash
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  1byte/snell-server
```

### 启用 IPv6

```bash
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  -e IPv6=true \
  1byte/snell-server
```

### 启用混淆并自定义主机

```bash
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=http \
  -e OBFS_HOST=my.domain.com \
  1byte/snell-server
```

### 禁用混淆

```bash
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=off \
  1byte/snell-server
```

### 完整配置示例

```bash
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  -e IPv6=true \
  -e OBFS=http \
  -e OBFS_HOST=gateway.icloud.com \
  -e TFO=false \
  1byte/snell-server
```

## 错误处理

服务器在启动前验证所有输入值：

- **无效的 PORT**：必须是 1025 到 65535 之间的整数
- **无效的 IPv6**：如果提供，必须是 `true` 或 `false`
- **无效的 OBFS**：如果提供，必须是 `off` 或 `http`

如果任何验证失败，服务器将显示错误消息并以代码 1 退出。

## 许可证

[LICENSE](LICENSE)
