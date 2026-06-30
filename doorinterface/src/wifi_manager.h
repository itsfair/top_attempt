#pragma once

#include <Arduino.h>
#include <WiFi.h>
#include <ESPmDNS.h>
#include <vector>

struct WiFiNetwork {
    String ssid;
    int    rssi;
    bool   open; // true = no password required
};

class WifiManager {
public:
    static WifiManager& instance() {
        static WifiManager inst;
        return inst;
    }

    // Start in Station mode and connect to stored credentials.
    // Returns true if connected within timeoutMs.
    bool connectSTA(uint32_t timeoutMs = 15000);

    // Start as Access Point.
    // SSID will be "DoorInterface-XXXX" using last 4 MAC digits.
    void startAP();

    // Stop the Access Point.
    void stopAP();

    // Test a specific SSID/password without saving.
    // Temporarily connects in AP+STA mode, then disconnects.
    // Returns true if credentials are valid.
    bool testCredentials(const String& ssid, const String& password,
                         uint32_t timeoutMs = 10000);

    // Scan for available networks (blocking).
    std::vector<WiFiNetwork> scan();

    // Start mDNS responder with the configured device name.
    bool startMDNS();

    // Reconnect if connection was lost.
    bool reconnect(uint32_t timeoutMs = 10000);

    bool isConnected() const { return WiFi.status() == WL_CONNECTED; }
    String getIP()     const { return WiFi.localIP().toString(); }
    String getSSID()   const { return WiFi.SSID(); }
    int    getRSSI()   const { return WiFi.RSSI(); }
    String getAPSSID() const { return _apSSID; }
    String getMACAddress() const;

private:
    WifiManager() = default;
    WifiManager(const WifiManager&) = delete;
    WifiManager& operator=(const WifiManager&) = delete;

    String buildAPSSID();

    String _apSSID;
};

inline WifiManager& Wifi() { return WifiManager::instance(); }
