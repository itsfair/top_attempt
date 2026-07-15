#include <Arduino.h>
#include "WifiManager.h"
#include "WebInterface.h"
#include "NukiManager.h"
#include "BleServer.h"
#include "config.h"

WifiManager wifi;
WebInterface web;
NukiManager nuki;
BleServer ble;
bool bleStarted = false;
bool nukiStarted = false;
bool webStarted = false;

void setup() {
    Serial.begin(115200);
    delay(3000);
    Serial.println("[BOOT] starte DoorInterface");
    wifi.begin();
}

void loop() {
    wifi.loop();
    if (!bleStarted && wifi.isConnected() && !wifi.isApActive()) {
        ble.begin(wifi.getHostname());
        bleStarted = true;
    }
    if (!nukiStarted && bleStarted) {
        nuki.begin();
        nukiStarted = true;
    }
    if (nukiStarted) nuki.loop();
    if (!webStarted && bleStarted) {
        web.begin(wifi, nuki, ble);
        webStarted = true;
    }
    if (webStarted) web.loop();
    if (bleStarted) ble.loop();
}