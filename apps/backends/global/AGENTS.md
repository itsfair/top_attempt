# AGENTS.md — Serverpod-Backend „global“

Zentrale Serverpod-Instanz des Monorepos `top_attempt`: die eine
Plattform-Ebene, auf der Enduser Benutzerkonten anlegen und ihre Profile
pflegen. Teil des Dart-Workspaces `apps/` — Kontext und Instanz-Modell:
[`apps/AGENTS.md`](../../AGENTS.md), Monorepo-Struktur:
[Root-AGENTS.md](../../../AGENTS.md).

## Zweck

- Registrierung/Login von Endusern (E-Mail + Passwort) und Passwort-Reset.
- Zentrale Profile (Name, Geburtstag, Profilbild) — Datenbasis, aus der
  später lokale Instanzen Mitgliederdaten synchronisieren.
- Später ggf. globale Entitäten (z. B. Kurskatalog — offen, siehe
  apps/AGENTS.md → „Offene Architekturfragen“).
- Partner-App: `apps/frontends/top_attempt_global_flutter`
  (Plattform-Admin, noch Scaffold) und `top_attempt_enduser_flutter`
  (ausgebaut).

## Layout / Ports

- Serverpod 4.0.2; Ports in Dev: API 8080, Insights 8081, Web 8082
  (`config/development.yaml`); Postgres 8090, Redis-Port 8091
  (Redis `enabled: false`).
- `top_attempt_global_client`: generiertes Client-Paket, wird von den
  Frontends per Pfad-Dependency eingebunden. Nach Modelländerungen
  `serverpod generate` im Server-Paket ausführen.

## Starten (Dev)

```bash
cd apps/backends/global/top_attempt_global_server
docker compose up --build --detach
dart pub get
dart bin/main.dart   # Start-Skript mit --apply-migrations: siehe pubspec (serverpod.scripts.start)
```

## Endpoints (eigener Code)

| Endpoint | Zweck |
|---|---|
| `emailIdp` (`src/auth/email_idp_endpoint.dart`) | E-Mail-IdP: Registrierung, Login, Passwort-Reset (Verifizierungscodes werden in Dev nur geloggt) |
| `jwtRefresh` (`src/auth/jwt_refresh_endpoint.dart`) | Access-Token erneuern |
| `userProfileEdit` (`src/auth/user_profile_edit_endpoint.dart`) | E-Mail/User-ID/Profilbild über das eingebaute Auth-Modul |
| `profileDetails` (`src/profile/profile_details_endpoint.dart`) | Vor-/Nachname + Geburtstag; requireLogin, Name 1–60 Zeichen, Geburtstag 1900–gestern; Name wird synchron in das UserProfile geschrieben |
| `greeting` (`src/greetings/…`) | Serverpod-Beispiel-Endpoint |

Auth-Setup in `lib/server.dart` (`initializeAuthServices`: JWT +
EmailIdp, Codes werden geloggt statt gemailt). RustFS-Storage ist als
Storage-Id `public` registriert (Bucket `top-attempt`), Endpoint aus
`rustFS:`-Block der Stage-Config — **kein `publicHost` setzen**
(Adapter-Bug v1.0.0, siehe Root-AGENTS.md).

## Datenmodell

- Eigene Tabelle `profile_details` (`src/profile/profile_details.spy.yaml`):
  `authUserId`, Vor-/Nachname, Geburtstag. Pflichtfelder Name + Geburtstag,
  Bild optional und im `UserProfile`.
- Restliche Auth-Daten liegen in den Serverpod-Auth-Modul-Tabellen.

## File-Storage

RustFS (S3-API), Dev: LAN-IP aus `config/development.yaml` → Port 9001
(Konsole), S3 auf 9000, Credentials rustfsadmin / rustfsadmin_secret.
CORS am Bucket aktivieren, wenn Flutter-Web direkt auf Dateien zugreift.

## Test / CI

- `dart test` (Integration-Tests mit `test_tools/serverpod_test_tools.dart`).
- CI: `analyze.yml`, `format.yml`, `tests.yml` (Docker-Compose) —
  Versionen dort noch alt (Dart 3.8.0 / CLI 3.3.1), To-do siehe
  apps/AGENTS.md.

## Stand / Fortsetzung

- Stand: MVP-Basis — Auth + Profile + Storage funktionieren gegen die
  Enduser-App; verifizierter Stand nach Serverpod-4.0.2-Upgrade
  (2026-09-23), siehe apps/AGENTS.md → Upgrade-Abschnitt.
- Nächste Schritte: Rolle in der Instanz-Synchronisation klären
  (Member-Daten-/Login-Modell), Entscheidung globale Entitäten
  (Kurskatalog), Admin-Funktionen für die Plattform-Admin-App bereitstellen.
