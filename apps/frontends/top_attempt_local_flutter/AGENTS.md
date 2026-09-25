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

2026-09-25 sehr erweitert (zuerst Scaffold am 2026-09-23 als Kopie):

- GoRouter (`lib/main.dart`): `/` Home + `/setup` Site-Einrichtungs-Maske;
  Layout-Shell mit Drawer und **App-Bar-Verbindungs-Chip**, der auf den
  lokalen Backend-Status pollt (`siteSetup.connectionStatus`, alle 10 s):
  `noneSetup|connecting|reconnecting|connected|needsReSetup|failure`.
- Die Client-Domäne ist der **lokale Client**
  (`top_attempt_local_client`, API `localhost:8180`); der **globale**
  Client ist als Dependency hinterlegt (für zukünftige globale
  Eigenschaften wie Kursverwaltung — noch nicht benutzt).
- **Setup-Maske** (`lib/screens/site_setup.dart`): Global-E-Mail/-Passwort
  des Site-Admins (der bei der Site-Erstellung choses wurde) →
  `siteSetup.enterSetup` → bei mehreren Sites ein Site-Picker; Erfolg →
  SnackBar (lokal gespeicherte Verbindung + lokale Admin-Login-Zeile).
- Die alte scaffold sign-in/greeting UI wurde entfernt — der echte lokale
  Login (mit `local-admin`-Account) ist ausstehend (s. Nachstehendes).

## Backend / Client

- Nutzt aktuell **nur den lokalen Client** (`top_attempt_local_client`,
  API `localhost:8180`): Setup-Maske + Verbindungs-Chip laufen gegen die
  lokale Instanz. Das Enrollment selbst passiert serverseitig im lokalen
  Backend (dort lebt der globale Client).
- `top_attempt_global_client` ist **aktuell auskommentiert** (pubspec,
  2026-09-25): zu entfernt, da ungenutzt — bewusst wieder eintragen, wenn
  die App globale Eigenschaften manipulieren wird (z. B. Kursverwaltung,
  siehe apps/AGENTS.md → „Offene Architekturfragen“).
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
2. Lokalen Login (`local-admin`-Account) etablieren → Schutz für Setup-
   und Admin-Bereichte (derzeit offen für alle im LAN).
3. Sobald das lokale Backend-Datenmodell + Membership-Sync steht: UI für
   Geräte-Übersicht und Mitgliederverwaltung (Zugangsrechte).
