#pragma once

#include <Arduino.h>

enum class DoorState {
    CLOSED,
    OPEN,
    UNKNOWN
};

// Abstract base class for all door hardware drivers.
// Add new hardware types by subclassing this.
class DoorHardware {
public:
    virtual ~DoorHardware() = default;

    // Initialize the hardware. Returns true on success.
    virtual bool begin() = 0;

    // Open the door. durationMs=0 uses the configured default duration.
    // Returns true if the command was sent successfully.
    virtual bool open(uint32_t durationMs = 0) = 0;

    // Close the door (cancel auto-close / actively lock).
    // Returns true if the command was sent successfully.
    virtual bool close() = 0;

    // Get the current door state.
    virtual DoorState getState() = 0;

    // Human-readable driver name, e.g. "relay" or "nuki".
    virtual String getTypeName() = 0;

    // True if the driver is ready to receive commands.
    virtual bool isReady() = 0;
};
