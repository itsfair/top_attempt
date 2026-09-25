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
| `usersAdmin` (`src/admin/users_admin_endpoint.dart`) | Plattform-Admin: `listUsers` (50/Seite, Filter E-Mail/Name ILIKE), `getUser`, `setBlocked`, `setGlobalAdmin`, eigene `UserAdminException` |
| `sitesAdmin` (`src/sites/sites_admin_endpoint.dart`) | Plattform-Admin, Sites ("Betriebe"): `createSite` (Validierung, One-Time-Passwort + initiales Admin-Passwort inkl. Ab-, Zustand für erste Verbindung), `listSites`/`countSites` (50/Seite, Suche), `getSite` |
| `greeting` (`src/greetings/…`) | Serverpod-Beispiel-Endpoint |

### Site-Einrichtung / Secrets (2026-09-25)

- Modelle: `Site` (Tabelle `sites`: Adresse, `companyEmail`,
  `status`-Enum `pendingSetup|registered`, `firstAdmin`-Relation als
  Anlage-Komfortverweis) sowie die serverOnly-Felder
  `oneTimePasswordHash` und `initialAdminPasswordEncrypted` (nie Richtung
  Client). `SiteMembership` (Tabelle `site_memberships`: site + authUser +
  `role`-Enum `member|staff|siteAdmin` + `active` bool) — globales
  Quellverzeichnis der Mitgliedschaften; die lokale Instanz leitet daraus
  ihre lokale Repräsentation ab (Stufe 2-Sync).
- Secrets-Lifecycle bei `createSite`: One-Time-Passwort (32 Zeichen
  alfanumerisch) wird als SHA-256-Hash gespeichert; initiales Admin-Passwort
  (16 Zeichen, alle Zeichenklassen, passwort-policy-kompatibel) wird
  **AES-256-GCM verschlüsselt** abgelegt (Key `siteSetupEncryptionKey` in
  `config/passwords.yaml` unter `development`, AES-Key = SHA-256 des
  Secrets). Die Klartextwerte werden via `CreatedSiteInfo` genau einmal an
  die UI zurückgegeben und nie wieder versendet. Nach der ersten Verbindung
  der lokalen Instanz (Stufe 2) wird `initialAdminPasswordEncrypted`
  **gelöscht**; das OTP wird bei der Registrierung verbrannt und das eine
  device credential siehe To-dos aus.
- Selbstschutz/Validierung: gesperrte Admin-Nutzer werden abgelehnt,
  Firmenmail wird per Regex validiert, Fehler → `SiteAdminException`.

### Admin-Scopes (2026-09-24)

- `kGlobalAdminScope = 'global-admin'` (`src/auth/scopes.dart`); Admin-Endpoints
  erzwingen ihn **deklarativ** über `Endpoint.requiredScopes` (Serverpod
  Dispatch prüft `session.authenticated.scopes` aus dem JWT).
- Scopes liegen auf dem `AuthUser` (`serverpod_auth_core_user.scope_names`)
  und werden **beim Login in Access- und Refresh-Token „eingebrannt“**.
  `rotateRefreshToken` re-liest beim Rotieren nur `blocked`, **nicht die
  Scopes** — laufende Sessions sehen Scope-Änderungen erst, wenn die
  Tokens revoked werden bzw. ein neuer Login stattfindet. Deshalb rufen
  `setBlocked`/`setGlobalAdmin` nach dem Update `revokeAllTokens` +
  `authenticationRevoked` auf.
- Selbstschutz in den Endpoints: die eigene Sperre wird abgewiesen; der
  eigene `global-admin`-Scope kann nicht entzogen werden (sonst
  Selbst-Ausschluss ohne Weg zurück). Der **erste Admin** bleibt als
  Dev-SQL-Update (`scope_names` auf `serverpod_auth_core_user`) +
  Re-Login.

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
- 2026-09-24: erstes Admin-Endpoint-Set fertig (`usersAdmin`: paging-fähige
  Nutzerliste 50/Seite mit E-Mail/Name-Suche, Blocked- und
  Global-Admin-Toggles inkl. Token-Revocation; Selbstschutz gegen
  Aussperren). Bedient die Members-Seite der Plattform-Admin-App.
- 2026-09-25: Site-Anlage fertig (`sitesAdmin`, Modelle `sites` +
  `site_memberships`, One-Time-Passwort + initiales Admin-Passwort,
  Secrets-Lifecycle siehe Abschnitt oben). Migration
  `20260925122822442`.
- Nächste Schritte (Stufe 2/3, Details in apps/AGENTS.md → To-dos):
  Registrierungsprotokoll der lokalen Instanz (OTP verbrauchen, device
  credential ausstellen), WS-Verbindungsmanagement + Heartbeat
  (`lastSeenAt`), Erstverbindungs-Übertragung (SiteMembership-Sync:
  member → lokale Members-Zeile ohne Login; staff/siteAdmin → verknüpfter
  lokaler AuthUser mit `local-admin`-Scope), WS-Status pro Site in der
  Sites-Liste der globalen UI, Site edit/delete + OTP-Regenerierung,
  E-Mail-Versand der Einrichtungsgeheimnisse.
