#include "BleServer.h"

#define SERVICE_UUID        "5f6d4f5a-0001-0001-8000-00805f9b34fb"
#define CHAR_REQUEST_UUID   "5f6d4f5a-0002-0001-8000-00805f9b34fb"
#define CHAR_RESPONSE_UUID  "5f6d4f5a-0003-0001-8000-00805f9b34fb"

static String extractField(const String& json, const String& key) {
    String needle = "\"" + key + "\"";
    int k = json.indexOf(needle);
    if (k < 0) return "";
    int c = json.indexOf(':', k);
    if (c < 0) return "";
    c = json.indexOf('"', c);
    if (c < 0) return "";
    int end = json.indexOf('"', c + 1);
    if (end < 0) return "";
    return json.substring(c + 1, end);
}

class ServerCallbacks : public NimBLEServerCallbacks {
    void onConnect(NimBLEServer*) override {
        Serial.println("[BLE] client connected");
    }
    void onDisconnect(NimBLEServer*) override {
        Serial.println("[BLE] client disconnected");
        NimBLEDevice::getAdvertising()->start();
    }
};

class RequestCallbacks : public NimBLECharacteristicCallbacks {
    BleServer* _owner;
public:
    RequestCallbacks(BleServer* o) : _owner(o) {}
    void onWrite(NimBLECharacteristic* pChar) override {
        std::string val = pChar->getValue();
        String payload = String(val.c_str());
        Serial.printf("[BLE] RX (%d bytes): %s\n", (int)val.size(), payload.c_str());

        String action     = extractField(payload, "action");
        String credential = extractField(payload, "credential");
        String deviceId   = extractField(payload, "deviceId");
        Serial.printf("[BLE] parsed: action=%s credential=%s deviceId=%s\n",
            action.c_str(), credential.c_str(), deviceId.c_str());

        bool success = false;
        String code, message;
        if (action == "open") {
            success = true;  code = "OK";             message = "Tuer geoeffnet (mock)";
        } else if (action == "test") {
            success = true;  code = "TEST_OK";        message = "Test empfangen: " + deviceId;
        } else {
            success = false; code = "UNKNOWN_ACTION"; message = "Aktion unbekannt";
        }

        String resp = "{\"success\":";
        resp += success ? "true" : "false";
        resp += ",\"code\":\"" + code + "\"";
        resp += ",\"message\":\"" + message + "\"";
        resp += "}";
        Serial.printf("[BLE] TX: %s\n", resp.c_str());
        _owner->sendResponse(resp);
    }
};

void BleServer::begin(const String& deviceName) {
    Serial.println("[BLE] init server");
    NimBLEDevice::init(deviceName.c_str());
    NimBLEDevice::setMTU(128);

    NimBLEServer* server = NimBLEDevice::createServer();
    server->setCallbacks(new ServerCallbacks());

    NimBLEService* service = server->createService(SERVICE_UUID);
    NimBLECharacteristic* requestChar = service->createCharacteristic(
        CHAR_REQUEST_UUID, NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::WRITE_NR);
    requestChar->setCallbacks(new RequestCallbacks(this));
    NimBLECharacteristic* responseChar = service->createCharacteristic(
        CHAR_RESPONSE_UUID, NIMBLE_PROPERTY::NOTIFY);
    service->start();

    NimBLEAdvertising* adv = NimBLEDevice::getAdvertising();
    adv->addServiceUUID(SERVICE_UUID);
    adv->setScanResponse(true);
    adv->setMinInterval(0x20);
    adv->setMaxInterval(0x40);
    adv->start();
    Serial.printf("[BLE] advertising name='%s'\n", deviceName.c_str());
    Serial.printf("[BLE] mac=%s\n", getAddress().c_str());
}

String BleServer::getAddress() {
    return String(NimBLEDevice::getAddress().toString().c_str());
}

void BleServer::loop() {}

void BleServer::sendResponse(const String& resp) {
    NimBLECharacteristic* responseChar = NimBLEDevice::getServer()->getServiceByUUID(SERVICE_UUID)->getCharacteristic(CHAR_RESPONSE_UUID);
    if (responseChar && responseChar->getSubscribedCount() > 0) {
        responseChar->setValue(std::string(resp.c_str()));
        responseChar->notify();
    }
}