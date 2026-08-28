# AGENTS.md — top_attempt (Monorepo-Root)

Dieses Repo ist ein Monorepo: ESP32-Firmware + Serverpod-Backends +
Flutter-Clients. Pro Sub-Paket gibt es eine eigene AGENTS.md mit den
Details — diese Root-Datei gibt nur den Überblick und die Verweise.

## Layout

| Pfad | Was | Eigenes AGENTS.md |
|---|---|---|
| `doorinterface/` | ESP32-Firmware (PlatformIO/Arduino) | [`doorinterface/AGENTS.md`](doorinterface/AGENTS.md) |
| `apps/backends/global/top_attempt_global_server` | Serverpod-Backend „global“ | (noch keins) |
| `apps/backends/local/top_attempt_local_server` | Serverpod-Backend „local“ | (noch keins) |
| `apps/frontends/top_attempt_flutter` | Flutter-Client (Admin?) | (noch keins) |
| `apps/frontends/top_attempt_enduser_flutter` | Flutter-Client (Enduser) | (noch keins) |

## Workflows (`.github/workflows/`)

| Datei | Zweck | Trigger |
|---|---|---|
| `firmware.yml` | Baut die Firmware bei Tag-Push `fw-v*` und erstellt ein GitHub-Release mit `firmware.bin` (OTA-Quelle); auch manuell (`workflow_dispatch`) | Tag-Push `fw-v*` / manuell |
| `analyze.yml` | `dart analyze --fatal-infos` für beide Serverpod-Backends | Push/PR auf `main`, das `apps/**` toucht |
| `format.yml` | `dart format --set-exit-if-changed .` für beide Backends | Push/PR auf `main`, das `apps/**` toucht |
| `tests.yml` | `dart test` gegen beide Backends (mit Docker-Compose für Postgres/Redis/RustFS) | Push/PR auf `main`, das `apps/**` toucht |

Die Firmware selbst zieht das neueste `fw-v*`-Release per OTA
(`doorinterface/src/Updater.cpp`); Details siehe
`doorinterface/AGENTS.md` → „Monorepo-Kontext".

## Toolchain-Voraussetzungen

- **Firmware**: PlatformIO (`pio` CLI) — siehe `doorinterface/AGENTS.md`.
- **Apps**: Dart 3.8.0, Flutter 3.32.8 (laut `tests.yml`), Serverpod 3.4.12
  (Serverpod-CLI global ebenfalls auf 3.4.12).
- **Für Backend-Tests lokal**: Docker (für Postgres + Redis + RustFS-Container).

## Schnittstellen-Specs

| Pfad | Was | Status |
|---|---|---|
| [`doorinterface/docs/ble_interface.md`](doorinterface/docs/ble_interface.md) | BLE-GATT-Schnittstelle ESP ↔ Enduser-Smartphone-App (Prototyp, gemockte Backend-Antwort) | in Arbeit |
| `doorinterface/docs/interfaces.md` | HTTP-API / NVS / BLE-GATT-Komplett-Spec (alt, veraltet) | TODO |

Wer eine App gegen das Doorinterface baut, startet beim Lesen dieser Specs
und der `doorinterface/AGENTS.md` (speziell „Architektur-Entscheidungen"
und „BleServer").

## Konventionen / Notizen

- Commits pro Sub-Paket sind fine; keine Cross-Paket-Commits erzwingen.
- Keine Auto-Commits ohne ausdrückliches OK des Nutzers (siehe
  `doorinterface/AGENTS.md` → „Arbeitsweise").
- `apps/AGENTS.md` existiert nicht; bei Bedarf anlegen, wenn die
  Backend-/Frontend-Arbeit mehr wird.
- **File-Storage**: Dateien (u. a. Profilbilder) liegen im RustFS-Bucket
  `top-attempt` (S3-API :9000, Web-Konsole http://localhost:9001,
  Credentials rustfsadmin / rustfsadmin_secret) — nicht mehr als Blobs in
  der DB. Adapter: `serverpod_cloud_storage_rustfs` nach Artikel
  (thecodebrothers.pl/improving-local-file-storage-in-serverpod), registriert
  in `global/.../lib/server.dart`; der Endpoint (scheme/host/port) kommt pro
  Stage aus dem `rustFS:`-Block der jeweiligen `config/<runMode>.yaml` (Dev:
  LAN-IP des Entwicklungsrechners, wichtig für Tests am echten Gerät).
  **Kein `publicHost` setzen** — Upstream-Bug im publicHost-Zweig von
  `buildPublicUri` (Paket v1.0.0) erzeugt ungültige URLs. Für Flutter-Web-
  Tests muss CORS am Bucket aktiviert sein (RustFS-Konsole).
- **User-Profil**: E-Mail/User-ID/Bild kommen aus dem eingebauten
  `UserProfile` des Auth-Moduls (`userProfileEdit`-Endpoint), Vor-/Nachname
  und Geburtstag liegen in eigener Tabelle `profile_details`
  (`ProfileDetailsEndpoint`). Pflichtfelder: Name + Geburtstag; Bild optional.

## Forsetzung

- Firmware-Seite: siehe `doorinterface/AGENTS.md` → „Forsetzung".
- Apps-Seite: in aktiver Entwicklung — Serverpod-Backend „global" mit
  Auth + File-Storage (RustFS) und die Enduser-App (Login, Profil-Feature
  mit Bild/QR/ID, GoRouter-Guard). Eigene `apps/AGENTS.md` bei Bedarf
  anlegen, sobald der Umfang es rechtfertigt.