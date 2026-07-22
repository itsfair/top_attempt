#include "Updater.h"
#include "config.h"
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <Update.h>

#define GITHUB_API_URL "https://api.github.com/repos/itsfair/top_attempt/releases/latest"
#define GITHUB_HOST "api.github.com"
#define GITHUB_ACCEPT "application/vnd.github+json"

void Updater::begin() {
    Serial.printf("[UPDATE] bereit, aktuelle Version: %s\n", FW_VERSION);
}

void Updater::loop() {
}

void Updater::checkForUpdate() {
    if (_state == CHECKING || _state == DOWNLOADING) return;
    setState(CHECKING);
    doCheck();
}

void Updater::startUpdate() {
    if (_state != UPDATE_AVAILABLE) return;
    setState(DOWNLOADING);
    _progress = 0;
    doDownload();
}

void Updater::doCheck() {
    WiFiClientSecure client;
    client.setInsecure();
    HTTPClient http;
    http.setReuse(false);
    http.setTimeout(15000);
    if (!http.begin(client, GITHUB_API_URL)) {
        fail("HTTP begin fehlgeschlagen");
        return;
    }
    http.addHeader("Accept", GITHUB_ACCEPT);
    http.addHeader("User-Agent", "DoorInterface-ESP32");
    int code = http.GET();
    if (code != 200) {
        http.end();
        fail("GitHub API HTTP " + String(code));
        return;
    }
    String body = http.getString();
    http.end();

    String tag = extractJsonField(body, "tag_name");
    if (tag.length() == 0) {
        fail("tag_name nicht gefunden");
        return;
    }
    _latest = stripFwPrefix(tag);
    Serial.printf("[UPDATE] GitHub latest tag: %s, version: %s\n", tag.c_str(), _latest.c_str());

    String url = "";
    int assetPos = 0;
    while (true) {
        int bUrl = body.indexOf("\"browser_download_url\"", assetPos);
        if (bUrl < 0) break;
        int c = body.indexOf(':', bUrl);
        int q1 = body.indexOf('"', c + 1);
        int q2 = body.indexOf('"', q1 + 1);
        String assetUrl = body.substring(q1 + 1, q2);
        if (assetUrl.endsWith("firmware.bin")) {
            url = assetUrl;
            break;
        }
        assetPos = q2 + 1;
    }
    if (url.length() == 0) {
        fail("Kein firmware.bin Asset im Release gefunden");
        return;
    }
    _downloadUrl = url;
    Serial.printf("[UPDATE] Download-URL: %s\n", url.c_str());

    String current = String(FW_VERSION);
    if (_latest == current) {
        Serial.println("[UPDATE] Firmware ist aktuell");
        setState(IDLE);
    } else {
        Serial.printf("[UPDATE] Update verfuegbar: %s -> %s\n", current.c_str(), _latest.c_str());
        setState(UPDATE_AVAILABLE);
    }
}

void Updater::doDownload() {
    WiFiClientSecure client;
    client.setInsecure();
    HTTPClient http;
    http.setReuse(false);
    http.setTimeout(60000);
    String url = _downloadUrl;
    int redirectCount = 0;
    int code = 0;
    while (redirectCount < 5) {
        if (!http.begin(client, url)) {
            fail("HTTP begin fehlgeschlagen");
            return;
        }
        const char* hdrs[] = {"location"};
        http.collectHeaders(hdrs, 1);
        http.addHeader("User-Agent", "DoorInterface-ESP32");
        code = http.GET();
        Serial.printf("[UPDATE] HTTP code=%d, headers=%d\n", code, http.headers());
        if (code == 301 || code == 302 || code == 307 || code == 308) {
            String loc = http.header("location");
            Serial.printf("[UPDATE] Redirect %d -> %s\n", code, loc.c_str());
            http.end();
            if (loc.length() == 0) { fail("Location-Header leer"); return; }
            url = loc;
            redirectCount++;
            continue;
        }
        break;
    }
    if (code != 200) {
        http.end();
        fail("Download HTTP " + String(code));
        return;
    }
    _total = http.getSize();
    if (_total <= 0) {
        http.end();
        fail("Content-Length fehlt");
        return;
    }
    Serial.printf("[UPDATE] Download start, size: %u bytes\n", (unsigned)_total);

    if (!Update.begin(_total, U_FLASH)) {
        http.end();
        fail("Update.begin fehlgeschlagen");
        return;
    }

    WiFiClient* stream = http.getStreamPtr();
    uint8_t buf[1024];
    size_t written = 0;
    while (http.connected() && written < _total) {
        size_t avail = stream->available();
        if (avail == 0) {
            delay(1);
            continue;
        }
        int read = stream->readBytes(buf, ((avail < sizeof(buf)) ? avail : sizeof(buf)));
        if (read <= 0) continue;
        size_t wr = Update.write(buf, read);
        if (wr != (size_t)read) {
            http.end();
            fail("Update.write mismatch");
            return;
        }
        written += wr;
        _progress = written;
    }
    http.end();

    if (written != _total) {
        fail("Download unvollstaendig");
        return;
    }
    if (!Update.end()) {
        fail("Update.end fehlgeschlagen: " + String(Update.getError()));
        return;
    }
    Serial.println("[UPDATE] Flash erfolgreich, Neustart erforderlich");
    setState(DONE);
}

String Updater::getStatusJson() {
    const char* stateStr = "IDLE";
    switch (_state) {
        case IDLE: stateStr = "IDLE"; break;
        case CHECKING: stateStr = "CHECKING"; break;
        case UPDATE_AVAILABLE: stateStr = "UPDATE_AVAILABLE"; break;
        case DOWNLOADING: stateStr = "DOWNLOADING"; break;
        case DONE: stateStr = "DONE"; break;
        case FAILED: stateStr = "FAILED"; break;
    }
    String json = "{";
    json += "\"state\":\"" + String(stateStr) + "\"";
    json += ",\"current\":\"" + String(FW_VERSION) + "\"";
    json += ",\"latest\":\"" + _latest + "\"";
    json += ",\"progress\":" + String((unsigned)_progress);
    json += ",\"total\":" + String((unsigned)_total);
    json += ",\"error\":\"" + _error + "\"";
    json += "}";
    return json;
}

void Updater::setState(State s) {
    _state = s;
    if (s == IDLE || s == DONE || s == FAILED) {
        Serial.printf("[UPDATE] state=%s\n", s == IDLE ? "IDLE" : (s == DONE ? "DONE" : "FAILED"));
    }
}

void Updater::fail(const String& msg) {
    _error = msg;
    Serial.printf("[UPDATE] FEHLER: %s\n", msg.c_str());
    setState(FAILED);
}

String Updater::extractJsonField(const String& json, const String& key) {
    String needle = "\"" + key + "\"";
    int k = json.indexOf(needle);
    if (k < 0) return "";
    int c = json.indexOf(':', k);
    if (c < 0) return "";
    int q1 = json.indexOf('"', c + 1);
    if (q1 < 0) return "";
    int q2 = json.indexOf('"', q1 + 1);
    if (q2 < 0) return "";
    return json.substring(q1 + 1, q2);
}

String Updater::stripFwPrefix(const String& tag) {
    if (tag.startsWith("fw-v")) return tag.substring(4);
    if (tag.startsWith("fw-")) return tag.substring(3);
    if (tag.startsWith("v")) return tag.substring(1);
    return tag;
}