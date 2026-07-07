#include <Arduino.h>
#include "WifiManager.h"
#include "WebInterface.h"
#include "NukiManager.h"
#include "config.h"

WifiManager wifi;
WebInterface web;
NukiManager nuki;
bool nukiStarted = false;
bool webStarted = false;

void setup() {
    Serial.begin(115200);
    wifi.begin();
}

void loop() {
    wifi.loop();
    if (!nukiStarted && wifi.isConnected() && !wifi.isApActive()) {
        nuki.begin();
        nukiStarted = true;
    }
    if (nukiStarted) nuki.loop();
    if (!webStarted && wifi.isConnected() && !wifi.isApActive()) {
        web.begin(wifi, nuki);
        webStarted = true;
    }
    if (webStarted) web.loop();
}