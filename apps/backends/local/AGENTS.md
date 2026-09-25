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

Seit 2026-09-25 **Site-Modul** implementiert (kein reiner Spiegel mehr):

- **Enrollment**: lokale Maske verifiziert mit den **globalen
  Anmeldedaten des Site-Admins** bei der globalen Instanz
  (`siteSetup.enterSetup` → `top_attempt_global_client` → globaler
  `siteEnrollment`-Endpoint; Site-Picker falls der Admin mehrere Sites
  betreut).
- ** Mitglieder-Verzeichnis**: Nach dem Enrollment wird der lokale Members-Eintrag
  des Admins angelegt (`site_connections.adminAuthUserId` —
  **globalAuthUserId = Austausch-ID**, später auch Türfreigabe-Schlüssel)
  und ein **lokaler AuthUser** erstellt (E-Mail wie global, **gleiches
  Passwort**, wie der Admin es gerade genutzt hat; Scope
  `local-admin` — über `EmailIdp.admin.createEmailAuthentication`
  verschlüsselt lokal ge-hashed). Keine (!) lokale Selbst-Registrierung:
  Logins entstehen grundsätzlich nur aus verifizierten Global-Logins
  (Muster gilt später genauso für Angestellte).
- **Device-Verbindung**: `GlobalSiteConnection`-Worker (in `server.dart`
  gestartet): liest die Credentials und die global API URL
  (`siteConnection.globalApiUrl` in config), Client-Auth mit dem
  (`siteConnection.globalApiUrl` in config), Client-API-Auth mit dem
  **non-rotating SAS-Session-Key** (`AuthStrategy.session`), Method-Stream
  `siteConnection.connect`, Ping alle 30 s → `lastSeenAt` beim globalen
  Backend frisch; Reconnect mit Backoff (5→60 s), Status-Maschine
  `noneSetup|connecting|reconnecting|connected|needsReSetup|failure`
  (`needsReSetup` = Widerrufen/abgelaufen → lokale Maske, Recovery durch
  erneutes Setup mit globalen Zugangsdaten).
- Config: `siteConnection.globalApiUrl` in `config/development.yaml`
  (Dev: `http://localhost:8080`; Devices: LAN-IP).

Bis auf das Site-Modul ist das Backend noch der beim Serverpod-4-Upgrade
angelegte Spiegel des globalen (JWT-Auth + `ProfileDetails`), fertig
eingerichtete Infrastruktur (Ports/RustFS) siehe unten.

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

`serverpod start` startet Docker, Server und zusätzlich automatisch die
Site-Admin-App (`serverpod: flutter_apps:` in der Server-pubspec,
`device: chrome`). `--no-flutter` unterdrückt den Autostart; Apps lassen
sich im Start-TUI jederzeit per Ctrl+R nachstarten.

## Endpoints (eigener Code)

| Endpoint | Zweck |
|---|---|
| `emailIdp` (`src/auth/email_idp_endpoint.dart`) | E-Mail-IdP: Login lokal (Registrierung/Members-Login ist bewusst aus) |
| `jwtRefresh` (`src/auth/jwt_refresh_endpoint.dart`) | Access-Token erneuern |
| `profileDetails` (`src/profile/profile_details_endpoint.dart`) | Vor-/Nachname + Geburtstag (Spiegel von global) |
| `siteSetup` (`src/site/site_setup_endpoint.dart`) | `enterSetup({email, password, siteId?})` (verifiziert global, verarbeitet Transfer: Members-Zeile + lokaler `local-admin`-Login) und `connectionStatus()` für den App-Bar-Chip |
| `greeting` (`src/greetings/…`) | Serverpod-Beispiel-Endpoint |

Kein `userProfileEdit`-Endpoint im eigenen Code (im globalen Backend
vorhanden) — beim Ausbau des Mitglieder-/Angestellten-Modells klären.

## Offene Fragen (nächster Ausbau)

1. **Membership-Sync über den Stream**: Neue/entfernte globale
   `SiteMembership`-Events in die lokale `members`-Tabelle propagieren
   (die WS-Verbindung ist dafür die Transport-Ebene; nach Grad der
   Daten/O-ID-Regel: `members.globalAuthUserId` = globale Person-ID,
   Türfreigabe-Schlüssel).
2. **Angestellte**: Member muss sich vor Ort mit globalen Anmeldedaten
   verifizieren → lokales Login (gleiches Modell wie der Admin-Setup);
   Rolle/Status global ändern (über `site-device`-beschränkte Endpoints).
3. **ESP32-Protokoll**: Wie meldet sich der ESP32 hier an (empfohlen:
   ausgehender WebSocket-Client mit Geräte-Token, siehe
   docs/project.md → To-dos)?
4. **Authentifizierung des lokalen Admin-UI** (`local-admin`): Login-Flow
   in `top_attempt_local_flutter` (derzeit offen — die Setup-Maske
   existiert, der Mitglieder/Admin-Bereich braucht eine Schutzschicht).

## Test / CI

- `dart test` (Integration-Tests mit `test_tools/serverpod_test_tools.dart`).
- CI: `analyze.yml`, `format.yml`, `tests.yml` (Docker-Compose) —
  Versionen dort noch alt (Dart 3.8.0 / CLI 3.3.1), To-do siehe
  apps/AGENTS.md.

## Fortsetzung

- Nächster Schritt: Membership-Sync über die WS-Verbindung (offene Frage
  1), danach Mitglieder-/Angestellten-Modell + Admin-UI-Schutz.
- Migrationen: Basismigration `20260923104843538` +
  `20260923112557527-upgrade-4-0` + Site-Modul-Migration
  `20260925151309478` (SiteConnection/Member).
