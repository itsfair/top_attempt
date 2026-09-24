# AGENTS.md — top_attempt_local_flutter (Site-Admin-App)

Flutter-App zur **Verwaltung einer lokalen Instanz** (eines
Betriebs/Standorts) im Monorepo `top_attempt`: Geräte (ESP32/NUKI),
Nutzer vor Ort, Zugangsrechte — und langfristig der ERP-Ausbau
(Kursverwaltung, Angestelltenverwaltung, Schichtplan). Kontext:
[`apps/AGENTS.md`](../../AGENTS.md), Monorepo:
[Root-AGENTS.md](../../../AGENTS.md).

## Zweck / Zielgruppe

- Zielgruppe: **Site-Admins** — Betreiber eines Standorts, die Mitglieder
  ihrer Instanz verwalten (Einschreiben, Zugangsrechte, Entfernen) und
  später das ERP des Betriebs bedienen.
- Ziel-Ablauf, zu dem diese App gehört: Enduser registriert sich global →
  schreibt sich bei der lokalen Instanz als Mitglied ein → **Site-Admin
  verwaltet die Mitglieder seiner Instanz** (Zugangsrechte etc.) →
  Enduser öffnet per QR/OTP/BLE die Tür (lokale Instanz prüft).
- ERP-Roadmap (Stück für Stück): Kursverwaltung → Angestelltenverwaltung
  → Schichtplan.

## Aktueller Stand

**Rohes Serverpod-Scaffold** (2026-09-23 als Kopie des Scaffolds
entstanden, zusammen mit `top_attempt_global_flutter`):

- `lib/main.dart` — Serverpod-Client-Setup (Beispiel-SignIn/Greetings)
- `lib/screens/sign_in_screen.dart` / `greetings_screen.dart` —
  SignIn/Greeting-Beispiele
- Keine Site-Admin-Domäne, kein eigenes Routing-Konzept

Serverpod-Flutter-Pakete auf 4.0.2. **Achtung:** Paket fehlt noch in der
Workspace-Liste (`apps/pubspec.yaml`) — To-do, siehe apps/AGENTS.md.

## Backend / Client

- Bindet **bewusst beide Clients** ein: `top_attempt_global_client` und
  `top_attempt_local_client`. Hintergrund: die App wird auch globale
  Eigenschaften manipulieren (z. B. Kursverwaltung — aktuell offen, ob
  Kurse global angelegt oder lokal angelegt und synchronisiert werden,
  siehe apps/AGENTS.md → „Offene Architekturfragen“).
- Aktuell wird im Scaffold-Code nur der **globale** Client tatsächlich
  benutzt (`lib/main.dart` importiert `top_attempt_global_client`); der
  lokale Client ist als Dependency hinterlegt, aber noch nicht benutzt.
- Server-URL: `--dart-define=SERVER_URL=…` oder `assets/config.json`;
  bei physischen Geräten LAN-IP des Dev-Rechners. Lokales Backend: API
  auf Port 8180.

## Abhängigkeiten (fachlich)

- Lokales Backend muss erst Geräte-/Mitglieder-/Berechtigungsmodell
  bekommen (siehe `apps/backends/local/AGENTS.md` → offene Fragen) —
  größter Blocker für echte Admin-Features.
- Login-Modell lokal (`staff`-Attribut vs. `members`-Tabelle) entscheidet,
  wie sich Site-Admins hier anmelden und welche Rechte sie sehen.

## Nächste Schritte (Vorschlag)

1. Ins Workspace aufnehmen (`apps/pubspec.yaml`).
2. Scaffold aufräumen, Login gegen die **lokale** Instanz etablieren.
3. Sobald das lokale Backend-Modell steht: UI für Geräte-Übersicht und
   Mitgliederverwaltung (Zugangsrechte) aufbauen.
