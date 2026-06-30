#include <Arduino.h>
#include <esp_log.h>

#include "config_manager.h"
#include "wifi_manager.h"
#include "captive_portal.h"
#include "http_api.h"
#include "ble_service.h"
#include "serial_console.h"
#include "hardware/nuki_driver.h"
#include "update_manager.h"

// ============================================================
//  Device state machine
// ============================================================
enum class DeviceState {
    BOOTING,
    SETUP_MODE,      // AP + Captive Portal — awaiting WiFi configuration
    CONNECTING,      // STA — trying to connect to WiFi
    OPERATIONAL,     // Connected, HTTP API running
    AP_FALLBACK      // WiFi connection failed — AP with error hint
};

static DeviceState gState = DeviceState::BOOTING;
static NukiDriver* gNuki  = nullptr;

// ============================================================
//  Forward declarations
// ============================================================
static void startSetupMode();
static void startOperationalMode();
static void wifiReconnectTask(void* param);
static void nukiUpdateTask(void* param);

// ============================================================
//  setup()
// ============================================================
void setup() {
    Serial.begin(115200);
    delay(300);

    // Suppress NimBLE scan advertisement info logs that flood the console.
    esp_log_level_set("NimBLEScan", ESP_LOG_WARN);

    Serial.println("\n========================================");
    Serial.println("  DoorInterface Firmware v1.0.0");
    Serial.println("========================================\n");

    // 1. Load persistent configuration
    Config().begin();

    // 2. Initialize BLE (NimBLE init must happen once, before any BLE use)
    BleService::instance().begin(Config().getDeviceName());
    BleService::instance().startAdvertising();

    // 3. Start serial console
    Console().begin(nullptr);

    // 4. Decide boot path
    if (Config().getWifiSSID().isEmpty() || !Config().isConfigured()) {
        Serial.println("[Main] No WiFi configured — starting Setup Wizard");
        gState = DeviceState::SETUP_MODE;
        startSetupMode();
    } else {
        gState = DeviceState::CONNECTING;
        Serial.println("[Main] Configuration found — connecting to WiFi");

        bool connected = Wifi().connectSTA(15000);

        if (connected) {
            Wifi().startMDNS();
            gState = DeviceState::OPERATIONAL;
            Serial.printf("[Main] WiFi connected. Starting operational mode.\n");
            startOperationalMode();
        } else {
            Serial.println("[Main] WiFi connection failed — falling back to AP mode");
            gState = DeviceState::AP_FALLBACK;
            startSetupMode();
        }
    }
}

// ============================================================
//  loop()
// ============================================================
void loop() {
    if (gState == DeviceState::SETUP_MODE || gState == DeviceState::AP_FALLBACK) {
        Portal().process();
    }

    if (gState == DeviceState::OPERATIONAL) {
        Api().process();
        Update().tick();
    }

    // Notify BLE clients with updated status every 5 seconds
    static uint32_t lastBleNotify = 0;
    if (millis() - lastBleNotify > 5000) {
        lastBleNotify = millis();
        BleService::instance().notifyStatus();
    }

    delay(10);
}

// ============================================================
//  Setup mode (Captive Portal)
// ============================================================
static void startSetupMode() {
    Wifi().startAP();
    delay(500);
    Portal().begin();

    if (gState == DeviceState::AP_FALLBACK) {
        Serial.println("[Main] AP Fallback: connect to WiFi AP and reconfigure");
        Serial.printf("[Main] SSID: %s\n", Wifi().getAPSSID().c_str());
    } else {
        Serial.printf("[Main] Setup mode: connect to '%s' and open http://192.168.4.1\n",
                      Wifi().getAPSSID().c_str());
    }
}

// ============================================================
//  Operational mode
// ============================================================
static void startOperationalMode() {
    // Always create NUKI driver — even if not paired yet
    gNuki = new NukiDriver();
    if (!gNuki->begin()) {
        Serial.println("[Main] NUKI driver init failed");
    }

    Api().begin(gNuki);
    Console().setHardware(gNuki);

    // WiFi reconnect watchdog task
    xTaskCreatePinnedToCore(wifiReconnectTask, "wifi_watchdog", 3072, nullptr, 1, nullptr, 0);

    // NUKI update task (processes BLE events)
    xTaskCreatePinnedToCore(nukiUpdateTask, "nuki_update", 3072, gNuki, 2, nullptr, 0);

    // OTA tick task (pending-verify watchdog + periodic auto-check)
    xTaskCreatePinnedToCore([](void*){
        for (;;) {
            Update().tick();
            vTaskDelay(1000 / portTICK_PERIOD_MS);
        }
    }, "ota_tick", 4096, nullptr, 1, nullptr, 0);

    Serial.println("[Main] Operational — ready");
    Serial.printf("[Main] Web UI: http://%s.local  or  http://%s\n",
                  Config().getDeviceName().c_str(), Wifi().getIP().c_str());
}

// ============================================================
//  FreeRTOS Tasks
// ============================================================

static void wifiReconnectTask(void* /*param*/) {
    int failCount = 0;
    for (;;) {
        vTaskDelay(10000 / portTICK_PERIOD_MS); // check every 10s

        if (Wifi().isConnected()) {
            failCount = 0;
            continue;
        }

        failCount++;
        Serial.printf("[WiFi] Connection lost (failCount=%d) — reconnecting...\n", failCount);

        // After 3 failed attempts -> fall back to AP/setup mode
        if (failCount >= 3) {
            Serial.println("[WiFi] Too many reconnect failures — switching to AP fallback");
            Config().setConfigured(false);
            delay(500);
            ESP.restart();
        }

        Wifi().reconnect(15000);
        if (Wifi().isConnected()) {
            Serial.printf("[WiFi] Reconnected: %s\n", Wifi().getIP().c_str());
        } else {
            Serial.println("[WiFi] Reconnect failed");
        }
    }
}

static void nukiUpdateTask(void* param) {
    NukiDriver* nuki = static_cast<NukiDriver*>(param);
    for (;;) {
        nuki->update();
        vTaskDelay(100 / portTICK_PERIOD_MS);
    }
}
