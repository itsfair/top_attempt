# AGENTS.md — top_attempt (monorepo root)

This repo is a monorepo: ESP32 firmware + Serverpod backends + Flutter
clients. Every instance (backend/frontend) has its own AGENTS.md with the
instance details (state, responsibilities, open questions). This root file
holds the **global structure** — wherever a session starts, this is the
entry point.

"Global instance" = the central Serverpod instance (`global`); "local
instance" = one Serverpod instance per site/door installation (`local`).
The `global_`/`local_` package name prefixes refer to these instance
levels, not to where code runs.

## What is top_attempt? (short version)

Digital door access solution (self-entry via NUKI locks controlled by an
ESP32, BLE for smartphone clients), being extended into an ERP system for
businesses.

- **Global instance** — central user accounts/profiles; end users
  register here. Platform level.
- **Local instance** (one per business/site) — represents a business:
  door access (self-entry), later courses, employees, shift scheduling.
  Works autonomously during short internet outages.
- **Interplay** — you become a member of a business globally
  (registration) and locally (enrollment at an instance); the local
  instance receives the necessary user data synchronized. For details on
  the data/login flow see `apps/AGENTS.md` → "Instance purposes and
  synchronization".

Target flow "self-entry" (state: end user is a member of a local
instance): scan the QR code at the location → request OTP → send OTP over
BLE to the ESP32 → ESP32 forwards to the local instance → the instance
checks the access data → door unlocks. Door access works **without a
cloud round trip** (BLE + local instance suffice; the long-term goal is
securing that path).

## Layout — instances and their purposes

Purposes per instance (context above); details in the linked AGENTS.md:

| Path | What | Purpose | Own AGENTS.md |
|---|---|---|---|
| `doorinterface/` | ESP32 firmware (PlatformIO/Arduino) | Door control: NUKI BLE, Wi-Fi setup, web UI, BLE peripheral for the end-user app | [`doorinterface/AGENTS.md`](doorinterface/AGENTS.md) |
| `apps/backends/global/top_attempt_global_server` | Serverpod backend "global" | Central user management: registration, auth, profiles, later global entities (e.g. course catalog) | [`apps/backends/global/AGENTS.md`](apps/backends/global/AGENTS.md) |
| `apps/backends/global/top_attempt_global_client` | Serverpod client for "global" | Generated client package; used by frontends against the global instance | — (generated, docs in backend) |
| `apps/backends/local/top_attempt_local_server` | Serverpod backend "local" | On-site business: device/member/permission model, autonomous operation during internet outage | [`apps/backends/local/AGENTS.md`](apps/backends/local/AGENTS.md) |
| `apps/backends/local/top_attempt_local_client` | Serverpod client for "local" | Generated client package; used by frontends against the local instance | — (generated, docs in backend) |
| `apps/frontends/top_attempt_global_flutter` | Flutter app "global" | **Platform admin app**: manage the global instance (user accounts/profiles, sites, more later) | [`apps/frontends/top_attempt_global_flutter/AGENTS.md`](apps/frontends/top_attempt_global_flutter/AGENTS.md) |
| `apps/frontends/top_attempt_local_flutter` | Flutter app "local" | **Site admin app**: devices, on-site users, access rights; ERP extension (courses, employees, shift scheduling) | [`apps/frontends/top_attempt_local_flutter/AGENTS.md`](apps/frontends/top_attempt_local_flutter/AGENTS.md) |
| `apps/frontends/top_attempt_enduser_flutter` | Flutter app (end user) | End-user app: login (global), profile, QR scan, BLE test against the ESP32 | [`apps/frontends/top_attempt_enduser_flutter/AGENTS.md`](apps/frontends/top_attempt_enduser_flutter/AGENTS.md) |
| `apps/frontends/top_attempt_flutter` | Flutter app (template) | **Raw Serverpod scaffold as a copy template** for future frontends; no purpose of its own | [`apps/frontends/top_attempt_flutter/AGENTS.md`](apps/frontends/top_attempt_flutter/AGENTS.md) |

All app instances live in a Dart workspace (`apps/pubspec.yaml`); details
in [`apps/AGENTS.md`](apps/AGENTS.md).

## Workflows (`.github/workflows/`)

| File | Purpose | Trigger |
|---|---|---|
| `firmware.yml` | Builds the firmware on tag push `fw-v*` and creates a GitHub release with `firmware.bin` (OTA source); also manual (`workflow_dispatch`) | Tag push `fw-v*` / manual |
| `analyze.yml` | `dart analyze --fatal-infos` for both Serverpod backends | Push/PR to `main` touching `apps/**` |
| `format.yml` | `dart format --set-exit-if-changed .` for both backends | Push/PR to `main` touching `apps/**` |
| `tests.yml` | `dart test` against both backends (Docker compose for Postgres/Redis/RustFS) | Push/PR to `main` touching `apps/**` |

If another CI instance should be added later or per-instance gates are
wanted (e.g. frontends), adapt these files — no new workflows without
agreement.

The firmware pulls the latest `fw-v*` release via OTA itself
(`doorinterface/src/Updater.cpp`); details in
`doorinterface/AGENTS.md` → "Monorepo context".

## Toolchain requirements (as of 2026-09-23)

- **Firmware**: PlatformIO (`pio` CLI) — see `doorinterface/AGENTS.md`.
- **Apps (Dart/Flutter)**: Dart SDK `^3.12.2` (pubspec constraint; locally
  installed is 3.13.4), Flutter 3.47.5, **Serverpod 4.0.2**
  (Serverpod CLI globally 4.0.2 as well).
- **For local backend tests**: Docker (Postgres + Redis + RustFS via
  docker-compose per backend).
- Check locally installed versions before work (`dart --version`,
  `flutter --version`, `serverpod --version`).

## Interface specs

| Path | What | State |
|---|---|---|
| [`doorinterface/docs/ble_interface.md`](doorinterface/docs/ble_interface.md) | BLE GATT interface ESP ↔ end-user smartphone app (prototype, mocked backend response) | in progress (German) |
| `doorinterface/docs/interfaces.md` | Full HTTP API / NVS / BLE GATT spec (old, outdated) | TODO |

Anyone building an app against the DoorInterface starts by reading these
specs plus `doorinterface/AGENTS.md` (especially "Architecture decisions"
and "BleServer").

## Conventions / notes

- **Answer language**: agents answer in chat in **English** (the user
  writes German). **All AGENTS.md files: English** (per decision
  2026-09-25). Documentation under `docs/**` and code comments stay in
  German.
- Commits per sub-package are fine; do not force cross-package commits.
- No auto-commits without explicit user OK (see
  `doorinterface/AGENTS.md` → "Working rules").
- **File storage**: files (among others profile images) live in the RustFS
  bucket `top-attempt` (S3 API, web console per backend on :9001 resp.
  :9101, credentials rustfsadmin / rustfsadmin_secret) — no longer blobs
  in the DB. Adapter: `serverpod_cloud_storage_rustfs`; registered in
  `lib/server.dart` of **both** backends; the endpoint (scheme/host/port)
  comes per stage from the `rustFS:` block of the respective
  `config/<runMode>.yaml` (dev: LAN IP of the dev machine, important for
  tests on real devices). **Do not set `publicHost`** — upstream bug in
  the publicHost branch of `buildPublicUri` (package v1.0.0) produces
  invalid URLs. For Flutter web tests CORS must be enabled on the bucket
  (RustFS console).
- **User profile**: email/user ID/image come from the built-in
  `UserProfile` of the auth module (`userProfileEdit` endpoint, global
  only); first/last name and birthday live in the own table
  `profile_details` (`ProfileDetailsEndpoint`, in both backends).
  Required fields: name + birthday; image optional.

## Serverpod upgrade 3.4.12 → 4.0.2 (2026-09-23)

Both backends were upgraded following the official guide
(https://docs.serverpod.dev/upgrading/upgrade-to-four). Important for
future troubleshooting:

- Dart workspace SDK constraint bumped to `^3.12.2`
  (`apps/pubspec.yaml` + both backend pubspecs).
- "Repaired local backend for upgrade" (commit `fc2574b`): local backend
  initialized and aligned with the global one; for this **migrations were
  deleted and the DB recreated** — the old local migration folder
  (`20260222122319691`) was removed and replaced by a fresh base migration
  (`20260923104843538`); both backends got an `*-upgrade-4-0` migration
  folder.
- `container_name: rustfs_server` was removed from both
  `docker-compose.yaml` files (name collision when both stacks run).
- Generated files (`src/generated/…`, client `protocol/…`) and
  `test_tools/serverpod_test_tools.dart` were regenerated.
- No issues known so far; if anomalies appear after the upgrade, first
  check generate/DB migration state.

## Continuation

- Firmware side: see `doorinterface/AGENTS.md` → "Continuation".
- Apps side: see [`apps/AGENTS.md`](apps/AGENTS.md) → "Continuation /
  open work items" — the direction (ERP goal, instance sync, login
  model) is described there.
