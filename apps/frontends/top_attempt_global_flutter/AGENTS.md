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

**Rohes Serverpod-Scaffold** (2026-09-23 als Kopie des Scaffolds
entstanden, zusammen mit `top_attempt_local_flutter`):

- `lib/main.dart` — Serverpod-Client-Setup (globaler Client,
  `FlutterAuthSessionManager`, Connectivity-Monitor)
- `lib/screens/sign_in_screen.dart` / `greetings_screen.dart` —
  SignIn/Greeting-Beispiele
- Keine Admin-Domäne, kein eigenes Routing-Konzept

Serverpod-Flutter-Pakete auf 4.0.2. **Achtung:** Paket fehlt noch in der
Workspace-Liste (`apps/pubspec.yaml`) — To-do, siehe apps/AGENTS.md.

## Backend / Client

- Bindet (wie das Scaffold es mitbringt) den **globalen Client**
  (`top_attempt_global_client`) ein — korrekt für diese App.
- Server-URL: `--dart-define=SERVER_URL=…` oder `assets/config.json`
  (Default `http://localhost:8080/`); bei physischen Geräten LAN-IP des
  Dev-Rechners.

## Nächste Schritte (Vorschlag)

1. Ins Workspace aufnehmen (`apps/pubspec.yaml`).
2. Scaffold aufräumen (Beispiel-Screens entfernen), Login-Flow sichtbar
   machen (`SignInScreen`-Wrapper aktivieren).
3. Erste Admin-Features gegen das globale Backend: Usersuche,
   Profil-Einblick; Voraussetzung ist eine Admin-Rollen-/Berechtigungs-
   entscheidung im globalen Backend (noch offen).
