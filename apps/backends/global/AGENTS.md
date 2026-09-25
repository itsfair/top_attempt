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

`serverpod start` startet Docker, Server und zusätzlich automatisch die
Plattform-Admin-App (`serverpod: flutter_apps:` in der Server-pubspec,
`device: chrome`). `--no-flutter` unterdrückt den Autostart; Apps lassen
sich im Start-TUI jederzeit per Ctrl+R nachstarten. Die Enduser-App ist
bewusst nicht konfiguriert — sie läuft separat auf einem physischen
Android-Gerät.

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

### Site-Einrichtung / Enrollment (Stand 2026-09-25)

- Modelle: `Site` (Tabelle `sites`: Adresse, `companyEmail`,
  `status`-Enum `pendingSetup|registered`, `firstAdmin`-Relation,
  `registeredAt`/`lastSeenAt`), `SiteMembership` (Tabelle
  `site_memberships`: site + authUser + `role`-Enum
  `member|staff|siteAdmin` + `active`) — globales Quellverzeichnis der
  Mitgliedschaften. `SiteDeviceSession` (Tabelle `site_device_sessions`:
  site ↔ SAS-Session-Id, eine aktive Session je Site).
- `createSite` generiert **keine Secrets mehr**: Der Site-Admin richtet
  die lokale Instanz vor Ort mit seinen **globalen Anmeldedaten** ein
  (alte OTP- / Initialpasswort-Mechanik wurde entfernt).
- `SiteEnrollmentEndpoint` (public): `listSiteAdminCandidates` +
  `enroll({email, password, siteId?})` — verifiziert die globalen
  Zugangsdaten über die E-Mail-IdP-Logik (Rate-Limit/Sperr-Checks
  geerbt, Login-Session wird von dort nicht angelegt), löst die
  aktive `siteAdmin`-Membership auf (bei mehreren →
  `requiresSiteSelection` + Kandidaten für den Site-Picker in der
  lokalen Maske), setzt dann:
  - frisches Setup: Site → `registered` + `registeredAt`, Transfer
    (Site + Admin-E-Mail/-Name + `adminAuthUserId` — **Austausch-ID für
    die lokale Members-Tabelle, später Schlüssel der Türfreigabe**) und
    der Device-Session-Key.
  - Recovery: wie frisches Setup, ohne Transfer-Daten; vorherige
    `SiteDeviceSession` wird revoked + ersetzt. Der lokale Admin kann
    damit allein re-setup-en.
  - Device-Credential: SAS-Session (`method: 'device'`, token-level
    Scope `site-device`, `AuthStrategy.session`, non-rotating,
    write-once lokal; kein Julius-Ablauf). Key in
    `serverSideSessionKeyHashPepper` (passwords.yaml, dev+test).
  - `sitesAdmin.revokeSiteConnection(siteId)`: widerruft die
    Geräteanmeldung (Site bleibt erhalten).
- `SiteConnectionEndpoint` (`requiredScopes: {site-device}`):
  Method-Stream `connect(Stream<SitePing>)→Stream<SiteEvent>`: jede
  Ping-Aktualität frischt `lastSeenAt` auf (Site aus der Mapping-Row via
  `session.authenticated!.authId`). Sperr-Hygiene:
  `usersAdmin.setBlocked` revokiert zusätzlich alle `device`-Sessions
  des Users (SAS-Verification prüft `blocked` nicht pro Request).
- IdentityProvider-Zugriff: `AuthServices.getIdentityProvider<EmailIdp>()`
  (aus `providers/email.dart`); Passwortverify ohne Token-Issue über
  `emailIdp.utils.authentication.authenticate`.
- Authservices-Registrierung: zweiter TokenManagerBuilder
  (`SiteDeviceAuthentication.config`) neben JWT; Pepper
  `serverSideSessionKeyHashPepper` in passwords.yaml (dev/test; CI über
  SERVERPOD_PASSWORD_* env To-do).

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
- 2026-09-25: Site-Anlage + Enrollment fertig (`sitesAdmin.createSite`
  ohne Secrets, `siteEnrollment` (glo. Anmeldedaten-Verify, Site-Picker,
  Device-Session-Issuance SAS `method: 'device'`, Scope
  `site-device` token-level), `SiteConnectionEndpoint`-Stream,
  `SiteDeviceSession`-Mapping, Migrationen `20260925122822442` +
  `20260925150857366`).
- Nächste Schritte (Stufe 3, Details in apps/AGENTS.md → To-dos):
  Membership-Sync über die WS-Verbindung (neue/reingelöschte Member
  propagieren), Live-Status-Push an die Admin-Clients (message central),
  Mitglieder-/Angestellten-Ausbau lokal, ESP32-Geräte-Autorisierung.
