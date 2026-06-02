# ---- build stage: compile native modules (canvas, sqlite3) + fetch sharp prebuilt ----
FROM node:22-alpine AS build

ENV NODE_ENV=production
WORKDIR /quickchart

# Build toolchain + -dev headers needed only to compile native addons.
RUN apk add --no-cache \
    build-base g++ python3 py3-setuptools yarn git \
    cairo-dev pango-dev libjpeg-turbo-dev librsvg-dev pixman-dev libimagequant-dev

COPY package*.json yarn.lock ./
RUN yarn install --production && yarn cache clean

# ---- runtime stage: runtime shared libs only (no -dev, no build tools) ----
FROM node:22-alpine

ENV NODE_ENV=production
WORKDIR /quickchart

# Patch OS packages to latest to reduce base-image CVEs.
RUN apk upgrade --no-cache

# Runtime .so deps for the canvas native addon. sharp 0.34 ships its own libvips
# via @img/* (copied in node_modules), so no system vips package is needed.
RUN apk add --no-cache \
    cairo pango libjpeg-turbo librsvg pixman libimagequant \
    graphviz sqlite \
    ttf-dejavu ttf-droid ttf-freefont ttf-liberation font-noto font-noto-emoji fontconfig
RUN apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/community font-wqy-zenhei

COPY --from=build /quickchart/node_modules ./node_modules
COPY package*.json yarn.lock ./
COPY *.js ./
COPY lib/*.js lib/
COPY LICENSE .

# Run as the unprivileged built-in `node` user; give it a writable DB dir.
RUN mkdir -p /var/lib/db && chown -R node:node /var/lib/db
VOLUME /var/lib/db/
EXPOSE 3400

USER node

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3400/healthcheck >/dev/null 2>&1 || exit 1

ENTRYPOINT ["node", "--max-http-header-size=65536", "--experimental-global-webcrypto", "index.js"]
