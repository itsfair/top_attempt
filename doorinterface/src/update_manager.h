#pragma once

#include <Arduino.h>
#include <Update.h>

class UpdateManager {
public:
    enum class State { IDLE, CHECKING, AVAILABLE, DOWNLOADING,
                       INSTALLED, PENDING_VERIFY, FAILED };

    static UpdateManager& instance();

    // Periodic check + pending-verify watchdog. Call from a 1 Hz task or loop().
    void tick();

    // Trigger an immediate check. Non-blocking — runs in a FreeRTOS task.
    void checkNow();

    // Start downloading + flashing the available update. Non-blocking.
    void startUpdate();

    // Acknowledge the running firmware as good (cancels pending-verify rollback).
    // Persists lastBootVersion to NVS.
    void confirmBoot();

    // Override the NVS-stored manifest URL (persists).
    void setManifestUrl(const String& url);

    String getCurrentVersion();
    String getAvailableVersion() const { return _availableVersion; }
    String getManifestUrl();
    String getChannelLabel();
    State  getState() const { return _state; }
    int    getProgressPct() const { return _progressPct; }
    String getError() const { return _error; }

private:
    UpdateManager() = default;
    UpdateManager(const UpdateManager&) = delete;
    UpdateManager& operator=(const UpdateManager&) = delete;

    void parseManifest(const String& json);
    static void updateTask(void*);
    static void checkTask(void*);

    volatile State _state = State::IDLE;
    String  _availableVersion;
    String  _downloadUrl;
    String  _expectedSha256;
    size_t  _expectedSize = 0;
    int     _progressPct = 0;
    String  _error;
    uint32_t _lastCheckMs = 0;
    uint32_t _pendingVerifyStartMs = 0;
    bool    _downloadInProgress = false;
    volatile bool _downloadDone = false;
    bool    _downloadSuccess = false;
};

inline UpdateManager& Update() { return UpdateManager::instance(); }
