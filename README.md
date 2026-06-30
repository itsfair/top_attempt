# top_attempt

Monorepo for the DoorInterface project — an ESP32-based door
controller, a Serverpod 3.3.1 backend, Flutter clients, and
GitHub-hosted OTA firmware updates.

## Layout

| Path | What | Docs |
|---|---|---|
| `apps/` | Serverpod 3.3.1 backends (`global` + `local`) and Flutter clients | [`apps/AGENTS.md`](apps/AGENTS.md) |
| `doorinterface/` | ESP32 firmware (Arduino / PlatformIO) with OTA | [`doorinterface/AGENTS.md`](doorinterface/AGENTS.md) |
| `doorinterface/docs/interfaces.md` | HTTP API, BLE GATT, NVS, OTA spec | — |

## Build status

[![Analyze](https://github.com/itsfair/top_attempt/actions/workflows/analyze.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/analyze.yml)
[![Format](https://github.com/itsfair/top_attempt/actions/workflows/format.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/format.yml)
[![Tests](https://github.com/itsfair/top_attempt/actions/workflows/tests.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/tests.yml)
[![Build firmware](https://github.com/itsfair/top_attempt/actions/workflows/firmware.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/firmware.yml)

## OTA firmware updates

The ESP32 fetches a JSON manifest (default: dev channel, latest
`main`), streams the referenced `firmware.bin` over HTTPS, verifies
the SHA-256 in app code, flashes the other OTA slot, and waits 60 s
for an explicit `POST /update/confirm`. Without confirm, the device
rolls back to the previous image. See
[`doorinterface/docs/interfaces.md`](doorinterface/docs/interfaces.md)
→ "OTA / Firmware-Update" for the full spec.

- **Stable releases:** `v*` tag push → `release.yml` builds, hashes,
  and creates a GitHub release with `firmware.bin` + `manifest-stable.json`.
- **Dev builds:** every push to `main` touching `doorinterface/` →
  `dev-manifest.yml` builds, creates/updates a `dev` pre-release
  (assets replaced in place), and commits `manifest-dev.json` back to
  the repo.
