#pragma once

#include <Arduino.h>
#include <NimBLEDevice.h>
#include <NimBLEServer.h>
#include <NimBLECharacteristic.h>

// BLE GATT server — always active.
//
// Phase 1:
//   - WiFi provision (write SSID+password via BLE)
//   - Device status (read/notify)
//
// Phase 2 (stubs prepared):
//   - Door control (write open/close with session token)
//   - Session token (read/notify — for auth handshake)
//
// Service UUID:  4fafc201-1fb5-459e-8fcc-c5c9c331914b
class BleService : public NimBLEServerCallbacks,
                   public NimBLECharacteristicCallbacks {
public:
    static BleService& instance() {
        static BleService inst;
        return inst;
    }

    // Initialize BLE (NimBLEDevice::init must NOT be called before this).
    void begin(const String& deviceName);

    // Start advertising.
    void startAdvertising();

    // Notify connected clients with updated status JSON.
    void notifyStatus();

    bool isAdvertising() const;
    String getAddress() const;

    // NimBLE server callbacks
    void onConnect(NimBLEServer* server) override;
    void onDisconnect(NimBLEServer* server) override;

    // NimBLE characteristic callbacks
    void onWrite(NimBLECharacteristic* chr) override;

    // UUIDs (also used by main.cpp for QR code generation)
    static constexpr const char* SERVICE_UUID     = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
    static constexpr const char* CHR_WIFI_PROV    = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
    static constexpr const char* CHR_STATUS       = "beb5483e-36e1-4688-b7f5-ea07361b26a9";
    static constexpr const char* CHR_DOOR_CTRL    = "beb5483e-36e1-4688-b7f5-ea07361b26aa"; // Phase 2
    static constexpr const char* CHR_SESSION_TOK  = "beb5483e-36e1-4688-b7f5-ea07361b26ab"; // Phase 2

private:
    BleService() = default;
    BleService(const BleService&) = delete;
    BleService& operator=(const BleService&) = delete;

    void handleWifiProvision(const String& json);
    String buildStatusJson();

    NimBLEServer*         _server        = nullptr;
    NimBLECharacteristic* _chrWifiProv   = nullptr;
    NimBLECharacteristic* _chrStatus     = nullptr;
    NimBLECharacteristic* _chrDoorCtrl   = nullptr;
    NimBLECharacteristic* _chrSessionTok = nullptr;

    bool _clientConnected = false;
};
