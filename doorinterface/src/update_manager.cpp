#include "update_manager.h"
#include "config_manager.h"

#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#include <esp_ota_ops.h>
#include <mbedtls/md.h>

#ifndef FIRMWARE_VERSION
#define FIRMWARE_VERSION "0.0.0"
#endif

static const char* TAG = "[Update]";
static const uint32_t PENDING_VERIFY_TIMEOUT_MS = 60000UL;

static String sha256Hex(const unsigned char* hash) {
    char hex[65];
    for (int i = 0; i < 32; i++) {
        sprintf(hex + i * 2, "%02x", hash[i]);
    }
    hex[64] = 0;
    return String(hex);
}

UpdateManager& UpdateManager::instance() {
    static UpdateManager inst;
    return inst;
}

String UpdateManager::getCurrentVersion() {
    return String(FIRMWARE_VERSION);
}

String UpdateManager::getManifestUrl() {
    return Config().getOtaManifestUrl();
}

String UpdateManager::getChannelLabel() {
    return Config().getOtaChannelLabel();
}

void UpdateManager::setManifestUrl(const String& url) {
    Config().setOtaManifestUrl(url);
}

void UpdateManager::tick() {
    if (_state == State::PENDING_VERIFY) {
        if (millis() - _pendingVerifyStartMs > PENDING_VERIFY_TIMEOUT_MS) {
            Serial.printf("%s Pending-verify timeout (%lu ms) — rolling back\n",
                          TAG, PENDING_VERIFY_TIMEOUT_MS);
            _error = "Pending-verify timeout";
            // Mark this app invalid, reboot into the previous partition.
            // Does not return.
            esp_ota_mark_app_invalid_rollback_and_reboot();
        }
        return;
    }

    if (_state == State::IDLE
        && Config().getOtaAutoCheck()
        && !_downloadInProgress
        && (millis() - _lastCheckMs) > (Config().getOtaCheckIntervalMin() * 60000UL)) {
        checkNow();
    }
}

void UpdateManager::checkNow() {
    if (_downloadInProgress) return;
    _downloadInProgress = true;
    _state = State::CHECKING;
    _error = "";
    Serial.printf("%s checkNow: %s\n", TAG, getManifestUrl().c_str());
    xTaskCreate(checkTask, "ota_check", 8192, nullptr, 1, nullptr);
}

void UpdateManager::startUpdate() {
    if (_downloadInProgress) return;
    if (_state != State::AVAILABLE) return;
    if (_downloadUrl.isEmpty() || _expectedSize == 0 || _expectedSha256.isEmpty()) {
        _error = "Missing manifest data";
        _state = State::FAILED;
        return;
    }
    _downloadInProgress = true;
    _state = State::DOWNLOADING;
    _progressPct = 0;
    _error = "";
    Serial.printf("%s startUpdate: v%s (%u bytes, sha256=%s...)\n", TAG,
                  _availableVersion.c_str(), (unsigned)_expectedSize,
                  _expectedSha256.substring(0, 12).c_str());
    xTaskCreate(updateTask, "ota_update", 16384, nullptr, 1, nullptr);
}

void UpdateManager::confirmBoot() {
    String v = getCurrentVersion();
    Config().setLastBootVersion(v);
    _state = State::IDLE;
    _error = "";
    Serial.printf("%s confirmBoot: v%s\n", TAG, v.c_str());
}

void UpdateManager::parseManifest(const String& json) {
    JsonDocument doc;
    if (deserializeJson(doc, json) != DeserializationError::Ok) {
        _error = "Manifest parse error";
        _state = State::FAILED;
        return;
    }
    _availableVersion = doc["version"].as<String>();
    _downloadUrl      = doc["url"].as<String>();
    _expectedSha256   = doc["sha256"].as<String>();
    _expectedSize     = doc["size"].as<size_t>();

    if (_availableVersion.isEmpty() || _downloadUrl.isEmpty()
        || _expectedSha256.isEmpty() || _expectedSize == 0) {
        _error = "Manifest incomplete";
        _state = State::FAILED;
        return;
    }

    String current = getCurrentVersion();
    if (_availableVersion == current) {
        Serial.printf("%s Manifest version (%s) matches current — nothing to do\n",
                      TAG, current.c_str());
        _state = State::IDLE;
    } else {
        Serial.printf("%s Update available: %s (current %s)\n", TAG,
                      _availableVersion.c_str(), current.c_str());
        _state = State::AVAILABLE;
    }
}

void UpdateManager::checkTask(void* /*p*/) {
    UpdateManager& m = UpdateManager::instance();

    WiFiClientSecure client;
    client.setInsecure();
    HTTPClient http;
    http.setFollowRedirects(HTTPC_STRICT_FOLLOW_REDIRECTS);

    bool ok = http.begin(client, m.getManifestUrl());
    if (!ok) {
        m._error = "Manifest HTTP begin failed";
        m._state = State::FAILED;
    } else {
        int code = http.GET();
        if (code != 200) {
            m._error = "Manifest HTTP " + String(code);
            m._state = State::FAILED;
        } else {
            String payload = http.getString();
            http.end();
            m.parseManifest(payload);
        }
        if (m._state == State::CHECKING) http.end();
    }

    m._lastCheckMs = millis();
    m._downloadInProgress = false;
    m._downloadDone = true;
    Serial.printf("%s checkTask done, state=%d\n", TAG, (int)m._state);
    vTaskDelete(nullptr);
}

void UpdateManager::updateTask(void* /*p*/) {
    UpdateManager& m = UpdateManager::instance();

    WiFiClientSecure client;
    client.setInsecure();
    HTTPClient http;
    http.setFollowRedirects(HTTPC_STRICT_FOLLOW_REDIRECTS);

    if (!http.begin(client, m._downloadUrl)) {
        m._error = "Firmware HTTP begin failed";
        m._state = State::FAILED;
        m._downloadInProgress = false;
        vTaskDelete(nullptr);
        return;
    }

    int code = http.GET();
    if (code != 200) {
        m._error = "Firmware HTTP " + String(code);
        http.end();
        m._state = State::FAILED;
        m._downloadInProgress = false;
        vTaskDelete(nullptr);
        return;
    }

    int total = http.getSize();
    if (total <= 0 || (size_t)total != m._expectedSize) {
        m._error = "Size mismatch (got " + String(total) +
                   ", expected " + String((unsigned)m._expectedSize) + ")";
        http.end();
        m._state = State::FAILED;
        m._downloadInProgress = false;
        vTaskDelete(nullptr);
        return;
    }

    if (!Update.begin((size_t)total)) {
        m._error = "Update.begin failed: " + String(Update.getError());
        http.end();
        m._state = State::FAILED;
        m._downloadInProgress = false;
        vTaskDelete(nullptr);
        return;
    }

    mbedtls_md_context_t ctx;
    mbedtls_md_init(&ctx);
    mbedtls_md_setup(&ctx, mbedtls_md_info_from_type(MBEDTLS_MD_SHA256), 0);
    mbedtls_md_starts(&ctx);

    WiFiClient* stream = http.getStreamPtr();
    uint8_t buf[1024];
    int written = 0;
    bool streamError = false;

    while (http.connected() && written < total) {
        size_t avail = stream->available();
        if (avail == 0) { delay(1); continue; }
        int toRead = (int)min(avail, (size_t)sizeof(buf));
        int n = stream->readBytes(buf, toRead);
        if (n <= 0) { streamError = true; break; }

        mbedtls_md_update(&ctx, buf, n);
        size_t wn = Update.write(buf, n);
        if (wn != (size_t)n) {
            m._error = "Update.write failed: " + String(Update.getError());
            mbedtls_md_free(&ctx);
            Update.abort();
            http.end();
            m._state = State::FAILED;
            m._downloadInProgress = false;
            vTaskDelete(nullptr);
            return;
        }

        written += n;
        m._progressPct = (int)((written * 100ULL) / (unsigned)total);
    }

    unsigned char hash[32];
    mbedtls_md_finish(&ctx, hash);
    mbedtls_md_free(&ctx);
    http.end();

    if (streamError) {
        m._error = "Stream read error after " + String(written) + " bytes";
        Update.abort();
        m._state = State::FAILED;
        m._downloadInProgress = false;
        vTaskDelete(nullptr);
        return;
    }

    String actual = sha256Hex(hash);
    if (!m._expectedSha256.equalsIgnoreCase(actual)) {
        m._error = "SHA-256 mismatch (got " + actual + ")";
        Update.abort();
        m._state = State::FAILED;
        m._downloadInProgress = false;
        vTaskDelete(nullptr);
        return;
    }

    if (!Update.end(true)) {
        m._error = "Update.end failed: " + String(Update.getError());
        m._state = State::FAILED;
        m._downloadInProgress = false;
        vTaskDelete(nullptr);
        return;
    }

    Serial.printf("%s Flash complete — entering PENDING_VERIFY (%lu ms)\n",
                  TAG, PENDING_VERIFY_TIMEOUT_MS);
    m._state = State::PENDING_VERIFY;
    m._pendingVerifyStartMs = millis();
    m._downloadInProgress = false;
    m._downloadSuccess = true;
    vTaskDelete(nullptr);
}
