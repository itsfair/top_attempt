# AGENTS.md — top_attempt_local_flutter (site admin app)

Flutter app for **managing a local instance** (a business/site) in the
`top_attempt` monorepo: devices (ESP32/NUKI), on-site users, access
rights — and long-term the ERP extension (course management, employee
management, shift scheduling). Context: [`apps/AGENTS.md`](../../AGENTS.md),
monorepo: [Root AGENTS.md](../../../AGENTS.md).

## Purpose / audience

- Audience: **site admins** — operators of a location who manage the
  members of their instance (enrollment, access rights, removal) and
  later operate the business ERP.
- Target flow this app belongs to: end user registers globally → enrols
  at the local instance as a member → **the site admin manages the
  members of their instance** (access rights etc.) → end user opens the
  door via QR/OTP/BLE (local instance checks).
- ERP roadmap (step by step): course management → employee management →
  shift scheduling.

## Current state

Reworked 2026-09-26 (first round 2026-09-25; originally a scaffold copy
from 2026-09-23):

- **`lib/layout.dart` separated from `lib/main.dart`** (same pattern as
  the other frontends): drawer navigation (Home / Standort / Profil /
  Site-Einrichtung) + AppBar with the **per-site connection chip**
  (polls `siteSetup.connectionStatus` every 10 s and mirrors the state
  into `connectionStateNotifier` for redirect re-evaluation).
- **GoRouter redirect** (pattern of the global app): not enrolled
  (`noneSetup`) → `/setup`; enrolled but not locally signed in →
  `/sign-in`; signed-in visitor of `/sign-in|/setup` → `/`. After setup
  completes, the shell lands on `/sign-in`.
- **Local login is ACTIVE**: `/sign-in` is a hand-written email/password
  form calling `client.emailIdp.login` (no Serverpod `SignInWidget`:
  local self-registration is intentionally disabled and the
  widget-level sign-up suppression attempt failed in the global app —
  same library).
- **Setup mask** (`lib/screens/site_setup.dart`): global credentials of
  the site admin (chosen at site creation) → `siteSetup.enterSetup`
  (site picker when the admin owns several sites). Success → snack bar
  + redirect to the local login.
- **`/profile` (view-only)**: the mirrored person data of the site admin
  (their `profile_details` row via `siteSetup.adminInfo`); no edit
  controls.
- **`/standort`**: **all site properties** (id, name, address, company
  email, status/registeredAt) + live connection chip.

## Backend / client

- Uses the **local client** (`top_attempt_local_client`, default API
  `localhost:8180` — **always the LOCAL instance**: the scaffold
  `assets/config.json` originally pointed at the global backend `8080`
  and caused `ServerpodClientNotFound 404`, fixed 2026-09-25; note that
  the Serverpod `getServerUrl()` fallback default is also `8080` — on
  devices use `--dart-define=SERVER_URL=http://<LAN-IP>:8180/`).
- The enrollment runs server-side in the local backend (the global
  client lives there).

## TODOs / open decisions

1. **Local login (`local-admin`) protection is active** — but the
   member/employee admin areas do not exist yet; when they land, keep
   them behind the local login as well.
2. **"Edit profile in enduser app" link**: code-plumbed but **hidden**
   (`showEditInEndUserApp` constant alongside an `endUserUrl` config
   field); re-enable when the profile sync design is settled.
3. Keep the layouts of the two admin frontends (global/local) aligned
   where screens overlap (drawer/menu), like the shared package does for
   the end-user + global app account dropdown.
