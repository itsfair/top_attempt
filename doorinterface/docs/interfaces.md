# DoorInterface — Schnittstellendokumentation

> Firmware-Version: 1.0.0 (Phase 1)
> Hardware: ESP32 Dev Module
> Framework: Arduino / ESP-IDF v4.4.7
> Zuletzt aktualisiert: Phase 1

---

## Inhaltsverzeichnis

1. [Systemarchitektur](#systemarchitektur)
2. [Gerätezustände (State Machine)](#gerätezustände-state-machine)
3. [ESP32 HTTP API](#esp32-http-api)
4. [ESP32 BLE GATT Service](#esp32-ble-gatt-service)
5. [ESP32 Serial Console](#esp32-serial-console)
6. [ESP32 NVS Konfiguration](#esp32-nvs-konfiguration)
7. [Captive Portal (Setup-Wizard)](#captive-portal-setup-wizard)
8. [ESP32 ↔ Lokaler Server](#esp32--lokaler-server-phase-2)
9. [Lokaler Server ↔ Globaler Server](#lokaler-server--globaler-server-phase-2)
10. [Authentifizierungsfluss](#authentifizierungsfluss-phase-2)
11. [Benutzergruppen](#benutzergruppen)
12. [OTA / Firmware-Update](#ota--firmware-update)

---

## Systemarchitektur

```
Flutter App (End User)
    │
    │ BLE (GATT)
    │ Phase 2: Auth-Handshake, Tür-Ergebnis
    ▼
ESP32 (doorinterface)
    │                           │
    │ HTTP (Port 80)            │ BLE Central
    │ Phase 2: /open vom Server │ (NimBLE)
    ▼                           ▼
Lokaler Server              NUKI Smart Lock
(Serverpod, Port 8080)
    │
    │ REST Webhooks
    │ Phase 2: User-Sync
    ▼
Globaler Server
(Serverpod, Port 8080)
```

---

## Gerätezustände (State Machine)

```
BOOTING ──────────────────────────────────────────────┐
    │                                                  │
    │ WLAN-Credentials vorhanden?                      │
    ├── NEIN ──→ SETUP_MODE                            │
    │              (AP: "DoorInterface-XXXX")          │
    │              Captive Portal — NUR WLAN-Setup     │
    │              WLAN verbunden → Neustart           │
    │                                                  │
    └── JA ───→ CONNECTING                             │
                    │                                  │
                    ├── Erfolg ──→ OPERATIONAL         │
                    │              HTTP-API aktiv      │
                    │              Hardware optional   │
                    │              (Config über /config│
                    │               oder API)          │
                    │                                  │
                    └── Fehler ──→ AP_FALLBACK         │
                                   (wie SETUP_MODE)    │
```

**Wichtig:** Das Ersteinrichtungs-Wizard konfiguriert **ausschließlich das WLAN**.
Server-URL, Hardware-Typ (Relais/NUKI) und NUKI-Pairing werden **danach** im
Betriebsmodus über die Webseite `/config` oder die HTTP-API eingerichtet.
Der Betriebsmodus startet auch ohne konfigurierte Hardware (Typ `none`).

---

## ESP32 HTTP API

Erreichbar unter `http://doorinterface.local` (mDNS) oder `http://<IP-Adresse>`
Port: **80**
Status: **Phase 1 — aktiv (kein Auth erforderlich)**

> In Phase 2 wird `/open` durch einen `Authorization`-Header mit Server-Token gesichert.

---

### GET /

Gibt die Status-Webseite mit Test-Buttons zurück (HTML).

---

### GET /status

Gibt den aktuellen Gerätestatus zurück.

**Response `200 OK`:**
```json
{
  "device": "doorinterface",
  "firmware": "1.0.0",
  "wifi": {
    "connected": true,
    "ssid": "Büro-WLAN",
    "ip": "192.168.1.42",
    "rssi": -62
  },
  "hardware": {
    "type": "relay",
    "configured": true,
    "state": "closed"
  },
  "ble": {
    "advertising": true,
    "address": "AA:BB:CC:DD:EE:FF"
  },
  "server": {
    "url": "http://192.168.1.100:8080",
    "registered": false
  },
  "uptime_s": 3600
}
```

**Hardware-Typen:** `"relay"` | `"nuki"` | `"none"`
**Door-States:** `"open"` | `"closed"` | `"unknown"`

---

### POST /open

Öffnet die Tür.

**Request Body** (optional):
```json
{
  "duration_ms": 5000
}
```

**Response `200 OK`:**
```json
{
  "success": true,
  "hardware": "relay",
  "duration_ms": 3000
}
```

**Response `503 Service Unavailable`:**
```json
{
  "success": false,
  "error": "Hardware not configured"
}
```

> Phase 2: Zusätzliches Pflichtfeld `"token": "<one_time_token>"` zur Server-Authentifizierung.

---

### POST /close

Schließt die Tür manuell (Relais zurücksetzen / NUKI Lock).

**Response `200 OK`:**
```json
{
  "success": true
}
```

---

### GET /config

Liefert die Konfigurations-Webseite (HTML). Die JSON-Konfiguration ist unter
`GET /config/data` abrufbar — siehe Abschnitt
[Konfiguration im Betriebsmodus](#konfiguration-im-betriebsmodus-config).

---

### POST /setup

Löscht WiFi-Credentials und startet den Setup-Wizard (Neustart in AP-Modus).

**Response `200 OK`:**
```json
{
  "success": true,
  "message": "Rebooting into setup mode..."
}
```

---

### POST /reboot

Startet das Gerät neu.

**Response `200 OK`:**
```json
{
  "success": true
}
```

---

## ESP32 BLE GATT Service

**Service UUID:** `4fafc201-1fb5-459e-8fcc-c5c9c331914b`
**Gerätename (Advertisement):** `DoorInterface`

---

### Characteristic: WiFi Provision

| Eigenschaft | Wert |
|---|---|
| UUID | `beb5483e-36e1-4688-b7f5-ea07361b26a8` |
| Permissions | WRITE |
| Phase | 1 |

**Write-Format (JSON):**
```json
{
  "ssid": "MeinNetz",
  "password": "geheim"
}
```

**Response via Device Status Notify:**
```json
{
  "event": "wifi_result",
  "success": true,
  "ip": "192.168.1.42"
}
```

---

### Characteristic: Device Status

| Eigenschaft | Wert |
|---|---|
| UUID | `beb5483e-36e1-4688-b7f5-ea07361b26a9` |
| Permissions | READ, NOTIFY |
| Phase | 1 |

**Read/Notify-Format (JSON):**
```json
{
  "hw": "relay",
  "door": "closed",
  "wifi": true,
  "ip": "192.168.1.42"
}
```

---

### Characteristic: Door Control

| Eigenschaft | Wert |
|---|---|
| UUID | `beb5483e-36e1-4688-b7f5-ea07361b26aa` |
| Permissions | WRITE |
| Phase | 2 (vorbereitet) |

**Write-Format:**
```json
{
  "action": "open",
  "session_token": "a1b2c3...",
  "duration_ms": 3000
}
```

`action`: `"open"` | `"close"`

---

### Characteristic: Session Token

| Eigenschaft | Wert |
|---|---|
| UUID | `beb5483e-36e1-4688-b7f5-ea07361b26ab` |
| Permissions | READ, NOTIFY |
| Phase | 2 (vorbereitet) |

**Read-Format:**
```json
{
  "token": "a1b2c3d4e5f6...",
  "expires_s": 30
}
```

---

## ESP32 Serial Console

Verbindung: USB, **115200 Baud**

### System

| Befehl | Beschreibung |
|---|---|
| `status` | Gesamtstatus ausgeben |
| `reboot` | Neustart |
| `setup` | Setup-Wizard starten (AP-Modus) |
| `help` | Alle Befehle auflisten |

### Tür

| Befehl | Beschreibung |
|---|---|
| `open` | Tür öffnen (Dauer aus Config) |
| `open <ms>` | Tür öffnen für N Millisekunden |
| `close` | Tür schließen |

### Konfiguration

| Befehl | Beschreibung |
|---|---|
| `config show` | Alle Einstellungen anzeigen |
| `config wifi <SSID> <PASS>` | WLAN konfigurieren und sofort verbinden |
| `config server <URL>` | Server-URL setzen |
| `config hardware relay <PIN>` | Relais an GPIO-Pin (normally open) |
| `config hardware relay_nc <PIN>` | Relais an GPIO-Pin (normally closed) |
| `config hardware nuki` | NUKI-Modus aktivieren |
| `config duration <ms>` | Standard-Öffnungsdauer in Millisekunden |
| `config reset` | Werksreset (löscht NVS vollständig) |

### BLE

| Befehl | Beschreibung |
|---|---|
| `ble info` | BLE-Adresse und Service-UUID anzeigen |
| `ble advertise` | BLE-Advertising neu starten |

### NUKI (nur wenn Hardware-Typ = NUKI)

| Befehl | Beschreibung |
|---|---|
| `nuki pair` | Pairing-Modus starten (Knopf am Schloss halten) |
| `nuki state` | Aktuellen Schloss-Status abfragen |
| `nuki unlock` | Schloss öffnen (Riegel zurück) |
| `nuki unlatch` | Tür aufstoßen (Falle zurückziehen) |
| `nuki lock` | Schloss verriegeln |
| `nuki info` | Geräteinformationen des Schlosses abfragen |

---

## ESP32 NVS Konfiguration

Namespace: `doorconfig`

| Schlüssel | Typ | Standard | Beschreibung |
|---|---|---|---|
| `wifi_ssid` | String | `""` | WLAN-Name |
| `wifi_pass` | String | `""` | WLAN-Passwort |
| `server_url` | String | `""` | Lokale Server-URL |
| `hw_type` | uint8 | `0` | `0`=NONE, `1`=RELAY, `2`=NUKI |
| `relay_pin` | uint8 | `18` | GPIO-Pin für Relais |
| `relay_nc` | bool | `false` | Normally Closed Logik |
| `open_duration_ms` | uint32 | `3000` | Öffnungsdauer in ms |
| `nuki_address` | String | `""` | BLE MAC des NUKI-Schlosses |
| `nuki_paired` | bool | `false` | Pairing abgeschlossen |
| `device_name` | String | `"doorinterface"` | mDNS-Hostname |
| `is_configured` | bool | `false` | WLAN-Setup abgeschlossen (informativ; Boot prüft `wifi_ssid`) |

> NUKI Pairing-Credentials (Auth-ID, Secret-Key) werden intern von der
> NukiBleEsp32-Library im NVS-Namespace `"nuki_lock"` verwaltet.

---

## Captive Portal (Setup-Wizard — nur WLAN)

Aktiv wenn keine WLAN-Credentials gespeichert sind, oder nach `POST /setup`.

**AP-SSID:** `DoorInterface-XXXX` (XXXX = letzte 4 Stellen der MAC-Adresse)
**AP-IP:** `192.168.4.1`
**DNS:** Alle Anfragen werden auf `192.168.4.1` umgeleitet (Captive Portal)

Der Wizard ist eine einzelne Seite: WLAN scannen/auswählen, Passwort eingeben,
verbinden & speichern. Bei Erfolg startet das Gerät in den Betriebsmodus neu.

### Endpunkte

| Methode | Pfad | Beschreibung |
|---|---|---|
| `GET`  | `/` | Redirect zu `/setup` |
| `GET`  | `/setup` | Setup-Seite (HTML) |
| `POST` | `/scan/start` | WLAN-Scan starten (Task) → `{"status":"scanning"}` |
| `GET`  | `/scan/result` | Scan-Status / Ergebnis pollen |
| `POST` | `/connect` | Verbindung testen & bei Erfolg speichern |
| `GET`  | `/connect/status` | Verbindungsstatus pollen |

### `GET /scan/result` Response

Solange laufend:
```json
{ "status": "scanning" }
```

Fertig:
```json
{
  "status": "done",
  "networks": [
    { "ssid": "Büro-WLAN", "rssi": -62, "open": false },
    { "ssid": "Gäste", "rssi": -78, "open": true }
  ]
}
```

### `POST /connect` Request

```json
{ "ssid": "Büro-WLAN", "password": "geheim" }
```

Antwort: `{ "status": "connecting" }` — danach `/connect/status` pollen.

### `GET /connect/status` Response

```json
{ "status": "connecting" }
```
```json
{ "status": "ok", "ip": "192.168.1.42", "host": "doorinterface" }
```
```json
{ "status": "failed" }
```

Bei `ok` speichert das Gerät die Credentials und startet nach ~6s neu.

---

## Konfiguration im Betriebsmodus (`/config`)

Nach dem WLAN-Setup werden alle weiteren Einstellungen hier vorgenommen.
Erreichbar unter `http://doorinterface.local/config`.

### Endpunkte

| Methode | Pfad | Beschreibung |
|---|---|---|
| `GET`  | `/config` | Konfigurations-Webseite (HTML, Tabs: Allgemein/Hardware) |
| `GET`  | `/config/data` | Aktuelle Konfiguration als JSON |
| `POST` | `/config/general` | Server-URL, Gerätename, Öffnungsdauer speichern |
| `POST` | `/config/hardware` | Hardware-Typ speichern (→ Neustart) |
| `POST` | `/config/hardware/test` | Tür-Test (Relais-Puls / NUKI unlatch+lock) |
| `POST` | `/config/nuki/scan/start` | NUKI-Scan starten |
| `GET`  | `/config/nuki/scan/result` | NUKI-Scan-Ergebnis pollen |
| `POST` | `/config/nuki/pair/start` | NUKI-Pairing starten |
| `GET`  | `/config/nuki/pair/status` | Pairing-Status pollen |

### `GET /config/data` Response

```json
{
  "hardware_type": "relay",
  "relay_pin": 18,
  "relay_nc": false,
  "open_duration_ms": 3000,
  "server_url": "http://192.168.1.100:8080",
  "device_name": "doorinterface",
  "nuki_address": "",
  "nuki_paired": false
}
```

### `POST /config/general` Request

```json
{
  "server_url": "http://192.168.1.100:8080",
  "device_name": "tuer-eingang",
  "open_duration_ms": 3000
}
```
Antwort: `{ "success": true, "reboot_required": false }`
(`reboot_required` = true wenn Gerätename geändert → mDNS-Neustart)

### `POST /config/hardware` Request

```json
{
  "type": "relay",
  "relay_pin": 18,
  "relay_normally_closed": false,
  "nuki_address": ""
}
```
`type`: `none` | `relay` | `nuki`. Antwort `{ "success": true }`, Gerät startet
nach ~1,5s neu um die neue Hardware zu aktivieren.

### NUKI Scan/Pair (Polling-Muster)

```
POST /config/nuki/scan/start   → { "status": "scanning" }
GET  /config/nuki/scan/result  → { "status": "scanning" }
                               → { "status": "done", "devices": [
                                     { "name": "Nuki ...", "address": "AA:..", "rssi": -55 } ] }

POST /config/nuki/pair/start { "address": "AA:.." } → { "status": "pairing" }
GET  /config/nuki/pair/status → { "status": "pairing" }
                              → { "status": "ok" }  |  { "status": "failed" }
```

---

## ESP32 ↔ Lokaler Server (Phase 2)

> **Status: Phase 2 — noch nicht implementiert**

### ESP32 → Server: Gerät registrieren

Wird bei jedem Boot nach erfolgreicher WiFi-Verbindung aufgerufen.

```
POST <server_url>/device/register
Content-Type: application/json

{
  "device_id": "AA:BB:CC:DD:EE:FF",
  "ip": "192.168.1.42",
  "hardware_type": "relay",
  "firmware": "1.0.0",
  "door_id": "uuid"
}
```

**Response `200 OK`:**
```json
{ "success": true, "server_token": "<token>" }
```

---

### ESP32 → Server: Zugangsberechtigung prüfen

```
POST <server_url>/door/verifyAccess
Content-Type: application/json

{
  "user_jwt": "<globaler JWT des Benutzers>",
  "door_id": "uuid",
  "device_id": "AA:BB:CC:DD:EE:FF",
  "session_token": "<vom ESP32 generierter Einmal-Token>"
}
```

**Response `200 OK`:**
```json
{ "success": true, "user_id": "uuid", "scope": "member" }
```

---

### Server → ESP32: Tür öffnen

```
POST http://<esp32_ip>/open
Content-Type: application/json

{
  "token": "<session_token aus verifyAccess>",
  "duration_ms": 3000
}
```

---

## Lokaler Server ↔ Globaler Server (Phase 2)

> **Status: Phase 2 — noch nicht implementiert**

### Globaler Server → Lokaler Server (Webhooks)

| Ereignis | Endpunkt | Payload |
|---|---|---|
| User tritt Betrieb bei | `POST /sync/member/add` | `{user_id, name, email}` |
| User verlässt Betrieb | `POST /sync/member/remove` | `{user_id}` |
| User gesperrt | `POST /sync/member/block` | `{user_id}` |
| Mitarbeiter freigeschalten | `POST /sync/employee/add` | `{user_id, email, scope}` |
| Mitarbeiter entfernt | `POST /sync/employee/remove` | `{user_id}` |

---

## Authentifizierungsfluss (Phase 2)

```
1. User scannt QR-Code an Tür
   Inhalt: { "ble_address": "AA:BB:CC:DD:EE:FF",
             "door_id": "uuid",
             "service_uuid": "4fafc201-..." }

2. Flutter App verbindet via BLE mit ESP32

3. ESP32 generiert session_token (32 Byte Zufallswert)
   → sendet via BLE Notify (Characteristic: Session Token)

4. App sendet an Lokalen Server:
   POST <local_server>/door/requestAccess
   Authorization: Bearer <globaler_JWT>
   { "door_id": "uuid", "session_token": "<token>" }

5. Lokaler Server:
   a. JWT-Signatur verifizieren (shared signing key)
   b. user_id in local_member / local_employee prüfen
   c. door_id Berechtigung prüfen
   d. Bei Erfolg:
      POST http://<esp32_ip>/open { "token": "<session_token>", "duration_ms": 3000 }

6. ESP32:
   a. session_token verifizieren
   b. Hardware öffnen (Relay oder NUKI)
   c. BLE Notify an App (Ergebnis: success / error)
```

---

## Benutzergruppen

| Gruppe | Lokaler Login | Tür-Zugang | Admin-Funktionen |
|---|---|---|---|
| `member` | Nein (nur globaler JWT) | Ja (wenn berechtigt) | Nein |
| `employee` | Ja (lokale Credentials) | Ja | Eingeschränkt |
| `admin` | Ja (lokale Credentials) | Ja | Vollständig |

**JWT Scope-Namen:**
- Member: `scopeNames: ["member"]`
- Employee: `scopeNames: ["employee"]`
- Admin: `scopeNames: ["admin", "employee"]`

**Lokale Auth-Strategie:**
- Members: Globaler JWT wird lokal validiert (shared HMAC-SHA-512 Signing Key)
- Employees: Zusätzlich lokale Email+Passwort-Credentials für serverunabhängigen Login
- User-UUID ist global und lokal identisch (bei Sync übertragen)

---

## OTA / Firmware-Update

### Übersicht

Das ESP32 holt sich ein JSON-Manifest von einer konfigurierbaren URL,
lädt die referenzierte `firmware.bin` über HTTPS herunter, prüft die
SHA-256 aus dem Manifest, flasht das andere OTA-Partition-Slot und
wartet 60 Sekunden auf eine explizite Bestätigung. Ohne Bestätigung
wird automatisch auf das vorherige Image zurückgerollt.

**Update-Trigger:**
- **Web-UI:** Button "Nach Update suchen" auf `/update` (POST /update/check)
- **REST:** `POST /update/check`, `POST /update/install`, `POST /update/confirm`
- **Automatisch:** konfigurierbares Intervall (Default 360 Minuten = 6 h)

**Update-Flow:**
1. `checkNow()` → `HTTPClient::GET` Manifest → parsen mit ArduinoJson
2. Wenn `available_version > current_version` → State `AVAILABLE`
3. `startUpdate()` → `HTTPClient::GET` firmware.bin (HTTPS, insecure) → streamen in `Update.write()`
4. SHA-256 wird parallel mit mbedtls berechnet; bei Mismatch → Abort
5. `Update.end(true)` → State `PENDING_VERIFY`, 60 s Timer startet
6. User sendet `POST /update/confirm` ODER Timer läuft ab
7. Bei Timeout: `esp_ota_mark_app_invalid_rollback_and_reboot()`

> **Kanäle:** Die `ota_manifest_url` zeigt standardmäßig auf den Dev-Kanal
> (latest main, Manifest unter `doorinterface/firmware/manifest-dev.json`).
> Für Stable wird per `ota_channel_label="stable"` die Stable-Manifest-URL
> gesetzt — typischerweise `.../releases/latest/download/manifest-stable.json`.

### HTTP-Endpunkte

| Methode | Pfad | Beschreibung |
|---|---|---|
| `GET`  | `/update`           | Update-Webseite (Status, Buttons, Konfiguration) |
| `GET`  | `/update/status`    | JSON-Snapshot des UpdateManager-States |
| `POST` | `/update/check`     | Triggert `checkNow()` (asynchron) |
| `POST` | `/update/install`   | Triggert `startUpdate()` (asynchron) |
| `POST` | `/update/confirm`   | Bestätigt das laufende Image (`confirmBoot()`) |
| `POST` | `/config/ota`       | Setzt OTA-Konfiguration (JSON-Body) |

### GET /update/status

Response `200 OK`:
```json
{
  "state": "idle",
  "progress_pct": 0,
  "error": "",
  "current": "0.0.0",
  "available": "",
  "channel": "dev",
  "manifest_url": "https://raw.githubusercontent.com/itsfair/top_attempt/main/doorinterface/firmware/manifest-dev.json",
  "check_interval_min": 360,
  "auto_check": true,
  "update_available": false
}
```

Bei `state == "pending_verify"` zusätzlich:
```json
{
  "state": "pending_verify",
  "pending_remaining_s": 42
}
```

### POST /update/install

Startet den Download + Flash. Body wird ignoriert.

Response `200 OK`:
```json
{ "status": "downloading" }
```

### POST /update/confirm

Bestätigt das laufende Image als gut (persistiert `last_boot_version`).

Response `200 OK`:
```json
{ "success": true }
```

### POST /config/ota

Request (alle Felder optional — nicht gesetzte Felder bleiben unverändert):
```json
{
  "manifest_url": "https://...",
  "channel_label": "stable",
  "auto_check": true,
  "check_interval_min": 360
}
```

Response `200 OK`:
```json
{ "success": true }
```

### Manifest-Schema

```json
{
  "version": "0.0.0",
  "url": "https://github.com/itsfair/top_attempt/releases/download/v0.0.1/firmware.bin",
  "sha256": "abc1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcd",
  "size": 1234567,
  "notes": "Release v0.0.1"
}
```

| Feld | Typ | Pflicht | Beschreibung |
|---|---|---|---|
| `version` | String  | ja | Version, die das Device mit `FIRMWARE_VERSION` vergleicht |
| `url`     | String  | ja | HTTPS-URL zur `firmware.bin` |
| `sha256`  | String  | ja | SHA-256 des Binaries (64 Hex-Zeichen, Lowercase) |
| `size`    | Number  | ja | Größe in Bytes (wird vor dem Flash gegen Content-Length geprüft) |
| `notes`   | String  | nein | Freitext (z.B. Release-Notes) |

**Default-URLs (NVS, `ota_manifest_url`):**
- **Dev:**    `https://raw.githubusercontent.com/itsfair/top_attempt/main/doorinterface/firmware/manifest-dev.json`
- **Stable:** `https://github.com/itsfair/top_attempt/releases/latest/download/manifest-stable.json`

> **HTTPS-Zertifikate:** `WiFiClientSecure::setInsecure()` — die
> Zertifikatsprüfung ist deaktiviert. Die Integrität wird stattdessen
> über die SHA-256 aus dem Manifest sichergestellt. Bei Bedarf kann
> später auf echte Zertifikatsvalidierung umgestellt werden.

### NVS-Keys für OTA

Namespace: `doorconfig`

| Schlüssel (C++ / HTTP) | NVS-Key | Typ | Standard | Beschreibung |
|---|---|---|---|---|
| `ota_manifest_url`       | `ota_man_url`     | String | Dev-Manifest-URL (siehe oben) | Manifest-URL, die das Device periodisch pollt |
| `ota_channel_label`      | `ota_chan_lbl`     | String | `"dev"` | Anzeige-Label für den Kanal (Status-UI) |
| `ota_auto_check`         | `ota_auto_check`   | bool   | `true`  | Periodischer Auto-Check aktiv |
| `ota_check_interval_min` | `ota_chk_int_min`  | uint32 | `360`   | Auto-Check-Intervall in Minuten (Default 6 h) |
| `last_boot_version`      | `last_boot_ver`    | String | `""`    | Version, die zuletzt per `/update/confirm` bestätigt wurde |

> **Hinweis:** Die NVS-Keys sind intern auf ≤ 15 Zeichen gekürzt
> (Limit der Arduino-`Preferences`-Library). Die C++-Feldnamen und
> die externen Bezeichner in HTTP/JSON bleiben unverändert
> (`ota_manifest_url` etc.).

### Pending-Verify Workflow

Nach erfolgreichem Flash:
1. `Update.end(true)` setzt das neue Partition als Boot-Partition.
2. `UpdateManager._state` wechselt zu `PENDING_VERIFY`.
3. `_pendingVerifyStartMs = millis()` startet den 60 s Timer.
4. Die Webseite `/update` zeigt einen Countdown (`pending_remaining_s`)
   und einen "Installation bestätigen"-Button.

**Bestätigung (User):** `POST /update/confirm` → `confirmBoot()` →
- `setLastBootVersion(currentVersion)` → NVS
- `_state` → `IDLE`
- Das Image ist als gut markiert und bleibt nach Reboot aktiv.

**Auto-Rollback (kein Confirm):** Nach 60 s
- `tick()` erkennt den Timeout
- `esp_ota_mark_app_invalid_rollback_and_reboot()` markiert das
  laufende Image als ungültig und bootet das andere Partition
- Das vorherige (bekannte) Image läuft weiter

> **Wichtig:** Der Auto-Rollback greift nur, solange `tick()` läuft.
> Bei einem Hard-Crash (z.B. `while(1){delay(1000);}` in `setup()`)
> greift der Watchdog, aber der Bootloader versucht das neue Image
> erneut, da es als "valid" markiert ist. Für Bootloader-Level-Rollback
> bräuchte es `CONFIG_BOOTLOADER_APP_ROLLBACK_ENABLE=y` im ESP-IDF
> Bootloader-Config.

### Partition-Layout

`partitions/ota.csv`:

```
# Name,    Type, SubType, Offset,   Size,     Flags
nvs,       data, nvs,     0x9000,   0x6000,
otadata,   data, ota,     0xf000,   0x2000,
ota_0,     app,  ota_0,   0x10000,  0x1E0000,
ota_1,     app,  ota_1,   0x1F0000, 0x1E0000,
spiffs,    data, spiffs,  0x3D0000, 0x10000,
coredump,  data, coredump,0x3E0000, 0x10000,
```

> **Hard cut:** `huge_app.csv` (vorher) → `partitions/ota.csv` (jetzt)
> ist ein harter Schnitt. Geräte, die mit dem alten Partition-Layout
> geflasht wurden, müssen einmal per USB neu geflasht werden, sonst
> booten sie nicht mehr.
