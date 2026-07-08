# AGENTS.md — top_attempt (Monorepo-Root)

Dieses Repo ist ein Monorepo: ESP32-Firmware + Serverpod-Backends +
Flutter-Clients. Pro Sub-Paket gibt es eine eigene AGENTS.md mit den
Details — diese Root-Datei gibt nur den Überblick und die Verweise.

## Layout

| Pfad | Was | Eigenes AGENTS.md |
|---|---|---|
| `doorinterface/` | ESP32-Firmware (PlatformIO/Arduino) | [`doorinterface/AGENTS.md`](doorinterface/AGENTS.md) |
| `apps/backends/global/top_attempt_global_server` | Serverpod-Backend „global“ | (noch keins) |
| `apps/backends/local/top_attempt_local_server` | Serverpod-Backend „local“ | (noch keins) |
| `apps/frontends/top_attempt_flutter` | Flutter-Client (Admin?) | (noch keins) |
| `apps/frontends/top_attempt_enduser_flutter` | Flutter-Client (Enduser) | (noch keins) |

## Workflows (`.github/workflows/`)

| Datei | Zweck | Trigger |
|---|---|---|
| `firmware.yml` | Baut `pio run` im `doorinterface/` als CI-Check; lädt Binary als Artifact hoch | Push/PR auf `main`, das `doorinterface/**` toucht |
| `analyze.yml` | `dart analyze --fatal-infos` für beide Serverpod-Backends | Push/PR auf `main`, das `apps/**` toucht |
| `format.yml` | `dart format --set-exit-if-changed .` für beide Backends | Push/PR auf `main`, das `apps/**` toucht |
| `tests.yml` | `dart test` gegen beide Backends (mit Docker-Compose für Postgres/Redis) | Push/PR auf `main`, das `apps/**` toucht |

**Keine OTA-Workflows mehr.** Die vormaligen `dev-manifest.yml` und
`release.yml` wurden beim Neustart der DoorInterface-Firmware gelöscht;
siehe `doorinterface/AGENTS.md` → „Monorepo-Kontext".

## Toolchain-Voraussetzungen

- **Firmware**: PlatformIO (`pio` CLI) — siehe `doorinterface/AGENTS.md`.
- **Apps**: Dart 3.8.0, Flutter 3.32.8 (laut `tests.yml`), Serverpod 3.3.1.
- **Für Backend-Tests lokal**: Docker (für Postgres + Redis-Container).

## Schnittstellen-Specs

| Pfad | Was | Status |
|---|---|---|
| [`doorinterface/docs/ble_interface.md`](doorinterface/docs/ble_interface.md) | BLE-GATT-Schnittstelle ESP ↔ Enduser-Smartphone-App (Prototyp, gemockte Backend-Antwort) | in Arbeit |
| `doorinterface/docs/interfaces.md` | HTTP-API / NVS / BLE-GATT-Komplett-Spec (alt, veraltet) | TODO |

Wer eine App gegen das Doorinterface baut, startet beim Lesen dieser Specs
und der `doorinterface/AGENTS.md` (speziell „Architektur-Entscheidungen"
und „BleServer").

## Konventionen / Notizen

- Commits pro Sub-Paket sind fine; keine Cross-Paket-Commits erzwingen.
- Keine Auto-Commits ohne ausdrückliches OK des Nutzers (siehe
  `doorinterface/AGENTS.md` → „Arbeitsweise").
- `apps/AGENTS.md` existiert nicht; bei Bedarf anlegen, wenn die
  Backend-/Frontend-Arbeit mehr wird.

## Forsetzung

- Firmware-Seite: siehe `doorinterface/AGENTS.md` → „Forsetzung".
- Apps-Seite: aktuell ungedockt; bei Wiederaufnahme ggf. eigene
  `apps/AGENTS.md` anlegen.