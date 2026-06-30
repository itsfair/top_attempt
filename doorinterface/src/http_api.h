#pragma once

#include <Arduino.h>
#include <ESPAsyncWebServer.h>
#include "hardware/nuki_driver.h"

// Operational HTTP API server (runs when WiFi is connected).
// Minimal version: dashboard + NUKI pairing only.
class HttpApi {
public:
    static HttpApi& instance() {
        static HttpApi inst;
        return inst;
    }

    void begin(NukiDriver* nuki);

    // Call frequently from loop() — handles scheduled reboot.
    void process();

private:
    HttpApi();
    HttpApi(const HttpApi&) = delete;
    HttpApi& operator=(const HttpApi&) = delete;

    void setupRoutes();

    // Pages
    void handleIndex(AsyncWebServerRequest* req);
    void handleSettingsPage(AsyncWebServerRequest* req);

    // JSON API
    void handleStatus(AsyncWebServerRequest* req);
    void handleOpen(AsyncWebServerRequest* req);
    void handleClose(AsyncWebServerRequest* req);

    // NUKI setup
    void handleNukiScanStart(AsyncWebServerRequest* req);
    void handleNukiScanResult(AsyncWebServerRequest* req);
    void handleNukiPairStart(AsyncWebServerRequest* req, uint8_t* data, size_t len);
    void handleNukiPairStatus(AsyncWebServerRequest* req);
    void handleNukiForget(AsyncWebServerRequest* req);

    // System
    void handleResetWifi(AsyncWebServerRequest* req);
    void handleReboot(AsyncWebServerRequest* req);

    static void sendJson(AsyncWebServerRequest* req, int code, const String& json);
    static String doorStateStr(DoorState s);

    AsyncWebServer _server;
    NukiDriver*    _nuki;
    uint32_t       _rebootAt;

    static const char* INDEX_HTML;
    static const char* SETTINGS_HTML;
};

inline HttpApi& Api() { return HttpApi::instance(); }
