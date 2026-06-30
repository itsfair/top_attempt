#include "wifi_manager.h"
#include "config_manager.h"

static const char* TAG = "[WiFi]";

String WifiManager::buildAPSSID() {
    uint8_t mac[6];
    WiFi.macAddress(mac);
    char suffix[5];
    snprintf(suffix, sizeof(suffix), "%02X%02X", mac[4], mac[5]);
    return String("DoorInterface-") + suffix;
}

String WifiManager::getMACAddress() const {
    return WiFi.macAddress();
}

bool WifiManager::connectSTA(uint32_t timeoutMs) {
    String ssid = Config().getWifiSSID();
    String pass = Config().getWifiPassword();

    if (ssid.isEmpty()) {
        Serial.printf("%s No SSID configured\n", TAG);
        return false;
    }

    Serial.printf("%s Connecting to '%s'...\n", TAG, ssid.c_str());
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid.c_str(), pass.c_str());

    uint32_t start = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - start < timeoutMs) {
        delay(250);
        Serial.print(".");
    }
    Serial.println();

    if (WiFi.status() == WL_CONNECTED) {
        Serial.printf("%s Connected! IP: %s\n", TAG, WiFi.localIP().toString().c_str());
        return true;
    } else {
        Serial.printf("%s Connection failed (status=%d)\n", TAG, (int)WiFi.status());
        return false;
    }
}

void WifiManager::startAP() {
    _apSSID = buildAPSSID();
    WiFi.mode(WIFI_AP_STA); // AP+STA allows WiFi scanning while AP is running
    WiFi.softAP(_apSSID.c_str());
    Serial.printf("%s AP started: SSID='%s'  IP=%s\n",
                  TAG, _apSSID.c_str(), WiFi.softAPIP().toString().c_str());
}

void WifiManager::stopAP() {
    WiFi.softAPdisconnect(true);
    WiFi.mode(WIFI_STA);
    Serial.printf("%s AP stopped\n", TAG);
}

bool WifiManager::testCredentials(const String& ssid, const String& password,
                                   uint32_t timeoutMs) {
    Serial.printf("%s Testing credentials for '%s'...\n", TAG, ssid.c_str());

    // Connect in AP+STA mode — keeps AP alive while testing
    WiFi.begin(ssid.c_str(), password.c_str());

    uint32_t start = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - start < timeoutMs) {
        delay(250);
        Serial.print(".");
    }
    Serial.println();

    bool success = (WiFi.status() == WL_CONNECTED);
    if (success) {
        Serial.printf("%s Test successful — IP: %s\n",
                      TAG, WiFi.localIP().toString().c_str());
        // Don't disconnect — caller decides what to do next
    } else {
        Serial.printf("%s Test failed\n", TAG);
        WiFi.disconnect();
    }
    return success;
}

std::vector<WiFiNetwork> WifiManager::scan() {
    Serial.printf("%s Scanning...\n", TAG);
    std::vector<WiFiNetwork> networks;

    int n = WiFi.scanNetworks(false, true); // blocking, include hidden
    for (int i = 0; i < n; i++) {
        WiFiNetwork net;
        net.ssid = WiFi.SSID(i);
        net.rssi = WiFi.RSSI(i);
        net.open = (WiFi.encryptionType(i) == WIFI_AUTH_OPEN);
        networks.push_back(net);
    }
    WiFi.scanDelete();
    Serial.printf("%s Found %d networks\n", TAG, (int)networks.size());
    return networks;
}

bool WifiManager::startMDNS() {
    String hostname = Config().getDeviceName();
    if (!MDNS.begin(hostname.c_str())) {
        Serial.printf("%s mDNS failed\n", TAG);
        return false;
    }
    MDNS.addService("http", "tcp", 80);
    Serial.printf("%s mDNS: http://%s.local\n", TAG, hostname.c_str());
    return true;
}

bool WifiManager::reconnect(uint32_t timeoutMs) {
    if (isConnected()) return true;
    Serial.printf("%s Reconnecting...\n", TAG);
    WiFi.reconnect();
    uint32_t start = millis();
    while (!isConnected() && millis() - start < timeoutMs) {
        delay(250);
    }
    return isConnected();
}
