#!/bin/sh
# One HTTP request on stdin, one response on stdout (run by nc -e).
read -r _request || true
reply=$(REDISCLI_AUTH="${VALKEY_PASSWORD:-}" timeout 3 valkey-cli --no-auth-warning -h 127.0.0.1 -p "${VALKEY_PORT:-6379}" ping 2>&1 || true)
case "$reply" in
  *PONG*|*LOADING*) status="200 OK"; body="ok" ;;
  *) status="503 Service Unavailable"; body="valkey not ready" ;;
esac
printf 'HTTP/1.1 %s\r\nContent-Type: text/plain\r\nContent-Length: %s\r\nConnection: close\r\n\r\n%s\n' "$status" "$((${#body} + 1))" "$body"
