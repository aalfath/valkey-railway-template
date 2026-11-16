# Valkey on Railway

A Railway template for [Valkey](https://valkey.io), the BSD-licensed, Redis-compatible key-value store from the Linux Foundation. It is meant as a cache, queue or session store for apps you already run on Railway, and it is a drop-in replacement for Railway's Redis: it exposes the same `REDIS_URL`, `REDISHOST`, `REDISPORT`, `REDISUSER` and `REDISPASSWORD` variables.

**Version:** Valkey 9.1.3, official image `valkey/valkey:9.1.3-alpine@sha256:bf09d58e96d6b4524a15396b65b242bbe18beebbcc15a04d8ee75ddac62fae0b`.

## What the template deploys

One service, built from this repo's `Dockerfile`:

- Valkey on port `6379` on Railway's private network (IPv4 and IPv6), with a password generated at deploy time. It never starts without one.
- Persistence on a volume at `/data`: append-only file (`appendfsync everysec`) plus RDB snapshots, so data survives redeploys and restarts.
- A TCP proxy for access from outside Railway (`REDIS_PUBLIC_URL`). Remove it in the service's settings if only your Railway services need Valkey.
- A small HTTP health endpoint on `PORT` (`8080`, `GET /health`) that answers 200 once Valkey replies to `PING`. Railway uses it as the deploy health check, so a broken deploy never shows as healthy.

## Connect your app

In your app service's variables, reference Valkey's (the service is named `Valkey`):

```env
REDIS_URL=${{Valkey.REDIS_URL}}
```

`REDIS_URL` is `redis://default:PASSWORD@valkey.railway.internal:6379` and stays on the private network. If your app wants separate settings, use `${{Valkey.REDISHOST}}`, `${{Valkey.REDISPORT}}`, `${{Valkey.REDISUSER}}` and `${{Valkey.REDISPASSWORD}}`. Apps that run on Alpine/musl and resolve only IPv4 work too, because Valkey listens on both stacks.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `VALKEY_PASSWORD` | generated, 32 characters | Password for the `default` user |
| `VALKEY_PORT` | `6379` | Valkey port on the private network |
| `PORT` | `8080` | HTTP health check port (must differ from `VALKEY_PORT`) |
| `REDIS_URL`, `VALKEY_URL` | private URL | Connection URL on the private network |
| `REDIS_PUBLIC_URL` | TCP proxy URL | Connection URL from outside Railway |
| `REDISHOST`, `REDISPORT`, `REDISUSER`, `REDISPASSWORD` | references | The same settings one by one, named like Railway's Redis |

Optional: set `VALKEY_EXTRA_FLAGS` to pass more `valkey-server` flags, for example `--maxmemory 256mb --maxmemory-policy allkeys-lru` for a pure cache.

## Updates

The template builds from this repo's `main` branch. When the pinned Valkey version changes here, Railway shows an "update available" notice on every project deployed from the template, and you choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) first: breaking changes are listed at the top of each entry.

## Run it locally

```sh
docker build -t valkey-railway .
docker run --rm -e VALKEY_PASSWORD=change-me -p 6379:6379 -p 8080:8080 -v valkey-data:/data valkey-railway
```

## License

The wrapper files in this repo are MIT. Valkey itself is [BSD-3-Clause](https://github.com/valkey-io/valkey/blob/unstable/COPYING).
