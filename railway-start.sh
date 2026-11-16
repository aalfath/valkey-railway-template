#!/bin/sh
# Start Valkey with a password, persistence on /data and a small HTTP health
# endpoint for Railway's health check. Settings come from the environment:
#   VALKEY_PASSWORD     required; the template generates it
#   VALKEY_PORT         Valkey port, default 6379
#   PORT                health check port, default 8080 (GET /health)
#   VALKEY_EXTRA_FLAGS  optional extra valkey-server flags, for example
#                       "--maxmemory 256mb --maxmemory-policy allkeys-lru"
set -eu

if [ -z "${VALKEY_PASSWORD:-}" ]; then
  echo "VALKEY_PASSWORD is empty. Refusing to start Valkey without a password." >&2
  exit 1
fi

export VALKEY_PORT="${VALKEY_PORT:-6379}"
HEALTH_PORT="${PORT:-8080}"
if [ "$HEALTH_PORT" = "$VALKEY_PORT" ]; then
  echo "PORT ($HEALTH_PORT) must differ from VALKEY_PORT: PORT serves the HTTP health check." >&2
  exit 1
fi

# Write the config at runtime, so the password never shows on the command line.
mkdir -p /etc/valkey
escaped=$(printf '%s' "$VALKEY_PASSWORD" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
umask 077
cat > /etc/valkey/valkey.conf <<CONF
bind * -::*
port ${VALKEY_PORT}
dir /data
requirepass "${escaped}"
appendonly yes
appendfsync everysec
save 3600 1 300 100 60 10000
CONF
chown -R valkey:valkey /etc/valkey

# HTTP health check: 200 when Valkey answers PING (or is still loading data).
( while :; do nc -lk -p "$HEALTH_PORT" -e /usr/local/bin/valkey-health.sh; sleep 1; done ) &

# The official entrypoint fixes /data ownership and drops to the valkey user.
exec docker-entrypoint.sh /etc/valkey/valkey.conf
