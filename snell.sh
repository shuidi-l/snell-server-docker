#!/usr/bin/env bash
set -eu

BIN="/app/snell-server"
CONF="./snell-server.conf"

random_port() {
  NUM="$(od -An -N2 -tu2 /dev/urandom 2>/dev/null | tr -d ' ' || true)"
  : "${NUM:=$$}"  # if NUM is null, Get the current process ID
  echo $(( (NUM % 64511) + 1025 ))
}
# 
PORT="${PORT:-$(random_port)}"
PSK="${PSK:-$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)}"
# Only set optional values if provided via environment; otherwise keep empty
IPv6="${IPv6-}"
OBFS="${OBFS-}"
OBFS_HOST="${OBFS_HOST-}"
TFO="${TFO:-true}"

ensure() {
  case "${PORT:-}" in
    ''|*[!0-9]*)
      echo "Invalid PORT: ${PORT:-<empty>} (must be an integer 1025–65535)" >&2
      exit 1
      ;;
  esac

  if [ "$PORT" -lt 1025 ] || [ "$PORT" -gt 65535 ]; then
    echo "PORT out of range: ${PORT} (must be 1025–65535)" >&2
    exit 1
  fi

  # Validate IPv6 value if provided
  if [[ -n "${IPv6}" ]]; then
    case "${IPv6}" in
      true|false)
        # Valid value, continue
        ;;
      *)
        echo "Invalid IPv6: ${IPv6} (must be 'true' or 'false')" >&2
        exit 1
        ;;
    esac
  fi

  # Validate OBFS value if provided
  if [[ -n "${OBFS}" ]]; then
    case "${OBFS}" in
      off|http)
        # Valid value, continue
        ;;
      *)
        echo "Invalid OBFS: ${OBFS} (must be 'off' or 'http')" >&2
        exit 1
        ;;
    esac
  fi
}

print_start_info() {
  echo "==> Starting Snell"
  echo "PORT: ${PORT}"
  echo "PSK: ${PSK}"
  # Print optional fields only when set
  if [[ -n "${IPv6}" ]]; then
    echo "IPv6: ${IPv6}"
  fi
  if [[ -n "${OBFS}" ]]; then
    echo "OBFS: ${OBFS}"
  fi
  if [[ "${OBFS}" == "http" && -n "${OBFS_HOST}" ]]; then
    echo "OBFS_HOST: ${OBFS_HOST}"
  fi
}

write_config() {
  # If a config is already provided (e.g., mounted via volume), do not overwrite
  if [[ -e "$CONF" ]]; then
    echo "==> Using existing config: $CONF (skipping generation)"
    return 0
  fi
  umask 077
  cat >"$CONF" <<EOF
[snell-server]
listen = 0.0.0.0:${PORT}
psk = ${PSK}
EOF

  # Conditionally write optional fields
  if [[ -n "${IPv6}" ]]; then
    echo "ipv6 = ${IPv6}" >>"$CONF"
  fi

  if [[ -n "${OBFS}" ]]; then
    echo "obfs = ${OBFS}" >>"$CONF"
    if [[ "${OBFS}" == "http" && -n "${OBFS_HOST}" ]]; then
      echo "obfs-host = ${OBFS_HOST}" >>"$CONF"
    fi
  fi

  echo "tfo = ${TFO}" >>"$CONF"
}

main() {
  ensure
  write_config
  print_start_info
  exec "$BIN" -c "$CONF"
}

main
