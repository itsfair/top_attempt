# AGENTS.md — top_attempt_enduser_flutter (Enduser-App)

Flutter-App für **Enduser** im Monorepo `top_attempt`: Login gegen die
globale Instanz, Profilpflege, QR-Scan an der Location und
BLE-Testsession gegen den ESP32. Mit dieser App ist der Tür-Prototyp
entstanden. Kontext: [`apps/AGENTS.md`](../../AGENTS.md), Monorepo:
[Root-AGENTS.md](../../../AGENTS.md), BLE-Spec:
[`doorinterface/docs/ble_interface.md`](../../../doorinterface/docs/ble_interface.md).

## Zweck

- Registrierung/Login (E-Mail) gegen das **globale** Backend.
- Profil mit Bild, Vor-/Nachname, Geburtstag, E-Mail, Auth-ID und
  QR-Code (Pflichtfelder Name + Geburtstag; GoRouter-Guard auf
  fehlende Pflichtfelder).
- QR-Reader (Zielformat `doorinterface|MAC|Token`, noch nicht final).
- BLE-Verbindungstest gegen den ESP32 (DoorInterface-Service).

## Aktueller Stand

Am weitesten ausgebaut der vier Frontends:

- GoRouter als Navigation, Serverpod-Auth-Session-Manager.
- Screens: `lib/screens/` (home, profile, sign_in, qr_reader, ble_test,
  greetings), State: `lib/profile_state.dart`, `lib/layout.dart`.
- BLE unter `lib/ble/` (`ble_constants.dart`, `ble_test_session.dart`):
  Scan, Service-Discovery, Notify-Subscription, Request-Write, Timeout,
  sauberer Disconnect via `flutter_blue_plus`.
- BLE-Flow sendet aktuell immer `action: test`; `open` ist auf
  Firmware-Seite Mock, keine Credential-Prüfung (siehe docs/project.md
  → Sicherheitslage).

## Backend / Client

- Nutzt den **globalen Client** (`top_attempt_global_client`) — korrekt,
  da Auth/Profile global leben.
- Server-URL: `--dart-define=SERVER_URL=…` oder `assets/config.json`;
  bei physischen Geräten LAN-IP des Dev-Rechners (global: API 8080).
- Wichtige Pakete: `serverpod_auth_idp_flutter`, `go_router`,
  `mobile_scanner`, `flutter_blue_plus`, `image_picker`, `qr_flutter`.

## Verhältnis zu den neueren Apps

`top_attempt_global_flutter`/`top_attempt_local_flutter` (2026-09-23
entstanden) sind die **Admin-Apps**, nicht Ersatz für diese App. Künftig
gehört hierher: Einschreiben als Mitglied bei einer lokalen Instanz und
der echte Selbsteinlass-Flow (QR → OTP → BLE → Tür).

## Nächste Schritte (Vorschlag)

1. Membership-Flow (Einschreiben bei lokaler Instanz) — hängt am
   User-/Login-Modell des lokalen Backends (siehe apps/AGENTS.md).
2. `open`-Flow: Credential/OTP statt `test` senden, sobald die
   Autorisierung im lokalen Backend steht.
3. BLE-Spec abgleichen (`doorinterface/docs/ble_interface.md`).
