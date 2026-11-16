# Mongo Express on Railway: the official image, pinned by version and digest.
# Image source: https://github.com/mongo-express/mongo-express-docker
FROM mongo-express:1.0.2-20-alpine3.19@sha256:1aae0077525133249133d42980ba23998712a1077e02ac0ac295b50a7a79d550

# Clear the image's unsafe defaults (a "mongo" host and the session secret "secret")
# and set Railway-friendly ones. Every value can be overridden with a service variable.
ENV ME_CONFIG_MONGODB_URL="" \
    ME_CONFIG_SITE_SESSIONSECRET="" \
    ME_CONFIG_SITE_COOKIESECRET="" \
    ME_CONFIG_BASICAUTH=true \
    ME_CONFIG_BASICAUTH_USERNAME=admin \
    ME_CONFIG_MONGODB_ENABLE_ADMIN=true \
    ME_CONFIG_CONNECT_RETRIES=60 \
    VCAP_APP_HOST=:: \
    PORT=8081

COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 0755 /usr/local/bin/railway-start.sh

EXPOSE 8081
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/railway-start.sh"]
