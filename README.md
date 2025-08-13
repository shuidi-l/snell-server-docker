# Snell Server Docker Image

A lightweight, multi-architecture (`linux/amd64` and `linux/arm64`) Docker image for Snell Server.  
Supports configuration via environment variables, with secure defaults when not provided: random PSK and random port (>1024).

## Features

-  **Multi-stage build** for a smaller image size
-  **Multi-architecture support**: `linux/amd64`, `linux/arm64`
-  **Configurable via environment variables**
-  **Secure defaults**: random port and random 32-character PSK
-  **Minimal dependencies**: based on `alpine`
-  **Optional obfuscation**: when `OBFS=false`, `obfs-host` will not be written to the config

## Environment Variables

| Variable    | Default Value               | Description                                 |
| ----------- | --------------------------- | ------------------------------------------- |
| `PORT`      | Random 1025–65535           | Listening port                              |
| `PSK`       | Random 32-char alphanumeric | Pre-shared key                              |
| `IPv6`      | `false`                     | Enable IPv6                                 |
| `OBFS`      | `http`                      | Obfuscation mode, set to `false` to disable |
| `OBFS_HOST` | `gateway.icloud.com`        | Obfuscation host, ignored when `OBFS=false` |
| `TFO`       | `true`                      | Enable TCP Fast Open                        |


## Build the Image

### Local build:

```bash
docker build -t 1byte/snell-server .
```



### Multi-arch build (requires buildx):

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t 1byte/snell-server:latest 
```



## Run Examples
### Default config (random port & PSK)

> docker run --rm 1byte/snell-server

### Specify port and PSK

```bash
docker run --rm -p 8234:8234 \
  -e PORT=8234 \
  -e PSK=mysecurepsk \
  1byte/snell-server
```

### Enable obfuscation with custom host

```bash
docker run --rm -p 9000:9000 \
  -e PORT=9000 \
  -e OBFS=http \
  -e OBFS_HOST=my.domain.com \
  1byte/snell-server
```
