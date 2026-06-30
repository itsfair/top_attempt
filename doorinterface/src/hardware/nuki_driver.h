#pragma once

#include "door_hardware.h"
#include "../config_manager.h"
#include <NukiLock.h>
#include <BleScanner.h>
#include <vector>

struct NukiDevice {
    String name;
    String address; // BLE MAC
    int    rssi;
};

// Controls a NUKI Smart Lock via BLE (acting as BLE Central).
// Uses the NukiBleEsp32 library over NimBLE.
//
// NimBLE must be initialized (NimBLEDevice::init) before calling begin().
// Call update() periodically from the main loop or a dedicated task.
class NukiDriver : public DoorHardware {
public:
    NukiDriver();
    ~NukiDriver() override;

    bool begin() override;
    bool open(uint32_t durationMs = 0) override; // Sends UNLATCH action
    bool close() override;                        // Sends LOCK action
    DoorState getState() override;
    String getTypeName() override { return "nuki"; }
    bool isReady() override { return _ready; }

    // Must be called periodically (e.g. every 10ms) for BLE event processing.
    void update();

    // ---- Pairing ----
    // Scan for nearby NUKI devices. Blocks for scanDurationMs.
    std::vector<NukiDevice> scan(uint32_t scanDurationMs = 5000);

    // Initiate pairing. The user must press the button on the NUKI lock.
    // Blocks until pairing succeeds or timeoutMs elapses.
    // Returns true on success.
    bool pair(const String& deviceAddress, uint32_t timeoutMs = 30000);

    bool isPaired() const;

    // ---- Direct actions (for serial console testing) ----
    bool unlock();
    bool unlatch();
    bool lock();
    bool requestState(NukiLock::KeyTurnerState& outState);

private:
    uint32_t deviceIdFromMac();
    void markScannerNeeded();
    void updateScannerState();

    BleScanner::Scanner  _scanner;
    NukiLock::NukiLock*  _nukiLock; // heap-allocated after NimBLE init
    bool                 _scannerInitialized;
    bool                 _ready;
    bool                 _scannerActive;
    uint32_t             _scannerNeedUntil;

    static constexpr const char* TAG = "[NUKI]";
    static constexpr uint32_t SCANNER_KEEPALIVE_MS = 8000;
};
