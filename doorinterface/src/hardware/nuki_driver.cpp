#include "nuki_driver.h"
#include <NimBLEDevice.h>
#include <esp_mac.h>

// NUKI BLE service UUID — used to identify NUKI devices during scan
static const char* NUKI_SERVICE_UUID = "a92ee200-5501-11e4-916c-0800200c9a66";

NukiDriver::NukiDriver()
    : _nukiLock(nullptr),
      _scannerInitialized(false),
      _ready(false),
      _scannerActive(false),
      _scannerNeedUntil(0) {}

NukiDriver::~NukiDriver() {
    delete _nukiLock;
}

uint32_t NukiDriver::deviceIdFromMac() {
    uint8_t mac[6];
    esp_read_mac(mac, ESP_MAC_BT);
    return (uint32_t)mac[2] << 24 | (uint32_t)mac[3] << 16 |
           (uint32_t)mac[4] << 8  | (uint32_t)mac[5];
}

bool NukiDriver::begin() {
    Serial.printf("%s Initializing\n", TAG);

    // NimBLEDevice::init() must have been called before this (done in BleService::begin()).
    uint32_t devId = deviceIdFromMac();
    _nukiLock = new NukiLock::NukiLock("DoorInterface", devId);

    // BleScanner::Scanner::initialize() checks BLEDevice::getInitialized() internally,
    // so it will not re-initialize NimBLE if already done.
    _scanner.initialize();
    _scannerInitialized = true;
    _scanner.enableScanning(false); // keep scanner off until needed
    _scannerActive = false;

    _nukiLock->registerBleScanner(&_scanner);
    _nukiLock->initialize();

    if (_nukiLock->isPairedWithLock()) {
        _ready = true;
        Serial.printf("%s Ready (already paired)\n", TAG);
    } else {
        Serial.printf("%s Not paired yet — run 'nuki pair' or use setup wizard\n", TAG);
        _ready = false;
    }

    return true;
}

void NukiDriver::update() {
    if (_scannerInitialized) {
        _scanner.update();
    }
    updateScannerState();
}

void NukiDriver::markScannerNeeded() {
    _scannerNeedUntil = millis() + SCANNER_KEEPALIVE_MS;
    if (!_scannerActive) {
        _scanner.enableScanning(true);
        _scannerActive = true;
        Serial.printf("%s Scanner enabled\n", TAG);
    }
}

void NukiDriver::updateScannerState() {
    if (_scannerActive && millis() > _scannerNeedUntil) {
        _scanner.enableScanning(false);
        _scannerActive = false;
        Serial.printf("%s Scanner disabled\n", TAG);
    }
}

bool NukiDriver::isPaired() const {
    return _nukiLock && _nukiLock->isPairedWithLock();
}

// ---- Pairing ----

std::vector<NukiDevice> NukiDriver::scan(uint32_t scanDurationMs) {
    Serial.printf("%s Scanning for NUKI devices (%u ms)...\n", TAG, scanDurationMs);
    std::vector<NukiDevice> found;

    // Pause the BleScanner while we do a raw NimBLE scan to avoid conflicts.
    if (_scannerActive) {
        _scanner.enableScanning(false);
        _scannerActive = false;
    }

    // Use raw NimBLE scan for device discovery (synchronous, blocking)
    NimBLEScan* pScan = NimBLEDevice::getScan();
    pScan->stop();         // stop any ongoing scan
    pScan->clearResults();
    pScan->setActiveScan(true);
    pScan->setInterval(100);
    pScan->setWindow(80);

    NimBLEScanResults results = pScan->start(scanDurationMs / 1000, false);
    Serial.printf("%s Raw scan returned %d device(s)\n", TAG, results.getCount());

    for (int i = 0; i < results.getCount(); i++) {
        // getDevice() returns by value in this version of NimBLE
        NimBLEAdvertisedDevice dev = results.getDevice(i);
        String devName = dev.getName().c_str();
        String devAddr = dev.getAddress().toString().c_str();
        Serial.printf("%s Dev[%d]: '%s' [%s] RSSI=%d\n",
                      TAG, i, devName.c_str(), devAddr.c_str(), dev.getRSSI());

        // NUKI: name typically starts with "Nuki" — match by name (more reliable
        // than checking service UUID, which Nuki puts in scan response only).
        bool isNuki = devName.startsWith("Nuki") || devName.startsWith("nuki")
                   || dev.isAdvertisingService(NimBLEUUID(NUKI_SERVICE_UUID));

        if (isNuki) {
            NukiDevice nd;
            nd.name    = devName.isEmpty() ? "Nuki Smart Lock" : devName;
            nd.address = devAddr;
            nd.rssi    = dev.getRSSI();
            found.push_back(nd);
            Serial.printf("%s Matched: %s (%s) RSSI=%d\n",
                          TAG, nd.name.c_str(), nd.address.c_str(), nd.rssi);
        }
    }
    pScan->clearResults();

    if (found.empty()) {
        Serial.printf("%s No NUKI devices found\n", TAG);
    }
    return found;
}

bool NukiDriver::pair(const String& /*deviceAddress*/, uint32_t timeoutMs) {
    Serial.printf("%s Starting pairing (timeout %u ms)\n", TAG, timeoutMs);
    Serial.printf("%s Press and hold the button on the NUKI lock now...\n", TAG);

    markScannerNeeded();

    if (!_nukiLock) {
        // Called from setup wizard before begin() — initialize temporarily
        uint32_t devId = deviceIdFromMac();
        _nukiLock = new NukiLock::NukiLock("DoorInterface", devId);
        _scanner.initialize();
        _scannerInitialized = true;
        _nukiLock->registerBleScanner(&_scanner);
        _nukiLock->initialize();
    }

    uint32_t start = millis();
    Nuki::PairingResult result = Nuki::PairingResult::Timeout;

    while (millis() - start < timeoutMs) {
        markScannerNeeded(); // keep scanner alive during pairing
        result = _nukiLock->pairNuki();
        if (result == Nuki::PairingResult::Success) break;
        if (result != Nuki::PairingResult::Timeout &&
            result != Nuki::PairingResult::Pairing) break;
        _scanner.update();
        delay(50);
    }

    if (result == Nuki::PairingResult::Success) {
        _ready = true;
        Serial.printf("%s Pairing successful!\n", TAG);
        return true;
    } else {
        Serial.printf("%s Pairing failed (result=%d)\n", TAG, (int)result);
        return false;
    }
}

// ---- DoorHardware interface ----

bool NukiDriver::open(uint32_t /*durationMs*/) {
    return unlatch();
}

bool NukiDriver::close() {
    return lock();
}

DoorState NukiDriver::getState() {
    if (!_ready || !_nukiLock) return DoorState::UNKNOWN;

    markScannerNeeded();
    NukiLock::KeyTurnerState state;
    Nuki::CmdResult result = _nukiLock->requestKeyTurnerState(&state);
    if (result != Nuki::CmdResult::Success) return DoorState::UNKNOWN;

    switch (state.lockState) {
        case NukiLock::LockState::Locked:
        case NukiLock::LockState::Locking:
            return DoorState::CLOSED;
        case NukiLock::LockState::Unlocked:
        case NukiLock::LockState::Unlocking:
        case NukiLock::LockState::Unlatched:
        case NukiLock::LockState::Unlatching:
        case NukiLock::LockState::UnlockedLnga:  // "Lock 'n' Go" unlocked state
            return DoorState::OPEN;
        default:
            return DoorState::UNKNOWN;
    }
}

// ---- Direct action helpers ----

bool NukiDriver::unlock() {
    if (!_ready || !_nukiLock) { Serial.printf("%s Not ready\n", TAG); return false; }
    markScannerNeeded();
    Serial.printf("%s UNLOCK\n", TAG);
    Nuki::CmdResult r = _nukiLock->lockAction(NukiLock::LockAction::Unlock, 0, 0);
    Serial.printf("%s Result: %d\n", TAG, (int)r);
    return r == Nuki::CmdResult::Success;
}

bool NukiDriver::unlatch() {
    if (!_ready || !_nukiLock) { Serial.printf("%s Not ready\n", TAG); return false; }
    markScannerNeeded();
    Serial.printf("%s UNLATCH\n", TAG);
    Nuki::CmdResult r = _nukiLock->lockAction(NukiLock::LockAction::Unlatch, 0, 0);
    Serial.printf("%s Result: %d\n", TAG, (int)r);
    return r == Nuki::CmdResult::Success;
}

bool NukiDriver::lock() {
    if (!_ready || !_nukiLock) { Serial.printf("%s Not ready\n", TAG); return false; }
    markScannerNeeded();
    Serial.printf("%s LOCK\n", TAG);
    Nuki::CmdResult r = _nukiLock->lockAction(NukiLock::LockAction::Lock, 0, 0);
    Serial.printf("%s Result: %d\n", TAG, (int)r);
    return r == Nuki::CmdResult::Success;
}

bool NukiDriver::requestState(NukiLock::KeyTurnerState& outState) {
    if (!_ready || !_nukiLock) return false;
    markScannerNeeded();
    return _nukiLock->requestKeyTurnerState(&outState) == Nuki::CmdResult::Success;
}
