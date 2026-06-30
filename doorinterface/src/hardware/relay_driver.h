#pragma once

#include "door_hardware.h"
#include "../config_manager.h"

// Controls a door strike / magnetic lock via a GPIO relay.
//
// Normally Open (NO):  GPIO HIGH = relay closed = door open
// Normally Closed (NC): GPIO HIGH = relay open  = door open (inverted)
//
// Auto-close is handled via a FreeRTOS timer.
class RelayDriver : public DoorHardware {
public:
    RelayDriver();
    ~RelayDriver() override;

    bool begin() override;
    bool open(uint32_t durationMs = 0) override;
    bool close() override;
    DoorState getState() override;
    String getTypeName() override { return "relay"; }
    bool isReady() override { return _ready; }

private:
    // FreeRTOS timer callback for auto-close
    static void autoCloseCallback(TimerHandle_t timer);

    void applyState(bool active); // true = door open

    uint8_t       _pin;
    bool          _normallyClosed;
    uint32_t      _defaultDurationMs;
    DoorState     _state;
    bool          _ready;
    TimerHandle_t _autoCloseTimer;
};
