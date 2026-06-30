#include "serial_console.h"
#include "config_manager.h"
#include "wifi_manager.h"
#include "ble_service.h"
#include "hardware/nuki_driver.h"
#include <esp_timer.h>

static const char* TAG = "[Console]";

void SerialConsole::begin(DoorHardware* hardware) {
    _hardware = hardware;
    xTaskCreatePinnedToCore(task, "serial_console", 4096, this, 1, nullptr, 1);
    Serial.printf("%s Ready. Type 'help' for commands.\n", TAG);
}

void SerialConsole::task(void* param) {
    SerialConsole* self = static_cast<SerialConsole*>(param);
    String line;
    line.reserve(128);

    for (;;) {
        while (Serial.available()) {
            char c = (char)Serial.read();
            if (c == '\n' || c == '\r') {
                line.trim();
                if (!line.isEmpty()) {
                    self->processLine(line);
                    line = "";
                }
            } else {
                line += c;
            }
        }
        vTaskDelay(20 / portTICK_PERIOD_MS);
    }
}

void SerialConsole::processLine(const String& line) {
    int spaceIdx = line.indexOf(' ');
    String cmd  = spaceIdx >= 0 ? line.substring(0, spaceIdx) : line;
    String args = spaceIdx >= 0 ? line.substring(spaceIdx + 1) : "";
    cmd.toLowerCase();
    args.trim();

    if      (cmd == "status") cmdStatus();
    else if (cmd == "open")   cmdOpen(args);
    else if (cmd == "close")  cmdClose();
    else if (cmd == "config") cmdConfig(args);
    else if (cmd == "ble")    cmdBle(args);
    else if (cmd == "nuki")   cmdNuki(args);
    else if (cmd == "setup")  cmdSetup();
    else if (cmd == "reboot") cmdReboot();
    else if (cmd == "help")   cmdHelp();
    else Serial.printf("[Console] Unknown command: '%s'. Type 'help'.\n", cmd.c_str());
}

void SerialConsole::printSeparator() {
    Serial.println("----------------------------------------");
}

void SerialConsole::cmdStatus() {
    printSeparator();
    Serial.printf("Device:    %s\n", Config().getDeviceName().c_str());
    Serial.printf("Uptime:    %llu s\n", esp_timer_get_time() / 1000000ULL);
    Serial.println();
    Serial.printf("WiFi:      %s\n", Wifi().isConnected() ? "Connected" : "Disconnected");
    if (Wifi().isConnected()) {
        Serial.printf("  SSID:    %s\n", Wifi().getSSID().c_str());
        Serial.printf("  IP:      %s\n", Wifi().getIP().c_str());
        Serial.printf("  RSSI:    %d dBm\n", Wifi().getRSSI());
    }
    Serial.println();
    NukiDriver* nuki = static_cast<NukiDriver*>(_hardware);
    Serial.printf("NUKI:      %s\n", (nuki && nuki->isPaired()) ? "Paired" : "Not paired");
    if (nuki && nuki->isPaired()) {
        DoorState s = nuki->getState();
        Serial.printf("  State:   %s\n",
                      s == DoorState::OPEN ? "OPEN" :
                      s == DoorState::CLOSED ? "CLOSED" : "UNKNOWN");
    }
    Serial.println();
    Serial.printf("BLE:       %s\n", BleService::instance().isAdvertising() ? "Advertising" : "Stopped");
    Serial.printf("  Address: %s\n", BleService::instance().getAddress().c_str());
    printSeparator();
}

void SerialConsole::cmdOpen(const String& args) {
    NukiDriver* nuki = static_cast<NukiDriver*>(_hardware);
    if (!nuki || !nuki->isPaired()) { Serial.println("[Console] NUKI not paired"); return; }
    uint32_t ms = args.isEmpty() ? 0 : (uint32_t)args.toInt();
    bool ok = nuki->open(ms);
    Serial.printf("[Console] open -> %s\n", ok ? "OK" : "FAILED");
}

void SerialConsole::cmdClose() {
    NukiDriver* nuki = static_cast<NukiDriver*>(_hardware);
    if (!nuki || !nuki->isPaired()) { Serial.println("[Console] NUKI not paired"); return; }
    bool ok = nuki->close();
    Serial.printf("[Console] close -> %s\n", ok ? "OK" : "FAILED");
}

void SerialConsole::cmdConfig(const String& args) {
    int sp = args.indexOf(' ');
    String sub  = sp >= 0 ? args.substring(0, sp) : args;
    String rest = sp >= 0 ? args.substring(sp + 1) : "";
    sub.toLowerCase();

    if (sub == "show") {
        printSeparator();
        Serial.printf("wifi_ssid:        %s\n", Config().getWifiSSID().c_str());
        Serial.printf("open_duration_ms: %u\n", Config().getOpenDurationMs());
        Serial.printf("nuki_address:     %s\n", Config().getNukiAddress().c_str());
        Serial.printf("nuki_paired:      %s\n", Config().isNukiPaired() ? "yes" : "no");
        Serial.printf("device_name:      %s\n", Config().getDeviceName().c_str());
        Serial.printf("is_configured:    %s\n", Config().isConfigured() ? "yes" : "no");
        printSeparator();

    } else if (sub == "wifi") {
        int s2 = rest.indexOf(' ');
        String ssid = s2 >= 0 ? rest.substring(0, s2) : rest;
        String pass = s2 >= 0 ? rest.substring(s2 + 1) : "";
        if (ssid.isEmpty()) { Serial.println("[Console] Usage: config wifi <SSID> <PASS>"); return; }
        Config().setWifi(ssid, pass);
        Serial.printf("[Console] WiFi set to '%s'. Reconnecting...\n", ssid.c_str());
        Wifi().connectSTA(15000);

    } else if (sub == "duration") {
        uint32_t ms = (uint32_t)rest.toInt();
        if (ms < 100) { Serial.println("[Console] Min duration: 100ms"); return; }
        Config().setOpenDurationMs(ms);
        Serial.printf("[Console] Open duration set to %u ms\n", ms);

    } else if (sub == "reset") {
        Serial.println("[Console] Factory reset — rebooting...");
        Config().reset();
        delay(500);
        ESP.restart();

    } else {
        Serial.println("[Console] Subcommands: show | wifi | duration | reset");
    }
}

void SerialConsole::cmdBle(const String& args) {
    if (args == "info") {
        Serial.printf("[Console] BLE Address:      %s\n", BleService::instance().getAddress().c_str());
        Serial.printf("[Console] Service UUID:     %s\n", BleService::SERVICE_UUID);
    } else if (args == "advertise") {
        BleService::instance().startAdvertising();
        Serial.println("[Console] BLE advertising restarted");
    } else {
        Serial.println("[Console] Usage: ble info | ble advertise");
    }
}

void SerialConsole::cmdNuki(const String& args) {
    NukiDriver* nuki = static_cast<NukiDriver*>(_hardware);
    if (!nuki) { Serial.println("[Console] NUKI driver not active"); return; }

    if (args == "pair") {
        Serial.println("[Console] Press and hold the button on the NUKI lock...");
        bool ok = nuki->pair("", 30000);
        if (ok) Config().setHardwareNuki(Config().getNukiAddress(), true);
        Serial.printf("[Console] Pairing: %s\n", ok ? "SUCCESS" : "FAILED");

    } else if (args == "state") {
        NukiLock::KeyTurnerState state;
        if (nuki->requestState(state)) {
            Serial.printf("[Console] Lock state: %d\n", (int)state.lockState);
        } else {
            Serial.println("[Console] Failed to read state");
        }

    } else if (args == "unlock") {
        bool ok = nuki->unlock();
        Serial.printf("[Console] unlock -> %s\n", ok ? "OK" : "FAILED");

    } else if (args == "unlatch") {
        bool ok = nuki->unlatch();
        Serial.printf("[Console] unlatch -> %s\n", ok ? "OK" : "FAILED");

    } else if (args == "lock") {
        bool ok = nuki->lock();
        Serial.printf("[Console] lock -> %s\n", ok ? "OK" : "FAILED");

    } else {
        Serial.println("[Console] Usage: nuki pair | state | unlock | unlatch | lock");
    }
}

void SerialConsole::cmdSetup() {
    Serial.println("[Console] Restarting into setup mode...");
    Config().setConfigured(false);
    delay(500);
    ESP.restart();
}

void SerialConsole::cmdReboot() {
    Serial.println("[Console] Rebooting...");
    delay(500);
    ESP.restart();
}

void SerialConsole::cmdHelp() {
    printSeparator();
    Serial.println("DoorInterface Console Commands:");
    Serial.println();
    Serial.println("  status                 Show device status");
    Serial.println("  open [ms]              Open door (optional duration in ms)");
    Serial.println("  close                  Close door");
    Serial.println();
    Serial.println("  config show            Show all settings");
    Serial.println("  config wifi <SSID> <PASS>  Set WiFi credentials");
    Serial.println("  config duration <ms>   Set default open duration");
    Serial.println("  config reset           Factory reset");
    Serial.println();
    Serial.println("  ble info               Show BLE address and UUIDs");
    Serial.println("  ble advertise          Restart BLE advertising");
    Serial.println();
    Serial.println("  nuki pair              Start NUKI pairing");
    Serial.println("  nuki state             Read lock state");
    Serial.println("  nuki unlock            Unlock");
    Serial.println("  nuki unlatch           Unlatch (open door)");
    Serial.println("  nuki lock              Lock");
    Serial.println();
    Serial.println("  setup                  Restart into setup wizard");
    Serial.println("  reboot                 Reboot device");
    printSeparator();
}
