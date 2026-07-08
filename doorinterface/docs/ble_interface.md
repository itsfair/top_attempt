# DoorInterface — BLE-Schnittstelle (ESP → Smartphone-App)

Schnittstelle für die direkte Kommunikation zwischen der Enduser-Smartphone-App
und dem ESP32 per Bluetooth Low Energy (BLE). Status: **Prototyp / Test-Stage**
— die Backend-Anbindung ist noch nicht implementiert, Antworten werden auf dem
ESP gemockt.

## Übersicht

```
Smartphone-App                ESP32 (Peripheral)              Lokales Backend
     │                              │                              │
     │── BLE Scan ─────────────────>│                              │
     │── BLE Connect ─────────────>│ (onConnect)                  │
     │── Write Request ───────────>│ (onWrite)                    │
     │                              │── (später) HTTP/WS ─────────>│
     │                              │<── (später) Result ─────────│
     │<── Notify Response ─────────│                              │
     │── BLE Disconnect ──────────>│ (onDisconnect → Adv restart) │
```

## GATT-Struktur

| Element              | UUID                                  | Bedeutung / Richtung                                |
|----------------------|---------------------------------------|-----------------------------------------------------|
| **Service**          | `5f6d4f5a-0001-0001-8000-00805f9b34fb` | DoorInterface-Befehlsservice                        |
| **Char. Request**    | `5f6d4f5a-0002-0001-8000-00805f9b34fb` | `WRITE` + `WRITE_NR` — Smartphone → ESP             |
| **Char. Response**   | `5f6d4f5a-0003-0001-8000-00805f9b34fb` | `NOTIFY` — ESP → Smartphone (Client muss subscriben) |

- **Encoding:** UTF-8 JSON, kein Längenpräfix, kein Chunking (max. MTU 128).
- **Keine Verschlüsselung / Pairing** im Prototyp — die Characteristic-Flags
  setzten nur `WRITE*` / `NOTIFY`, keine `*_ENC` / `*_AUTHEN`. Wird später für
  die produktive `credential`-Übertragung zwingend gebraucht.
- **Service im Advertising:** Die Service-UUID wird ins Advertising gepackt,
  die App kann also schon beim Scan prüfen, ohne verbinden zu müssen.
- **Advertising-Name:** = konfigurierter Hostname des ESP (z.B.
  `doorinterface-a1b2`). Default: `doorinterface-XXXX` (letzte 2 MAC-Bytes).

## Request-Format (Smartphone → ESP, Write auf Request-Characteristic)

```json
{
  "action": "test",
  "credential": "<freitext>",
  "deviceId": "<freitext>"
}
```

| Feld         | Typ   | Pflicht | Bedeutung                                                  |
|--------------|-------|---------|------------------------------------------------------------|
| `action`     | str   | ja      | `"test"` zum Verbindungstest, später `"open"` zum Türöffnen |
| `credential` | str   | nein*   | Zugangsdaten (im Prototyp beliebiger String)               |
| `deviceId`   | str   | nein    | Geräte-ID des Smartphones, nur fürs Logging / Echo        |

`*` Später Pflicht, sobald die Backend-Anbindung steht.

## Response-Format (ESP → Smartphone, Notify auf Response-Characteristic)

```json
{
  "success": true,
  "code": "TEST_OK",
  "message": "Test empfangen: pixel7"
}
```

| Feld      | Typ   | immer? | Bedeutung                                      |
|-----------|-------|--------|------------------------------------------------|
| `success` | bool  | ja     | Request insgesamt erfolgreich?                |
| `code`    | str   | ja     | Maschinenlesbarer Statuscode (s. Tabelle)     |
| `message` | str   | ja     | Menschnenlesbare Erklärung (kann leer sein)    |

### Status-Codes (Prototyp)

| `code`            | `success` | Bedeutung                                            |
|-------------------|-----------|------------------------------------------------------|
| `OK`              | true      | `action=open` akzeptiert (Mock-Türöffnung)           |
| `TEST_OK`         | true      | `action=test` empfangen, Echo mit `deviceId`         |
| `UNKNOWN_ACTION`  | false     | `action` fehlt oder wurde nicht erkannt              |

Später (mit Backend) erweitert um z.B. `BACKEND_UNREACHABLE`, `CRED_INVALID`,
`ACCESS_DENIED`, `LOCK_FAILED`.

## Ablauf einer Test-Session

1. App scannt BLE → findet Advertising mit `doorinterface-XXXX` + Service-UUID.
2. App verbindet → ESP loggt `[BLE] client connected`.
3. App subscribt auf Response-Characteristic (CCCD, Notify=0x0001).
4. App schreibt JSON auf Request-Characteristic, z.B.
   `{"action":"test","credential":"","deviceId":"pixel7"}`.
5. ESP extrahiert die Felder, loggt sie im Serial Monitor, erzeugt Response.
6. ESP sendet Notify auf Response-Characteristic mit dem Response-JSON.
7. App zeigt Response an (z.B. Toast / SnackBar: "Test empfangen: pixel7").
8. App trennt → ESP loggt `[BLE] client disconnected` und startet Advertising
   neu, damit der nächste Client andocken kann.

## Serial-Monitor-Ausgaben (ESP)

```
[BLE] init server
[BLE] advertising name='doorinterface-a1b2'
[BLE] client connected
[BLE] RX (52 bytes): {"action":"test","credential":"","deviceId":"pixel7"}
[BLE] parsed: action=test credential= deviceId=pixel7
[BLE] TX: {"success":true,"code":"TEST_OK","message":"Test empfangen: pixel7"}
[BLE] client disconnected
```

## QR-Code (geplant)

Statisch ausgedruckt. Inhalt (voreilend, noch nicht final):
```
doorinterface|<BLE_MAC>|<optional token>
```

- **Trennzeichen:** `|` (Pipe) — NICHT `:`, da die MAC selbst Colons enthält
  (`A4:CF:12:9D:71:E2`) und ein `:`-Split die MAC zerstören würde.
- **MAC-Format:** 6 Hex-Gruppen à 2 Stellen, getrennt durch `:` (canonical
  Bluetooth-Adresse). App validiert mit Regex
  `^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$`.
- **Token:** optional, freitextlich (darf `:` und `|` enthalten — Parser nimmt
  erster Pipe-Split, Rest joins als Token).

Beispiel-QR-Inhalt:
```
doorinterface|A4:CF:12:9D:71:E2|my-credential-token
```

Die App parst den QR, verbindet per BLE direkt an die MAC
(`BluetoothDevice.fromId`), sendet ggf. den Token als `credential` mit. Im
aktuellen Prototyp noch nicht implementiert — die App kann rein über den
Advertising-Namen finden.

## Open Questions / TODOs für die App-Seite

- [ ] Library-Wahl in der App (flutter_blue_plus? react-native-ble?).
- [ ] CCCD-Subscription explizit triggern bevor Write (sonst kein Notify).
- [ ] MTU-Verhandlung prüfen — wir setzen auf 128, Android defaultet 23.
- [ ] Timeouts: Write ohne Notify-Antwort nach z.B. 5s.
- [ ] Encoding von `credential` später (JWT? ephemeral token? hashed pin?).
- [ ] Wiederverbindung / Mehrfachversuch falls Advertising noch nicht läuft.

## Siehe auch

- Firmware-Modul: `src/BleServer.h` / `src/BleServer.cpp`
- Projekt-Handoff: `doorinterface/AGENTS.md` → Abschnitt „BleServer"