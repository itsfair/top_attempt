#include "relay_driver.h"

RelayDriver::RelayDriver()
    : _pin(18),
      _normallyClosed(false),
      _defaultDurationMs(3000),
      _state(DoorState::UNKNOWN),
      _ready(false),
      _autoCloseTimer(nullptr) {}

RelayDriver::~RelayDriver() {
    if (_autoCloseTimer) {
        xTimerDelete(_autoCloseTimer, 0);
        _autoCloseTimer = nullptr;
    }
}

bool RelayDriver::begin() {
    _pin                = Config().getRelayPin();
    _normallyClosed     = Config().isRelayNC();
    _defaultDurationMs  = Config().getOpenDurationMs();

    pinMode(_pin, OUTPUT);
    applyState(false); // Start closed
    _state = DoorState::CLOSED;
    _ready = true;

    // Create the auto-close timer (one-shot, not started yet)
    _autoCloseTimer = xTimerCreate(
        "relay_close",
        pdMS_TO_TICKS(_defaultDurationMs),
        pdFALSE,   // one-shot
        this,      // pvTimerID = pointer to this driver
        autoCloseCallback
    );

    Serial.printf("[Relay] Initialized on GPIO %d (%s)\n",
                  _pin, _normallyClosed ? "NC" : "NO");
    return true;
}

bool RelayDriver::open(uint32_t durationMs) {
    if (!_ready) {
        Serial.println("[Relay] Not ready");
        return false;
    }

    uint32_t duration = (durationMs > 0) ? durationMs : _defaultDurationMs;

    // Stop any running auto-close timer
    if (_autoCloseTimer && xTimerIsTimerActive(_autoCloseTimer)) {
        xTimerStop(_autoCloseTimer, 0);
    }

    applyState(true);
    _state = DoorState::OPEN;
    Serial.printf("[Relay] OPEN for %u ms\n", duration);

    // Start auto-close timer
    if (duration > 0 && _autoCloseTimer) {
        xTimerChangePeriod(_autoCloseTimer, pdMS_TO_TICKS(duration), 0);
        xTimerStart(_autoCloseTimer, 0);
    }

    return true;
}

bool RelayDriver::close() {
    if (!_ready) return false;

    // Cancel any pending auto-close
    if (_autoCloseTimer && xTimerIsTimerActive(_autoCloseTimer)) {
        xTimerStop(_autoCloseTimer, 0);
    }

    applyState(false);
    _state = DoorState::CLOSED;
    Serial.println("[Relay] CLOSED");
    return true;
}

DoorState RelayDriver::getState() {
    return _state;
}

void RelayDriver::applyState(bool active) {
    // active = true means door should be open
    // NC: active HIGH closes the normally-closed relay → door opens
    // NO: active HIGH closes the normally-open relay → door closes... wait:
    //   NO relay: coil energised = contacts closed = door strike powered = door open
    //   NC relay: coil energised = contacts open  = door strike depowered = depends on lock
    // We map "active" to "HIGH for NO" and "LOW for NC":
    bool pinHigh = _normallyClosed ? !active : active;
    digitalWrite(_pin, pinHigh ? HIGH : LOW);
}

// static
void RelayDriver::autoCloseCallback(TimerHandle_t timer) {
    RelayDriver* self = static_cast<RelayDriver*>(pvTimerGetTimerID(timer));
    if (self) {
        self->applyState(false);
        self->_state = DoorState::CLOSED;
        Serial.println("[Relay] Auto-close triggered");
    }
}
