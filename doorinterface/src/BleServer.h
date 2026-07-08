#pragma once

#include <Arduino.h>
#include <NimBLEDevice.h>

class BleServer {
public:
    void begin(const String& deviceName);
    void loop();
    void sendResponse(const String& resp);
    String getAddress();
};