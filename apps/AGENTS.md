# AGENTS.md — apps (Dart-Workspace: Backends + Frontends)

Dieser Ordner fasst alle Dart/Flutter-Pakete in einem Workspace zusammen
(`apps/pubspec.yaml`, `resolution: workspace`). Die globale Monorepo-
Struktur steht in der [Root-AGENTS.md](../AGENTS.md) — hier geht es um
die Details der Backends und Frontends.

## Workspace

`apps/pubspec.yaml` definiert den Workspace. **Aktuell Mitglied:**

- `backends/global/top_attempt_global_client`
- `backends/global/top_attempt_global_server`
- `backends/local/top_attempt_local_client`
- `backends/local/top_attempt_local_server`
- `frontends/top_attempt_enduser_flutter`

**Noch NICHT im Workspace** (obwohl `resolution: workspace` gesetzt):
`frontends/top_attempt_global_flutter`, `frontends/top_attempt_local_flutter`,
`frontends/top_attempt_flutter`. → To-do, siehe unten. Bis dahin
funktioniert `dart pub get` auf Workspace-Ebene für die neuen Frontends
nicht; einzeln auflösen oder Workspace erweitern.

SDK-Constraint: `^3.12.2` (lokal installiert: Dart 3.13.4, Flutter 3.47.5,
Serverpod-CLI 4.0.2).

## Instanz-Modell (fachlich)

Zwei Instanz-Ebenen, begrifflich strikt trennen:

- **Globale Instanz** (`global`) — die eine zentrale Plattform-Instanz.
  Enduser registrieren sich hier (E-Mail-IdP), hier leben Benutzerkonten
  und Profile. Später ggf. globale Entitäten (z. B. Kurskatalog — offene
  Frage, siehe unten).
- **Lokale Instanz** (`local`) — **eine Instanz pro Betrieb/Standort**
  (Türanlage). Bildet den Betrieb ab: Selbsteinlass (Türzugang), später
  ERP-Features (Kursverwaltung, Angestelltenverwaltung, Schichtplan).
  Muss bei kurzer Internettrennung autark weiterlaufen.

**Mitgliedschaft/Flow (Zielbild):**

1. Enduser registriert sich global (E-Mail, Profil mit Name/Geburtstag/Bild).
2. Enduser schreibt sich bei einer lokalen Instanz als Mitglied ein.
3. Die lokalen Instanz bekommt die nötigen Nutzerdaten synchronisiert
   (Details offen, siehe unten).
4. Site-Admin verwaltet Mitglieder seiner Instanz (Zugangsrechte etc.).
5. Selbsteinlass: Enduser scannt QR an der Location → OTP abfragen →
   OTP per BLE an ESP32 → ESP32 an lokale Instanz → Instanz prüft und
   schaltet Tür über den ESP32/NUKI.

Der Türzugang selbst braucht **keinen Cloud-Roundtrip** (BLE + lokale
Instanz genügt); die Absicherung darüber (OTP-Herkunft, Synchronisation)
ist der langfristige Zielzustand.

### Offene Architekturfragen (noch zu klären)

- **Login-/User-Modell lokal:** Werden globale User 1:1 mit Zugangsdaten
  übertragen (Attribut `staff` regelt Zugang zur lokalen Verwaltung) oder
  landen User in separater Tabelle `members` mit lokal neu angelegten
  Zugangsdaten (verknüpft mit der Members-Tabelle)? → einer der nächsten
  Klärungspunkte.
- **Globale vs. lokale Entitäten (z. B. Kurse):** Kurse könnten global
  angelegt werden (Enduser sieht/bucht sie global) oder lokal und werden
  global synchronisiert/erreichbar gemacht (WebSocket?). Kurse sind nicht
  kritisch für den lokalen Betrieb bei Internetausfall.
- **„Von außen erreichbar":** Wie genau lokale Instanzen über die globale
  Instanz erreicht werden (technisches Routing vs. nur fachlich zentrale
  Verwaltung) — noch unbesprochen.

## Ports / Infrastruktur (Dev)

| | global | local |
|---|---|---|
| API-Server | 8080 | 8180 |
| Insights | 8081 | 8181 |
| Web-Server | 8082 | 8182 |
| Postgres | 8090 | 8190 |
| Redis (disabled) | 8091 | 8191 |
| RustFS S3-API / Konsole | 9000 / 9001 | 9000 / 9101 |

Beide Backends haben eigene `docker-compose.yaml` (Postgres + Redis +
RustFS) und können gleichzeitig laufen (`container_name: rustfs_server`
wurde deshalb entfernt). DB-Name jeweils `top_attempt`. RustFS-Bucket
`top-attempt` (Credentials rustfsadmin / rustfsadmin_secret); der
Endpoint kommt aus dem `rustFS:`-Block der `config/<runMode>.yaml`
(Dev: LAN-IP des Entwicklungsrechners, wichtig für Tests am echten
Gerät). **Kein `publicHost` setzen** (Adapter-Bug, siehe Root-AGENTS.md).
Redis ist in beiden `development.yaml` derzeit `enabled: false`.

## Backends

### global (`apps/backends/global/`) — Details in [AGENTS.md](backends/global/AGENTS.md)

Zentrale Benutzerverwaltung: E-Mail-IdP (Registrierung/Login/Reset),
JWT-Auth, `UserProfileEditEndpoint` (E-Mail/User-ID/Bild),
`ProfileDetailsEndpoint` (Vor-/Nachname, Geburtstag), RustFS-Storage.
Stand: MVP-Basis, funktionsfähig gegen die Enduser-App; `usersAdmin`
(2026-09-24: Nutzerlisten-Paging, Globale-Admin-/Blocked-Toggles inkl.
Token-Revocation, `global-admin`-Scope); **Site-Ebene (2026-09-25)**:
`sitesAdmin` (createSite ohne Secrets, Site-Verwaltung inkl.
`revokeSiteConnection`), `siteEnrollment` (globale Anmeldedaten-Verify,
Site-Picker, Device-Session = SAS `method:'device'`, token-level Scope
`site-device`, Mapping-Tabelle), `siteConnection` (Method-Stream,
Ping/Pone aktualisiert `lastSeenAt`) — der lokale Backend verbindet sich
damit — Details/Offenpunkte im Backend-AGENTS.md. Site-Migrationen:
`20260923122822442` + `20260925150857366`.

### local (`apps/backends/local/`) — Details in [AGENTS.md](backends/local/AGENTS.md)

Lokale Instanz eines Betriebs/Standorts. Seit 2026-09-25 **Site-Modul**:
Enrollment über die globalen Anmeldedaten des Site-Admins
(`siteSetup.enterSetup` mit globalem Client-Dep), lokales
Mitglieder-Verzeichnis (`members` mit `globalAuthUserId` als
Austausch-/Tür-ID), lokaler `local-admin`-Login (gleiches Passwort wie
global beim Setup), und der Verbindungs-Worker
(`GlobalSiteConnection`: SAS-Session-Key device cred, long-lived
Method-Stream + 30s-Ping → `lastSeenAt`, Backoff-Reconnect,
`needsReSetup`-Status). Keine lokale Selbst-Registrierung — Logins
entstehen nur aus verifizierten Global-Logins (gilt später für
Angestellte identisch). Grundverwaltung/Ports: wie global (8180er-Schema).

## Frontends

### top_attempt_enduser_flutter — Details in [AGENTS.md](frontends/top_attempt_enduser_flutter/AGENTS.md)

Enduser-App: Login (global), Profil (Bild/QR/ID), QR-Reader,
BLE-Testsession gegen den ESP32. Am weitesten ausgebaut.

### top_attempt_global_flutter — Details in [AGENTS.md](frontends/top_attempt_global_flutter/AGENTS.md)

**Plattform-Admin-App** (Verwaltung der globalen Instanz). GoRouter mit
Auth-/Scope-Guard (nicht eingeloggt → `/sign-in`, ohne
`global-admin`-Scope → `/forbidden`); Drawer-Layout; Members-Screen (50/
Seite + Suche + „Weitere laden“, Detail-Editor für
`Global Admin`/`blocked`) und seit 2026-09-25 Sites-Screen (FAB + Create-
Dialog mit erster Site-admin-Auswahl, Onboarding-Modal für beide
Einrichtungsgeheimnisse je genau einmal, Detail-Route `/sites/:id`).
Bindet den globalen Client ein.

### top_attempt_local_flutter — Details in [AGENTS.md](frontends/top_attempt_local_flutter/AGENTS.md)

**Site-Admin-App** (Verwaltung einer lokalen Instanz: Geräte, Nutzer vor
Ort, Zugangsrechte; später ERP-Ausbau). Aktuell rohes Serverpod-Scaffold;
bindet bewusst **beide** Clients ein (global + local), da die App auch
globale Eigenschaften manipulieren wird (z. B. Kursverwaltung — offen,
siehe oben).

### top_attempt_flutter — Details in [AGENTS.md](frontends/top_attempt_flutter/AGENTS.md)

**Kopiervorlage**: rohes Serverpod-Grundgerüst, kein eigener Zweck. Wird
von den `flutter_build`-Skripten beider Backends noch als Web-App-Quelle
referenziert (To-do: auf die echten Apps umstellen oder bewusst lassen).

## Serverpod-Upgrade 3.4.12 → 4.0.2 (2026-09-23, für Fehlersuche)

Nach offizieller Anleitung (https://docs.serverpod.dev/upgrading/upgrade-to-four).
Rekonstruktion aus Git:

- Commits: `103c597` („Serverpod 3.4.12 upgrade, RustFS file storage, user
  profile feature“ — Vorzustand), dann `106f5b4`/`e5f95b6` (RustFS + Profile
  ins lokale Backend), dann `fc2574b` („Repaired local backend for upgrade“).
- `apps/pubspec.yaml` + beide Backend-pubspecs: SDK auf `^3.12.2`,
  serverpod-Pakete auf `4.0.2` (serverpod, serverpod_auth_idp_server,
  serverpod_test; Frontends: serverpod_flutter, serverpod_auth_idp_flutter).
- Lokales Backend wurde dabei initialisiert und an das globale angeglichen
  (Auth-IdP, ProfileDetails, RustFS, yaml-Config-Reader in `lib/server.dart`).
- **Migrations gelöscht + DB neu erstellt:** lokale Migration
  `20260222122319691` entfernt, frische Basismigration
  `20260923104843538` erzeugt. Globale Registry:
  `20260222122319691`, `20260827100208475`, `20260923112307048-upgrade-4-0`;
  lokale Registry: `20260923104843538`, `20260923112557527-upgrade-4-0`.
  Wenn danach DB-/Schema-Fehler auftreten: Migrationsstand beider Backends
  und `serverpod --apply-migrations` prüfen.
- Beide `docker-compose.yaml`: `container_name: rustfs_server` entfernt
  (Kollision bei gleichzeitigen Stacks).
- Generierte Dateien neu erzeugt (`src/generated/…`, Client-`protocol/…`,
  `test_tools/serverpod_test_tools.dart`).
- Stand jetzt: keine bekannten Fehler. CI pinnt noch CLI `3.3.1`
  (siehe To-dos).

## To-dos / offene Baustellen (apps-übergreifend)

1. **Workspace-Membership**: `top_attempt_global_flutter`,
   `top_attempt_local_flutter` (und `top_attempt_flutter`) in
   `apps/pubspec.yaml` aufnehmen.
2. **CI vereinheitlichen**: `analyze.yml`/`format.yml`/`tests.yml`
   nutzen Dart 3.8.0 bzw. Serverpod-CLI 3.3.1 — auf 3.13/4.0.2 heben
   (lokale Realität: Dart 3.13.4, Flutter 3.47.5, CLI 4.0.2).
3. **`flutter_build`-Skripte** beider Backends bauen noch
   `top_attempt_flutter` als Web-App — Ziel-App festlegen.
4. **User-/Login-Modell lokal** klären (siehe offene Fragen oben) —
   Blocker für das Mitglieder-/Berechtigungsmodell im lokalen Backend.
5. **Local-Frontend-Inhalte**: Site-Admin-UI (Geräte, Mitglieder,
   Zugangsrechte) aufbauen, sobald das lokale Backend-Modell steht.
6. **Members-Feature Hartening** (2026-09-24 erstes Set): Integrations-Tests
   für `usersAdmin`-Endpoints, Bestätigungsdialog beim Sperren,
   `usersAdmin`-Nutzer konsequent hinter `requiredScopes` halten
   (Scope-Guard-Fehler → `UserAdminException`/`AccessDeniedException`
   clientseitig abfangen).
7. **Registrierung im global-Admin-Frontend abschalten** (nicht dringend):
   Versuche 2026-09-25 (Texte leeren + `EmailAuthController`-Subclass)
   wirkten nicht — Details und Ansätze für später in
   [`frontends/top_attempt_global_flutter/AGENTS.md`](frontends/top_attempt_global_flutter/AGENTS.md)
   → „Nächste Schritte“, Punkt 5.
8. **Stufe 2 — Enrollment/WS umgesetzt (2026-09-25)**; verbleibende
   Stufen (Stufe 3):
   a) **Membership-Sync über den Method-Stream**: neue/entfernte globale
      `SiteMembership`-Events in die lokale `members`-Tabelle (Regel:
      lokale Rows führen `globalAuthUserId` — Austausch- und Tür-ID),
      Staff-Wechsel → lokales LOGIN analog Admin-Setup (bereits aus
      verifizierten Global-Logins, dann Scope-Zuweisung beim lokalen
      Admin) — und Rollen/Status rückgemeldet (site-device-beschränkte
      Endpoints).
   b) **Live-Status-Push** an die Admin-Clients (message central) statt
      30s-Polling in der globalen Sites-Liste.
   c) **Lokaler Schutz**: Admin-UI-Login (local-admin) für die lokale
      App — aktuell offen (Setup-Maske ungeschützt).
   d) **Verschlüsselung-at-rest** der lokalen `site_connections.row`
      (Session-Key) — vor Produktivbetrieb.
   e) SITEPOD_PASSWORD_serverSideSessionKeyHashPepper in CI (tests.yml)
      ergänzen + Serverpod-CLI-Versionen in CI vereinheitlichen (siehe
      Punkt 2).
 9. **Site-Editor/Roadmap**: Site bearbeiten/löschen, Mitgliedschaften-
    Ansicht je Site; Hinweis Login gleiches Passwort global + lokal
    (gewünscht) — Umsetzung: lokale Kopie entsteht bei dem verifizierten
    Global-Login (Selbstheilung bei Passwort-Änderung = To-do).
10. **Ansatz/Entscheidungen (2026-09-25)**: keine lokale Selbst-
    Registrierung; Logins entstehen nur aus verifizierten Global-Logins
    (beim Setup des Admins / später bei Angestellten durch den lokalen
    Admin); Device-Credential = non-rotating SAS-Session-Key
    (`site-device`, Streuung über `serverSideSessionKeyHashPepper`),
    verbindungs-Status chips via `lastSeenAt`.

## Fortsetzung / nächste Schritte

Die Richtung ist: ERP-Ausbau der lokalen Instanz bei autarkem Betrieb,
Synchronisation mit der globalen Instanz so schlank wie möglich. Nächste
konkrete Schritte stehen unter „To-dos"; der wichtigste fehlende Block ist
der Membership-Sync über den Stream (Punkt 8a) plus der lokale Admin-Login
(Punkt 8c).
