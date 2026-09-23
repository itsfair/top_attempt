#pragma once

#include <Arduino.h>
#include <NimBLEDevice.h>

class NukiManager;

class BleServer {
public:
    void begin(const String& deviceName, NukiManager* nuki);
    void loop();
    void sendResponse(const String& resp);
    String getAddress();
    void queueRequest(const String& action, const String& deviceId);
    bool openDoor(String& code, String& message);

private:
    NukiManager* _nuki = nullptr;
    String _pendingAction = "";
    String _pendingDeviceId = "";
};