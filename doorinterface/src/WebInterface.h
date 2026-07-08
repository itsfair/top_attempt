#pragma once

#include <WiFi.h>
#include <WebServer.h>
#include <ESPmDNS.h>

class WifiManager;
class NukiManager;
class BleServer;

class WebInterface {
public:
    void begin(WifiManager& wifi, NukiManager& nuki, BleServer& ble);
    void loop();
private:
    WebServer _server{80};
    WifiManager* _wifi = nullptr;
    NukiManager* _nuki = nullptr;
    BleServer* _ble = nullptr;
    bool _restartRequested = false;
    unsigned long _restartAt = 0;
    void handleRoot();
    void handleCss();
    void handleJs();
    void handleSetup();
    void handleSetupJs();
    void handleDisplay();
    void handleDisplayJs();
    void handleQrJs();
    void handleStatus();
    void handleBleInfo();
    void handleHostnameGet();
    void handleHostnamePost();
    void handleNukiPair();
    void handleNukiCancel();
    void handleNukiUnlock();
    void handleNukiLock();
    void handleNotFound();
};
