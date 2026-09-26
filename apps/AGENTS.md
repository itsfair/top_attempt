# AGENTS.md — apps (Dart workspace: backends + frontends)

This folder combines all Dart/Flutter packages into one workspace
(`apps/pubspec.yaml`, `resolution: workspace`). The monorepo structure is
in the [root AGENTS.md](../AGENTS.md) — this file holds the details of
the backends and frontends.

## Workspace

`apps/pubspec.yaml` defines the workspace. **Current members:**

- `backends/global/top_attempt_global_client`
- `backends/global/top_attempt_global_server`
- `backends/local/top_attempt_local_client`
- `backends/local/top_attempt_local_server`
- `frontends/shared` (`top_attempt_shared`: ProfileState, AccountDropdown,
  ProfileScreen shared by end-user + global admin app)
- `frontends/top_attempt_enduser_flutter`

**Not yet in the workspace** (although `resolution: workspace` is set):
`frontends/top_attempt_global_flutter`, `frontends/top_attempt_local_flutter`,
`frontends/top_attempt_flutter`. → TODO, see below. Until then `dart pub
get` at workspace level does not work for these frontends; resolve
individually or extend the workspace.

SDK constraint: `^3.12.2` (locally installed: Dart 3.13.4, Flutter 3.47.5,
Serverpod CLI 4.0.2).

## Instance model (domain)

Two instance levels — always keep the terms apart:

- **Global instance** (`global`) — the single central platform instance.
  End users register here (email IdP); user accounts and profiles live
  here. Later possibly global entities (e.g. course catalog — open
  question, see below).
- **Local instance** (`local`) — **one instance per business/site**
  (door installation). Represents the business: self-entry (door access),
  later ERP features (course management, employee management, shift
  scheduling). Must keep running autonomously during short internet
  outages.

**Membership/flow (target picture):**

1. End user registers globally (email, profile with name/birthday/image).
2. End user enrolls as a member at a local instance.
3. The local instance receives the required user data synchronized
   (details below).
4. Site admin manages members of their instance (access rights etc.).
5. Self-entry: end user scans QR at the location → request OTP → send OTP
   via BLE to ESP32 → ESP32 forwards to local instance → instance checks
   and opens door via ESP32/NUKI.

Door access itself needs **no cloud round trip** (BLE + local instance
suffice); securing that path (OTP origin, synchronization) is the
long-term goal.

### Open architecture questions (still to be clarified)

- **Login/user model local:** Copy global users 1:1 including credentials
  (attribute `staff` governs access to local administration) **or** put
  users into a separate `members` table with locally created credentials
  linked to members? → one of the next clarification points.
- **Global vs. local entities (e.g. courses):** Courses could be created
  globally (end user sees/book them globally) or locally and be
  synchronized/made reachable globally (WebSocket?). Courses are not
  critical for local operation during an internet outage.
- **"Reachable from outside":** How exactly local instances are reached
  via the global instance (technical routing vs. only centrally managed
  membership) — not discussed yet.

## Ports / infrastructure (dev)

| | global | local |
|---|---|---|
| API server | 8080 | 8180 |
| Insights | 8081 | 8181 |
| Web server | 8082 | 8182 |
| Postgres | 8090 | 8190 |
| Redis (disabled) | 8091 | 8191 |
| RustFS S3 API / console | 9000 / 9001 | 9000 / 9101 |

Both backends have their own `docker-compose.yaml` (Postgres + Redis +
RustFS) and can run simultaneously (`container_name: rustfs_server` was
removed for that reason). DB name is `top_attempt` in both. RustFS bucket
`top-attempt` (credentials rustfsadmin / rustfsadmin_secret); the endpoint
comes from the `rustFS:` block of `config/<runMode>.yaml` (dev: LAN IP of
the dev machine, important for tests on real devices). **Do not set
`publicHost`** (adapter bug, see root AGENTS.md). Redis is currently
`enabled: false` in both `development.yaml` files.

## Backends

### global (`apps/backends/global/`) — details in [AGENTS.md](backends/global/AGENTS.md)

Central user management: email IdP (registration/login/reset), JWT auth,
`UserProfileEditEndpoint` (email/user ID/image), `ProfileDetailsEndpoint`
(first/last name, birthday), RustFS storage. State: MVP base working
against the end-user app; `usersAdmin` endpoints (2026-09-24: user list
paging, global-admin/blocked toggles incl. token revocation,
`global-admin` scope); **site level (2026-09-25)**: `sitesAdmin`
(createSite without secrets, site management incl.
`revokeSiteConnection`), `siteEnrollment` (global credential verify,
site picker, device session = SAS `method:'device'`, token-level scope
`site-device`, mapping table), `siteConnection` (method stream,
ping/pong updates `lastSeenAt`) — the local backend connects to this.
Global clients use this; site migrations `20260925122822442` +
`20260925150857366`.

### local (`apps/backends/local/`) — details in [AGENTS.md](backends/local/AGENTS.md)

Local instance of a business/site. Since 2026-09-25 **site module**:
enrollment via the global credentials of the site admin
(`siteSetup.enterSetup` with global client dependency), local members
directory (`members` with `globalAuthUserId` as exchange/door id), local
`local-admin` login (same password as globally at setup), and the
connection worker (`GlobalSiteConnection`: SAS session key device
credential, long-lived method stream + 30 s ping → `lastSeenAt`, backoff
reconnect, `needsReSetup` state). No local self-registration — logins
are only created from verified global logins (same pattern later for
employees). Basic infrastructure/ports: like global (8180 scheme).

## Frontends

### top_attempt_enduser_flutter — details in [AGENTS.md](frontends/top_attempt_enduser_flutter/AGENTS.md)

End-user app: login (global), profile (image/QR/ID), QR reader,
BLE test session against ESP32. Most advanced of the four frontends.

### top_attempt_global_flutter — details in [AGENTS.md](frontends/top_attempt_global_flutter/AGENTS.md)

**Platform admin app** (manage the global instance). GoRouter with
auth/scope guard (not signed in → `/sign-in`, without `global-admin`
scope → `/forbidden`); drawer layout; Members screen (50/page + search +
"load more", detail editor for `Global Admin`/`blocked`) and Sites
screen (2026-09-25: FAB + create dialog with first site admin selection,
connection chips per site from `lastSeenAt`, revoke action in detail
route). Uses the global client.

### top_attempt_local_flutter — details in [AGENTS.md](frontends/top_attempt_local_flutter/AGENTS.md)

**Site admin app** (manage a local instance). GoRouter shell with
**App-Bar connection chip** (polls local backend
`siteSetup.connectionStatus` every 10 s) and the
**Site setup mask** (`siteSetup.enterSetup` with the **global
credentials** of the site admin; site picker when the admin owns several
sites). Uses only the local client; the global client dependency is
commented out until the app will manipulate global properties (e.g.
course management — open question above).

### top_attempt_flutter — details in [AGENTS.md](frontends/top_attempt_flutter/AGENTS.md)

**Copy template**: raw Serverpod scaffold, no purpose of its own. The
`flutter_build` scripts of both backends still reference this app as web
app source (TODO: retarget or remove intentionally).

## Serverpod upgrade 3.4.12 → 4.0.2 (2026-09-23, for troubleshooting)

Following the official guide
(https://docs.serverpod.dev/upgrading/upgrade-to-four). Reconstructed
from git:

- Commits: `103c597` ("Serverpod 3.4.12 upgrade, RustFS file storage,
  user profile feature" — prior state), then `106f5b4`/`e5f95b6` (RustFS +
  profile into the local backend), then `fc2574b` ("Repaired local
  backend for upgrade").
- `apps/pubspec.yaml` + both backend pubspecs: SDK to `^3.12.2`,
  serverpod packages to `4.0.2` (serverpod, serverpod_auth_idp_server,
  serverpod_test; frontends: serverpod_flutter, serverpod_auth_idp_flutter).
- The local backend was initialized and aligned with the global one
  (auth IdP, ProfileDetails, RustFS, yaml config reader in
  `lib/server.dart`).
- **Migrations deleted + DB recreated:** local migration
  `20260222122319691` removed, fresh base migration `20260923104843538`
  created. Global registry: `20260222122319691`, `20260827100208475`,
  `20260923112307048-upgrade-4-0`; local registry:
  `20260923104843538`, `20260923112557527-upgrade-4-0`. If DB/schema
  errors occur afterwards: check migration state of both backends and
  `--apply-migrations`.
- Both `docker-compose.yaml`: `container_name: rustfs_server` removed
  (collision with simultaneous stacks).
- Generated files regenerated (`src/generated/…`, client `protocol/…`,
  `test_tools/serverpod_test_tools.dart`).
- State: no known issues. CI still pins CLI `3.3.1` (see TODOs).

## TODOs / open work items (cross-app)

1. **Workspace membership**: add `top_attempt_global_flutter`,
   `top_attempt_local_flutter` (and `top_attempt_flutter`) to
   `apps/pubspec.yaml`.
2. **Unify CI**: `analyze.yml`/`format.yml`/`tests.yml` use Dart 3.8.0 /
   Serverpod CLI 3.3.1 — raise to 3.13/4.0.2 (local reality: Dart
   3.13.4, Flutter 3.47.5, CLI 4.0.2).
3. **`flutter_build` scripts** of both backends still build
   `top_attempt_flutter` as web app — decide the target app.
4. **Local user/login model** clarified on 2026-09-25 (see local backend
   AGENTS.md): no local self-registration; logins only from verified
   global logins (admin at setup; employees later by the local admin).
5. **Local frontend contents**: site admin UI (devices, members, access
   rights) once the local backend model + membership sync exist; local
   app login (`local-admin`) as protection layer.
6. **Members feature hardening** (first set 2026-09-24): integration
   tests for `usersAdmin` endpoints, confirmation dialog on block, keep
   `usersAdmin` strictly behind `requiredScopes` (client handles
   `UserAdminException`/scope errors).
7. **Registration in the global admin frontend: disable** (not urgent):
   attempts on 2026-09-25 (blank texts + `EmailAuthController` subclass)
   did not work — details and approaches in
   [`frontends/top_attempt_global_flutter/AGENTS.md`](frontends/top_attempt_global_flutter/AGENTS.md)
   → "Next steps", item 5.
8. **Stage 2 — enrollment/WS done (2026-09-25)**; remaining (stage 3):
   a) **Membership sync over the method stream**: propagate new/removed
      global `SiteMembership` events into the local `members` table
      (rule: local rows carry `globalAuthUserId` — exchange/door id),
      staff switch → local login analog admin setup, roles/status
      reported back (site-device-restricted endpoints).
   b) **Live status push** to the admin clients (message central)
      instead of 30 s polling in the global sites list.
   c) **Local protection**: admin UI login (`local-admin`) for the local
      app — currently open (setup mask unprotected).
   d) **Encryption at rest** for the local `site_connections` row
      (session key) — before production.
   e) Add `SERVERPOD_PASSWORD_serverSideSessionKeyHashPepper` to CI
      (tests.yml) + unify Serverpod CLI versions in CI (see item 2).
9. **Site editor/roadmap**: edit/delete site, memberships view per site;
   note on "same password globally + locally" (desired): the local copy
   is created at the verified global login; self-healing on password
   change = TODO.
10. **Decisions (2026-09-25)**: no local self-registration; logins only
    from verified global logins (admin at setup; later employees via the
    local admin); device credential = non-rotating SAS session key
    (`site-device`, pepper `serverSideSessionKeyHashPepper`),
    connection status chips via `lastSeenAt`.

## Continuation / next steps

The direction is: ERP extension of the local instance with autonomous
operation, synchronization with the global instance as lean as possible.
Concrete next steps are under "TODOs"; the most important missing block
is the membership sync over the stream (item 8a) plus the local admin
login (item 8c).
