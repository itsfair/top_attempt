#pragma once

#include <Arduino.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <DNSServer.h>

// First-time setup wizard — WiFi configuration ONLY.
// Runs in AP mode with a captive portal. Once WiFi is configured and
// verified, the device reboots into operational mode. NUKI pairing is
// configured afterwards via the operational web UI (/settings).
//
// AP SSID:  DoorInterface-XXXX
// AP IP:    192.168.4.1
class CaptivePortal {
public:
    static CaptivePortal& instance() {
        static CaptivePortal inst;
        return inst;
    }

    // Start the captive portal. Call after the WiFi AP is up.
    void begin();

    // Call frequently from loop(). Handles:
    //  - DNS captive-portal redirect
    //  - deferred WiFi scan completion
    //  - non-blocking WiFi connect test
    //  - scheduled reboot after successful save
    void process();

    bool isSaved() const { return _saved; }

private:
    CaptivePortal();
    CaptivePortal(const CaptivePortal&) = delete;
    CaptivePortal& operator=(const CaptivePortal&) = delete;

    void setupRoutes();

    // Route handlers
    void handleRoot(AsyncWebServerRequest* req);
    void handleSetupPage(AsyncWebServerRequest* req);
    void handleScanStart(AsyncWebServerRequest* req);    // POST /scan/start
    void handleScanResult(AsyncWebServerRequest* req);   // GET  /scan/result
    void handleConnect(AsyncWebServerRequest* req,
                       uint8_t* data, size_t len);       // POST /connect
    void handleConnectStatus(AsyncWebServerRequest* req); // GET  /connect/status

    static void sendNoCacheJson(AsyncWebServerRequest* req,
                                int code, const String& json);

    AsyncWebServer _server;
    DNSServer      _dns;
    bool           _saved;

    static const char* SETUP_HTML;
};

inline CaptivePortal& Portal() { return CaptivePortal::instance(); }
