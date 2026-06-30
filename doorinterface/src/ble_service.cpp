#include "ble_service.h"
#include "config_manager.h"
#include "wifi_manager.h"
#include <ArduinoJson.h>

static const char* TAG = "[BLE]";

void BleService::begin(const String& deviceName) {
    Serial.printf("%s Initializing NimBLE as '%s'\n", TAG, deviceName.c_str());

    NimBLEDevice::init(deviceName.c_str());
    NimBLEDevice::setPower(ESP_PWR_LVL_P9); // max TX power

    _server = NimBLEDevice::createServer();
    _server->setCallbacks(this);

    // Create service
    NimBLEService* svc = _server->createService(SERVICE_UUID);

    // WiFi provision characteristic (write only)
    _chrWifiProv = svc->createCharacteristic(
        CHR_WIFI_PROV,
        NIMBLE_PROPERTY::WRITE
    );
    _chrWifiProv->setCallbacks(this);

    // Status characteristic (read + notify)
    _chrStatus = svc->createCharacteristic(
        CHR_STATUS,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
    );

    // Door control — Phase 2 stub (write only)
    _chrDoorCtrl = svc->createCharacteristic(
        CHR_DOOR_CTRL,
        NIMBLE_PROPERTY::WRITE
    );
    _chrDoorCtrl->setCallbacks(this);

    // Session token — Phase 2 stub (read + notify)
    _chrSessionTok = svc->createCharacteristic(
        CHR_SESSION_TOK,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
    );

    svc->start();

    // Set initial status value
    String statusJson = buildStatusJson();
    _chrStatus->setValue(statusJson.c_str());

    Serial.printf("%s Service started. Address: %s\n",
                  TAG, NimBLEDevice::getAddress().toString().c_str());
}

void BleService::startAdvertising() {
    NimBLEAdvertising* adv = NimBLEDevice::getAdvertising();
    adv->addServiceUUID(SERVICE_UUID);
    adv->setScanResponse(true);
    adv->start();
    Serial.printf("%s Advertising started\n", TAG);
}

void BleService::notifyStatus() {
    if (!_clientConnected || !_chrStatus) return;
    String json = buildStatusJson();
    _chrStatus->setValue(json.c_str());
    _chrStatus->notify();
}

bool BleService::isAdvertising() const {
    return NimBLEDevice::getAdvertising()->isAdvertising();
}

String BleService::getAddress() const {
    return String(NimBLEDevice::getAddress().toString().c_str());
}

// ---- NimBLE Callbacks ----

void BleService::onConnect(NimBLEServer* server) {
    _clientConnected = true;
    Serial.printf("%s Client connected\n", TAG);
    notifyStatus();
    // Restart advertising so another client can find us while one is connected
    NimBLEDevice::getAdvertising()->start();
}

void BleService::onDisconnect(NimBLEServer* server) {
    _clientConnected = false;
    Serial.printf("%s Client disconnected\n", TAG);
    NimBLEDevice::getAdvertising()->start();
}

void BleService::onWrite(NimBLECharacteristic* chr) {
    String uuid = String(chr->getUUID().toString().c_str());

    if (uuid.equalsIgnoreCase(CHR_WIFI_PROV)) {
        String value = chr->getValue().c_str();
        Serial.printf("%s WiFi provision received\n", TAG);
        handleWifiProvision(value);

    } else if (uuid.equalsIgnoreCase(CHR_DOOR_CTRL)) {
        // Phase 2: handle door control command
        Serial.printf("%s Door control received (Phase 2 — not yet implemented)\n", TAG);
    }
}

// ---- Private ----

void BleService::handleWifiProvision(const String& json) {
    JsonDocument doc;
    if (deserializeJson(doc, json) != DeserializationError::Ok) {
        Serial.printf("%s WiFi provision: invalid JSON\n", TAG);
        return;
    }

    String ssid = doc["ssid"] | "";
    String pass = doc["password"] | "";

    if (ssid.isEmpty()) {
        Serial.printf("%s WiFi provision: missing SSID\n", TAG);
        return;
    }

    Serial.printf("%s WiFi provision: SSID='%s'\n", TAG, ssid.c_str());
    Config().setWifi(ssid, pass);

    // Try to connect
    bool ok = Wifi().connectSTA(15000);

    // Notify result via status characteristic
    String result = ok
        ? "{\"event\":\"wifi_result\",\"success\":true,\"ip\":\"" + Wifi().getIP() + "\"}"
        : "{\"event\":\"wifi_result\",\"success\":false,\"error\":\"Connection failed\"}";
    _chrStatus->setValue(result.c_str());
    if (_clientConnected) _chrStatus->notify();

    if (ok) {
        Config().setConfigured(true);
        Serial.printf("%s WiFi provisioned — rebooting in 3s\n", TAG);
        delay(3000);
        ESP.restart();
    }
}

String BleService::buildStatusJson() {
    JsonDocument doc;
    doc["hw"]   = Config().getHardwareType() == HardwareType::NUKI ? "nuki" :
                  Config().getHardwareType() == HardwareType::RELAY ? "relay" : "none";
    doc["door"] = "unknown"; // real state filled in by main.cpp
    doc["wifi"] = Wifi().isConnected();
    doc["ip"]   = Wifi().isConnected() ? Wifi().getIP() : "";

    String out;
    serializeJson(doc, out);
    return out;
}
