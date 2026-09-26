# AGENTS.md — top_attempt_enduser_flutter (end-user app)

Flutter app for **end users** in the `top_attempt` monorepo: login
against the global instance, profile maintenance, QR scan at the
location and BLE test session against the ESP32. The door prototype was
built with this app. Context: [`apps/AGENTS.md`](../../AGENTS.md),
monorepo: [Root AGENTS.md](../../../AGENTS.md), BLE spec:
[`doorinterface/docs/ble_interface.md`](../../../doorinterface/docs/ble_interface.md).

## Purpose

- Registration/login (email) against the **global** backend.
- Profile with image, first/last name, birthday, email, auth ID and QR
  code (required fields name + birthday; GoRouter guard on missing
  required fields).
- QR reader (target format `doorinterface|MAC|Token`, not final yet).
- BLE connection test against the ESP32 (DoorInterface service).

## Current state

Most advanced of the four frontends:

- GoRouter navigation, Serverpod auth session manager.
- Screens: `lib/screens/` (home, sign_in, qr_reader, ble_test,
  greetings) plus the shared Profile screen; state: the shared
  `ProfileState` (single profile_state.dart).
- **Shared components**: the account dropdown in the AppBar
  (`AccountDropdown`), the `ProfileState` and the `ProfileScreen` live
  in the **`frontends/shared` package** (`top_attempt_shared`) and are
  consumed identically by `top_attempt_global_flutter` — changes there
  apply to both apps (the end-user app additionally uses the
  `isComplete` guard to force profile completion; admins ignore it).
  Wiring contract of the shared widget: `onLogin`/`onLogout`/`onProfile`
  are host-injected — `onLogout` MUST perform the real device sign-out
  (`client.auth.signOutDevice()`); navigation after actions goes via the
  host callbacks.
- BLE under `lib/ble/` (`ble_constants.dart`, `ble_test_session.dart`):
  scan, service discovery, notify subscription, request write, timeout,
  clean disconnect via `flutter_blue_plus`.
- The BLE flow currently always sends `action: test`; `open` is a mock
  on the firmware side, no credential check (see docs/project.md →
  security situation).

## Backend / client

- Uses the **global client** (`top_attempt_global_client`) — correct,
  since auth/profiles live globally.
- Server URL: `--dart-define=SERVER_URL=…` or `assets/config.json`;
  for physical devices the LAN IP of the dev machine (global: API 8080).
- Important packages: `serverpod_auth_idp_flutter`, `go_router`,
  `mobile_scanner`, `flutter_blue_plus`, `image_picker`, `qr_flutter`.

## Relation to the newer apps

`top_attempt_global_flutter`/`top_attempt_local_flutter` (created
2026-09-23) are the **admin apps**, not replacements for this app.
Coming here next: enrolling as a member at a local instance and the real
self-entry flow (QR → OTP → BLE → door).

## Next steps (suggestion)

1. Membership flow (enroll at the local instance) — depends on the
   user/login model of the local backend (see apps/AGENTS.md).
2. `open` flow: send credential/OTP instead of `test` once authorization
   exists in the local backend.
3. Sync with the BLE spec
   (`doorinterface/docs/ble_interface.md`).
