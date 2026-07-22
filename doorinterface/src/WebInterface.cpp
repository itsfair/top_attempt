#include "WebInterface.h"
#include "WifiManager.h"
#include "NukiManager.h"
#include "BleServer.h"
#include "Updater.h"
#include "web/main_html.h"
#include "web/main_css.h"
#include "web/main_js.h"
#include "web/setup_html.h"
#include "web/setup_js.h"
#include "web/display_html.h"
#include "web/display_js.h"
#include "web/qr_js.h"
#include "config.h"

void WebInterface::begin(WifiManager& wifi, NukiManager& nuki, BleServer& ble, Updater& updater) {
    _wifi = &wifi;
    _nuki = &nuki;
    _ble = &ble;
    _updater = &updater;
    String hostname = _wifi->getHostname();
    if (MDNS.begin(hostname.c_str())) MDNS.addService("http", "tcp", 80);
    _server.on("/",             HTTP_GET,  [this](){ handleRoot();        });
    _server.on("/main.css",     HTTP_GET,  [this](){ handleCss();         });
    _server.on("/main.js",      HTTP_GET,  [this](){ handleJs();          });
    _server.on("/setup",        HTTP_GET,  [this](){ handleSetup();       });
    _server.on("/setup.js",     HTTP_GET,  [this](){ handleSetupJs();     });
    _server.on("/display",      HTTP_GET,  [this](){ handleDisplay();     });
    _server.on("/display.js",   HTTP_GET,  [this](){ handleDisplayJs();   });
    _server.on("/qr.js",        HTTP_GET,  [this](){ handleQrJs();        });
    _server.on("/api/status",   HTTP_GET,  [this](){ handleStatus();      });
    _server.on("/api/ble/info", HTTP_GET,  [this](){ handleBleInfo();     });
    _server.on("/api/hostname", HTTP_GET,  [this](){ handleHostnameGet(); });
    _server.on("/api/hostname", HTTP_POST, [this](){ handleHostnamePost();});
    _server.on("/api/nuki/pair",   HTTP_POST, [this](){ handleNukiPair();   });
    _server.on("/api/nuki/cancel", HTTP_POST, [this](){ handleNukiCancel(); });
    _server.on("/api/nuki/unlock", HTTP_POST, [this](){ handleNukiUnlock(); });
    _server.on("/api/nuki/lock",   HTTP_POST, [this](){ handleNukiLock();   });
    _server.on("/api/nuki/open",   HTTP_POST, [this](){ handleNukiOpen();   });
    _server.on("/api/nuki/unpair", HTTP_POST, [this](){ handleNukiUnpair(); });
    _server.on("/api/nuki/pin", HTTP_GET,  [this](){ handleNukiPinGet();  });
    _server.on("/api/nuki/pin", HTTP_POST, [this](){ handleNukiPinPost(); });
    _server.on("/api/nuki/poll", HTTP_GET,  [this](){ handleNukiPollGet(); });
    _server.on("/api/nuki/poll", HTTP_POST, [this](){ handleNukiPollPost(); });
    _server.on("/api/update/check",   HTTP_POST, [this](){ handleUpdateCheck(); });
    _server.on("/api/update/start",   HTTP_POST, [this](){ handleUpdateStart(); });
    _server.on("/api/update/progress",HTTP_GET,  [this](){ handleUpdateProgress(); });
    _server.on("/api/reboot",         HTTP_POST, [this](){ handleReboot(); });
    _server.onNotFound(                     [this](){ handleNotFound();   });
    _server.begin();
    Serial.printf("[HTTP] Hauptseite bereit (%s.local)\n", hostname.c_str());
}

void WebInterface::loop() {
    if (_restartRequested && millis() >= _restartAt) {
        Serial.println("[HTTP] Neustart (Hostname geaendert)");
        delay(100);
        ESP.restart();
    }
    _server.handleClient();
}

void WebInterface::handleRoot() {
    _server.sendHeader("Cache-Control", "no-store");
    _server.send_P(200, "text/html", MAIN_HTML);
}
void WebInterface::handleCss() {
    _server.sendHeader("Cache-Control", "no-store");
    _server.send_P(200, "text/css", MAIN_CSS);
}
void WebInterface::handleJs() {
    _server.sendHeader("Cache-Control", "no-store");
    _server.send_P(200, "application/javascript", MAIN_JS);
}
void WebInterface::handleSetup() {
    _server.sendHeader("Cache-Control", "no-store");
    _server.send_P(200, "text/html", SETUP_HTML);
}
void WebInterface::handleSetupJs() {
    _server.sendHeader("Cache-Control", "no-store");
    _server.send_P(200, "application/javascript", SETUP_JS);
}
void WebInterface::handleDisplay() {
    _server.sendHeader("Cache-Control", "no-store");
    _server.send_P(200, "text/html", DISPLAY_HTML);
}
void WebInterface::handleDisplayJs() {
    _server.sendHeader("Cache-Control", "no-store");
    _server.send_P(200, "application/javascript", DISPLAY_JS);
}
void WebInterface::handleQrJs() {
    _server.sendHeader("Cache-Control", "no-store");
    _server.send_P(200, "application/javascript", QR_JS);
}
void WebInterface::handleReboot() {
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", "{\"ok\":true}");
    Serial.println("[HTTP] Neustart angefordert");
    delay(500);
    ESP.restart();
}
void WebInterface::handleUpdateCheck() {
    if (!_updater) { _server.send(500, "application/json", "{\"error\":\"no updater\"}"); return; }
    _updater->checkForUpdate();
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", "{\"started\":true}");
}
void WebInterface::handleUpdateStart() {
    if (!_updater) { _server.send(500, "application/json", "{\"error\":\"no updater\"}"); return; }
    _updater->startUpdate();
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", "{\"started\":true}");
}
void WebInterface::handleUpdateProgress() {
    if (!_updater) { _server.send(500, "application/json", "{\"error\":\"no updater\"}"); return; }
    String json = _updater->getStatusJson();
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", json);
}
void WebInterface::handleNotFound() {
    _server.send(404, "text/plain", "Not found");
}
void WebInterface::handleStatus() {
    bool connected = WiFi.status() == WL_CONNECTED;
    String json = "{";
    json += "\"wifi\":{\"connected\":" + String(connected ? "true" : "false");
    json += ",\"ssid\":\"" + WiFi.SSID() + "\"";
    json += ",\"rssi\":" + String(WiFi.RSSI());
    json += ",\"ip\":\"" + WiFi.localIP().toString() + "\"}";
    json += ",\"relay\":{\"available\":false}";
    bool paired = _nuki->isPaired();
    json += ",\"locks\":{\"available\":" + String(paired ? "true" : "false");
    json += ",\"count\":" + String(paired ? "1" : "0");
    json += ",\"paired\":" + String(paired ? "true" : "false");
    json += ",\"pairing\":" + String(_nuki->isPairing() ? "true" : "false");
    json += ",\"hasUltraPin\":" + String(_nuki->hasUltraPin() ? "true" : "false");
    json += ",\"pollInterval\":" + String((int)_nuki->getPollInterval());
    if (paired) {
        json += ",\"lockState\":\"" + _nuki->getLockStateStr() + "\"";
        json += ",\"batteryPct\":" + String(_nuki->getBatteryPct());
        json += ",\"batteryCritical\":" + String(_nuki->isBatteryCritical() ? "true" : "false");
        json += ",\"rssi\":" + String(_nuki->getRssi());
    }
    json += "}";
    json += ",\"firmware\":{\"version\":\"" FW_VERSION "\"}";
    String mac = _ble ? _ble->getAddress() : String("");
    String hostname = _wifi ? _wifi->getHostname() : String("");
    json += ",\"ble\":{\"available\":" + String(_ble ? "true" : "false");
    json += ",\"mac\":\"" + mac + "\"";
    json += ",\"hostname\":\"" + hostname + "\"";
    json += ",\"qrContent\":\"doorinterface|" + mac + "|\"";
    json += "}";
    json += "}";
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", json);
}
void WebInterface::handleBleInfo() {
    String mac = _ble ? _ble->getAddress() : String("");
    String hostname = _wifi ? _wifi->getHostname() : String("");
    String qr = "doorinterface|" + mac + "|";
    String json = "{";
    json += "\"mac\":\"" + mac + "\"";
    json += ",\"hostname\":\"" + hostname + "\"";
    json += ",\"qrContent\":\"" + qr + "\"";
    json += "}";
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", json);
}
void WebInterface::handleHostnameGet() {
    String json = "{\"hostname\":\"" + _wifi->getHostname() + "\"}";
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", json);
}
void WebInterface::handleHostnamePost() {
    String hostname = _server.arg("hostname");
    if (_wifi->setHostname(hostname)) {
        _server.sendHeader("Cache-Control", "no-store");
        _server.send(200, "application/json", "{\"ok\":true}");
        _restartRequested = true;
        _restartAt = millis() + 1000;
    } else {
        _server.send(400, "application/json", "{\"error\":\"ungueltiger Hostname\"}");
    }
}
void WebInterface::handleNukiPair() {
    if (_nuki->isPaired()) {
        _server.send(200, "application/json", "{\"status\":\"already_paired\"}");
        return;
    }
    _nuki->startPairing();
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", "{\"status\":\"pairing\"}");
}
void WebInterface::handleNukiCancel() {
    _nuki->cancelPairing();
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", "{\"status\":\"cancelled\"}");
}
void WebInterface::handleNukiUnlock() {
    if (!_nuki->isPaired()) {
        _server.send(409, "application/json", "{\"ok\":false,\"error\":\"not_paired\"}");
        return;
    }
    bool ok = _nuki->unlock();
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", ok ? "{\"ok\":true}" : "{\"ok\":false,\"error\":\"failed\"}");
}
void WebInterface::handleNukiLock() {
    if (!_nuki->isPaired()) {
        _server.send(409, "application/json", "{\"ok\":false,\"error\":\"not_paired\"}");
        return;
    }
    bool ok = _nuki->lock();
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", ok ? "{\"ok\":true}" : "{\"ok\":false,\"error\":\"failed\"}");
}
void WebInterface::handleNukiOpen() {
    if (!_nuki->isPaired()) {
        _server.send(409, "application/json", "{\"ok\":false,\"error\":\"not_paired\"}");
        return;
    }
    bool ok = _nuki->unlatch();
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", ok ? "{\"ok\":true}" : "{\"ok\":false,\"error\":\"failed\"}");
}
void WebInterface::handleNukiUnpair() {
    if (!_nuki->isPaired()) {
        _server.send(409, "application/json", "{\"ok\":false,\"error\":\"not_paired\"}");
        return;
    }
    bool ok = _nuki->unpair();
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", ok ? "{\"ok\":true}" : "{\"ok\":false,\"error\":\"failed\"}");
}
void WebInterface::handleNukiPinGet() {
    String json = "{\"hasPin\":" + String(_nuki->hasUltraPin() ? "true" : "false") + "}";
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", json);
}
void WebInterface::handleNukiPinPost() {
    String pinStr = _server.arg("pin");
    if (pinStr.length() != 6) {
        _server.send(400, "application/json", "{\"ok\":false,\"error\":\"PIN muss 6 Ziffern sein\"}");
        return;
    }
    for (size_t i = 0; i < pinStr.length(); i++) {
        if (!isDigit(pinStr.charAt(i))) {
            _server.send(400, "application/json", "{\"ok\":false,\"error\":\"PIN darf nur Ziffern enthalten\"}");
            return;
        }
    }
    uint32_t pin = (uint32_t)strtoul(pinStr.c_str(), nullptr, 10);
    _nuki->setUltraPin(pin);
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", "{\"ok\":true}");
}
void WebInterface::handleNukiPollGet() {
    String json = "{\"interval\":" + String(_nuki->getPollInterval()) + "}";
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", json);
}
void WebInterface::handleNukiPollPost() {
    String val = _server.arg("interval");
    int interval = val.toInt();
    if (interval < 10 || interval > 3600) {
        _server.send(400, "application/json", "{\"ok\":false,\"error\":\"Intervall muss 10-3600 Sekunden sein\"}");
        return;
    }
    _nuki->setPollInterval((uint16_t)interval);
    _server.sendHeader("Cache-Control", "no-store");
    _server.send(200, "application/json", "{\"ok\":true}");
}