# Changelog

## 9.1.3-1 (2026-11-16)

- No breaking changes. README only: adds the Deploy on Railway button, linked to the published template `valkey-3`. Valkey stays at 9.1.3, so applying this update rebuilds the same image.

## 9.1.3 (2026-11-16)

- First release of the template: Valkey 9.1.3 (`valkey/valkey:9.1.3-alpine`, pinned by digest), password required, AOF and RDB persistence on `/data`, HTTP health check on `PORT`, Redis-style connection variables.
