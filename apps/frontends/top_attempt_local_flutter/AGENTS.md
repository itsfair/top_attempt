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

Expanded 2026-09-25 (originally a scaffold copy from 2026-09-23):

- GoRouter (`lib/main.dart`): `/` home + `/setup` site setup mask;
  layout shell with drawer and the **App-Bar connection chip** that
  polls the local backend status (`siteSetup.connectionStatus`, every
  10 s): `noneSetup|connecting|reconnecting|connected|needsReSetup|
  failure`.
- Client in use is the **local client** (`top_attempt_local_client`,
  default API `localhost:8180`; **always point the app at the LOCAL
  instance**: the scaffold `assets/config.json` originally contained
  `8080` (global backend) which caused `ServerpodClientNotFound 404`;
  fixed on 2026-09-25 — note also that the Serverpod `getServerUrl()`
  fallback default is `8080` (global) — on devices use
  `--dart-define=SERVER_URL=http://<LAN-IP>:8180/`).
- **Setup mask** (`lib/screens/site_setup.dart`): global email/password
  of the site admin (chosen at site creation) → `siteSetup.enterSetup`
  → site picker when the admin owns several sites; success → snack bar
  (connection stored locally + local admin login row created).
- The old scaffold sign-in/greeting UI was removed — the real local
  login (with the `local-admin` account) is still missing (see below).

## Backend / client

- Currently uses **only the local client** (`top_attempt_local_client`):
  setup mask + connection chip run against the local instance. The
  enrollment itself happens server-side in the local backend (the
  global client lives there).
- `top_attempt_global_client` is **currently commented out** (pubspec,
  2026-09-25): removed because unused — deliberately re-add when the app
  will manipulate global properties (e.g. course management, see
  apps/AGENTS.md → "Open architecture questions").
- Server URL: `--dart-define=SERVER_URL=…` or `assets/config.json`;
  for physical devices the LAN IP of the dev machine. Local backend:
  API on port 8180.

## Dependencies (domain)

- The local backend needs the device/member/permission model first (see
  `apps/backends/local/AGENTS.md` → open questions) — biggest blocker
  for real admin features.
- Local login (`local-admin`) decides how site admins sign in here and
  which rights they see.

## Next steps (suggestion)

1. Add to the workspace (`apps/pubspec.yaml`).
2. Establish the local login (`local-admin` account) → protect the
   setup and admin areas (currently open to everyone in the LAN).
3. Once the local backend model + membership sync exist: UI for the
   device overview and member management (access rights).
