#pragma once

#include <WiFi.h>
#include <WebServer.h>
#include <ESPmDNS.h>

class WifiManager;
class NukiManager;
class BleServer;
class Updater;

class WebInterface {
public:
    void begin(WifiManager& wifi, NukiManager& nuki, BleServer& ble, Updater& updater);
    void loop();
private:
    WebServer _server{80};
    WifiManager* _wifi = nullptr;
    NukiManager* _nuki = nullptr;
    BleServer* _ble = nullptr;
    Updater* _updater = nullptr;
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
<<<<<<< HEAD
    void handleNukiOpen();
    void handleNukiUnpair();
    void handleNukiPinGet();
    void handleNukiPinPost();
    void handleNukiPollGet();
    void handleNukiPollPost();
    void handleUpdateCheck();
    void handleUpdateStart();
    void handleUpdateProgress();
    void handleReboot();
=======
>>>>>>> 1d0e9c06369b58cb019c9a37ddc34579a58a15d4
    void handleNotFound();
};
