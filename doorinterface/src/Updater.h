#pragma once

#include <Arduino.h>

class Updater {
public:
    enum State { IDLE, CHECKING, UPDATE_AVAILABLE, DOWNLOADING, DONE, FAILED };

    void begin();
    void loop();
    void checkForUpdate();
    void startUpdate();
    String getStatusJson();

private:
    State _state = IDLE;
    String _latest = "";
    String _downloadUrl = "";
    size_t _progress = 0;
    size_t _total = 0;
    String _error = "";

    void setState(State s);
    void fail(const String& msg);
    void doCheck();
    void doDownload();
    String extractJsonField(const String& json, const String& key);
    String stripFwPrefix(const String& tag);
};