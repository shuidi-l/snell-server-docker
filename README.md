<p align="center">
  <a>English</a> | <a href="https://github.com/shuidi-l/snell-server/blob/main/README.zh_CN.md">中文</a>
</p>

# Snell Server Docker Image
 [![Build](https://github.com/shuidi-l/snell-server/actions/workflows/build-push.yml/badge.svg)](https://github.com/shuidi-l/snell-server/actions/workflows/build-push.yml) [![Release](https://img.shields.io/github/release/shuidi-l/snell-server.svg?style=flat-square&logo=github&logoColor=fff&color=005AA4)](https://github.com/shuidi-l/snell-server/releases) [![Docker Pulls](https://img.shields.io/docker/pulls/1byte/snell-server.svg?style=&logo=docker)](https://hub.docker.com/r/1byte/snell-server) [![Repository License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://opensource.org/license/mit)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fshuidi-l%2Fsnell-server.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fshuidi-l%2Fsnell-server?ref=badge_shield)

A lightweight, multi-architecture (`linux/amd64` and `linux/arm64`) Docker image for Snell Server.  
Supports configuration via environment variables, with secure defaults when not provided: random PSK and random port (>1024).


[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fshuidi-l%2Fsnell-server.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fshuidi-l%2Fsnell-server?ref=badge_large)

## Available Images

This project provides Docker images from two sources:

- **Docker Hub**: `1byte/snell-server`
- **GitHub Container Registry (GHCR)**: `ghcr.io/shuidi-l/snell-server`

Both images are identical and you can use either one based on your preference.

## Features

- **Multi-stage build** for a smaller image size
- **Multi-architecture support**: `linux/amd64`, `linux/arm64`
- **Configurable via environment variables**
- **Secure defaults**: random port and random 32-character PSK
- **Minimal dependencies**: based on [frolvlad/alpine-glibc](https://github.com/Docker-Hub-frolvlad/docker-alpine-glibc) for glibc compatibility
- **Conditional configuration**: only writes optional fields when values are provided
- **Input validation**: validates IPv6 and OBFS values before startup

## Environment Variables

| Variable    | Default Value               | Description                                 | Validation Rules |
| ----------- | --------------------------- | ------------------------------------------- | ---------------- |
| `PORT`      | Random 1025–65535           | Listening port                              | Must be integer 1025–65535 |
| `PSK`       | Random 32-char alphanumeric | Pre-shared key                              | Required |
| `IPv6`      | Not set (optional)          | Enable IPv6                                 | Must be `true` or `false` if provided |
| `OBFS`      | Not set (optional)          | Obfuscation mode                            | Must be `off` or `http` if provided |
| `OBFS_HOST` | Not set (optional)          | Obfuscation host                            | Only used when `OBFS=http` |
| `TFO`       | `true`                      | Enable TCP Fast Open                        | Boolean |

## Configuration Behavior

The server uses conditional configuration writing:

- **IPv6**: Only written to config if `IPv6` environment variable is set
- **OBFS**: Only written to config if `OBFS` environment variable is set
- **OBFS_HOST**: Only written to config if `OBFS=http` and `OBFS_HOST` is set
- **Existing config file**: If `snell-server.conf` already exists (e.g., mounted via volume), it will be used as-is and the script will skip generating a new one

## Docker Images

### Docker Hub

```bash
docker pull 1byte/snell-server
```

### GitHub Container Registry (GHCR)

```bash
docker pull ghcr.io/shuidi-l/snell-server
```

## Build the Image

### Local build:

```bash
# Build with default Snell version (5.0.0)
docker build -t 1byte/snell-server .

# Build with specific Snell version
docker build --build-arg SNELL_VERSION=4.1.1 -t 1byte/snell-server:4.1.1 .
```

### Multi-arch build (requires buildx):

```bash
# Build with default Snell version (5.0.0)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t 1byte/snell-server:latest .

# Build with specific Snell version
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg SNELL_VERSION=4.1.1 \
  -t 1byte/snell-server:v4.1.1 .
```

## Run Examples

### Default config (random port & PSK)

```bash
# Using Docker Hub
docker run --rm 1byte/snell-server

# Using GitHub Container Registry
docker run --rm ghcr.io/shuidi-l/snell-server
```

### Specify port and PSK

```bash
# Using Docker Hub
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  1byte/snell-server

# Using GitHub Container Registry
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  ghcr.io/shuidi-l/snell-server
```

### Enable IPv6

```bash
# Using Docker Hub
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  -e IPv6=true \
  1byte/snell-server

# Using GitHub Container Registry
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  -e IPv6=true \
  ghcr.io/shuidi-l/snell-server
```

### Enable obfuscation with custom host

```bash
# Using Docker Hub
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=http \
  -e OBFS_HOST=my.domain.com \
  1byte/snell-server

# Using GitHub Container Registry
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=http \
  -e OBFS_HOST=my.domain.com \
  ghcr.io/shuidi-l/snell-server
```

### Disable obfuscation

```bash
# Using Docker Hub
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=off \
  1byte/snell-server

# Using GitHub Container Registry
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=off \
  ghcr.io/shuidi-l/snell-server
```

### Complete configuration example

```bash
# Using Docker Hub
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  -e IPv6=true \
  -e OBFS=http \
  -e OBFS_HOST=gateway.icloud.com \
  -e TFO=false \
  1byte/snell-server

# Using GitHub Container Registry
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  -e IPv6=true \
  -e OBFS=http \
  -e OBFS_HOST=gateway.icloud.com \
  -e TFO=false \
  ghcr.io/shuidi-l/snell-server
```

## Run with docker-compose

### Quick start

1. Ensure `docker-compose.yml` is in your working directory
2. Provide environment variables via a `.env` file (recommended) or your shell

Example `.env` (place next to `docker-compose.yml`):

```env
PORT=8234
PSK=mysecurepsk
# IPv6=false
# TFO=true
# OBFS=http
# OBFS_HOST=gateway.icloud.com
```

Start the service:

```bash
docker compose up -d
```

### Use a custom snell-server.conf

If you already have a `snell-server.conf`, mount it and the script will skip auto-generation:

```yaml
services:
  snell-server:
    # ...
    volumes:
      - ./snell-server.conf:/app/snell-server.conf
```

With this volume mount, the container will use your provided config file and ignore environment variables for generation.

## Error Handling

The server validates all input values before starting:

- **Invalid PORT**: Must be an integer between 1025 and 65535
- **Invalid IPv6**: Must be `true` or `false` if provided
- **Invalid OBFS**: Must be `off` or `http` if provided

If any validation fails, the server will display an error message and exit with code 1.

## License

[LICENSE](LICENSE)