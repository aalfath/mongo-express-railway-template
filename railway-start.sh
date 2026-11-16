#!/bin/bash
# Start wrapper for Mongo Express on Railway.
# It refuses to start without a MongoDB URL or a real login, generates the
# session secrets when they are not set, then runs the image's own entrypoint.
set -euo pipefail

fail() { echo "railway-start: $*" >&2; exit 1; }
rand() { node -e 'process.stdout.write(require("crypto").randomBytes(32).toString("hex"))'; }

: "${ME_CONFIG_MONGODB_URL:=}"
: "${ME_CONFIG_BASICAUTH:=true}"
: "${ME_CONFIG_BASICAUTH_USERNAME:=}"
: "${ME_CONFIG_BASICAUTH_PASSWORD:=}"
: "${ME_CONFIG_SITE_SESSIONSECRET:=}"
: "${ME_CONFIG_SITE_COOKIESECRET:=}"

[ -n "$ME_CONFIG_MONGODB_URL" ] || fail 'ME_CONFIG_MONGODB_URL is empty. Set it to your MongoDB connection string, for example ${{MongoDB.MONGO_URL}} in a project that has Railway MongoDB.'
case "$ME_CONFIG_MONGODB_URL" in
  mongodb://*|mongodb+srv://*) ;;
  *) fail "ME_CONFIG_MONGODB_URL must start with mongodb:// or mongodb+srv://." ;;
esac
[ "${ME_CONFIG_BASICAUTH,,}" = "true" ] || fail "ME_CONFIG_BASICAUTH must stay true: the UI has full read and write access to MongoDB."
[ -n "$ME_CONFIG_BASICAUTH_USERNAME" ] || fail "ME_CONFIG_BASICAUTH_USERNAME is empty."
[ -n "$ME_CONFIG_BASICAUTH_PASSWORD" ] || fail "ME_CONFIG_BASICAUTH_PASSWORD is empty."
[ "$ME_CONFIG_BASICAUTH_PASSWORD" != "pass" ] || fail "ME_CONFIG_BASICAUTH_PASSWORD is the upstream default 'pass'. Use a real password."
[ "${#ME_CONFIG_BASICAUTH_PASSWORD}" -ge 12 ] || fail "ME_CONFIG_BASICAUTH_PASSWORD must be at least 12 characters."

# Sessions live in memory, so per-boot secrets only log users out on a restart.
if [ -z "$ME_CONFIG_SITE_SESSIONSECRET" ] || [ "$ME_CONFIG_SITE_SESSIONSECRET" = "secret" ]; then
  ME_CONFIG_SITE_SESSIONSECRET=$(rand)
fi
[ -n "$ME_CONFIG_SITE_COOKIESECRET" ] || ME_CONFIG_SITE_COOKIESECRET=$(rand)

export ME_CONFIG_MONGODB_URL ME_CONFIG_BASICAUTH ME_CONFIG_BASICAUTH_USERNAME ME_CONFIG_BASICAUTH_PASSWORD \
       ME_CONFIG_SITE_SESSIONSECRET ME_CONFIG_SITE_COOKIESECRET

cd /app
exec /docker-entrypoint.sh mongo-express
