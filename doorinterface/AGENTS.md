# AGENTS.md — DoorInterface Firmware

ESP32 firmware (Arduino framework, PlatformIO) for a door controller. Single
environment `esp32dev` (see `platformio.ini`).

## Build & flash

- Build:  `pio run`
- Upload: `pio run -t upload` (specify `-t upload --upload-port <COM?>` if
  autodetect fails on Windows)
- Monitor: `pio device monitor` (115200 baud, ESP32 exception decoder is
  enabled in `platformio.ini` so crash backtraces decode automatically)
- Clean:  `pio run -t clean`

There is no CI, no linter/formatter config, and no unit tests — the `test/`,
`include/`, and `lib/` directories are PlatformIO defaults that are otherwise
empty. Do not invent tests; verify behavior on real hardware or in the serial
console.

## Code layout

- `src/main.cpp` — entry point and the device state machine
  (`BOOTING → SETUP_MODE | CONNECTING → OPERATIONAL | AP_FALLBACK`).
- `src/config_manager.*` — NVS-backed `Config()` singleton
  (namespace `doorconfig`).
- `src/wifi_manager.*` — STA / AP / mDNS, `Wifi()` singleton.
- `src/captive_portal.*` — first-time WiFi-setup wizard, `Portal()` singleton.
- `src/http_api.*` — operational HTTP server, `Api()` singleton.
- `src/ble_service.*` — NimBLE GATT server (WiFi provision + status),
  `BleService::instance()`.
- `src/serial_console.*` — USB-serial CLI, `Console()` singleton.
- `src/hardware/door_hardware.h` — abstract base; `RelayDriver` and
  `NukiDriver` are the two concrete drivers.

Headers live next to their `.cpp` in `src/` (not in `include/`).

## Conventions

- All subsystems are singletons accessed through inline global shims defined
  in each header (`Config()`, `Wifi()`, `Portal()`, `Api()`, `Console()`).
  New managers should follow the same pattern.
- New hardware types subclass `DoorHardware` and update
  `enum class HardwareType` in `config_manager.h` plus NVS key handling in
  `config_manager.cpp`.
- NVS schema additions go in `ConfigManager::begin` (load) /
  `setHardware*` (save); keys are listed in `docs/interfaces.md`.
- Do not call `NimBLEDevice::init` from anywhere except `BleService::begin`,
  which must run before any driver that uses NimBLE (NUKI).

## Boot flow & gotchas

- First boot with no `wifi_ssid` (or `isConfigured == false`) → AP mode,
  SSID `DoorInterface-XXXX` (last 4 MAC hex), IP `192.168.4.1`. Captive
  portal at `http://192.168.4.1`. After successful `/connect`, device
  schedules a reboot into operational mode.
- Operational mode reachable at `http://<device_name>.local` (mDNS) or the
  assigned IP. Default hostname is `doorinterface`.
- WiFi watchdog (`wifiReconnectTask` in `main.cpp`): 3 failed reconnect
  attempts within ~30 s set `isConfigured = false` and restart into
  `AP_FALLBACK`.
- NimBLE scan logs are suppressed via `esp_log_level_set("NimBLEScan",
  ESP_LOG_WARN)` in `setup()` — leave this or serial becomes unreadable.
- Partition table is `huge_app.csv` (set in `platformio.ini`); the default
  table does not fit AsyncWebServer + NimBLE + ArduinoJson + Nuki lib.
- NUKI pairing: user must press the button on the lock within 30 s of
  triggering it from the web UI. Credentials are stored by the
  `NukiBleEsp` library in the NVS namespace `nuki_lock` (not
  `doorconfig`).
- BLE status notifications are pushed every 5 s from `loop()`.

## Docs vs code

`docs/interfaces.md` is the canonical interface spec but is **ahead of the
code** in places. In particular, the `/config/*` HTTP endpoints, the
`/open` token field, the Phase-2 BLE characteristics, and the local/global
server (Serverpod) sections are documented but not yet implemented. Do not
"fix" code to match docs without checking with the user; trust the code and
the headers.

## Things to avoid

- Adding dependencies to `lib_deps` without checking they work with
  `NimBLE-Arduino` (NukiBleEsp is BLE-Central; mixing with other BLE stacks
  will break it).
- Calling `NimBLEDevice::deinit` or re-initializing NimBLE — NukiBleEsp
  assumes a single init for the device lifetime.
- Writing to the `nuki_lock` NVS namespace by hand; that namespace is owned
  by the Nuki library.
- Editing `.pio/` — it's the PlatformIO build/cache directory and is
  gitignored.
