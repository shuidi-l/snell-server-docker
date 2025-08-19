<p align="center">
  <a>English</a> | <a href="https://github.com/shuidi-l/snell-server/blob/main/README.zh_CN.md">中文</a>
</p>

# Snell Server Docker Image

A lightweight, multi-architecture (`linux/amd64` and `linux/arm64`) Docker image for Snell Server.  
Supports configuration via environment variables, with secure defaults when not provided: random PSK and random port (>1024).

## Features

- **Multi-stage build** for a smaller image size
- **Multi-architecture support**: `linux/amd64`, `linux/arm64`
- **Configurable via environment variables**
- **Secure defaults**: random port and random 32-character PSK
- **Minimal dependencies**: based on `alpine`
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

## Build the Image

### Local build:

```bash
docker build -t 1byte/snell-server .
```

### Multi-arch build (requires buildx):

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t 1byte/snell-server:latest .
```

## Run Examples

### Default config (random port & PSK)

```bash
docker run --rm 1byte/snell-server
```

### Specify port and PSK

```bash
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  1byte/snell-server
```

### Enable IPv6

```bash
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  -e IPv6=true \
  1byte/snell-server
```

### Enable obfuscation with custom host

```bash
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=http \
  -e OBFS_HOST=my.domain.com \
  1byte/snell-server
```

### Disable obfuscation

```bash
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e PSK=mysecurepsk \
  -e OBFS=off \
  1byte/snell-server
```

### Complete configuration example

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
