# DoorInterface — Projekt-Handoff

ESP32-Firmware (PlatformIO + Arduino-Framework) zur Steuerung von Türöffnern
(Relais + NUKI Smart Locks über BLE), mit W-LAN-Einrichtung per Captive Portal,
gesicherter Weboberfläche und API/Websocket für lokales Backend.

## Build & Flash — WICHTIG FÜR ALLE AGENTEN

```bash
pio run                 # build
pio run -t upload       # flash
pio device monitor      # serial @ 115200
```

> **DRAKONISCH REGEL FÜR ALLE AGENTEN (gilt auch für Sub-Agenten):**
>
> 1. **Kein Build nach jeder kleinen Code-Änderung.** Ein `pio run` dauert
>    20–60 s und verbraucht massiv Kontextzeit. Baut nur auf ausdrücklichen
>    Wunsch des Nutzers **oder** bei tiefergehenden Refactorings, bei denen
>    Syntaxfehler nicht offensichtlich sind. Wenn die Änderung trivial ist
>    (z.B. eine String-Konstante, eine Log-Zeile, eine JS-HTML-Snippet-Anpassung),
>    vertraut auf sorgfältiges Lesen des Diffs — der Nutzer kompiliert und
>    flasht ohnehin selbst.
> 2. **Änderungen VORHER erklären, nicht einfach in Dateien schreiben.**
>    Der Agent schlägt jeden Häppchen-Schritt als Code-Snippet + kurze
>    Erklärung vor und wartet auf das „Okay" des Nutzers, bevor die Dateien
>    tatsächlich angefasst werden. Ausnahme: reine Dokumentations-Updates
>    (AGENTS.md, docs/*.md), die keine Code-Semantik ändern.
>
> Missachtet ein Agent diese Regeln, beeinträchtigt das die
>    Arbeitsgeschwindigkeit erheblich — die Regeln sind nicht optional.

PlatformIO-Konfiguration: `platformio.ini`, env `esp32dev`, `monitor_speed = 115200`.

> Hinweis: `pio` ist nicht im PATH. PlatformIO liegt unter
> `C:\Users\Simon\.platformio\penv\Scripts\platformio.exe`.

> Hinweis zur lokalen Installation (vorgefallen): Das ESP32-Framework-Paket
> `framework-arduinoespressif32` war unvollständig installiert (fehlender
> `variants/`-Ordner) und das Python-Modul `intelhex` fehlte für `esptool`.
> Beides wurde manuell behoben (`intelhex` per `pip install` ins PIO-Python-Env).
> Falls der Build auf einem anderen Rechner fehlschlägt, zuerst prüfen:
> `Test-Path "$env:USERPROFILE\.platformio\packages\framework-arduinoespressif32\variants"`

## Monorepo-Kontext

Dieses Firmware-Verzeichnis ist Teil des Monorepos `top_attempt`:

```
top_attempt/
├── apps/             → Serverpod-Backends + Flutter-Clients (eigene AGENTS.md)
├── doorinterface/    → dieses Projekt
├── .github/workflows/
│   ├── firmware.yml  → baut nur `pio run` als CI-Build-Check (kein OTA!)
│   ├── analyze.yml   → Dart-Analyse für apps/
│   ├── format.yml    → dart format-Check für apps/
│   └── tests.yml     → dart test für apps/
└── README.md
```

- Die alten OTA-Workflows (`dev-manifest.yml`, `release.yml`) wurden
  gelöscht. Es gibt aktuell **kein** automatisches Manifest- oder
  Release-Management — eventuell später nach dem OTA-Relaunch neu anlegen.
- Der alte Firmware-Code mit `Update()` / `update_manager.*` /
  `partitions/ota.csv` / `firmware/manifest-*.json` wurde komplett
  verworfen. Die aktuelle Firmware nutzt die Default-Partition-Table
  (kein OTA-Slot), deshalb der knappe Flash (92.2%) — siehe TODO.

## Code-Struktur (Stand jetzt)

```
platformio.ini
src/
  config.h              -> FW_VERSION "0.1.0"
  main.cpp              -> instanziiert WifiManager, NukiManager, WebInterface
  WifiManager.h/.cpp    -> WLAN-STA-Versuch + AP-Fallback + Captive Portal + Hostname
  WebInterface.h/.cpp   -> Haupt-Webserver (STA-Modus): Dashboard, Setup, API
  NukiManager.h/.cpp    -> NUKI BLE: Pairing, Lock/Unlock, Status-Querying
  BleServer.h/.cpp      -> BLE Peripheral (GATT-Server) für Smartphone-App, s. docs/ble_interface.md
  Updater.h/.cpp       -> OTA-Update über GitHub-Releases-Pull (WiFiClientSecure + Update-Lib)
  web/
    portal_html.h       -> Captive-Portal-HTML (PROGMEM)
    portal_css.h        -> Captive-Portal-CSS (PROGMEM)
    portal_js.h         -> Captive-Portal-JS  (PROGMEM)
    main_html.h         -> Dashboard-HTML (PROGMEM)
    main_css.h          -> Dashboard + Setup CSS (PROGMEM)
    main_js.h           -> Dashboard-JS: Status-Poll, Lock/Unlock-Buttons
    setup_html.h        -> Setup-Seite-HTML (PROGMEM)
    setup_js.h          -> Setup-JS: Hostname, NUKI-Pairing, Test-Buttons
lib/
  nuki_ble/             -> Gepatchter Fork von AzonInc/NukiBleEsp32 (idf-Branch)
                           7 NimBLE-API-Patches für NimBLE-Arduino 1.4.x
                           Eigene Preferences.h/.cpp entfernt (Arduino-Framework genutzt)
docs/
  ble_interface.md      -> Spec der BLE-Schnittstelle ESP<->Smartphone-App (Prototyp)
```

## Architektur-Entscheidungen

- **Webinhalte als PROGMEM-Strings**, nicht als Filesystem (LittleFS).
  Grund: späteres OTA-Update (per GitHub-Push generiertes Binary) soll die
  Webinhalte automatisch mitliefern — eine Daten-Partition via OTA separat
  zu updaten wäre fehleranfälliger. Dateien unter `src/web/`, header-only,
  je ein PROGMEM-String pro Datei.
- **Trennung nach Bereich und Typ**: `portal_*.h` für Captive Portal,
  `main_*.h`/`setup_*.h` für die Haupt-Weboberfläche. Pro Bereich je eine
  Datei für html/css/js.
- **WifiManager als eigenes Modul** (`src/WifiManager.cpp`), `main.cpp`
  bleibt schlank.
- **WebInterface als eigenes Modul** (`src/WebInterface.cpp`), startet wenn
  STA verbunden + AP zu. Nimmt `WifiManager&` und `NukiManager&` per Referenz.
- **NukiManager als eigenes Modul** (`src/NukiManager.cpp`), kapselt BLE-Scanner
  + NukiLock. Event-Handler für Status-Updates. Credentials in NVS (Namespace
  = Gerätename, verwaltet von NukiBleEsp32-Lib).
- **Debug-Logging** über `Serial.print*` mit Präfixen: `[WifiManager]`,
  `[HTTP]`, `[NUKI]`, `[BLE]`.
- **BLE-Start verzögert**: `nuki.begin()` wird **nicht** in `setup()`
  aufgerufen, sondern in `loop()` erst, wenn `wifi.isConnected() &&
  !wifi.isApActive()`. Grund: der ESP32 teilt sich ein 2.4 GHz-Radio
  für WiFi und Bluetooth — initialisiert man BLE parallel zum aktiven
  Setup-AP,_BLOCKIERT das den AP. Im STA-Modus funktioniert WiFi/BT
  Coexistence (Time-Slicing). Entsprechend startet auch `WebInterface`
  erst nach erfolgreicher STA-Verbindung; `main.cpp` hält die
  `_started`-Flags dafür.
- **BleServer startet vor NukiManager**: `BleServer.begin()` ruft als
  Erstes `NimBLEDevice::init(name)` auf — dieser Aufruf ist nur beim
  ersten Mal wirksam, danach No-Op. NimBLE heißt also = ESP-Hostname.
  `NukiManager.begin()` (das `init()` intern nochmal aufruft) läuft erst
  danach. BleServer nutzt bewusst **keine eigenen Member-Pointer** auf
  Service/Characteristic, sondern holt sie per `NimBLEDevice::getServer()`
  /`getServiceByUUID()` zurück — das verhindert Stale-Pointer-Probleme
  falls NimBLE intern reorganisiert und ist mit nur einem Service
  ausreichend schnell.
- **BleServer = Peripheral, NukiManager = Central** an demselben NimBLE-
  Stack. NimBLE erlaubt per Default max. 3 Verbindungen + alle Rollen.
  BleServer hat genau eine Smartphone-Verbindung, NukiManager eine
  Central-Verbindung zum Lock — beide laufen gleichzeitig (Time-Slicing
  im Controller). Stabilität bei parallelem Connect muss beobachtet
  werden; ggf. später Connection-Params des Clients anpassen.
- **Protokoll**: JSON über GATT (Write auf Request-Char, Notify auf
  Response-Char), keine Verschlüsselung im Prototyp. Spec in
  `docs/ble_interface.md`.

## NUKI BLE Integration — wichtige Details

- **Bibliothek**: `lib/nuki_ble/` = gepatchter Fork von
  `https://github.com/AzonInc/NukiBleEsp32.git` (idf-Branch).
  Unterstützt **alle NUKI-Modelle**: Smart Lock 1.0–4.0, 5.0 Pro, Ultra, Go,
  Opener, Keypad.
- **7 NimBLE-API-Patches** für Kompatibilität mit `NimBLE-Arduino @ ^1.4.1`:
  1. `onDisconnect(BLEClient*, int reason)` → `onDisconnect(BLEClient*)`
  2. `onResult(const BLEAdvertisedDevice*)` → `onResult(BLEAdvertisedDevice*)`
  3. `NimBLERemoteCharacteristic::notify_callback` → `notify_callback`
  4. `NimBLEDevice::isInitialized()` Aufrufe entfernt (nicht in 1.4.x)
  5. `NimBLEDevice::setPower(int)` → `setPower(esp_power_level_t)`
  6. `NimBLEBeacon::setData(uint8_t*, uint8_t)` → `setData(std::string)`
  7. `BLEAddress::getVal()` → `BLEAddress::getNative()`
8. **`NukiBle.cpp onResult` — Edge-Detection für Status-Updated-Flag.**
   Original feuert `eventHandler->notify(KeyTurnerStatusUpdated)` bei jedem
   Advertising-Paket, in dem das Status-Bit gesetzt ist — d.h. fortlaufend
   alle paar hundert Millisekunden. Patch: `if (!statusUpdated && eventHandler)`
   als Gate, so dass das Event nur bei echter Flanke (false→true) einmalig
   feuert. `statusUpdated=true` wird intern weiterhin gesetzt; der Reset-Zweig
   (Flag gelöscht) setzt `statusUpdated=false` zurück und Feuer
   `KeyTurnerStatusReset`. Behebt permanentes State-Request-Loop im
   NukiManager, das NUKI alle 30s aktiv connected und Batterie verbraucht.
- **Preferences-Konflikt gelöst**: Die idf-Branch hat eine eigene
  `Preferences.h/.cpp` mit `std::string`-API, die mit der Arduino-Framework-
  `Preferences` (mit `String`-API) kollidiert. Lösung: eigene Dateien
  **gelöscht**, die Arduino-Framework-Version ist ein Drop-in Replacement.
- **Kein Framework-Wechsel**: `framework = arduino` (kein espidf), keine
  sdkconfig.defaults, keine partitions.csv nötig.
- **Dependencies**: `NimBLE-Arduino @ ^1.4.1`, `BleScanner` (I-Connect),
  `Crc16` (vinmenn).
- **Ultra/5th-Gen PIN**: Für Smart Lock Ultra/5th Gen/Go/Pro muss vor dem
  Pairing die 6-stellige PIN gesetzt werden (`saveUltraPincode()`).
  Standard-Locks (1.0–4.0) brauchen keine PIN.
  TODO: PIN-Eingabe in der Setup-Seite.
- **Ultra-Support Forschung**: Platform-Upgrade auf Arduino Core 3.x
  (ESP-IDF 5.x) mit `framework = arduino, espidf` wurde getestet, scheiterte
  aber an Python-Dependency-Problemen in PlatformIO. Die gepatchte Fork-Lösung
  umgeht das vollständig.

## Captive Portal — implementierter Ablauf

1. `begin()`: NVS-Hostname (Namespace `"system"`) + Credentials (Namespace
   `"wifi"`) laden. Hostname-Default: `doorinterface-XXXX` (letzte 2 MAC-Bytes).
2. Falls SSID vorhanden: STA-Versuch (`tryConnect`), 15 s Timeout.
   `WiFi.setHostname()` wird vor jedem `WiFi.begin()` aufgerufen.
3. `startFallbackAp()`: `setAutoReconnect(false)` + `disconnect(false)` →
   STA-Radio frei für Scan. Modus `WIFI_AP_STA`, AP-Name `DoorSetup-AP`.
4. `startPortal()`:
   - `DNSServer` Catch-All (`*` -> AP-IP).
   - Routen: `/`, `/portal.css`, `/portal.js`, `/scan`, `/save`, `/status`,
     `/config`, `/close`.
   - `UriGlob("*")` + `HTTP_ANY` als Catch-All → kein `log_e`-Spam mehr.
   - `onNotFound` als defensive fallback.
5. `/scan` (GET): `WiFi.scanNetworks()` blockierend, JSON-Array.
6. `/save` (POST): SSID/Pass + optional Hostname in NVS, `WiFi.begin()`,
   antwortet sofort `{"status":"connecting"}`.
   **Validierung**: Ist ein Hostname angegeben, wird `setHostname()`
   geprüft (nur `a-z`, `0-9`, `-`; 1–63 Zeichen; nicht mit `-` beginnen/
   enden). Bei ungültigem Namen liefert `/save` HTTP 400 +
   `{"error":"Hostname ungültig (nur a-z, 0-9, -; nicht mit - beginnen/enden)"}`
   und bricht den Save-Flow ab — die WLAN-Daten werden nicht gespeichert.
   Das Frontend zeigt den Fehler im Status-Bereich an.
7. `/config` (GET): JSON `{hostname}` für Portal-Frontend.
8. `/close` (POST): AP sofort schließen (Button im Overlay nach erfolgtem
   Connect). Frontend kopiert STA-IP ins Clipboard + schließt AP.
9. Portal-State-Machine in `loop()`:
   - `_shutdownRequested` Flag → `shutdownAp()` (vom Button und 30s-Timer).
   - `PORTAL_CONNECTING` → `PORTAL_CONNECTED` → 30s Timer → `shutdownAp()`.
   - `shutdownAp()`: `setAutoReconnect(true)` für reinen STA-Betrieb.

## Frontend (Captive Portal)

- HTML/CSS/JS inline als PROGMEM in `src/web/portal_*.h`.
- Select für gescannte Netzwerke + manuelles SSID-Feld.
- Gerätename-Feld (geladen via `/config`).
- Overlay mit Spinner + Status-Polling.
- Bei `connected`: Adresse + „Adresse kopieren & Setup beenden"-Button.

## Haupt-Weboberfläche (STA-Modus)

- **WebInterface** startet wenn `wifi.isConnected() && !wifi.isApActive()`.
- mDNS mit dynamischem Hostnamen (`MDNS.begin(hostname)`).
- Routen: `/`, `/main.css`, `/main.js`, `/setup`, `/setup.js`,
  `/api/status`, `/api/hostname` (GET+POST), `/api/nuki/pair`,
  `/api/nuki/cancel`, `/api/nuki/unlock`, `/api/nuki/lock`.
- `/api/status` JSON: `{wifi, relay, locks, firmware}`.
  `locks`: `{available, count, paired, pairing, lockState, batteryPct,
  batteryCritical, rssi}`.
- Dashboard (`main_js.h`): 3 Karten (WLAN, Türöffner, Firmware).
  - WLAN: Badge + SSID/RSSI/IP, Poll alle 3s.
  - Türöffner: „nicht eingerichtet" + Setup-Link, oder Lock-State-Badge +
    Akku/RSSI + „Öffnen"/„Sperren"-Buttons.
  - ⚙-Dropdown oben rechts → `/setup`.
- Setup-Seite (`setup_js.h`):
  - Gerätename ändern (→ Reboot).
  - NUKI Pairing: Anleitung + „Pairing starten"/„Pairing abbrechen".
  - Test-Buttons (Öffnen/Sperren) bei gepaartem Lock.
  - Poll alle 2s.

## NUKI Pairing-Flow

1. Nuki-App: Bluetooth Pairing aktivieren (Settings → Features & Configuration
   → Button and LED).
2. Nuki-Taste 10s drücken (LED-Ring leuchtet).
3. Setup-Seite → „Pairing starten" → `POST /api/nuki/pair`.
4. `NukiManager::startPairing()` → `_pairingRequested = true`.
5. `loop()` ruft `pairNuki()` auf bis Success oder 10-Min-Timeout.
6. Bei Success: `requestKeyTurnerState()` → Status im Dashboard.
7. „Pairing abbrechen" → `POST /api/nuki/cancel` → `_pairingRequested = false`.
8. Credentials (ECDH-Key, Auth-ID) in NVS gespeichert (von Lib verwaltet).
   Bei Neustart: kein Re-Pairing nötig.

## Bisherige Häppchen-Schritte

1. Grundgerüst `WifiManager` (STA + AP-Fallback).
2. Captive Portal (HTML/CSS/JS, DNS, Routen, Scan, Save, Status, State-Machine).
3. NVS-Fix + Captive-Detection-Pfade.
4. Scan-Fix (`setAutoReconnect(false)` + `disconnect`).
5. `UriGlob("*")`-Catch-All gegen Log-Spam.
6. Portal-Finish-Button (Adresse kopieren + AP schließen).
7. `config.h` mit `FW_VERSION`.
8. `WebInterface`-Modul (Dashboard + mDNS).
9. Hostname-Feature: NVS `"system"`, unique Default, editierbar im Portal +
   Setup-Seite, `WiFi.setHostname()` vor `WiFi.begin()`.
10. NUKI BLE Integration: gepatchter Fork (idf-Branch), `NukiManager`,
    Pairing, Lock/Unlock, Status, Dashboard-Buttons, Setup-Seite.
11. Pairing-Abbruch (`/api/nuki/cancel`).
12. Hostname-Validierung im Portal: `setHostname()`-Rückgabewert wird in
    `handleSave()` geprüft; bei ungültigem Name -> HTTP 400 + JSON-Error,
    Frontend zeigt Meldung im Status-Bereich.
13. BLE-Start **deferred**: `nuki.begin()` aus `setup()` in `loop()`
    verschoben, erst wenn `wifi.isConnected() && !wifi.isApActive()`.
    Behebt „AP nicht erreichbar nach BLE-Init“ (Radio-Konflikt auf ESP32).
    `WebInterface` startet ebenfalls erst danach.
14. **BleServer-Prototyp**: neues Modul `src/BleServer.cpp` (NimBLE
    Peripheral). GATT-Service mit Request-Char (Write) + Response-Char
    (Notify). Smartphone schickt JSON, ESP loggt und antwortet gemockt.
    BleServer startet vor `NukiManager` (nimmt `NimBLEDevice::init` vorweg
    → Advertising-Name = Hostname). Deferred in `loop()` analog zu Nuki.
    Spec: `docs/ble_interface.md`. Noch ohne Backend / ohne Verschlüsselung.
<<<<<<< HEAD
15. **NUKI Ultra-/Go-PIN-Eingabe**: Setup-Seite um PIN-Feld ergänzt
    (`/api/nuki/pin` GET/POST), `NukiManager::setUltraPin()` ruft
    `saveUltraPincode()` auf (Lib speichert selbst im NVS). Status-Endpoint
    liefert `locks.hasUltraPin`. Notwendig für Smart Lock Go (2025) /
    Ultra / 5.0 / Pro — ohne PIN verweigert `NukiBle` das Pairing
    (`No pairing PIN code set`). Standard-Locks (1.0–4.0) brauchen keine PIN.
16. **OTA-Update** über GitHub-Releases: neues Modul `src/Updater.cpp`
    pollt `api.github.com/repos/itsfair/top_attempt/releases/latest`,
    vergleicht `tag_name` (ohne `fw-v`-Präfix) mit `FW_VERSION`, lädt
    `firmware.bin` herunter und flasht per `Update`-Lib in den inaktiven
    OTA-Slot. Setup-Seite: „Firmware-Update"-Sektion mit Button +
    Fortschrittsanzeige. Dashboard-Menü: „Neustart"-Button via
    `/api/reboot`. Neue `partitions.csv` mit 2 OTA-Slots je 1.875 MB.
    GitHub-Action `firmware.yml` triggert nur noch auf Tag-Push `fw-v*`,
    erstellt GitHub-Release. Version wird per `${sysenv.FW_VERSION_FLAGS}`
    in den Build injiziert (lokal: `0.0.0-dev` Fallback). Flash-Stand
    nach OTA-Integration: 72.1 %.
=======
>>>>>>> 1d0e9c06369b58cb019c9a37ddc34579a58a15d4

## Arbeitsweise

- Kleine Häppchen, jeder Schritt als Code-Snippet vorgeschlagen + erklärt,
  erst auf "okay" in Dateien geschrieben. **Keine Ausnahmen** — auch nicht
  bei „nur mal eben einer Kleinigkeit".
- Schritte werden vor dem Anlegen erklärt, nicht automatisch committed.
- `git commit` nur auf ausdrücklichen Wunsch.
- **Kein Build-Test nach jeder kleinen Änderung.** Der Nutzer kompiliert/flasht
  selbst und gibt Bescheid bei Problemen. Builds nur auf ausdrücklichen Wunsch
  oder bei tiefergehenden Refactorings. **Gilt auch wenn der Agent „sicher
  gerade sein will" — der Build kostet 20–60 s Kontextzeit und ist ASA-Regel
  aus dem vorherigen Abschnitt unter „Build & Flash" eh verboten.**

## Offene TODOs (Reihenfolge grob nach Priorität)

### NUKI
- [ ] PIN-Eingabe für Ultra/5th Gen/Go/Pro in der Setup-Seite
        (`saveUltraPincode()` vor Pairing).
- [ ] Unpair-Funktion (`unPairNuki()` + Setup-Button).
- [ ] Mehrere Locks parallel (Liste von NukiLock-Instanzen am selben Scanner).
- [ ] Keypad-Verwaltung, Auth-Entries, Time-Control.
- [ ] Event-Log (benötigt PIN).

### WLAN / Setup
- [ ] AP-Passwort für Setup-AP konfigurierbar (aktuell offen).
- [ ] Reset-Möglichkeit der gespeicherten WLAN-Credentials (Taster/Erase-Flag).
- [ ] Reconnect-Logik bei STA-Verbindungsabbruch.

### Weboberfläche
- [ ] Login / Session-Auth (z. B. Basic-Auth, Token, Session-Cookie).
- [ ] Relais-Konfiguration (Pin, Pegel) in Setup-Seite.
- [ ] SSID-Escaping im Status-JSON.

### Backend-Anbindung
- [ ] Entscheidung: ESP als WS-Client (Empfehlung bei mehreren ESPs) oder
        WS-Server auf ESP. Serverpod-Backend noch nicht begonnen.
- [ ] Gesicherte Verbindung ESP↔Backend (TLS? Mutual Auth?).
- [ ] Authentifizierung des Backends gegenüber dem ESP (API-Token).

### Relais
- [ ] GPIO-Ansteuerung (Pin, Timing, Entstörung). Braucht Hardware-Info.

### Türsensor
- [ ] **Option A — NUKI-eigener Türsensor:** Das im
        `Keyturner States (0x000C)`-Frame der Nuki-API enthaltene Feld
        `Door sensor state` (uint8: 0x00 unavailable, 0x02 closed, 0x03 opened,
        0x10 uncalibrated, 0xF0 tampered, 0xFF unknown) auswerten und im
        Dashboard anzeigen. Setzt voraus, dass ein NUKI-Türsensor gekoppelt
        ist. Updates nur im Poll-Intervall (`locks.pollInterval`).
- [ ] **Option B — Eigener Reed-/Magnetsensor am ESP-GPIO:** Reed-Schalter
        am Türblatt (Magnet am Rahmen) an einem GPIO-Pin mit internem
        Pull-up, Firmware pollt Pin und feuert Event bei Flanke.
        Real-time (unabhängig vom NUKI-Poll-Intervall), neue Klasse etwa
        `DoorSensor.h/.cpp` im `src/`. Pin in Setup-Seite konfigurierbar
        (wie Poll-Intervall). Braucht Hardware-Info (welcher GPIO).

### OTA / GitHub-Workflow
- [x] **OTA per GitHub-Releases-Pull** implementiert: `src/Updater.cpp`
        fragt `https://api.github.com/repos/itsfair/top_attempt/releases/latest`
        ab, vergleicht Version, lädt `firmware.bin` herunter und flasht
        per `Update`-Lib. TLS via `WiFiClientSecure::setInsecure` (ohne
        CA-Bundle, kann später mit eingebettetem Bundle verbessert werden).
- [x] **GitHub-Action** (`.github/workflows/firmware.yml`) baut bei
        Tag-Push `fw-v*` und erstellt ein GitHub-Release mit
        `firmware.bin` als Asset. Version wird aus Tag extrahiert
        (`fw-v0.2.0` → `0.2.0`) und per `FW_VERSION_FLAGS` in den Build
        injiziert (`platformio.ini` `${sysenv.FW_VERSION_FLAGS}`).
        Lokaler Build ohne CI → Fallback `0.0.0-dev` (via `config.h`).
- [x] **Web-UI Update-Sektion** in Setup-Seite (/setup → „Firmware-Update"):
        Button „Nach Update suchen", Fortschrittsanzeige während Download,
        Status `DONE` → separater „Neustart"-Button (`/api/reboot`).
- [x] **Reboot-Endpoint** `/api/reboot` + Dashboard-Menü „Neustart".
- [x] **Partition-Tabelle** `doorinterface/partitions.csv` mit 2 OTA-Slots
        (1.875 MB je), NVS (16 KB), otadata (8 KB). Flash-Auslastung ~72 %.
        **Wichtig**: Wechsel der Partition-Tabelle löscht NVS beim ersten
        Flash — WLAN/NUKI-Credentials/Hostname müssen neu konfiguriert werden.
- [ ] ESP prüft periodisch GitHub auf neue Version (z. Zt. nur manuell über
        Setup-Seite, später Auto-Poll hintergrundlich).

### Logging / Robustheit
- [ ] Zentrales Debug-Makro (`#define DEBUG_SERIAL` + `LOGI/LOGW/LOGE`).
- [ ] Flash bei 92.2% — knapp. Custom-Partition-Table (kein OTA-Slot →
        2 MB App) oder `-Os` bei Bedarf.

### Doku
- [x] **BLE-Schnittstelle ESP↔Smartphone-App** in `docs/ble_interface.md`
        (Prototyp-Stand, gemockte Backend-Antwort).
- [ ] `docs/interfaces.md` neu schreiben, sobald HTTP-API / NVS / BLE-GATT
        des aktuellen Stands stabil sind (die alte Spec aus der Vor-Version
        wurde beim Setup-Reset der Firmware gelöscht und ist veraltet).

## Konventionen / Notizen

- Keine Kommentare im Code (per Absprache).
- `Serial`-Präfixe: `[WifiManager]`, `[HTTP]`, `[NUKI]`, `[BLE]`.
- NVS-Namespaces: `"wifi"`, `"system"`, NUKI verwaltet eigene
  (Namespace = Gerätename).
- Dateien im `src/`-Verzeichnis, nicht in `lib/` (per Absprache).
  Ausnahme: `lib/nuki_ble/` = gepatchter Fork (nicht eigenem Code).

## Forsetzung

Nächster empfohlener Schritt:
**BleServer: Anbindung ans lokale Backend** (ersetzt die gemockte Antwort
durch echte Credential-Prüfung via HTTP/WS) oder **Verschlüsselung /
Pairing der BLE-Verbindung** (`*_ENC`-Flags + NimBLE-Security-Callbacks)
 oder **Relais-GPIO** — je nach Priorität.