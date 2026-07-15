#include "NukiManager.h"

NukiManager::NukiManager()
    : _nukiLock("DoorInterface", 123456) {}

void NukiManager::begin() {
    Serial.println("[NUKI] init");
    _scanner.initialize();
    _nukiLock.registerBleScanner(&_scanner);
    _nukiLock.initialize();
    _nukiLock.setEventHandler(this);
    Serial.printf("[NUKI] paired: %s, hasUltraPin: %s\n",
        _nukiLock.isPairedWithLock() ? "yes" : "no",
        hasUltraPin() ? "yes" : "no");
    if (_nukiLock.isPairedWithLock()) {
        _stateUpdateNeeded = true;
    }
}

void NukiManager::loop() {
    _scanner.update();
    _nukiLock.updateConnectionState();

    unsigned long now = millis();
    if (_nukiLock.isPairedWithLock() && !_hasState && now - _lastStateAttempt >= _stateRetryInterval) {
        _stateUpdateNeeded = true;
    }
    if (_nukiLock.isPairedWithLock() && _hasState && now - _lastStateRefresh >= _stateRefreshInterval) {
        _stateUpdateNeeded = true;
    }

    if (_stateUpdateNeeded && _nukiLock.isPairedWithLock()) {
        _stateUpdateNeeded = false;
        _lastStateAttempt = millis();
        Serial.println("[NUKI] Versuche State-Request");
        Nuki::CmdResult result = _nukiLock.requestKeyTurnerState(&_lastState);
        if (result == Nuki::CmdResult::Success) {
            _hasState = true;
            _lastStateRefresh = millis();
            char stateStr[32];
            NukiLock::lockstateToString(_lastState.lockState, stateStr);
            Serial.printf("[NUKI] State: %s, Battery: %d%%\n", stateStr, _nukiLock.getBatteryPerc());
        } else {
            Serial.printf("[NUKI] State-Request fehlgeschlagen (%d), retry in %lus\n", (int)result, _stateRetryInterval / 1000);
            _scanner.enableScanning(true);
        }
    }

    if (_pairingRequested) {
        if (millis() - _pairingStart > _pairingTimeout) {
            _pairingRequested = false;
            Serial.println("[NUKI] Pairing-Timeout");
        } else {
            Nuki::PairingResult result = _nukiLock.pairNuki();
            if (result == Nuki::PairingResult::Success) {
                _pairingRequested = false;
                _stateUpdateNeeded = true;
                Serial.println("[NUKI] Pairing erfolgreich");
            }
        }
    }
}

bool NukiManager::isPaired() { return _nukiLock.isPairedWithLock(); }
bool NukiManager::isPairing() { return _pairingRequested; }

void NukiManager::startPairing() {
    if (_nukiLock.isPairedWithLock()) return;
    _pairingRequested = true;
    _pairingStart = millis();
    Serial.println("[NUKI] Pairing gestartet");
}

void NukiManager::cancelPairing() {
    _pairingRequested = false;
    Serial.println("[NUKI] Pairing abgebrochen");
}

void NukiManager::setUltraPin(uint32_t pin) {
    if (pin == 0) {
        Serial.println("[NUKI] Ultra-PIN geleert");
        _nukiLock.saveUltraPincode(0, true);
    } else {
        Serial.printf("[NUKI] Ultra-PIN gesetzt: %06lu\n", pin);
        _nukiLock.saveUltraPincode(pin, true);
    }
}

bool NukiManager::hasUltraPin() {
    return _nukiLock.getUltraPincode() != 0;
}

String NukiManager::getLockStateStr() {
    if (!_hasState) return "unknown";
    char buf[32];
    NukiLock::lockstateToString(_lastState.lockState, buf);
    return String(buf);
}

int NukiManager::getBatteryPct() {
    if (!_hasState) return -1;
    return _nukiLock.getBatteryPerc();
}

bool NukiManager::isBatteryCritical() {
    if (!_hasState) return false;
    return _nukiLock.isBatteryCritical();
}

int NukiManager::getRssi() {
    return _nukiLock.getRssi();
}

bool NukiManager::unlock() {
    if (!_nukiLock.isPairedWithLock()) return false;
    Serial.println("[NUKI] Unlock");
    Nuki::CmdResult result = _nukiLock.lockAction(NukiLock::LockAction::Unlock);
    if (result == Nuki::CmdResult::Success) {
        _stateUpdateNeeded = true;
        return true;
    }
    Serial.printf("[NUKI] Unlock failed: %d\n", (int)result);
    return false;
}

bool NukiManager::lock() {
    if (!_nukiLock.isPairedWithLock()) return false;
    Serial.println("[NUKI] Lock");
    Nuki::CmdResult result = _nukiLock.lockAction(NukiLock::LockAction::Lock);
    if (result == Nuki::CmdResult::Success) {
        _stateUpdateNeeded = true;
        return true;
    }
    Serial.printf("[NUKI] Lock failed: %d\n", (int)result);
    return false;
}

bool NukiManager::unlatch() {
    if (!_nukiLock.isPairedWithLock()) return false;
    Serial.println("[NUKI] Unlatch (Tuer oeffnen)");
    Nuki::CmdResult result = _nukiLock.lockAction(NukiLock::LockAction::Unlatch);
    if (result == Nuki::CmdResult::Success) {
        _stateUpdateNeeded = true;
        return true;
    }
    Serial.printf("[NUKI] Unlatch failed: %d\n", (int)result);
    return false;
}

bool NukiManager::unpair() {
    if (!_nukiLock.isPairedWithLock()) return false;
    Serial.println("[NUKI] Unpair");
    _nukiLock.unPairNuki();
    _hasState = false;
    Serial.println("[NUKI] Unpair abgeschlossen");
    return true;
}

void NukiManager::notify(Nuki::EventType eventType) {
    if (eventType == Nuki::EventType::KeyTurnerStatusUpdated) {
        _stateUpdateNeeded = true;
    }
}
