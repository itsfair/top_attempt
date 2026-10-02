# AGENTS.md — Serverpod backend "global"

Central Serverpod instance of the `top_attempt` monorepo: the single
platform level on which end users create accounts and maintain their
profiles. Part of the `apps/` Dart workspace — context and instance
model: [`apps/AGENTS.md`](../../AGENTS.md), monorepo structure:
[Root AGENTS.md](../../../AGENTS.md).

## Purpose

- Registration/login of end users (email + password) and password reset.
- Own person/profile model `member_profile` (see below) — the data basis
  local instances synchronize from (site admins, member profiles).
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
| `memberProfile` (`src/profile/member_profile_endpoint.dart`) | Own person/profile endpoints: `get`, `save` (names 1–60 chars + birthday), `setUserImage`, `removeUserImage` |
| `usersAdmin` (`src/admin/users_admin_endpoint.dart`) | Platform admin: `listUsers` (50/page, email/name ILIKE filter), `getUser`, `setBlocked`, `setGlobalAdmin`, own `UserAdminException` |
| `sitesAdmin` (`src/sites/sites_admin_endpoint.dart`) | Platform admin, sites ("Betriebe"): `createSite`, `listSites`/`countSites` (50/page, search), `getSite`, `revokeSiteConnection` |
| `siteEnrollment` (`src/sites/site_enrollment_endpoint.dart`) | Public: `listSiteAdminCandidates` + `enroll({email, password, siteId?})` for the local instance |
| `siteConnection` (`src/sites/site_connection_endpoint.dart`) | Device connection method stream (`connect(Stream<SitePing>) → Stream<SiteEvent>`), scope `site-device` |
| `greeting` (`src/greetings/…`) | Serverpod sample endpoint (candidate for removal) |

## member_profile (own person model — since 2026-10-02)

The built-in Serverpod UserProfile feature is **bypassed by design**;
we maintain our own person directory instead (uniform with the local
instance's copy):

- Table `member_profile`: `authUser` (module AuthUser relation; row is
  created **sparse at registration** via the
  `EmailIdpConfig.onAfterAccountCreated` hook incl. the email
  duplicate), `email` (accepted duplicate — the ONLY intended one vs.
  auth tables), `firstName`/`lastName` (1–60 chars), `birthday`
  (UTC-midnight date sentinel), `imageUrl` (RustFS public URL),
  `createdAt`. Unique index on `authUserId`.
- Images: `member_images/<authUserId>.jpg` — **deterministic, one object
  per person, overwrite on change** (`session.storage.storeFile`
  replaces existing paths; no random suffix, no magic-byte detection:
  uploads are JPEG-only because the shared frontend's image picker
  produces JPEG bytes; format extension = deliberate TODO).
- Birthday convention: values travel as **UTC-midnight sentinels** (the
  shared frontend sends `DateTime.utc(y, m, d)`); the backend validates
  against UTC calendar days only — no server-side re-normalization (the
  earlier server-side fix was dropped; the bug was client-side, see
  `apps/frontends/shared/lib/screens/profile_screen.dart`).
- Old tables/endpoints removed: `profile_details`/
  `ProfileDetailsEndpoint`/`userProfileEdit` are gone (the Serverpod
  module still writes its own profile tables at registration — unused
  residue, we never read them).
- Site linkage: `SiteMembership.profile` FK → `member_profile`
  (membership links the person via the directory, not the auth user).

### Site setup / enrollment (as of 2026-09-25/26)

- Models: `Site` (table `sites`: address, `companyEmail`, `status`
  enum `pendingSetup|registered`, `firstAdmin` relation,
  `registeredAt`/`lastSeenAt`), `SiteMembership` (table
  `site_memberships`: site + profile → `member_profile` + `role` enum
  `member|staff|siteAdmin` + `active`) — global source-of-truth
  directory of memberships. `SiteDeviceSession` (table
  `site_device_sessions`: site ↔ SAS session id, exactly one active
  session per site).
- `createSite` generates **no secrets**: the site admin sets up the
  local instance on site with their **global credentials**; the
  membership seeds via the admin's `member_profile` row
  (`SiteAdminException` if that row is missing).
- `SiteEnrollmentEndpoint` (public):
  `listSiteAdminCandidates` + `enroll({email, password, siteId?})` —
  verifies the global credentials via the email IdP logic (rate
  limit/blocked checks inherited, no login session created there),
  resolves the active `siteAdmin` membership (multiple →
  `requiresSiteSelection` + candidates for the site picker in the local
  mask), then:
  - fresh setup: site → `registered` + `registeredAt`; transfer (site
    snapshot incl. address/company mail/status/registeredAt +
    member-profile mirror fields: email, names, birthday, `imageUrl`)
    and the device session key.
  - recovery: same verification path without transfer data; the
    previous `SiteDeviceSession` is revoked and replaced. The local
    admin can re-run setup alone (no platform-admin involvement).
  - device credential: SAS session (`method: 'device'`, token-level
    scope `site-device`, `AuthStrategy.session`, non-rotating,
    write-once on the local side). Pepper key:
    `serverSideSessionKeyHashPepper` (passwords.yaml, dev+test).
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
  validated by the server-side session manager. No action needed.
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
ServerSideSessions + EmailIdp incl. the member_profile hook; codes are
logged instead of emailed). RustFS storage is registered as storage id
`public` (bucket `top-attempt`), endpoint from the `rustFS:` block of
the stage config — **do not set `publicHost`** (adapter bug v1.0.0, see
root AGENTS.md).

## File storage

RustFS (S3 API), dev: LAN IP from `config/development.yaml` → port 9001
(console), S3 on 9000, credentials rustfsadmin / rustfsadmin_secret.
Enable CORS on the bucket when Flutter web accesses files directly.
Profile images live at `member_images/<authUserId>.jpg` (own model, see
above). RustFS stays LAN-only (never expose 9000/9001 to the internet);
image URLs are capability URLs today — presigned-URL redesign is a
security TODO (see apps/AGENTS.md).

## Test / CI

- `dart test` (integration tests with
  `test_tools/serverpod_test_tools.dart`).
- CI: `analyze.yml`, `format.yml`, `tests.yml` (Docker compose) —
  versions there are still old (Dart 3.8.0 / CLI 3.3.1), TODO see
  apps/AGENTS.md.

## Migrations

- **Rebuilt 2026-10-02** (fresh history after the member_profile
  redesign; database volumes wiped by the user): single base migration
  `20261002120454383`.

## State / continuation

- State: auth + member_profile + storage + sites/enrollment/device
  connection all functional against the admin frontends and the local
  backend (after its enrollment round).
- Next steps (stage 3, details in apps/AGENTS.md → TODOs): membership
  sync over the WS connection (propagate new/removed members incl.
  member_profile/image mirrors), live status push to admin clients
  (message central), "profiles editable globally only" sync rule
  implementation, ESP32 device authorization.
