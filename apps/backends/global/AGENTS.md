# AGENTS.md — Serverpod backend "global"

Central Serverpod instance of the `top_attempt` monorepo: the single
platform level on which end users create accounts and maintain their
profiles. Part of the `apps/` Dart workspace — context and instance
model: [`apps/AGENTS.md`](../../AGENTS.md), monorepo structure:
[Root AGENTS.md](../../../AGENTS.md).

## Purpose

- Registration/login of end users (email + password) and password reset.
- Central profiles (name, birthday, profile image) — data basis that
  local instances later synchronize member data from.
- Later possibly global entities (e.g. course catalog — open, see
  apps/AGENTS.md → "Open architecture questions").
- Partner apps: `apps/frontends/top_attempt_global_flutter` (platform
  admin) and `top_attempt_enduser_flutter` (full-fledged).

## Layout / ports

- Serverpod 4.0.2; dev ports: API 8080, Insights 8081, Web 8082
  (`config/development.yaml`); Postgres 8090, Redis port 8091
  (Redis `enabled: false`).
- `top_attempt_global_client`: generated client package, used by the
  frontends as path dependency. After model changes run
  `serverpod generate` in the server package.

## Running (dev)

```bash
cd apps/backends/global/top_attempt_global_server
docker compose up --build --detach
dart pub get
dart bin/main.dart   # start script with --apply-migrations, see pubspec (serverpod.scripts.start)
```

`serverpod start` starts Docker, the server **and** the platform admin
app automatically (`serverpod: flutter_apps:` in the server pubspec,
`device: chrome`). `--no-flutter` suppresses the autostart; apps can be
relaunched any time in the start TUI via Ctrl+R. The end-user app is
intentionally not configured — it runs separately on a physical Android
device.

## Endpoints (own code)

| Endpoint | Purpose |
|---|---|
| `emailIdp` (`src/auth/email_idp_endpoint.dart`) | Email IdP: registration, login, password reset (verification codes are only logged in dev) |
| `jwtRefresh` (`src/auth/jwt_refresh_endpoint.dart`) | Renew access tokens |
| `userProfileEdit` (`src/auth/user_profile_edit_endpoint.dart`) | Email/user ID/profile image via the built-in auth module |
| `profileDetails` (`src/profile/profile_details_endpoint.dart`) | First/last name + birthday; requireLogin, name 1–60 chars, birthday 1900–yesterday; name is written synchronously into the UserProfile |
| `usersAdmin` (`src/admin/users_admin_endpoint.dart`) | Platform admin: `listUsers` (50/page, email/name ILIKE filter), `getUser`, `setBlocked`, `setGlobalAdmin`, own `UserAdminException` |
| `sitesAdmin` (`src/sites/sites_admin_endpoint.dart`) | Platform admin, sites ("Betriebe"): `createSite` (validation), `listSites`/`countSites` (50/page, search), `getSite`, `revokeSiteConnection` |
| `siteEnrollment` (`src/sites/site_enrollment_endpoint.dart`) | Public: `listSiteAdminCandidates` + `enroll({email, password, siteId?})` for the local instance |
| `siteConnection` (`src/sites/site_connection_endpoint.dart`) | Device connection method stream (`connect(Stream<SitePing>) → Stream<SiteEvent>`), scope `site-device` |
| `greeting` (`src/greetings/…`) | Serverpod sample endpoint |

### Site setup / enrollment (as of 2026-09-25)

- Models: `Site` (table `sites`: address, `companyEmail`, `status` enum
  `pendingSetup|registered`, `firstAdmin` relation, `registeredAt`/
  `lastSeenAt`), `SiteMembership` (table `site_memberships`: site +
  authUser + `role` enum `member|staff|siteAdmin` + `active`) — global
  source-of-truth directory of memberships. `SiteDeviceSession` (table
  `site_device_sessions`: site ↔ SAS session id, exactly one active
  session per site).
- `createSite` generates **no secrets anymore**: the site admin sets up
  the local instance on site with their **global credentials** (the old
  one-time-password / initial-password machinery was removed).
- `SiteEnrollmentEndpoint` (public):
  `listSiteAdminCandidates` + `enroll({email, password, siteId?})` —
  verifies the global credentials via the email IdP logic (rate
  limit/blocked checks inherited, no login session is created there),
  resolves the active `siteAdmin` membership (multiple →
  `requiresSiteSelection` + candidates for the site picker in the local
  mask), then:
  - fresh setup: site → `registered` + `registeredAt`, transfer (site +
    admin email/name + `adminAuthUserId` — **exchange id for the local
    members table, later the key for door authorization**) and the
    device session key.
  - recovery: same verification path without transfer data; the previous
    `SiteDeviceSession` is revoked and replaced. The local admin can
    re-run setup alone (no platform-admin involvement needed).
  - device credential: SAS session (`method: 'device'`, token-level
    scope `site-device`, `AuthStrategy.session`, non-rotating,
    write-once on the local side; no rotation/crash-window issues).
    Pepper key: `serverSideSessionKeyHashPepper` (passwords.yaml,
    dev+test).
  - `sitesAdmin.revokeSiteConnection(siteId)`: revokes the device
    enrollment (site data/memberships kept).
- `SiteConnectionEndpoint` (`requiredScopes: {site-device}`): method
  stream `connect(Stream<SitePing>) → Stream<SiteEvent>`; every ping
  refreshes `lastSeenAt` (site resolved from the mapping row via
  `session.authenticated!.authId`). Block hygiene: `usersAdmin.setBlocked`
  additionally revokes all `device` sessions of the user (SAS
  verification does not check `blocked` per request).
- Identity provider access: `AuthServices.getIdentityProvider<EmailIdp>()`
  (from `providers/email.dart`); password verification without token
  issuance via `emailIdp.utils.authentication.authenticate`.
- Auth services registration: second TokenManagerBuilder
  (`SiteDeviceAuthentication.config`) next to JWT; pepper
  `serverSideSessionKeyHashPepper` in passwords.yaml (dev/test; CI via
  SERVERPOD_PASSWORD_* env — TODO).

### Known & harmless log entries with device connections

- `Invalid JWT access token — JWTInvalidException: token does not use
  JWS Compact Serialization` (debug level): expected. The auth pipeline
  tries token managers in order; JWT is primary (because the identity
  providers issue via the primary manager), so a SAS session key first
  fails the JWT handler (logged at debug) and is then successfully
  validated by the server-side session manager. No action needed; out of
  scope until upstream supports quiet-flags for non-JWT keys.
- A persistent `STREAM siteConnection.connect …` entry while a site is
  connected: that is the session logging of the (long-lived) method
  stream — it is open as long as the local instance is connected. Not an
  error. If unwanted in dev, reduce `sessionLogs` (costs insights data).

### Admin scopes (2026-09-24)

- `kGlobalAdminScope = 'global-admin'` (`src/auth/scopes.dart`); admin
  endpoints enforce it **declaratively** via `Endpoint.requiredScopes`
  (Serverpod dispatch checks `session.authenticated.scopes` from the JWT).
- Scopes live on the `AuthUser` (`serverpod_auth_core_user.scope_names`)
  and are **baked into access and refresh tokens at login**.
  `rotateRefreshToken` re-reads only `blocked` during rotation, **not the
  scopes** — running sessions see scope changes only when tokens are
  revoked or a new login happens. Therefore `setBlocked`/`setGlobalAdmin`
  call `revokeAllTokens` + `authenticationRevoked` after the update.
- Self-protection in the endpoints: blocking yourself is rejected; your
  own `global-admin` scope cannot be revoked (otherwise self-lockout
  with no way back). The **first admin** remains a dev-SQL update
  (`scope_names` on `serverpod_auth_core_user`) + re-login.

Auth setup in `lib/server.dart` (`initializeAuthServices`: JWT +
ServerSideSessions + EmailIdp; codes are logged instead of emailed).
RustFS storage is registered as storage id `public` (bucket
`top-attempt`), endpoint from the `rustFS:` block of the stage config —
**do not set `publicHost`** (adapter bug v1.0.0, see root AGENTS.md).

## Data model

- Own table `profile_details` (`src/profile/profile_details.spy.yaml`):
  `authUserId`, first/last name, birthday. Required fields name +
  birthday, image optional and in the `UserProfile`.
- **Birthday as UTC-midnight date sentinel** (2026-09-25): a picked date
  is normalized server-side to `DateTime.utc(year, month, day)` before
  persistence and `profileDetails.save` validates against UTC calendar
  days (`DateTime.timestamp()`/`DateTime.utc`). Reason: the date picker
  produces local midnight; converted to UTC (wire/DB) a January date in
  UT+1 would drift one day back (26.01 → stored 25.01). Display/client
  code must always use the UTC calendar day of the returned value
  (values come back as UTC). German-market only (UT+1/+2) today.
  **Second line of defense**: the server normalization alone is not
  enough — the client serialization is `DateTime.toUtc()`
  (`serverpod_serialization`), so by decode time the calendar day is
  already shifted. The shared `ProfileScreen` therefore sends
  `DateTime.utc(y, m, d)` explicitly (see
  `apps/frontends/shared/lib/screens/profile_screen.dart`).
- Remaining auth data lives in the Serverpod auth module tables.

## File storage

RustFS (S3 API), dev: LAN IP from `config/development.yaml` → port 9001
(console), S3 on 9000, credentials rustfsadmin / rustfsadmin_secret.
Enable CORS on the bucket when Flutter web accesses files directly.

## Test / CI

- `dart test` (integration tests with
  `test_tools/serverpod_test_tools.dart`).
- CI: `analyze.yml`, `format.yml`, `tests.yml` (Docker compose) —
  versions there are still old (Dart 3.8.0 / CLI 3.3.1), TODO see
  apps/AGENTS.md.

## State / continuation

- State: MVP base — auth + profile + storage work against the end-user
  app; verified state after the Serverpod 4.0.2 upgrade (2026-09-23),
  see apps/AGENTS.md → upgrade section.
- 2026-09-24: first admin endpoint set done (`usersAdmin`: paginated
  user list 50/page with email/name search, blocked and global-admin
  toggles incl. token revocation; self-lockout protection). Serves the
  Members page of the platform admin app.
- 2026-09-25: site creation + enrollment done (`sitesAdmin.createSite`
  without secrets, `siteEnrollment` (global credential verify, site
  picker, device session issuance SAS `method: 'device'`, scope
  `site-device` token-level), `SiteConnectionEndpoint` stream,
  `SiteDeviceSession` mapping, migrations `20260925122822442` +
  `20260925150857366`).
- Next steps (stage 3, details in apps/AGENTS.md → TODOs): membership
  sync over the WS connection (propagate new/removed members), live
  status push to admin clients (message central), local members/
  employees expansion, ESP32 device authorization.
