# AGENTS.md — top_attempt (Monorepo-Root)

Dieses Repo ist ein Monorepo: ESP32-Firmware + Serverpod-Backends +
Flutter-Clients. Jede Instanz (Backend/Frontend) hat eine eigene
AGENTS.md mit den Instanz-Details (Stand, Verantwortlichkeiten, offene
Fragen). Diese Root-Datei hält die **globale Struktur** fest — egal wo
eine Session startet, hier ist der Einstieg.

„Globale Instanz“ = zentrale Serverpod-Instanz (`global`); „lokale
Instanz“ = eine Serverpod-Instanz pro Standort/Türanlage (`local`).
Namen mit `global_`/`local_` im Paketnamen beziehen sich auf diese
Instanz-Ebene, nicht darauf, wo der Code läuft.

## Was ist top_attempt? (Kurzfassung)

Digitale Türzugangslösung (Selbsteinlass über NUKI-Schlösser via ESP32,
BLE für Smartphone-Clients), die zu einem ERP-System für Betriebe
ausgebaut wird.

- **Globale Instanz** — zentrale Benutzerkonten/Profile; Enduser
  registrieren sich hier. Plattform-Ebene.
- **Lokale Instanz** (eine pro Betrieb/Standort) — bildet einen Betrieb
  ab: Türzugang (Selbsteinlass), später Kurse, Angestellte, Schichtplan.
  Autark-fähig bei kurzer Internettrennung.
- **Zusammenspiel** — Mitglied eines Betriebs wird man global (Registrierung)
  und lokal (Einschreiben bei Instanz); die lokale Instanz bekommt die
  nötigen Nutzerdaten synchronisiert. Genauer Daten-/Login-Flow: siehe
  `apps/AGENTS.md` → „Instanz-Zwecke und Synchronisation“.

Ziel-Ablauf „Selbsteinlass“ (Zustand: Enduser-Mitglied einer lokalen
Instanz): QR-Code an der Location scannen → OTP abfragen → OTP über BLE an
den ESP32 → ESP32 reicht an lokale Instanz → Instanz prüft Zugangsdaten →
Tür schaltet. Türzugang funktioniert **ohne Cloud-Roundtrip** (BLE + lokale
Instanz reicht; der langfristige Zielzustand ist die Absicherung darüber).

## Layout — Instanzen und ihre Zwecke

Zwecke je Instanz (Kontext oben); Details in den verlinkten AGENTS.md:

| Pfad | Was | Zweck | Eigenes AGENTS.md |
|---|---|---|---|
| `doorinterface/` | ESP32-Firmware (PlatformIO/Arduino) | Türsteuerung: NUKI-BLE, WLAN-Setup, Web-UI, BLE-Peripheral für Enduser-App | [`doorinterface/AGENTS.md`](doorinterface/AGENTS.md) |
| `apps/backends/global/top_attempt_global_server` | Serverpod-Backend „global“ | Zentrale Benutzerverwaltung: Registrierung, Auth, Profile, später globale Entitäten (z. B. Kurskatalog) | [`apps/backends/global/AGENTS.md`](apps/backends/global/AGENTS.md) |
| `apps/backends/global/top_attempt_global_client` | Serverpod-Client für „global“ | Generiertes Client-Paket; von Frontends gegen die globale Instanz genutzt | — (generiert, Doku im Backend) |
| `apps/backends/local/top_attempt_local_server` | Serverpod-Backend „local“ | Betrieb vor Ort: Geräte-/Mitglieder-/Berechtigungsmodell (geplant), Autarkie bei Internetausfall | [`apps/backends/local/AGENTS.md`](apps/backends/local/AGENTS.md) |
| `apps/backends/local/top_attempt_local_client` | Serverpod-Client für „local“ | Generiertes Client-Paket; von Frontends gegen die lokale Instanz genutzt | — (generiert, Doku im Backend) |
| `apps/frontends/top_attempt_global_flutter` | Flutter-App „global“ | **Plattform-Admin-App**: Verwaltung der globalen Instanz (Nutzerkonten/Profile, später mehr) | [`apps/frontends/top_attempt_global_flutter/AGENTS.md`](apps/frontends/top_attempt_global_flutter/AGENTS.md) |
| `apps/frontends/top_attempt_local_flutter` | Flutter-App „local“ | **Site-Admin-App**: Geräte, Nutzer vor Ort, Zugangsrechte; ERP-Ausbau (Kurse, Angestellte, Schichtplan) | [`apps/frontends/top_attempt_local_flutter/AGENTS.md`](apps/frontends/top_attempt_local_flutter/AGENTS.md) |
| `apps/frontends/top_attempt_enduser_flutter` | Flutter-App (Enduser) | Enduser-App: Login (global), Profil, QR-Scan, BLE-Test gegen ESP32 | [`apps/frontends/top_attempt_enduser_flutter/AGENTS.md`](apps/frontends/top_attempt_enduser_flutter/AGENTS.md) |
| `apps/frontends/top_attempt_flutter` | Flutter-App (Vorlage) | **Rohes Serverpod-Grundgerüst als Kopiervorlage** für künftige Frontends; kein eigener Zweck | [`apps/frontends/top_attempt_flutter/AGENTS.md`](apps/frontends/top_attempt_flutter/AGENTS.md) |

Alle App-Instanzen sind in einem Dart-Workspace (`apps/pubspec.yaml`)
zusammengefasst; Details in [`apps/AGENTS.md`](apps/AGENTS.md).

## Workflows (`.github/workflows/`)

| Datei | Zweck | Trigger |
|---|---|---|
| `firmware.yml` | Baut die Firmware bei Tag-Push `fw-v*` und erstellt ein GitHub-Release mit `firmware.bin` (OTA-Quelle); auch manuell (`workflow_dispatch`) | Tag-Push `fw-v*` / manuell |
| `analyze.yml` | `dart analyze --fatal-infos` für beide Serverpod-Backends | Push/PR auf `main`, das `apps/**` toucht |
| `format.yml` | `dart format --set-exit-if-changed .` für beide Backends | Push/PR auf `main`, das `apps/**` toucht |
| `tests.yml` | `dart test` gegen beide Backends (mit Docker-Compose für Postgres/Redis/RustFS) | Push/PR auf `main`, das `apps/**` toucht |

Soll später eine weitere CI-Instanz hinzukommen oder sollen CI-Gates pro
Instanz ergänzt werden (z. B. Frontends), nur die Dateien anpassen — keine
neuen Workflows ohne Absprache.

Die Firmware selbst zieht das neueste `fw-v*`-Release per OTA
(`doorinterface/src/Updater.cpp`); Details siehe
`doorinterface/AGENTS.md` → „Monorepo-Kontext“.

## Toolchain-Voraussetzungen (Stand 2026-09-23)

- **Firmware**: PlatformIO (`pio` CLI) — siehe `doorinterface/AGENTS.md`.
- **Apps (Dart/Flutter)**: Dart SDK `^3.12.2` (pubspec-Constraint; lokal
  installiert ist 3.13.4), Flutter 3.47.5, **Serverpod 4.0.2**
  (Serverpod-CLI global ebenfalls 4.0.2).
- **Für Backend-Tests lokal**: Docker (Postgres + Redis + RustFS via
  docker-compose je Backend).
- Lokal installierte Versionen prüfen (`dart --version`,
  `flutter --version`, `serverpod --version`).

## Schnittstellen-Specs

| Pfad | Was | Status |
|---|---|---|
| [`doorinterface/docs/ble_interface.md`](doorinterface/docs/ble_interface.md) | BLE-GATT-Schnittstelle ESP ↔ Enduser-Smartphone-App (Prototyp, gemockte Backend-Antwort) | in Arbeit |
| `doorinterface/docs/interfaces.md` | HTTP-API / NVS / BLE-GATT-Komplett-Spec (alt, veraltet) | TODO |

Wer eine App gegen das Doorinterface baut, startet beim Lesen dieser Specs
und der `doorinterface/AGENTS.md` (speziell „Architektur-Entscheidungen“
und „BleServer“).

## Konventionen / Notizen

- Commits pro Sub-Paket sind fine; keine Cross-Paket-Commits erzwingen.
- Keine Auto-Commits ohne ausdrückliches OK des Nutzers (siehe
  `doorinterface/AGENTS.md` → „Arbeitsweise“).
- **File-Storage**: Dateien (u. a. Profilbilder) liegen im RustFS-Bucket
  `top-attempt` (S3-API, Web-Konsole je nach Backend auf :9001 bzw. :9101,
  Credentials rustfsadmin / rustfsadmin_secret) — nicht mehr als Blobs in
  der DB. Adapter: `serverpod_cloud_storage_rustfs`; registriert in
  `lib/server.dart` **beider** Backends; der Endpoint (scheme/host/port)
  kommt pro Stage aus dem `rustFS:`-Block der jeweiligen
  `config/<runMode>.yaml` (Dev: LAN-IP des Entwicklungsrechners, wichtig
  für Tests am echten Gerät). **Kein `publicHost` setzen** —
  Upstream-Bug im publicHost-Zweig von `buildPublicUri` (Paket v1.0.0)
  erzeugt ungültige URLs. Für Flutter-Web-Tests muss CORS am Bucket
  aktiviert sein (RustFS-Konsole).
- **User-Profil**: E-Mail/User-ID/Bild kommen aus dem eingebauten
  `UserProfile` des Auth-Moduls (`userProfileEdit`-Endpoint, nur global),
  Vor-/Nachname und Geburtstag liegen in eigener Tabelle `profile_details`
  (`ProfileDetailsEndpoint`, in beiden Backends). Pflichtfelder: Name +
  Geburtstag; Bild optional.

## Serverpod-Upgrade 3.4.12 → 4.0.2 (2026-09-23)

Beide Backends wurden nach der offiziellen Anleitung
(https://docs.serverpod.dev/upgrading/upgrade-to-four) aktualisiert.
Wichtig für Fehlersuche in der Zukunft:

- SDK-Constraint des Dart-Workspaces hochgezogen auf `^3.12.2`
  (`apps/pubspec.yaml` + beide Backend-pubspecs).
- „Repaired local backend for upgrade“ (Commit `fc2574b`): lokales
  Backend initialisiert und an globales angeglichen; dafür **Migrations
  gelöscht und DB neu erstellt** — die lokalen Migrations-Ordner
  (`20260222122319691`) wurden gelöscht und durch eine frische
  Basismigration (`20260923104843538`) ersetzt; beides mal entstanden
  je ein Upgrade-Migrationsordner `*-upgrade-4-0`.
- In beiden `docker-compose.yaml` wurde `container_name: rustfs_server`
  entfernt (Namenskollision, wenn beide Compose-Stacks gleichzeitig
  laufen).
- Die generierten Dateien (`src/generated/…`, Client-`protocol/…`) und
  `test_tools/serverpod_test_tools.dart` wurden neu generiert.
- Bisher keine Fehler bekannt; falls nach dem Upgrade Auffälligkeiten
  auftreten, zuerst Generate/DB-Migrationsstand prüfen.

## Fortsetzung

- Firmware-Seite: siehe `doorinterface/AGENTS.md` → „Fortsetzung“.
- Apps-Seite: siehe [`apps/AGENTS.md`](apps/AGENTS.md) → „Fortsetzung /
  offene Baustellen“ — die Richtung (ERP-Ziel, Instanz-Sync,
  Login-Modell) ist dort beschrieben.
