# AGENTS.md — Serverpod-Backend „local“

Lokale Serverpod-Instanz des Monorepos `top_attempt`: **eine Instanz pro
Betrieb/Standort (Türanlage)**. Soll den Betrieb vor Ort abbilden —
Selbsteinlass (Türzugang) und später ERP-Features (Kursverwaltung,
Angestelltenverwaltung, Schichtplan) — und bei kurzer Internettrennung
autark weiterlaufen. Teil des Dart-Workspaces `apps/` — Kontext und
Instanz-Modell: [`apps/AGENTS.md`](../../AGENTS.md), Monorepo-Struktur:
[Root-AGENTS.md](../../../AGENTS.md).

## Zweck (Zielbild)

- Autorisierung des Türzugangs: ESP32 reicht (per BLE von der Enduser-App
  empfangene) Zugangsdaten an diese Instanz weiter; hier wird geprüft und
  die Tür geschaltet. **Ohne Cloud-Roundtrip** — die lokale Instanz muss
  dafür genug Daten lokal halten (Synchronisation von der globalen
  Instanz, Details offen).
- Verwaltung von Geräten (ESP32/NUKI), Mitgliedern und Zugangsrechten —
  Bedienung über die Site-Admin-App (`top_attempt_local_flutter`).
- ERP-Ausbau Stück für Stück: Kurse, Angestellte, Schichtplan.

## Aktueller Stand (wichtig!)

**Momentan 1:1-Spiegel des globalen Backends** — beim Serverpod-4-Upgrade
(„Repaired local backend for upgrade", Commit `fc2574b`, 2026-09-23)
wurde dieses Backend initialisiert und an das globale angeglichen:

- E-Mail-IdP (Registrierung/Login/Reset), JWT-Auth
- `ProfileDetailsEndpoint` (Vor-/Nachname, Geburtstag) — gleiches
  Datenmodell wie global
- RustFS-Storage (Bucket `top-attempt`), gleiche Implementierung wie
  global inkl. `rustFS:`-Config-Reader in `lib/server.dart`
- Ports verschoben (siehe unten), sonst gleiche Struktur

**Fachlich fehlt noch alles Tür-/Betriebsspezifische**: kein
Gerätemodell, kein Mitgliedermodell, keine Berechtigungen, kein
ESP32-Protokoll. Das ist der nächste große Baustein.

## Ports / Infrastruktur (Dev)

- API 8180, Insights 8181, Web 8182 (`config/development.yaml`)
- Postgres 8190, Redis-Port 8191 (Redis `enabled: false`), DB-Name
  `top_attempt`
- RustFS: S3-API 9000, Konsole **9101** (global nutzt 9001 — beide
  Stacks können gleichzeitig laufen; `container_name: rustfs_server`
  wurde deshalb entfernt)
- `top_attempt_local_client`: generiertes Client-Paket; nach
  Modelländerungen `serverpod generate` im Server-Paket ausführen.

## Starten (Dev)

```bash
cd apps/backends/local/top_attempt_local_server
docker compose up --build --detach
dart pub get
dart bin/main.dart   # Start-Skript mit --apply-migrations: siehe pubspec (serverpod.scripts.start)
```

## Endpoints (eigener Code)

Identisch zum globalen Backend (Stand: Spiegel):

| Endpoint | Zweck |
|---|---|
| `emailIdp` (`src/auth/email_idp_endpoint.dart`) | E-Mail-IdP: Registrierung, Login, Passwort-Reset (Codes werden in Dev nur geloggt) |
| `jwtRefresh` (`src/auth/jwt_refresh_endpoint.dart`) | Access-Token erneuern |
| `profileDetails` (`src/profile/profile_details_endpoint.dart`) | Vor-/Nachname + Geburtstag; gleiche Validierung wie global |
| `greeting` (`src/greetings/…`) | Serverpod-Beispiel-Endpoint |

Kein `userProfileEdit`-Endpoint im eigenen Code (im globalen Backend
vorhanden) — falls das kein bewusster Unterschied ist, beim Aufbau des
Mitgliedermodells klären.

## Offene Fragen (Blocker für den nächsten Ausbau)

1. **User-/Login-Modell**: Globale User 1:1 inkl. Zugangsdaten
   synchronisieren (Attribut `staff` regelt Zugang zur lokalen
   Verwaltungsoberfläche) **oder** separate Tabelle `members` mit lokal
   neu angelegten Zugangsdaten (verknüpft mit Members)? → einer der
   nächsten Klärungspunkte, siehe auch apps/AGENTS.md.
2. **ESP32-Protokoll**: Wie meldet sich der ESP32 hier an (empfohlen:
   ausgehender WebSocket-Client mit Geräte-Token, siehe
   docs/project.md → To-dos)?
3. **Autarkie-Umfang**: Welche Daten müssen offline verfügbar sein
   (Mitglieder + Zugangsrechte sicher; Kurse z. B. nicht kritisch)?

## Test / CI

- `dart test` (Integration-Tests mit `test_tools/serverpod_test_tools.dart`).
- CI: `analyze.yml`, `format.yml`, `tests.yml` (Docker-Compose) —
  Versionen dort noch alt (Dart 3.8.0 / CLI 3.3.1), To-do siehe
  apps/AGENTS.md.

## Fortsetzung

- Nächster Schritt: Klärung User-/Login-Modell (offene Frage 1), dann
  Datenmodell für Geräte/Mitglieder/Berechtigungen + erste Endpoints.
- Migrationen: Basismigration `20260923104843538` +
  `20260923112557527-upgrade-4-0` (alte Migration wurde beim Upgrade
  gelöscht, DB neu erstellt — Details apps/AGENTS.md → Upgrade-Abschnitt).
