# top_attempt

Monorepo for the DoorInterface project — an ESP32-based door
controller, Serverpod backends, and Flutter clients.

## Documentation

The project overview, architecture, scenarios, current status, interfaces,
security notes and prioritized roadmap are documented in
[`docs/project.md`](docs/project.md).

## Layout

| Path | What | Docs |
|---|---|---|
| `apps/` | Serverpod backends (`global` + `local`) and Flutter clients | [`docs/project.md`](docs/project.md) |
| `doorinterface/` | ESP32 firmware (Arduino / PlatformIO) | [`doorinterface/AGENTS.md`](doorinterface/AGENTS.md) |

## Build status

[![Analyze](https://github.com/itsfair/top_attempt/actions/workflows/analyze.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/analyze.yml)
[![Format](https://github.com/itsfair/top_attempt/actions/workflows/format.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/format.yml)
[![Tests](https://github.com/itsfair/top_attempt/actions/workflows/tests.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/tests.yml)
[![Build firmware](https://github.com/itsfair/top_attempt/actions/workflows/firmware.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/firmware.yml)
