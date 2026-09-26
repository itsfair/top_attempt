# AGENTS.md — Serverpod backend "local"

Local Serverpod instance of the `top_attempt` monorepo: **one instance
per business/site (door installation)**. Represents the on-site
operation — self-entry (door access) and later ERP features (course
management, employee management, shift scheduling) — and must keep
running autonomously during short internet outages. Part of the `apps/`
Dart workspace — context and instance model: [`apps/AGENTS.md`](../../AGENTS.md),
monorepo structure: [Root AGENTS.md](../../../AGENTS.md).

## Purpose (target picture)

- Door access authorization: the ESP32 forwards (BLE-received from the
  end-user app) access data to this instance; verification and door
  control happen here. **Without a cloud round trip** — the local
  instance must hold enough data locally (synchronization from the
  global instance, details open).
- Management of devices (ESP32/NUKI), members and access rights —
  operated via the site admin app (`top_attempt_local_flutter`).
- ERP extension step by step: courses, employees, shift scheduling.

## Current state (important!)

Since 2026-09-25 the **site module** is implemented (no longer a pure
mirror):

- **Enrollment**: the local mask verifies with the **global credentials
  of the site admin** at the global instance (`siteSetup.enterSetup` →
  `top_attempt_global_client` → global `siteEnrollment` endpoint; site
  picker if the admin owns several sites).
- **Members directory**: after enrollment the local member row of the
  admin is created (`globalAuthUserId` from the transfer — **exchange
  id**, later also the key for door authorization) and a **local
  AuthUser** is created (email like global, **same password** the admin
  just used; scope `local-admin` — hashed locally via
  `EmailIdp.admin.createEmailAuthentication`). No (!) local
  self-registration: logins are only ever created from verified global
  logins (the same pattern applies later for employees).
- **Device connection**: `GlobalSiteConnection` worker (started in
  `server.dart`): reads the credential and the global API URL
  (`siteConnection.globalApiUrl` in config), client auth with the
  **non-rotating SAS session key** (`AuthStrategy.session`), method
  stream `siteConnection.connect`, ping every 30 s → `lastSeenAt` stays
  fresh at the global backend; reconnect with backoff (5→60 s), state
  machine `noneSetup|connecting|reconnecting|connected|needsReSetup|
  failure` (`needsReSetup` = revoked/expired → local mask; recovery by
  re-running setup with global credentials).
- Config: `siteConnection.globalApiUrl` in `config/development.yaml`
  (dev: `http://localhost:8080`; devices: LAN IP).

Apart from the site module, the backend is still the mirror of the
global one created during the Serverpod-4 upgrade (JWT auth +
`ProfileDetails`), infrastructure (ports/RustFS) see below.

## Ports / infrastructure (dev)
- API 8180, Insights 8181, Web 8182 (`config/development.yaml`)
- Postgres 8190, Redis port 8191 (Redis `enabled: false`), DB name
  `top_attempt`
- RustFS: S3 API 9000, console **9101** (global uses 9001 — both stacks
  can run simultaneously; `container_name: rustfs_server` was removed
  for that reason)
- `top_attempt_local_client`: generated client package; after model
  changes run `serverpod generate` in the server package.

## Running (dev)

```bash
cd apps/backends/local/top_attempt_local_server
docker compose up --build --detach
dart pub get
dart bin/main.dart   # start script with --apply-migrations, see pubspec (serverpod.scripts.start)
```

`serverpod start` starts Docker, the server **and** the site admin app
automatically (`serverpod: flutter_apps:` in the server pubspec,
`device: chrome`). `--no-flutter` suppresses the autostart; apps can be
relaunched any time in the start TUI via Ctrl+R.

## Endpoints (own code)

| Endpoint | Purpose |
|---|---|
| `emailIdp` (`src/auth/email_idp_endpoint.dart`) | Email IdP: local login (registration/member self-signup is intentionally off) |
| `jwtRefresh` (`src/auth/jwt_refresh_endpoint.dart`) | Renew access tokens |
| `profileDetails` (`src/profile/profile_details_endpoint.dart`) | First/last name + birthday (mirror of global) |
| `siteSetup` (`src/site/site_setup_endpoint.dart`) | `enterSetup({email, password, siteId?})` (checks against global, processes transfer: members row + local `local-admin` login) and `connectionStatus()` for the App-Bar chip |
| `greeting` (`src/greetings/…`) | Serverpod sample endpoint |

No `userProfileEdit` endpoint in own code (present in the global
backend) — clarify when building out the members/employee model.

## Data model notes

- `profile_details` mirrors global. **Birthday as UTC-midnight date
  sentinel** (2026-09-25, identical to global): the picked date is
  normalized to `DateTime.utc(year, month, day)` before persistence;
  validation uses UTC calendar days. Reason: the date picker produces
  local midnight; the conversion to UTC (wire/DB) in UT+1 would drift
  the calendar day one back. Client code must always display the UTC
  calendar day of the returned value.
  **Second line of defense**: the server normalization alone is not
  enough — the client serialization is `DateTime.toUtc()`
  (`serverpod_serialization`), so the calendar day is already shifted at
  decode time. The shared `ProfileScreen` sends `DateTime.utc(y, m, d)`
  explicitly (see `apps/frontends/shared/lib/screens/profile_screen.dart`).

## Open questions (next expansion)

1. **Membership sync over the stream**: propagate new/removed global
   `SiteMembership` events into the local `members` table (the WS
   connection is the transport layer; rule: `members.globalAuthUserId` =
   global person id = door authorization key).
2. **Employees**: the member verifies on site with global credentials →
   local login (same model as the admin setup); roles/status changed
   globally via `site-device`-restricted endpoints.
3. **ESP32 protocol**: how does the ESP32 authenticate here (maybe
   outgoing WebSocket client with device token, see docs/project.md →
   TODOs)?
4. **Local admin UI authentication** (`local-admin`): login flow in
   `top_attempt_local_flutter` (currently open — the setup mask exists;
   the member/admin area needs a protection layer).

## Test / CI

- `dart test` (integration tests with
  `test_tools/serverpod_test_tools.dart`).
- CI: `analyze.yml`, `format.yml`, `tests.yml` (Docker compose) —
  versions there are still old (Dart 3.8.0 / CLI 3.3.1), TODO see
  apps/AGENTS.md.

## Continuation

- Next step: membership sync over the WS connection (open question 1),
  then members/employee model + admin UI protection.
- Migrations: base migration `20260923104843538` +
  `20260923112557527-upgrade-4-0` + site module migration
  `20260925151309478` (SiteConnection/Member).
