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
mirror); person model **rebuilt 2026-10-02** to the final uniform design:

- **Enrollment**: the local mask verifies with the **global credentials
  of the site admin** at the global instance (`siteSetup.enterSetup` →
  `top_attempt_global_client` → global `siteEnrollment` endpoint; site
  picker if the admin owns several sites).
- **Person model = `member_profile` (as global)**: one row per person of
  the site — same model shape as the global instance, with an OPTIONAL
  `authUser` module link (only site admin/staff have local logins) and a
  required unique `globalAuthUserId` (exchange id + door-flow key +
  image-object key). The old `memberships`/`profile_details` tables are
  gone; a local membership mirror table comes with the sync round.
- **Local login for the site admin**: created at enrollment (local
  AuthUser, new random id — "id egal"; email like global, **same
  password** the admin just used; scope `local-admin` — hashed locally
  via `EmailIdp.admin.createEmailAuthentication`) and linked on the
  member_profile copy. No (!) local self-registration: logins are only
  ever created from verified global logins (same pattern for employees
  later).
- **Image transfer (fail-fast, no fallback)**: at fresh setup the bytes
  are downloaded **first** (server-to-server from the global
  `member_profile.imageUrl`) — a failure aborts the whole enrollment;
  then one DB transaction (AuthUser + email login + member_profile copy)
  and the upload into the local RustFS at the same deterministic path
  `member_images/<globalAuthUserId>.jpg` (overwrite semantics, URL →
  profile copy). Later, a plain member's image is mirrored from global
  at the same path pattern; a member→user conversion needs **no image
  move** (all images of a person always live under
  `member_images/<globalAuthUserId>.jpg`).
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
global one created during the Serverpod-4 upgrade (JWT auth), being the
INFRASTRUCTURE basis (ports/RustFS) documented below. The built-in
Serverpod UserProfile feature is bypassed (like global); the auth module
still creates its own profile tables at login/registration internally —
unused residue.

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
| `memberProfile` (`src/site/member_profile_endpoint.dart`) | Own person endpoints (mirror of global): `get`, `save` (names/birthday), `setUserImage`, `removeUserImage` — for locally logged-in persons (site admin/staff) |
| `siteSetup` (`src/site/site_setup_endpoint.dart`) | `enterSetup({email, password, siteId?})` (checks against global, processes transfer: member_profile copy + local `local-admin` login + fail-fast image) + `adminInfo()` (connection/site snapshot/admin person data) + `connectionStatus()` for the App-Bar chip |
| `greeting` (`src/greetings/…`) | Serverpod sample endpoint (candidate for removal) |

The built-in Serverpod UserProfile feature is bypassed (like global) —
the auth module's own profile tables are unused residue.

## Data model notes

- **`member_profile` (final design 2026-10-02, symmetric to global)**:
  one row per person; `authUserId` optional (only local users
  (siteAdmin/staff) have a login account; `onDelete=SetNull`),
  **`globalAuthUserId` required + unique** (exchange/door/image-object
  key), mirrored `email` (required — duplicate of the auth mail,
  accepted), `firstName`/`lastName`/`birthday`/`imageUrl`
  (mirror of the global member_profile; "profiles are edited globally
  only" — sync rule).
- **Images**: `member_images/<globalAuthUserId>.jpg` (deterministic, one
  object per person, overwrite on change, JPEG-only for now). Fail-fast
  transfer at enrollment (no fallback); plain members: mirrored from
  global on sync; a member→user conversion needs NO image move (same
  path for every person of both types) — only the image row/profile
  linkage is updated via native module methods.
- **Birthday as UTC-midnight date sentinel**: values travel as
  `DateTime.utc(y, m, d)`; the backend validates against UTC calendar
  days only — NO server-side re-normalization (client convention;
  documented in the shared frontend).

## Open questions (next expansion)

1. **Membership sync over the stream**: propagate new/removed global
   `SiteMembership` events into the local `member_profile` copies
   (image: download from global URL into the same local path; rule:
   `member_profile.globalAuthUserId` = global person id = door
   authorization key). A local membership-mirror table (role/active
   alignment) is part of that round.
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
- Migrations: **history rebuilt 2026-10-02** (fresh base migration
  `20261002122115491` after the member_profile redesign; the database
  volumes were wiped). **Existing enrollment data requires re-setup**
  (fresh DB anyway).
- Profile image serving caveat: Flutter-web display of local RustFS
  images requires CORS on the local RustFS instance (console :9101).
- Security TODOs (see apps/AGENTS.md): presigned/short-lived image URLs
  for the enrollment transfer instead of raw capability URLs, HTTPS for
  all transfers in production, RustFS stays LAN-only.
