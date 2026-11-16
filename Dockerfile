# Valkey for Railway: the official image, pinned by version and digest.
# Update by changing this line (and CHANGELOG.md); Railway then offers the
# update to everyone who deployed the template.
FROM valkey/valkey:9.1.3-alpine@sha256:bf09d58e96d6b4524a15396b65b242bbe18beebbcc15a04d8ee75ddac62fae0b

COPY --chmod=0755 railway-start.sh /usr/local/bin/railway-start.sh
COPY --chmod=0755 valkey-health.sh /usr/local/bin/valkey-health.sh

# Valkey port (private network) and the HTTP health check port (PORT).
# Data lives in /data: mount a Railway volume there (Railway rejects VOLUME).
EXPOSE 6379 8080

ENTRYPOINT ["tini", "--", "/usr/local/bin/railway-start.sh"]
