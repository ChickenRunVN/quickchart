# Security Policy

This is a maintained fork of [typpo/quickchart](https://github.com/typpo/quickchart).

## Reporting a vulnerability

Open a [GitHub security advisory](https://github.com/ChickenRunVN/quickchart/security/advisories/new)
or a private issue. Please do not disclose publicly until a fix is available.

## Self-host hardening

QuickChart renders charts from configs supplied by the caller. Harden any
instance reachable by untrusted clients:

- **`DISABLE_JS_CHARTS=1`** — chart configs that are not strict JSON are
  evaluated via `new Function` (a JavaScript "function config" feature). This is
  **not a sandbox**: a hostile config can reach Node globals (`process`, …) and
  achieve remote code execution. Set this to accept JSON-only configs and refuse
  JS function configs. Leave it unset only for trusted/internal callers.
- **`RATE_LIMIT_PER_MIN=<n>`** — enable per-IP rate limiting on the render
  endpoints (`/chart`, `/graphviz`, `/qr`, `/gchart`); off by default.
- **`QUICKCHART_API_KEY=<secret>`** — require this key (via the `x-api-key`
  header or `?key=`) on the render endpoints. `/healthcheck` and `/` stay open.
  Unset = open (default).
- **Network isolation** — prefer running behind a reverse proxy / internal
  network rather than exposing the container port directly to the internet.
- **Telemetry** — remote telemetry to quickchart.io is **off by default**; it is
  opt-in via `ENABLE_TELEMETRY_SEND=1`.
- The image runs as a non-root user and ships a `HEALTHCHECK`.

## Supported versions

Only the latest `master` of this fork is supported.
