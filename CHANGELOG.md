# Changelog

## 1.0.2-1 (2026-11-16)

First release.

- Mongo Express 1.0.2 (`mongo-express:1.0.2-20-alpine3.19@sha256:1aae0077525133249133d42980ba23998712a1077e02ac0ac295b50a7a79d550`).
- Basic auth is always on; the start script refuses an empty password, the upstream default `pass`, or a password under 12 characters.
- Session and cookie secrets are random per boot unless set; the image's default session secret `secret` is never used.
- Health check at `/status`, listens on `PORT` (default 8081) over IPv4 and IPv6.
