# Mongo Express on Railway

A Railway template for [Mongo Express](https://github.com/mongo-express/mongo-express), the web-based admin interface for MongoDB. Use it to browse, edit, import and export the data in the MongoDB your Railway app already uses, or deploy it with its own MongoDB.

## What it deploys

| Service | Source | Notes |
| --- | --- | --- |
| Mongo Express | this repo (`Dockerfile`), `mongo-express:1.0.2-20-alpine3.19` pinned by digest | Public domain, HTTP basic auth, health check `/status` |
| MongoDB | `mongo:7.0.48`, pinned by digest | Private network only, data on a volume at `/data/db` |

Mongo Express keeps no data of its own, so it has no volume.

## Variables

| Variable | Default | What it does |
| --- | --- | --- |
| `ME_CONFIG_MONGODB_URL` | `${{MongoDB.MONGO_URL}}` | The MongoDB to manage, over the private network |
| `ME_CONFIG_BASICAUTH_USERNAME` | `admin` | Login user |
| `ME_CONFIG_BASICAUTH_PASSWORD` | generated secret | Login password |
| `PORT` | `8081` | Port the web UI listens on |

The start script (`railway-start.sh`) refuses to start when the MongoDB URL or the password is empty, when the password is the upstream default `pass` or shorter than 12 characters, or when basic auth is switched off. It sets random session and cookie secrets on each boot unless you set `ME_CONFIG_SITE_SESSIONSECRET` and `ME_CONFIG_SITE_COOKIESECRET` yourself.

### Use it with the MongoDB you already run on Railway

Add the template to your existing project (or deploy it and delete the bundled MongoDB), then set `ME_CONFIG_MONGODB_URL` on the Mongo Express service to a reference to your database, for example `${{MongoDB.MONGO_URL}}`, where `MongoDB` is the name of your MongoDB service. Railway's MongoDB `MONGO_URL` uses the private host `*.railway.internal:27017`, so no traffic leaves Railway's network. Any `mongodb://` or `mongodb+srv://` URL works, including MongoDB Atlas.

Optional settings you can add as variables: `ME_CONFIG_OPTIONS_READONLY=true` (read-only UI), `ME_CONFIG_OPTIONS_NO_DELETE=true` (hide delete buttons), `ME_CONFIG_MONGODB_ENABLE_ADMIN=false` (show only the database in the URL). See the [upstream configuration](https://github.com/mongo-express/mongo-express#usage-docker).

## Updates

The services built from this repo get Railway's "update available" notice when `main` changes. Each change is listed in [CHANGELOG.md](CHANGELOG.md), with breaking changes first. The MongoDB service runs a pinned image and is not updated by the template.
