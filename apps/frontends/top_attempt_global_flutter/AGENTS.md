# AGENTS.md — top_attempt_global_flutter (Plattform-Admin-App)

Flutter-App zur **Verwaltung der globalen Instanz** (Plattform-Ebene des
Monorepos `top_attempt`): Nutzerkonten/Profile der Enduser einsehen und
verwalten, später weitere globale Verwaltung (z. B. Kurskatalog, sobald
die Frage global vs. lokal geklärt ist). Kontext: [`apps/AGENTS.md`](../../AGENTS.md),
Monorepo: [Root-AGENTS.md](../../../AGENTS.md).

## Zweck / Zielgruppe

- Zielgruppe: Plattform-Betreiber (Super-Admins der zentralen Instanz),
  **nicht** Enduser und **nicht** Site-Admins (dafür gibt es
  `top_attempt_local_flutter`).
- Künftige Inhalte: Benutzerverwaltung (Konten, Profile,
  Verifizierungsstatus), später Verwaltung globaler Entitäten und
  ggf. Einblick in die Instanzenlandschaft (offen).

## Aktueller Stand

2026-09-23 als Kopie des Serverpod-Scaffolds entstanden (zusammen mit
`top_attempt_local_flutter`); seither enorm ausgebaut (2026-09-24):

- GoRouter (`lib/main.dart`) mit Auth-Guard: nicht eingeloggt → `/sign-in`,
  eingeloggter Nicht-Admin (kein `global-admin`-Scope in
  `client.auth.authInfo.scopeNames`) → `/forbidden`.
- Drawer-Layout (`lib/layout.dart`) für Home, Members, Sites.
- **Members** (`screens/members.dart` + `screens/member_detail.dart`):
  Liste aller Nutzer (Backend-Paging, 50/Seite mit „Weitere laden“-Button,
  Suche nach E-Mail/Name), Detail-Route `/members/:authUserId` mit Toggles
  (Global Admin / Gesperrt; Selbstschutz-SnackBars wie im Backend).
- **Sites** (2026-09-25, `screens/sites.dart`,
  `screens/create_site_dialog.dart`, `screens/site_detail.dart`):
  Sites-Liste (Backend-Paging 50/Seite + Suche nach Name/E-Mail/Stadt,
  Status-Chip „Setup offen“/„Registriert“), FAB unten rechts öffnet den
  Create-Dialog (Adresse + Firmenmail + erster Site-Admin per
  Such-Dropdown über `usersAdmin.listUsers`). Nach dem Anlegen zeigt ein
  Onboarding-Modal **beide Geheimnisse je genau einmal** (Einmalpasswort
  der lokalen Instanz + initiales Site-Admin-Passwort; Copy-Buttons,
  Bestätigungs-Checkbox). Detail-Route `/sites/:id` zeigt Adresse, Status
  und den ersten Site-Admin — die Geheimnisse sind dort nie wieder
  sichtbar. Per-Site-WS-Verbindungsstatus (via `lastSeenAt`) folgt in
  Stufe 2.
- Registrierung im Admin-Frontend ist **bewusst sichtbar und nutzbar**
   (Stand: Versuch, sie zu unterdrücken, scheiterte an den
   Serverpod-Auth-Widget-Internals — To-do siehe unten). Kein
   Sicherheitsrisiko: jeder Nicht-Admin endet im `/forbidden`-Screen
   (Scope-Guard, serverseitig erzwungen).
- Serverpod-Flutter-Pakete auf 4.0.2. **Achtung:** Paket fehlt noch in der
  Workspace-Liste (`apps/pubspec.yaml`) — To-do, siehe apps/AGENTS.md.

## Backend / Client

- Bindet (wie das Scaffold es mitbringt) den **globalen Client**
  (`top_attempt_global_client`) ein — korrekt für diese App.
- Server-URL: `--dart-define=SERVER_URL=…` oder `assets/config.json`
  (Default `http://localhost:8080/`); bei physischen Geräten LAN-IP des
  Dev-Rechners.

## Nächste Schritte (Vorschlag)

1. Ins Workspace aufnehmen (`apps/pubspec.yaml`).
2. Scaffold-Reste aufräumen (Greeting-Beispiel ersetzen/entfernen).
3. Weitere Admin-Features gegen `usersAdmin`/`sitesAdmin`-Erweiterungen:
   Blockieren bestätigen (Bestätigungsdialog), Profil-Details im Editor,
   Memberships-Anzeige je Site im Detail (Stufe 2).
4. **Stufe 2 (Sites, Backend + Frontend)**: WS-Verbindungsstatus pro Site
   in dieser Liste (globale UI, via `lastSeenAt`-Heartbeats); Statusanzeige
   in der App-Bar der **lokalen** UI (anderes Frontend); Site edit/delete,
   OTP-/Setup-Regenerierung, E-Mail-Versand der Einrichtungsgeheimnisse.
5. **Registrierung im Admin-Frontend abschalten** (To-do, nicht dringend):
   Die Admin-App soll kein Self-Sign-up anbieten — die Registrierung muss
   für die Enduser-App aber am globalen Server bleiben (serverseitig
   deaktivieren wäre falsch; Admin-Zugriff ist ohnehin scope-codiert
   serverseitig erzwingbar). 2026-09-25 erfolglos versucht wurden:
   a) „Sign-up“-Texte über `SignInLocalizationProvider`/`EmailSignInTexts
       .copyWith(dontHaveAnAccount: '', signUp: '')` leeren — Button bleibt
       als unsichtbarer Hotspot klickbar; die Navigation zum
       Registration-Screen weiterhin möglich.
   b) Eigener `EmailAuthController`-Subclass mit geblocktem `navigateTo`
       auf die Registration-Screens (`startRegistration`,
       `verifyRegistration`, `completeRegistration`) — wirkte ebenfalls
       nicht (genaue Ursache ungeklärt; Stand: `screens/sign_in.dart`
       wurde auf den funktionierenden, Registrierung zeigenden Stand
       zurückgesetzt).
   Mögliche Ansätze für später: eigener Login-Screen (LoginForm ohne
   Sign-up-Zeile selbst bauen, Backend-Aufrufe direkt über
   `client.emailIdp`/Auth-Controller) oder Upstream-Feature der
   `serverpod_auth_idp_flutter`-Widgets anfragen.
