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
IPv6="${IPv6:-false}"
OBFS="${OBFS:-http}"
OBFS_HOST="${OBFS_HOST:-gateway.icloud.com}"
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
}

print_start_info() {
  echo "==> Starting Snell"
  echo "PORT: ${PORT}"
  echo "PSK: ${PSK}"
  # Print OBFS_HOST if OBFS isn't equal to false
  if [[ "$OBFS" != "false" ]]; then
    echo "OBFS_HOST: ${OBFS_HOST}"
  fi
}

write_config() {
  umask 077
  cat >"$CONF" <<EOF
[snell-server]
listen = 0.0.0.0:${PORT}
psk = ${PSK}
ipv6 = ${IPv6}
obfs = ${OBFS}
obfs-host = ${OBFS_HOST}
tfo = ${TFO}
EOF
}

main() {
  ensure
  write_config
  print_start_info
  exec "$BIN" -c "$CONF"
}

main
