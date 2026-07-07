# top_attempt

Monorepo for the DoorInterface project — an ESP32-based door
controller, a Serverpod 3.3.1 backend, and Flutter clients.

## Layout

| Path | What | Docs |
|---|---|---|
| `apps/` | Serverpod 3.3.1 backends (`global` + `local`) and Flutter clients | [`apps/AGENTS.md`](apps/AGENTS.md) |
| `doorinterface/` | ESP32 firmware (Arduino / PlatformIO) | [`doorinterface/AGENTS.md`](doorinterface/AGENTS.md) |

## Build status

[![Analyze](https://github.com/itsfair/top_attempt/actions/workflows/analyze.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/analyze.yml)
[![Format](https://github.com/itsfair/top_attempt/actions/workflows/format.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/format.yml)
[![Tests](https://github.com/itsfair/top_attempt/actions/workflows/tests.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/tests.yml)
[![Build firmware](https://github.com/itsfair/top_attempt/actions/workflows/firmware.yml/badge.svg)](https://github.com/itsfair/top_attempt/actions/workflows/firmware.yml)