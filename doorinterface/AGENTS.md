# DoorInterface — project handoff

ESP32 firmware (PlatformIO + Arduino framework) for controlling door
openers (relay + NUKI smart locks via BLE), with Wi-Fi setup via captive
portal, web interface and API/WebSocket for the local backend.

## Build & flash — IMPORTANT FOR ALL AGENTS

```bash
pio run                 # build
pio run -t upload       # flash
pio device monitor      # serial @ 115200
```

> **DRAKONIAN RULE FOR ALL AGENTS (also applies to sub-agents):**
>
> 1. **No build after every small code change.** A `pio run` takes
>    20–60 s and massively consumes context time. Build only on explicit
>    request of the user **or** for deeper refactorings where syntax
>    errors are not obvious. If the change is trivial (e.g. a string
>    constant, a log line, a JS/HTML snippet adjustment), trust a careful
>    reading of the diff — the user compiles and flashes anyway.
> 2. **Explain changes BEFORE writing files.** The agent proposes every
>    bite-size step as code snippet + short explanation and waits for the
>    user's "okay" before actually touching files. Exception: pure
>    documentation updates (AGENTS.md, docs/*.md) that do not change code
>    semantics.
>
> Agents ignoring these rules impair working speed considerably — the
> rules are not optional.

PlatformIO configuration: `platformio.ini`, env `esp32dev`,
`monitor_speed = 115200`.

> Note: `pio` is not in the PATH. PlatformIO lives at
> `C:\Users\Simon\.platformio\penv\Scripts\platformio.exe`.

> Note on the local installation (happened before): the ESP32 framework
> package `framework-arduinoespressif32` was incompletely installed
> (missing `variants/` folder) and the Python module `intelhex` was
> missing for `esptool`. Both were fixed manually (`intelhex` installed
> via `pip install` into the PIO Python environment). If the build fails
> on another machine, first check:
> `Test-Path "$env:USERPROFILE\.platformio\packages\framework-arduinoespressif32\variants"`

## Monorepo context

This firmware directory is part of the `top_attempt` monorepo:

```
top_attempt/
├── apps/             → Serverpod backends + Flutter clients (own AGENTS.md)
├── doorinterface/    → this project
├── .github/workflows/
│   ├── firmware.yml  → build + GitHub release on tag push `fw-v*`
│   ├── analyze.yml   → Dart analyze for apps/
│   ├── format.yml    → dart format check for apps/
│   └── tests.yml     → dart test for apps/
└── README.md
```

- The original OTA workflows (`dev-manifest.yml`, `release.yml`) were
  removed; instead `firmware.yml` builds on tag push `fw-v*` and creates
  a GitHub release with `firmware.bin` — the firmware (`src/Updater.cpp`)
  pulls this release via OTA.
- The old firmware code with `Update()` / `update_manager.*` /
  `partitions/ota.csv` / `firmware/manifest-*.json` was fully discarded.
  The current firmware uses a custom partition table (`partitions.csv`,
  2 OTA slots, flash usage ~72 %).

## Code structure (current)

```
platformio.ini
src/
  config.h              -> FW_VERSION "0.1.0"
  main.cpp              -> instantiates WifiManager, NukiManager, WebInterface
  WifiManager.h/.cpp    -> WLAN STA attempt + AP fallback + captive portal + hostname
  WebInterface.h/.cpp   -> main webserver (STA mode): dashboard, setup, API
  NukiManager.h/.cpp    -> NUKI BLE: pairing, lock/unlock, status querying
  BleServer.h/.cpp      -> BLE peripheral (GATT server) for smartphone app, see docs/ble_interface.md
  Updater.h/.cpp        -> OTA update via GitHub release pull (WiFiClientSecure + Update lib)
  web/
    portal_html.h       -> captive portal HTML (PROGMEM)
    portal_css.h        -> captive portal CSS (PROGMEM)
    portal_js.h         -> captive portal JS  (PROGMEM)
    main_html.h         -> dashboard HTML (PROGMEM)
    main_css.h          -> dashboard + setup CSS (PROGMEM)
    main_js.h           -> dashboard JS: status poll, lock/unlock buttons
    setup_html.h        -> setup page HTML (PROGMEM)
    setup_js.h          -> setup JS: hostname, NUKI pairing, test buttons
lib/
  nuki_ble/             -> patched fork of AzonInc/NukiBleEsp32 (idf branch)
                           7 NimBLE API patches for NimBLE-Arduino 1.4.x
                           Own Preferences.h/.cpp removed (Arduino framework used)
docs/
  ble_interface.md      -> spec of the BLE interface ESP↔smartphone app (prototype)
```

## Architecture decisions

- **Web content as PROGMEM strings**, not on a filesystem (LittleFS).
  Reason: later OTA updates (generated binary via GitHub push) should
  deliver web content automatically — updating a data partition
  separately via OTA would be more error-prone. Files under `src/web/`,
  header-only, one PROGMEM string per file.
- **Separation by area and type**: `portal_*.h` for the captive portal,
  `main_*.h`/`setup_*.h` for the main web interface. One file per area
  for html/css/js.
- **WifiManager as own module** (`src/WifiManager.cpp`), `main.cpp`
  stays lean.
- **WebInterface as own module** (`src/WebInterface.cpp`), starts when
  STA connected + AP off. Takes `WifiManager&` and `NukiManager&` by
  reference.
- **NukiManager as own module** (`src/NukiManager.cpp`), encapsulates
  BLE scanner + NukiLock. Event handler for status updates. Credentials
  in NVS (namespace = device name, managed by the NukiBleEsp32 lib).
- **Debug logging** via `Serial.print*` with prefixes: `[WifiManager]`,
  `[HTTP]`, `[NUKI]`, `[BLE]`.
- **BLE start deferred**: `nuki.begin()` is **not** called in `setup()`
  but in `loop()` only when `wifi.isConnected() && !wifi.isApActive()`.
  Reason: the ESP32 shares one 2.4 GHz radio for Wi-Fi and Bluetooth —
  initializing BLE parallel to an active setup AP **blocks the AP**. In
  STA mode Wi-Fi/BT coexistence works (time slicing). Accordingly,
  `WebInterface` also starts only after a successful STA connection;
  `main.cpp` keeps the `_started` flags for this.
- **BleServer starts before NukiManager**: `BleServer.begin()` calls
  `NimBLEDevice::init(name)` first — this call only takes effect the
  first time, afterwards it is a no-op. NimBLE is thus named = ESP
  hostname. `NukiManager.begin()` (which calls `init()` internally
  again) runs after that. BleServer deliberately uses **no own member
  pointers** to service/characteristics but fetches them via
  `NimBLEDevice::getServer()` / `getServiceByUUID()` — that prevents
  stale pointer issues if NimBLE reorganizes internally and is fast
  enough with only one service.
- **BleServer = peripheral, NukiManager = central** on the same NimBLE
  stack. NimBLE allows max. 3 connections and all roles by default.
  BleServer holds exactly one smartphone connection, NukiManager one
  central connection to the lock — both work simultaneously (time
  slicing in the controller). Stability under parallel connects must be
  observed; if needed adjust connection params of the client later.
- **Protocol**: JSON over GATT (write on request characteristic, notify
  on response characteristic), no encryption in the prototype. Spec in
  `docs/ble_interface.md`.

## NUKI BLE integration — important details

- **Library**: `lib/nuki_ble/` = patched fork of
  `https://github.com/AzonInc/NukiBleEsp32.git` (idf branch).
  Supports **all NUKI models**: Smart Lock 1.0–4.0, 5.0 Pro, Ultra, Go,
  Opener, Keypad.
- **7 NimBLE API patches** for compatibility with `NimBLE-Arduino @ ^1.4.1`:
  1. `onDisconnect(BLEClient*, int reason)` → `onDisconnect(BLEClient*)`
  2. `onResult(const BLEAdvertisedDevice*)` → `onResult(BLEAdvertisedDevice*)`
  3. `NimBLERemoteCharacteristic::notify_callback` → `notify_callback`
  4. `NimBLEDevice::isInitialized()` calls removed (not in 1.4.x)
  5. `NimBLEDevice::setPower(int)` → `setPower(esp_power_level_t)`
  6. `NimBLEBeacon::setData(uint8_t*, uint8_t)` → `setData(std::string)`
  7. `BLEAddress::getVal()` → `BLEAddress::getNative()`
- **`NukiBle.cpp onResult` — edge detection for the status-updated flag.**
  The original fires `eventHandler->notify(KeyTurnerStatusUpdated)` on
  every advertising packet with the status bit set — i.e. continuously
  every few hundred milliseconds. Patch: `if (!statusUpdated && eventHandler)`
  as gate so the event only fires once on a real edge (false→true).
  `statusUpdated=true` is still set internally; the reset branch (flag
  cleared) sets `statusUpdated=false` back and fires
  `KeyTurnerStatusReset`. Fixes a permanent state-request loop in
  NukiManager that connected to NUKI actively every 30 s and drained the
  battery.
- **Preferences conflict solved**: the idf branch ships its own
  `Preferences.h/.cpp` with a `std::string` API that collides with the
  Arduino-framework `Preferences` (with `String` API). Solution: own
  files **deleted**; the Arduino framework version is a drop-in
  replacement.
- **No framework switch**: `framework = arduino` (no espidf), no
  sdkconfig.defaults, no partitions.csv needed.
- **Dependencies**: `NimBLE-Arduino @ ^1.4.1`, `BleScanner` (I-Connect),
  `Crc16` (vinmenn).
- **Ultra/5th-gen PIN**: for Smart Lock Ultra/5th Gen/Go/Pro the 6-digit
  PIN must be set before pairing (`saveUltraPincode()`). Standard locks
  (1.0–4.0) need no PIN. TODO: PIN input in the setup page.
- **Ultra support research**: platform upgrade to Arduino Core 3.x
  (ESP-IDF 5.x) with `framework = arduino, espidf` was tested but failed
  on Python dependency problems in PlatformIO. The patched-fork solution
  bypasses that completely.

## Captive portal — implemented flow

1. `begin()`: load NVS hostname (namespace `"system"`) + credentials
   (namespace `"wifi"`). Default hostname: `doorinterface-XXXX` (last 2
   MAC bytes).
2. If SSID present: STA attempt (`tryConnect`), 15 s timeout.
   `WiFi.setHostname()` is called before every `WiFi.begin()`.
3. `startFallbackAp()`: `setAutoReconnect(false)` + `disconnect(false)`
   → free the STA radio for scanning. Mode `WIFI_AP_STA`, AP name
   `DoorSetup-AP`.
4. `startPortal()`:
   - `DNSServer` catch-all (`*` → AP IP).
   - Routes: `/`, `/portal.css`, `/portal.js`, `/scan`, `/save`,
     `/status`, `/config`, `/close`.
   - `UriGlob("*")` + `HTTP_ANY` as catch-all → no more `log_e` spam.
   - `onNotFound` as defensive fallback.
5. `/scan` (GET): `WiFi.scanNetworks()` blocking, JSON array.
6. `/save` (POST): SSID/password + optional hostname to NVS,
   `WiFi.begin()`, responds immediately `{"status":"connecting"}`.
   **Validation**: if a hostname is provided, `setHostname()` is checked
   (only `a-z`, `0-9`, `-`; 1–63 chars; must not start/end with `-`).
   On an invalid name `/save` returns HTTP 400 +
   `{"error":"Hostname invalid (only a-z, 0-9, -; must not start/end with -)"}`
   and aborts the save flow — Wi-Fi data is not stored. The frontend
   shows the error in the status area.
7. `/config` (GET): JSON `{hostname}` for the portal frontend.
8. `/close` (POST): close the AP immediately (button in the overlay
   after a successful connect). Frontend copies the STA IP to the
   clipboard + closes the AP.
9. Portal state machine in `loop()`:
   - `_shutdownRequested` flag → `shutdownAp()` (button and 30 s timer).
   - `PORTAL_CONNECTING` → `PORTAL_CONNECTED` → 30 s timer →
     `shutdownAp()`.
   - `shutdownAp()`: `setAutoReconnect(true)` for pure STA operation.

## Frontend (captive portal)

- HTML/CSS/JS inline as PROGMEM in `src/web/portal_*.h`.
- Select for scanned networks + manual SSID field.
- Device name field (loaded via `/config`).
- Overlay with spinner + status polling.
- On `connected`: address + "copy address & finish setup" button.

## Main web interface (STA mode)

- **WebInterface** starts when `wifi.isConnected() && !wifi.isApActive()`.
- mDNS with dynamic hostname (`MDNS.begin(hostname)`).
- Routes: `/`, `/main.css`, `/main.js`, `/setup`, `/setup.js`,
  `/api/status`, `/api/hostname` (GET+POST), `/api/nuki/pair`,
  `/api/nuki/cancel`, `/api/nuki/unlock`, `/api/nuki/lock`.
- `/api/status` JSON: `{wifi, relay, locks, firmware}`.
  `locks`: `{available, count, paired, pairing, lockState, batteryPct,
  batteryCritical, rssi}`.
- Dashboard (`main_js.h`): 3 cards (Wi-Fi, door opener, firmware).
  - Wi-Fi: badge + SSID/RSSI/IP, poll every 3 s.
  - Door opener: "not set up" + setup link, or lock-state badge +
    battery/RSSI + "open"/"lock" buttons.
  - ⚙ dropdown top right → `/setup`.
- Setup page (`setup_js.h`):
  - Change device name (→ reboot).
  - NUKI pairing: instructions + "start pairing"/"cancel pairing".
  - Test buttons (open/lock) with a paired lock.
  - Poll every 2 s.

## NUKI pairing flow

1. Nuki app: enable Bluetooth pairing (Settings → Features &
   Configuration → Button and LED).
2. Press the NUKI button 10 s (LED ring lights up).
3. Setup page → "start pairing" → `POST /api/nuki/pair`.
4. `NukiManager::startPairing()` → `_pairingRequested = true`.
5. `loop()` calls `pairNuki()` until success or 10 min timeout.
6. On success: `requestKeyTurnerState()` → status in the dashboard.
7. "cancel pairing" → `POST /api/nuki/cancel` → `_pairingRequested = false`.
8. Credentials (ECDH key, auth ID) stored in NVS (managed by the lib).
   After restart: no re-pairing needed.

## Completed bite-size steps

1. Basic `WifiManager` scaffold (STA + AP fallback).
2. Captive portal (HTML/CSS/JS, DNS, routes, scan, save, status, state
   machine).
3. NVS fix + captive detection paths.
4. Scan fix (`setAutoReconnect(false)` + `disconnect`).
5. `UriGlob("*")` catch-all against log spam.
6. Portal finish button (copy address + close AP).
7. `config.h` with `FW_VERSION`.
8. `WebInterface` module (dashboard + mDNS).
9. Hostname feature: NVS `"system"`, unique default, editable in portal
   + setup page, `WiFi.setHostname()` before `WiFi.begin()`.
10. NUKI BLE integration: patched fork (idf branch), `NukiManager`,
    pairing, lock/unlock, status, dashboard buttons, setup page.
11. Pairing cancellation (`/api/nuki/cancel`).
12. Hostname validation in the portal: `setHostname()` return value is
    checked in `handleSave()`; on invalid name → HTTP 400 + JSON error,
    frontend shows the message in the status area.
13. BLE start **deferred**: `nuki.begin()` moved out of `setup()` into
    `loop()`, only when `wifi.isConnected() && !wifi.isApActive()`.
    Fixes "AP unreachable after BLE init" (radio conflict on ESP32).
    `WebInterface` also starts only after that.
14. **BleServer prototype**: new module `src/BleServer.cpp` (NimBLE
    peripheral). GATT service with request char (write) + response char
    (notify). Smartphone sends JSON, ESP logs and answers mocked.
    BleServer starts before `NukiManager` (does `NimBLEDevice::init`
    first → advertising name = hostname). Deferred in `loop()` like
    NUKI. Spec: `docs/ble_interface.md`. Still without backend /
    without encryption.
15. **NUKI Ultra/Go PIN input**: setup page extended with a PIN field
    (`/api/nuki/pin` GET/POST), `NukiManager::setUltraPin()` calls
    `saveUltraPincode()` (lib stores itself in NVS). Status endpoint
    provides `locks.hasUltraPin`. Required for Smart Lock Go (2025) /
    Ultra / 5.0 / Pro — without a PIN `NukiBle` refuses pairing
    (`No pairing PIN code set`). Standard locks (1.0–4.0) need no PIN.
16. **OTA update** via GitHub releases: new module `src/Updater.cpp`
    polls `api.github.com/repos/itsfair/top_attempt/releases/latest`,
    compares `tag_name` (without `fw-v` prefix) with `FW_VERSION`,
    downloads `firmware.bin` and flashes into the inactive OTA slot via
    the `Update` lib. Setup page: "firmware update" section with button
    + progress display. Dashboard menu: "reboot" button via
    `/api/reboot`. New `partitions.csv` with 2 OTA slots of 1.875 MB
    each. GitHub action `firmware.yml` only triggers on tag push
    `fw-v*`, creates a GitHub release. Version is injected into the
    build via `${sysenv.FW_VERSION_FLAGS}` (local: `0.0.0-dev`
    fallback). Flash usage after OTA integration: 72.1 %.
17. **NUKI pairing name = hostname**: `NukiLock` is only created in
    `NukiManager::begin(deviceName)` (heap pointer instead of member;
    `main.cpp` passes `wifi.getHostname()`); name = configured hostname
    instead of fixed "DoorInterface". Name is truncated to 32 chars
    (the lib memcpys the name into a fixed 32-byte buffer during
    pairing without clamping). **Attention**: the name is also the NVS
    namespace of the NUKI credentials (lib-internal `preferencesId`) —
    after a hostname change re-pairing is required, the old namespace
    stays orphaned in NVS and the lock keeps the old authorization
    entry. Two ESPs with the same name: technically uncritical (the
    lock distinguishes pairings internally via authorization id), but
    two identical entries in the NUKI app.

## Working rules

- Small bites, each step proposed as code snippet + explained, only
  written to files after "okay". **No exceptions** — not even for "just
  one tiny thing".
- Steps are explained before being created, not auto-committed.
- `git commit` only on explicit request.
- **No build test after every small change.** The user compiles/flashes
  themselves and reports problems. Builds only on explicit request or
  for deeper refactorings. **Applies even when the agent "really thinks
  it should be safe"** — the build costs 20–60 s of context time and is
  forbidden anyway as a hard rule from the "Build & Flash" section.

## Open TODOs (roughly ordered by priority)

### NUKI
- [ ] PIN input for Ultra/5th Gen/Go/Pro in the setup page
        (`saveUltraPincode()` before pairing).
- [ ] Unpair function (`unPairNuki()` + setup button).
- [ ] Several locks in parallel (list of NukiLock instances on the same
        scanner).
- [ ] Keypad management, auth entries, time control.
- [ ] Event log (requires PIN).

### Wi-Fi / setup
- [ ] Configurable AP password for the setup AP (currently open).
- [ ] Reset option for stored Wi-Fi credentials (button/erase flag).
- [ ] Reconnect logic on STA connection loss.

### Web interface
- [ ] Login / session auth (e.g. basic auth, token, session cookie).
- [ ] Relay configuration (pin, level) in the setup page.
- [ ] SSID escaping in the status JSON.

### Backend connection
- [ ] Decision: ESP as WS client (recommendation for multiple ESPs) or
        WS server on ESP. Serverpod backend not started yet.
- [ ] Secure connection ESP↔backend (TLS? mutual auth?).
- [ ] Authentication of the backend against the ESP (API token).

### Relay
- [ ] GPIO control (pin, timing, interference suppression). Needs
        hardware info.

### Door sensor
- [ ] **Option A — NUKI's own door sensor:** evaluate the field
        `Door sensor state` (uint8: 0x00 unavailable, 0x02 closed,
        0x03 opened, 0x10 uncalibrated, 0xF0 tampered, 0xFF unknown)
        contained in the NUKI API's `Keyturner States (0x000C)` frame
        and display it in the dashboard. Requires a paired NUKI door
        sensor. Updates only in the poll interval (`locks.pollInterval`).
- [ ] **Option B — own reed/magnetic sensor on the ESP GPIO:** reed
        switch on the door leaf (magnet on the frame) on a GPIO pin
        with internal pull-up, firmware polls the pin and fires an
        event on edge. Real-time (independent of the NUKI poll
        interval), new class e.g. `DoorSensor.h/.cpp` in `src/`. Pin
        configurable in the setup page (like the poll interval). Needs
        hardware info (which GPIO).

### OTA / GitHub workflow
- [x] **OTA via GitHub release pull** implemented: `src/Updater.cpp`
        queries `https://api.github.com/repos/itsfair/top_attempt/releases/latest`,
        compares version, downloads `firmware.bin` and flashes via the
        `Update` lib. TLS via `WiFiClientSecure::setInsecure` (no CA
        bundle; can later be improved with an embedded bundle).
- [x] **GitHub action** (`.github/workflows/firmware.yml`) builds on
        tag push `fw-v*` and creates a GitHub release with
        `firmware.bin` as asset. Version extracted from the tag
        (`fw-v0.2.0` → `0.2.0`) and injected into the build via
        `FW_VERSION_FLAGS` (`platformio.ini`
        `${sysenv.FW_VERSION_FLAGS}`). Local build without CI →
        fallback `0.0.0-dev` (via `config.h`).
- [x] **Web UI update section** in the setup page (/setup → "Firmware
        update"): button "check for update", progress display during
        download, status `DONE` → separate "reboot" button
        (`/api/reboot`).
- [x] **Reboot endpoint** `/api/reboot` + dashboard menu "reboot".
- [x] **Partition table** `doorinterface/partitions.csv` with 2 OTA
        slots (1.875 MB each), NVS (16 KB), otadata (8 KB). Flash usage
        ~72 %. **Important**: switching the partition table deletes NVS
        on first flash — Wi-Fi/NUKI credentials/hostname must be
        reconfigured.
- [x] **OTA recovery trap: when OTA installs a firmware that does not
        run (e.g. crash at boot, or broken behaviour like the redirect
        bug here), the lib writes the other slot to `otadata` as
        "active on next boot". A subsequent `pio run -t upload` writes
        the fix to slot 0, but the bootloader keeps starting the
        (broken) slot 1 until the `otadata` partition is erased.
        **Solution in that case**: `pio run -t erase` → `pio run -t
        upload` (erases the entire flash including `otadata`; the
        bootloader defaults to slot 0).
- [ ] ESP periodically checks GitHub for a new version (currently only
        manually via the setup page; automatic background poll later).

### Logging / robustness
- [ ] Central debug macro (`#define DEBUG_SERIAL` + `LOGI/LOGW/LOGE`).

### Docs
- [x] **BLE interface ESP↔smartphone app** in `docs/ble_interface.md`
        (prototype state, mocked backend response; German).
- [ ] Rewrite `docs/interfaces.md` once the HTTP API / NVS / BLE GATT
        of the current state are stable (the old spec from the previous
        version was deleted during the firmware setup reset and is
        outdated).

## Conventions / notes

- No comments in the code (by agreement).
- `Serial` prefixes: `[WifiManager]`, `[HTTP]`, `[NUKI]`, `[BLE]`.
- NVS namespaces: `"wifi"`, `"system"`; NUKI manages its own (namespace
  = device name).
- Files in the `src/` directory, not in `lib/` (by agreement).
  Exception: `lib/nuki_ble/` = patched fork (not own code).

## Continuation

Next recommended step:
**BleServer: connection to the local backend** (replaces the mocked
answer with real credential checking via HTTP/WS) or **encryption /
pairing of the BLE connection** (`*_ENC` flags + NimBLE security
callbacks) or **relay GPIO** — depending on priority.
