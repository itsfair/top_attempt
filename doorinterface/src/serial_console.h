#pragma once

#include <Arduino.h>
#include "hardware/door_hardware.h"

// USB Serial command interface for development and testing.
// Runs in its own FreeRTOS task on Core 1.
//
// Start with begin(). Pass the active hardware driver pointer.
// Update the hardware pointer with setHardware() after reconfiguration.
class SerialConsole {
public:
    static SerialConsole& instance() {
        static SerialConsole inst;
        return inst;
    }

    // Spawn the console task. hardware may be nullptr.
    void begin(DoorHardware* hardware);

    void setHardware(DoorHardware* hw) { _hardware = hw; }

private:
    SerialConsole() = default;
    SerialConsole(const SerialConsole&) = delete;
    SerialConsole& operator=(const SerialConsole&) = delete;

    // FreeRTOS task entry point
    static void task(void* param);

    void processLine(const String& line);

    // Command handlers
    void cmdStatus();
    void cmdOpen(const String& args);
    void cmdClose();
    void cmdConfig(const String& args);
    void cmdBle(const String& args);
    void cmdNuki(const String& args);
    void cmdSetup();
    void cmdReboot();
    void cmdHelp();

    void printSeparator();

    DoorHardware* _hardware = nullptr;
};

inline SerialConsole& Console() { return SerialConsole::instance(); }
